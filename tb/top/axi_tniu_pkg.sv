// =============================================================================
// File        : axi_tniu_pkg.sv
// Description : Aggregation package for the axi_tniu UVM environment. It imports
//               UVM and the RKNP definition package, then `include`s every
//               component / sequence / test in strict compile order. The DUT
//               interfaces (rknp_if, axi_if) live OUTSIDE any package and must
//               be compiled ahead of this file (the filelist guarantees that).
// Project      : RKNoC - AXI Target NIU verification
// Author       : Verification Team
// =============================================================================
`ifndef AXI_TNIU_PKG_SV
`define AXI_TNIU_PKG_SV

package axi_tniu_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import axi_tniu_protocol_pkg::*;

  // ---- transaction items ----------------------------------------------------
  `include "rknp_seq_item.sv"
  `include "rknp_txn_tag_mgr.sv"
  `include "axi_seq_item.sv"

  // ---- configuration --------------------------------------------------------
  `include "axi_tniu_cfg.sv"

  // ---- RKNP agent -----------------------------------------------------------
  `include "rknp_sequencer.sv"
  `include "rknp_driver.sv"
  `include "rknp_monitor.sv"
  `include "rknp_agent.sv"

  // ---- AXI slave agent ------------------------------------------------------
  `include "axi_sequencer.sv"
  `include "axi_slave_driver.sv"
  `include "axi_monitor.sv"
  `include "axi_agent.sv"

  // ---- analysis components --------------------------------------------------
  `include "axi_tniu_refmodel.sv"
  `include "axi_tniu_scoreboard.sv"
  `include "axi_tniu_coverage.sv"

  // ---- environment ----------------------------------------------------------
  `include "virtual_sequencer.sv"
  `include "axi_tniu_env.sv"

  // ---- sequences ------------------------------------------------------------
  `include "rknp_base_seq.sv"
  `include "seq_aresetn_pulse.sv"
  `include "seq_norm_rd.sv"
  `include "seq_norm_wr.sv"
  `include "seq_norm_rdw.sv"
  `include "seq_norm_wrw.sv"
  `include "seq_norm_mix.sv"
  `include "seq_err_rd.sv"
  `include "seq_err_wr.sv"
  `include "seq_err_rdw.sv"
  `include "seq_err_wrw.sv"
  `include "seq_err_mix.sv"
  `include "seq_buff_wr.sv"
  `include "seq_buff_wrw.sv"
  `include "seq_buff_mix.sv"
  `include "seq_buff_err_mix.sv"
  `include "seq_addrol_waw.sv"
  `include "seq_addrol_raw.sv"
  `include "seq_axi_rsp_error_mix.sv"
  `include "seq_tag_name_toggle.sv"
  `include "seq_mix.sv"
  `include "vseq_base.sv"

  // ---- tests ----------------------------------------------------------------
  `include "axi_tniu_base_test.sv"
  `include "test_aresetn_recovery.sv"
  `include "test_norm_rd.sv"
  `include "test_norm_wr.sv"
  `include "test_norm_rdw.sv"
  `include "test_norm_wrw.sv"
  `include "test_norm_mix.sv"
  `include "test_err_rd.sv"
  `include "test_err_wr.sv"
  `include "test_err_rdw.sv"
  `include "test_err_wrw.sv"
  `include "test_err_mix.sv"
  `include "test_buff_wr.sv"
  `include "test_buff_wrw.sv"
  `include "test_buff_mix.sv"
  `include "test_buff_err_mix.sv"
  `include "test_addrol_waw.sv"
  `include "test_addrol_raw.sv"
  `include "test_mix.sv"
  `include "test_norm_wrw_narrow_noalign.sv"
  `include "test_norm_rdw_narrow_noalign.sv"
  `include "test_buff_mix_fixordkey.sv"
  `include "test_err_mix_fixordkey.sv"
  `include "test_norm_mix_stresstest.sv"

  `include "test_watchdog_1023.sv"
  `include "test_watchdog_1024.sv"
  `include "test_watchdog_1100.sv"
  `include "test_watchdog_normal_timeout.sv"
  `include "test_watchdog_bufferable_1100.sv"
  `include "test_axi_rsp_error_mix.sv"
  `include "test_tag_name_toggle.sv"
  `include "test_rwrap_stresstest.sv"
  

endpackage : axi_tniu_pkg

`endif // AXI_TNIU_PKG_SV
