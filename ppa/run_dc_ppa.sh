#!/usr/bin/env bash
# =============================================================================
# Friendly launcher for dc_pre_layout_ppa.tcl.
#
# Usage:
#   ./ppa/run_dc_ppa.sh
#   DC_CLOCK_PERIOD_NS=5.0 ./ppa/run_dc_ppa.sh
#   DC_COMPILE_MODE=standard ./ppa/run_dc_ppa.sh
# =============================================================================

set -o pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
TCL_SCRIPT=$SCRIPT_DIR/dc_pre_layout_ppa.tcl
DC_BIN=${DC_SHELL_BIN:-dc_shell}

if ! command -v "$DC_BIN" >/dev/null 2>&1; then
  printf 'ERROR: dc_shell was not found in PATH: %s\n' "$DC_BIN" >&2
  printf 'Load the IC_EDA_Lite Synopsys environment, then retry.\n' >&2
  exit 2
fi

if [[ ! -f $TCL_SCRIPT ]]; then
  printf 'ERROR: DC Tcl script not found: %s\n' "$TCL_SCRIPT" >&2
  exit 2
fi

# Use one stable result directory by default.  A marker prevents an accidental
# recursive deletion if PPA_RUN_DIR is pointed at an unrelated directory.
if [[ -z ${PPA_RUN_DIR:-} ]]; then
  PPA_RUN_DIR=$SCRIPT_DIR/run
fi
export PPA_RUN_DIR

RUN_MARKER=$PPA_RUN_DIR/.axi_tniu_dc_ppa_run_dir

if [[ -e $PPA_RUN_DIR && ! -d $PPA_RUN_DIR ]]; then
  printf 'ERROR: PPA_RUN_DIR exists but is not a directory: %s\n' \
         "$PPA_RUN_DIR" >&2
  exit 2
fi

mkdir -p "$PPA_RUN_DIR"

if [[ -f $RUN_MARKER ]]; then
  # Remove only entries inside a directory previously created by this flow.
  # Keep the marker itself so subsequent invocations remain protected.
  if ! find "$PPA_RUN_DIR" -mindepth 1 -maxdepth 1 \
            ! -name "$(basename "$RUN_MARKER")" \
            -exec rm -rf -- {} +; then
    printf 'ERROR: failed to clear previous PPA results: %s\n' \
           "$PPA_RUN_DIR" >&2
    exit 2
  fi
elif [[ -n $(find "$PPA_RUN_DIR" -mindepth 1 -maxdepth 1 -print -quit) ]]; then
  printf 'ERROR: refusing to overwrite an unmarked non-empty directory: %s\n' \
         "$PPA_RUN_DIR" >&2
  printf 'Choose an empty PPA_RUN_DIR or use the default ppa/run directory.\n' >&2
  exit 2
else
  : > "$RUN_MARKER"
fi

LOG_FILE=$PPA_RUN_DIR/dc_shell.log

printf 'Design Compiler executable : %s\n' "$(command -v "$DC_BIN")"
printf 'Tcl flow script            : %s\n' "$TCL_SCRIPT"
printf 'PPA run directory          : %s\n' "$PPA_RUN_DIR"
printf 'Console log                : %s\n' "$LOG_FILE"

"$DC_BIN" -f "$TCL_SCRIPT" 2>&1 | tee "$LOG_FILE"
dc_status=${PIPESTATUS[0]}

if ((dc_status != 0)); then
  printf 'ERROR: Design Compiler flow failed; inspect %s\n' "$LOG_FILE" >&2
  exit "$dc_status"
fi

printf 'PPA flow completed successfully.\n'
printf 'Open summary: %s\n' "$PPA_RUN_DIR/reports/ppa_summary.rpt"
