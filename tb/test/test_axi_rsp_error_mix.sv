// =============================================================================
// File        : test_axi_rsp_error_mix.sv
// Description : Drives directed OKAY/SLVERR/OKAY/DECERR/OKAY response sequences
//               for read and write. Error reads are four beats, so axi_monitor
//               also checks that the first RRESP is already an error and stays
//               unchanged through RLAST.
// =============================================================================
`ifndef TEST_AXI_RSP_ERROR_MIX_SV
`define TEST_AXI_RSP_ERROR_MIX_SV

class test_axi_rsp_error_mix extends axi_tniu_base_test;
  `uvm_component_utils(test_axi_rsp_error_mix)

  uvm_tlm_analysis_fifo #(axi_seq_item) b_fifo;
  uvm_tlm_analysis_fifo #(axi_seq_item) r_fifo;
  uvm_tlm_analysis_fifo #(rknp_seq_item) rsp_fifo;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    b_fifo = new("b_fifo", this);
    r_fifo = new("r_fifo", this);
    rsp_fifo = new("rsp_fifo", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    env.axi_agt.b_ap.connect(b_fifo.analysis_export);
    env.axi_agt.r_ap.connect(r_fifo.analysis_export);
    env.rknp_agt.rsp_ap.connect(rsp_fifo.analysis_export);
  endfunction

  virtual function void configure_cfg();
    // Keep this directed test deterministic. Response errors are enabled and
    // changed separately for each request by run_one_case().
    cfg.axi_ooo_en           = 1'b0;
    cfg.axi_interleave_en    = 1'b0;
    cfg.axi_ready_bp_en      = 1'b0;
    cfg.rsp_ready_bp_en      = 1'b0;
    cfg.axi_min_resp_delay   = 0;
    cfg.axi_max_resp_delay   = 4;
    cfg.axi_min_beat_gap     = 0;
    cfg.axi_max_beat_gap     = 2;
    cfg.axi_rsp_user_random_en = 1'b1;
    cfg.axi_error_rsp_en     = 1'b0;
    // The response type is selected explicitly by run_one_case().  Keep the
    // driver's SLVERR/DECERR random mode disabled so every transition below is
    // deterministic and reproducible.
    cfg.axi_error_resp_random_en = 1'b0;
    cfg.axi_slverr_pct       = 100;
    cfg.rsp_drain_timeout    = 100us;
  endfunction

  protected task run_one_case(
    string             case_name,
    axi_rsp_case_dir_e request_dir,
    logic [1:0]        expected_resp
  );
    seq_axi_rsp_error_mix seq;
    axi_seq_item            observed_rsp;
    rknp_seq_item           observed_rknp_rsp;
    bit                     response_seen;

    // OKAY disables error injection. SLVERR/DECERR use 100% injection so the
    // selected result is deterministic rather than merely probable.
    cfg.axi_error_rsp_en = (expected_resp != 2'b00);
    if (expected_resp != 2'b00)
      cfg.axi_error_resp = expected_resp;
    cfg.axi_slverr_pct = 100;

    `uvm_info("AXI_RSP_CASE", $sformatf(
      "Start %-12s dir=%s expected_resp=%02b",
      case_name,
      (request_dir == AXI_RSP_CASE_READ) ? "READ" : "WRITE",
      expected_resp), UVM_LOW)

    seq = seq_axi_rsp_error_mix::type_id::create({"seq_", case_name});
    seq.request_dir    = request_dir;
    seq.transfer_bytes = 32; // four 64-bit R beats for every directed read
    seq.num_txn        = 1;
    start_rknp_sequence(seq);

    // Consume the AXI completion before changing cfg for the next request.
    // This is important because read response policy is sampled at AR, while
    // write response policy is sampled after both AW and W have completed.
    response_seen = 1'b0;
    fork : wait_axi_response
      begin
        if (request_dir == AXI_RSP_CASE_READ)
          r_fifo.get(observed_rsp);
        else
          b_fifo.get(observed_rsp);
        response_seen = 1'b1;
      end
      begin
        #50us;
      end
    join_any
    disable wait_axi_response;

    if (!response_seen)
      `uvm_fatal("AXI_RSP_CASE", $sformatf(
        "%s timed out waiting for AXI response", case_name))

    if (observed_rsp.resp !== expected_resp)
      `uvm_error("AXI_RSP_CASE", $sformatf(
        "%s response mismatch: expected=%02b observed=%02b id=0x%0h",
        case_name, expected_resp, observed_rsp.resp, observed_rsp.id))
    else
      `uvm_info("AXI_RSP_CASE", $sformatf(
        "Pass %-12s resp=%02b user=0x%0h id=0x%0h",
        case_name, observed_rsp.resp, observed_rsp.user, observed_rsp.id),
        UVM_LOW)

    // Check the end-to-end conversion too. The final RKNP response must carry
    // the status implied by BRESP/RRESP, and normal downstream responses must
    // propagate the randomized AXI USER value into RKNP user[8].
    response_seen = 1'b0;
    fork : wait_rknp_response
      begin
        do begin
          rsp_fifo.get(observed_rknp_rsp);
        end while (!observed_rknp_rsp.rsp_lw);
        response_seen = 1'b1;
      end
      begin
        #50us;
      end
    join_any
    disable wait_rknp_response;

    if (!response_seen)
      `uvm_fatal("AXI_RSP_CASE", $sformatf(
        "%s timed out waiting for final RKNP response", case_name))

    if (expected_resp == 2'b00) begin
      if (observed_rknp_rsp.rsp_status !== axi_tniu_protocol_pkg::ST_OK)
        `uvm_error("AXI_RSP_CASE", $sformatf(
          "%s expected RKNP ST_OK, observed %s",
          case_name, observed_rknp_rsp.rsp_status.name()))
    end
    else begin
      if (observed_rknp_rsp.rsp_status !== axi_tniu_protocol_pkg::ST_ERR)
        `uvm_error("AXI_RSP_CASE", $sformatf(
          "%s AXI error was not converted to RKNP ST_ERR; observed %s",
          case_name, observed_rknp_rsp.rsp_status.name()))
      if (observed_rknp_rsp.rsp_errcode !== axi_tniu_protocol_pkg::EC_TARGET)
        `uvm_error("AXI_RSP_CASE", $sformatf(
          "%s RKNP error code mismatch: expected EC_TARGET, observed %s",
          case_name, observed_rknp_rsp.rsp_errcode.name()))
    end

    if (observed_rknp_rsp.axi_user !== observed_rsp.user)
      `uvm_error("AXI_RSP_USER", $sformatf(
        "%s AXI USER propagation mismatch: B/RUSER=%0b RKNP user[8]=%0b",
        case_name, observed_rsp.user, observed_rknp_rsp.axi_user))
  endtask

  virtual task run_testcase();
    // Exercise bit[1] of RRESP and BRESP in both directions.  Each channel
    // follows OKAY -> SLVERR -> OKAY -> DECERR -> OKAY, so resp[1] must toggle
    // 0 -> 1 -> 0 -> 1 -> 0 instead of remaining at one after an error.

    // 1..5: directed read responses.
    run_one_case("read_okay_1",  AXI_RSP_CASE_READ, 2'b00);
    run_one_case("read_slverr",  AXI_RSP_CASE_READ, 2'b10);
    run_one_case("read_okay_2",  AXI_RSP_CASE_READ, 2'b00);
    run_one_case("read_decerr",  AXI_RSP_CASE_READ, 2'b11);
    run_one_case("read_okay_3",  AXI_RSP_CASE_READ, 2'b00);

    // 6..10: directed write responses.
    run_one_case("write_okay_1", AXI_RSP_CASE_WRITE, 2'b00);
    run_one_case("write_slverr", AXI_RSP_CASE_WRITE, 2'b10);
    run_one_case("write_okay_2", AXI_RSP_CASE_WRITE, 2'b00);
    run_one_case("write_decerr", AXI_RSP_CASE_WRITE, 2'b11);
    run_one_case("write_okay_3", AXI_RSP_CASE_WRITE, 2'b00);
  endtask

endclass : test_axi_rsp_error_mix

`endif // TEST_AXI_RSP_ERROR_MIX_SV
