#!/usr/bin/env bash
# =============================================================================
# File        : run_tests_in_order.sh
# Description : 按 TEST_SEQUENCE 中配置的顺序，串行运行 UVM testcase。
# Platform    : CentOS 7+ / Bash 4.2+
#
# 使用方法：
#   1. 在下方 TEST_SEQUENCE 数组中增删或移动 testcase 名称；
#   2. chmod +x run_tests_in_order.sh
#   3. ./run_tests_in_order.sh
# =============================================================================

# 不启用 nounset：CentOS 7 自带 Bash 4.2 在展开空数组时与新版 Bash
# 行为不同；COMPILE_MAKE_ARGS/SIM_ARGS 允许保持为空。
set -o pipefail

# =============================================================================
# 用户配置区
# =============================================================================

# testcase 会严格按照数组中从上到下的顺序运行。
# 增加 testcase：添加一行 testcase 类名（不带 .sv）。
# 删除 testcase：删除或注释对应行。
# 调整顺序：直接移动对应行。
TEST_SEQUENCE=(
  test_aresetn_recovery
  test_norm_rd
  test_norm_wr
  test_norm_rdw
  test_norm_rdw_narrow_noalign
  test_norm_wrw
  test_norm_wrw_narrow_noalign
  
  test_funcov_incr_len_sweep
  test_funcov_wrap_aligned_len_sweep
  test_funcov_wrap_unaligned_len_sweep
  test_funcov_wrap_short_len_sweep
  test_funcov_b2b_mix_wrap_unaligned
  test_funcov_b2b_mix_wrap_aligned
  test_funcov_multi_req_gap_holes
  test_norm_mix
  test_watchdog_1023
  test_watchdog_1024
  test_watchdog_1100
  test_watchdog_normal_timeout
  test_timeout_same_axid_prev_rsp
  test_timeout_busy_context_same_axid
  test_watchdog_bufferable_1100
  test_watchdog_multi_timeout_cov
  test_watchdog_timer_wrap_cov
  test_watchdog_fifo_full_cov
  test_norm_mix_stresstest
  test_rwrap_stresstest
  test_tag_name_toggle

  test_err_rd
  test_err_wr
  test_err_rdw
  test_err_wrw
  test_err_mix
  test_err_mix_fixordkey

  test_buff_wr
  test_buff_wrw
  test_buff_mix
  test_buff_mix_fixordkey

  test_sameaxid_buf_err_alt
  test_sameaxid_norm_buf_err_allpairs
  test_buff_err_mix

  test_addrol_waw
  test_addrol_raw
  test_axi_rsp_error_mix
  test_rsp_order_deep_followers
  test_rsp_order_high_firstflag
  test_mix

  
)

# 仿真参数。也可以通过命令行 --seed/--verbosity 临时覆盖。
SEED=${SEED:-1}
UVM_VERBOSITY=${UVM_VERBOSITY:-UVM_MEDIUM}

# 1：运行 testcase 前执行一次 make comp；0：使用已有 simv。
DO_COMPILE=${DO_COMPILE:-1}

# 1：遇到第一个失败立即停止；0：继续运行后续 testcase，并在最后汇总。
STOP_ON_FAIL=${STOP_ON_FAIL:-1}

# 是否采集覆盖率。该值会同时传给 make comp 和每次 simv 运行。
COV=${COV:-1}

# 额外传给 make comp 的参数，可按需增删。
# 示例：COMPILE_MAKE_ARGS=("WAVE=0" "RTL_HOME=/path/to/rtl")
COMPILE_MAKE_ARGS=()

# 额外传给每次 simv 运行的参数，可按需增删。
# 示例：SIM_ARGS=("+num_txn=100" "+wrap_narrow=1")
SIM_ARGS=()

# =============================================================================
# 脚本实现区；通常不需要修改
# =============================================================================

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SIM_DIR=${SIM_DIR:-$SCRIPT_DIR}
TEST_DIR=${TEST_DIR:-$SIM_DIR/../tb/test}
LOG_DIR=${LOG_DIR:-$SIM_DIR/log}

LIST_ONLY=0

usage() {
  cat <<'EOF'
Usage: ./run_tests_in_order.sh [options]

Options:
  --list                  仅显示 testcase 运行顺序
  --no-compile            跳过 make comp
  --stop-on-fail          遇到第一个失败立即停止
  --seed N                设置随机种子
  --verbosity LEVEL       设置 UVM verbosity
  -h, --help              显示帮助

Examples:
  ./run_tests_in_order.sh
  ./run_tests_in_order.sh --list
  ./run_tests_in_order.sh --no-compile --seed 123
  ./run_tests_in_order.sh --stop-on-fail
EOF
}

die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 2
}

while (($# > 0)); do
  case "$1" in
    --list)
      LIST_ONLY=1
      shift
      ;;
    --no-compile)
      DO_COMPILE=0
      shift
      ;;
    --stop-on-fail)
      STOP_ON_FAIL=1
      shift
      ;;
    --seed)
      (($# >= 2)) || die "--seed requires a value"
      SEED=$2
      shift 2
      ;;
    --verbosity)
      (($# >= 2)) || die "--verbosity requires a value"
      UVM_VERBOSITY=$2
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "unknown option: $1"
      ;;
  esac
done

[[ $SEED =~ ^[0-9]+$ ]] || die "seed must be a non-negative integer: $SEED"
[[ $DO_COMPILE == 0 || $DO_COMPILE == 1 ]] || \
  die "DO_COMPILE must be 0 or 1: $DO_COMPILE"
[[ $STOP_ON_FAIL == 0 || $STOP_ON_FAIL == 1 ]] || \
  die "STOP_ON_FAIL must be 0 or 1: $STOP_ON_FAIL"
[[ $COV == 0 || $COV == 1 ]] || die "COV must be 0 or 1: $COV"
[[ -f "$SIM_DIR/Makefile" ]] || die "Makefile not found: $SIM_DIR/Makefile"
[[ -d "$TEST_DIR" ]] || die "test directory not found: $TEST_DIR"
((${#TEST_SEQUENCE[@]} > 0)) || die "TEST_SEQUENCE is empty"

# 在真正开始之前检查名称和源文件，避免运行到一半才发现配置错误。
for test_name in "${TEST_SEQUENCE[@]}"; do
  [[ $test_name =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] || \
    die "invalid testcase name in TEST_SEQUENCE: $test_name"
  [[ -f "$TEST_DIR/$test_name.sv" ]] || \
    die "testcase source not found: $TEST_DIR/$test_name.sv"
done

if ((LIST_ONLY)); then
  printf 'Configured testcase order (%d total):\n' "${#TEST_SEQUENCE[@]}"
  index=1
  for test_name in "${TEST_SEQUENCE[@]}"; do
    printf '  %02d. %s\n' "$index" "$test_name"
    index=$((index + 1))
  done
  exit 0
fi

mkdir -p "$LOG_DIR" || die "cannot create log directory: $LOG_DIR"
LOG_DIR=$(cd "$LOG_DIR" && pwd)
SUMMARY_FILE=$LOG_DIR/summary.log
: > "$SUMMARY_FILE"

printf 'Simulation directory : %s\n' "$SIM_DIR" | tee "$SUMMARY_FILE"
printf 'Test count           : %d\n' "${#TEST_SEQUENCE[@]}" | tee -a "$SUMMARY_FILE"
printf 'Seed                 : %s\n' "$SEED" | tee -a "$SUMMARY_FILE"
printf 'UVM verbosity        : %s\n' "$UVM_VERBOSITY" | tee -a "$SUMMARY_FILE"
printf 'Log directory        : %s\n' "$LOG_DIR" | tee -a "$SUMMARY_FILE"

if ((DO_COMPILE)); then
  COMPILE_LOG=$LOG_DIR/compile.log
  printf '\n[COMPILE] make comp\n' | tee -a "$SUMMARY_FILE"
  if ! make --no-print-directory -C "$SIM_DIR" comp \
      "COV=$COV" "${COMPILE_MAKE_ARGS[@]}" > "$COMPILE_LOG" 2>&1; then
    printf '[COMPILE FAIL] See %s\n' "$COMPILE_LOG" | tee -a "$SUMMARY_FILE" >&2
    exit 1
  fi
  printf '[COMPILE PASS]\n' | tee -a "$SUMMARY_FILE"
else
  [[ -x "$SIM_DIR/simv" ]] || \
    die "--no-compile was selected, but executable simv was not found"
fi

TOTAL=${#TEST_SEQUENCE[@]}
PASSED=0
FAILED=0
EXECUTED=0
index=1

for test_name in "${TEST_SEQUENCE[@]}"; do
  printf -v index_text '%02d' "$index"
  # test_xxx.sv 对应 sim/log/test_xxx.log。每次运行会覆盖同名旧日志。
  TEST_LOG=$LOG_DIR/$test_name.log
  : > "$TEST_LOG"

  printf '\n[%02d/%02d] RUN  %s\n' "$index" "$TOTAL" "$test_name" | \
    tee -a "$SUMMARY_FILE"

  run_rc=0
  declare -a coverage_args=()
  if ((COV)); then
    coverage_args=(
      -cm line+cond+fsm+tgl+branch+assert
      -cm_dir "$SIM_DIR/cov.vdb"
      -cm_name "${test_name}_${SEED}"
    )
  fi

  (
    cd "$SIM_DIR" || exit 2
    ./simv \
      "+UVM_TESTNAME=$test_name" \
      "+UVM_VERBOSITY=$UVM_VERBOSITY" \
      "+ntb_random_seed=$SEED" \
      "${coverage_args[@]}" \
      "${SIM_ARGS[@]}" \
      -l "$TEST_LOG"
  ) || run_rc=$?

  test_failed=0
  if ((run_rc != 0)); then
    test_failed=1
  elif grep -Eq '\*\*\* TEST FAILED \*\*\*' "$TEST_LOG"; then
    test_failed=1
  elif grep -Eq 'UVM_(ERROR|FATAL)[[:space:]]*:[[:space:]]*[1-9][0-9]*' \
      "$TEST_LOG"; then
    test_failed=1
  fi

  EXECUTED=$((EXECUTED + 1))
  if ((test_failed)); then
    FAILED=$((FAILED + 1))
    printf '[%02d/%02d] FAIL %s  log=%s\n' \
      "$index" "$TOTAL" "$test_name" "$TEST_LOG" | tee -a "$SUMMARY_FILE"

    if ((STOP_ON_FAIL)); then
      printf 'STOP_ON_FAIL=1, remaining testcase(s) will not run.\n' | \
        tee -a "$SUMMARY_FILE"
      break
    fi
  else
    PASSED=$((PASSED + 1))
    printf '[%02d/%02d] PASS %s  log=%s\n' \
      "$index" "$TOTAL" "$test_name" "$TEST_LOG" | tee -a "$SUMMARY_FILE"
  fi

  index=$((index + 1))
done

SKIPPED=$((TOTAL - EXECUTED))
printf '\n========== REGRESSION SUMMARY ==========\n' | tee -a "$SUMMARY_FILE"
printf 'Total configured : %d\n' "$TOTAL" | tee -a "$SUMMARY_FILE"
printf 'Executed         : %d\n' "$EXECUTED" | tee -a "$SUMMARY_FILE"
printf 'Passed           : %d\n' "$PASSED" | tee -a "$SUMMARY_FILE"
printf 'Failed           : %d\n' "$FAILED" | tee -a "$SUMMARY_FILE"
printf 'Skipped          : %d\n' "$SKIPPED" | tee -a "$SUMMARY_FILE"
printf 'Summary          : %s\n' "$SUMMARY_FILE" | tee -a "$SUMMARY_FILE"

if ((FAILED > 0)); then
  exit 1
fi

exit 0
