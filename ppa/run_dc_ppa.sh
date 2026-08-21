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

if [[ -z ${PPA_RUN_DIR:-} ]]; then
  RUN_STAMP=$(date +%Y%m%d_%H%M%S)
  PPA_RUN_DIR=$SCRIPT_DIR/runs/dc_$RUN_STAMP
  export PPA_RUN_DIR
fi

mkdir -p "$PPA_RUN_DIR"
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
