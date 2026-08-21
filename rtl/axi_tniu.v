module axi_tniu#(
     
     //RKNoC可配置位宽域段参数
     parameter URGE_WITH = 7
    ,parameter SUBR_WITH = 8
    ,parameter IID_WITH = 10
    ,parameter TID_WITH = 10
    ,parameter ADDR_WITH = 32
    ,parameter AXID_WITH = 4
    ,parameter ORDKEY_WITH = 8 
    ,parameter LEN_WITH = 8 
    ,parameter USER_WITH = 10
    ,parameter NBYTEPERWORD = 8

    //req packet域段偏移量参数
    ,parameter REQ_IID_OFFSET = 7
    ,parameter REQ_TID_OFFSET = 17
    ,parameter REQ_SUBR_OFFSET = 27
    ,parameter REQ_ORDKEY_OFFSET = 35 
    ,parameter REQ_OPC_OFFSET = 43
    ,parameter REQ_STATUS_OFFSET = 47
    ,parameter REQ_LEN_OFFSET = 49 
    ,parameter REQ_ADDR_OFFSET = 57
    ,parameter REQ_USER_OFFSET = 89
    ,parameter REQ_ERRC_OFFSET = 99
    ,parameter REQ_HEAD_LEN_OFFSET = 102
    ,parameter REQ_FLIT_WITH = 175

    //rsp packet域段偏移量参数
    ,parameter RSP_IID_OFFSET = 7
    ,parameter RSP_TID_OFFSET = 17
    ,parameter RSP_ORDKEY_OFFSET = 27
    ,parameter RSP_OPC_OFFSET = 35
    ,parameter RSP_STATUS_OFFSET =37
    ,parameter RSP_ADDR_OFFSET = 39
    ,parameter RSP_USER_OFFSET = 71
    ,parameter RSP_ERRC_OFFSET = 81
    ,parameter RSP_HEAD_LEN_OFFSET = 84
    ,parameter RSP_FLIT_WITH = 157

    //AXI可配置接口位宽参数
    ,parameter AADDR_WITH = 40
    ,parameter AUSER_WITH = 1
    ,parameter AQOS_WITH = 3
    
    //watchdog计数器配置参数
    ,parameter TIMOUT_VALUE = 10240          //可配置最大超时值（限制大于3，默认值为10240）  

    //模式配置参数
    ,parameter SUP_REQ_NUM = 8  //支持最大请求个数
    ,parameter ADDR_BLOCK_SIZE = 64
    ,parameter ADDR_BP_TYPE = 1  // 0:无同地址反压  1:写后读/写后写同地址反压   2:写后读/写后写/读后写同地址反压
    ,parameter EARLY_RSP_MODE = 1 // 0：关闭early response模式    1：开启early response模式
    ,parameter WRAP_ALIGN_MODE = 1 // 0：关闭wrap align模式    1：开启wrap align模式
    ,parameter RWRAP_CNT_MAX = 4
    ,parameter PS_SWITCH = 0      //0:并行输出，1：串行输出

    ,parameter DLY = 0
)(
     input                                aclk
    ,input                                aresetn

    // rknp请求通道接口             
    ,input                                rknp_rxreq_head
    ,input                                rknp_rxreq_tail
    ,input                                rknp_rxreq_valid
    ,output                               rknp_rxreq_ready
    ,input       [REQ_FLIT_WITH-1:0]      rknp_rxreq_data
    // rknp响应通道接口             
    ,output                               rknp_txrsp_head
    ,output                               rknp_txrsp_tail
    ,output                               rknp_txrsp_valid
    ,input                                rknp_txrsp_ready
    ,output      [RSP_FLIT_WITH-1:0]      rknp_txrsp_data
    
    // The interface signals of AXI AW channel
    ,output                               axi_m_awvalid
    ,input                                axi_m_awready
    ,output      [AXID_WITH-1:0]          axi_m_awid
    ,output      [AADDR_WITH-1:0]         axi_m_awaddr
    ,output      [7:0]                    axi_m_awlen
    ,output      [2:0]                    axi_m_awsize
    ,output      [1:0]                    axi_m_awburst
    ,output                               axi_m_awlock
    ,output      [3:0]                    axi_m_awcache
    ,output      [2:0]                    axi_m_awprot
    ,output      [AQOS_WITH-1:0]          axi_m_awqos
    ,output      [AUSER_WITH-1:0]         axi_m_awuser

    // The interface signals of AXI W channel
    ,output reg                           axi_m_wvalid
    ,input                                axi_m_wready
    ,output reg                           axi_m_wlast
    ,output reg  [AXID_WITH-1:0]          axi_m_wid
    ,output reg  [8*NBYTEPERWORD-1:0]     axi_m_wdata
    ,output reg  [NBYTEPERWORD-1:0]       axi_m_wstrb

    // The interface signals of AXI AR channel
    ,output reg                           axi_m_arvalid
    ,input                                axi_m_arready
    ,output reg  [AXID_WITH-1:0]          axi_m_arid
    ,output reg  [AADDR_WITH-1:0]         axi_m_araddr
    ,output reg  [7:0]                    axi_m_arlen
    ,output reg  [2:0]                    axi_m_arsize
    ,output reg  [1:0]                    axi_m_arburst
    ,output reg                           axi_m_arlock
    ,output reg  [3:0]                    axi_m_arcache
    ,output reg  [2:0]                    axi_m_arprot
    ,output reg  [AQOS_WITH-1:0]          axi_m_arqos
    ,output reg  [AUSER_WITH-1:0]         axi_m_aruser

    // The interface signals of AXI R channel
    ,input                              axi_m_rvalid
    ,output wire                        axi_m_rready
    ,input       [AXID_WITH-1:0]        axi_m_rid
    ,input       [8*NBYTEPERWORD-1:0]   axi_m_rdata
    ,input       [1:0]                  axi_m_rresp
    ,input       [AUSER_WITH-1:0]       axi_m_ruser
    ,input                              axi_m_rlast

    // The interface signals of AXI B channel
    ,input                              axi_m_bvalid
    ,output wire                        axi_m_bready
    ,input       [AXID_WITH-1:0]        axi_m_bid
    ,input       [1:0]                  axi_m_bresp
    ,input       [AUSER_WITH-1:0]       axi_m_buser

);

localparam TAG_CNT_WITH       = $clog2(SUP_REQ_NUM);
localparam HEAD_BUFF_DEEP     = SUP_REQ_NUM;
localparam SPEC_REQ_BUFF_DEEP = SUP_REQ_NUM;
localparam TIMOUT_TABLE_DEEP  = SUP_REQ_NUM;
localparam ELYRSP_TABLE_DEEP  = SUP_REQ_NUM;


wire                              clk;
wire                              resetn;
// rknp_xx to wrap_align/req_order
wire                              rknp_xx2reqo_head;
wire                              rknp_xx2reqo_tail;
wire                              rknp_xx2reqo_valid;
wire [REQ_FLIT_WITH-1:0]          rknp_xx2reqo_data;
wire                              reqo2rknp_xx_ready;
// req_order to rsp_order       
wire                              reqo2rspo_head;
wire                              reqo2rspo_tail;
wire                              reqo2rspo_valid;
wire                              rspo2reqo_ready;
wire [URGE_WITH-1:0]              reqo2rspo_urg;
wire [SUBR_WITH-1:0]              reqo2rspo_subr;
wire [ADDR_WITH-1:0]              reqo2rspo_addr;
wire [AXID_WITH-1:0]              reqo2rspo_axid;
wire [3:0]                        reqo2rspo_opc;
wire [2:0]                        reqo2rspo_errcode;
wire [1:0]                        reqo2rspo_status;
wire [LEN_WITH-1:0]               reqo2rspo_len;
wire [USER_WITH-1:0]              reqo2rspo_user;
wire [NBYTEPERWORD*9:0]           reqo2rspo_data;
wire [TAG_CNT_WITH-1:0]           reqo2rspo_tag_cnt;
wire                              fir_req_flag;

wire [HEAD_BUFF_DEEP*(AXID_WITH+3)-1:0] reqo2rspo_tag_name;  //将一维数组输出 
// wrap_align to req_order      
wire [7:0]                        wa2reqo_offset_addr;
// req_order to rsp_order      
wire [URGE_WITH-1:0]              reqo2rspo_rsp_urg;
wire [ADDR_WITH-1:0]              reqo2rspo_rsp_addr;
wire [ORDKEY_WITH-1:0]            reqo2rspo_rsp_ordkey;
wire [LEN_WITH-1:0]               reqo2rspo_rsp_len;
wire [USER_WITH-1:0]              reqo2rspo_rsp_user;
wire [IID_WITH-1:0]               reqo2rspo_rsp_iid;
wire [TID_WITH-1:0]               reqo2rspo_rsp_tid;
wire [1:0]                        reqo2rspo_rsp_status;
wire [7:0]                        reqo2rspo_rsp_offset_addr;
wire [AXID_WITH+TAG_CNT_WITH+1:0] rspo2reqo_head_index;
wire                              rspo2reqo_rhead_en;
wire                              rspo2reqo_rsp_valid;
wire                              del_head_en;
wire                              reqo2rspo_timout;
wire                              rspo2reqo_timout;
// req_order to watchdog      
wire [AXID_WITH-1:0]              reqo2wd_axid;
wire [1:0]                        reqo2wd_opc;
wire [TAG_CNT_WITH-1:0]           reqo2wd_tag_cnt;
wire                              reqo2wd_timon_en;
wire                              timer_interrupt;
wire [HEAD_BUFF_DEEP*(AXID_WITH+2+TAG_CNT_WITH+1)-1:0] reqo2wd_timout_table;

// rsp_trans to rsp_trans
wire                              rspt2rspo_head           ;                                            
wire                              rspt2rspo_tail           ;                                            
wire                              rspt2rspo_valid          ;                                             
wire                              rspo2rspt_ready          ;                                             
wire [AXID_WITH-1:0]              rspt2rspo_axid           ;                                            
wire [AUSER_WITH:0]               rspt2rspo_auser          ;                                            
wire [1:0]                        rspt2rspo_opc            ;                                           
wire [2:0]                        rspt2rspo_errcode        ;  
wire [1:0]                        rspt2rspo_status         ;                                             
wire [9*NBYTEPERWORD:0]           rspt2rspo_data           ;     
wire                              rspt2rspo_lw             ;

//rsp_order to rknp_xx
wire                              rspo2rknp_xx_head         ;                       
wire                              rspo2rknp_xx_tail         ;                           
wire                              rspo2rknp_xx_valid        ;                           
wire                              rknp_xx2rspo_ready        ;                       
wire [RSP_FLIT_WITH-1:0]           rspo2rknp_xx_data         ;              


// rsp_order to wrap_adjust
wire [7:0]                        rspo2wad_offset_addr      ;        
wire [AXID_WITH-1:0]              rspo2wad_axid             ; 



// rsp_order to watchdog
wire [AXID_WITH-1:0]              wd2rspo_axid             ;       
wire [1:0]                        wd2rspo_opc              ;    
wire                              timout_fifo_empty        ;          
wire                              timout_fifo_rden         ;         
wire [AXID_WITH-1:0]              rspo2wd_axid             ;     
wire [1:0]                        rspo2wd_opc              ;    
wire [TAG_CNT_WITH-1:0]           rspo2wd_tag_cnt          ;        
wire                              rspo2wd_timoff_en        ;  

// rsp_order to addr_map
wire                              rspo2am_head             ;                         
wire                              rspo2am_tail             ;                      
wire                              rspo2am_valid            ;                       
wire                              am2rspo_ready            ;                       
wire [URGE_WITH-1:0]              rspo2am_urg              ;                     
wire [SUBR_WITH-1:0]              rspo2am_subr             ;                      
wire [ADDR_WITH-1:0]              rspo2am_addr             ;                      
wire [AXID_WITH-1:0]              rspo2am_axid             ;                      
wire [3:0]                        rspo2am_opc              ;                     
wire [LEN_WITH-1:0]               rspo2am_len              ;                     
wire [USER_WITH-1:0]              rspo2am_user             ;                      
wire [9*NBYTEPERWORD:0]           rspo2am_data             ;                      

// addr_map to rreq_trans
wire                              am2rreqt_head            ;                       
wire                              am2rreqt_tail            ;                       
wire                              am2rreqt_valid           ;                        
wire                              rreqt2am_ready           ;                        
wire [AADDR_WITH-1:0]             am2rreqt_araddr          ;                         
wire [AXID_WITH-1:0]              am2rreqt_axid            ;                       
wire [1:0]                        am2rreqt_opc             ;                      
wire [7:0]                        am2rreqt_arlen           ;                        
wire [USER_WITH-1:0]              am2rreqt_user            ;                       
wire [AQOS_WITH-1:0]              am2rreqt_arqos           ;                        

// addr_map to wreq_trans
wire                              am2wreqt_head            ;                       
wire                              am2wreqt_tail            ;                       
wire                              am2wreqt_valid           ;                        
wire                              wreqt2am_ready           ;                        
wire [AADDR_WITH-1:0]             am2wreqt_awaddr          ;                         
wire [AXID_WITH-1:0]              am2wreqt_axid            ;                       
wire [1:0]                        am2wreqt_opc             ;                      
wire [7:0]                        am2wreqt_awlen           ;                        
wire [USER_WITH-1:0]              am2wreqt_user            ;                       
wire [AQOS_WITH-1:0]              am2wreqt_awqos           ;                        
wire [9*NBYTEPERWORD:0]           am2wreqt_data            ;                       


assign clk    = aclk;
assign resetn = aresetn;


generate
    if(WRAP_ALIGN_MODE == 0) begin
        assign rknp_xx2reqo_head  = rknp_rxreq_head;
        assign rknp_xx2reqo_tail  = rknp_rxreq_tail;
        assign rknp_xx2reqo_valid = rknp_rxreq_valid;
        assign rknp_xx2reqo_data  = rknp_rxreq_data;
        assign rknp_rxreq_ready   = reqo2rknp_xx_ready;
        assign wa2reqo_offset_addr= 8'd0;


    end else begin
        // rknp_xx to wrap_align
        wire                     rknp_xx2wa_head;
        wire                     rknp_xx2wa_tail;
        wire                     rknp_xx2wa_valid;
        wire [REQ_FLIT_WITH-1:0] rknp_xx2wa_data;
        wire                     wa2rknp_xx_ready;
        // wrap_align to req_order
        wire                     wa2reqo_head;
        wire                     wa2reqo_tail;
        wire                     wa2reqo_valid;
        wire                     reqo2wa_ready;
        wire [REQ_FLIT_WITH-1:0] wa2reqo_data;
        // wrap_adjust to wrap_align
        wire                     rwrap_rsp_fin;

        // rsp_order to wrap_adjust
        wire                     rspo2wad_head;
        wire                     rspo2wad_tail;
        wire                     rspo2wad_valid;
        wire                     wad2rspo_ready;
        wire [RSP_FLIT_WITH-1:0] rspo2wad_data;
        // wire [7:0]               rspo2wad_offset_addr;  //别的地方已经定义了
        
        
        // wrap_adjust to rknp_xx
        wire                    wad2rknp_xx_head;
        wire                    wad2rknp_xx_tail;
        wire                    wad2rknp_xx_valid;
        wire                    rknp_xx2wad_ready;
        wire [RSP_FLIT_WITH-1:0]wad2rknp_xx_data;

        // rknp_xx to wrap_align to req_order 
        assign rknp_xx2wa_head   = rknp_rxreq_head;
        assign rknp_xx2wa_tail   = rknp_rxreq_tail;
        assign rknp_xx2wa_valid  = rknp_rxreq_valid;
        assign rknp_xx2wa_data   = rknp_rxreq_data;
        assign rknp_rxreq_ready  = wa2rknp_xx_ready;

        assign rknp_xx2reqo_head = wa2reqo_head;  
        assign rknp_xx2reqo_tail = wa2reqo_tail;  
        assign rknp_xx2reqo_valid= wa2reqo_valid; 
        assign rknp_xx2reqo_data = wa2reqo_data; 
        assign reqo2wa_ready     = reqo2rknp_xx_ready;
        
        wrap_align #(
             .REQ_HEAD_LEN_OFFSET    (REQ_HEAD_LEN_OFFSET   )
            ,.ADDR_WITH              (ADDR_WITH             )
            ,.REQ_OPC_OFFSET         (REQ_OPC_OFFSET        )
            ,.REQ_STATUS_OFFSET      (REQ_STATUS_OFFSET     )
            ,.REQ_LEN_OFFSET         (REQ_LEN_OFFSET        )
            ,.REQ_ADDR_OFFSET        (REQ_ADDR_OFFSET       )
            ,.REQ_USER_OFFSET        (REQ_USER_OFFSET       )
            ,.NBYTEPERWORD           (NBYTEPERWORD          )
            ,.REQ_FLIT_WITH          (REQ_FLIT_WITH         )
            ,.RWRAP_CNT_MAX          (RWRAP_CNT_MAX         )
            ,.DLY                    (DLY                   )
        ) U_WRAP_ALIGN (
             .clk                    (clk                   )
            ,.resetn                 (resetn                )
            ,.rknp_xx2wa_head        (rknp_xx2wa_head       )
            ,.rknp_xx2wa_tail        (rknp_xx2wa_tail       )
            ,.rknp_xx2wa_valid       (rknp_xx2wa_valid      )
            ,.rknp_xx2wa_data        (rknp_xx2wa_data       )
            ,.wa2rknp_xx_ready       (wa2rknp_xx_ready      )
            ,.wa2reqo_head           (wa2reqo_head          )
            ,.wa2reqo_tail           (wa2reqo_tail          )
            ,.wa2reqo_valid          (wa2reqo_valid         )
            ,.reqo2wa_ready          (reqo2wa_ready         )
            ,.wa2reqo_data           (wa2reqo_data          )
            ,.wa2reqo_offset_addr    (wa2reqo_offset_addr   )
            ,.rwrap_rsp_fin          (rwrap_rsp_fin         )
        );

        // rsp_order to wrap_adjust to rknp_xx
        assign rspo2wad_head  = rspo2rknp_xx_head;
        assign rspo2wad_tail  = rspo2rknp_xx_tail;
        assign rspo2wad_valid = rspo2rknp_xx_valid;
        assign rspo2wad_data  = rspo2rknp_xx_data;

        assign rknp_txrsp_head  = wad2rknp_xx_head;
        assign rknp_txrsp_tail  = wad2rknp_xx_tail;
        assign rknp_txrsp_valid = wad2rknp_xx_valid;
        assign rknp_txrsp_data  = wad2rknp_xx_data;
        assign rknp_xx2wad_ready = rknp_txrsp_ready;

        assign rknp_xx2rspo_ready = wad2rspo_ready;

        wrap_adjust #(
             .RSP_FLIT_WITH          (RSP_FLIT_WITH         )
            ,.NBYTEPERWORD           (NBYTEPERWORD          )
            ,.USER_WITH              (USER_WITH             )
            ,.ADDR_WITH              (ADDR_WITH             )
            ,.AXID_WITH              (AXID_WITH             )
            ,.RWRAP_CNT_MAX          (RWRAP_CNT_MAX         )
            ,.DLY                    (DLY                   )
        ) U_WRAP_ADJUST (
             .clk                    (clk                   )
            ,.resetn                 (resetn                )
            ,.rspo2wad_head          (rspo2wad_head         )
            ,.rspo2wad_tail          (rspo2wad_tail         )
            ,.rspo2wad_valid         (rspo2wad_valid        )
            ,.wad2rspo_ready         (wad2rspo_ready        )
            ,.rspo2wad_data          (rspo2wad_data         )
            ,.rspo2wad_offset_addr   (rspo2wad_offset_addr  )
            ,.rspo2wad_axid          (rspo2wad_axid         )
            ,.wad2rknp_xx_head       (wad2rknp_xx_head      )
            ,.wad2rknp_xx_tail       (wad2rknp_xx_tail      )
            ,.wad2rknp_xx_valid      (wad2rknp_xx_valid     )
            ,.rknp_xx2wad_ready      (rknp_xx2wad_ready     )
            ,.wad2rknp_xx_data       (wad2rknp_xx_data      )
            ,.rwrap_rsp_fin          (rwrap_rsp_fin         )
        );
    end
endgenerate

req_order #(
     .REQ_FLIT_WITH             (REQ_FLIT_WITH             )      
    ,.URGE_WITH                 (URGE_WITH                 )         
    ,.SUBR_WITH                 (SUBR_WITH                 )                
    ,.IID_WITH                  (IID_WITH                  )               
    ,.TID_WITH                  (TID_WITH                  )               
    ,.ADDR_WITH                 (ADDR_WITH                 )               
    ,.AXID_WITH                 (AXID_WITH                 )                
    ,.ORDKEY_WITH               (ORDKEY_WITH               )                  
    ,.LEN_WITH                  (LEN_WITH                  )              
    ,.USER_WITH                 (USER_WITH                 )              
    ,.NBYTEPERWORD              (NBYTEPERWORD              )                    
    ,.TAG_CNT_WITH              (TAG_CNT_WITH              )                 
       
    ,.REQ_SUBR_OFFSET           (REQ_SUBR_OFFSET           )                 
    ,.REQ_IID_OFFSET            (REQ_IID_OFFSET            )              
    ,.REQ_TID_OFFSET            (REQ_TID_OFFSET            )                       
    ,.REQ_ORDKEY_OFFSET         (REQ_ORDKEY_OFFSET         )                    
    ,.REQ_OPC_OFFSET            (REQ_OPC_OFFSET            )                     
    ,.REQ_STATUS_OFFSET         (REQ_STATUS_OFFSET         )                       
    ,.REQ_LEN_OFFSET            (REQ_LEN_OFFSET            )                    
    ,.REQ_ADDR_OFFSET           (REQ_ADDR_OFFSET           )                     
    ,.REQ_USER_OFFSET           (REQ_USER_OFFSET           )   
    ,.REQ_ERRC_OFFSET           (REQ_ERRC_OFFSET           )                
    ,.REQ_HEAD_LEN_OFFSET       (REQ_HEAD_LEN_OFFSET       )                  
       
    ,.HEAD_BUFF_DEEP            (HEAD_BUFF_DEEP            )                  
       
    ,.ADDR_BLOCK_SIZE           (ADDR_BLOCK_SIZE           )                    
    ,.ADDR_BP_TYPE              (ADDR_BP_TYPE              )    // 0:无同地址反压  1:写后读/写后写同地址反压   2:写后读/写后写/读后写同地址反压
    ,.EARLY_RSP_MODE            (EARLY_RSP_MODE            )
    ,.DLY                       (DLY                       )
) U_REQ_ORDER (       
     .clk                       (clk                       )
    ,.resetn                    (resetn                    )
    // The interface signals of rknp_xx/wrap_align
    ,.rknp_xx2reqo_head         (rknp_xx2reqo_head         )            
    ,.rknp_xx2reqo_tail         (rknp_xx2reqo_tail         )  
    ,.rknp_xx2reqo_valid        (rknp_xx2reqo_valid        )  
    ,.rknp_xx2reqo_data         (rknp_xx2reqo_data         )     
    ,.reqo2rknp_xx_ready        (reqo2rknp_xx_ready        )     
    // The interface signals of req channel of rsp_order 
    ,.reqo2rspo_head            (reqo2rspo_head            )
    ,.reqo2rspo_tail            (reqo2rspo_tail            )
    ,.reqo2rspo_valid           (reqo2rspo_valid           )  
    ,.rspo2reqo_ready           (rspo2reqo_ready           )   
    ,.reqo2rspo_urg             (reqo2rspo_urg             )     
    ,.reqo2rspo_subr            (reqo2rspo_subr            )     
    ,.reqo2rspo_addr            (reqo2rspo_addr            )   
    ,.reqo2rspo_axid            (reqo2rspo_axid            )   
    ,.reqo2rspo_opc             (reqo2rspo_opc             ) 
    ,.reqo2rspo_errcode         (reqo2rspo_errcode         )
    ,.reqo2rspo_status          (reqo2rspo_status          )
    ,.reqo2rspo_len             (reqo2rspo_len             )      
    ,.reqo2rspo_user            (reqo2rspo_user            ) 
    ,.reqo2rspo_data            (reqo2rspo_data            )  
    ,.reqo2rspo_tag_cnt         (reqo2rspo_tag_cnt         )     
    ,.fir_req_flag              (fir_req_flag              )   
       
    ,.reqo2rspo_tag_name        (reqo2rspo_tag_name        )
    // The interface signals of wrap_align
    ,.wa2reqo_offset_addr       (wa2reqo_offset_addr       )     //未使用wrap_align功能
    // The interface signals of rsp channel of rsp_order 
    ,.reqo2rspo_rsp_urg         (reqo2rspo_rsp_urg         )        
    ,.reqo2rspo_rsp_addr        (reqo2rspo_rsp_addr        )      
    ,.reqo2rspo_rsp_ordkey      (reqo2rspo_rsp_ordkey      )      
    ,.reqo2rspo_rsp_len         (reqo2rspo_rsp_len         )         
    ,.reqo2rspo_rsp_user        (reqo2rspo_rsp_user        )         
    ,.reqo2rspo_rsp_iid         (reqo2rspo_rsp_iid         )         
    ,.reqo2rspo_rsp_tid         (reqo2rspo_rsp_tid         )      
    ,.reqo2rspo_rsp_status      (reqo2rspo_rsp_status      )      
    ,.reqo2rspo_rsp_offset_addr (reqo2rspo_rsp_offset_addr )    
    ,.rspo2reqo_head_index      (rspo2reqo_head_index      )         
    ,.rspo2reqo_rhead_en        (rspo2reqo_rhead_en        )         
    ,.rspo2reqo_rsp_valid       (rspo2reqo_rsp_valid       )            
    ,.del_head_en               (del_head_en               )       
    ,.rspo2reqo_timout          (rspo2reqo_timout          )       
    ,.reqo2rspo_timout          (reqo2rspo_timout          )
    // The interface signals of watchdog       
    ,.reqo2wd_axid              (reqo2wd_axid              )          
    ,.reqo2wd_opc               (reqo2wd_opc               )         
    ,.reqo2wd_tag_cnt           (reqo2wd_tag_cnt           )         
    ,.reqo2wd_timon_en          (reqo2wd_timon_en          )        
    ,.timer_interrupt           (timer_interrupt           )
    ,.reqo2wd_timout_table      (reqo2wd_timout_table      )
);






addr_map #(
     .URGE_WITH        (URGE_WITH       )    
    ,.SUBR_WITH        (SUBR_WITH       )    
    ,.ADDR_WITH        (ADDR_WITH       )    
    ,.AXID_WITH        (AXID_WITH       )    
    ,.LEN_WITH         (LEN_WITH        )     
    ,.USER_WITH        (USER_WITH       )    
    ,.NBYTEPERWORD     (NBYTEPERWORD    ) 
    ,.AADDR_WITH       (AADDR_WITH      )   
    ,.AQOS_WITH        (AQOS_WITH       )    
) U_ADDR_MAP (
// The interface signals of rsp_order
     .rspo2am_head     (rspo2am_head    )                   
    ,.rspo2am_tail     (rspo2am_tail    )                    
    ,.rspo2am_valid    (rspo2am_valid   )             
    ,.am2rspo_ready    (am2rspo_ready   )               
    ,.rspo2am_urg      (rspo2am_urg     )               
    ,.rspo2am_subr     (rspo2am_subr    )           
    ,.rspo2am_addr     (rspo2am_addr    )             
    ,.rspo2am_axid     (rspo2am_axid    )             
    ,.rspo2am_opc      (rspo2am_opc     )            
    ,.rspo2am_len      (rspo2am_len     )            
    ,.rspo2am_user     (rspo2am_user    )             
    ,.rspo2am_data     (rspo2am_data    )             

// The interface signals of rreq_trans
    ,.am2rreqt_head    (am2rreqt_head   )              
    ,.am2rreqt_tail    (am2rreqt_tail   )              
    ,.am2rreqt_valid   (am2rreqt_valid  )               
    ,.rreqt2am_ready   (rreqt2am_ready  )               
    ,.am2rreqt_araddr  (am2rreqt_araddr )                
    ,.am2rreqt_axid    (am2rreqt_axid   )              
    ,.am2rreqt_opc     (am2rreqt_opc    )             
    ,.am2rreqt_arlen   (am2rreqt_arlen  )               
    ,.am2rreqt_user    (am2rreqt_user   )              
    ,.am2rreqt_arqos   (am2rreqt_arqos  )               

// The interface signals of wreq_trans
    ,.am2wreqt_head    (am2wreqt_head   )              
    ,.am2wreqt_tail    (am2wreqt_tail   )              
    ,.am2wreqt_valid   (am2wreqt_valid  )               
    ,.wreqt2am_ready   (wreqt2am_ready  )               
    ,.am2wreqt_awaddr  (am2wreqt_awaddr )                
    ,.am2wreqt_axid    (am2wreqt_axid   )              
    ,.am2wreqt_opc     (am2wreqt_opc    )             
    ,.am2wreqt_awlen   (am2wreqt_awlen  )               
    ,.am2wreqt_user    (am2wreqt_user   )              
    ,.am2wreqt_awqos   (am2wreqt_awqos  )               
    ,.am2wreqt_data    (am2wreqt_data   )              
);

rreq_trans#(

     .URGE_WITH        (URGE_WITH       )             
    ,.SUBR_WITH        (SUBR_WITH       )             
    ,.AXID_WITH        (AXID_WITH       )             
    ,.LEN_WITH         (LEN_WITH        )            
    ,.USER_WITH        (USER_WITH       )             
    ,.NBYTEPERWORD     (NBYTEPERWORD    )                

    ,.AADDR_WITH       (AADDR_WITH      )              
    ,.AUSER_WITH       (AUSER_WITH      )              
    ,.AQOS_WITH        (AQOS_WITH       )    
    ,.DLY              (DLY             )         
) U_RREQ_TRANS (

     .clk              (clk             )                     
    ,.resetn           (resetn          )                        
    // The interface signals of addr_map
    ,.am2rreqt_head    (am2rreqt_head   )                               
    ,.am2rreqt_tail    (am2rreqt_tail   )                               
    ,.am2rreqt_valid   (am2rreqt_valid  )                                
    ,.rreqt2am_ready   (rreqt2am_ready  )                                
    ,.am2rreqt_araddr  (am2rreqt_araddr )                                 
    ,.am2rreqt_axid    (am2rreqt_axid   )                               
    ,.am2rreqt_opc     (am2rreqt_opc    )                              
    ,.am2rreqt_arlen   (am2rreqt_arlen  )                                
    ,.am2rreqt_user    (am2rreqt_user   )                               
    ,.am2rreqt_arqos   (am2rreqt_arqos  )                                

    // The interface signals of AXI AR channel
    ,.axi_m_arvalid    (axi_m_arvalid   )                               
    ,.axi_m_arready    (axi_m_arready   )                               
    ,.axi_m_arid       (axi_m_arid      )                            
    ,.axi_m_araddr     (axi_m_araddr    )                              
    ,.axi_m_arlen      (axi_m_arlen     )                             
    ,.axi_m_arsize     (axi_m_arsize    )                              
    ,.axi_m_arburst    (axi_m_arburst   )                               
    ,.axi_m_arlock     (axi_m_arlock    )                              
    ,.axi_m_arcache    (axi_m_arcache   )                               
    ,.axi_m_arprot     (axi_m_arprot    )                              
    ,.axi_m_arqos      (axi_m_arqos     )                             
    ,.axi_m_aruser     (axi_m_aruser    )                              
    
);


wreq_trans#(

     .URGE_WITH        (URGE_WITH       )                        
    ,.SUBR_WITH        (SUBR_WITH       )                       
    ,.AXID_WITH        (AXID_WITH       )                       
    ,.LEN_WITH         (LEN_WITH        )                      
    ,.USER_WITH        (USER_WITH       )                       
    ,.NBYTEPERWORD     (NBYTEPERWORD    )                          

    ,.AADDR_WITH       (AADDR_WITH      )                        
    ,.AUSER_WITH       (AUSER_WITH      )                        
    ,.AQOS_WITH        (AQOS_WITH       )    
    ,.DLY              (DLY             )                   
) U_WREQ_TRANS (

     .clk              (clk             )                                 
    ,.resetn           (resetn          )                                    
    // The interface signals of addr_map
    ,.am2wreqt_head    (am2wreqt_head   )                                           
    ,.am2wreqt_tail    (am2wreqt_tail   )                                           
    ,.am2wreqt_valid   (am2wreqt_valid  )                                                
    ,.wreqt2am_ready   (wreqt2am_ready  )                                            
    ,.am2wreqt_awaddr  (am2wreqt_awaddr )                                             
    ,.am2wreqt_axid    (am2wreqt_axid   )                                           
    ,.am2wreqt_opc     (am2wreqt_opc    )                                          
    ,.am2wreqt_awlen   (am2wreqt_awlen  )                                            
    ,.am2wreqt_user    (am2wreqt_user   )                                           
    ,.am2wreqt_data    (am2wreqt_data   )                                           
    ,.am2wreqt_awqos   (am2wreqt_awqos  )                                            

    // The interface signals of AXI AW channel
    ,.axi_m_awvalid    (axi_m_awvalid   )                                           
    ,.axi_m_awready    (axi_m_awready   )                                           
    ,.axi_m_awid       (axi_m_awid      )                                        
    ,.axi_m_awaddr     (axi_m_awaddr    )                                          
    ,.axi_m_awlen      (axi_m_awlen     )                                         
    ,.axi_m_awsize     (axi_m_awsize    )                                          
    ,.axi_m_awburst    (axi_m_awburst   )                                           
    ,.axi_m_awlock     (axi_m_awlock    )                                          
    ,.axi_m_awcache    (axi_m_awcache   )                                             
    ,.axi_m_awprot     (axi_m_awprot    )                                          
    ,.axi_m_awqos      (axi_m_awqos     )                                         
    ,.axi_m_awuser     (axi_m_awuser    )                                          
    
    // The interface signals of AXI W channel
    ,.axi_m_wvalid     (axi_m_wvalid    )                                          
    ,.axi_m_wready     (axi_m_wready    )                                          
    ,.axi_m_wlast      (axi_m_wlast     )                                         
    ,.axi_m_wid        (axi_m_wid       )                                       
    ,.axi_m_wdata      (axi_m_wdata     )                                         
    ,.axi_m_wstrb      (axi_m_wstrb     )                                         
);





watchdog #(
     .AXID_WITH          (AXID_WITH             )
    ,.TAG_CNT_WITH       (TAG_CNT_WITH          )
    ,.TIMOUT_VALUE       (TIMOUT_VALUE          )
    ,.TIMOUT_TABLE_DEEP  (TIMOUT_TABLE_DEEP     )
    ,.DLY                (DLY                   )
) U_WATCHDOG (
     .clk                (clk                   )
    ,.resetn             (resetn                )
    ,.reqo2wd_axid       (reqo2wd_axid          )
    ,.reqo2wd_opc        (reqo2wd_opc           )
    ,.reqo2wd_tag_cnt    (reqo2wd_tag_cnt       )
    ,.reqo2wd_timon_en   (reqo2wd_timon_en      )
    ,.timer_interrupt    (timer_interrupt       )
    ,.reqo2wd_timout_table(reqo2wd_timout_table )
    ,.rspo2wd_axid       (rspo2wd_axid          )
    ,.rspo2wd_opc        (rspo2wd_opc           )
    ,.rspo2wd_tag_cnt    (rspo2wd_tag_cnt       )
    ,.rspo2wd_timoff_en  (rspo2wd_timoff_en     )
    ,.timout_fifo_rden   (timout_fifo_rden      )
    ,.wd2rspo_axid       (wd2rspo_axid          )
    ,.wd2rspo_opc        (wd2rspo_opc           )
    ,.timout_fifo_empty  (timout_fifo_empty     )
);


generate
    if(EARLY_RSP_MODE == 0) begin
        rsp_order #(
             .URGE_WITH                 (URGE_WITH              )       
            ,.SUBR_WITH                 (SUBR_WITH              )                     
            ,.IID_WITH                  (IID_WITH               )          
            ,.TID_WITH                  (TID_WITH               )        
            ,.ADDR_WITH                 (ADDR_WITH              )       
            ,.AXID_WITH                 (AXID_WITH              )       
            ,.ORDKEY_WITH               (ORDKEY_WITH            )     
            ,.LEN_WITH                  (LEN_WITH               )        
            ,.USER_WITH                 (USER_WITH              )       
            ,.RSP_IID_OFFSET            (RSP_IID_OFFSET         )     
            ,.RSP_TID_OFFSET            (RSP_TID_OFFSET         )      
            ,.RSP_ORDKEY_OFFSET         (RSP_ORDKEY_OFFSET      )             
            ,.RSP_OPC_OFFSET            (RSP_OPC_OFFSET         )          
            ,.RSP_STATUS_OFFSET         (RSP_STATUS_OFFSET      )            
            ,.RSP_ADDR_OFFSET           (RSP_ADDR_OFFSET        )           
            ,.RSP_USER_OFFSET           (RSP_USER_OFFSET        )           
            ,.RSP_ERRC_OFFSET           (RSP_ERRC_OFFSET        )           
            ,.NBYTEPERWORD              (NBYTEPERWORD           )        
            ,.TAG_CNT_WITH              (TAG_CNT_WITH           )        
            ,.SPEC_REQ_BUFF_DEEP        (SPEC_REQ_BUFF_DEEP     )             
            ,.ADDR_BLOCK_SIZE           (ADDR_BLOCK_SIZE        )           
            ,.ADDR_BP_TYPE              (ADDR_BP_TYPE           ) // 0:无同地址反压  1:写后读/写后写同地址反压   2:写后读/写后写/读后写同地址反压
            ,.AUSER_WITH                (AUSER_WITH             )          
            ,.EARLY_RSP_MODE            (EARLY_RSP_MODE         ) // 0：关闭early response模式    1：开启early response模式
            ,.DLY                       (DLY                    )
        ) U_RSP_ORDER (
             .clk                       (clk                    )                    
            ,.resetn                    (resetn                 )                       
            // The interface signals of req channel of req_order 
            ,.reqo2rspo_head            (reqo2rspo_head         )                               
            ,.reqo2rspo_tail            (reqo2rspo_tail         )                               
            ,.reqo2rspo_valid           (reqo2rspo_valid        )                                
            ,.rspo2reqo_ready           (rspo2reqo_ready        )                                
            ,.reqo2rspo_urg             (reqo2rspo_urg          )                                 
            ,.reqo2rspo_subr            (reqo2rspo_subr         )                                
            ,.reqo2rspo_addr            (reqo2rspo_addr         )                               
            ,.reqo2rspo_axid            (reqo2rspo_axid         )                               
            ,.reqo2rspo_opc             (reqo2rspo_opc          )                              
            ,.reqo2rspo_errcode         (reqo2rspo_errcode      )                                  
            ,.reqo2rspo_status          (reqo2rspo_status       )                                 
            ,.reqo2rspo_len             (reqo2rspo_len          )                                 
            ,.reqo2rspo_user            (reqo2rspo_user         )                               
            ,.reqo2rspo_data            (reqo2rspo_data         )                               
            ,.reqo2rspo_tag_cnt         (reqo2rspo_tag_cnt      )                                  
            ,.fir_req_flag              (fir_req_flag           )                             

            ,.reqo2rspo_tag_name        (reqo2rspo_tag_name     )
            // The interface signals of addr_map
            ,.rspo2am_head              (rspo2am_head           )                             
            ,.rspo2am_tail              (rspo2am_tail           )                             
            ,.rspo2am_valid             (rspo2am_valid          )                              
            ,.am2rspo_ready             (am2rspo_ready          )                              
            ,.rspo2am_urg               (rspo2am_urg            )                            
            ,.rspo2am_subr              (rspo2am_subr           )                             
            ,.rspo2am_addr              (rspo2am_addr           )                             
            ,.rspo2am_axid              (rspo2am_axid           )                             
            ,.rspo2am_opc               (rspo2am_opc            )                            
            ,.rspo2am_len               (rspo2am_len            )                            
            ,.rspo2am_user              (rspo2am_user           )                             
            ,.rspo2am_data              (rspo2am_data           )                             

            // The interface signals of rsp_trans
            ,.rspt2rspo_head            (rspt2rspo_head         )                               
            ,.rspt2rspo_tail            (rspt2rspo_tail         )                               
            ,.rspt2rspo_valid           (rspt2rspo_valid        )                                
            ,.rspo2rspt_ready           (rspo2rspt_ready        )                                
            ,.rspt2rspo_axid            (rspt2rspo_axid         )                               
            ,.rspt2rspo_auser           (rspt2rspo_auser        )                               
            ,.rspt2rspo_opc             (rspt2rspo_opc          )                              
            ,.rspt2rspo_errcode         (rspt2rspo_errcode      )                                  
            ,.rspt2rspo_data            (rspt2rspo_data         )       
            ,.rspt2rspo_lw              (rspt2rspo_lw           )                        
            // The interface signals of req channel of req_order 
            ,.reqo2rspo_rsp_urg         (reqo2rspo_rsp_urg      )                                     
            ,.reqo2rspo_rsp_addr        (reqo2rspo_rsp_addr     )                                   
            ,.reqo2rspo_rsp_ordkey      (reqo2rspo_rsp_ordkey   )                                     
            ,.reqo2rspo_rsp_len         (reqo2rspo_rsp_len      )                                     
            ,.reqo2rspo_rsp_user        (reqo2rspo_rsp_user     )                                   
            ,.reqo2rspo_rsp_iid         (reqo2rspo_rsp_iid      )                                  
            ,.reqo2rspo_rsp_tid         (reqo2rspo_rsp_tid      )                                  
            ,.reqo2rspo_rsp_status      (reqo2rspo_rsp_status   )     
            ,.reqo2rspo_rsp_offset_addr (reqo2rspo_rsp_offset_addr)                                
            ,.rspo2reqo_head_index      (rspo2reqo_head_index   )                                     
            ,.rspo2reqo_rhead_en        (rspo2reqo_rhead_en     )                                   
            ,.rspo2reqo_rsp_valid       (rspo2reqo_rsp_valid    )                                    
            ,.del_head_en               (del_head_en            )                            
            ,.rspo2reqo_timout          (rspo2reqo_timout       )                                 
            ,.reqo2rspo_timout          (reqo2rspo_timout       )     
            // The interface signals of rsp channel of rknp_xx/wrap_adjust
            ,.rspo2rknp_xx_head         (rspo2rknp_xx_head      )
            ,.rspo2rknp_xx_tail         (rspo2rknp_xx_tail      )
            ,.rspo2rknp_xx_valid        (rspo2rknp_xx_valid     )
            ,.rknp_xx2rspo_ready        (rknp_xx2rspo_ready     )
            ,.rspo2rknp_xx_data         (rspo2rknp_xx_data      )
            // The interface signals of wrap_adjust
            ,.rspo2wad_offset_addr      (rspo2wad_offset_addr   )
            ,.rspo2wad_axid             (rspo2wad_axid          )
            // The interface signals of watchdog
            ,.wd2rspo_axid              (wd2rspo_axid           )
            ,.wd2rspo_opc               (wd2rspo_opc            )
            ,.timout_fifo_empty         (timout_fifo_empty      )
            ,.timout_fifo_rden          (timout_fifo_rden       )
            ,.rspo2wd_axid              (rspo2wd_axid           )
            ,.rspo2wd_opc               (rspo2wd_opc            )
            ,.rspo2wd_tag_cnt           (rspo2wd_tag_cnt        )
            ,.rspo2wd_timoff_en         (rspo2wd_timoff_en      )
            // The interface signals of ely_rsp_detect
            ,.rspo2erd_head             (                       )
            ,.rspo2erd_axid             (                       )
            ,.rspo2erd_opc              (                       )
            ,.rspo2erd_user             (                       )
            ,.erd2rspo_tag_cnt          (0                      )
            ,.buff_rsp_flag             (0                      )
            ,.rspo2erd_tag_cnt          (                       )
        );

        rsp_trans #(
             .AXID_WITH                 (AXID_WITH              )
            ,.USER_WITH                 (USER_WITH              )
            ,.NBYTEPERWORD              (NBYTEPERWORD           )
            ,.AUSER_WITH                (AUSER_WITH             )
            ,.DLY                       (DLY                    )
        ) U_RSP_TRANS (                     
             .clk                       (clk                    )
            ,.resetn                    (resetn                 ) 
            ,.axi_m_rvalid              (axi_m_rvalid           )
            ,.axi_m_rready              (axi_m_rready           )
            ,.axi_m_rid                 (axi_m_rid              )
            ,.axi_m_rdata               (axi_m_rdata            )
            ,.axi_m_rresp               (axi_m_rresp            )
            ,.axi_m_ruser               (axi_m_ruser            )
            ,.axi_m_rlast               (axi_m_rlast            )
            ,.axi_m_bvalid              (axi_m_bvalid           )
            ,.axi_m_bready              (axi_m_bready           )
            ,.axi_m_bid                 (axi_m_bid              )
            ,.axi_m_bresp               (axi_m_bresp            )
            ,.axi_m_buser               (axi_m_buser            )

            ,.rspt2rspo_head            (rspt2rspo_head         )
            ,.rspt2rspo_tail            (rspt2rspo_tail         )
            ,.rspt2rspo_valid           (rspt2rspo_valid        )
            ,.rspo2rspt_ready           (rspo2rspt_ready        )
            ,.rspt2rspo_axid            (rspt2rspo_axid         )
            ,.rspt2rspo_auser           (rspt2rspo_auser        )
            ,.rspt2rspo_opc             (rspt2rspo_opc          )
            ,.rspt2rspo_errcode         (rspt2rspo_errcode      )
            ,.rspt2rspo_status          (rspt2rspo_status       )
            ,.rspt2rspo_data            (rspt2rspo_data         )       
            ,.rspt2rspo_lw              (rspt2rspo_lw           )
);

    end else begin

        // rsp_order to ely_rsp_detect
        wire                    rspo2erd_head   ;
        wire [AXID_WITH-1:0]    rspo2erd_axid   ;
        wire [3:0]              rspo2erd_opc    ;
        wire [USER_WITH-1:0]    rspo2erd_user   ;
        wire [TAG_CNT_WITH-1:0] rspo2erd_tag_cnt;

        // rsp_trans to ely_rsp_detect
        wire                    rspt2erd_head   ;
        wire                    rspt2erd_tail   ;
        wire                    rspt2erd_valid  ;
        wire                    erd2rspt_ready  ;
        wire [AXID_WITH-1:0]    rspt2erd_axid   ;
        wire [AUSER_WITH:0]     rspt2erd_auser  ;
        wire [1:0]              rspt2erd_opc    ;
        wire [2:0]              rspt2erd_errcode;
        wire [1:0]              rspt2erd_status ;
        wire [9*NBYTEPERWORD:0] rspt2erd_data   ;
        wire                    rspt2erd_lw     ;

        // ely_rsp_detect to rsp_order
        wire                    erd2rspo_head   ;
        wire                    erd2rspo_tail   ;
        wire                    erd2rspo_valid  ;
        wire                    rspo2erd_ready  ;   // 注意：这是下游给模块的ready，测试平台作为下游驱动这个信号
        wire [AXID_WITH-1:0]    erd2rspo_axid   ;
        wire [AUSER_WITH:0]     erd2rspo_auser  ;
        wire [1:0]              erd2rspo_opc    ;
        wire [2:0]              erd2rspo_errcode;
        wire [1:0]              erd2rspo_status ;
        wire [9*NBYTEPERWORD:0] erd2rspo_data   ;
        wire                    erd2rspo_lw     ;
        wire [TAG_CNT_WITH-1:0] erd2rspo_tag_cnt;
        wire                    buff_rsp_flag   ;


        assign rspt2erd_head   = rspt2rspo_head     ;
        assign rspt2erd_tail   = rspt2rspo_tail     ;
        assign rspt2erd_valid  = rspt2rspo_valid    ;
        assign rspo2rspt_ready = erd2rspt_ready     ;
        assign rspt2erd_axid   = rspt2rspo_axid     ;
        assign rspt2erd_auser  = rspt2rspo_auser    ;
        assign rspt2erd_opc    = rspt2rspo_opc      ;
        assign rspt2erd_errcode= rspt2rspo_errcode  ;
        assign rspt2erd_status = rspt2rspo_status   ;
        assign rspt2erd_data   = rspt2rspo_data     ;
        assign rspt2erd_lw     = rspt2rspo_lw       ;

        
        rsp_trans #(
             .AXID_WITH        (AXID_WITH       )
            ,.USER_WITH        (USER_WITH       )
            ,.NBYTEPERWORD     (NBYTEPERWORD    )
            ,.AUSER_WITH       (AUSER_WITH      )
            ,.DLY              (DLY             )
        ) U_RSP_TRANS ( 
             .clk              (clk             )
            ,.resetn           (resetn          ) 
            ,.axi_m_rvalid     (axi_m_rvalid    )
            ,.axi_m_rready     (axi_m_rready    )
            ,.axi_m_rid        (axi_m_rid       )
            ,.axi_m_rdata      (axi_m_rdata     )
            ,.axi_m_rresp      (axi_m_rresp     )
            ,.axi_m_ruser      (axi_m_ruser     )
            ,.axi_m_rlast      (axi_m_rlast     )
            ,.axi_m_bvalid     (axi_m_bvalid    )
            ,.axi_m_bready     (axi_m_bready    )
            ,.axi_m_bid        (axi_m_bid       )
            ,.axi_m_bresp      (axi_m_bresp     )
            ,.axi_m_buser      (axi_m_buser     )

            ,.rspt2rspo_head   (rspt2rspo_head   )
            ,.rspt2rspo_tail   (rspt2rspo_tail   )
            ,.rspt2rspo_valid  (rspt2rspo_valid  )
            ,.rspo2rspt_ready  (rspo2rspt_ready  )
            ,.rspt2rspo_axid   (rspt2rspo_axid   )
            ,.rspt2rspo_auser  (rspt2rspo_auser  )
            ,.rspt2rspo_opc    (rspt2rspo_opc    )
            ,.rspt2rspo_errcode(rspt2rspo_errcode)
            ,.rspt2rspo_status (rspt2rspo_status )
            ,.rspt2rspo_data   (rspt2rspo_data   )  
            ,.rspt2rspo_lw     (rspt2rspo_lw     )     
        );


        ely_rsp_detect #(
             .URGE_WITH         (URGE_WITH          )
            ,.SUBR_WITH         (SUBR_WITH          )
            ,.ADDR_WITH         (ADDR_WITH          )
            ,.AXID_WITH         (AXID_WITH          )
            ,.LEN_WITH          (LEN_WITH           )
            ,.USER_WITH         (USER_WITH          )
            ,.NBYTEPERWORD      (NBYTEPERWORD       )
            ,.ELYRSP_TABLE_DEEP (ELYRSP_TABLE_DEEP  )
            ,.AUSER_WITH        (AUSER_WITH         )
            ,.TAG_CNT_WITH      (TAG_CNT_WITH       )
            ,.DLY               (DLY                )
        ) U_ELY_RSP_DETECT (
             .clk               (clk                )
            ,.resetn            (resetn             )
            ,.rspo2erd_head     (rspo2erd_head      )
            ,.rspo2erd_axid     (rspo2erd_axid      )
            ,.rspo2erd_opc      (rspo2erd_opc       )
            ,.rspo2erd_user     (rspo2erd_user      )
            ,.rspo2erd_tag_cnt  (rspo2erd_tag_cnt   )
            ,.rspt2erd_head     (rspt2erd_head      )
            ,.rspt2erd_tail     (rspt2erd_tail      )
            ,.rspt2erd_valid    (rspt2erd_valid     )
            ,.erd2rspt_ready    (erd2rspt_ready     )
            ,.rspt2erd_axid     (rspt2erd_axid      )
            ,.rspt2erd_auser    (rspt2erd_auser     )
            ,.rspt2erd_opc      (rspt2erd_opc       )
            ,.rspt2erd_errcode  (rspt2erd_errcode   )
            ,.rspt2erd_status   (rspt2erd_status    )
            ,.rspt2erd_data     (rspt2erd_data      )
            ,.rspt2erd_lw       (rspt2erd_lw        )
            ,.erd2rspo_head     (erd2rspo_head      )
            ,.erd2rspo_tail     (erd2rspo_tail      )
            ,.erd2rspo_valid    (erd2rspo_valid     )
            ,.rspo2erd_ready    (rspo2erd_ready     )
            ,.erd2rspo_axid     (erd2rspo_axid      )
            ,.erd2rspo_auser    (erd2rspo_auser     )
            ,.erd2rspo_opc      (erd2rspo_opc       )
            ,.erd2rspo_errcode  (erd2rspo_errcode   )
            ,.erd2rspo_status   (erd2rspo_status    )
            ,.erd2rspo_data     (erd2rspo_data      )
            ,.erd2rspo_lw       (erd2rspo_lw        )
            ,.buff_rsp_flag     (buff_rsp_flag      )
            ,.erd2rspo_tag_cnt  (erd2rspo_tag_cnt   )
        );
        
        rsp_order #(
             .URGE_WITH                 (URGE_WITH              )       
            ,.SUBR_WITH                 (SUBR_WITH              )                     
            ,.IID_WITH                  (IID_WITH               )          
            ,.TID_WITH                  (TID_WITH               )        
            ,.ADDR_WITH                 (ADDR_WITH              )       
            ,.AXID_WITH                 (AXID_WITH              )       
            ,.ORDKEY_WITH               (ORDKEY_WITH            )     
            ,.LEN_WITH                  (LEN_WITH               )        
            ,.USER_WITH                 (USER_WITH              )       
            ,.RSP_IID_OFFSET            (RSP_IID_OFFSET         )     
            ,.RSP_TID_OFFSET            (RSP_TID_OFFSET         )      
            ,.RSP_ORDKEY_OFFSET         (RSP_ORDKEY_OFFSET      )             
            ,.RSP_OPC_OFFSET            (RSP_OPC_OFFSET         )          
            ,.RSP_STATUS_OFFSET         (RSP_STATUS_OFFSET      )            
            ,.RSP_ADDR_OFFSET           (RSP_ADDR_OFFSET        )           
            ,.RSP_USER_OFFSET           (RSP_USER_OFFSET        )           
            ,.RSP_ERRC_OFFSET           (RSP_ERRC_OFFSET        )           
            ,.NBYTEPERWORD              (NBYTEPERWORD           )        
            ,.TAG_CNT_WITH              (TAG_CNT_WITH           )        
            ,.SPEC_REQ_BUFF_DEEP        (SPEC_REQ_BUFF_DEEP     )             
            ,.ADDR_BLOCK_SIZE           (ADDR_BLOCK_SIZE        )           
            ,.ADDR_BP_TYPE              (ADDR_BP_TYPE           ) // 0:无同地址反压  1:写后读/写后写同地址反压   2:写后读/写后写/读后写同地址反压
            ,.AUSER_WITH                (AUSER_WITH             )          
            ,.EARLY_RSP_MODE            (EARLY_RSP_MODE         ) // 0：关闭early response模式    1：开启early response模式
            ,.DLY                       (DLY                    )
        ) U_RSP_ORDER (
             .clk                       (clk                    )                    
            ,.resetn                    (resetn                 )                       
            // The interface signals of req channel of req_order 
            ,.reqo2rspo_head            (reqo2rspo_head         )                               
            ,.reqo2rspo_tail            (reqo2rspo_tail         )                               
            ,.reqo2rspo_valid           (reqo2rspo_valid        )                                
            ,.rspo2reqo_ready           (rspo2reqo_ready        )                                
            ,.reqo2rspo_urg             (reqo2rspo_urg          )                                 
            ,.reqo2rspo_subr            (reqo2rspo_subr         )                                
            ,.reqo2rspo_addr            (reqo2rspo_addr         )                               
            ,.reqo2rspo_axid            (reqo2rspo_axid         )                               
            ,.reqo2rspo_opc             (reqo2rspo_opc          )                              
            ,.reqo2rspo_errcode         (reqo2rspo_errcode      )                                  
            ,.reqo2rspo_status          (reqo2rspo_status       )      
            ,.reqo2rspo_rsp_offset_addr (reqo2rspo_rsp_offset_addr)                           
            ,.reqo2rspo_len             (reqo2rspo_len          )                                 
            ,.reqo2rspo_user            (reqo2rspo_user         )                               
            ,.reqo2rspo_data            (reqo2rspo_data         )                               
            ,.reqo2rspo_tag_cnt         (reqo2rspo_tag_cnt      )                                  
            ,.fir_req_flag              (fir_req_flag           )                             

            ,.reqo2rspo_tag_name        (reqo2rspo_tag_name     )
            // The interface signals of addr_map
            ,.rspo2am_head              (rspo2am_head           )                             
            ,.rspo2am_tail              (rspo2am_tail           )                             
            ,.rspo2am_valid             (rspo2am_valid          )                              
            ,.am2rspo_ready             (am2rspo_ready          )                              
            ,.rspo2am_urg               (rspo2am_urg            )                            
            ,.rspo2am_subr              (rspo2am_subr           )                             
            ,.rspo2am_addr              (rspo2am_addr           )                             
            ,.rspo2am_axid              (rspo2am_axid           )                             
            ,.rspo2am_opc               (rspo2am_opc            )                            
            ,.rspo2am_len               (rspo2am_len            )                            
            ,.rspo2am_user              (rspo2am_user           )                             
            ,.rspo2am_data              (rspo2am_data           )                             

            // The interface signals of ely_rsp_detect
            ,.rspt2rspo_head            (erd2rspo_head          )                               
            ,.rspt2rspo_tail            (erd2rspo_tail          )                               
            ,.rspt2rspo_valid           (erd2rspo_valid         )                                
            ,.rspo2rspt_ready           (rspo2erd_ready         )                                
            ,.rspt2rspo_axid            (erd2rspo_axid          )                               
            ,.rspt2rspo_auser           (erd2rspo_auser         )                               
            ,.rspt2rspo_opc             (erd2rspo_opc           )                              
            ,.rspt2rspo_errcode         (erd2rspo_errcode       )         
            ,.rspt2rspo_status          (erd2rspo_status        )                         
            ,.rspt2rspo_data            (erd2rspo_data          ) 
            ,.rspt2rspo_lw              (erd2rspo_lw            )                          
            // The interface signals of req channel of req_order 
            ,.reqo2rspo_rsp_urg         (reqo2rspo_rsp_urg      )                                     
            ,.reqo2rspo_rsp_addr        (reqo2rspo_rsp_addr     )                                   
            ,.reqo2rspo_rsp_ordkey      (reqo2rspo_rsp_ordkey   )                                     
            ,.reqo2rspo_rsp_len         (reqo2rspo_rsp_len      )                                     
            ,.reqo2rspo_rsp_user        (reqo2rspo_rsp_user     )                                   
            ,.reqo2rspo_rsp_iid         (reqo2rspo_rsp_iid      )                                  
            ,.reqo2rspo_rsp_tid         (reqo2rspo_rsp_tid      )                                  
            ,.reqo2rspo_rsp_status      (reqo2rspo_rsp_status   )                                     
            ,.rspo2reqo_head_index      (rspo2reqo_head_index   )                                     
            ,.rspo2reqo_rhead_en        (rspo2reqo_rhead_en     )                                   
            ,.rspo2reqo_rsp_valid       (rspo2reqo_rsp_valid    )                                    
            ,.del_head_en               (del_head_en            )                            
            ,.rspo2reqo_timout          (rspo2reqo_timout       )                                 
            ,.reqo2rspo_timout          (reqo2rspo_timout       )     
            // The interface signals of rsp channel of rknp_xx/wrap_adjust
            ,.rspo2rknp_xx_head         (rspo2rknp_xx_head      )
            ,.rspo2rknp_xx_tail         (rspo2rknp_xx_tail      )
            ,.rspo2rknp_xx_valid        (rspo2rknp_xx_valid     )
            ,.rknp_xx2rspo_ready        (rknp_xx2rspo_ready     )
            ,.rspo2rknp_xx_data         (rspo2rknp_xx_data      )
            // The interface signals of wrap_adjust
            ,.rspo2wad_offset_addr      (rspo2wad_offset_addr   )
            ,.rspo2wad_axid             (rspo2wad_axid          )
            // The interface signals of watchdog
            ,.wd2rspo_axid              (wd2rspo_axid           )
            ,.wd2rspo_opc               (wd2rspo_opc            )
            ,.timout_fifo_empty         (timout_fifo_empty      )
            ,.timout_fifo_rden          (timout_fifo_rden       )
            ,.rspo2wd_axid              (rspo2wd_axid           )
            ,.rspo2wd_opc               (rspo2wd_opc            )
            ,.rspo2wd_tag_cnt           (rspo2wd_tag_cnt        )
            ,.rspo2wd_timoff_en         (rspo2wd_timoff_en      )
            // The interface signals of ely_rsp_detect
            
            ,.rspo2erd_head             (rspo2erd_head          )
            ,.rspo2erd_axid             (rspo2erd_axid          )
            ,.rspo2erd_opc              (rspo2erd_opc           )
            ,.rspo2erd_user             (rspo2erd_user          )
            ,.erd2rspo_tag_cnt          (erd2rspo_tag_cnt       )
            ,.buff_rsp_flag             (buff_rsp_flag          )
            ,.rspo2erd_tag_cnt          (rspo2erd_tag_cnt       )
        );


    end
endgenerate








endmodule
