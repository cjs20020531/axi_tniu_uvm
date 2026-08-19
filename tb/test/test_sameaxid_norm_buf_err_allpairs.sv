`ifndef SEQ_SAMEAXID_NORM_BUF_ERR_ALLPAIRS_SV
`define SEQ_SAMEAXID_NORM_BUF_ERR_ALLPAIRS_SV

// =============================================================================
// File        : seq_sameaxid_norm_buf_err_allpairs.sv
// Description : ONE directed three-request combination for cg_special_mix
//               x_triple closure.
//
// The paired test invokes this sequence 64 times and traverses all:
//
//   cp_prev2 x cp_prev x cp_cur = 4 x 4 x 4 = 64
//
// special classes:
//   0 = NORMAL : status=ST_OK,  non-bufferable
//   1 = ERROR  : status=ST_ERR, non-bufferable
//   2 = BUF    : status=ST_OK,  bufferable write
//   3 = BOTH   : status=ST_ERR, bufferable write
//
// NORMAL intentionally alternates between normal READ and normal WRITE across
// the 64 combinations.  Thus "normal read/write" is represented without making
// read-vs-write an additional dimension of x_triple.
//
// All three requests use the same fixed OrderKey, therefore the same mapped
// AXID.  IID/TID are unique per request to keep response matching unambiguous.
//
// This sequence sends exactly THREE adjacent requests.  Waiting for their
// responses is intentionally owned by the TEST, because the scoreboard is an
// environment component and should not be reached from a leaf sequence.
// =============================================================================

typedef enum int unsigned {
  SAMEAXID_TRIPLE_NORMAL = 0,
  SAMEAXID_TRIPLE_ERROR  = 1,
  SAMEAXID_TRIPLE_BUF    = 2,
  SAMEAXID_TRIPLE_BOTH   = 3
} sameaxid_triple_class_e;

class seq_sameaxid_norm_buf_err_allpairs extends rknp_base_seq;
  `uvm_object_utils(seq_sameaxid_norm_buf_err_allpairs)

  localparam int unsigned REQ_LEN = 7; // 8-byte request

  // One invocation = one exact ordered triple.
  sameaxid_triple_class_e class_prev2 = SAMEAXID_TRIPLE_NORMAL;
  sameaxid_triple_class_e class_prev  = SAMEAXID_TRIPLE_NORMAL;
  sameaxid_triple_class_e class_cur   = SAMEAXID_TRIPLE_NORMAL;

  int unsigned combo_index = 0;

  function new(string name = "seq_sameaxid_norm_buf_err_allpairs");
    super.new(name);
    num_txn = 3;

    use_fixed_orderkey = 1'b1;
    fixed_orderkey     = 8'h55;
  endfunction

  protected function string class_name(sameaxid_triple_class_e cls);
    case (cls)
      SAMEAXID_TRIPLE_NORMAL: return "NORMAL";
      SAMEAXID_TRIPLE_ERROR : return "ERROR";
      SAMEAXID_TRIPLE_BUF   : return "BUF";
      SAMEAXID_TRIPLE_BOTH  : return "BOTH";
      default:                return "ILLEGAL";
    endcase
  endfunction

  // ---------------------------------------------------------------------------
  // Build one request whose special_class_of() result is exactly cls.
  //
  // position = 0 / 1 / 2 corresponds to prev2 / prev / cur.
  // ---------------------------------------------------------------------------
  protected task send_one(
      sameaxid_triple_class_e cls,
      int unsigned            position);

    rknp_seq_item it;

    axi_tniu_protocol_pkg::req_opc_e opc_v;
    axi_tniu_protocol_pkg::status_e  status_v;
    axi_tniu_protocol_pkg::errcode_e errcode_v;

    bit is_error_v;
    bit is_bufferable_v;
    bit normal_is_write_v;

    logic [axi_tniu_protocol_pkg::IID_WITH-1:0]  iid_v;
    logic [axi_tniu_protocol_pkg::TID_WITH-1:0]  tid_v;
    logic [axi_tniu_protocol_pkg::ADDR_WITH-1:0] addr_v;

    int unsigned global_index;

    global_index = combo_index * 3 + position;

    is_error_v      = (cls == SAMEAXID_TRIPLE_ERROR) ||
                      (cls == SAMEAXID_TRIPLE_BOTH);
    is_bufferable_v = (cls == SAMEAXID_TRIPLE_BUF) ||
                      (cls == SAMEAXID_TRIPLE_BOTH);

    status_v  = is_error_v
              ? axi_tniu_protocol_pkg::ST_ERR
              : axi_tniu_protocol_pkg::ST_OK;

    errcode_v = is_error_v
              ? axi_tniu_protocol_pkg::EC_ADDR_DEC
              : axi_tniu_protocol_pkg::EC_TARGET;

    // Only NORMAL has a read/write choice. Alternate deterministically so the
    // complete 64-combination regression contains both normal reads and writes.
    normal_is_write_v = ((combo_index + position) & 1) != 0;

    case (cls)
      SAMEAXID_TRIPLE_NORMAL:
        opc_v = normal_is_write_v
              ? axi_tniu_protocol_pkg::OPC_WR
              : axi_tniu_protocol_pkg::OPC_RD;

      SAMEAXID_TRIPLE_ERROR,
      SAMEAXID_TRIPLE_BUF,
      SAMEAXID_TRIPLE_BOTH:
        opc_v = axi_tniu_protocol_pkg::OPC_WR;

      default:
        opc_v = axi_tniu_protocol_pkg::OPC_RD;
    endcase

    // There are 192 requests total.  These values remain within the current
    // IID/TID widths and are unique inside this test.
    iid_v = 10'h040 + global_index;
    tid_v = 10'h180 + global_index;

    // Separate, 8-byte-aligned addresses.  INCR is sufficient because WRAP/INCR
    // is explicitly not a dimension of this feature.
    addr_v = 32'h7200_0000 + global_index * 32'h0000_0020;

    it = rknp_seq_item::type_id::create(
           $sformatf("combo_%02d_pos%0d_%s",
                     combo_index, position, class_name(cls)));

    start_item(it);

    if (!it.randomize() with {
          opc      == local::opc_v;
          status   == local::status_v;
          errcode  == local::errcode_v;

          len      == REQ_LEN;
          addr     == local::addr_v;

          iid      == local::iid_v;
          tid      == local::tid_v;
          orderkey == local::fixed_orderkey;

          rknp_user == 1'b0;
          axi_user  == 1'b0;
          axlock    == 1'b0;
          axport    == 3'b000;

          // special_class_of() mapping:
          //
          // NORMAL: is_err=0, is_buf=0
          // ERROR : is_err=1, is_buf=0
          // BUF   : is_err=0, is_buf=1
          // BOTH  : is_err=1, is_buf=1
          //
          // is_buf is only meaningful for writes, and BUF/BOTH are forced WR.
          axcache[3:1] == 3'b000;
          axcache[0]   == local::is_bufferable_v;
        }) begin
      `uvm_fatal(
        "SEQ_SAMEAXID_TRIPLE",
        $sformatf(
          "Randomization failed: combo=%0d pos=%0d class=%s OrderKey=0x%0h",
          combo_index, position, class_name(cls), fixed_orderkey
        )
      )
    end

    complete_item(it, "SEQ_SAMEAXID_TRIPLE");
  endtask

  task body();
    axi_tniu_protocol_pkg::axi_id_t axid;

    if (!use_fixed_orderkey)
      `uvm_fatal(
        "SEQ_SAMEAXID_TRIPLE",
        "x_triple same-AXID test requires use_fixed_orderkey=1"
      )

    axid = axi_tniu_protocol_pkg::map_ordkey_to_axid(fixed_orderkey);

    `uvm_info(
      "SEQ_SAMEAXID_TRIPLE",
      $sformatf(
        "combo=%0d : %s -> %s -> %s, OrderKey=0x%0h AXID=0x%0h",
        combo_index,
        class_name(class_prev2),
        class_name(class_prev),
        class_name(class_cur),
        fixed_orderkey,
        axid
      ),
      UVM_MEDIUM
    )

    // These three requests are adjacent.  The test sets req gap=0.
    send_one(class_prev2, 0);
    send_one(class_prev,  1);
    send_one(class_cur,   2);
  endtask

endclass : seq_sameaxid_norm_buf_err_allpairs

`endif // SEQ_SAMEAXID_NORM_BUF_ERR_ALLPAIRS_SV
