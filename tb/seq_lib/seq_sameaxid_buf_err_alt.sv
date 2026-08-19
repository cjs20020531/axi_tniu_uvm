`ifndef SEQ_SAMEAXID_BUF_ERR_ALT_SV
`define SEQ_SAMEAXID_BUF_ERR_ALT_SV

// =============================================================================
// File        : seq_sameaxid_buf_err_alt.sv
// Feature     : Same-AXID bufferable-write / ERROR-write alternating traffic.
//
// Required order:
//   BUFFERABLE_WR -> ERROR_WR -> BUFFERABLE_WR -> ERROR_WR
//
// INCR/WRAP is intentionally not treated as a separate feature dimension.
// This directed sequence nevertheless uses both forms deterministically:
//   0: bufferable INCR write
//   1: error      WRAP write
//   2: bufferable WRAP write
//   3: error      INCR write
//
// All four requests use one fixed OrderKey, therefore one mapped AXID.
// IID/TID/address are kept different so this test isolates the same-AXID
// relationship rather than forcing the complete RKNP transaction key equal.
// =============================================================================

class seq_sameaxid_buf_err_alt extends rknp_base_seq;
  `uvm_object_utils(seq_sameaxid_buf_err_alt)

  localparam int unsigned REQ_COUNT = 4;
  localparam int unsigned REQ_LEN   = 7; // 8 bytes; legal for INCR and WRAP

  function new(string name = "seq_sameaxid_buf_err_alt");
    super.new(name);
    num_txn = REQ_COUNT;

    // Keep the sequence usable standalone.  The test overwrites these with the
    // same values explicitly.
    use_fixed_orderkey = 1'b1;
    fixed_orderkey     = 8'h55;
  endfunction

  protected task send_write(
      int unsigned index,
      bit          is_bufferable,
      bit          use_wrap);

    rknp_seq_item it;
    axi_tniu_protocol_pkg::req_opc_e opc_v;
    axi_tniu_protocol_pkg::status_e  status_v;
    logic [axi_tniu_protocol_pkg::IID_WITH-1:0]  iid_v;
    logic [axi_tniu_protocol_pkg::TID_WITH-1:0]  tid_v;
    logic [axi_tniu_protocol_pkg::ADDR_WITH-1:0] addr_v;

    opc_v    = use_wrap
             ? axi_tniu_protocol_pkg::OPC_WRW
             : axi_tniu_protocol_pkg::OPC_WR;
    status_v = is_bufferable
             ? axi_tniu_protocol_pkg::ST_OK
             : axi_tniu_protocol_pkg::ST_ERR;

    iid_v  = 10'h100 + index;
    tid_v  = 10'h200 + index;

    // 8-byte aligned; every item gets a separate address.
    addr_v = 32'h7000_0000 + index * 32'h0000_0100;

    it = rknp_seq_item::type_id::create(
           $sformatf("item_%0d_%s_%s",
                     index,
                     is_bufferable ? "BUF" : "ERR",
                     use_wrap ? "WRAP" : "INCR"));

    start_item(it);

    if (!it.randomize() with {
          opc      == local::opc_v;
          status   == local::status_v;
          len      == REQ_LEN;
          addr     == local::addr_v;

          iid      == local::iid_v;
          tid      == local::tid_v;
          orderkey == local::fixed_orderkey;

          rknp_user == 1'b0;
          axi_user  == 1'b0;
          axlock    == 1'b0;
          axport    == 3'b000;

          // Bufferable write:
          //   ST_OK + AxCACHE[0]=1
          //
          // ERROR write:
          //   ST_ERR + EC_ADDR_DEC + AxCACHE[0]=0
          axcache[3:1] == 3'b000;
          axcache[0]   == local::is_bufferable;

          if (!local::is_bufferable)
            errcode == axi_tniu_protocol_pkg::EC_ADDR_DEC;
        }) begin
      `uvm_fatal(
        "SEQ_SAMEAXID_BUF_ERR_ALT",
        $sformatf(
          "Randomization failed: index=%0d class=%s burst=%s orderkey=0x%0h",
          index,
          is_bufferable ? "BUFFERABLE" : "ERROR",
          use_wrap ? "WRAP" : "INCR",
          fixed_orderkey
        )
      )
    end

    complete_item(it, "SEQ_SAMEAXID_BUF_ERR_ALT");
  endtask

  task body();
    axi_tniu_protocol_pkg::axi_id_t axid;

    if (!use_fixed_orderkey)
      `uvm_fatal(
        "SEQ_SAMEAXID_BUF_ERR_ALT",
        "This feature requires use_fixed_orderkey=1"
      )

    axid = axi_tniu_protocol_pkg::map_ordkey_to_axid(fixed_orderkey);

    `uvm_info(
      "SEQ_SAMEAXID_BUF_ERR_ALT",
      $sformatf(
        "Start feature: fixed OrderKey=0x%0h -> AXID=0x%0h; order=BUF,ERR,BUF,ERR",
        fixed_orderkey, axid
      ),
      UVM_LOW
    )

    // Required sequence:
    //   bufferable write -> ERROR write -> bufferable write -> ERROR write
    send_write(0, 1'b1, 1'b0); // BUF  INCR
    send_write(1, 1'b0, 1'b1); // ERR  WRAP
    send_write(2, 1'b1, 1'b1); // BUF  WRAP
    send_write(3, 1'b0, 1'b0); // ERR  INCR
  endtask

endclass : seq_sameaxid_buf_err_alt

`endif // SEQ_SAMEAXID_BUF_ERR_ALT_SV
