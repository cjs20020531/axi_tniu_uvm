class c_6_2;
    bit[31:0] selected_len = 32'hff;
    rand bit[7:0] len; // rand_mode = ON 
    rand bit[3:0] opc; // rand_mode = ON 

    constraint c_wrap_len_this    // (constraint_mode = ON) (/home/ICer/RKNoC/axi_tniu_uvm/tb/rknp_agent/rknp_seq_item.sv:334)
    {
       ((opc == 4'h1 /* axi_tniu_protocol_pkg::req_opc_e::OPC_RDW */) || (opc == 4'h5 /* axi_tniu_protocol_pkg::req_opc_e::OPC_WRW */)) -> (len inside {8'h1, 8'h3, 8'h7, 8'hf, 8'h1f, 8'h3f, 8'h7f});
    }
    constraint WITH_CONSTRAINT_this    // (constraint_mode = ON) (/home/ICer/RKNoC/axi_tniu_uvm/tb/seq_lib/seq_norm_rdw.sv:21)
    {
       (opc == 4'h1 /* axi_tniu_protocol_pkg::req_opc_e::OPC_RDW */);
       (len == selected_len);
    }
endclass

program p_6_2;
    c_6_2 obj;
    string randState;

    initial
        begin
            obj = new;
            randState = "1x1x00z01z110z1xxx0x0zzx0z0z1xxzzzzzxzxxzzxzzxxzxxzzzzzxxxxzzxzz";
            obj.set_randstate(randState);
            obj.randomize();
        end
endprogram
