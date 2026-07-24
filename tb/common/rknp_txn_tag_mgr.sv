`ifndef RKNP_TXN_TAG_MGR_SV
`define RKNP_TXN_TAG_MGR_SV

class rknp_txn_tag_mgr extends uvm_object;
  `uvm_object_utils(rknp_txn_tag_mgr)

  typedef axi_tniu_protocol_pkg::rknp_txn_key_t txn_key_t;

  int unsigned next_txn_no;

  // Driver 登记，Request Monitor 消费。
  int unsigned req_no_q[txn_key_t][$];

  // Driver 登记，Response Monitor 在最终响应时消费。
  int unsigned rsp_no_q[txn_key_t][$];

  function new(string name = "rknp_txn_tag_mgr");
    super.new(name);
    next_txn_no = 1;
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
    input logic [axi_tniu_protocol_pkg::ORDKEY_WITH-1:0] orderkey
  );
    txn_key_t key;
    int unsigned txn_no;

    key = make_key(iid, tid, orderkey);

    txn_no = next_txn_no;
    next_txn_no++;

    req_no_q[key].push_back(txn_no);
    rsp_no_q[key].push_back(txn_no);

    return txn_no;
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
