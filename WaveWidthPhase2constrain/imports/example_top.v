//*****************************************************************************
// (c) Copyright 2009 - 2013 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
//*****************************************************************************
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor             : Xilinx
// \   \   \/     Version            : 4.0
//  \   \         Application        : MIG
//  /   /         Filename           : example_top.v
// /___/   /\     Date Last Modified : $Date: 2011/06/02 08:35:03 $
// \   \  /  \    Date Created       : Tue Sept 21 2010
//  \___\/\___\
//
// Device           : 7 Series
// Design Name      : DDR3 SDRAM
// Purpose          :
//   Top-level  module. This module serves as an example,
//   and allows the user to synthesize a self-contained design,
//   which they can be used to test their hardware.
//   In addition to the memory controller, the module instantiates:
//     1. Synthesizable testbench - used to model user's backend logic
//        and generate different traffic patterns
// Reference        :
// Revision History :
//*****************************************************************************

//`define SKIP_CALIB
`timescale 1ps/1ps

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
    input                               pld_clk_p,pld_clk_n,   //CDCM61004的输出PLD_CLK_p/n 
    input                               dco_p,dco_n, //AD输出数据输出时钟，DCO周期是CLK的2倍，
                                                    //DCO-(DCO_p)为正A输出，为负B输出。这俩差分信号互补
    input  [7:0]                        adc_p1,adc_p2, //AD输出的差分数据，两个差分输出根据DCO的来决定当前时刻哪个输出
    

    output                              pen, //LT1963A低压差线性稳压器的关闭功能引脚(|SHDN)，
                                            //低电平有效，当引脚为低电平时稳压器不工作  
    output                              pll_ce, //CDCM61004的控制使能，置1为使能
    output                              pll_rst_n, //低电平有效，低电平复位，高电平正常工作  
    output                              adc_pd,  //FPGA置1设置AD为powerdown
    //output [7:0]                        adc_data,  //将上面的差分输出结合为最后的输出

    input                               dac_pll_locked,
    output                              dac_rst,
    output [9:0]                        dac_p1,dac_p2,
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
   
   input                                clk100m_i,
   input                                rst_key   

   // System reset - Default polarity of sys_rst pin is Active Low.
   // System reset polarity will change based on the option 
   // selected in GUI.
   //input                                        sys_rst
   );


(*mark_debug="true"*)reg [127:0]                           ddr3_wr_data;
(*mark_debug="true"*)reg                                   ddr3_onewr_flag;
(*mark_debug="true"*)reg                                   ddr3_allwr_flag;
//(*mark_debug="true"*)reg                                   ddr3_allrd_flag;

(*mark_debug="true"*)reg [2:0]               AD_Count;
(*mark_debug="true"*)wire                    ddr3_flag;
(*mark_debug="true"*)reg [127:0]             ddr3_wr_data_r;
(*mark_debug="true"*)reg [7:0]               bit_count;
always@(posedge clk_250m)
    begin
        AD_Count        <= AD_Count + 3'd1; //AD_Count位数改为4位
        bit_count       <= bit_count + 8'd1;
    //    ad_joint_data <= (ad_joint_data<<16) + AD_Count;
    end



/*****************************************************************
**********************一个周期的标志*******************************
*****************************************************************/
parameter ONE_PERIOD=21'd2000000;
reg [20:0]              Phase_count;
(*mark_debug="true"*)reg [5:0]               Period_count;
//wire                     Period_flag;
(*mark_debug="true"*)reg                     Period_flag;
always@(posedge clk)
    if(rst&!init_calib_complete)begin
        Phase_count         <= 21'd0;
        Period_flag         <= 0;
    end 
    else if(Phase_count==ONE_PERIOD)begin
        Phase_count         <= 24'd0;
        Period_count        <= Period_count + 6'd1;
        if(Period_count == 6'd25)begin
            Period_flag     <= 1;
            Period_count    <= 6'd0;
        end
    end
    else if(Phase_count < ONE_PERIOD) begin
        Phase_count         <= Phase_count+1'b1;
        Period_flag         <= 0;
    end

//assign Period_flag = (Period_count == 6'd25)?1:0;

(*mark_debug="true"*)reg                     OnePeriod_flag;
(*mark_debug="true"*)reg                     ddr3_oneperiod_flag;
always@(posedge clk)
    if(rst&!init_calib_complete)begin
        OnePeriod_flag <= 0;
    end 
    else if(ddr3_oneperiod_flag) begin
        OnePeriod_flag <= 0;
    end
    else if(Phase_count==ONE_PERIOD)begin
        OnePeriod_flag <= 1;
    end
    else begin
        OnePeriod_flag <= 0;
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
      
  wire [(2*nCK_PER_CLK)-1:0]              app_ecc_multiple_err;
  wire [(2*nCK_PER_CLK)-1:0]              app_ecc_single_err;
  (*mark_debug="true"*) wire [ADDR_WIDTH-1:0]                 app_addr;       
  wire [2:0]                            app_cmd;
  wire                                  app_en;
  (*mark_debug="true"*) wire                                  app_rdy;
  (*mark_debug="true"*) wire [APP_DATA_WIDTH-1:0]             app_rd_data;
  wire                                  app_rd_data_end;
  (*mark_debug="true"*)wire                                  app_rd_data_valid;
  (*mark_debug="true"*)wire [APP_DATA_WIDTH-1:0]             app_wdf_data;
  wire                                  app_wdf_end;
  wire [APP_MASK_WIDTH-1:0]             app_wdf_mask;
  wire                                  app_wdf_rdy;
  wire                                  app_sr_active;
  wire                                  app_ref_ack;
  wire                                  app_zq_ack;
  wire                                  app_wdf_wren;
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

  (*mark_debug="true"*)wire                                  clk;
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

(*mark_debug="true"*)wire [127:0]          Write_Fifo_Out;
(*mark_debug="true"*)wire                  Write_Fifo_empty;
(*mark_debug="true"*)wire                  Write_Fifo_full;
(*mark_debug="true"*)wire [7:0]            Write_Fifo_rusdw_o;
(*mark_debug="true"*)wire [7:0]            Write_Fifo_datain;
assign Write_Fifo_datain = {8'd0,bit_count};
fifo_generator_0 FIFO_INST (
    .rst                   (sys_rst),  // input wire rst
    .wr_clk                (clk_250m), // input wire wr_clk
    .rd_clk                (clk),// input wire rd_clk
    .din                   ({8'd0,bit_count}), // input wire [15 : 0] din
    .wr_en                 (WriteSign), // input wire wr_en
    .rd_en                 (ddr3write_en), // input wire rd_en
    .dout                  (Write_Fifo_Out),  // output wire [127 : 0] dout
    .full                  (Write_Fifo_full),  // output wire full
    .empty                 (Write_Fifo_empty), // output wire empty
    .rd_data_count         (Write_Fifo_rusdw_o)  // output wire [7 : 0] rd_data_count
    );

(*mark_debug="true"*)wire [15:0]            Read_Fifo_Out;
(*mark_debug="true"*)wire                   Read_Fifo_rst;
(*mark_debug="true"*)wire                   Read_Fifo_empty;
(*mark_debug="true"*)wire                   Read_Fifo_full;
(*mark_debug="true"*)wire [7:0]             Read_Fifo_wusdw_o;
(*mark_debug="true"*)wire [10:0]            Read_Fifo_rusdw_o;
(*mark_debug="true"*)wire                   Read_Fifo_wren;
(*mark_debug="true"*)wire                   Read_Fifo_rden;


fifo_generator_1 READ_FIFO_INST (
    .rst              (rst),  // input wire rst
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
assign Read_Fifo_wren = (app_rd_data_valid&&ddr3read_en);
assign Read_Fifo_rden = (Read_Fifo_empty==0)&&(!FeatureExtraction_flag)?1:0;


(*mark_debug="true"*)reg                     Read_Fifo_in_en1;
always@(posedge clk)
if(rst&!init_calib_complete)//
   begin
       Read_Fifo_in_en1 <= 0;
   end
else begin
  if(Read_Fifo_wusdw_o >= 8'd200)begin
    Read_Fifo_in_en1 <= 1;
  end
  else if(Read_Fifo_wusdw_o <= 8'd30)begin
    Read_Fifo_in_en1 <= 0;
  end
  else begin
    Read_Fifo_in_en1 <= Read_Fifo_in_en1;
  end
end


(*mark_debug="true"*)reg [3:0]              state=0;
(*mark_debug="true"*)reg                    ProsessIn=0;//表示读写操作的包络
(*mark_debug="true"*)reg                    WriteSign=0;//表示是写操作
(*mark_debug="true"*)reg                    ProsessIn1=0;//表示写操作的包络
(*mark_debug="true"*)reg [28:0]             app_addr_begin=0;
(*mark_debug="true"*)reg [31:0]             CountWrite_tem=0; //5万个数据只需要23位
(*mark_debug="true"*)reg [31:0]             CountRead_tem=0;
(*mark_debug="true"*)reg [31:0]             PeriodPoint_num;

(*mark_debug="true"*)reg [29:0]             CountWrite=0;
(*mark_debug="true"*)reg [29:0]             CountRead=0;
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


assign    app_wdf_end                     =app_wdf_wren;//两个相等即可
assign    app_en                          =ProsessIn?(WriteSign?app_rdy&&app_wdf_rdy:app_rdy):1'd0;//控制命令使能
assign    app_cmd                         =WriteSign?CMD_WRITE:CMD_READ;
assign    app_addr                        =app_addr_begin;
assign    app_wdf_data                    =ddr3_wr_data;//写入的数据是计数器
assign    app_wdf_wren                    =ProsessIn1?app_rdy&&app_wdf_rdy:1'd0;
assign    ddr3write_en                    =app_rdy&&app_wdf_rdy&&(Write_Fifo_rusdw_o>=8'd2);//
assign    ddr3read_en                     =app_rdy&&(!Read_Fifo_in_en1)&&(!FeatureExtraction_flag);


always@(posedge clk)
   if(rst&!init_calib_complete)//
       begin
       state                            <=4'd0;
       app_addr_begin                   <=28'd0;
       WriteSign                        <=1'd0;
       ProsessIn                        <=1'd0;
       CountWrite_tem                   <=32'd0;//
       CountRead_tem                    <=32'd0;
       ddr3_oneperiod_flag              <=0;
       PeriodPoint_num                  <=32'd0;
       ddr3_allwr_flag                  <=0;
       ddr3_onewr_flag                  <=1'd0; 
       ddr3_wr_data                     <=128'd0;
       end
    else begin
       state                            <=state_reg;
       app_addr_begin                   <=app_addr_begin_reg;
       WriteSign                        <=WriteSign_reg;
       ProsessIn                        <=ProsessIn_reg;
       CountWrite_tem                   <=CountWrite_tem_reg;//
       CountRead_tem                    <=CountRead_tem_reg;
       ddr3_oneperiod_flag              <=ddr3_oneperiod_flag_reg;
       PeriodPoint_num                  <=PeriodPoint_num_reg;
       ddr3_allwr_flag                  <=ddr3_allwr_flag_reg;
       ddr3_onewr_flag                  <=ddr3_onewr_flag_reg; 
       ddr3_wr_data                     <=ddr3_wr_data_reg;
    end

always@(*)
begin
    case(state)
    4'd0:  begin
       state_reg                            <=4'd1;
       app_addr_begin_reg                   <=28'd0;
       WriteSign_reg                        <=1'd0;
       ProsessIn_reg                        <=1'd0;
       CountWrite_tem_reg                   <=32'd0;//
       CountRead_tem_reg                    <=32'd0;
       ddr3_oneperiod_flag_reg              <=0;
       PeriodPoint_num_reg                  <=32'd0;
       ddr3_allwr_flag_reg                  <=0;
       ddr3_onewr_flag_reg                  <=1'd0; 
       ddr3_wr_data_reg                     <=128'd0;
       end
    4'd1:  begin
       state_reg                            <=4'd2;
       WriteSign_reg                        <=1'd1;
       ProsessIn_reg                        <=1'd1;    
       ddr3_wr_data_reg                     <=128'd0;    
       app_addr_begin_reg                   <=28'd0;
       CountWrite_tem_reg                   <=32'd0;//
       CountRead_tem_reg                    <=32'd0;
       ddr3_oneperiod_flag_reg              <=0;
       PeriodPoint_num_reg                  <=32'd0;
       ddr3_allwr_flag_reg                  <=0;
       ddr3_onewr_flag_reg                  <=1'd0; 
       end
    4'd2:  begin//写DDR3
       state_reg                            <=Period_flag&&app_rdy&&app_wdf_rdy?4'd3:4'd2;//最后一个地址写完之后跳出状态
       WriteSign_reg                        <=Period_flag&&app_rdy&&app_wdf_rdy?1'd0:1'd1;//写数据使能
       ProsessIn_reg                        <=Period_flag&&app_rdy&&app_wdf_rdy?1'd0:1'd1;//写命令使能
       ddr3_allwr_flag_reg                  <=Period_flag&&app_rdy&&app_wdf_rdy?1'd1:1'd0;
       ddr3_onewr_flag_reg                  <=ddr3write_en?1'd1:1'd0; 

       ddr3_oneperiod_flag_reg              <=ddr3write_en?((OnePeriod_flag)?1:0):ddr3_oneperiod_flag;
       ddr3_wr_data_reg                     <=ddr3write_en?((OnePeriod_flag)?{112'd0,16'h0100}:Write_Fifo_Out):ddr3_wr_data;     
       CountWrite_tem_reg                   <=ddr3write_en?(CountWrite_tem+32'd1):CountWrite_tem;
       PeriodPoint_num_reg                  <=ddr3write_en?((OnePeriod_flag)?0:(PeriodPoint_num+32'd1)):PeriodPoint_num;
       app_addr_begin_reg                   <=ddr3write_en?(app_addr_begin+28'd8):app_addr_begin;      
       CountRead_tem_reg                    <=32'd0;
       end
    4'd3:  begin
       state_reg                            <=(state1==4'd0)?4'd4:state;
       WriteSign_reg                        <=1'd0;
       ProsessIn_reg                        <=(state1==4'd0)?1'd1:1'd0;
       ddr3_wr_data_reg                     <=128'd0;    
       app_addr_begin_reg                   <=28'd0;    
       CountRead_tem_reg                    <=32'd1;
       CountWrite_tem_reg                   <=CountWrite_tem;
       ddr3_allwr_flag_reg                  <=ddr3_allwr_flag;
       ddr3_onewr_flag_reg                  <=ddr3_onewr_flag; 
       ddr3_oneperiod_flag_reg              <=0;
       PeriodPoint_num_reg                  <=32'd0;
       end
    4'd4:    begin//读DDR3
       state_reg                            <=(CountRead_tem==CountWrite_tem)&&app_rdy?4'd0:state;
       WriteSign_reg                        <=1'd0;
       ProsessIn_reg                        <=(CountRead_tem==CountWrite_tem)&&app_rdy?1'd0:1'd1;    
       app_addr_begin_reg                   <=ddr3read_en?(app_addr_begin+28'd8):app_addr_begin;
       CountRead_tem_reg                    <=ddr3read_en?(CountRead_tem+32'd1):CountRead_tem;
       ddr3_wr_data_reg                     <=128'd0;
       CountWrite_tem_reg                   <=CountWrite_tem;
       ddr3_allwr_flag_reg                  <=ddr3_allwr_flag;
       ddr3_onewr_flag_reg                  <=ddr3_onewr_flag; 
       ddr3_oneperiod_flag_reg              <=0;
       PeriodPoint_num_reg                  <=32'd0;
       end
    default:begin
       state_reg                            <=4'd1;
       app_addr_begin_reg                   <=28'd0;
       WriteSign_reg                        <=1'd0; 
       ProsessIn_reg                        <=1'd0;
       ddr3_wr_data_reg                     <=128'd0;
       end        
   endcase
end
// always@(posedge clk)
//    if(rst&!init_calib_complete)//
//        begin
//        state                            <=4'd0;
//        app_addr_begin                   <=28'd0;
//        WriteSign                        <=1'd0;
//        ProsessIn                        <=1'd0;
//        CountWrite_tem                   <=32'd0;//
//        CountRead_tem                    <=32'd0;
//        ddr3_oneperiod_flag              <=0;
//        PeriodPoint_num                  <=32'd0;
//        ddr3_allwr_flag                  <=0;
//        ddr3_onewr_flag                  <=1'd0; 
//        ddr3_wr_data                     <=128'd0;
//        app_addr_begin                   <=0;
//        end
// else case(state)
// 4'd0:    begin
//        state                            <=4'd1;
//        app_addr_begin                   <=28'd0;
//        WriteSign                        <=1'd0;
//        ProsessIn                        <=1'd0;
//        ddr3_wr_data                     <=128'd0;
//        CountWrite_tem                   <=32'd0;//
//        CountRead_tem                    <=32'd0;
//        CountWrite                       <=CountWrite_tem;//
//        CountRead                        <=CountRead_tem;
//        end
// 4'd1:    begin
//        state                            <=4'd2;
//        WriteSign                        <=1'd1;
//        ProsessIn                        <=1'd1;    
//        ddr3_wr_data                     <=128'd0;    
//        app_addr_begin                   <=28'd0;
//        CountWrite_tem                   <=32'd0;//
//        CountRead_tem                    <=32'd0;
//        ddr3_oneperiod_flag              <=0;
//        PeriodPoint_num                  <=32'd0;

//        end
// 4'd2:    begin//写DDR3
//        state                            <=Period_flag&&app_rdy&&app_wdf_rdy?4'd3:4'd2;//最后一个地址写完之后跳出状态
//        WriteSign                        <=Period_flag&&app_rdy&&app_wdf_rdy?1'd0:1'd1;//写数据使能
//        ProsessIn                        <=Period_flag&&app_rdy&&app_wdf_rdy?1'd0:1'd1;//写命令使能
//        ddr3_allwr_flag                  <=Period_flag&&app_rdy&&app_wdf_rdy?1'd1:1'd0;
//        ddr3_onewr_flag                  <=ddr3write_en?1'd1:1'd0; 

//        ddr3_oneperiod_flag              <=ddr3write_en?((OnePeriod_flag)?1:0):ddr3_oneperiod_flag;
//        ddr3_wr_data                     <=ddr3write_en?((OnePeriod_flag)?{112'd0,16'h0100}:Write_Fifo_Out):ddr3_wr_data;     
//        CountWrite_tem                   <=ddr3write_en?(CountWrite_tem+32'd1):CountWrite_tem;
//        PeriodPoint_num                  <=ddr3write_en?((OnePeriod_flag)?0:(PeriodPoint_num+32'd1)):PeriodPoint_num;
//        app_addr_begin                   <=ddr3write_en?(app_addr_begin+28'd8):app_addr_begin;      
//        // if(!OnePeriod_flag) begin
//        //     ddr3_oneperiod_flag          <=ddr3write_en?0:ddr3_oneperiod_flag;
//        //     ddr3_wr_data                 <=ddr3write_en?Write_Fifo_Out:ddr3_wr_data;     
//        //     CountWrite_tem               <=ddr3write_en?(CountWrite_tem+32'd1):CountWrite_tem;
//        //     PeriodPoint_num              <=ddr3write_en?(PeriodPoint_num+32'd1):PeriodPoint_num;
//        //     app_addr_begin               <=ddr3write_en?(app_addr_begin+28'd8):app_addr_begin;
//        // end
//        // else begin
//        //     ddr3_oneperiod_flag          <=ddr3write_en?1:0;
//        //     PeriodPoint_num              <=ddr3write_en?0:PeriodPoint_num;
//        //     ddr3_wr_data                 <=ddr3write_en?{112'd0,16'h0100}:ddr3_wr_data;
//        //     CountWrite_tem               <=ddr3write_en?(CountWrite_tem+32'd1):CountWrite_tem;
//        //     app_addr_begin               <=ddr3write_en?(app_addr_begin+28'd8):app_addr_begin;
//        // end     
//        end
// 4'd3:    begin
//        state                            <=(state1==4'd0)?4'd4:state;
//        WriteSign                        <=1'd0;
//        ProsessIn                        <=(state1==4'd0)?1'd1:1'd0;
//        ddr3_wr_data                     <=128'd0;    
//        app_addr_begin                   <=28'd0;    
//        CountRead_tem                    <=32'd1;
//        CountWrite_tem                   <=CountWrite_tem;
//        app_addr_write                   <=app_addr_begin;
//        end
// 4'd4:    begin//读DDR3
//        state                            <=(CountRead_tem==CountWrite_tem)&&app_rdy?4'd0:state;
//        WriteSign                        <=1'd0;
//        ProsessIn                        <=(CountRead_tem==CountWrite_tem)&&app_rdy?1'd0:1'd1;    
//        app_addr_begin                   <=ddr3read_en?(app_addr_begin+28'd8):app_addr_begin;
//        CountRead_tem                    <=ddr3read_en?(CountRead_tem+32'd1):CountRead_tem;
//        end
// default:begin
//        state                            <=4'd1;
//        app_addr_begin                   <=28'd0;
//        WriteSign                        <=1'd0; 
//        ProsessIn                        <=1'd0;
//        ddr3_wr_data                     <=128'd0;
//        end        
//    endcase
   

always@(posedge clk)//单独将写操作从上面的状态机提出来，当然也可以和上面的状态机合并到一起
   if(rst&!init_calib_complete)//
       begin
       state1                            <=4'd0;
       ProsessIn1                        <=1'd0;
       end
else case(state1)
4'd0:    begin
       state1                            <=(state==4'd1)?4'd1:4'd0;
       ProsessIn1                        <=(state==4'd1)?1'd1:1'd0;
       end
4'd1:    begin
       state1                            <=(Period_flag)&&app_rdy&&app_wdf_rdy?4'd0:4'd1; 
       ProsessIn1                        <=(Period_flag)&&app_rdy&&app_wdf_rdy?1'd0:1'd1;      
       end
default:begin
       state1                            <=(state==4'd1)?4'd1:4'd0;
       ProsessIn1                        <=(state==4'd1)?1'd1:1'd0;
       end
       endcase

reg                          app_wdf_rdy_r=1'b0;
reg                          app_rdy_r=1'b0;


reg  [7:0]                   adc_data_r;
reg  [7:0]                   Period_count_r;
reg  [9:0]                   dac_data_r;
reg                          app_rd_data_valid_r=1'b0;
reg                          ddr3_onewr_flag_r;
reg                          ddr3_allwr_flag_r;
reg [127:0]                  ad_joint_data_r;
reg                          ddr3_flag_r;
reg [4:0]                    AD_Count_r;
reg [127:0]                  ddr3_wr_data_r1;
reg [127:0]                  ddr3_wr_data_r2;
reg [APP_DATA_WIDTH-1:0]     app_rd_data_r;


always@(posedge clk_250m) begin
    app_rd_data_valid_r   <= app_rd_data_valid;
    app_rd_data_r         <= app_rd_data;
    app_rdy_r             <= app_rdy;
    app_wdf_rdy_r         <= app_wdf_rdy;

    adc_data_r            <= adc_data;
    Period_count_r        <= Period_count;
    dac_data_r            <= dac_data;
    ddr3_onewr_flag_r     <= ddr3_onewr_flag;
    ddr3_allwr_flag_r     <= ddr3_allwr_flag;
    ddr3_flag_r           <= ddr3_flag;
    AD_Count_r            <= AD_Count;
    ddr3_wr_data_r1       <= ddr3_wr_data_r;//ddr3_wr_data_1
    ddr3_wr_data_r2       <= ddr3_wr_data;
end


(*mark_debug="true"*) wire [15:0]  app_rd_data1,app_rd_data2,app_rd_data3,app_rd_data4,
            app_rd_data5,app_rd_data6,app_rd_data7,app_rd_data8;

assign app_rd_data1 = app_rd_data[15:0];
assign app_rd_data2 = app_rd_data[31:16];
assign app_rd_data3 = app_rd_data[47:32];
assign app_rd_data4 = app_rd_data[63:48];
assign app_rd_data5 = app_rd_data[79:64];
assign app_rd_data6 = app_rd_data[95:80];
assign app_rd_data7 = app_rd_data[111:96];
assign app_rd_data8 = app_rd_data[127:112];
(*mark_debug="true"*)reg [15:0]                   Read_Fifo_Out_r;
always@(posedge clk_250m) begin
   // app_rd_data1 <= app_rd_data[15:0];
   // app_rd_data2 <= app_rd_data[31:16];
   // app_rd_data3 <= app_rd_data[47:32];
   // app_rd_data4 <= app_rd_data[63:48];
   // app_rd_data5 <= app_rd_data[79:64];
   // app_rd_data6 <= app_rd_data[95:80];
   // app_rd_data7 <= app_rd_data[111:96];
   // app_rd_data8 <= app_rd_data[127:112];
   Read_Fifo_Out_r        <= Read_Fifo_Out;
end
wire [15:0]                   Read_Fifo_Out_rr;
assign Read_Fifo_Out_rr = Read_Fifo_Out_r+1;

wire [127:0]                  Write_Fifo_Out_r;
wire                          Write_Fifo_empty_r;
wire [7:0]                    Write_Fifo_rusdw_o_r;
wire [28:0]                   app_addr_begin_r;
wire                          ddr3write_en_r;
wire                          Write_Fifo_full_r;
wire                          clk_r;
wire                          OnePeriod_flag_r;
wire                          ddr3_oneperiod_flag_r;
wire [31:0]                   PeriodPoint_num_r;
wire  [APP_DATA_WIDTH-1:0]    app_wdf_data_r;
wire [31:0]                   CountWrite_tem_r;
wire [31:0]                   CountRead_tem_r;


assign Write_Fifo_Out_r       = Write_Fifo_Out;
assign Write_Fifo_empty_r     = Write_Fifo_empty;
assign Write_Fifo_rusdw_o_r   = Write_Fifo_rusdw_o;
assign app_addr_begin_r       = app_addr_begin;
assign ddr3write_en_r         = ddr3write_en;
assign Write_Fifo_full_r      = Write_Fifo_full;
assign clk_r                  = clk;
assign OnePeriod_flag_r       = OnePeriod_flag;
assign ddr3_oneperiod_flag_r  = ddr3_oneperiod_flag;
assign PeriodPoint_num_r      = PeriodPoint_num;
assign app_wdf_data_r         = app_wdf_data;
assign CountWrite_tem_r       = CountWrite_tem;
assign CountRead_tem_r        = CountRead_tem;



reg  [15:0]  app_rd_data11,app_rd_data12,app_rd_data13,app_rd_data14,
            app_rd_data15,app_rd_data16,app_rd_data17,app_rd_data18;


always@(posedge sys_clk_i) begin
    app_rd_data11 <= app_rd_data1;
    app_rd_data12 <= app_rd_data2;
    app_rd_data13 <= app_rd_data3;
    app_rd_data14 <= app_rd_data4;
    app_rd_data15 <= app_rd_data5;
    app_rd_data16 <= app_rd_data6;
    app_rd_data17 <= app_rd_data7;
    app_rd_data18 <= app_rd_data8;
end


(*mark_debug="true"*)wire              Extract_en;
(*mark_debug="true"*)wire  [15:0]      Monopulse_data1;
(*mark_debug="true"*)wire              FeatureExtraction_flag;
(*mark_debug="true"*)wire              FeatureExtraction_flag_reg;
(*mark_debug="true"*)wire  [15:0]      Pulse_point_num;
(*mark_debug="true"*)wire  [7:0]       Monopulse_data_01;
(*mark_debug="true"*)wire  [7:0]       Monopulse_data_00;
(*mark_debug="true"*)wire  [1:0]       WaveState;
(*mark_debug="true"*)wire  [7:0]       Monopulse_data_1;

/*********************************************/
(*mark_debug="true"*)wire  [15:0]      Front_area;
(*mark_debug="true"*)wire  [15:0]      Behind_area;
(*mark_debug="true"*)wire  [15:0]      Total_area;
(*mark_debug="true"*)wire  [15:0]      Total_area_reg;
(*mark_debug="true"*)wire  [7:0]       Peak_value;
(*mark_debug="true"*)wire  [23:0]      Second_moment;
(*mark_debug="true"*)wire  [32:0]      Third_moment;
(*mark_debug="true"*)wire  [40:0]      Fourth_moment;

(*mark_debug="true"*)wire  [15:0]      Monopulse_num;
(*mark_debug="true"*)wire  [15:0]      Monopulse_num_reg;
(*mark_debug="true"*)wire  [15:0]      Read_num; //从DDR2中读取的个数
(*mark_debug="true"*)wire  [7:0]       Mean_value;
(*mark_debug="true"*)wire  [7:0]       Mean_value_remainders;
(*mark_debug="true"*)wire  [20:0]      Square_data;
(*mark_debug="true"*)wire  [15:0]      ii;
(*mark_debug="true"*)wire  [2:0]       Arithmetic_State;
(*mark_debug="true"*)wire  [15:0]      Period_condition;
(*mark_debug="true"*)wire              Read_Over_flag;
(*mark_debug="true"*)wire  [31:0]      ReadPosition;
(*mark_debug="true"*)wire  [31:0]      MonopulsePosition;
(*mark_debug="true"*)wire  [15:0]      Count;
(*mark_debug="true"*)wire  [15:0]      time_cnt;
(*mark_debug="true"*)wire  [15:0]      time_cnt_n;
(*mark_debug="true"*)wire              Over_flag;
//assign Extract_en             = (Read_Fifo_rusdw_o==11'd0)?0:1;
assign Extract_en             = Read_Fifo_rden;
assign ReadPosition           = CountRead_tem*8 - Read_Fifo_rusdw_o;
MonopulseEx_Arithmetic MonopulseEx_Arithmetic1
(
  .Clk                               (clk_200),
  .Rst                               (!sys_rst),
  .Extract_en                        (Extract_en),
  .Period_count                      (Period_count),
  .Data_in                           (Read_Fifo_Out),
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
  .Peak_value                        (Peak_value), //最大��
  .Second_moment                     (Second_moment), //二阶��
  .Third_moment                      (Third_moment), //三阶��
  .Fourth_moment                     (Fourth_moment), //四阶��
  .Read_num                          (Read_num),
  .Mean_value                        (Mean_value),
  .Mean_value_remainders             (Mean_value_remainders),
  .ii                                (ii), 
  .Square_data                       (Square_data),
  .Total_area_reg                    (Total_area_reg),
  .Arithmetic_State                  (Arithmetic_State),
  .Read_Over_flag                    (Read_Over_flag),
  .time_cnt                          (time_cnt),
  .time_cnt_n                        (time_cnt_n),
  .Monopulse_num_reg                 (Monopulse_num_reg),
  .Over_flag                         (Over_flag)
  
);

wire              Extract_en_r;
wire  [9:0]       Monopulse_data1_r;
wire              FeatureExtraction_flag_r;
(*mark_debug="true"*)wire              FeatureExtraction_flag_reg_r;
wire  [15:0]      Pulse_point_num_r;
wire  [7:0]       Monopulse_data_01_r;
wire  [7:0]       Monopulse_data_00_r;
wire  [1:0]       WaveState_r;
wire  [7:0]       Monopulse_data_1_r;
wire  [15:0]      Count_r;

/*********************************************/
wire  [15:0]      Front_area_r;
wire  [15:0]      Behind_area_r;
wire  [15:0]      Total_area_r;
wire  [15:0]      Total_area_reg_r;
wire  [7:0]       Peak_value_r;
wire  [20:0]      Second_moment_r;
wire  [32:0]      Third_moment_r;
wire  [40:0]      Fourth_moment_r;

wire  [15:0]      Monopulse_num_r;
wire  [15:0]      Monopulse_num_reg_r;
wire  [15:0]      Read_num_r; //从DDR2中读取的个数
wire  [7:0]       Mean_value_r;
wire  [7:0]       Mean_value_remainders_r;
wire  [20:0]      Square_data_r;
wire  [5:0]       ii_r;
wire  [2:0]       Arithmetic_State_r;
wire  [15:0]      Period_condition_r;
wire              Read_Over_flag_r;
wire  [31:0]      ReadPosition_r;
wire  [31:0]      MonopulsePosition_r;
wire  [15:0]      time_cnt_r;
wire  [15:0]      time_cnt_n_r;
//wire              Over_flag_r;

assign Extract_en_r                   = Extract_en;
assign Monopulse_data1_r              = Monopulse_data1;
assign FeatureExtraction_flag_r       = FeatureExtraction_flag;
assign FeatureExtraction_flag_reg_r   = FeatureExtraction_flag_reg;
assign Pulse_point_num_r              = Pulse_point_num;
assign Monopulse_data_01_r            = Monopulse_data_01;
assign Monopulse_data_00_r            = Monopulse_data_00;
assign WaveState_r                    = WaveState;
assign Monopulse_data_1_r             = Monopulse_data_1;

/*********************************************/
assign Front_area_r                   = Front_area;
assign Behind_area_r                  = Behind_area;
assign Total_area_r                   = Total_area;
assign Total_area_reg_r               = Total_area_reg;
assign Peak_value_r                   = Peak_value;
assign Second_moment_r                = Second_moment;
assign Third_moment_r                 = Third_moment;
assign Fourth_moment_r                = Fourth_moment;

assign Monopulse_num_r                = Monopulse_num;
assign Read_num_r                     = Read_num; //从DDR2中读取的个数
assign Mean_value_r                   = Mean_value;
assign Mean_value_remainders_r        = Mean_value_remainders;
assign Square_data_r                  = Square_data;
assign ii_r                           = ii;
assign Arithmetic_State_r             = Arithmetic_State;
assign Period_condition_r             = Period_condition;
assign Read_Over_flag_r               = Read_Over_flag;
assign ReadPosition_r                 = ReadPosition;
assign MonopulsePosition_r            = MonopulsePosition;
assign Count_r                        = Count;
assign time_cnt_r                     = time_cnt;
assign time_cnt_n_r                   = time_cnt_n;
assign Monopulse_num_reg_r            = Monopulse_num_reg;


(*mark_debug="true"*)reg               SendToArm_begin;
(*mark_debug="true"*)reg               SendToArm_Over;
//(*mark_debug="true"*)reg [40:0]        SendToArm_Data;
(*mark_debug="true"*)reg [31:0]        SendToArm_Data;
(*mark_debug="true"*)reg [7:0]         SendToArm_Count;
(*mark_debug="true"*)reg               S_FeatureExtraction_flag_reg1;
(*mark_debug="true"*)reg               S_FeatureExtraction_flag_reg2;
(*mark_debug="true"*)wire              S_FeatureExtraction_flag_neg;
always@(posedge clk_200 or negedge sys_rst) begin
    if(sys_rst)
    begin
      S_FeatureExtraction_flag_reg1              <= 0;
      S_FeatureExtraction_flag_reg2              <= 0;      
    end
    else begin
      S_FeatureExtraction_flag_reg1              <= FeatureExtraction_flag_reg;
      S_FeatureExtraction_flag_reg2              <= S_FeatureExtraction_flag_reg1;
    end
  end
assign S_FeatureExtraction_flag_neg = (~S_FeatureExtraction_flag_reg1)&S_FeatureExtraction_flag_reg2;

always@(posedge clk_200 or negedge sys_rst) begin
    if(sys_rst)
    begin
      SendToArm_Data              <= 0;
      SendToArm_Count             <= 0;
      SendToArm_begin             <= 0;
      SendToArm_Over              <= 0;
    end
    else begin
      if(FeatureExtraction_flag_reg)begin
        SendToArm_begin           <= 1;
        SendToArm_Over            <= 0;
      end
      else begin
        SendToArm_begin           <= SendToArm_begin;
        SendToArm_Over            <= SendToArm_Over;
      end
      if(SendToArm_begin)begin
        SendToArm_Count           <= SendToArm_Count + 8'd1;
        case(SendToArm_Count)
          8'd0: SendToArm_Data    <= Period_condition;//16
          8'd1: SendToArm_Data    <= MonopulsePosition;//32
          8'd2: SendToArm_Data    <= Front_area;//16
          8'd3: SendToArm_Data    <= Behind_area;//16
          8'd4: SendToArm_Data    <= Total_area;//16
          8'd5: SendToArm_Data    <= Peak_value;//8
          8'd6: SendToArm_Data    <= Second_moment;//24
          8'd7: SendToArm_Data    <= Third_moment[31:0];//33
          8'd8: SendToArm_Data    <= Third_moment[32];//33
          8'd9: SendToArm_Data    <= Fourth_moment[31:0];//41
          8'd10: SendToArm_Data   <= Fourth_moment[40:32];//41
          8'd11: begin
                SendToArm_Data    <= Monopulse_num;//16
                SendToArm_begin   <= 0;
                SendToArm_Over    <= 1;
          end
          default: SendToArm_Data <= 0;
        endcase
      end
      else begin
          SendToArm_Count         <= 0;
          SendToArm_Data          <= 0;
      end
    end
  end  
endmodule

