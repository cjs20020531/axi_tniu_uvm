// =============================================================================
// File        : axi_tniu_coverage.sv
// Description : Functional coverage collector for AXI Target NIU.
//
// Design goal
// -----------
// This class is written from the feature-oriented testplan.  Coverage focuses
// on proving that the requested stimulus / response scenarios have actually
// occurred.  Protocol correctness (field equality, ordering legality, data
// compare, etc.) must remain in the scoreboard / assertions.
//
// Integration
// -----------
// The current env already connects:
//   rknp_agt.req_ap -> cov.analysis_export     (uvm_subscriber::write)
//   rknp_agt.rsp_ap -> cov.rsp_imp
//   axi_agt.aw_ap   -> cov.aw_imp
//   axi_agt.ar_ap   -> cov.ar_imp
//
// No extra analysis connection is required by this file.  AXI W/R/B channel
// behavior, RKNP request/response handshake, reset, request start gaps, and AXI
// R interleaving are sampled directly from the existing virtual interfaces.
//
// Notes
// -----
// 1) The Excel testplan lists several WRAP LEN values that are broader than the
//    current rknp_seq_item WRAP constraint.  The bins are intentionally kept
//    according to the testplan so the report exposes any stimulus holes.
// 2) "timeout happens while another response is being transmitted" is an
//    internal-event timing condition.  From external interfaces alone this
//    class can cover the emitted timeout response and the surrounding response
//    context, but it cannot prove the exact internal watchdog-fire cycle.
// =============================================================================

`ifndef AXI_TNIU_COVERAGE_SV
`define AXI_TNIU_COVERAGE_SV

// Use private suffixes so these imps never collide with scoreboard imp classes.
`uvm_analysis_imp_decl(_cov_rsp)
`uvm_analysis_imp_decl(_cov_aw)
`uvm_analysis_imp_decl(_cov_ar)

class axi_tniu_coverage extends uvm_subscriber #(rknp_seq_item);

  `uvm_component_utils(axi_tniu_coverage)

  // ---------------------------------------------------------------------------
  // Analysis imports used by the current environment
  // ---------------------------------------------------------------------------
  uvm_analysis_imp_cov_rsp #(rknp_seq_item, axi_tniu_coverage) rsp_imp;
  uvm_analysis_imp_cov_aw  #(axi_seq_item,  axi_tniu_coverage) aw_imp;
  uvm_analysis_imp_cov_ar  #(axi_seq_item,  axi_tniu_coverage) ar_imp;

  axi_tniu_cfg cfg;

  // Virtual interfaces are read-only here.  They let a single coverage class
  // observe reset / backpressure / W-R-B behavior without adding new monitors.
  virtual rknp_if rknp_vif;
  virtual axi_if  axi_vif;
  bit have_rknp_vif;
  bit have_axi_vif;

  localparam int NBPW = axi_tniu_protocol_pkg::NBYTEPERWORD;
  localparam int MAX_OUTSTANDING = axi_tniu_protocol_pkg::SUP_REQ_NUM;
  localparam int MAX_RWRAP_OUTSTANDING = axi_tniu_protocol_pkg::RWRAP_CNT_MAX;

  // ---------------------------------------------------------------------------
  // Internal coverage encodings
  // ---------------------------------------------------------------------------
  typedef enum int {
    K_INCR_RD = 0,
    K_WRAP_RD = 1,
    K_INCR_WR = 2,
    K_WRAP_WR = 3
  } req_kind_e;

  typedef enum int {
    DIR_RD = 0,
    DIR_WR = 1
  } dir_e;

  typedef enum int {
    GAP_B2B  = 0,   // zero idle cycles between request HEAD handshakes
    GAP_1_10 = 1,
    GAP_GT10 = 2,
    GAP_FIRST= 3
  } gap_e;

  typedef enum int {
    BODY_FULL       = 0,
    BODY_LEAD_PAD   = 1,
    BODY_TAIL_PAD   = 2,
    BODY_BOTH_PAD   = 3
  } body_shape_e;

  typedef enum int {
    SPEC_NORMAL = 0,
    SPEC_ERR    = 1,
    SPEC_BUF    = 2,
    SPEC_BOTH   = 3
  } special_e;

  typedef enum int {
    WRAP_CLASS_NONE            = 0,
    WRAP_CLASS_ALIGN_PLAN      = 1,
    WRAP_CLASS_UA_SHORT_PLAN   = 2,
    WRAP_CLASS_UA_LONG_PLAN    = 3,
    WRAP_CLASS_OTHER           = 4
  } wrap_plan_e;

  // ---------------------------------------------------------------------------
  // Transaction/history state
  // ---------------------------------------------------------------------------
  rknp_seq_item req_by_txn[int unsigned];

  int unsigned pending_aw_req[int unsigned][$];
  int unsigned pending_ar_req[int unsigned][$];

  axi_seq_item orphan_aw[int unsigned][$];
  axi_seq_item orphan_ar[int unsigned][$];

  // Once an RKNP request and AXI address request have been paired, keep the
  // txn number until the real AXI completion arrives.
  int unsigned axi_b_txn_q[int unsigned][$];
  int unsigned axi_r_txn_q[int unsigned][$];
  int          axi_resp_by_txn[int unsigned];

  int unsigned rd_outstanding_q[$];
  int unsigned wr_outstanding_q[$];

  int type_depth[int unsigned];

  int unsigned rsp_valid_bytes[int unsigned];
  int unsigned rsp_packet_count[int unsigned];
  bit          rsp_interleaved[int unsigned];
  bit          rsp_complete[int unsigned];

  int total_outstanding;
  int unaligned_wrap_rd_outstanding;
  int timeout_streak;
  int prev_timeout_dir;

  bit have_prev_req;
  rknp_seq_item prev_req;
  int prev_gap_class;

  bit have_last_rsp;
  int unsigned last_rsp_txn;
  int last_rsp_kind;
  int last_rsp_axid;

  // Last three special classes are used to cover mixed-special sequences.
  int special_hist0, special_hist1, special_hist2;
  int special_hist_count;

  // Raw RKNP request-HEAD gap measured at the interface.
  longint unsigned rknp_cycle;
  longint unsigned last_req_head_cycle;
  bit              have_req_head_cycle;
  int               req_gap_q[$];

  // Raw AXI R-channel state.
  int unsigned rbeat_count[int unsigned];
  logic [1:0] rfirst_resp[int unsigned];
  int last_rid;
  bit have_last_rbeat;

  // Raw AXI W-channel state.
  int unsigned wbeat_count;
  int w_first_strb_class;
  int w_last_strb_class;

  // ---------------------------------------------------------------------------
  // Covergroup: reset feature (RST-001/RST-002)
  //
  // reset_event:
  //   0 = initial reset release
  //   1 = reset asserted again after simulation has started
  //   2 = random reset release
  // ---------------------------------------------------------------------------
  covergroup cg_reset with function sample(int reset_event);
    option.per_instance = 1;
    cp_reset_event : coverpoint reset_event {
      bins initial_release = {0};
      bins random_assert   = {1};
      bins random_release  = {2};
    }
  endgroup

  // ---------------------------------------------------------------------------
  // Covergroup: interface handshake/backpressure observation
  // HANDSHAKE-001/002 are primarily assertion/checker items in the plan, but
  // this group still records whether both no-stall and stalled handshakes were
  // exercised.
  // channel: 0=request, 1=response
  // ---------------------------------------------------------------------------
  covergroup cg_handshake with function sample(
      int channel, bit valid, bit ready, bit head, bit tail, int stall_bucket);
    option.per_instance = 1;

    cp_channel : coverpoint channel {
      bins req = {0};
      bins rsp = {1};
    }

    // This group is sampled only while VALID is asserted.
    cp_hs : coverpoint {valid, ready} {
      bins stall     = {2'b10};
      bins handshake = {2'b11};
    }

    cp_head : coverpoint head iff (valid) {
      bins no  = {0};
      bins yes = {1};
    }

    cp_tail : coverpoint tail iff (valid) {
      bins no  = {0};
      bins yes = {1};
    }

    cp_stall : coverpoint stall_bucket iff (valid) {
      bins none  = {0};
      bins short = {[1:3]};
      bins mid   = {[4:10]};
      bins long  = {[11:1000000]};
    }

    x_channel_hs : cross cp_channel, cp_hs;
  endgroup

  // ---------------------------------------------------------------------------
  // Covergroup: basic RKNP request feature space
  // Covers INCR/WRAP, RD/WR, LEN, alignment, beat count, ERR/normal,
  // bufferable, AXID mapping, and first/follower type.
  // ---------------------------------------------------------------------------
  covergroup cg_req_protocol with function sample(
      int kind,
      int len,
      int aligned,
      int one_or_multi_beat,
      int status,
      int bufferable,
      int axid,
      int first_of_type,
      int body_shape);
    option.per_instance = 1;

    cp_kind : coverpoint kind {
      bins incr_rd = {K_INCR_RD};
      bins wrap_rd = {K_WRAP_RD};
      bins incr_wr = {K_INCR_WR};
      bins wrap_wr = {K_WRAP_WR};
    }

    // INCR_REQ-001/002 explicitly ask for RKNP LEN=0..255.
    cp_incr_len : coverpoint len
      iff ((kind == K_INCR_RD) || (kind == K_INCR_WR)) {
      bins every_len[] = {[0:255]};
    }

    // Testplan values for aligned WRAP.
    cp_wrap_align_len : coverpoint len
      iff (((kind == K_WRAP_RD) || (kind == K_WRAP_WR)) && aligned) {
      bins plan_len[] = {7,15,23,31,39,47,55,63};
      // Unlisted values are intentionally not coverage goals.
    }

    // Testplan values for unaligned short WRAP (< one NBPW).
    cp_wrap_ua_short_len : coverpoint len
      iff (((kind == K_WRAP_RD) || (kind == K_WRAP_WR)) &&
           !aligned && ((len + 1) < NBPW)) {
      bins plan_len[] = {1,3,5};
      // Unlisted values are intentionally not coverage goals.
    }

    // Testplan formula len=2*n-1, n in [4,32] -> odd LEN 7..63.
    cp_wrap_ua_long_len : coverpoint len
      iff (((kind == K_WRAP_RD) || (kind == K_WRAP_WR)) &&
           !aligned && ((len + 1) >= NBPW)) {
      bins plan_len[] = {
         7, 9,11,13,15,17,19,21,23,25,
        27,29,31,33,35,37,39,41,43,45,
        47,49,51,53,55,57,59,61,63
      };
      // Unlisted values are intentionally not coverage goals.
    }

    cp_aligned : coverpoint aligned {
      bins unaligned = {0};
      bins aligned   = {1};
    }

    cp_beats : coverpoint one_or_multi_beat {
      bins beat1 = {0};
      bins multi = {1};
    }

    cp_req_status : coverpoint status {
      bins ok   = {0};
      bins err  = {1};
      // Unlisted values are intentionally not coverage goals.
    }

    cp_bufferable : coverpoint bufferable
      iff ((kind == K_INCR_WR) || (kind == K_WRAP_WR)) {
      bins non_bufferable = {0};
      bins bufferable     = {1};
    }

    cp_axid : coverpoint axid {
      bins all_axid[] = {[0:15]};
    }

    cp_first_type : coverpoint first_of_type {
      bins first    = {1};
      bins follower = {0};
    }

    cp_body_shape : coverpoint body_shape {
      bins full      = {BODY_FULL};
      bins lead_pad  = {BODY_LEAD_PAD};
      bins tail_pad  = {BODY_TAIL_PAD};
      bins both_pad  = {BODY_BOTH_PAD};
    }

    x_kind_align_beats : cross cp_kind, cp_aligned, cp_beats;
    x_kind_status      : cross cp_kind, cp_req_status;
    x_kind_first       : cross cp_kind, cp_first_type;
  endgroup

  // ---------------------------------------------------------------------------
  // Covergroup: USER/QoS request fields used by protocol conversion.
  // AxCACHE is intentionally not a functional-coverage target.
  // ---------------------------------------------------------------------------
  covergroup cg_req_user_qos with function sample(
      int qos, int subr, int rknp_user, int axi_user,
      int axlock, int axport);
    option.per_instance = 1;

    cp_qos : coverpoint qos {
      bins each[] = {[0:7]};
    }

    cp_subr : coverpoint subr {
      bins each[] = {[0:7]};
    }

    cp_rknp_user : coverpoint rknp_user { bins b[] = {0,1}; }
    cp_axi_user  : coverpoint axi_user  { bins b[] = {0,1}; }
    cp_axlock    : coverpoint axlock    { bins b[] = {0,1}; }

    cp_axport : coverpoint axport {
      bins each[] = {[0:7]};
    }

    x_lock_port : cross cp_axlock, cp_axport;
  endgroup

  // ---------------------------------------------------------------------------
  // Covergroup: observed AXI AW/AR address-channel transaction
  // Covers what was actually emitted on AXI after RKNP conversion.
  // ---------------------------------------------------------------------------
  covergroup cg_axi_addr with function sample(
      int dir, int burst, int axlen, int size, int addr_low);
    option.per_instance = 1;

    cp_dir : coverpoint dir {
      bins read  = {DIR_RD};
      bins write = {DIR_WR};
    }

    cp_burst : coverpoint burst {
      bins incr = {1};
      bins wrap = {2};
      // Unlisted values are intentionally not coverage goals.
    }

    // INCR can reach at most 33 beats (AxLEN=32) with a 256B payload
    // starting from a non-zero lane.
    cp_incr_axlen : coverpoint axlen iff (burst == 1) {
      bins one_beat   = {0};
      bins beat_2_4   = {[1:3]};
      bins beat_5_8   = {[4:7]};
      bins beat_9_16  = {[8:15]};
      bins beat_17_32 = {[16:31]};
      bins beat_33    = {32};
      ignore_bins impossible = {[33:255]};
    }

    // WRAP can reach at most 32 beats (AxLEN=31).
    cp_wrap_axlen : coverpoint axlen iff (burst == 2) {
      bins one_beat   = {0};
      bins beat_2_4   = {[1:3]};
      bins beat_5_8   = {[4:7]};
      bins beat_9_16  = {[8:15]};
      bins beat_17_32 = {[16:31]};
      ignore_bins impossible = {[32:255]};
    }

    cp_size : coverpoint size {
      bins byte_8 = {3};
      // Unlisted values are intentionally not coverage goals.
    }

    cp_addr_low : coverpoint addr_low {
      bins lane[] = {[0:7]};
    }

    x_dir_burst : cross cp_dir, cp_burst;
  endgroup

  // ---------------------------------------------------------------------------
  // Covergroup: source RKNP request -> observed AXI address behavior.
  //
  // The actual AXI address is compared against
  // axi_tniu_protocol_pkg::map_subr_addr_to_axaddr(), which includes SubRange
  // mapping and WRAP alignment. Correctness remains a scoreboard responsibility.
  // ---------------------------------------------------------------------------
  covergroup cg_req_axi_map with function sample(
      int kind, int wrap_plan_class, int aligned, int axi_burst,
      int axi_len, int burst_map_class, bit addr_match);
    option.per_instance = 1;

    cp_kind : coverpoint kind {
      bins incr_rd = {K_INCR_RD};
      bins wrap_rd = {K_WRAP_RD};
      bins incr_wr = {K_INCR_WR};
      bins wrap_wr = {K_WRAP_WR};
    }

    cp_plan : coverpoint wrap_plan_class {
      bins non_wrap       = {WRAP_CLASS_NONE};
      bins aligned_wrap   = {WRAP_CLASS_ALIGN_PLAN};
      bins ua_short_wrap  = {WRAP_CLASS_UA_SHORT_PLAN};
      bins ua_long_wrap   = {WRAP_CLASS_UA_LONG_PLAN};
      bins other_wrap     = {WRAP_CLASS_OTHER};
    }

    cp_aligned : coverpoint aligned {
      bins no  = {0};
      bins yes = {1};
    }

    cp_axi_burst : coverpoint axi_burst {
      bins incr = {1};
      bins wrap = {2};
      // Unlisted values are intentionally not coverage goals.
    }

    cp_axi_len : coverpoint axi_len {
      bins one_beat   = {0};
      bins beat_2_4   = {[1:3]};
      bins beat_5_8   = {[4:7]};
      bins beat_9_16  = {[8:15]};
      bins beat_17_32 = {[16:31]};
      bins beat_33    = {32};
      ignore_bins impossible = {[33:255]};
    }

    // 0 non-wrap->INCR, 1 aligned WRAP->WRAP,
    // 2 unaligned short WRAP->INCR, 3 unaligned long WRAP->WRAP,
    // 4 other legal WRAP mapping, 5 mismatch.
    cp_burst_map : coverpoint burst_map_class {
      bins non_wrap_incr = {0};
      bins aligned_wrap  = {1};
      bins ua_short_incr = {2};
      bins ua_long_wrap  = {3};
      bins other_wrap_ok = {4};
      ignore_bins mismatch = {5};
    }

    cp_addr_match : coverpoint addr_match {
      bins expected_mapping = {1};
      ignore_bins mismatch  = {0};
    }
  endgroup

  // ---------------------------------------------------------------------------
  // Covergroup: adjacent request patterns.
  // Covers M10/M11/M12: back-to-back vs N-cycle gap, INCR/WRAP, RD/WR,
  // beat=1 vs beat>1, same/different AXID, and mixed request transitions.
  // ---------------------------------------------------------------------------
  covergroup cg_multi_req with function sample(
      int prev_kind, int cur_kind, int gap_class,
      int prev_multi_beat, int cur_multi_beat,
      int same_axid, int wrap_pair_alignment);
    option.per_instance = 1;

    cp_prev_kind : coverpoint prev_kind { bins kind[] = {[0:3]}; }
    cp_cur_kind  : coverpoint cur_kind  { bins kind[] = {[0:3]}; }

    cp_gap : coverpoint gap_class {
      bins back_to_back = {GAP_B2B};
      bins gap_1_10     = {GAP_1_10};
      bins gap_gt10     = {GAP_GT10};
    }

    cp_prev_beats : coverpoint prev_multi_beat {
      bins beat1 = {0};
      bins multi = {1};
    }

    cp_cur_beats : coverpoint cur_multi_beat {
      bins beat1 = {0};
      bins multi = {1};
    }

    cp_same_axid : coverpoint same_axid {
      bins different = {0};
      bins same      = {1};
    }

    // 0=no WRAP in pair, 1=all WRAP operands aligned, 2=at least one WRAP
    // operand unaligned.
    cp_wrap_pair_alignment : coverpoint wrap_pair_alignment {
      bins no_wrap         = {0};
      bins wrap_aligned    = {1};
      bins wrap_unaligned  = {2};
    }

    x_pair_gap  : cross cp_prev_kind, cp_cur_kind, cp_gap;
    x_pair_beat : cross cp_prev_kind, cp_cur_kind,
                        cp_prev_beats, cp_cur_beats;
  endgroup

  // ---------------------------------------------------------------------------
  // Covergroup: same-address overlap scenarios (ADDR_OL-001..006)
  // flow: 0=WAW, 1=RAW (a read issued after an overlapping write)
  // Each overlap size 1..63 is an individual bin.
  // ---------------------------------------------------------------------------
  covergroup cg_addr_overlap with function sample(
      int flow, int prev_wrap, int cur_wrap, int overlap_bytes);
    option.per_instance = 1;

    cp_flow : coverpoint flow {
      bins waw = {0};
      bins raw = {1};
    }

    cp_prev_wrap : coverpoint prev_wrap { bins incr={0}; bins wrap={1}; }
    cp_cur_wrap  : coverpoint cur_wrap  { bins incr={0}; bins wrap={1}; }

    cp_overlap_bytes : coverpoint overlap_bytes {
      bins each_overlap[] = {[1:63]};
    }

    x_flow_burst_pair : cross cp_flow, cp_prev_wrap, cp_cur_wrap;
  endgroup

  // ---------------------------------------------------------------------------
  // Covergroup: request-error / bufferable special request scenarios.
  //
  // first_of_type is calculated from the number of currently outstanding
  // requests with the same {mapped AXID, original RKNP OPC}.
  // ---------------------------------------------------------------------------
  covergroup cg_special_req with function sample(
      int special_class, int kind, int first_of_type,
      int same_axid_prev, int body_shape, int req_errcode);
    option.per_instance = 1;

    cp_special : coverpoint special_class {
      bins normal = {SPEC_NORMAL};
      bins error  = {SPEC_ERR};
      bins bufferable = {SPEC_BUF};
      bins error_and_bufferable = {SPEC_BOTH};
    }

    cp_kind : coverpoint kind { bins kind[] = {[0:3]}; }

    cp_first : coverpoint first_of_type {
      bins first    = {1};
      bins follower = {0};
    }

    cp_same_axid_prev : coverpoint same_axid_prev {
      bins different = {0};
      bins same      = {1};
    }

    cp_body_shape : coverpoint body_shape {
      bins full      = {BODY_FULL};
      bins lead_pad  = {BODY_LEAD_PAD};
      bins tail_pad  = {BODY_TAIL_PAD};
      bins both_pad  = {BODY_BOTH_PAD};
    }

    cp_errcode : coverpoint req_errcode
      iff ((special_class == SPEC_ERR) || (special_class == SPEC_BOTH)) {
      bins addr_dec = {axi_tniu_protocol_pkg::EC_ADDR_DEC};
      // Unlisted values are intentionally not coverage goals.
    }

    // Encode special class and request kind into one legal-combination point.
    cp_special_kind : coverpoint (special_class*4 + kind) {
      bins normal_incr_rd = {SPEC_NORMAL*4 + K_INCR_RD};
      bins normal_wrap_rd = {SPEC_NORMAL*4 + K_WRAP_RD};
      bins normal_incr_wr = {SPEC_NORMAL*4 + K_INCR_WR};
      bins normal_wrap_wr = {SPEC_NORMAL*4 + K_WRAP_WR};

      bins error_incr_rd  = {SPEC_ERR*4 + K_INCR_RD};
      bins error_wrap_rd  = {SPEC_ERR*4 + K_WRAP_RD};
      bins error_incr_wr  = {SPEC_ERR*4 + K_INCR_WR};
      bins error_wrap_wr  = {SPEC_ERR*4 + K_WRAP_WR};

      bins buf_incr_wr    = {SPEC_BUF*4 + K_INCR_WR};
      bins buf_wrap_wr    = {SPEC_BUF*4 + K_WRAP_WR};

      bins both_incr_wr   = {SPEC_BOTH*4 + K_INCR_WR};
      bins both_wrap_wr   = {SPEC_BOTH*4 + K_WRAP_WR};

      // Unlisted values are intentionally not coverage goals.
    }

    x_special_first : cross cp_special, cp_first;
    x_special_axid  : cross cp_special, cp_same_axid_prev;
  endgroup

  // ---------------------------------------------------------------------------
  // Covergroup: mixed special response request sequences (M20)
  //
  // Pair cross covers normal/error/bufferable/both transitions.
  // Triple cross adds sequence depth so "all combinations" is not reduced to
  // only adjacent pairs.
  // ---------------------------------------------------------------------------
  covergroup cg_special_mix with function sample(
      int prev2_special, int prev_special, int cur_special,
      int same_axid_prev);
    option.per_instance = 1;

    cp_prev2 : coverpoint prev2_special { bins c[] = {[0:3]}; }
    cp_prev  : coverpoint prev_special  { bins c[] = {[0:3]}; }
    cp_cur   : coverpoint cur_special   { bins c[] = {[0:3]}; }

    cp_same_axid : coverpoint same_axid_prev {
      bins different = {0};
      bins same      = {1};
    }

    x_pair   : cross cp_prev, cp_cur, cp_same_axid;
    x_triple : cross cp_prev2, cp_prev, cp_cur;
  endgroup

  // ---------------------------------------------------------------------------
  // Covergroup: observed RKNP response packet.
  //
  // packet_pos: 0=first packet of txn, 1=continuation packet
  // interleaved: this txn was actually split/suspended by another txn
  // ooo: -1 when the transaction has not completed yet; otherwise 0/1
  // axi_resp: -1 if no real AXI completion exists yet (e.g. early response)
  // ---------------------------------------------------------------------------
  covergroup cg_rknp_rsp with function sample(
      int req_kind, int rsp_status, int rsp_errcode, int packet_pos,
      int body_shape, int interleaved, int ooo, int axi_resp);
    option.per_instance = 1;

    cp_kind : coverpoint req_kind { bins kind[] = {[0:3]}; }

    cp_status : coverpoint rsp_status {
      bins ok   = {0};
      bins err  = {1};
      bins cont = {2};
      // Unlisted values are intentionally not coverage goals.
    }

    cp_errcode : coverpoint rsp_errcode {
      bins none_or_target = {0};
      bins timeout        = {6};
      bins other[]        = {[1:5],7};
    }

    cp_packet_pos : coverpoint packet_pos {
      bins first = {0};
      bins continuation = {1};
    }

    cp_body_shape : coverpoint body_shape {
      bins full      = {BODY_FULL};
      bins lead_pad  = {BODY_LEAD_PAD};
      bins tail_pad  = {BODY_TAIL_PAD};
      bins both_pad  = {BODY_BOTH_PAD};
    }

    cp_interleaved : coverpoint interleaved {
      bins no  = {0};
      bins yes = {1};
    }

    cp_ooo : coverpoint ooo iff (ooo >= 0) {
      bins in_order     = {0};
      bins out_of_order = {1};
    }

    cp_axi_resp : coverpoint axi_resp iff (axi_resp >= 0) {
      bins okay   = {0};
      // bins exokay = {1};
      bins slverr = {2};
      bins decerr = {3};
    }

    // Broad automatic crosses are intentionally omitted here because they
    // create protocol-impossible goals (e.g. write x ST_CONT).
  endgroup

  // ---------------------------------------------------------------------------
  // Covergroup: completed response ordering behavior
  // Covers in-order/out-of-order completion and actual read interleaving.
  // ---------------------------------------------------------------------------
  covergroup cg_rsp_order with function sample(
      int dir, int out_of_order, int interleaved,
      int packet_count_class, int same_axid_prev_rsp);
    option.per_instance = 1;

    cp_dir : coverpoint dir {
      bins read  = {DIR_RD};
      bins write = {DIR_WR};
    }

    cp_ooo : coverpoint out_of_order {
      bins in_order = {0};
      bins out_of_order = {1};
    }

    cp_interleaved : coverpoint interleaved {
      bins no  = {0};
      bins yes = {1};
    }

    cp_packets : coverpoint packet_count_class {
      bins one = {0};
      bins two = {1};
      bins many = {2};
    }

    cp_same_axid_prev_rsp : coverpoint same_axid_prev_rsp {
      bins different = {0};
      bins same      = {1};
    }

    x_dir_ooo : cross cp_dir, cp_ooo;
    x_dir_ilv : cross cp_dir, cp_interleaved;
  endgroup

  // ---------------------------------------------------------------------------
  // Covergroup: actual AXI R/B responses observed on the interface.
  // beat_pos: 0=first, 1=middle, 2=last, 3=single
  // ilv_switch: accepted R beat switched RID while the previous RID burst was
  // still open.
  // ---------------------------------------------------------------------------
  covergroup cg_axi_rsp with function sample(
      int dir, int resp, int beat_pos, int ilv_switch, int id);
    option.per_instance = 1;

    cp_dir : coverpoint dir {
      bins read  = {DIR_RD};
      bins write = {DIR_WR};
    }

    cp_resp : coverpoint resp {
      bins okay   = {0};
      // bins exokay = {1};
      bins slverr = {2};
      bins decerr = {3};
    }

    cp_beat_pos : coverpoint beat_pos {
      bins first  = {0};
      bins middle = {1};
      bins last   = {2};
      bins single = {3};
    }

    cp_ilv_switch : coverpoint ilv_switch iff (dir == DIR_RD) {
      bins no  = {0};
      bins yes = {1};
    }

    cp_id : coverpoint id {
      bins each_id[] = {[0:15]};
    }

    x_dir_resp : cross cp_dir, cp_resp;
  endgroup

  // ---------------------------------------------------------------------------
  // Covergroup: AXI W burst shape observed directly on the interface.
  // strobe class: 0=all-zero, 1=partial, 2=full
  // ---------------------------------------------------------------------------
  covergroup cg_axi_w with function sample(
      int beats, int first_strb_class, int last_strb_class);
    option.per_instance = 1;

    cp_beats : coverpoint beats {
      bins one       = {1};
      bins beat_2_4  = {[2:4]};
      bins beat_5_8  = {[5:8]};
      bins beat_9_16 = {[9:16]};
      bins beat_17_32= {[17:32]};
      bins gt32      = {[33:1024]};
    }

    cp_first_strb : coverpoint first_strb_class {
      ignore_bins zero = {0};
      bins partial = {1};
      bins full    = {2};
    }

    cp_last_strb : coverpoint last_strb_class {
      ignore_bins zero = {0};
      bins partial = {1};
      bins full    = {2};
    }

    x_first_last_strb : cross cp_first_strb, cp_last_strb;
  endgroup

  // ---------------------------------------------------------------------------
  // Covergroup: watchdog timeout response feature space.
  //
  // prev_rsp_dir/same_axid_prev_rsp record externally visible response context.
  // The exact internal cycle at which watchdog.timout_flag fires is intentionally
  // not claimed here.
  // ---------------------------------------------------------------------------
  covergroup cg_timeout with function sample(
      int dir, int body_shape, int streak,
      int prev_timeout_direction, int prev_rsp_dir,
      int same_axid_prev_rsp);
    option.per_instance = 1;

    cp_dir : coverpoint dir {
      bins read  = {DIR_RD};
      bins write = {DIR_WR};
    }

    cp_body_shape : coverpoint body_shape {
      bins full      = {BODY_FULL};
      bins lead_pad  = {BODY_LEAD_PAD};
      bins tail_pad  = {BODY_TAIL_PAD};
      bins both_pad  = {BODY_BOTH_PAD};
    }

    cp_streak : coverpoint streak {
      bins single = {1};
      bins two    = {2};
      bins few    = {[3:7]};
      bins eight_or_more = {[8:1024]};
    }

    cp_prev_timeout_dir : coverpoint prev_timeout_direction
      iff (prev_timeout_direction >= 0) {
      bins read  = {DIR_RD};
      bins write = {DIR_WR};
    }

    cp_prev_rsp_dir : coverpoint prev_rsp_dir iff (prev_rsp_dir >= 0) {
      bins read  = {DIR_RD};
      bins write = {DIR_WR};
    }

    cp_same_axid_prev_rsp : coverpoint same_axid_prev_rsp
      iff (prev_rsp_dir >= 0) {
      bins different = {0};
      bins same      = {1};
    }

    x_timeout_mix : cross cp_prev_timeout_dir, cp_dir;
    x_busy_context: cross cp_prev_rsp_dir, cp_dir, cp_same_axid_prev_rsp;
  endgroup

  // ---------------------------------------------------------------------------
  // Covergroup: stress depth
  // Covers outstanding pressure, unaligned WRAP-read pressure, and timeout runs.
  // ---------------------------------------------------------------------------
  covergroup cg_stress with function sample(
      int outstanding, int ua_wrap_rd_outstanding, int timeout_run);
    option.per_instance = 1;

    cp_outstanding : coverpoint outstanding {
      bins zero = {0};
      bins each_depth[] = {[1:MAX_OUTSTANDING]};
      ignore_bins overflow = {[MAX_OUTSTANDING+1:1024]};
    }

    cp_ua_wrap_rd : coverpoint ua_wrap_rd_outstanding {
      bins zero = {0};
      bins depth[] = {[1:MAX_RWRAP_OUTSTANDING]};
      ignore_bins above_configured_limit =
        {[MAX_RWRAP_OUTSTANDING+1:1024]};
    }

    cp_timeout_run : coverpoint timeout_run {
      bins zero = {0};
      bins one = {1};
      bins two_to_seven = {[2:7]};
      bins eight_or_more = {[8:1024]};
    }
  endgroup

  // ===========================================================================
  // Constructor / build
  // ===========================================================================
  function new(string name, uvm_component parent);
    super.new(name, parent);

    cg_reset       = new;
    cg_handshake   = new;
    cg_req_protocol= new;
    cg_req_user_qos= new;
    cg_axi_addr    = new;
    cg_req_axi_map = new;
    cg_multi_req   = new;
    cg_addr_overlap= new;
    cg_special_req = new;
    cg_special_mix = new;
    cg_rknp_rsp    = new;
    cg_rsp_order   = new;
    cg_axi_rsp     = new;
    cg_axi_w       = new;
    cg_timeout     = new;
    cg_stress      = new;

    total_outstanding = 0;
    unaligned_wrap_rd_outstanding = 0;
    timeout_streak = 0;
    prev_timeout_dir = -1;

    have_prev_req = 0;
    have_last_rsp = 0;
    special_hist_count = 0;

    rknp_cycle = 0;
    have_req_head_cycle = 0;

    have_last_rbeat = 0;
    last_rid = -1;
    wbeat_count = 0;
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    rsp_imp = new("rsp_imp", this);
    aw_imp  = new("aw_imp",  this);
    ar_imp  = new("ar_imp",  this);

    void'(uvm_config_db#(axi_tniu_cfg)::get(this, "", "cfg", cfg));

    // The top currently publishes the VIFs to the two agents.  Fetch those same
    // handles by their absolute config-db paths so this coverage class remains
    // the only new component required.
    have_rknp_vif =
      uvm_config_db#(virtual rknp_if)::get(
        null, "uvm_test_top.env.rknp_agt", "vif", rknp_vif);

    have_axi_vif =
      uvm_config_db#(virtual axi_if)::get(
        null, "uvm_test_top.env.axi_agt", "vif", axi_vif);

    if (!have_rknp_vif)
      `uvm_warning("COV_VIF",
        "rknp_vif not found: reset/handshake/exact request-gap coverage disabled")

    if (!have_axi_vif)
      `uvm_warning("COV_VIF",
        "axi_vif not found: AXI W/R/B raw-channel coverage disabled")
  endfunction

  // ===========================================================================
  // Helper functions
  // ===========================================================================
  function automatic int kind_of(rknp_seq_item t);
    if (!t.is_write() && !t.is_wrap()) return K_INCR_RD;
    if (!t.is_write() &&  t.is_wrap()) return K_WRAP_RD;
    if ( t.is_write() && !t.is_wrap()) return K_INCR_WR;
    return K_WRAP_WR;
  endfunction

  function automatic int dir_of_kind(int kind);
    return ((kind == K_INCR_WR) || (kind == K_WRAP_WR)) ? DIR_WR : DIR_RD;
  endfunction

  function automatic int axid_of(rknp_seq_item t);
    return int'(axi_tniu_protocol_pkg::map_ordkey_to_axid(t.orderkey));
  endfunction

  function automatic bit addr_aligned(rknp_seq_item t);
    return ((int'(t.addr) & (NBPW-1)) == 0);
  endfunction

  function automatic int expected_axi_beats(rknp_seq_item t);
    int bytes;
    int start_lane;
    bytes = int'(t.len) + 1;
    start_lane = int'(t.addr) & (NBPW-1);

    // Short WRAP is planned as converted-to-INCR; long WRAP is treated as a
    // wrap-window transfer.  This helper is only for beat-category coverage.
    if (t.is_wrap() && (bytes >= NBPW))
      return (bytes + NBPW - 1) / NBPW;
    else
      return (start_lane + bytes + NBPW - 1) / NBPW;
  endfunction

  function automatic int body_shape_of(rknp_seq_item t);
    int start_lane;
    int bytes;
    int end_lane;
    bit lead_pad;
    bit tail_pad;

    start_lane = int'(t.addr) & (NBPW-1);
    bytes      = int'(t.len) + 1;
    end_lane   = (start_lane + bytes) % NBPW;

    lead_pad = (start_lane != 0);
    tail_pad = (end_lane != 0);

    if (!lead_pad && !tail_pad) return BODY_FULL;
    if ( lead_pad && !tail_pad) return BODY_LEAD_PAD;
    if (!lead_pad &&  tail_pad) return BODY_TAIL_PAD;
    return BODY_BOTH_PAD;
  endfunction

  function automatic int special_class_of(rknp_seq_item t);
    bit is_err;
    bit is_buf;
    is_err = (int'(t.status) == 1);
    is_buf = t.is_write() && t.bufferable;

    if (is_err && is_buf) return SPEC_BOTH;
    if (is_err)           return SPEC_ERR;
    if (is_buf)           return SPEC_BUF;
    return SPEC_NORMAL;
  endfunction

  function automatic int type_key_of(rknp_seq_item t);
    return (axid_of(t) << 4) | kind_of(t);
  endfunction

  function automatic int wrap_plan_class_of(rknp_seq_item t);
    int l;
    if (!t.is_wrap()) return WRAP_CLASS_NONE;

    l = int'(t.len);

    if (addr_aligned(t) &&
        (l inside {7,15,23,31,39,47,55,63}))
      return WRAP_CLASS_ALIGN_PLAN;

    if (!addr_aligned(t) && ((l+1) < NBPW) &&
        (l inside {1,3,5}))
      return WRAP_CLASS_UA_SHORT_PLAN;

    if (!addr_aligned(t) && ((l+1) >= NBPW) &&
        (l inside {
           7, 9,11,13,15,17,19,21,23,25,
          27,29,31,33,35,37,39,41,43,45,
          47,49,51,53,55,57,59,61,63
        }))
      return WRAP_CLASS_UA_LONG_PLAN;

    return WRAP_CLASS_OTHER;
  endfunction

  function automatic int strb_class(logic [7:0] s);
    if (s == 8'h00) return 0;
    if (s == 8'hFF) return 2;
    return 1;
  endfunction

  function automatic int gap_classify(longint signed gap_cycles);
    if (gap_cycles <= 0) return GAP_B2B;
    if (gap_cycles <= 10) return GAP_1_10;
    return GAP_GT10;
  endfunction

  function automatic int packet_count_class(int n);
    if (n <= 1) return 0;
    if (n == 2) return 1;
    return 2;
  endfunction

  function automatic int count_valid_bytes(rknp_seq_item t);
    int n;
    n = 0;
    foreach (t.rd_be[i])
      if (t.rd_be[i]) n++;
    return n;
  endfunction

  function automatic int queue_find(
      ref int unsigned q[$], int unsigned txn_no);
    foreach (q[i])
      if (q[i] == txn_no) return i;
    return -1;
  endfunction

  function automatic int overlap_bytes(
      rknp_seq_item a, rknp_seq_item b);
    longint unsigned a0, a1, b0, b1, lo, hi;
    a0 = longint'(a.addr);
    b0 = longint'(b.addr);
    a1 = a0 + longint'(a.len);
    b1 = b0 + longint'(b.len);

    lo = (a0 > b0) ? a0 : b0;
    hi = (a1 < b1) ? a1 : b1;

    if (hi < lo) return 0;
    return int'(hi - lo + 1);
  endfunction

  function automatic rknp_seq_item clone_rknp(
      rknp_seq_item src, string name);
    rknp_seq_item c;
    c = rknp_seq_item::type_id::create(name);
    c.copy(src);
    return c;
  endfunction

  function automatic axi_seq_item clone_axi(
      axi_seq_item src, string name);
    axi_seq_item c;
    c = axi_seq_item::type_id::create(name);
    c.copy(src);
    return c;
  endfunction

  function automatic bit axi_addr_matches_expected(
      rknp_seq_item req, axi_seq_item ax);
    logic [axi_tniu_protocol_pkg::AADDR_WITH-1:0] expected_addr;

    expected_addr = axi_tniu_protocol_pkg::map_subr_addr_to_axaddr(
                      req.subr, req.addr, req.opc, req.len);
    return (ax.addr == expected_addr);
  endfunction

  function automatic int burst_map_class_of(
      rknp_seq_item req, axi_seq_item ax);
    int plan;
    int expected_burst;

    plan = wrap_plan_class_of(req);
    expected_burst = (req.is_wrap() && (int'(req.len) > 6)) ? 2 : 1;

    if (int'(ax.burst) != expected_burst)
      return 5;

    case (plan)
      WRAP_CLASS_NONE:          return 0;
      WRAP_CLASS_ALIGN_PLAN:    return 1;
      WRAP_CLASS_UA_SHORT_PLAN: return 2;
      WRAP_CLASS_UA_LONG_PLAN:  return 3;
      default:                  return 4;
    endcase
  endfunction

  function automatic int wrap_pair_alignment(
      rknp_seq_item a, rknp_seq_item b);
    if (!a.is_wrap() && !b.is_wrap()) return 0;
    if ((!a.is_wrap() || addr_aligned(a)) &&
        (!b.is_wrap() || addr_aligned(b)))
      return 1;
    return 2;
  endfunction

  // ===========================================================================
  // AXI address binding
  // ===========================================================================
  function void bind_req_to_axi(rknp_seq_item req, axi_seq_item ax);
    int kind;
    int id;

    if (req == null || ax == null) return;

    kind = kind_of(req);
    id   = int'(ax.id);

    cg_req_axi_map.sample(
      kind,
      wrap_plan_class_of(req),
      addr_aligned(req),
      int'(ax.burst),
      int'(ax.len),
      burst_map_class_of(req, ax),
      axi_addr_matches_expected(req, ax)
    );

    if (ax.dir == AXI_READ)
      axi_r_txn_q[id].push_back(req.txn_no);
    else
      axi_b_txn_q[id].push_back(req.txn_no);
  endfunction

  // ===========================================================================
  // RKNP request stream: inherited uvm_subscriber write()
  // ===========================================================================
  virtual function void write(rknp_seq_item t);
    rknp_seq_item c;
    int kind;
    int dir;
    int axid;
    int tkey;
    int first_of_type;
    int bshape;
    int gap_class;
    int same_axid_prev;
    int ov;
    int flow;
    int spec_class;
    int cur_multi;
    int prev_multi;
    int pair_align;

    if (t == null || t.is_rsp) return;

    c = clone_rknp(t, $sformatf("cov_req_%0d", t.txn_no));
    req_by_txn[t.txn_no] = c;

    kind   = kind_of(c);
    dir    = dir_of_kind(kind);
    axid   = axid_of(c);
    tkey   = type_key_of(c);
    bshape = body_shape_of(c);
    spec_class = special_class_of(c);

    first_of_type = (!type_depth.exists(tkey) || (type_depth[tkey] == 0));
    if (!type_depth.exists(tkey)) type_depth[tkey] = 0;
    type_depth[tkey]++;

    total_outstanding++;
    if ((kind == K_WRAP_RD) && !addr_aligned(c) &&
        (int'(c.len) > 6))
      unaligned_wrap_rd_outstanding++;

    if (dir == DIR_RD)
      rd_outstanding_q.push_back(c.txn_no);
    else
      wr_outstanding_q.push_back(c.txn_no);

    // Use the exact request-HEAD gap captured from the physical interface.
    if (req_gap_q.size() != 0)
      gap_class = req_gap_q.pop_front();
    else
      gap_class = GAP_FIRST;

    cur_multi = (expected_axi_beats(c) > 1);

    cg_req_protocol.sample(
      kind,
      int'(c.len),
      addr_aligned(c),
      cur_multi,
      int'(c.status),
      c.bufferable,
      axid,
      first_of_type,
      bshape
    );

    cg_req_user_qos.sample(
      int'(c.qos),
      int'(c.subr),
      int'(c.rknp_user),
      int'(c.axi_user),
      int'(c.axlock),
      int'(c.axport)
    );

    same_axid_prev = 0;

    if (have_prev_req) begin
      same_axid_prev = (axid_of(prev_req) == axid);
      prev_multi = (expected_axi_beats(prev_req) > 1);
      pair_align = wrap_pair_alignment(prev_req, c);

      if (gap_class != GAP_FIRST)
        cg_multi_req.sample(
          kind_of(prev_req), kind, gap_class,
          prev_multi, cur_multi,
          same_axid_prev, pair_align
        );

      // ADDR_OL only cares about first request being write and overlap 1..63.
      if (prev_req.is_write()) begin
        ov = overlap_bytes(prev_req, c);
        if ((ov >= 1) && (ov <= 63)) begin
          if (c.is_write()) flow = 0; // WAW
          else              flow = 1; // RAW

          cg_addr_overlap.sample(
            flow,
            prev_req.is_wrap(),
            c.is_wrap(),
            ov
          );
        end
      end
    end

    cg_special_req.sample(
      spec_class,
      kind,
      first_of_type,
      same_axid_prev,
      bshape,
      int'(c.errcode)
    );

    if (special_hist_count >= 2)
      cg_special_mix.sample(
        special_hist1, special_hist2, spec_class, same_axid_prev);

    // Shift special-history state.
    special_hist0 = special_hist1;
    special_hist1 = special_hist2;
    special_hist2 = spec_class;
    if (special_hist_count < 3) special_hist_count++;

    // Protocol-error requests are locally answered and should not emit AW/AR.
    // For all other requests, bind to an already observed AXI transaction or
    // queue the request until its AW/AR arrives.
    if (int'(c.status) != 1) begin
      if (c.is_write()) begin
        if (orphan_aw[axid].size() != 0) begin
          axi_seq_item ax;
          ax = orphan_aw[axid].pop_front();
          bind_req_to_axi(c, ax);
        end
        else begin
          pending_aw_req[axid].push_back(c.txn_no);
        end
      end
      else begin
        if (orphan_ar[axid].size() != 0) begin
          axi_seq_item ax;
          ax = orphan_ar[axid].pop_front();
          bind_req_to_axi(c, ax);
        end
        else begin
          pending_ar_req[axid].push_back(c.txn_no);
        end
      end
    end

    prev_req = clone_rknp(c, "cov_prev_req");
    have_prev_req = 1;
    prev_gap_class = gap_class;

    cg_stress.sample(
      total_outstanding,
      unaligned_wrap_rd_outstanding,
      timeout_streak
    );
  endfunction

  // ===========================================================================
  // AXI AW / AR address streams
  // ===========================================================================
  function void write_cov_aw(axi_seq_item t);
    int id;
    axi_seq_item c;

    if (t == null) return;
    id = int'(t.id);

    cg_axi_addr.sample(
      DIR_WR,
      int'(t.burst),
      int'(t.len),
      int'(t.size),
      int'(t.addr & 7)
    );

    if (pending_aw_req[id].size() != 0) begin
      int unsigned txn;
      txn = pending_aw_req[id].pop_front();
      if (req_by_txn.exists(txn))
        bind_req_to_axi(req_by_txn[txn], t);
    end
    else begin
      c = clone_axi(t, "cov_orphan_aw");
      orphan_aw[id].push_back(c);
    end
  endfunction

  function void write_cov_ar(axi_seq_item t);
    int id;
    axi_seq_item c;

    if (t == null) return;
    id = int'(t.id);

    cg_axi_addr.sample(
      DIR_RD,
      int'(t.burst),
      int'(t.len),
      int'(t.size),
      int'(t.addr & 7)
    );

    if (pending_ar_req[id].size() != 0) begin
      int unsigned txn;
      txn = pending_ar_req[id].pop_front();
      if (req_by_txn.exists(txn))
        bind_req_to_axi(req_by_txn[txn], t);
    end
    else begin
      c = clone_axi(t, "cov_orphan_ar");
      orphan_ar[id].push_back(c);
    end
  endfunction

  // ===========================================================================
  // RKNP response stream
  // ===========================================================================
  function void write_cov_rsp(rknp_seq_item t);
    rknp_seq_item req;
    int kind;
    int dir;
    int axid;
    int packet_pos;
    int bshape;
    int pkt_bytes;
    int need_bytes;
    int interleaved_now;
    int completed;
    int ooo;
    int idx;
    int pkt_cls;
    int axi_resp;
    int same_axid_prev_rsp;
    int prev_rsp_dir;
    int is_timeout;

    if (t == null || !t.is_rsp) return;
    if (!req_by_txn.exists(t.txn_no)) return;

    req   = req_by_txn[t.txn_no];
    kind  = kind_of(req);
    dir   = dir_of_kind(kind);
    axid  = axid_of(req);
    bshape= body_shape_of(req);

    packet_pos = (rsp_packet_count.exists(t.txn_no) &&
                  (rsp_packet_count[t.txn_no] != 0)) ? 1 : 0;

    if (!rsp_packet_count.exists(t.txn_no))
      rsp_packet_count[t.txn_no] = 0;
    rsp_packet_count[t.txn_no]++;

    interleaved_now = 0;
    if (have_last_rsp && (last_rsp_txn != t.txn_no) &&
        (!rsp_complete.exists(last_rsp_txn) || !rsp_complete[last_rsp_txn])) begin
      interleaved_now = 1;
      rsp_interleaved[t.txn_no] = 1;
      rsp_interleaved[last_rsp_txn] = 1;
    end

    if (!rsp_interleaved.exists(t.txn_no))
      rsp_interleaved[t.txn_no] = 0;

    completed = 0;

    if (dir == DIR_WR) begin
      // Write response is one response transaction.
      completed = 1;
    end
    else begin
      pkt_bytes = count_valid_bytes(t);
      if (!rsp_valid_bytes.exists(t.txn_no))
        rsp_valid_bytes[t.txn_no] = 0;
      rsp_valid_bytes[t.txn_no] += pkt_bytes;

      need_bytes = int'(req.len) + 1;
      if (rsp_valid_bytes[t.txn_no] >= need_bytes)
        completed = 1;
    end

    ooo = -1;
    if (completed) begin
      if (dir == DIR_RD) begin
        idx = queue_find(rd_outstanding_q, t.txn_no);
        if (idx >= 0) begin
          ooo = (idx != 0);
          rd_outstanding_q.delete(idx);
        end
      end
      else begin
        idx = queue_find(wr_outstanding_q, t.txn_no);
        if (idx >= 0) begin
          ooo = (idx != 0);
          wr_outstanding_q.delete(idx);
        end
      end
    end

    axi_resp = -1;
    if (axi_resp_by_txn.exists(t.txn_no))
      axi_resp = axi_resp_by_txn[t.txn_no];

    cg_rknp_rsp.sample(
      kind,
      int'(t.rsp_status),
      int'(t.rsp_errcode),
      packet_pos,
      bshape,
      rsp_interleaved[t.txn_no],
      ooo,
      axi_resp
    );

    // Timeout special response: Status=ERR, ErrorCode=TIM_OUT(3'b110).
    is_timeout = ((int'(t.rsp_status) == 1) &&
                  (int'(t.rsp_errcode) == 6));

    same_axid_prev_rsp = 0;
    prev_rsp_dir = -1;

    if (have_last_rsp && req_by_txn.exists(last_rsp_txn)) begin
      prev_rsp_dir = dir_of_kind(kind_of(req_by_txn[last_rsp_txn]));
      same_axid_prev_rsp =
        (axid_of(req_by_txn[last_rsp_txn]) == axid);
    end

    if (is_timeout) begin
      timeout_streak++;
      cg_timeout.sample(
        dir,
        bshape,
        timeout_streak,
        prev_timeout_dir,
        prev_rsp_dir,
        same_axid_prev_rsp
      );
      prev_timeout_dir = dir;
    end
    else begin
      timeout_streak = 0;
    end

    if (completed) begin
      int tkey;
      pkt_cls = packet_count_class(rsp_packet_count[t.txn_no]);

      cg_rsp_order.sample(
        dir,
        (ooo < 0) ? 0 : ooo,
        rsp_interleaved[t.txn_no],
        pkt_cls,
        same_axid_prev_rsp
      );

      rsp_complete[t.txn_no] = 1;

      tkey = type_key_of(req);
      if (type_depth.exists(tkey) && (type_depth[tkey] > 0))
        type_depth[tkey]--;

      if (total_outstanding > 0)
        total_outstanding--;

      if ((kind == K_WRAP_RD) && !addr_aligned(req) &&
          (int'(req.len) > 6) &&
          (unaligned_wrap_rd_outstanding > 0))
        unaligned_wrap_rd_outstanding--;

      cg_stress.sample(
        total_outstanding,
        unaligned_wrap_rd_outstanding,
        timeout_streak
      );
    end

    last_rsp_txn  = t.txn_no;
    last_rsp_kind = kind;
    last_rsp_axid = axid;
    have_last_rsp = 1;
  endfunction

  // ===========================================================================
  // Raw interface monitoring
  // ===========================================================================
  task run_phase(uvm_phase phase);
    fork
      begin
        if (have_rknp_vif)
          monitor_rknp_bus();
      end
      begin
        if (have_axi_vif)
          monitor_axi_bus();
      end
      begin
        if (have_axi_vif)
          monitor_axi_r_bus();
      end
    join
  endtask

  task monitor_rknp_bus();
    bit prev_resetn;
    bit ever_released;
    int req_stall;
    int rsp_stall;
    longint signed gap;

    prev_resetn = 0;
    ever_released = 0;
    req_stall = 0;
    rsp_stall = 0;

    forever begin
      @(posedge rknp_vif.aclk);
      rknp_cycle++;

      if (!rknp_vif.aresetn) begin
        if (prev_resetn)
          cg_reset.sample(1); // random reset assertion

        prev_resetn = 0;
        req_stall = 0;
        rsp_stall = 0;
        continue;
      end

      if (!prev_resetn) begin
        if (!ever_released)
          cg_reset.sample(0);
        else
          cg_reset.sample(2);

        ever_released = 1;
        prev_resetn = 1;
      end

      // Request channel
      if (rknp_vif.rxreq_valid && !rknp_vif.rxreq_ready)
        req_stall++;
      else if (rknp_vif.rxreq_valid && rknp_vif.rxreq_ready) begin
        cg_handshake.sample(
          0, 1, 1,
          int'(rknp_vif.rxreq_head),
          int'(rknp_vif.rxreq_tail),
          req_stall
        );
        req_stall = 0;

        if (rknp_vif.rxreq_head) begin
          if (!have_req_head_cycle) begin
            req_gap_q.push_back(GAP_FIRST);
            have_req_head_cycle = 1;
          end
          else begin
            gap = longint'(rknp_cycle) -
                  longint'(last_req_head_cycle) - 1;
            req_gap_q.push_back(gap_classify(gap));
          end
          last_req_head_cycle = rknp_cycle;
        end
      end

      if (rknp_vif.rxreq_valid && !rknp_vif.rxreq_ready)
        cg_handshake.sample(
          0, 1, 0,
          int'(rknp_vif.rxreq_head),
          int'(rknp_vif.rxreq_tail),
          req_stall
        );

      // Response channel
      if (rknp_vif.txrsp_valid && !rknp_vif.txrsp_ready)
        rsp_stall++;
      else if (rknp_vif.txrsp_valid && rknp_vif.txrsp_ready) begin
        cg_handshake.sample(
          1, 1, 1,
          int'(rknp_vif.txrsp_head),
          int'(rknp_vif.txrsp_tail),
          rsp_stall
        );
        rsp_stall = 0;
      end

      if (rknp_vif.txrsp_valid && !rknp_vif.txrsp_ready)
        cg_handshake.sample(
          1, 1, 0,
          int'(rknp_vif.txrsp_head),
          int'(rknp_vif.txrsp_tail),
          rsp_stall
        );
    end
  endtask

  // ---------------------------------------------------------------------------
  // Raw AXI W/B coverage.
  //
  // Keep W/B sampling behavior unchanged. R-channel coverage is handled by
  // monitor_axi_r_bus() so interleave detection can use the same clocking block
  // as axi_monitor.
  // ---------------------------------------------------------------------------
  task monitor_axi_bus();
    int id;
    int txn;

    forever begin
      @(posedge axi_vif.aclk);

      if (!axi_vif.aresetn) begin
        wbeat_count = 0;
        continue;
      end

      // ---------------- AXI W ----------------
      if (axi_vif.wvalid && axi_vif.wready) begin
        wbeat_count++;

        if (wbeat_count == 1)
          w_first_strb_class = strb_class(axi_vif.wstrb);

        w_last_strb_class = strb_class(axi_vif.wstrb);

        if (axi_vif.wlast) begin
          cg_axi_w.sample(
            wbeat_count,
            w_first_strb_class,
            w_last_strb_class
          );
          wbeat_count = 0;
        end
      end

      // ---------------- AXI B ----------------
      if (axi_vif.bvalid && axi_vif.bready) begin
        id = int'(axi_vif.bid);

        cg_axi_rsp.sample(
          DIR_WR,
          int'(axi_vif.bresp),
          3, // single
          0,
          id
        );

        if (axi_b_txn_q[id].size() != 0) begin
          txn = axi_b_txn_q[id].pop_front();
          axi_resp_by_txn[txn] = int'(axi_vif.bresp);
        end
      end
    end
  endtask

  // ---------------------------------------------------------------------------
  // Raw AXI R-channel coverage.
  //
  // Interleave definition:
  //   An accepted R beat switches from RID=A to RID=B while RID=A still has an
  //   open burst (A's accepted RLAST has not occurred yet).
  //
  // Sampling uses axi_vif.mon_cb, matching axi_monitor.
  //
  // rbeat_count.exists(id):
  //   1 -> that RID has started and its RLAST has not yet been accepted.
  //   0 -> no open burst for that RID.
  //
  // Example:
  //   RID=7, RLAST=0, handshake
  //   RID=8,          handshake
  //
  // At the RID=8 beat, RID 7 is still open, so ilv_switch=1.
  // ---------------------------------------------------------------------------
  task monitor_axi_r_bus();
    int id;
    int beat_pos;
    int ilv_switch;
    int txn;
    int resp_to_store;

    forever begin
      @(axi_vif.mon_cb);

      if (!axi_vif.aresetn) begin
        rbeat_count.delete();
        rfirst_resp.delete();
        have_last_rbeat = 0;
        last_rid = -1;
        continue;
      end

      if (axi_vif.mon_cb.rvalid && axi_vif.mon_cb.rready) begin
        id = int'(axi_vif.mon_cb.rid);

        // Detect switch before updating current-RID state.
        ilv_switch = 0;
        if (have_last_rbeat &&
            (last_rid != id) &&
            rbeat_count.exists(last_rid)) begin
          ilv_switch = 1;

          `uvm_info(
            "COV_AXI_R_ILV",
            $sformatf(
              "AXI R interleave: previous RID=%0d still open, current RID=%0d",
              last_rid, id
            ),
            UVM_HIGH
          )
        end

        if (!rbeat_count.exists(id))
          rbeat_count[id] = 0;

        if (rbeat_count[id] == 0)
          rfirst_resp[id] = axi_vif.mon_cb.rresp;

        if ((rbeat_count[id] == 0) && axi_vif.mon_cb.rlast)
          beat_pos = 3; // single
        else if (rbeat_count[id] == 0)
          beat_pos = 0; // first
        else if (axi_vif.mon_cb.rlast)
          beat_pos = 2; // last
        else
          beat_pos = 1; // middle

        cg_axi_rsp.sample(
          DIR_RD,
          int'(axi_vif.mon_cb.rresp),
          beat_pos,
          ilv_switch,
          id
        );

        rbeat_count[id]++;

        if (axi_vif.mon_cb.rlast) begin
          resp_to_store = int'(rfirst_resp[id]);

          if (axi_r_txn_q[id].size() != 0) begin
            txn = axi_r_txn_q[id].pop_front();
            axi_resp_by_txn[txn] = resp_to_store;
          end

          rbeat_count.delete(id);
          rfirst_resp.delete(id);
        end

        last_rid = id;
        have_last_rbeat = 1;
      end
    end
  endtask

  // ===========================================================================
  // Coverage summary
  // ===========================================================================
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);

    `uvm_info("COV_SUMMARY",
      $sformatf(
        {"Functional coverage summary:\n",
         "  reset            = %0.2f%%\n",
         "  handshake        = %0.2f%%\n",
         "  request protocol = %0.2f%%\n",
         "  request user/qos = %0.2f%%\n",
         "  AXI address       = %0.2f%%\n",
         "  req->AXI map      = %0.2f%%\n",
         "  multi request     = %0.2f%%\n",
         "  address overlap   = %0.2f%%\n",
         "  special request   = %0.2f%%\n",
         "  special mix       = %0.2f%%\n",
         "  RKNP response     = %0.2f%%\n",
         "  response ordering = %0.2f%%\n",
         "  AXI response      = %0.2f%%\n",
         "  AXI W             = %0.2f%%\n",
         "  timeout           = %0.2f%%\n",
         "  stress            = %0.2f%%"},
        cg_reset.get_inst_coverage(),
        cg_handshake.get_inst_coverage(),
        cg_req_protocol.get_inst_coverage(),
        cg_req_user_qos.get_inst_coverage(),
        cg_axi_addr.get_inst_coverage(),
        cg_req_axi_map.get_inst_coverage(),
        cg_multi_req.get_inst_coverage(),
        cg_addr_overlap.get_inst_coverage(),
        cg_special_req.get_inst_coverage(),
        cg_special_mix.get_inst_coverage(),
        cg_rknp_rsp.get_inst_coverage(),
        cg_rsp_order.get_inst_coverage(),
        cg_axi_rsp.get_inst_coverage(),
        cg_axi_w.get_inst_coverage(),
        cg_timeout.get_inst_coverage(),
        cg_stress.get_inst_coverage()
      ),
      UVM_LOW
    )
  endfunction

endclass : axi_tniu_coverage

`endif // AXI_TNIU_COVERAGE_SV
