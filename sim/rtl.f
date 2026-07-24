// =============================================================================
// File : rtl.f
// RTL compile filelist for axi_tniu.
//
// The uploaded axi_tniu.v is only the TOP wrapper. It instantiates the
// following sub-modules whose RTL you MUST provide for elaboration:
//
//   wrap_align, wrap_adjust, req_order, rsp_order, addr_map,
//   rreq_trans, wreq_trans, rsp_trans, watchdog, ely_rsp_detect
//
// Point $RTL_HOME at the directory that contains all of them (top + subs),
// e.g.:  make comp RTL_HOME=/path/to/rknoc/rtl
// =============================================================================

+incdir+${RTL_HOME}

// ---- top wrapper (shipped with this UVM package under rtl/) -----------------
${RTL_HOME}/axi_tniu.v

// ---- sub-modules : SUPPLY THESE FROM YOUR DESIGN TREE -----------------------
// Uncomment / adjust the paths to match your repository layout.
${RTL_HOME}/wrap_align.v
${RTL_HOME}/wrap_adjust.v
${RTL_HOME}/req_order.v
${RTL_HOME}/rsp_order.v
${RTL_HOME}/addr_map.v
${RTL_HOME}/rreq_trans.v
${RTL_HOME}/wreq_trans.v
${RTL_HOME}/rsp_trans.v
${RTL_HOME}/watchdog.v
${RTL_HOME}/ely_rsp_detect.v
${RTL_HOME}/addr_border_count.v
${RTL_HOME}/syn_fifo.v


