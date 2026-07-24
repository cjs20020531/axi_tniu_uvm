// =============================================================================
// File        : axi_tniu_coverage.sv
// Description : Functional coverage collector for axi_tniu. Subscribes to the
//               RKNP request stream and the AXI phase streams and samples the
//               covergroups defined in the verification plan:
//                 cg_req    : opcode x qos x wrap x bufferable x error
//                 cg_axid   : OrderKey -> AxID mapping coverage
//                 cg_burst  : AXI burst type x length buckets x size
//                 cg_err    : error-code space + SLVERR upgrade
//                 cg_resp   : response opcode x status
//               (ooo/ilv/bp/ely/wrap/wd cross buckets are folded into the above
//               groups so a single subscriber owns all sampling.)
// Project      : RKNoC - AXI Target NIU verification
// Author       : Verification Team
// =============================================================================
`ifndef AXI_TNIU_COVERAGE_SV
`define AXI_TNIU_COVERAGE_SV

`uvm_analysis_imp_decl(_cvreq)
`uvm_analysis_imp_decl(_cvaw)
`uvm_analysis_imp_decl(_cvar)
`uvm_analysis_imp_decl(_cvrsp)

class axi_tniu_coverage extends uvm_subscriber #(rknp_seq_item);
  `uvm_component_utils(axi_tniu_coverage)

  axi_tniu_cfg cfg;

  // extra imports for AXI + response streams
  uvm_analysis_imp_cvaw  #(axi_seq_item, axi_tniu_coverage) aw_imp;
  uvm_analysis_imp_cvar  #(axi_seq_item, axi_tniu_coverage) ar_imp;
  uvm_analysis_imp_cvrsp #(rknp_seq_item, axi_tniu_coverage) rsp_imp;

  // ---- sampling shadow variables --------------------------------------------
  axi_tniu_protocol_pkg::req_opc_e  s_opc;
  logic [2:0]          s_qos;
  bit                  s_wrap;
  bit                  s_buf;
  bit                  s_err;
  logic [7:0]          s_ordkey;
  logic [3:0]          s_axid;
  logic [1:0]          s_burst;
  logic [7:0]          s_len;
  logic [2:0]          s_size;
  axi_tniu_protocol_pkg::errcode_e  s_errc;
  axi_tniu_protocol_pkg::rsp_opc_e  s_rsp_opc;
  axi_tniu_protocol_pkg::status_e   s_rsp_status;

  // ---- covergroups ----------------------------------------------------------
  covergroup cg_req;
    option.per_instance = 1;
    cp_opc  : coverpoint s_opc {
      bins rd  = {axi_tniu_protocol_pkg::OPC_RD};
      bins rdw = {axi_tniu_protocol_pkg::OPC_RDW};
      bins wr  = {axi_tniu_protocol_pkg::OPC_WR};
      bins wrw = {axi_tniu_protocol_pkg::OPC_WRW};
    }
    cp_qos  : coverpoint s_qos { bins q[] = {[0:7]}; }
    cp_wrap : coverpoint s_wrap;
    cp_buf  : coverpoint s_buf;
    cp_err  : coverpoint s_err;
    x_opc_buf : cross cp_opc, cp_buf;      // bufferable across opcodes
    x_opc_err : cross cp_opc, cp_err;      // error injection across opcodes
    x_opc_qos : cross cp_opc, cp_qos;
  endgroup

  covergroup cg_axid;
    option.per_instance = 1;
    cp_ordkey : coverpoint s_ordkey { bins k[8] = {[0:255]}; }
    cp_axid   : coverpoint s_axid   { bins a[]  = {[0:15]}; }
    x_map     : cross cp_ordkey, cp_axid;
  endgroup

  covergroup cg_burst;
    option.per_instance = 1;
    cp_burst : coverpoint s_burst { bins incr={2'b01}; bins wrap={2'b10}; }
    cp_len   : coverpoint s_len {
      bins len1     = {0};
      bins len_sm   = {[1:3]};
      bins len_md   = {[4:15]};
      bins len_lg   = {[16:255]};
    }
    cp_size  : coverpoint s_size { bins b8 = {3}; }
    x_burst_len : cross cp_burst, cp_len;
  endgroup

  covergroup cg_err;
    option.per_instance = 1;
    cp_errc : coverpoint s_errc {
      bins target   = {axi_tniu_protocol_pkg::EC_TARGET};
      bins addr_dec = {axi_tniu_protocol_pkg::EC_ADDR_DEC};
      bins unsup    = {axi_tniu_protocol_pkg::EC_UNSUP};
      bins disconn  = {axi_tniu_protocol_pkg::EC_DISCONN};
      bins sec      = {axi_tniu_protocol_pkg::EC_SEC};
      bins hidden   = {axi_tniu_protocol_pkg::EC_HIDDEN_SEC};
      bins timeout  = {axi_tniu_protocol_pkg::EC_TIMEOUT};
    }
  endgroup

  covergroup cg_resp;
    option.per_instance = 1;
    cp_ropc : coverpoint s_rsp_opc {
      bins rd = {axi_tniu_protocol_pkg::RSP_OPC_RD};
      bins wr = {axi_tniu_protocol_pkg::RSP_OPC_WR};
    }
    cp_rst  : coverpoint s_rsp_status {
      bins ok   = {axi_tniu_protocol_pkg::ST_OK};
      bins err  = {axi_tniu_protocol_pkg::ST_ERR};
      bins cont = {axi_tniu_protocol_pkg::ST_CONT};
    }
    x_resp : cross cp_ropc, cp_rst;
  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    cg_req   = new();
    cg_axid  = new();
    cg_burst = new();
    cg_err   = new();
    cg_resp  = new();
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    void'(uvm_config_db#(axi_tniu_cfg)::get(this, "", "cfg", cfg));
    aw_imp  = new("aw_imp",  this);
    ar_imp  = new("ar_imp",  this);
    rsp_imp = new("rsp_imp", this);
  endfunction

  // uvm_subscriber base write() : RKNP request stream
  function void write(rknp_seq_item t);
    if (cfg != null && !cfg.coverage_enable) return;
    s_opc    = t.opc;
    s_qos    = t.qos;
    s_wrap   = t.is_wrap();
    s_buf    = t.bufferable;
    s_err    = (t.status == axi_tniu_protocol_pkg::ST_ERR);
    s_ordkey = t.orderkey;
    s_axid   = t.orderkey[3:0];
    s_errc   = t.errcode;
    cg_req.sample();
    cg_axid.sample();
    if (s_err) cg_err.sample();
  endfunction

  function void write_cvaw(axi_seq_item t);
    if (cfg != null && !cfg.coverage_enable) return;
    s_burst = t.burst; s_len = t.len; s_size = t.size;
    cg_burst.sample();
  endfunction

  function void write_cvar(axi_seq_item t);
    if (cfg != null && !cfg.coverage_enable) return;
    s_burst = t.burst; s_len = t.len; s_size = t.size;
    cg_burst.sample();
  endfunction

  function void write_cvrsp(rknp_seq_item t);
    if (cfg != null && !cfg.coverage_enable) return;
    s_rsp_opc    = t.rsp_opc;
    s_rsp_status = t.rsp_status;
    cg_resp.sample();
  endfunction

endclass : axi_tniu_coverage

`endif // AXI_TNIU_COVERAGE_SV
