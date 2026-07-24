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
  `include "rknp_sequences.sv"
  `include "virtual_sequences.sv"

  // ---- tests ----------------------------------------------------------------
  `include "axi_tniu_tests.sv"

endpackage : axi_tniu_pkg

`endif // AXI_TNIU_PKG_SV
