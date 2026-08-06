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

  localparam int unsigned MAX_LEN = (1 << axi_tniu_protocol_pkg::LEN_WITH) - 1;
  localparam int unsigned NBPW    = axi_tniu_protocol_pkg::NBYTEPERWORD;

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

  protected function int unsigned choose_wrap_len();
    int unsigned candidate;
    int unsigned legal_len[$];

    candidate = 1;
    while (candidate <= MAX_LEN) begin
      if (((wrap_len_mode == WRAP_LEN_NARROW) && (candidate < (NBPW - 1))) ||
           ((wrap_len_mode == WRAP_LEN_FULL) && (candidate >= (NBPW - 1))))
        legal_len.push_back(candidate);
      candidate = (candidate << 1) | 1;
    end

    if (legal_len.size() == 0)
      `uvm_fatal("SEQ_WRAP_CFG", "No legal WRAP length for selected mode")

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
