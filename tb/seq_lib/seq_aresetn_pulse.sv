`ifndef SEQ_ARESETN_PULSE_SV
`define SEQ_ARESETN_PULSE_SV

// Drive one active-low reset pulse after the initial power-on reset has
// already been released.  aresetn is owned by tb_top, so this small virtual
// sequence uses the UVM HDL backdoor instead of driving an interface input.
class seq_aresetn_pulse extends uvm_sequence;
  `uvm_object_utils(seq_aresetn_pulse)

  virtual rknp_if vif;

  int unsigned low_cycles = 5;
  string       reset_path = "tb_top.aresetn";

  function new(string name = "seq_aresetn_pulse");
    super.new(name);
  endfunction

  task body();
    if (vif == null)
      `uvm_fatal("RESET_SEQ", "rknp_if handle is null")

    if (low_cycles == 0)
      `uvm_fatal("RESET_SEQ", "low_cycles must be greater than zero")

    // This sequence is for a second reset, not the initial power-on reset.
    wait (vif.aresetn === 1'b1);

    // Assert between active clock edges so the following posedge is a full
    // reset cycle.  Deposit is intentional: tb_top's initial reset process has
    // already completed and has no later procedural assignment to overwrite it.
    @(negedge vif.aclk);
    if (!uvm_hdl_deposit(reset_path, 1'b0))
      `uvm_fatal("RESET_SEQ",
                 $sformatf("Cannot drive reset path '%s' low", reset_path))

    if (vif.aresetn !== 1'b0)
      `uvm_fatal("RESET_SEQ", "aresetn did not change from 1 to 0")

    `uvm_info("RESET_SEQ",
              $sformatf("aresetn asserted for %0d cycles", low_cycles),
              UVM_LOW)

    repeat (low_cycles) begin
      @(posedge vif.aclk);
      if (vif.aresetn !== 1'b0)
        `uvm_fatal("RESET_SEQ", "aresetn was released earlier than expected")
    end

    // Deassert between edges and leave one active clock edge for all agents
    // and the DUT to observe normal operation before the next request starts.
    @(negedge vif.aclk);
    if (!uvm_hdl_deposit(reset_path, 1'b1))
      `uvm_fatal("RESET_SEQ",
                 $sformatf("Cannot drive reset path '%s' high", reset_path))

    @(posedge vif.aclk);
    if (vif.aresetn !== 1'b1)
      `uvm_fatal("RESET_SEQ", "aresetn did not return to 1")

    `uvm_info("RESET_SEQ", "aresetn deasserted; reset pulse completed", UVM_LOW)
  endtask
endclass : seq_aresetn_pulse

`endif // SEQ_ARESETN_PULSE_SV
