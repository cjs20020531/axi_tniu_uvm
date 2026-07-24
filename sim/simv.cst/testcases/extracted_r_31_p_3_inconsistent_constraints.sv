class c_31_3;
    rand bit[1:0] status; // rand_mode = ON 

    constraint c_status_this    // (constraint_mode = ON) (/home/ICer/RKNoC/axi_tniu_uvm_260708/tb/rknp_agent/rknp_seq_item.sv:238)
    {
       (status == 2'h0 /* axi_tniu_protocol_pkg::status_e::ST_OK */);
    }
    constraint WITH_CONSTRAINT_this    // (constraint_mode = ON) (/home/ICer/RKNoC/axi_tniu_uvm_260708/tb/seq_lib/rknp_sequences.sv:125)
    {
       (status == 2'h1 /* axi_tniu_protocol_pkg::status_e::ST_ERR */);
    }
endclass

program p_31_3;
    c_31_3 obj;
    string randState;

    initial
        begin
            obj = new;
            randState = "1zxz0zzxx0z1zz10x1zxzzxzxx00z01zxzzzzzxxxxxzxxxzzxzzzxxzxxxzxzxx";
            obj.set_randstate(randState);
            obj.randomize();
        end
endprogram
