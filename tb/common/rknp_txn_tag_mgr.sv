`ifndef RKNP_TXN_TAG_MGR_SV
`define RKNP_TXN_TAG_MGR_SV

class rknp_txn_tag_mgr extends uvm_object;
  `uvm_object_utils(rknp_txn_tag_mgr)

  typedef axi_tniu_protocol_pkg::rknp_txn_key_t txn_key_t;
  typedef axi_tniu_protocol_pkg::axi_id_t       axi_id_t;

  int unsigned next_txn_no;

  // Latency tracking. Requests are registered before they can reach AXI and
  // are associated with AXI handshakes in same-ID channel order.
  int unsigned axi_rd_no_q[axi_id_t][$];
  int unsigned axi_wr_no_q[axi_id_t][$];

  bit  aw_seen[int unsigned];
  bit  w_seen[int unsigned];
  time aw_accept_time[int unsigned];
  time w_accept_time[int unsigned];
  time axi_accept_time[int unsigned];
  time first_rsp_time[int unsigned];
  bit  axi_expected[int unsigned];
  time clk_period;

  // Driver 登记，Request Monitor 消费。
  int unsigned req_no_q[txn_key_t][$];

  // Driver 登记，Response Monitor 在最终响应时消费。
  int unsigned rsp_no_q[txn_key_t][$];

  function new(string name = "rknp_txn_tag_mgr");
    super.new(name);
    next_txn_no = 1;
    clk_period  = 10ns;
  endfunction

  function void set_clk_period(input time period);
    if (period > 0)
      clk_period = period;
  endfunction

  function txn_key_t make_key(
    input logic [axi_tniu_protocol_pkg::IID_WITH-1:0] iid,
    input logic [axi_tniu_protocol_pkg::TID_WITH-1:0] tid,
    input logic [axi_tniu_protocol_pkg::ORDKEY_WITH-1:0] orderkey
  );
    return axi_tniu_protocol_pkg::make_rknp_txn_key(iid, tid, orderkey);
  endfunction

  // Driver 在开始发送新请求前调用。
  function int unsigned alloc_request(
    input logic [axi_tniu_protocol_pkg::IID_WITH-1:0] iid,
    input logic [axi_tniu_protocol_pkg::TID_WITH-1:0] tid,
    input logic [axi_tniu_protocol_pkg::ORDKEY_WITH-1:0] orderkey,
    input axi_tniu_protocol_pkg::req_opc_e opc,
    input axi_tniu_protocol_pkg::status_e status
  );
    txn_key_t key;
    int unsigned txn_no;
    axi_id_t axid;

    key = make_key(iid, tid, orderkey);

    txn_no = next_txn_no;
    next_txn_no++;

    req_no_q[key].push_back(txn_no);
    rsp_no_q[key].push_back(txn_no);

    // Error requests are answered inside the DUT and never reach the AXI
    // slave, so they intentionally have no AXI-accept start time.
    if (status == axi_tniu_protocol_pkg::ST_OK) begin
      axid = axi_tniu_protocol_pkg::map_ordkey_to_axid(orderkey);

      if (opc == axi_tniu_protocol_pkg::OPC_RD ||
          opc == axi_tniu_protocol_pkg::OPC_RDW) begin
        axi_expected[txn_no] = 1'b1;
        axi_rd_no_q[axid].push_back(txn_no);
      end
      else if (opc == axi_tniu_protocol_pkg::OPC_WR ||
               opc == axi_tniu_protocol_pkg::OPC_WRW) begin
        axi_expected[txn_no] = 1'b1;
        axi_wr_no_q[axid].push_back(txn_no);
      end
    end

    return txn_no;
  endfunction

  // A read request is complete at the slave when AR handshakes.
  function bit record_axi_ar_accept(input axi_id_t axid,
                                    input time accept_time);
    int unsigned txn_no;

    if (!axi_rd_no_q.exists(axid) || axi_rd_no_q[axid].size() == 0)
      return 0;

    txn_no = axi_rd_no_q[axid].pop_front();
    if (axi_rd_no_q[axid].size() == 0)
      axi_rd_no_q.delete(axid);

    axi_accept_time[txn_no] = accept_time;
    return 1;
  endfunction

  // AW and W are independent. Associate each channel with the oldest request
  // of the same AXID that has not seen that channel yet.
  function bit record_axi_aw_accept(input axi_id_t axid,
                                    input time accept_time);
    int unsigned txn_no;

    if (!axi_wr_no_q.exists(axid))
      return 0;

    foreach (axi_wr_no_q[axid][i]) begin
      txn_no = axi_wr_no_q[axid][i];
      if (!aw_seen.exists(txn_no) || !aw_seen[txn_no]) begin
        aw_seen[txn_no]        = 1'b1;
        aw_accept_time[txn_no] = accept_time;
        finish_axi_write_if_complete(axid, i, txn_no);
        return 1;
      end
    end

    return 0;
  endfunction

  // Called only when the WLAST beat handshakes.
  function bit record_axi_w_accept(input axi_id_t axid,
                                   input time accept_time);
    int unsigned txn_no;

    if (!axi_wr_no_q.exists(axid))
      return 0;

    foreach (axi_wr_no_q[axid][i]) begin
      txn_no = axi_wr_no_q[axid][i];
      if (!w_seen.exists(txn_no) || !w_seen[txn_no]) begin
        w_seen[txn_no]        = 1'b1;
        w_accept_time[txn_no] = accept_time;
        finish_axi_write_if_complete(axid, i, txn_no);
        return 1;
      end
    end

    return 0;
  endfunction

  function void finish_axi_write_if_complete(input axi_id_t axid,
                                              input int queue_index,
                                              input int unsigned txn_no);
    if (aw_seen.exists(txn_no) && aw_seen[txn_no] &&
        w_seen.exists(txn_no)  && w_seen[txn_no]) begin
      // Complete write acceptance is the later of AW and WLAST handshakes.
      axi_accept_time[txn_no] =
        (aw_accept_time[txn_no] >= w_accept_time[txn_no]) ?
          aw_accept_time[txn_no] : w_accept_time[txn_no];

      axi_wr_no_q[axid].delete(queue_index);
      if (axi_wr_no_q[axid].size() == 0)
        axi_wr_no_q.delete(axid);
    end
  endfunction

  // packet_first_flit_time is captured on the response packet's first
  // valid/ready handshake. Cache only the first packet time so CONT packets use
  // the original request-to-first-response latency.
  function bit get_response_latency(
    input  int unsigned     txn_no,
    input  time             packet_first_flit_time,
    output longint unsigned latency_cycles,
    output time             latency_time
  );
    latency_cycles = 0;
    latency_time   = 0;

    if (!first_rsp_time.exists(txn_no))
      first_rsp_time[txn_no] = packet_first_flit_time;

    if (!axi_accept_time.exists(txn_no))
      return 0;

    // A bufferable early response can legally precede AXI write completion.
    if (first_rsp_time[txn_no] < axi_accept_time[txn_no])
      return 0;

    latency_time = first_rsp_time[txn_no] - axi_accept_time[txn_no];
    if (clk_period == 0)
      return 0;

    latency_cycles = latency_time / clk_period;
    return 1;
  endfunction

  function bit response_precedes_axi_complete(input int unsigned txn_no);
    if (!axi_expected.exists(txn_no) || !axi_expected[txn_no])
      return 0;

    // If completion has not been observed yet, the response necessarily
    // arrived before the user-selected latency start point.
    if (!axi_accept_time.exists(txn_no))
      return 1;

    return first_rsp_time.exists(txn_no) &&
           first_rsp_time[txn_no] < axi_accept_time[txn_no];
  endfunction

  // Request Monitor 在完整请求解包后调用。
  function bit claim_request_no(
    input logic [axi_tniu_protocol_pkg::IID_WITH-1:0] iid,
    input logic [axi_tniu_protocol_pkg::TID_WITH-1:0] tid,
    input logic [axi_tniu_protocol_pkg::ORDKEY_WITH-1:0] orderkey,
    output int unsigned txn_no
  );
    txn_key_t key;

    key = make_key(iid, tid, orderkey);
    txn_no = 0;

    if (!req_no_q.exists(key) || req_no_q[key].size() == 0)
      return 0;

    txn_no = req_no_q[key].pop_front();

    if (req_no_q[key].size() == 0)
      req_no_q.delete(key);

    return 1;
  endfunction

  // Response Monitor 在完整 response packet 解包后调用。
  //
  // ST_CONT：
  //   返回当前队首编号，但不删除，因此同一读请求后续 packet
  //   继续得到相同编号。
  //
  // ST_OK/ST_ERR：
  //   返回编号并删除，表示该请求响应已经结束。
  function bit claim_response_no(
    input logic [axi_tniu_protocol_pkg::IID_WITH-1:0] iid,
    input logic [axi_tniu_protocol_pkg::TID_WITH-1:0] tid,
    input logic [axi_tniu_protocol_pkg::ORDKEY_WITH-1:0] orderkey,
    input bit           rsp_lw,
    output int unsigned txn_no
  );
    txn_key_t key;

    key = make_key(iid, tid, orderkey);
    txn_no = 0;

    if (!rsp_no_q.exists(key) || rsp_no_q[key].size() == 0)
      return 0;

    txn_no = rsp_no_q[key][0];

    if (rsp_lw != 0) begin
      void'(rsp_no_q[key].pop_front());

      if (rsp_no_q[key].size() == 0)
        rsp_no_q.delete(key);
    end

    return 1;
  endfunction

  function void clear_pending();
    req_no_q.delete();
    rsp_no_q.delete();
    axi_rd_no_q.delete();
    axi_wr_no_q.delete();
    aw_seen.delete();
    w_seen.delete();
    aw_accept_time.delete();
    w_accept_time.delete();
    axi_accept_time.delete();
    first_rsp_time.delete();
    axi_expected.delete();
  endfunction

  // Number of requests allocated by the driver. The test samples this only
  // after its virtual sequence has returned, so it is the exact number of
  // transactions whose final responses must be drained.
  function int unsigned get_allocated_count();
    return next_txn_no - 1;
  endfunction

  function void reset_all();
    next_txn_no = 1;
    clear_pending();
  endfunction

endclass : rknp_txn_tag_mgr

`endif // RKNP_TXN_TAG_MGR_SV
