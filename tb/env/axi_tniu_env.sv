// =============================================================================
// File        : axi_tniu_env.sv
// Description : Top-level UVM environment for axi_tniu. Instantiates:
//                 - rknp_agent  (active : drives RKNP requests, monitors both
//                                request and response channels)
//                 - axi_agent   (active slave : services AW/AR/W, drives R/B)
//                 - axi_tniu_scoreboard (conversion / error / leak checks)
//                 - axi_tniu_coverage   (functional coverage)
//                 - virtual_sequencer   (stimulus coordination handle)
//               and wires every analysis port to the scoreboard and coverage.
// Project      : RKNoC - AXI Target NIU verification
// Author       : Verification Team
// =============================================================================
`ifndef AXI_TNIU_ENV_SV
`define AXI_TNIU_ENV_SV

class axi_tniu_env extends uvm_env;
  `uvm_component_utils(axi_tniu_env)

  rknp_agent            rknp_agt;
  axi_agent             axi_agt;
  axi_tniu_scoreboard   sb;
  axi_tniu_coverage     cov;
  virtual_sequencer     vseqr;
  axi_tniu_cfg          cfg;
  rknp_txn_tag_mgr      tag_mgr;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // A cfg must exist; create a default one if the test did not supply it.
    if (!uvm_config_db#(axi_tniu_cfg)::get(this, "", "cfg", cfg)) begin
      cfg = axi_tniu_cfg::type_id::create("cfg");
      uvm_config_db#(axi_tniu_cfg)::set(this, "*", "cfg", cfg);
    end

    rknp_agt = rknp_agent        ::type_id::create("rknp_agt", this);
    axi_agt  = axi_agent         ::type_id::create("axi_agt",  this);
    sb       = axi_tniu_scoreboard::type_id::create("sb",      this);
    cov      = axi_tniu_coverage ::type_id::create("cov",      this);
    vseqr    = virtual_sequencer ::type_id::create("vseqr",    this);
    tag_mgr  = rknp_txn_tag_mgr::type_id::create("tag_mgr");
    // AXI agent runs as an active slave.
    uvm_config_db#(uvm_active_passive_enum)::set(this, "axi_agt", "is_active", UVM_ACTIVE);
    uvm_config_db#(uvm_active_passive_enum)::set(this, "rknp_agt", "is_active", UVM_ACTIVE);
    uvm_config_db#(rknp_txn_tag_mgr)::set(this,"rknp_agt.drv","tag_mgr",tag_mgr);
    uvm_config_db#(rknp_txn_tag_mgr)::set(this,"rknp_agt.mon","tag_mgr",tag_mgr);
    uvm_config_db#(rknp_txn_tag_mgr)::set(this,"axi_agt.mon", "tag_mgr",tag_mgr);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // virtual sequencer handles
    vseqr.rknp_sqr = rknp_agt.sqr;
    vseqr.axi_sqr  = axi_agt.sqr;

    // ---- RKNP streams -> scoreboard + coverage ----
    rknp_agt.req_ap.connect(sb.req_imp);
    rknp_agt.rsp_ap.connect(sb.rsp_imp);
    rknp_agt.req_ap.connect(cov.analysis_export);   // uvm_subscriber base port
    rknp_agt.rsp_ap.connect(cov.rsp_imp);

    // ---- AXI streams -> scoreboard ----
    axi_agt.aw_ap.connect(sb.aw_imp);
    axi_agt.ar_ap.connect(sb.ar_imp);
    axi_agt.w_ap.connect(sb.w_imp);
    axi_agt.b_ap.connect(sb.b_imp);
    axi_agt.r_ap.connect(sb.r_imp);

    // ---- AXI streams -> coverage ----
    axi_agt.aw_ap.connect(cov.aw_imp);
    axi_agt.ar_ap.connect(cov.ar_imp);
  endfunction

endclass : axi_tniu_env

`endif // AXI_TNIU_ENV_SV
