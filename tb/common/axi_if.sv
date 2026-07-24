// =============================================================================
// File        : axi_if.sv
// Description : AXI4 master interface as seen from the DUT (axi_tniu is AXI
//               master; the TB provides an AXI slave agent on this interface).
//               Five channels AW/W/AR/R/B plus protocol assertions.
// Config       : NBYTEPERWORD=8 -> data width = 64 bit; AxSIZE = 3.
// Project      : RKNoC - AXI Target NIU verification
// Author       : Verification Team
// =============================================================================
`ifndef AXI_IF_SV
`define AXI_IF_SV

interface axi_if #(
  parameter int AXID_WITH    = 4,
  parameter int AADDR_WITH   = 40,
  parameter int NBYTEPERWORD = 8,
  parameter int AUSER_WITH   = 1,
  parameter int AQOS_WITH    = 3
) (input logic aclk, input logic aresetn);

  localparam int DATA_WITH = 8*NBYTEPERWORD;   // 64
  localparam int STRB_WITH = NBYTEPERWORD;     // 8

  // ---- Write address channel (AW) -------------------------------------------
  logic                    awvalid;  logic                    awready;
  logic [AXID_WITH-1:0]    awid;     logic [AADDR_WITH-1:0]   awaddr;
  logic [7:0]              awlen;    logic [2:0]              awsize;
  logic [1:0]              awburst;  logic                    awlock;
  logic [3:0]              awcache;  logic [2:0]              awprot;
  logic [AQOS_WITH-1:0]    awqos;    logic [AUSER_WITH-1:0]   awuser;

  // ---- Write data channel (W) -----------------------------------------------
  logic                    wvalid;   logic                    wready;
  logic                    wlast;    logic [AXID_WITH-1:0]    wid;
  logic [DATA_WITH-1:0]    wdata;    logic [STRB_WITH-1:0]    wstrb;

  // ---- Write response channel (B) -------------------------------------------
  logic                    bvalid;   logic                    bready;
  logic [AXID_WITH-1:0]    bid;      logic [1:0]              bresp;
  logic [AUSER_WITH-1:0]   buser;

  // ---- Read address channel (AR) --------------------------------------------
  logic                    arvalid;  logic                    arready;
  logic [AXID_WITH-1:0]    arid;     logic [AADDR_WITH-1:0]   araddr;
  logic [7:0]              arlen;    logic [2:0]              arsize;
  logic [1:0]              arburst;  logic                    arlock;
  logic [3:0]              arcache;  logic [2:0]              arprot;
  logic [AQOS_WITH-1:0]    arqos;    logic [AUSER_WITH-1:0]   aruser;

  // ---- Read data channel (R) ------------------------------------------------
  logic                    rvalid;   logic                    rready;
  logic [AXID_WITH-1:0]    rid;      logic [DATA_WITH-1:0]    rdata;
  logic [1:0]              rresp;    logic [AUSER_WITH-1:0]   ruser;
  logic                    rlast;

  // ---- Clocking block for the slave driver ----------------------------------
  clocking slv_cb @(posedge aclk);
    default input #1step output #1;
    // slave samples masters' address/data, drives ready + R/B
    input  awvalid, awid, awaddr, awlen, awsize, awburst,
           awlock, awcache, awprot, awqos, awuser;
    output awready;
    input  wvalid, wlast, wid, wdata, wstrb;  output wready;
    output bvalid, bid, bresp, buser;         input  bready;
    input  arvalid, arid, araddr, arlen, arsize, arburst,
           arlock, arcache, arprot, arqos, aruser;
    output arready;
    output rvalid, rid, rdata, rresp, ruser, rlast; input rready;
  endclocking

  clocking mon_cb @(posedge aclk);
    default input #1step;
    input awvalid, awready, awid, awaddr, awlen, awsize, awburst,
          awlock, awcache, awprot, awqos, awuser;
    input wvalid, wready, wlast, wid, wdata, wstrb;
    input bvalid, bready, bid, bresp, buser;
    input arvalid, arready, arid, araddr, arlen, arsize, arburst,
          arlock, arcache, arprot, arqos, aruser;
    input rvalid, rready, rid, rdata, rresp, ruser, rlast;
  endclocking

  // ---------------------------------------------------------------------------
  // Protocol assertions
  // ---------------------------------------------------------------------------
  // A-AXI-01 : address-channel payload stable while VALID && !READY
  property p_aw_stable;
    @(posedge aclk) disable iff (!aresetn)
      (awvalid && !awready) |=> $stable(awaddr) && $stable(awid) &&
                                $stable(awlen) && awvalid;
  endproperty
  a_aw_stable : assert property (p_aw_stable)
    else $error("[AXI_IF] AW payload changed while stalled");

  property p_ar_stable;
    @(posedge aclk) disable iff (!aresetn)
      (arvalid && !arready) |=> $stable(araddr) && $stable(arid) &&
                                $stable(arlen) && arvalid;
  endproperty
  a_ar_stable : assert property (p_ar_stable)
    else $error("[AXI_IF] AR payload changed while stalled");

  // A-AXI-05 : with NBYTEPERWORD=8 the transfer size must be 3 (8 bytes)
  a_awsize : assert property (@(posedge aclk) disable iff(!aresetn)
      (awvalid && awready) |-> (awsize == 3'd3))
    else $error("[AXI_IF] awsize != 3 for 64-bit data bus");
  a_arsize : assert property (@(posedge aclk) disable iff(!aresetn)
      (arvalid && arready) |-> (arsize == 3'd3))
    else $error("[AXI_IF] arsize != 3 for 64-bit data bus");

endinterface : axi_if

`endif // AXI_IF_SV
