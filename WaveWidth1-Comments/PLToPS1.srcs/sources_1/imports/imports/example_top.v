//*****************************************************************************
// (c) Copyright 2009 - 2013 Xilinx, Inc. All rights reserved.

module example_top #
  (
   parameter BANK_WIDTH            = 3,
                                     // # of memory Bank Address bits.
   parameter COL_WIDTH             = 10,
                                     // # of memory Column Address bits.
   parameter CS_WIDTH              = 1,
                                     // # of unique CS outputs to memory.
   parameter DQ_WIDTH              = 16,
                                     // # of DQ (data)
   parameter ECC_TEST              = "OFF",
   //parameter nBANK_MACHS           = 4,
   parameter RANKS                 = 1,
                                     // # of Ranks.
   parameter ROW_WIDTH             = 15,
                                     // # of memory Row Address bits.
   parameter ADDR_WIDTH            = 29,
                                     // # = RANK_WIDTH + BANK_WIDTH
                                     //     + ROW_WIDTH + COL_WIDTH;
                                     // Chip Select is always tied to low for
                                     // single rank devices

   //***************************************************************************
   // The following parameters are mode register settings
   //***************************************************************************
   parameter BURST_MODE            = "8",
                                     // DDR3 SDRAM:
                                     // Burst Length (Mode Register 0).
                                     // # = "8", "4", "OTF".
                                     // DDR2 SDRAM:
                                     // Burst Length (Mode Register).
                                     // # = "8", "4".  
   //***************************************************************************
   // System clock frequency parameters
   //***************************************************************************
   parameter nCK_PER_CLK           = 4,
                                     // # of memory CKs per fabric CLK                                  
   parameter [2:0]CMD_WRITE        =3'd0,
   parameter [2:0]CMD_READ         =3'd1,
   parameter TEST_DATA_RANGE       =26'd33554432//全地址测试
     //parameter TEST_DATA_RANGE=24'd100//部分测试
   )
  (
/*******************AD*************************/
   input [7:0]                          adc_data,
   input                                clk_250m,
/*******************DDR3***********************/
   // Inouts
   inout [15:0]                         ddr3_dq,
   inout [1:0]                          ddr3_dqs_n,
   inout [1:0]                          ddr3_dqs_p,

   // Outputs
   output [14:0]                        ddr3_addr,
   output [2:0]                         ddr3_ba,
   output                               ddr3_ras_n,
   output                               ddr3_cas_n,
   output                               ddr3_we_n,
   output                               ddr3_reset_n,
   output [0:0]                         ddr3_ck_p,
   output [0:0]                         ddr3_ck_n,
   output [0:0]                         ddr3_cke,   
   output [0:0]                         ddr3_cs_n,  
   output [1:0]                         ddr3_dm,   
   output [0:0]                         ddr3_odt,
   output                               tg_compare_error,
   output                               init_calib_complete,
  
  /**************系统输入*********************/
   input                                clk100m_i,
   // input                                FCLK_CLK0,
   input                                rst_key,

   /**************特征值**************************/
   input                                StartSample1,//开始采样标志
   input                                SendOver,//开始读取新数据
   input  [7:0]                         MonopulseExThreshould,//单脉冲提取的阈值
   input  [7:0]                         MonopulseExHold,//下降沿时小于单脉冲提取的阈值前的点数
   input  [7:0]                         MonopulseMultiThreshould,//下降沿后又出现大于单脉冲提取的阈值，这之间的点数小于这个值
   input  [7:0]                         MonopulseEndHold,
   input  [7:0]                         GentalThreshould,//稳定值
   input  [7:0]                         GentalThreshouldNum,//小于稳定值的数量
   input                                StopOrder,//结束采样标志
   // output [31:0]                        SendToArm_Data,
   output [15:0]                        Front_area,//波前面积
   output [15:0]                        Behind_area,//波后面积
   output [15:0]                        Total_area,//总面积
   output [15:0]                        Front_Width,//半波时长
   output [15:0]                        Behind_Width,
   output [15:0]                        Total_Width,//全波时长
   output [7:0]                         Peak_value,//峰值
   output [23:0]                        Second_moment,//二阶矩
   output [32:0]                        Third_moment,//三阶矩
   output [40:0]                        Fourth_moment,//四阶矩
   output [15:0]                        Monopulse_num,//本次单脉冲的点数
   output [15:0]                        Period_condition,//周期数
   output [31:0]                        MonopulsePosition,//相位
   output                               FeatureExtraction_flag_reg,//特征处理结束标志
   output                               ProcessOver,//25个工频周期处理结束标志
   output [7:0]                         ProcessNum,//第几个轮回（以25个周期为1轮回）
   // output                               Period_flag,
   // output                               SendToArm_begin,
   // output [9:0]                         PulseNum,
   // output [3:0]                         DDR_State,

  /**********Phase**************/
   input                                Signal_50HZ,//工频相位
   output                               sync_led//相位指示灯，1s 1亮            

   // System reset - Default polarity of sys_rst pin is Active Low.
   // System reset polarity will change based on the option 
   // selected in GUI.
   //input                                        sys_rst
   );

//模拟的数据锯齿波，不用了
reg [7:0]               bit_count;
always@(posedge clk_250m)
    begin
        // AD_Count        <= AD_Count + 3'd1; //AD_Count位数改为4位
        bit_count       <= bit_count + 8'd1;
    //    ad_joint_data <= (ad_joint_data<<16) + AD_Count;
    end

reg [127:0]                           ddr3_wr_data;//ddr3写入的数据
reg                                   ddr3_onewr_flag;//ddr3写入一个数据的标志位，没用了
reg                                   ddr3_allwr_flag;//ddr3全部数据写入，没用了

/*****************************************************************
**********************一个周期的标志*******************************
*****************************************************************/
// parameter ONE_PERIOD=21'd2000000;
// reg [20:0]              Phase_count;
// (*mark_debug="true"*)reg [5:0]               Period_count;
// //wire                     Period_flag;
// (*mark_debug="true"*)reg                     Period_flag;
// always@(posedge clk)
//     if(rst&!init_calib_complete)begin
//         Phase_count         <= 21'd0;
//         Period_flag         <= 0;
//     end 
//     else if(state==0)begin
//         Phase_count         <= 21'd0;
//         Period_flag         <= 0;
//         Period_count        <= 0;
//     end
//     else begin
//         if(Phase_count==ONE_PERIOD)begin
//             Phase_count         <= 24'd0;
//             Period_count        <= Period_count + 6'd1;
//             if(Period_count == 6'd25)begin
//                 Period_flag     <= 1;
//                 Period_count    <= 6'd0;
//             end
//         end
//         else if(Phase_count < ONE_PERIOD) begin
//             Phase_count         <= Phase_count+1'b1;
//             Period_flag         <= 0;
//         end
//     end

//assign Period_flag = (Period_count == 6'd25)?1:0;

//一个工频周期到时间后OnePeriod_flag置1，ddr写入周期数，写入后用ddr3_oneperiod_flag表示写完了，后OnePeriod_flag置0，周期数用不上，可以删去此步
(*mark_debug="true"*)reg                     OnePeriod_flag;//一个工频周期的标志
(*mark_debug="true"*)reg                     ddr3_oneperiod_flag;//ddr3将一个工频周期的数据都写入完成标志
always@(posedge clk or negedge rst_key)
if(!rst_key)begin
    OnePeriod_flag          <= 0;
end
else if(ddr3_oneperiod_flag) begin
    OnePeriod_flag <= 0;
end
else if(OnePeriodFlag)begin
    OnePeriod_flag <= 1;
end
else begin
    OnePeriod_flag <= OnePeriod_flag;
end


/*****************************************************************
**********************DDR3控制************************************
*****************************************************************/
   wire sys_rst;
   wire locked;
   wire clk_ref_i;
   wire sys_clk_i;
   wire clk_100;
   wire clk_200;
   wire clk_400;
      
   assign sys_rst = ~rst_key;//复位信号
   assign clk_ref_i = clk_200;//200M的参考时钟
   assign sys_clk_i = clk_100;//100M的系统时钟
   
   //时钟管理产生DDR需要的时钟   
   clk_wiz_0 CLK_WIZ_DDR
   ( 
       .clk_out1    (clk_100),
       .clk_out2    (clk_200),
       .clk_out3    (clk_400),
       .reset       (sys_rst),
       .locked      (locked),
       .clk_in1     (clk100m_i)
   ); 


function integer clogb2 (input integer size);
    begin
      size = size - 1;
      for (clogb2=1; size>1; clogb2=clogb2+1)
        size = size >> 1;
    end
  endfunction // clogb2

  function integer STR_TO_INT;
    input [7:0] in;
    begin
      if(in == "8")
        STR_TO_INT = 8;
      else if(in == "4")
        STR_TO_INT = 4;
      else
        STR_TO_INT = 0;
    end
  endfunction


  localparam DATA_WIDTH            = 16;
  localparam RANK_WIDTH            = clogb2(RANKS); //Rank = 1,so clogb2 = 1
  localparam PAYLOAD_WIDTH         = (ECC_TEST == "OFF") ? DATA_WIDTH : DQ_WIDTH; //ECC_TEST=OFF, so PAYLOAD = DATA_WIDTH = 16
  localparam BURST_LENGTH          = STR_TO_INT(BURST_MODE);
  localparam APP_DATA_WIDTH        = 2 * nCK_PER_CLK * PAYLOAD_WIDTH; //nCK_PER_CLK = 4,so APP_DATA_WIDTH = 2*4*16=128
  localparam APP_MASK_WIDTH        = APP_DATA_WIDTH / 8;

  //***************************************************************************
  // Traffic Gen related parameters (derived)
  //***************************************************************************
  localparam TG_ADDR_WIDTH         = ((CS_WIDTH == 1) ? 0 : RANK_WIDTH)
                                      + BANK_WIDTH + ROW_WIDTH + COL_WIDTH;
  localparam MASK_SIZE             = DATA_WIDTH/8;
      

  // Wire declarations
      
  wire [(2*nCK_PER_CLK)-1:0]            app_ecc_multiple_err;
  wire [(2*nCK_PER_CLK)-1:0]            app_ecc_single_err;
  (*mark_debug="true"*)wire [ADDR_WIDTH-1:0]                 app_addr;       
  wire [2:0]                            app_cmd;
  (*mark_debug="true"*)wire                                  app_en;//Input:This is the active-High strobe for the app_addr[], app_cmd[2:0],
                                               //app_sz, and app_hi_pri inputs.
  (*mark_debug="true"*)wire                                  app_rdy;//Output:This output indicates that the UI is ready to accept commands.
                                                // If the signal is deasserted when app_en is enabled, the current
                                                // app_cmd and app_addr must be retried until app_rdy is
                                                // asserted.
  (*mark_debug="true"*)wire [APP_DATA_WIDTH-1:0]             app_rd_data;//Output:This provides the output data from read commands.
  wire                                  app_rd_data_end;//Output:This active-High output indicates that the current clock cycle is
                                                        // the last cycle of output data on app_rd_data[]. This is valid only
                                                        // when app_rd_data_valid is active-High.
  (*mark_debug="true"*)wire                                  app_rd_data_valid;//Output:This active-High output indicates that app_rd_data[] is valid.
  (*mark_debug="true"*)wire [APP_DATA_WIDTH-1:0]             app_wdf_data;//Input:This provides the data for write commands.
  (*mark_debug="true"*)wire                                  app_wdf_end;//Input:This active-High input indicates that the current clock cycle is
                                                    // the last cycle of input data on app_wdf_data[].
  wire [APP_MASK_WIDTH-1:0]             app_wdf_mask;//Input:This provides the mask for app_wdf_data[].
  (*mark_debug="true"*)wire                                  app_wdf_rdy;//Output:This output indicates that the write data FIFO is ready to receive
                                                    // data. Write data is accepted when app_wdf_rdy = 1’b1 and
                                                    // app_wdf_wren = 1’b1.
  wire                                  app_sr_active;//Output:This output is reserved.
  wire                                  app_ref_ack;//Output:This active-High output indicates that the Memory Controller
                                                    // has sent the requested refresh command to the PHY interface.
  wire                                  app_zq_ack;//Output:This active-High output indicates that the Memory Controller
                                                    // has sent the requested ZQ calibration command to the PHY
                                                    // interface.
  (*mark_debug="true"*)wire                                  app_wdf_wren;//Input:This is the active-High strobe for app_wdf_data[].
                                                      // This input indicates that the data on the app_wdf_data[] bus is valid.
  wire [(64+(2*APP_DATA_WIDTH))-1:0]    error_status;
  wire [(PAYLOAD_WIDTH/8)-1:0]          cumlative_dq_lane_error;
  wire                                  mem_pattern_init_done;
  wire [47:0]                           tg_wr_data_counts;
  wire [47:0]                           tg_rd_data_counts;
  wire                                  modify_enable_sel;
  wire [2:0]                            data_mode_manual_sel;
  wire [2:0]                            addr_mode_manual_sel;
  wire [APP_DATA_WIDTH-1:0]             cmp_data;
  reg [63:0]                            cmp_data_r;
  wire                                  cmp_data_valid;
  reg                                   cmp_data_valid_r;
  wire                                  cmp_error;
  wire [(PAYLOAD_WIDTH/8)-1:0]          dq_error_bytelane_cmp;

  wire                                  clk;
  wire                                  rst;
     
  wire [11:0]                           device_temp;


//***************************************************************************     
// Start of User Design top instance
//***************************************************************************
// The User design is instantiated below. The memory interface ports are
// connected to the top-level and the application interface ports are
// connected to the traffic generator module. This provides a reference
// for connecting the memory controller to system.
//***************************************************************************

  mig_7series_0 u_mig_7series_0
      (
       
       
// Memory interface ports
       .ddr3_addr                      (ddr3_addr),
       .ddr3_ba                        (ddr3_ba),
       .ddr3_cas_n                     (ddr3_cas_n),
       .ddr3_ck_n                      (ddr3_ck_n),
       .ddr3_ck_p                      (ddr3_ck_p),
       .ddr3_cke                       (ddr3_cke),
       .ddr3_ras_n                     (ddr3_ras_n),
       .ddr3_we_n                      (ddr3_we_n),
       .ddr3_dq                        (ddr3_dq),
       .ddr3_dqs_n                     (ddr3_dqs_n),
       .ddr3_dqs_p                     (ddr3_dqs_p),
       .ddr3_reset_n                   (ddr3_reset_n),
       .init_calib_complete            (init_calib_complete),
      
       .ddr3_cs_n                      (ddr3_cs_n),
       .ddr3_dm                        (ddr3_dm),
       .ddr3_odt                       (ddr3_odt),
// Application interface ports
       .app_addr                       (app_addr),
       .app_cmd                        (app_cmd),
       .app_en                         (app_en),
       .app_wdf_data                   (app_wdf_data),
       .app_wdf_end                    (app_wdf_end),
       .app_wdf_wren                   (app_wdf_wren),
       .app_rd_data                    (app_rd_data),
       .app_rd_data_end                (app_rd_data_end),
       .app_rd_data_valid              (app_rd_data_valid),
       .app_rdy                        (app_rdy),
       .app_wdf_rdy                    (app_wdf_rdy),  //输出为1表示app_rd_data[]是有效数据
       .app_sr_req                     (1'b0),
       .app_ref_req                    (1'b0),
       .app_zq_req                     (1'b0),
       .app_sr_active                  (app_sr_active),
       .app_ref_ack                    (app_ref_ack),
       .app_zq_ack                     (app_zq_ack),
       .ui_clk                         (clk),
       .ui_clk_sync_rst                (rst),
      
       .app_wdf_mask                   (16'd0),
      
       
// System Clock Ports
       .sys_clk_i                      (sys_clk_i),
// Reference Clock Ports
       .clk_ref_i                      (clk_ref_i),
       .device_temp                    (device_temp),  
       .sys_rst                        (locked)
       );
// End of User Design top instance



wire [127:0]          Write_Fifo_Out;
(*mark_debug="true"*)wire                  Write_Fifo_empty;
(*mark_debug="true"*)wire                  Write_Fifo_full;
(*mark_debug="true"*)wire [7:0]            Write_Fifo_rusdw_o;
(*mark_debug="true"*)wire [7:0]            Write_Fifo_datain;
wire                    Write_Fifo_wr_en;
wire                    Write_Fifo_rst;

assign Write_Fifo_wr_en     = WriteSign&&(Write_Fifo_full==0);
assign Write_Fifo_datain    = {adc_data};
assign Write_Fifo_rst       = (state == 4'd1)?1'd1:1'd0;

//写入DDR3的FIFO
fifo_generator_0 FIFO_INST (
    .rst                   (Write_Fifo_rst),  // input wire rst
    .wr_clk                (clk_250m), // input wire wr_clk
    .rd_clk                (clk),// input wire rd_clk
    .din                   ({8'd0,adc_data}), // input wire [15 : 0] din
    .wr_en                 (Write_Fifo_wr_en), // input wire wr_en
    .rd_en                 (ddr3write_en), // input wire rd_en
    .dout                  (Write_Fifo_Out),  // output wire [127 : 0] dout
    .full                  (Write_Fifo_full),  // output wire full
    .empty                 (Write_Fifo_empty), // output wire empty
    .rd_data_count         (Write_Fifo_rusdw_o)  // output wire [7 : 0] rd_data_count
    );

/******从ddr3读入FIFO将128位重新拆分为16位数据*******/
(*mark_debug="true"*)wire [15:0]            Read_Fifo_Out;
(*mark_debug="true"*)wire                   Read_Fifo_rst;
(*mark_debug="true"*)wire                   Read_Fifo_empty;
(*mark_debug="true"*)wire                   Read_Fifo_full;
(*mark_debug="true"*)wire [7:0]             Read_Fifo_wusdw_o;
(*mark_debug="true"*)wire [10:0]            Read_Fifo_rusdw_o;
(*mark_debug="true"*)wire                   Read_Fifo_wren;
(*mark_debug="true"*)wire                   Read_Fifo_rden;
wire                   Read_Fifo_rst;

assign Read_Fifo_rst      = (state == 4'd3)?1'd1:1'd0;
//读取ddr3数据的FIFO
fifo_generator_1 READ_FIFO_INST (
    .rst              (Read_Fifo_rst),  // input wire rst
    .wr_clk           (clk), // input wire wr_clk同MIG控制的用户时钟一致
    .rd_clk           (clk_200),// input wire rd_clk
    .din              (app_rd_data), // input wire [127 : 0] din
    .wr_en            (Read_Fifo_wren), // input wire wr_en
    .rd_en            (Read_Fifo_rden), // input wire rd_en
    .dout             (Read_Fifo_Out),  // output wire [15 : 0] dout
    .full             (Read_Fifo_full),  // output wire full
    .empty            (Read_Fifo_empty), // output wire empty
    .wr_data_count    (Read_Fifo_wusdw_o), // output wire [7 : 0] rd_data_count
    .rd_data_count    (Read_Fifo_rusdw_o)  // output wire [10 : 0] rd_data_count
    );
assign Read_Fifo_wren = (app_rd_data_valid);//将有效数据写入ddr3
assign Read_Fifo_rden = (Read_Fifo_empty==0)&&(!FeatureExtraction_flag)&&SendOver?1:0;//当读FIFO里面数据不为空，并且没有在特征提取，并且arm将数据接收完成

// (*mark_debug="true"*)wire [15:0]            Read_Fifo_Out_r;
// assign Read_Fifo_Out_r = Read_Fifo_Out;

(*mark_debug="true"*)reg [3:0]              state=0;//读取ddr3的状态
(*mark_debug="true"*)reg                    ProsessIn=0;//表示读写操作的包络
(*mark_debug="true"*)reg                    WriteSign=0;//表示是写操作
(*mark_debug="true"*)reg                    ProsessIn1=0;//表示写操作的包络
(*mark_debug="true"*)reg [28:0]             app_addr_begin=0;//要读写的ddr的地址
(*mark_debug="true"*)reg [31:0]             CountWrite_tem=0; //5万个数据只需要23位
(*mark_debug="true"*)reg [31:0]             CountRead_tem=0;
// // (*mark_debug="true"*)reg [31:0]             PeriodPoint_num;

// reg [29:0]             CountWrite=0;
// reg [29:0]             CountRead=0;
(*mark_debug="true"*)reg [3:0]              state1=0;
(*mark_debug="true"*)wire                   ddr3write_en; 
(*mark_debug="true"*)wire                   ddr3read_en; 

reg [3:0]              state_reg=0;
reg                    ProsessIn_reg=0;//表示读写操作的包络
reg                    WriteSign_reg=0;//表示是写操作
reg [28:0]             app_addr_begin_reg=0;
reg [31:0]             CountWrite_tem_reg=0; //5万个数据只需要23位
reg [31:0]             CountRead_tem_reg=0;
reg [31:0]             PeriodPoint_num_reg;
reg [127:0]            ddr3_wr_data_reg;
reg                    ddr3_onewr_flag_reg;
reg                    ddr3_allwr_flag_reg;
reg                    ddr3_oneperiod_flag_reg;
reg                    ProcessOver;
reg                    ProcessOver_reg;
reg [7:0]              ProcessNum;
reg [7:0]              ProcessNum_reg;

assign    app_wdf_end                     =app_wdf_wren;//两个相等即可
assign    app_en                          =ProsessIn?(WriteSign?app_rdy:ddr3read_en):1'd0;//控制命令使能
assign    app_cmd                         =WriteSign?CMD_WRITE:CMD_READ;
assign    app_addr                        =app_addr_begin;
assign    app_wdf_data                    =ddr3_wr_data;//写入的数据
assign    app_wdf_wren                    =ProsessIn1?app_rdy&&app_wdf_rdy:1'd0;
assign    ddr3write_en                    =app_rdy&&app_wdf_rdy&&(Write_Fifo_rusdw_o>=8'd2);//
assign    ddr3read_en                     =app_rdy&&(Read_Fifo_wusdw_o <= 8'd230)&&(!FeatureExtraction_flag)&&SendOver;

wire      OneSampleWriteOver;//一次采样结束，25个工频周期结束
assign    OneSampleWriteOver = OneSampleFlag&&app_rdy&&app_wdf_rdy;


//状态转移
always@(posedge clk)
if(rst&!init_calib_complete)//
   begin
   state                            <=4'd0;
   end
else begin
   state                            <=state_reg;
end
always@(*)
begin
    case(state)
    4'd0:  begin
       state_reg                            <=StartSample1?4'd1:4'd0;
       end
    4'd1:  begin
       state_reg                            <=4'd2;
       end
    4'd2:  begin//写DDR3
       state_reg                            <=StopOrder?4'd0:((CountWrite_tem!=0)&&OneSampleWriteOver?4'd3:4'd2);//上位机强制结束，状态变为0，最后一个地址写完之后跳出状态
       end
    4'd3:  begin
       state_reg                            <=StopOrder?4'd0:((state1==4'd0)?4'd4:state);
       end
    4'd4:    begin//读DDR3
       state_reg                            <=StopOrder?4'd0:((CountRead_tem==CountWrite_tem)&&app_rdy?4'd5:state);//当写入数量等于读取的数量，表示读取结束
       end
    4'd5:  begin
       state_reg                            <=StopOrder?4'd0:4'd1;
       end
    default:begin
       state_reg                            <=4'd1;
       end        
   endcase
end

//根据状态进行数据转移
always@(posedge clk)
   if(rst&!init_calib_complete)//
       begin
       app_addr_begin                   <=28'd0;
       WriteSign                        <=1'd0;
       ProsessIn                        <=1'd0;
       CountWrite_tem                   <=32'd0;//
       CountRead_tem                    <=32'd0;
       ddr3_oneperiod_flag              <=0;
       // PeriodPoint_num                  <=32'd0;
       ddr3_allwr_flag                  <=0;
       ddr3_onewr_flag                  <=1'd0; 
       ddr3_wr_data                     <=128'd0;
       ProcessOver                      <= 0;
       end
    else begin
       app_addr_begin                   <=app_addr_begin_reg;
       WriteSign                        <=WriteSign_reg;
       ProsessIn                        <=ProsessIn_reg;
       CountWrite_tem                   <=CountWrite_tem_reg;//
       CountRead_tem                    <=CountRead_tem_reg;
       ddr3_oneperiod_flag              <=ddr3_oneperiod_flag_reg;
       // PeriodPoint_num                  <=PeriodPoint_num_reg;
       ddr3_allwr_flag                  <=ddr3_allwr_flag_reg;
       ddr3_onewr_flag                  <=ddr3_onewr_flag_reg; 
       ddr3_wr_data                     <=ddr3_wr_data_reg;
       ProcessOver                      <= ProcessOver_reg;
       ProcessNum                       <= ProcessNum_reg;
    end
always@(*)
begin
    case(state)
    4'd0:  begin
       app_addr_begin_reg                   <=28'd0;
       WriteSign_reg                        <=1'd0;
       ProsessIn_reg                        <=1'd0;
       CountWrite_tem_reg                   <=32'd0;//
       CountRead_tem_reg                    <=32'd0;
       ddr3_oneperiod_flag_reg              <=0;
       // PeriodPoint_num_reg                  <=32'd0;
       ddr3_allwr_flag_reg                  <=0;
       ddr3_onewr_flag_reg                  <=1'd0; 
       ddr3_wr_data_reg                     <=128'd0;
       ProcessOver_reg                      <=ProcessOver;
       end
    4'd1:  begin
       WriteSign_reg                        <=1'd1;
       ProsessIn_reg                        <=1'd1;    
       ddr3_wr_data_reg                     <=128'd0;    
       app_addr_begin_reg                   <=28'd0;
       CountWrite_tem_reg                   <=32'd0;//
       CountRead_tem_reg                    <=32'd0;
       ddr3_oneperiod_flag_reg              <=0;
       // PeriodPoint_num_reg                  <=32'd0;
       ddr3_allwr_flag_reg                  <=0;
       ddr3_onewr_flag_reg                  <=1'd0; 
       ProcessOver_reg                      <=ProcessOver;
       end
    4'd2:  begin//写DDR3
       WriteSign_reg                        <=OneSampleWriteOver?1'd0:1'd1;//写数据使能
       ProsessIn_reg                        <=OneSampleWriteOver?1'd0:1'd1;//写命令使能
       ddr3_allwr_flag_reg                  <=OneSampleWriteOver?1'd1:1'd0;
       ddr3_onewr_flag_reg                  <=ddr3write_en?1'd1:1'd0; 

       ddr3_oneperiod_flag_reg              <=ddr3write_en?((OnePeriod_flag)?1:0):ddr3_oneperiod_flag;//一个工频周期到来之后成功写入工频周期数的标志
       ddr3_wr_data_reg                     <=ddr3write_en?((OnePeriod_flag)?{16'h0100,{10'd0,Period_count},96'd0}:Write_Fifo_Out):ddr3_wr_data;//一个工频周期到来之后写入工频周期数，否则写入从写fifo读取的数据       
       CountWrite_tem_reg                   <=ddr3write_en?(CountWrite_tem+32'd1):CountWrite_tem;//计算写入ddr的数据个数
       // PeriodPoint_num_reg                  <=ddr3write_en?((OnePeriod_flag)?0:(PeriodPoint_num+32'd1)):PeriodPoint_num;
       app_addr_begin_reg                   <=ddr3write_en?(app_addr_begin+28'd8):app_addr_begin;//ddr3的地址      
       CountRead_tem_reg                    <=32'd0;
       ProcessOver_reg                      <=ProcessOver;
       end
    4'd3:  begin
       WriteSign_reg                        <=1'd0;
       ProsessIn_reg                        <=(state1==4'd0)?1'd1:1'd0;
       ddr3_wr_data_reg                     <=128'd0;    
       app_addr_begin_reg                   <=28'd0;    
       CountRead_tem_reg                    <=32'd1;
       CountWrite_tem_reg                   <=CountWrite_tem;
       ddr3_allwr_flag_reg                  <=ddr3_allwr_flag;
       ddr3_onewr_flag_reg                  <=ddr3_onewr_flag; 
       ddr3_oneperiod_flag_reg              <=0;
       ProcessOver_reg                      <=0;
       // PeriodPoint_num_reg                  <=32'd0;
       end
    4'd4:    begin//读DDR3
       WriteSign_reg                        <=1'd0;//读ddr，置0
       ProsessIn_reg                        <=(CountRead_tem==CountWrite_tem)&&app_rdy?1'd0:1'd1;    
       app_addr_begin_reg                   <=ddr3read_en?(app_addr_begin+28'd8):app_addr_begin;//ddr3的地址 
       CountRead_tem_reg                    <=ddr3read_en?(CountRead_tem+32'd1):CountRead_tem;//计算从ddr读取的个数
       ddr3_wr_data_reg                     <=128'd0;
       CountWrite_tem_reg                   <=CountWrite_tem;
       ddr3_allwr_flag_reg                  <=ddr3_allwr_flag;
       ddr3_onewr_flag_reg                  <=ddr3_onewr_flag; 
       ddr3_oneperiod_flag_reg              <=0;
       ProcessOver_reg                      <=(CountRead_tem==CountWrite_tem)&&app_rdy?1'd1:ProcessOver;//读完了表示都处理完了
       // PeriodPoint_num_reg                  <=32'd0;
       end
    4'd5:  begin
       WriteSign_reg                        <=1'd0;
       ProsessIn_reg                        <=1'd1;
       ddr3_wr_data_reg                     <=128'd0;    
       app_addr_begin_reg                   <=28'd0;    
       CountRead_tem_reg                    <=32'd1;
       CountWrite_tem_reg                   <=CountWrite_tem;
       ddr3_allwr_flag_reg                  <=ddr3_allwr_flag;
       ddr3_onewr_flag_reg                  <=ddr3_onewr_flag; 
       ddr3_oneperiod_flag_reg              <=0;
       ProcessOver_reg                      <=ProcessOver;
       // ProcessNum_reg                       <= ProcessNum;
       // PeriodPoint_num_reg                  <=32'd0;
       end
    default:begin
       app_addr_begin_reg                   <=28'd0;
       WriteSign_reg                        <=1'd0; 
       ProsessIn_reg                        <=1'd0;
       ddr3_wr_data_reg                     <=128'd0;
       end        
   endcase
end


always@(posedge clk)//单独将写操作从上面的状态机提出来，当然也可以和上面的状态机合并到一起
   if(rst&!init_calib_complete)//
       begin
       state1                              <=4'd0;
       ProsessIn1                          <=1'd0;
       end
  else case(state1)
  4'd0:    begin
         state1                            <=(state==4'd1)?4'd1:4'd0;
         ProsessIn1                        <=(state==4'd1)?1'd1:1'd0;
         end
  4'd1:    begin
         state1                            <=(OneSampleFlag)&&app_rdy&&app_wdf_rdy?4'd0:4'd1; 
         ProsessIn1                        <=(OneSampleFlag)&&app_rdy&&app_wdf_rdy?1'd0:1'd1;      
         end
  default:begin
         state1                            <=(state==4'd1)?4'd1:4'd0;
         ProsessIn1                        <=(state==4'd1)?1'd1:1'd0;
         end
  endcase

wire              Extract_en;//单脉冲提取使能
(*mark_debug="true"*)wire  [15:0]      Monopulse_data1;
(*mark_debug="true"*)wire              FeatureExtraction_flag;
wire              FeatureExtraction_flag_reg;
(*mark_debug="true"*)wire  [15:0]      Pulse_point_num;
wire  [7:0]       Monopulse_data_01;
wire  [7:0]       Monopulse_data_00;
(*mark_debug="true"*)wire  [1:0]       WaveState;
(*mark_debug="true"*)wire  [7:0]       Monopulse_data_1;

/*********************************************/
wire  [15:0]      Front_area;
(*mark_debug="true"*)wire  [15:0]      Behind_area;
wire  [15:0]      Total_area;
(*mark_debug="true"*)wire  [15:0]      Front_Width;
(*mark_debug="true"*)wire  [15:0]      Behind_Width;
(*mark_debug="true"*)wire  [15:0]      Total_Width;
wire  [7:0]       Peak_value;
(*mark_debug="true"*)wire  [23:0]      Second_moment;
(*mark_debug="true"*)wire  [32:0]      Third_moment;
(*mark_debug="true"*)wire  [40:0]      Fourth_moment;

(*mark_debug="true"*)wire  [15:0]      Monopulse_num;
wire  [15:0]      Monopulse_num_reg;
wire  [15:0]      Read_num; //从DDR2中读取的个数
wire  [7:0]       Mean_value;
wire  [7:0]       Mean_value_remainders;
wire  [20:0]      Square_data;
(*mark_debug="true"*)wire  [15:0]      ii;
(*mark_debug="true"*)wire  [2:0]       Arithmetic_State;
wire  [15:0]      Period_condition;
wire              Read_Over_flag;
wire  [31:0]      MonopulsePosition;
(*mark_debug="true"*)wire  [15:0]      Count;
(*mark_debug="true"*)wire  [15:0]      time_cnt;
wire  [15:0]      time_cnt_n;
// wire              Over_flag;
wire  [7:0]       MonopulseExThreshould;
(*mark_debug="true"*)wire  [7:0]       MonopulseExHold;
wire  [7:0]       MonopulseMultiThreshould;
wire  [7:0]       MonopulseEndHold;
wire  [3:0]       DDR_State;

assign Extract_en             = Read_Fifo_rden;//读fifo使能为提取单脉冲的使能
assign DDR_State              = state;
MonopulseEx_Arithmetic MonopulseEx_Arithmetic1
(
  .Clk                               (clk_200),
  .Rst                               (!sys_rst),
  .Extract_en                        (Extract_en),
  .Period_count                      (Period_count),
  .Data_in                           (Read_Fifo_Out),
  .DDR_State                         (DDR_State),
  .MonopulseExThreshould             (MonopulseExThreshould),
  .MonopulseExHold                   (MonopulseExHold),
  .MonopulseMultiThreshould          (MonopulseMultiThreshould),
  .MonopulseEndHold                  (MonopulseEndHold),
  .GentalThreshould                  (GentalThreshould),
  .GentalThreshouldNum               (GentalThreshouldNum),
  .Monopulse_data1                   (Monopulse_data1),
  .Pulse_point_num                   (Pulse_point_num),    //鏈鍗曡剦鍐茬殑閲囨牱鐐规暟
  .FeatureExtraction_flag            (FeatureExtraction_flag),     //灏嗘彁鍙栫殑鍗曡剦鍐茬殑涓暟浠ュ強鍗曡剦鍐查噰鏍风偣閫佸幓鐗瑰緛鎻愬彇
  .FeatureExtraction_flag_reg        (FeatureExtraction_flag_reg),
  .WaveState                         (WaveState),
  .Monopulse_data_1                  (Monopulse_data_1),
  .Monopulse_data_00                 (Monopulse_data_00),
  .Monopulse_data_01                 (Monopulse_data_01),
  .Period_condition                  (Period_condition),
  .ReadPosition                      (ReadPosition),
  .MonopulsePosition                 (MonopulsePosition),
  .Count                             (Count),
  
  .Monopulse_num                     (Monopulse_num),     //涓€涓懆鏈熷唴鍗曡剦鍐茬殑涓暟
  .Front_area                        (Front_area), //波前面积
  .Behind_area                       (Behind_area), //波后面积
  .Total_area                        (Total_area), //总面��
  .Front_Width                       (Front_Width),
  .Behind_Width                      (Behind_Width),
  .Total_Width                       (Total_Width),
  .Peak_value                        (Peak_value), //最大��
  .Second_moment                     (Second_moment), //二阶��
  .Third_moment                      (Third_moment), //三阶��
  .Fourth_moment                     (Fourth_moment), //四阶��
  .Read_num                          (Read_num),
  .Mean_value                        (Mean_value),
  .Mean_value_remainders             (Mean_value_remainders),
  .ii                                (ii), 
  .Square_data                       (Square_data),
  .Arithmetic_State                  (Arithmetic_State),
  .Read_Over_flag                    (Read_Over_flag),
  .time_cnt                          (time_cnt),
  .time_cnt_n                        (time_cnt_n),
  .Monopulse_num_reg                 (Monopulse_num_reg)
  // .Over_flag                         (Over_flag)
  
);

wire [5:0]        Period_count;
wire              OneSampleFlag;
Phase Phase
(
  .Clk_Phase                         (clk),
  .Rst                               (!sys_rst),
  .Signal_50HZ                       (Signal_50HZ),
  .StartSample                       (StartSample1),
  .DDR_State                         (DDR_State),
  // .sync_extern_out                   (sync_extern_out),
  .sync_led                          (sync_led),
  .Period_count                      (Period_count),
  .OnePeriodFlag                     (OnePeriodFlag),
  .OneSampleFlag                     (OneSampleFlag)
);

endmodule

