# =============================================================================
# File        : dc_pre_layout_ppa.tcl
# Purpose     : Reproducible pre-layout PPA synthesis flow for axi_tniu
# Tool        : Synopsys Design Compiler / dc_shell (tested syntax target: 2018.x)
#
# What this flow does
#   1. Loads the TSMC 90 nm standard-cell timing/power library.
#   2. Analyzes and elaborates RTL only (no UVM/testbench sources).
#   3. Applies block-level clock, I/O and design-rule constraints.
#   4. Runs mapped synthesis using compile_ultra or compile.
#   5. Optionally annotates SAIF/VCD activity; otherwise uses vectorless activity.
#   6. Saves DDC, mapped Verilog, SDC and SDF outputs.
#   7. Generates timing, area, power, QoR and consistency reports.
#
# Recommended invocation
#   ./ppa/run_dc_ppa.sh
#
# Important
#   This is a pre-layout estimate.  Interconnect, clock-tree and routed
#   parasitics are not available, so the results are not post-layout signoff.
# =============================================================================

# -----------------------------------------------------------------------------
# Small Tcl helpers
# -----------------------------------------------------------------------------
proc env_or_default {name default_value} {
  global env
  if {[info exists env($name)] && $env($name) ne ""} {
    return $env($name)
  }
  return $default_value
}

proc fatal {message} {
  puts stderr "\nFATAL: $message\n"
  exit 2
}

proc require_file {path description} {
  if {![file exists $path] || ![file isfile $path]} {
    fatal "$description not found: $path"
  }
}

proc require_number {name value} {
  if {![string is double -strict $value]} {
    fatal "$name must be numeric, got: $value"
  }
}

proc collection_nonempty {collection_object} {
  if {[catch {sizeof_collection $collection_object} count]} {
    return 0
  }
  return [expr {$count > 0}]
}

# Run a non-essential report without aborting an otherwise valid synthesis.
proc optional_report {report_path report_body} {
  if {[catch {
    uplevel 1 [list redirect -file $report_path $report_body]
  } report_error]} {
    puts "WARNING: optional report failed: $report_path"
    puts "         $report_error"
  }
}

# -----------------------------------------------------------------------------
# Paths and run directory
# -----------------------------------------------------------------------------
set SCRIPT_DIR [file dirname [file normalize [info script]]]
set REPO_ROOT  [file normalize [file join $SCRIPT_DIR ..]]
set RUN_STAMP  [clock format [clock seconds] -format "%Y%m%d_%H%M%S"]

set DEFAULT_RUN_DIR [file join $SCRIPT_DIR run]
set RUN_DIR         [file normalize [env_or_default PPA_RUN_DIR $DEFAULT_RUN_DIR]]
set REPORT_DIR      [file join $RUN_DIR reports]
set OUTPUT_DIR      [file join $RUN_DIR outputs]
set DATABASE_DIR    [file join $RUN_DIR database]
set WORK_DIR        [file join $RUN_DIR work]
set ALIB_DIR        [file join $RUN_DIR alib]

foreach directory [list $RUN_DIR $REPORT_DIR $OUTPUT_DIR \
                        $DATABASE_DIR $WORK_DIR $ALIB_DIR] {
  file mkdir $directory
}

# -----------------------------------------------------------------------------
# User-overridable flow configuration
#
# Override any value from the shell, for example:
#   DC_CLOCK_PERIOD_NS=5.0 DC_COMPILE_MODE=ultra ./ppa/run_dc_ppa.sh
# -----------------------------------------------------------------------------
set TOP_DESIGN          [env_or_default DC_TOP_DESIGN          axi_tniu]
set RTL_DIR             [file normalize [env_or_default DC_RTL_DIR \
                                           [file join $REPO_ROOT rtl]]]
set HDL_FORMAT          [string tolower [env_or_default DC_HDL_FORMAT sverilog]]

set LIB_DIR             [file normalize [env_or_default DC_LIB_DIR \
                                           /home/ic_libs/TSMC.90/aci/sc-x/libspm]]
set TARGET_LIBRARY      [file normalize [env_or_default DC_TARGET_LIBRARY \
                                           [file join $LIB_DIR typical.db]]]
set OPERATING_CONDITION [env_or_default DC_OPERATING_CONDITION typical]

set CLOCK_PORT          [env_or_default DC_CLOCK_PORT          aclk]
set CLOCK_NAME          [env_or_default DC_CLOCK_NAME          aclk]
set RESET_PORT          [env_or_default DC_RESET_PORT          aresetn]
set CLOCK_PERIOD        [env_or_default DC_CLOCK_PERIOD_NS     10.0]
set CLOCK_UNCERTAINTY   [env_or_default DC_CLOCK_UNCERTAINTY_NS 0.10]
set CLOCK_TRANSITION    [env_or_default DC_CLOCK_TRANSITION_NS  0.10]
set INPUT_DELAY_MAX     [env_or_default DC_INPUT_DELAY_MAX_NS   1.00]
set INPUT_DELAY_MIN     [env_or_default DC_INPUT_DELAY_MIN_NS   0.50]
set OUTPUT_DELAY_MAX    [env_or_default DC_OUTPUT_DELAY_MAX_NS  1.00]
set OUTPUT_DELAY_MIN    [env_or_default DC_OUTPUT_DELAY_MIN_NS  0.00]
set INPUT_TRANSITION    [env_or_default DC_INPUT_TRANSITION_NS  0.20]
set OUTPUT_LOAD         [env_or_default DC_OUTPUT_LOAD_PF       0.05]
set MAX_TRANSITION      [env_or_default DC_MAX_TRANSITION_NS    0.80]
set MAX_FANOUT          [env_or_default DC_MAX_FANOUT           16]
set CRITICAL_RANGE      [env_or_default DC_CRITICAL_RANGE_NS    0.50]
set MAX_AREA            [env_or_default DC_MAX_AREA             0]

set COMPILE_MODE        [string tolower [env_or_default DC_COMPILE_MODE ultra]]
set RUN_INCREMENTAL     [env_or_default DC_RUN_INCREMENTAL 1]
set MAX_CORES           [env_or_default DC_MAX_CORES       4]
set TIMING_MAX_PATHS    [env_or_default DC_TIMING_MAX_PATHS 30]

# Optional activity inputs.  Priority: SAIF, then VCD, then vectorless defaults.
# Automatically use sim/wave.saif when it exists.  DC_SAIF_FILE can still be
# used to select a different testcase or power-mode activity file.
set DEFAULT_SAIF_FILE   [file normalize [file join $REPO_ROOT sim wave.saif]]
set SAIF_FILE           [env_or_default DC_SAIF_FILE ""]
if {$SAIF_FILE eq "" && [file isfile $DEFAULT_SAIF_FILE]} {
  set SAIF_FILE $DEFAULT_SAIF_FILE
}
set VCD_FILE            [env_or_default DC_VCD_FILE  ""]
set ACTIVITY_SCOPE      [env_or_default DC_ACTIVITY_SCOPE tb_top/dut]
set INPUT_STATIC_PROB   [env_or_default DC_INPUT_STATIC_PROBABILITY 0.5]
set INPUT_TOGGLE_RATE   [env_or_default DC_INPUT_TOGGLE_RATE        0.10]

foreach numeric_setting {
  CLOCK_PERIOD CLOCK_UNCERTAINTY CLOCK_TRANSITION
  INPUT_DELAY_MAX INPUT_DELAY_MIN OUTPUT_DELAY_MAX OUTPUT_DELAY_MIN
  INPUT_TRANSITION OUTPUT_LOAD MAX_TRANSITION MAX_FANOUT CRITICAL_RANGE
  MAX_AREA MAX_CORES TIMING_MAX_PATHS INPUT_STATIC_PROB INPUT_TOGGLE_RATE
} {
  require_number $numeric_setting [set $numeric_setting]
}

if {$CLOCK_PERIOD <= 0.0} {
  fatal "DC_CLOCK_PERIOD_NS must be greater than zero"
}
if {$COMPILE_MODE ne "ultra" && $COMPILE_MODE ne "standard"} {
  fatal "DC_COMPILE_MODE must be 'ultra' or 'standard', got: $COMPILE_MODE"
}
if {$HDL_FORMAT ne "sverilog" && $HDL_FORMAT ne "verilog"} {
  fatal "DC_HDL_FORMAT must be 'sverilog' or 'verilog', got: $HDL_FORMAT"
}

require_file $TARGET_LIBRARY "target library"

# Keep this list explicit and RTL-only.  This prevents accidental synthesis of
# UVM, interfaces, assertions or the simulation clock/reset generator.
set RTL_FILES [list \
  [file join $RTL_DIR axi_tniu.v] \
  [file join $RTL_DIR wrap_align.v] \
  [file join $RTL_DIR wrap_adjust.v] \
  [file join $RTL_DIR req_order.v] \
  [file join $RTL_DIR rsp_order.v] \
  [file join $RTL_DIR addr_map.v] \
  [file join $RTL_DIR rreq_trans.v] \
  [file join $RTL_DIR wreq_trans.v] \
  [file join $RTL_DIR rsp_trans.v] \
  [file join $RTL_DIR watchdog.v] \
  [file join $RTL_DIR ely_rsp_detect.v] \
  [file join $RTL_DIR addr_border_count.v] \
  [file join $RTL_DIR syn_fifo.v] \
]

foreach rtl_file $RTL_FILES {
  require_file $rtl_file "RTL source"
}

# Save the resolved settings so every PPA result can be reproduced later.
set config_file [open [file join $RUN_DIR resolved_configuration.txt] w]
puts $config_file "run_stamp=$RUN_STAMP"
puts $config_file "repo_root=$REPO_ROOT"
puts $config_file "top_design=$TOP_DESIGN"
puts $config_file "rtl_dir=$RTL_DIR"
puts $config_file "hdl_format=$HDL_FORMAT"
puts $config_file "target_library=$TARGET_LIBRARY"
puts $config_file "operating_condition=$OPERATING_CONDITION"
puts $config_file "clock_port=$CLOCK_PORT"
puts $config_file "clock_name=$CLOCK_NAME"
puts $config_file "clock_period_ns=$CLOCK_PERIOD"
puts $config_file "clock_uncertainty_ns=$CLOCK_UNCERTAINTY"
puts $config_file "input_delay_max_ns=$INPUT_DELAY_MAX"
puts $config_file "input_delay_min_ns=$INPUT_DELAY_MIN"
puts $config_file "output_delay_max_ns=$OUTPUT_DELAY_MAX"
puts $config_file "output_delay_min_ns=$OUTPUT_DELAY_MIN"
puts $config_file "output_load_pf=$OUTPUT_LOAD"
puts $config_file "compile_mode=$COMPILE_MODE"
puts $config_file "run_incremental=$RUN_INCREMENTAL"
puts $config_file "saif_file=$SAIF_FILE"
puts $config_file "vcd_file=$VCD_FILE"
puts $config_file "activity_scope=$ACTIVITY_SCOPE"
close $config_file

puts ""
puts "=============================================================================="
puts " axi_tniu pre-layout PPA flow"
puts "=============================================================================="
puts " Top design       : $TOP_DESIGN"
puts " RTL directory    : $RTL_DIR"
puts " HDL format       : $HDL_FORMAT"
puts " Target library   : $TARGET_LIBRARY"
puts " PVT condition    : $OPERATING_CONDITION"
puts " Clock            : $CLOCK_PORT, period=${CLOCK_PERIOD}ns"
puts " Compile mode     : $COMPILE_MODE"
puts " Run directory    : $RUN_DIR"
puts "=============================================================================="
puts ""

# -----------------------------------------------------------------------------
# Design Compiler setup and technology libraries
# -----------------------------------------------------------------------------
set_app_var search_path [concat [get_app_var search_path] \
                                [list $RTL_DIR $LIB_DIR]]
set_app_var target_library [list $TARGET_LIBRARY]
set_app_var link_library   [concat "*" [list $TARGET_LIBRARY]]
set_app_var alib_library_analysis_path $ALIB_DIR

# Keep generated netlists legal and deterministic.
set_app_var verilogout_no_tri true
set_app_var bus_naming_style {%s[%d]}

# Use available CPU cores without changing synthesis semantics.
if {[catch {set_host_options -max_cores $MAX_CORES} host_error]} {
  puts "WARNING: could not set max cores: $host_error"
}

define_design_lib WORK -path $WORK_DIR
set_svf [file join $DATABASE_DIR "${TOP_DESIGN}.svf"]

# Read the .db now so library/PVT errors occur before RTL analysis.
if {[catch {read_db $TARGET_LIBRARY} library_error]} {
  fatal "failed to read target library: $library_error"
}

redirect -file [file join $REPORT_DIR library.rpt] {
  report_lib [get_libs *]
}
optional_report [file join $REPORT_DIR units.rpt] {
  report_units
}

# -----------------------------------------------------------------------------
# RTL analysis, elaboration and structural checks
# -----------------------------------------------------------------------------
puts "INFO: analyzing [llength $RTL_FILES] RTL files as $HDL_FORMAT"

# Analyze one source at a time.  A batch analyze can return false after the
# first syntax/front-end error without raising a Tcl exception; if that return
# value is ignored, the later link step only reports many misleading missing
# modules.  Per-file analysis identifies the first real failing source and
# preserves its complete diagnostic output in reports/analyze_<file>.rpt.
foreach rtl_file $RTL_FILES {
  set rtl_stem    [file rootname [file tail $rtl_file]]
  set analyze_log [file join $REPORT_DIR "analyze_${rtl_stem}.rpt"]
  set analyze_ok  0

  puts "INFO: analyze [file tail $rtl_file]"
  if {[catch {
    redirect -file $analyze_log {
      set analyze_ok [analyze -format $HDL_FORMAT -library WORK \
                              [list $rtl_file]]
    }
  } analyze_error]} {
    fatal "RTL analyze raised an error for '$rtl_file': $analyze_error\nSee: $analyze_log"
  }

  if {!$analyze_ok} {
    fatal "RTL analyze failed for '$rtl_file'\nSee: $analyze_log"
  }
}

optional_report [file join $REPORT_DIR analyzed_design_library.rpt] {
  report_design_lib WORK
}

set elaborate_ok 0
if {[catch {
  set elaborate_ok [elaborate $TOP_DESIGN -library WORK]
} elaborate_error]} {
  fatal "elaboration failed: $elaborate_error"
}
if {!$elaborate_ok} {
  fatal "elaboration returned failure for '$TOP_DESIGN'; inspect the analyze reports"
}

current_design $TOP_DESIGN

if {![link]} {
  fatal "link failed; inspect unresolved references and target_library"
}

# Operating conditions are a design attribute, so apply them only after a
# current design exists and technology references have been linked.
if {[catch {set_operating_conditions $OPERATING_CONDITION} oc_error]} {
  fatal "failed to select operating condition '$OPERATING_CONDITION': $oc_error"
}

# Give every parameterized instance a unique implementation before optimization.
uniquify -force

redirect -file [file join $REPORT_DIR check_design_precompile.rpt] {
  check_design
}

# Explicitly reject unresolved black-box designs: area, timing and power are not
# meaningful when an RTL submodule is missing.  Query design objects rather
# than cells here.  Before mapping, DC 2018 marks normal GTECH/DesignWare
# operators such as *MUX_OP and *ADD_UNS_OP with is_black_box on the cell
# object; treating those synthetic, unmapped operators as unresolved modules
# produces hundreds of false positives.
set black_box_design_count 0
if {[catch {
  set black_box_designs \
      [get_designs -quiet -filter "is_black_box == true" *]
  set black_box_design_count [sizeof_collection $black_box_designs]
} black_box_query_error]} {
  puts "WARNING: could not query black-box design objects"
  puts "         $black_box_query_error"
} elseif {$black_box_design_count > 0} {
  set black_box_report \
      [open [file join $REPORT_DIR black_box_designs.rpt] w]
  puts $black_box_report "Unresolved black-box designs:"
  foreach_in_collection black_box_design $black_box_designs {
    puts $black_box_report "  [get_object_name $black_box_design]"
  }
  close $black_box_report
  fatal "design contains $black_box_design_count unresolved black-box designs; see black_box_designs.rpt"
}

write -format ddc -hierarchy \
      -output [file join $DATABASE_DIR "${TOP_DESIGN}_elaborated.ddc"]

# -----------------------------------------------------------------------------
# Timing and electrical constraints
# -----------------------------------------------------------------------------
set clock_port_obj [get_ports $CLOCK_PORT -quiet]
if {[sizeof_collection $clock_port_obj] != 1} {
  fatal "expected exactly one clock port named '$CLOCK_PORT'"
}

set reset_port_obj [get_ports $RESET_PORT -quiet]
if {[sizeof_collection $reset_port_obj] != 1} {
  fatal "expected exactly one reset port named '$RESET_PORT'"
}

create_clock -name $CLOCK_NAME -period $CLOCK_PERIOD $clock_port_obj
set_clock_uncertainty $CLOCK_UNCERTAINTY [get_clocks $CLOCK_NAME]
set_clock_transition  $CLOCK_TRANSITION  [get_clocks $CLOCK_NAME]
set_dont_touch_network $clock_port_obj

# All top-level interfaces are assumed synchronous to aclk for this first
# block-level estimate.  Replace these budgets when chip-level timing contracts
# become available.
set excluded_inputs [get_ports [list $CLOCK_PORT $RESET_PORT] -quiet]
set data_inputs     [remove_from_collection [all_inputs] $excluded_inputs]
set data_outputs    [all_outputs]

if {[collection_nonempty $data_inputs]} {
  set_input_delay -max $INPUT_DELAY_MAX -clock $CLOCK_NAME $data_inputs
  set_input_delay -min $INPUT_DELAY_MIN -clock $CLOCK_NAME $data_inputs
  set_input_transition $INPUT_TRANSITION $data_inputs
}

if {[collection_nonempty $data_outputs]} {
  set_output_delay -max $OUTPUT_DELAY_MAX -clock $CLOCK_NAME $data_outputs
  set_output_delay -min $OUTPUT_DELAY_MIN -clock $CLOCK_NAME $data_outputs
  if {$OUTPUT_LOAD > 0.0} {
    set_load $OUTPUT_LOAD $data_outputs
  }
}

# Asynchronous reset is not a data path.  Recovery/removal signoff requires a
# physical clock tree and is outside this pre-layout block estimate.
set_false_path -from $reset_port_obj

# Electrical and area objectives.  MAX_AREA=0 asks DC to recover area while
# still respecting timing; it is not a literal zero-area requirement.
if {$MAX_TRANSITION > 0.0} {
  set_max_transition $MAX_TRANSITION [current_design]
}
if {$MAX_FANOUT > 0.0} {
  set_max_fanout $MAX_FANOUT [current_design]
}
set_max_area $MAX_AREA
set_critical_range $CRITICAL_RANGE [current_design]

# Pre-layout wire-load estimation.  DC will use the library's available model;
# the report records the selected model.  If the .db has no wire-load data,
# interconnect delay remains optimistic and that limitation must be reported.
if {[catch {set_app_var auto_wire_load_selection true} wireload_error]} {
  puts "WARNING: automatic wire-load selection unavailable: $wireload_error"
}
if {[catch {set_wire_load_mode top} wireload_mode_error]} {
  puts "WARNING: could not set top wire-load mode: $wireload_mode_error"
}

# Separate path groups prevent a difficult I/O path from hiding register-to-
# register optimization, and make the final timing report easier to interpret.
set all_regs [all_registers]
if {[collection_nonempty $all_regs]} {
  group_path -name REG2REG -from $all_regs -to $all_regs \
             -critical_range $CRITICAL_RANGE
  if {[collection_nonempty $data_inputs]} {
    group_path -name IN2REG -from $data_inputs -to $all_regs \
               -critical_range $CRITICAL_RANGE
  }
  if {[collection_nonempty $data_outputs]} {
    group_path -name REG2OUT -from $all_regs -to $data_outputs \
               -critical_range $CRITICAL_RANGE
  }
}
if {[collection_nonempty $data_inputs] && [collection_nonempty $data_outputs]} {
  group_path -name IN2OUT -from $data_inputs -to $data_outputs \
             -critical_range $CRITICAL_RANGE
}

# -----------------------------------------------------------------------------
# Power activity annotation
#
# The FSDB generated by tb_top is converted to sim/wave.saif outside DC.  The
# SAIF contains RTL hierarchy, so annotate it while the elaborated RTL names
# still exist, before compile_ultra maps and optimizes the design.  The DUT
# instance in tb/top/tb_top.sv is tb_top/dut.
# -----------------------------------------------------------------------------
set POWER_ACTIVITY_MODE vectorless
set activity_loaded 0

if {$SAIF_FILE ne ""} {
  set SAIF_FILE [file normalize $SAIF_FILE]
  require_file $SAIF_FILE "SAIF activity file"
  puts "INFO: reading RTL SAIF activity"
  puts "INFO: SAIF file     : $SAIF_FILE"
  puts "INFO: activity scope: $ACTIVITY_SCOPE"
  if {[catch {
    read_saif -input $SAIF_FILE -instance_name $ACTIVITY_SCOPE
  } saif_error]} {
    fatal "SAIF annotation failed: $saif_error"
  }
  set POWER_ACTIVITY_MODE saif
  set activity_loaded 1
} elseif {$VCD_FILE ne ""} {
  set VCD_FILE [file normalize $VCD_FILE]
  require_file $VCD_FILE "VCD activity file"
  puts "INFO: reading RTL VCD activity"
  puts "INFO: VCD file      : $VCD_FILE"
  puts "INFO: strip path    : $ACTIVITY_SCOPE"
  if {[catch {
    read_vcd -strip_path $ACTIVITY_SCOPE $VCD_FILE
  } vcd_error]} {
    fatal "VCD annotation failed: $vcd_error"
  }
  set POWER_ACTIVITY_MODE vcd
  set activity_loaded 1
}

if {!$activity_loaded} {
  puts "INFO: no SAIF/VCD supplied; using vectorless input activity assumptions"
  if {[collection_nonempty $data_inputs]} {
    set_switching_activity \
      -static_probability $INPUT_STATIC_PROB \
      -toggle_rate $INPUT_TOGGLE_RATE \
      -base_clock $CLOCK_NAME \
      $data_inputs
  }
}

# Reset is assumed deasserted for almost the entire functional power window.
# For a SAIF/VCD run, activity read from the waveform takes precedence on all
# other annotated DUT objects; this assignment only establishes a safe reset
# default if the reset was not represented in the activity file.
set_switching_activity -static_probability 1.0 -toggle_rate 0.0 \
                       $reset_port_obj

redirect -file [file join $REPORT_DIR clocks_precompile.rpt] {
  report_clock
}
redirect -file [file join $REPORT_DIR constraints_precompile.rpt] {
  report_constraint -all_violators -verbose
}
redirect -file [file join $REPORT_DIR check_timing_precompile.rpt] {
  check_timing -verbose
}

# Prevent constant drivers and multiply-connected nets from leaking into the
# final mapped Verilog netlist.
set_fix_multiple_port_nets -all -buffer_constants [get_designs $TOP_DESIGN]

# -----------------------------------------------------------------------------
# Mapped synthesis
# -----------------------------------------------------------------------------
puts "INFO: starting mapped synthesis ($COMPILE_MODE mode)"

if {$COMPILE_MODE eq "ultra"} {
  if {[catch {compile_ultra -no_autoungroup} compile_error]} {
    fatal "compile_ultra failed: $compile_error\nSet DC_COMPILE_MODE=standard if a DC-Ultra license is unavailable."
  }

  if {$RUN_INCREMENTAL} {
    puts "INFO: running incremental timing/area recovery"
    if {[catch {compile_ultra -incremental -no_autoungroup} incremental_error]} {
      puts "WARNING: incremental compile failed; keeping first mapped result"
      puts "         $incremental_error"
    }
  }
} else {
  if {[catch {compile -map_effort high -area_effort high} compile_error]} {
    fatal "standard compile failed: $compile_error"
  }
}

current_design $TOP_DESIGN
update_timing

redirect -file [file join $REPORT_DIR check_design_postcompile.rpt] {
  check_design
}
redirect -file [file join $REPORT_DIR check_timing_postcompile.rpt] {
  check_timing -verbose
}

# -----------------------------------------------------------------------------
# PPA, QoR and diagnostic reports
# -----------------------------------------------------------------------------
redirect -file [file join $REPORT_DIR qor.rpt] {
  report_qor
}

redirect -file [file join $REPORT_DIR timing_setup.rpt] {
  report_timing -delay_type max -path full -max_paths $TIMING_MAX_PATHS \
                -nworst 3 -nets -transition_time -capacitance
}

redirect -file [file join $REPORT_DIR timing_hold.rpt] {
  report_timing -delay_type min -path full -max_paths $TIMING_MAX_PATHS \
                -nworst 3 -nets -transition_time -capacitance
}

redirect -file [file join $REPORT_DIR area_hier.rpt] {
  report_area -hierarchy
}

redirect -file [file join $REPORT_DIR area_flat.rpt] {
  report_area
}

redirect -file [file join $REPORT_DIR constraints_all_violators.rpt] {
  report_constraint -all_violators -verbose
}

redirect -file [file join $REPORT_DIR design.rpt] {
  report_design
}

optional_report [file join $REPORT_DIR references.rpt] {
  report_reference -hierarchy
}
optional_report [file join $REPORT_DIR resources.rpt] {
  report_resources -hierarchy
}
optional_report [file join $REPORT_DIR power_hier.rpt] {
  report_power -hierarchy
}
optional_report [file join $REPORT_DIR power_flat.rpt] {
  report_power
}
optional_report [file join $REPORT_DIR activity_annotation.rpt] {
  report_saif -hierarchy
}
optional_report [file join $REPORT_DIR wire_load.rpt] {
  report_wire_load
}
optional_report [file join $REPORT_DIR high_fanout.rpt] {
  report_net_fanout -threshold $MAX_FANOUT
}

# -----------------------------------------------------------------------------
# Save synthesized deliverables
# -----------------------------------------------------------------------------
change_names -rules verilog -hierarchy

write -format ddc -hierarchy \
      -output [file join $DATABASE_DIR "${TOP_DESIGN}_mapped.ddc"]
write -format verilog -hierarchy \
      -output [file join $OUTPUT_DIR "${TOP_DESIGN}_mapped.v"]
write_sdc [file join $OUTPUT_DIR "${TOP_DESIGN}_mapped.sdc"]
write_sdf -version 3.0 [file join $OUTPUT_DIR "${TOP_DESIGN}_mapped.sdf"]

# Compact machine-readable summary.  The detailed source of truth remains
# qor.rpt, timing_setup.rpt, area_hier.rpt and power_hier.rpt.
set mapped_area N/A
set leaf_cell_count N/A
set worst_setup_slack N/A

catch {
  set mapped_area [get_attribute [get_designs $TOP_DESIGN] area]
}
catch {
  set leaf_cells [get_cells -hierarchical -filter "is_hierarchical == false"]
  set leaf_cell_count [sizeof_collection $leaf_cells]
}
catch {
  set worst_path [get_timing_paths -delay_type max -max_paths 1]
  if {[sizeof_collection $worst_path] > 0} {
    set worst_setup_slack [get_attribute $worst_path slack]
  }
}

set summary_file [open [file join $REPORT_DIR ppa_summary.rpt] w]
puts $summary_file "axi_tniu pre-layout PPA summary"
puts $summary_file "================================"
puts $summary_file "top_design          : $TOP_DESIGN"
puts $summary_file "target_library      : $TARGET_LIBRARY"
puts $summary_file "operating_condition : $OPERATING_CONDITION"
puts $summary_file "clock_period_ns      : $CLOCK_PERIOD"
puts $summary_file "clock_frequency_mhz  : [format %.3f [expr {1000.0 / $CLOCK_PERIOD}]]"
puts $summary_file "compile_mode         : $COMPILE_MODE"
puts $summary_file "mapped_area          : $mapped_area"
puts $summary_file "leaf_cell_count      : $leaf_cell_count"
puts $summary_file "worst_setup_slack_ns : $worst_setup_slack"
puts $summary_file "power_activity_mode  : $POWER_ACTIVITY_MODE"
puts $summary_file ""
puts $summary_file "Detailed reports:"
puts $summary_file "  QoR         : qor.rpt"
puts $summary_file "  Setup       : timing_setup.rpt"
puts $summary_file "  Area        : area_hier.rpt"
puts $summary_file "  Power       : power_hier.rpt"
puts $summary_file "  Violations  : constraints_all_violators.rpt"
close $summary_file

set_svf -off

puts ""
puts "=============================================================================="
puts " PRE-LAYOUT PPA FLOW COMPLETED"
puts "=============================================================================="
puts " Summary       : [file join $REPORT_DIR ppa_summary.rpt]"
puts " QoR           : [file join $REPORT_DIR qor.rpt]"
puts " Setup timing  : [file join $REPORT_DIR timing_setup.rpt]"
puts " Area          : [file join $REPORT_DIR area_hier.rpt]"
puts " Power         : [file join $REPORT_DIR power_hier.rpt]"
puts " Mapped netlist: [file join $OUTPUT_DIR "${TOP_DESIGN}_mapped.v"]"
puts " Run directory : $RUN_DIR"
puts "=============================================================================="
puts ""

quit
