`ifndef TEST_TIMEOUT_BUSY_RD_RSP_TO_WR_TIMEOUT_SV
`define TEST_TIMEOUT_BUSY_RD_RSP_TO_WR_TIMEOUT_SV

// =============================================================================
// File        : test_timeout_busy_rd_rsp_to_wr_timeout.sv
// Description : Wrapper for test_timeout_busy_context_same_axid case 2.
//
// Coverage target:
//   cg_timeout.x_busy_context
//     cp_prev_rsp_dir        = read
//     cp_dir                 = write
//     cp_same_axid_prev_rsp  = same
//
// The inherited testcase sends a normal READ first, waits for its RKNP
// response, then sends a WRITE on the same fixed OrderKey/AXID and delays its
// AXI response beyond the watchdog threshold.
// =============================================================================

class test_timeout_busy_rd_rsp_to_wr_timeout
    extends test_timeout_busy_context_same_axid;
  `uvm_component_utils(test_timeout_busy_rd_rsp_to_wr_timeout)

  function new(string name = "test_timeout_busy_rd_rsp_to_wr_timeout",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void configure_cfg();
    super.configure_cfg();

    // Base case 2:
    //   previous READ response -> current WRITE timeout -> same AXID.
    busy_case = 2;
  endfunction

endclass : test_timeout_busy_rd_rsp_to_wr_timeout

`endif // TEST_TIMEOUT_BUSY_RD_RSP_TO_WR_TIMEOUT_SV
