`ifndef SEQ_FUNCOV_INCR_LEN_SWEEP_SV
`define SEQ_FUNCOV_INCR_LEN_SWEEP_SV

// =============================================================================
// File        : seq_funcov_incr_len_sweep.sv
// Description : Directed functional-coverage sequence for RKNP INCR LEN.
//
// Coverage goal:
//   * OPC_RD : LEN = 0..255, every value exactly once
//   * OPC_WR : LEN = 0..255, every value exactly once
//
// Total requests = 512.
//
// The request status is kept normal (ST_OK), write requests are non-bufferable,
// and addr[11:0] is fixed to 0 so LEN is the only intended sweep dimension.
// rknp_base_seq::complete_item() builds the physical padded write body for WR.
// =============================================================================

class seq_funcov_incr_len_sweep extends rknp_base_seq;
  `uvm_object_utils(seq_funcov_incr_len_sweep)

  localparam int unsigned LEN_MAX =
      (1 << axi_tniu_protocol_pkg::LEN_WITH) - 1;

  function new(string name = "seq_funcov_incr_len_sweep");
    super.new(name);
  endfunction

  // ---------------------------------------------------------------------------
  // Send one normal INCR request with an explicitly selected LEN.
  // ---------------------------------------------------------------------------
  protected task send_incr_req(
      axi_tniu_protocol_pkg::req_opc_e req_opc,
      int unsigned                    len_value,
      string                          item_name);

    rknp_seq_item it;

    it = rknp_seq_item::type_id::create(item_name);

    start_item(it);

    if (!it.randomize() with {
          opc        == local::req_opc;
          status     == axi_tniu_protocol_pkg::ST_OK;

          // Keep early-response/bufferable behavior out of this LEN-only test.
          axcache[0] == 1'b0;

          // Exact LEN coverage target.
          len        == local::len_value;

          // Keep every request naturally aligned and far from a 4-KiB boundary.
          // This prevents address alignment/cross-boundary effects from
          // obscuring the LEN sweep.
          addr[11:0] == 12'h000;
        }) begin
      `uvm_fatal("SEQ_FUNCOV_INCR_LEN",
                 $sformatf("Randomization failed: opc=%s len=%0d",
                           req_opc.name(), len_value))
    end

    complete_item(it, "SEQ_FUNCOV_INCR_LEN");
  endtask

  task body();
    `uvm_info("SEQ_FUNCOV_INCR_LEN",
              $sformatf("Starting INCR LEN sweep: RD 0..%0d, WR 0..%0d",
                        LEN_MAX, LEN_MAX),
              UVM_LOW)

    // -------------------------------------------------------------------------
    // Read INCR sweep: every LEN value 0..255.
    // -------------------------------------------------------------------------
    for (int unsigned len_value = 0;
         len_value <= LEN_MAX;
         len_value++) begin

      send_incr_req(
        axi_tniu_protocol_pkg::OPC_RD,
        len_value,
        $sformatf("rd_len_%0d", len_value)
      );

      if ((len_value & 8'h1f) == 0)
        `uvm_info("SEQ_FUNCOV_INCR_LEN",
                  $sformatf("RD sweep progress: LEN=%0d/%0d",
                            len_value, LEN_MAX),
                  UVM_MEDIUM)
    end

    // -------------------------------------------------------------------------
    // Write INCR sweep: every LEN value 0..255.
    // complete_item() calls build_aligned_write_body(), so each WR gets exactly
    // LEN+1 logical payload bytes and a driver-ready RKNP physical body.
    // -------------------------------------------------------------------------
    for (int unsigned len_value = 0;
         len_value <= LEN_MAX;
         len_value++) begin

      send_incr_req(
        axi_tniu_protocol_pkg::OPC_WR,
        len_value,
        $sformatf("wr_len_%0d", len_value)
      );

      if ((len_value & 8'h1f) == 0)
        `uvm_info("SEQ_FUNCOV_INCR_LEN",
                  $sformatf("WR sweep progress: LEN=%0d/%0d",
                            len_value, LEN_MAX),
                  UVM_MEDIUM)
    end

    `uvm_info("SEQ_FUNCOV_INCR_LEN",
              $sformatf("INCR LEN sweep complete: %0d RD + %0d WR = %0d requests",
                        LEN_MAX + 1, LEN_MAX + 1, 2 * (LEN_MAX + 1)),
              UVM_LOW)
  endtask

endclass : seq_funcov_incr_len_sweep

`endif // SEQ_FUNCOV_INCR_LEN_SWEEP_SV
