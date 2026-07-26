// =============================================================================
// File        : rknp_seq_item.sv
// Description : RKNP transaction item. Represents ONE request packet driven
//               into the DUT, and is also reused by monitors to report an
//               observed request or response packet. Field-level (not bit-level)
//               so sequences stay readable; the driver/monitor use rknp_pkg to
//               convert between this and the raw flit.
// Project      : RKNoC - AXI Target NIU verification
// Author       : Verification Team
// =============================================================================
`ifndef RKNP_SEQ_ITEM_SV
`define RKNP_SEQ_ITEM_SV

class rknp_seq_item extends uvm_sequence_item;

  // ---- head fields (constrained-random for stimulus) ------------------------
  rand axi_tniu_protocol_pkg::req_opc_e            opc;
  rand logic [2:0]                    qos;       // 0..7 -> urgency bar-graph
  rand logic [axi_tniu_protocol_pkg::SUBR_WITH-1:0]   subr;
  rand logic [axi_tniu_protocol_pkg::IID_WITH-1:0]    iid;
  rand logic [axi_tniu_protocol_pkg::TID_WITH-1:0]    tid;
  rand logic [axi_tniu_protocol_pkg::ORDKEY_WITH-1:0] orderkey;  // un-mapped AXID (8 bit)
  rand axi_tniu_protocol_pkg::status_e             status;    // OK / ERR (req error mode)
  rand axi_tniu_protocol_pkg::errcode_e            errcode;   // valid when status==ERR
  rand logic [axi_tniu_protocol_pkg::LEN_WITH-1:0] len;       // byte number minus 1
  rand logic [axi_tniu_protocol_pkg::ADDR_WITH-1:0]   addr;
  // ---- USER field (10 bits): structured sub-fields, NOT fully random --------
  //   [9]=rknp_user  [8]=axi_user  [7]=axlock  [6:4]=axport  [3:0]=axcache
  rand bit                            rknp_user;    // user[9]
  rand bit                            axi_user;     // user[8]
  rand bit                            axlock;       // user[7]   (AxLOCK)
  rand logic [2:0]                    axport;       // user[6:4] (AxPROT)
  rand logic [3:0]                    axcache;      // user[3:0] (AxCACHE)
  logic [axi_tniu_protocol_pkg::USER_WITH-1:0]     user;         // composed from the fields above
  bit                                 bufferable;   // = axcache[0] (early-rsp mode)

  // ---- body (write data) ----------------------------------------------------
  //
  // Two representations are supported:
  //
  //   wr_body_aligned == 0:
  //     wr_bytes/wr_be contain only the logical payload bytes. This is the
  //     representation used by the request monitor and the reference model.
  //
  //   wr_body_aligned == 1:
  //     wr_bytes/wr_be contain the physical RKNP body lanes. Leading lanes
  //     before addr[$clog2(NBYTEPERWORD)-1:0] and trailing lanes at the end of
  //     the last flit are automatically filled with Byte=0 and BE=0.
  //     The existing driver can send this representation without modification.
  rand byte unsigned                  wr_bytes[];
  rand bit                            wr_be[];
  bit                                 wr_body_aligned;

  // ---- observed response (filled by response monitor) -----------------------
  axi_tniu_protocol_pkg::rsp_opc_e    rsp_opc;
  axi_tniu_protocol_pkg::status_e     rsp_status;
  axi_tniu_protocol_pkg::errcode_e    rsp_errcode;
  byte unsigned                       rd_bytes[];
  bit                                 rd_be[];
  bit                                 rsp_lw;
  bit                                 is_rsp;       // 0=request view, 1=response view (set by monitor)

  int unsigned                        txn_no;       // transaction编号，方便log查找

  `uvm_object_utils_begin(rknp_seq_item)
    `uvm_field_enum(axi_tniu_protocol_pkg::req_opc_e, opc, UVM_ALL_ON)
    `uvm_field_int (qos,      UVM_ALL_ON)
    `uvm_field_int (subr,     UVM_ALL_ON)
    `uvm_field_int (iid,      UVM_ALL_ON)
    `uvm_field_int (tid,      UVM_ALL_ON)
    `uvm_field_int (orderkey, UVM_ALL_ON)
    `uvm_field_enum(axi_tniu_protocol_pkg::status_e,  status,  UVM_ALL_ON)
    `uvm_field_enum(axi_tniu_protocol_pkg::errcode_e, errcode, UVM_ALL_ON)
    `uvm_field_int (len,      UVM_ALL_ON)
    `uvm_field_int (addr,     UVM_ALL_ON)
    `uvm_field_int (rknp_user, UVM_ALL_ON)
    `uvm_field_int (axi_user,  UVM_ALL_ON)
    `uvm_field_int (axlock,    UVM_ALL_ON)
    `uvm_field_int (axport,    UVM_ALL_ON)
    `uvm_field_int (axcache,   UVM_ALL_ON)
    `uvm_field_int (user,      UVM_ALL_ON)
    `uvm_field_int (bufferable,UVM_ALL_ON)
    `uvm_field_array_int(wr_bytes, UVM_ALL_ON)
    `uvm_field_array_int(wr_be,    UVM_ALL_ON)
    `uvm_field_int(wr_body_aligned, UVM_ALL_ON)
    `uvm_field_int(txn_no, UVM_ALL_ON | UVM_DEC)
    `uvm_field_int(rsp_lw, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "rknp_seq_item");
    super.new(name);
    wr_body_aligned = 1'b0;
  endfunction

  // is-write helper
  function bit is_write();
    return (opc == axi_tniu_protocol_pkg::OPC_WR) || (opc == axi_tniu_protocol_pkg::OPC_WRW);
  endfunction
  function bit is_wrap();
    return (opc == axi_tniu_protocol_pkg::OPC_RDW) || (opc == axi_tniu_protocol_pkg::OPC_WRW);
  endfunction


  // Return the physical byte lane selected by the low address bits.
  function int unsigned get_write_start_lane();
    return int'(addr & (axi_tniu_protocol_pkg::NBYTEPERWORD - 1));
  endfunction

  // Return the number of physical bytes occupied by the RKNP write body after
  // adding leading address-alignment lanes and rounding up to a complete flit.
  function int unsigned get_aligned_write_body_size();
    int unsigned payload_bytes;
    int unsigned occupied_bytes;

    if (!is_write())
      return 0;

    payload_bytes  = int'(len) + 1;
    occupied_bytes = get_write_start_lane() + payload_bytes;

    return ((occupied_bytes + axi_tniu_protocol_pkg::NBYTEPERWORD - 1)
            / axi_tniu_protocol_pkg::NBYTEPERWORD)
           * axi_tniu_protocol_pkg::NBYTEPERWORD;
  endfunction

  // Build a driver-ready physical body.
  //
  // Example: NBYTEPERWORD=8, addr[2:0]=5, len=7 (8 payload bytes)
  //
  //   wr_bytes[0:4]   = 0,  wr_be[0:4]   = 0   (leading padding)
  //   wr_bytes[5:12]  = random payload, wr_be[5:12] = 1
  //   wr_bytes[13:15] = 0,  wr_be[13:15] = 0   (trailing padding)
  //
  // The existing driver then naturally sends two body flits because it uses
  // wr_bytes.size() to calculate nword and packs array index 0 into lane0.
  function void build_aligned_write_body();
    int unsigned start_lane;
    int unsigned payload_bytes;
    int unsigned physical_bytes;

    if (!is_write()) begin
      wr_bytes.delete();
      wr_be.delete();
      wr_body_aligned = 1'b0;
      return;
    end

    start_lane     = get_write_start_lane();
    payload_bytes  = int'(len) + 1;
    physical_bytes = get_aligned_write_body_size();

    wr_bytes = new[physical_bytes];
    wr_be    = new[physical_bytes];

    // Dynamic arrays of 2-state byte/bit types are initialized explicitly so
    // padding is deterministic in every simulator.
    foreach (wr_bytes[i]) begin
      wr_bytes[i] = 8'h00;
      wr_be[i]    = 1'b0;
    end

    // Place the logical payload at its physical starting lane.
    for (int unsigned i = 0; i < payload_bytes; i++) begin
      wr_bytes[start_lane + i] = byte'($urandom_range(0, 255));
      wr_be[start_lane + i]    = 1'b1;
    end

    wr_body_aligned = 1'b1;
  endfunction

  // compose the 10-bit USER field from its sub-fields (call after randomize)
  function void pack_user();
    user       = {rknp_user, axi_user, axlock, axport, axcache};
    bufferable = axcache[0];
  endfunction
  // split a 10-bit USER field into its sub-fields (used by the monitor)
  function void unpack_user(logic [axi_tniu_protocol_pkg::USER_WITH-1:0] u);
    user       = u;
    rknp_user  = u[9];
    axi_user   = u[8];
    axlock     = u[7];
    axport     = u[6:4];
    axcache    = u[3:0];
    bufferable = u[0];
  endfunction

//-------------

function string convert2string();
  string s;
  int start_lane;
  int n_flit;
  int data_idx;

  if (!is_rsp) begin
    s = $sformatf("\nRKNP-REQ \n opc=%s \n qos=%0d \n iid=0x%0h \n tid=0x%0h \n subr=0x%0h \n ordkey=0x%0h \n status=%s \n len=%0d(=%0dB) \n addr=0x%08h \n user=0x%03h(rknp=%0b axi=%0b lock=%0b port=0x%0h cache=0x%0h)",
                  opc.name(), qos, iid, tid, subr, orderkey, status.name(),
                  len, len+1, addr, user, rknp_user, axi_user, axlock, axport, axcache);

    if (status == axi_tniu_protocol_pkg::ST_ERR)
      s = {s, $sformatf(" errc=%s", errcode.name())};

    if (wr_bytes.size() > 0) begin
      start_lane = int'(addr & (axi_tniu_protocol_pkg::NBYTEPERWORD - 1));

      // A sequence-generated item already contains physical padded lanes.
      // A monitor-generated item contains logical payload bytes and therefore
      // still needs address-based display mapping.
      if (wr_body_aligned)
        n_flit = (wr_bytes.size() + axi_tniu_protocol_pkg::NBYTEPERWORD - 1)
                 / axi_tniu_protocol_pkg::NBYTEPERWORD;
      else
        n_flit = (start_lane + wr_bytes.size()
                  + axi_tniu_protocol_pkg::NBYTEPERWORD - 1)
                 / axi_tniu_protocol_pkg::NBYTEPERWORD;

      s = {s, $sformatf("\nWR[%0d]:", len)};

      for (int flit_idx = 0; flit_idx < n_flit; flit_idx++) begin
        s = {s, "\n    "};

        // lane7 在左，lane0 在右，即左边高位、右边低位
        for (int lane = axi_tniu_protocol_pkg::NBYTEPERWORD - 1; lane >= 0; lane--) begin
          if (wr_body_aligned)
            data_idx = flit_idx * axi_tniu_protocol_pkg::NBYTEPERWORD + lane;
          else
            data_idx = flit_idx * axi_tniu_protocol_pkg::NBYTEPERWORD
                       + lane - start_lane;

          if (lane != axi_tniu_protocol_pkg::NBYTEPERWORD - 1)
            s = {s, "  "};

          if ((data_idx >= 0) && (data_idx < wr_bytes.size()))
            s = {s, $sformatf("%02h%s",
                              wr_bytes[data_idx],
                              (data_idx < wr_be.size() && wr_be[data_idx])
                                ? "" : "-")};
          else
            s = {s, "00-"};
        end
      end
    end
  end
  else begin
    s = $sformatf("\nRKNP-RSP \n opc=%s \n status=%s \n iid=0x%0h \n tid=0x%0h \n ordkey=0x%0h \n lw=%0b",
                  rsp_opc.name(), rsp_status.name(), iid, tid, orderkey,
                  rsp_lw);

    if (rsp_status == axi_tniu_protocol_pkg::ST_ERR)
      s = {s, $sformatf(" errc=%s", rsp_errcode.name())};

    if (rsp_opc == axi_tniu_protocol_pkg::RSP_OPC_RD) begin
      start_lane = int'(addr & (axi_tniu_protocol_pkg::NBYTEPERWORD - 1));
      n_flit = (start_lane + rd_bytes.size() + axi_tniu_protocol_pkg::NBYTEPERWORD - 1) / axi_tniu_protocol_pkg::NBYTEPERWORD;

      s = {s, $sformatf("\nRD[%0d]:", rd_bytes.size() - 1)};

      for (int flit_idx = 0; flit_idx < n_flit; flit_idx++) begin
        s = {s, "\n    "};

        // lane7 在左，lane0 在右，即左边高位、右边低位
        for (int lane = axi_tniu_protocol_pkg::NBYTEPERWORD - 1; lane >= 0; lane--) begin
          data_idx = flit_idx * axi_tniu_protocol_pkg::NBYTEPERWORD + lane - start_lane;

          if (lane != axi_tniu_protocol_pkg::NBYTEPERWORD - 1)
            s = {s, "  "};

          if ((data_idx >= 0) && (data_idx < rd_bytes.size()))
            s = {s, $sformatf("%02h%s", rd_bytes[data_idx], (data_idx < rd_be.size() && rd_be[data_idx]) ? "" : "-")};
          else
            s = {s, "00-"};
        end
      end
    end
  end

  return s;
endfunction

//-------------


  // ---- self description : one compact line per transaction ------------------
  // function string convert2string();
  //   string s;
  //   if (!is_rsp) begin
  //     s = $sformatf("\nRKNP-REQ \n opc=%s \n qos=%0d \n iid=0x%0h \n tid=0x%0h \n subr=0x%0h \n ordkey=0x%0h \n status=%s \n len=%0d(=%0dB) \n addr=0x%08h \n user=0x%03h(rknp=%0b axi=%0b lock=%0b port=0x%0h cache=0x%0h)",
  //                   opc.name(), qos, iid, tid, subr, orderkey, status.name(),
  //                   len, len+1, addr, user, rknp_user, axi_user, axlock, axport, axcache);
  //     if (status == axi_tniu_protocol_pkg::ST_ERR) s = {s, $sformatf(" errc=%s", errcode.name())};
  //     if (wr_bytes.size() > 0) begin
  //       s = {s, $sformatf("\n           wr[%0d]:", wr_bytes.size())};
  //       foreach (wr_bytes[i]) s = {s, $sformatf(" %02h%s", wr_bytes[i],
  //                                   (i < wr_be.size() && !wr_be[i]) ? "-" : "")};
  //     end
  //   end
  //   else begin
  //     s = $sformatf("\nRKNP-RSP \n opc=%s \n status=%s \n iid=0x%0h \n tid=0x%0h \n ordkey=0x%0h",
  //                   rsp_opc.name(), rsp_status.name(), iid, tid, orderkey);
  //     if (rsp_status == axi_tniu_protocol_pkg::ST_ERR) s = {s, $sformatf(" errc=%s", rsp_errcode.name())};
  //     if (rd_bytes.size() > 0) begin
  //       s = {s, $sformatf("\n           rd[%0d]:", rd_bytes.size())};
  //       foreach (rd_bytes[i]) s = {s, $sformatf(" %02h", rd_bytes[i])};
  //     end
  //   end
  //   return s;
  // endfunction

  // print the transaction at generation time (right after randomize)
  function void post_randomize();
    pack_user();                 // compose the USER field from its sub-fields
    //`uvm_info("RKNP_TXN", convert2string(), UVM_MEDIUM)
  endfunction

  // ---- constraints ----------------------------------------------------------

  // subr range : only allow 0~7
  constraint c_subr_range {
    subr inside {[0:7]};
  }

  // WRAP transfers: Len must be (2^n - 1)
  constraint c_wrap_len {
    (opc == axi_tniu_protocol_pkg::OPC_RDW || opc == axi_tniu_protocol_pkg::OPC_WRW) ->
      len inside {8'h01,8'h03,8'h07,8'h0F,8'h1F,8'h3F,8'h7F,8'hFF};
  }
  // WRAP transfers:
  // The start address must be aligned to a 2-byte boundary.
  constraint c_wrap_addr {
    (opc == axi_tniu_protocol_pkg::OPC_RDW || opc == axi_tniu_protocol_pkg::OPC_WRW) ->
      (addr[0] == 1'b0);
  }
  // Body sizing during item.randomize(): one logical entry per payload byte.
  // rknp_base_seq::finalize_item() calls build_aligned_write_body() afterward
  // and replaces these arrays with the padded physical body representation.
  constraint c_body_size {
    ((opc == axi_tniu_protocol_pkg::OPC_WR) || (opc == axi_tniu_protocol_pkg::OPC_WRW)) -> {
      wr_bytes.size() == (len + 1);
      wr_be.size()    == (len + 1);
    }

    ((opc != axi_tniu_protocol_pkg::OPC_WR) && (opc != axi_tniu_protocol_pkg::OPC_WRW)) -> {
      wr_bytes.size() == 0;
      wr_be.size()    == 0;
    }
  }

  // // ErrorCode only meaningful when status==ERR
  // constraint c_errc { (status != axi_tniu_protocol_pkg::ST_ERR) -> (errcode == axi_tniu_protocol_pkg::EC_TARGET); }
  // constraint c_status { (status == axi_tniu_protocol_pkg::ST_OK); }

  // // bufferable range : no bufferable 
  // constraint c_axcache_range {
  //   axcache == 0;
  // }

  // localparam int NBPW = axi_tniu_protocol_pkg::NBYTEPERWORD;   // 2 的幂,每拍字节数
  // // 不支持窄传输读与非对齐读
  // constraint c_rd_align_no_narrow {
  //   (opc == axi_tniu_protocol_pkg::OPC_RD) -> {
  //     (addr & (NBPW - 1)) == 0;            // 字对齐:排除非对齐读
  //     (len  & (NBPW - 1)) == (NBPW - 1);   // 整字:排除窄传输(最小一次读 NBPW 字节)
  //   }
  // }

endclass : rknp_seq_item

`endif // RKNP_SEQ_ITEM_SV
