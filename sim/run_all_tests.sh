#!/usr/bin/env bash
# Run every UVM test through sim/Makefile with configurable parallelism.
# CentOS 7 compatible: does not rely on Bash "wait -n".

set -uo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

if [[ -n ${SIM_DIR:-} ]]; then
  [[ -f "$SIM_DIR/Makefile" ]] || {
    printf 'ERROR: SIM_DIR does not contain a Makefile: %s\n' "$SIM_DIR" >&2
    exit 2
  }
  SIM_DIR=$(cd "$SIM_DIR" && pwd)
elif [[ -f "$SCRIPT_DIR/Makefile" ]]; then
  SIM_DIR=$SCRIPT_DIR
elif [[ -f "$SCRIPT_DIR/sim/Makefile" ]]; then
  SIM_DIR=$SCRIPT_DIR/sim
else
  printf 'ERROR: cannot find sim/Makefile. Put this script in the project root or sim directory.\n' >&2
  exit 2
fi

TEST_DIR=${TEST_DIR:-$SIM_DIR/../tb/test}
LOG_DIR=${LOG_DIR:-$SIM_DIR/log}
TEST_PATTERN=${TEST_PATTERN:-test_*.sv}
JOBS=${JOBS:-1}
SEED=${SEED:-1}
BUILD_TARGET=${BUILD_TARGET:-comp}
RUN_TARGET=${RUN_TARGET:-run}
DO_BUILD=1
LIST_ONLY=0

declare -a EXTRA_MAKE_ARGS=()
declare -a REQUESTED_TESTS=()

usage() {
  cat <<'EOF'
Usage:
  ./run_all_tests.sh [options] [test_name ...]

Options:
  -j, --jobs N             Maximum concurrent simulations (default: 1)
  -s, --seed N             Pass SEED=N to Makefile (default: 1)
  -d, --test-dir DIR       Directory containing test .sv files
  -p, --pattern GLOB       Test filename pattern (default: test_*.sv)
      --build-target NAME  Build target executed once (default: comp)
      --run-target NAME    Per-test Make target (default: run)
      --no-build           Skip the build step
      --make-arg ARG       Extra Make argument; may be repeated
      --list               List discovered tests without running them
  -h, --help               Show this help

Examples:
  ./run_all_tests.sh
  ./run_all_tests.sh -j 4
  ./run_all_tests.sh -j 4 -s 123 test_sanity test_raw
  ./run_all_tests.sh --no-build --run-target all -j 2

Environment variables:
  JOBS, SEED, TEST_DIR, LOG_DIR, TEST_PATTERN, BUILD_TARGET, RUN_TARGET
EOF
}

die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 2
}

while (($# > 0)); do
  case "$1" in
    -j|--jobs)
      (($# >= 2)) || die "$1 requires a value"
      JOBS=$2
      shift 2
      ;;
    -s|--seed)
      (($# >= 2)) || die "$1 requires a value"
      SEED=$2
      shift 2
      ;;
    -d|--test-dir)
      (($# >= 2)) || die "$1 requires a value"
      TEST_DIR=$2
      shift 2
      ;;
    -p|--pattern)
      (($# >= 2)) || die "$1 requires a value"
      TEST_PATTERN=$2
      shift 2
      ;;
    --build-target)
      (($# >= 2)) || die "$1 requires a value"
      BUILD_TARGET=$2
      shift 2
      ;;
    --run-target)
      (($# >= 2)) || die "$1 requires a value"
      RUN_TARGET=$2
      shift 2
      ;;
    --no-build)
      DO_BUILD=0
      shift
      ;;
    --make-arg)
      (($# >= 2)) || die "$1 requires a value"
      EXTRA_MAKE_ARGS+=("$2")
      shift 2
      ;;
    --list)
      LIST_ONLY=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      while (($# > 0)); do
        REQUESTED_TESTS+=("$1")
        shift
      done
      ;;
    -*)
      die "unknown option: $1"
      ;;
    *)
      REQUESTED_TESTS+=("$1")
      shift
      ;;
  esac
done

[[ $JOBS =~ ^[1-9][0-9]*$ ]] || die "jobs must be a positive integer: $JOBS"
[[ -d "$TEST_DIR" ]] || die "test directory does not exist: $TEST_DIR"
[[ -f "$SIM_DIR/Makefile" ]] || die "Makefile does not exist: $SIM_DIR/Makefile"

TEST_DIR=$(cd "$TEST_DIR" && pwd)
mkdir -p "$LOG_DIR" || die "cannot create log directory: $LOG_DIR"
LOG_DIR=$(cd "$LOG_DIR" && pwd)

normalize_test_name() {
  local name
  name=$(basename "$1")
  name=${name%.sv}
  [[ $name =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] || die "invalid test name: $1"
  printf '%s\n' "$name"
}

declare -a TESTS=()

if ((${#REQUESTED_TESTS[@]} > 0)); then
  for requested in "${REQUESTED_TESTS[@]}"; do
    TESTS+=("$(normalize_test_name "$requested")")
  done
else
  DISCOVERY_FILE=$(mktemp "$LOG_DIR/.run_all_tests.XXXXXX") || \
    die "cannot create a temporary test list"
  find "$TEST_DIR" -type f -name "$TEST_PATTERN" -printf '%f\n' | \
    LC_ALL=C sort > "$DISCOVERY_FILE"
  while IFS= read -r test_file; do
    TESTS+=("$(normalize_test_name "$test_file")")
  done < "$DISCOVERY_FILE"
  command rm -f -- "$DISCOVERY_FILE"
fi

((${#TESTS[@]} > 0)) || die "no test files matched '$TEST_PATTERN' under $TEST_DIR"

# Reject duplicate class/file basenames, which would make logs ambiguous.
declare -A SEEN_TESTS=()
for test_name in "${TESTS[@]}"; do
  [[ -z ${SEEN_TESTS[$test_name]+x} ]] || die "duplicate test name: $test_name"
  SEEN_TESTS[$test_name]=1
done

if ((LIST_ONLY)); then
  printf '%s\n' "${TESTS[@]}"
  exit 0
fi

printf 'Simulation directory : %s\n' "$SIM_DIR"
printf 'Test directory       : %s\n' "$TEST_DIR"
printf 'Log directory        : %s\n' "$LOG_DIR"
printf 'Test count           : %d\n' "${#TESTS[@]}"
printf 'Parallel jobs        : %d\n' "$JOBS"

if ((DO_BUILD)); then
  printf '\n[BUILD] make %s\n' "$BUILD_TARGET"
  if ! make --no-print-directory -C "$SIM_DIR" "$BUILD_TARGET" "${EXTRA_MAKE_ARGS[@]}"; then
    printf '[BUILD FAIL] tests were not started.\n' >&2
    exit 1
  fi
fi

# A Makefile clean/comp target may remove generated directories.
mkdir -p "$LOG_DIR" || die "cannot recreate log directory after build: $LOG_DIR"

run_one_test() {
  local test_name=$1
  local log_file=$LOG_DIR/$test_name.log
  local console_file=$LOG_DIR/.$test_name.console.$$
  local make_rc=0

  # LOG/LOG_FILE/LOG_DIR are command-line Make variables. Existing Makefiles
  # that use any of them will also place the simulator's own -l output here.
  # Console capture is separate to avoid two writers opening the same file.
  : > "$log_file"
  make --no-print-directory -C "$SIM_DIR" "$RUN_TARGET" \
    "TEST=$test_name" \
    "SEED=$SEED" \
    "LOG_DIR=$LOG_DIR" \
    "LOG=$log_file" \
    "LOG_FILE=$log_file" \
    "${EXTRA_MAKE_ARGS[@]}" > "$console_file" 2>&1 || make_rc=$?

  if [[ -s "$console_file" ]]; then
    if [[ -s "$log_file" ]]; then
      printf '\n===== make console output =====\n' >> "$log_file"
    fi
    command cat "$console_file" >> "$log_file"
  fi
  command rm -f -- "$console_file"

  if ((make_rc != 0)); then
    return "$make_rc"
  fi

  # VCS can return zero even when UVM reported an error. Treat a non-zero
  # UVM_ERROR/UVM_FATAL summary as a failed testcase.
  if grep -Eq 'UVM_(ERROR|FATAL)[[:space:]]*:[[:space:]]*[1-9][0-9]*' "$log_file"; then
    return 1
  fi

  return 0
}

declare -a ACTIVE_PIDS=()
declare -a ACTIVE_TESTS=()
FAILED=0
COMPLETED=0

reap_finished_jobs() {
  local found=0
  local index pid test_name

  for index in "${!ACTIVE_PIDS[@]}"; do
    pid=${ACTIVE_PIDS[$index]}
    test_name=${ACTIVE_TESTS[$index]}

    if ! kill -0 "$pid" 2>/dev/null; then
      found=1
      if wait "$pid"; then
        printf '[PASS] %s  (%s)\n' "$test_name" "$LOG_DIR/$test_name.log"
      else
        printf '[FAIL] %s  (%s)\n' "$test_name" "$LOG_DIR/$test_name.log"
        FAILED=$((FAILED + 1))
      fi
      COMPLETED=$((COMPLETED + 1))
      unset 'ACTIVE_PIDS[index]'
      unset 'ACTIVE_TESTS[index]'
    fi
  done

  ACTIVE_PIDS=("${ACTIVE_PIDS[@]}")
  ACTIVE_TESTS=("${ACTIVE_TESTS[@]}")

  if ((found == 0)); then
    sleep 0.2
  fi
}

TOTAL=${#TESTS[@]}
STARTED=0

for test_name in "${TESTS[@]}"; do
  while ((${#ACTIVE_PIDS[@]} >= JOBS)); do
    reap_finished_jobs
  done

  STARTED=$((STARTED + 1))
  printf '[START %d/%d] %s\n' "$STARTED" "$TOTAL" "$test_name"
  run_one_test "$test_name" &
  ACTIVE_PIDS+=("$!")
  ACTIVE_TESTS+=("$test_name")
done

while ((${#ACTIVE_PIDS[@]} > 0)); do
  reap_finished_jobs
done

printf '\nCompleted: %d, Passed: %d, Failed: %d\n' \
  "$COMPLETED" "$((COMPLETED - FAILED))" "$FAILED"

((FAILED == 0))
