// =============================================================================
// File : tb.f
// Testbench compile filelist for the axi_tniu UVM environment.
// $TB_HOME must point at the tb/ directory of this package.
// =============================================================================

// ---- include search paths (component .sv files are `included by the pkg) ----
+incdir+${TB_HOME}/common
+incdir+${TB_HOME}/rknp_agent
+incdir+${TB_HOME}/axi_agent
+incdir+${TB_HOME}/env
+incdir+${TB_HOME}/seq_lib
+incdir+${TB_HOME}/test
+incdir+${TB_HOME}/top

// ---- packages / interfaces (compile ORDER matters) --------------------------
// 1) RKNP definition package (source of truth)
${TB_HOME}/common/axi_tniu_protocol_pkg.sv
// 2) DUT interfaces (must precede the UVM package that uses virtual ifaces)
${TB_HOME}/common/rknp_if.sv
${TB_HOME}/common/axi_if.sv
// 3) Aggregation package (includes items, agents, env, seqs, tests)
${TB_HOME}/top/axi_tniu_pkg.sv
// 4) Testbench top module
${TB_HOME}/top/tb_top.sv
