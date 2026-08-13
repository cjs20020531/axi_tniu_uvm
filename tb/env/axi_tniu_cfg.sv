// =============================================================================
// File        : axi_tniu_cfg.sv
// Description : Runtime UVM configuration object for the axi_tniu verification
//               environment.
//
//               This object contains only settings that a test may change at
//               runtime, including:
//                 - AXI/RKNP back-pressure policy
//                 - Address/response/beat delays
//                 - AXI response ordering/interleaving policy
//                 - AXI error injection
//                 - RKNP request pacing
//                 - Number of generated transactions
//                 - Scoreboard and coverage enables
//
//               Compile-time widths, RKNP field offsets, structural DUT
//               parameters and fixed DUT build modes are defined only in
//               axi_tniu_protocol_pkg.sv.
// Project      : RKNoC - AXI Target NIU verification
// Author       : Verification Team
// =============================================================================
`ifndef AXI_TNIU_CFG_SV
`define AXI_TNIU_CFG_SV

typedef enum logic [1:0] {
  AXI_SLVERR = 2'b10,
  AXI_DECERR = 2'b11
} axi_respcode_e;

class axi_tniu_cfg extends uvm_object;

  // ===========================================================================
  // AXI slave-agent runtime response policy
  // ===========================================================================

  axi_respcode_e axi_respcode;
  bit axi_ooo_en        = 1;  // allow legal out-of-order B/R completion
  bit axi_interleave_en = 1;  // allow read-data interleaving when permitted

  bit axi_ready_bp_en = 1;    // AWREADY/WREADY/ARREADY stalls
  bit rsp_ready_bp_en = 1;    // RKNP txrsp_ready stalls

  int unsigned axi_min_addr_delay = 0;
  int unsigned axi_max_addr_delay = 4;

  int unsigned axi_min_resp_delay = 0;
  int unsigned axi_max_resp_delay = 8;

  int unsigned axi_min_beat_gap = 0;
  int unsigned axi_max_beat_gap = 3;

  // AXI response USER policy.  USER is randomized once per response
  // transaction and then held stable for the whole transaction.  Disabling
  // randomization is useful for directed tests that need a fixed value.
  bit axi_rsp_user_random_en = 1;
  logic [axi_tniu_protocol_pkg::AUSER_WITH-1:0] axi_rsp_user_fixed = '0;

  // AXI error-response injection.  Keep it disabled by default so existing
  // regressions continue to receive OKAY.  When enabled, each completed AXI
  // transaction independently receives an error with the probability selected
  // by axi_slverr_pct; otherwise it receives OKAY. In directed mode the error
  // is axi_error_resp. In random mode SLVERR/DECERR are selected 50%/50%.
  bit          axi_error_rsp_en        = 0;
  bit          axi_error_resp_random_en = 0;
  logic [1:0]  axi_error_resp          = AXI_SLVERR;
  int unsigned axi_slverr_pct          = 10; // error probability, 0..100

  // ===========================================================================
  // RKNP request/response runtime policy
  // ===========================================================================

  int unsigned req_min_gap = 0;
  int unsigned req_max_gap = 4;

  int unsigned rsp_ready_low_pct = 20;  // 0..100

  // Maximum time a test waits after stimulus generation for one LW=1 final
  // response per driven RKNP request. This replaces a fixed drain delay.
  time rsp_drain_timeout = 100us;

  // ===========================================================================
  // Global test controls
  // ===========================================================================

  int unsigned num_txn    = 200;
  bit checks_enable       = 1;
  bit coverage_enable     = 1;

  `uvm_object_utils_begin(axi_tniu_cfg)
    `uvm_field_int(axi_ooo_en,          UVM_ALL_ON)
    `uvm_field_int(axi_interleave_en,   UVM_ALL_ON)
    `uvm_field_int(axi_ready_bp_en,     UVM_ALL_ON)
    `uvm_field_int(rsp_ready_bp_en,     UVM_ALL_ON)
    `uvm_field_int(axi_min_addr_delay,  UVM_ALL_ON | UVM_DEC)
    `uvm_field_int(axi_max_addr_delay,  UVM_ALL_ON | UVM_DEC)
    `uvm_field_int(axi_min_resp_delay,  UVM_ALL_ON | UVM_DEC)
    `uvm_field_int(axi_max_resp_delay,  UVM_ALL_ON | UVM_DEC)
    `uvm_field_int(axi_min_beat_gap,    UVM_ALL_ON | UVM_DEC)
    `uvm_field_int(axi_max_beat_gap,    UVM_ALL_ON | UVM_DEC)
    `uvm_field_int(axi_rsp_user_random_en, UVM_ALL_ON)
    `uvm_field_int(axi_rsp_user_fixed,  UVM_ALL_ON | UVM_HEX)
    `uvm_field_int(axi_error_rsp_en,    UVM_ALL_ON)
    `uvm_field_int(axi_error_resp_random_en, UVM_ALL_ON)
    `uvm_field_int(axi_error_resp,      UVM_ALL_ON | UVM_BIN)
    `uvm_field_int(axi_slverr_pct,      UVM_ALL_ON | UVM_DEC)
    `uvm_field_int(req_min_gap,         UVM_ALL_ON | UVM_DEC)
    `uvm_field_int(req_max_gap,         UVM_ALL_ON | UVM_DEC)
    `uvm_field_int(rsp_ready_low_pct,   UVM_ALL_ON | UVM_DEC)
    `uvm_field_int(rsp_drain_timeout,   UVM_ALL_ON | UVM_TIME)
    `uvm_field_int(num_txn,             UVM_ALL_ON | UVM_DEC)
    `uvm_field_int(checks_enable,       UVM_ALL_ON)
    `uvm_field_int(coverage_enable,     UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "axi_tniu_cfg");
    super.new(name);
  endfunction

  function void validate();
    if (axi_min_addr_delay > axi_max_addr_delay)
      `uvm_fatal("CFG", $sformatf("axi_min_addr_delay(%0d) > axi_max_addr_delay(%0d)",
                                  axi_min_addr_delay, axi_max_addr_delay))

    if (axi_min_resp_delay > axi_max_resp_delay)
      `uvm_fatal("CFG", $sformatf("axi_min_resp_delay(%0d) > axi_max_resp_delay(%0d)",
                                  axi_min_resp_delay, axi_max_resp_delay))

    if (axi_min_beat_gap > axi_max_beat_gap)
      `uvm_fatal("CFG", $sformatf("axi_min_beat_gap(%0d) > axi_max_beat_gap(%0d)",
                                  axi_min_beat_gap, axi_max_beat_gap))

    if (req_min_gap > req_max_gap)
      `uvm_fatal("CFG", $sformatf("req_min_gap(%0d) > req_max_gap(%0d)",
                                  req_min_gap, req_max_gap))

    if (axi_slverr_pct > 100)
      `uvm_fatal("CFG", $sformatf("axi_slverr_pct=%0d must be in 0..100",
                                  axi_slverr_pct))

    if (!(axi_error_resp inside {2'b10, 2'b11}))
      `uvm_fatal("CFG", $sformatf(
        "axi_error_resp=%02b is not an AXI error response (use SLVERR=10 or DECERR=11)",
        axi_error_resp))

    if (rsp_ready_low_pct > 100)
      `uvm_fatal("CFG", $sformatf("rsp_ready_low_pct=%0d must be in 0..100",
                                  rsp_ready_low_pct))

    if (rsp_drain_timeout == 0)
      `uvm_fatal("CFG", "rsp_drain_timeout must be greater than zero")

    if (num_txn == 0)
      `uvm_warning("CFG", "num_txn is 0; no random transactions will be generated")
  endfunction

endclass : axi_tniu_cfg

`endif // AXI_TNIU_CFG_SV
