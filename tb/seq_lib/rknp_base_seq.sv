// =============================================================================
// File        : rknp_base_seq.sv
// Description : Common RKNP sequence controls and constraint-safe helpers.
// =============================================================================
`ifndef RKNP_BASE_SEQ_SV
`define RKNP_BASE_SEQ_SV

typedef enum bit {
  WRAP_LEN_NARROW,
  WRAP_LEN_FULL
} wrap_len_mode_e;

typedef enum bit {
  WRAP_ADDR_NOALIGN,
  WRAP_ADDR_ALIGN
} wrap_addr_align_mode_e;

class rknp_base_seq extends uvm_sequence #(rknp_seq_item);
  `uvm_object_utils(rknp_base_seq)

  int unsigned    num_txn = 1;
  wrap_len_mode_e wrap_len_mode = WRAP_LEN_FULL;
  bit             force_flit_aligned_addr = 1'b0;
  bit use_fixed_orderkey;
  axi_tniu_protocol_pkg::ordkey_t fixed_orderkey;

  localparam int unsigned MAX_LEN =
      (1 << axi_tniu_protocol_pkg::LEN_WITH) - 1;

  localparam int unsigned NBPW =
      axi_tniu_protocol_pkg::NBYTEPERWORD;

  // Current WRAP functional definition supports at most 16 AXI beats.
  //
  // With the current 64-bit AXI data width:
  //   NBPW = 8 bytes/beat
  //   MAX_WRAP_LEN = 16 * 8 - 1 = 127
  //
  // Therefore the legal WRAP LEN values selected by choose_wrap_len() are:
  //   WRAP_LEN_NARROW : 1, 3
  //   WRAP_LEN_FULL   : 7, 15, 31, 63, 127
  //
  // LEN=255 is deliberately excluded because it would represent 256 bytes,
  // i.e. 32 beats on the current 8-byte AXI data path.
  localparam int unsigned MAX_WRAP_BEATS = 16;
  localparam int unsigned MAX_WRAP_LEN =
      (MAX_WRAP_BEATS * NBPW) - 1;

  function new(string name = "rknp_base_seq");
    super.new(name);
  endfunction

  virtual task finalize_item(rknp_seq_item it);
    it.build_aligned_write_body();
  endtask

  protected function int unsigned choose_incr_len(int unsigned index);
    if (num_txn < 4)
      return $urandom_range(0, MAX_LEN);

    case (index)
      0:       return 0;
      1:       return MAX_LEN;
      2:       return $urandom_range(1, NBPW - 1);
      3:       return $urandom_range(NBPW, MAX_LEN - 1);
      default: return $urandom_range(0, MAX_LEN);
    endcase
  endfunction

  // ---------------------------------------------------------------------------
  // Select one legal WRAP LEN.
  //
  // WRAP LEN follows 2^n-1:
  //   1, 3, 7, 15, 31, 63, 127, ...
  //
  // The sequence helper is intentionally limited to MAX_WRAP_BEATS=16 so its
  // generated values stay consistent with the current c_wrap_len definition.
  //
  // Current NBPW=8:
  //   WRAP_LEN_NARROW -> {1,3}
  //   WRAP_LEN_FULL   -> {7,15,31,63,127}
  // ---------------------------------------------------------------------------
  protected function int unsigned choose_wrap_len();
    int unsigned candidate;
    int unsigned legal_len[$];
    int unsigned wrap_len_limit;

    // Protect the helper if LEN_WITH is ever reduced below MAX_WRAP_LEN.
    wrap_len_limit =
        (MAX_WRAP_LEN < MAX_LEN) ? MAX_WRAP_LEN : MAX_LEN;

    candidate = 1;

    while (candidate <= wrap_len_limit) begin
      if (((wrap_len_mode == WRAP_LEN_NARROW) &&
           (candidate < (NBPW - 1))) ||
          ((wrap_len_mode == WRAP_LEN_FULL) &&
           (candidate >= (NBPW - 1)))) begin
        legal_len.push_back(candidate);
      end

      candidate = (candidate << 1) | 1;
    end

    if (legal_len.size() == 0) begin
      `uvm_fatal(
        "SEQ_WRAP_CFG",
        $sformatf(
          "No legal WRAP length: mode=%0d NBPW=%0d MAX_WRAP_BEATS=%0d MAX_WRAP_LEN=%0d",
          wrap_len_mode, NBPW, MAX_WRAP_BEATS, MAX_WRAP_LEN
        )
      )
    end

    return legal_len[$urandom_range(0, legal_len.size() - 1)];
  endfunction

  protected task complete_item(rknp_seq_item it, string id);
    if (it == null)
      `uvm_fatal(id, "Null sequence item")

    finalize_item(it);
    finish_item(it);
  endtask

endclass : rknp_base_seq

`endif // RKNP_BASE_SEQ_SV
