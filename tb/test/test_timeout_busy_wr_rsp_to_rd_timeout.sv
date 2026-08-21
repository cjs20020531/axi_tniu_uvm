`ifndef TEST_TIMEOUT_BUSY_WR_RSP_TO_RD_TIMEOUT_SV
`define TEST_TIMEOUT_BUSY_WR_RSP_TO_RD_TIMEOUT_SV

// =============================================================================
// File        : test_timeout_busy_wr_rsp_to_rd_timeout.sv
// Description : Wrapper for test_timeout_busy_context_same_axid case 1.
//
// Coverage target:
//   cg_timeout.x_busy_context
//     cp_prev_rsp_dir        = write
//     cp_dir                 = read
//     cp_same_axid_prev_rsp  = same
//
// The inherited testcase sends a normal WRITE first, waits for its RKNP
// response, then sends a READ on the same fixed OrderKey/AXID and delays its AXI
// response beyond the watchdog threshold.
// =============================================================================

class test_timeout_busy_wr_rsp_to_rd_timeout
    extends test_timeout_busy_context_same_axid;
  `uvm_component_utils(test_timeout_busy_wr_rsp_to_rd_timeout)

  function new(string name = "test_timeout_busy_wr_rsp_to_rd_timeout",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void configure_cfg();
    super.configure_cfg();

    // Base case 1:
    //   previous WRITE response -> current READ timeout -> same AXID.
    busy_case = 1;
  endfunction

endclass : test_timeout_busy_wr_rsp_to_rd_timeout

`endif // TEST_TIMEOUT_BUSY_WR_RSP_TO_RD_TIMEOUT_SV
