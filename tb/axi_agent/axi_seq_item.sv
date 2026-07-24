// =============================================================================
// File        : axi_seq_item.sv
// Description : AXI transaction item. Used by the AXI slave agent both to model
//               a captured AW/AR/W burst and to carry the slave RESPONSE policy
//               (response code, beat delays, out-of-order / interleave hints).
//               A slave sequence can override these to steer corner cases.
// Project      : RKNoC - AXI Target NIU verification
// Author       : Verification Team
// =============================================================================
`ifndef AXI_SEQ_ITEM_SV
`define AXI_SEQ_ITEM_SV

typedef enum bit {AXI_READ, AXI_WRITE} axi_dir_e;

class axi_seq_item extends uvm_sequence_item;

  // ---- captured address-phase info ------------------------------------------
  axi_dir_e                dir;
  rand logic [3:0]         id;        // AXID_WITH=4
  logic [39:0]             addr;      // AADDR_WITH=40
  logic [7:0]              len;       // beats-1
  logic [2:0]              size;
  logic [1:0]              burst;
  logic [3:0]              cache;

  // ---- data -----------------------------------------------------------------
  logic [63:0]             data[];    // per-beat read/write data
  logic [7:0]              strb[];    // write strobes per beat

  // ---- slave response policy (rand for random slaves) -----------------------
  rand logic [1:0]         resp;             // OKAY/EXOKAY/SLVERR/DECERR
  rand int unsigned        addr_ready_delay; // cycles before AxREADY
  rand int unsigned        resp_delay;       // cycles before first R/B beat
  rand int unsigned        beat_gap;         // cycles between R beats
  rand bit                 allow_interleave; // may interleave with other read IDs

  `uvm_object_utils_begin(axi_seq_item)
    `uvm_field_enum(axi_dir_e, dir, UVM_ALL_ON)
    `uvm_field_int (id,    UVM_ALL_ON)
    `uvm_field_int (addr,  UVM_ALL_ON)
    `uvm_field_int (len,   UVM_ALL_ON)
    `uvm_field_int (burst, UVM_ALL_ON)
    `uvm_field_int (resp,  UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "axi_seq_item");
    super.new(name);
  endfunction

  constraint c_resp   { resp inside {2'b00, 2'b10}; resp dist {2'b00:=90, 2'b10:=10}; }
  constraint c_delay  { addr_ready_delay inside {[0:3]};
                        resp_delay       inside {[0:6]};
                        beat_gap         inside {[0:2]}; }

  // ---- self description : one compact line per transaction ------------------
  function string convert2string();
    return $sformatf("AXI-%s id=0x%0h addr=0x%010h len=%0d(beats=%0d) size=%0d burst=%0d cache=0x%0h resp=%0d [awdly=%0d rdly=%0d gap=%0d ilv=%0b]",
                     (dir==AXI_WRITE)?"WR":"RD", id, addr, len, len+1, size, burst, cache,
                     resp, addr_ready_delay, resp_delay, beat_gap, allow_interleave);
  endfunction

  // print the transaction at generation time (right after randomize)
  function void post_randomize();
    `uvm_info("AXI_TXN", convert2string(), UVM_HIGH)
  endfunction




endclass : axi_seq_item




`endif // AXI_SEQ_ITEM_SV

