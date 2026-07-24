// =============================================================================
// File        : rknp_if.sv
// Description : RKNP flow-control-layer interface (HeadPenalty = 0).
//               Carries the request channel (rxreq, TB->DUT) and the response
//               channel (txrsp, DUT->TB). Includes protocol assertions for
//               valid/ready stability and head/tail framing.
// Project      : RKNoC - AXI Target NIU verification
// Author       : Verification Team
// =============================================================================
`ifndef RKNP_IF_SV
`define RKNP_IF_SV

interface rknp_if #(
  parameter int REQ_FLIT_WITH = 175,
  parameter int RSP_FLIT_WITH = 157
) (input logic aclk, input logic aresetn);

  // ---- Request channel : TB (master) drives into DUT ------------------------
  logic                       rxreq_head;
  logic                       rxreq_tail;
  logic                       rxreq_valid;
  logic                       rxreq_ready;   // driven by DUT
  logic [REQ_FLIT_WITH-1:0]   rxreq_data;

  // ---- Response channel : DUT drives, TB (master) accepts -------------------
  logic                       txrsp_head;    // driven by DUT
  logic                       txrsp_tail;    // driven by DUT
  logic                       txrsp_valid;   // driven by DUT
  logic                       txrsp_ready;   // driven by TB
  logic [RSP_FLIT_WITH-1:0]   txrsp_data;    // driven by DUT

  // ---- Clocking blocks ------------------------------------------------------
  clocking drv_cb @(posedge aclk);
    default input #1step output #1;
    output rxreq_head, rxreq_tail, rxreq_valid, rxreq_data;
    input  rxreq_ready;
    output txrsp_ready;
    input  txrsp_head, txrsp_tail, txrsp_valid, txrsp_data;
  endclocking

  clocking mon_cb @(posedge aclk);
    default input #1step;
    input rxreq_head, rxreq_tail, rxreq_valid, rxreq_ready, rxreq_data;
    input txrsp_head, txrsp_tail, txrsp_valid, txrsp_ready, txrsp_data;
  endclocking

  // ---------------------------------------------------------------------------
  // Protocol assertions
  // ---------------------------------------------------------------------------
  // A-RKNP-01 : while valid && !ready, payload must remain stable
  property p_req_stable;
    @(posedge aclk) disable iff (!aresetn)
      (rxreq_valid && !rxreq_ready) |=> $stable(rxreq_data) && $stable(rxreq_head)
                                        && $stable(rxreq_tail) && rxreq_valid;
  endproperty
  a_req_stable : assert property (p_req_stable)
    else $error("[RKNP_IF] rxreq payload changed while stalled (valid&&!ready)");

  property p_rsp_stable;
    @(posedge aclk) disable iff (!aresetn)
      (txrsp_valid && !txrsp_ready) |=> $stable(txrsp_data) && $stable(txrsp_head)
                                        && $stable(txrsp_tail) && txrsp_valid;
  endproperty
  a_rsp_stable : assert property (p_rsp_stable)
    else $error("[RKNP_IF] txrsp payload changed while stalled (valid&&!ready)");

  // A-RKNP-04 : during reset no valid may be asserted on the request channel
  property p_req_reset_idle;
    @(posedge aclk) (!aresetn) |-> (rxreq_valid == 1'b0);
  endproperty
  a_req_reset_idle : assert property (p_req_reset_idle)
    else $error("[RKNP_IF] rxreq_valid asserted during reset");

endinterface : rknp_if

`endif // RKNP_IF_SV
