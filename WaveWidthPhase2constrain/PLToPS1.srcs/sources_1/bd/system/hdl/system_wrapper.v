//Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2017.4 (win64) Build 2086221 Fri Dec 15 20:55:39 MST 2017
//Date        : Tue Nov  5 09:37:33 2019
//Host        : LAPTOP-85TPG7JI running 64-bit major release  (build 9200)
//Command     : generate_target system_wrapper.bd
//Design      : system_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module system_wrapper
   (


    inout [14:0]                        DDR_addr,
    inout [2:0]                         DDR_ba,
    inout                               DDR_cas_n,
    inout                               DDR_ck_n,
    inout                               DDR_ck_p,
    inout                               DDR_cke,
    inout                               DDR_cs_n,
    inout [3:0]                         DDR_dm,
    inout [31:0]                        DDR_dq,
    inout [3:0]                         DDR_dqs_n,
    inout [3:0]                         DDR_dqs_p,
    inout                               DDR_odt,
    inout                               DDR_ras_n,
    inout                               DDR_reset_n,
    inout                               DDR_we_n,
    inout                               FIXED_IO_ddr_vrn,
    inout                               FIXED_IO_ddr_vrp,
    inout  [53:0]                       FIXED_IO_mio,
    inout                               FIXED_IO_ps_clk,
    inout                               FIXED_IO_ps_porb,
    inout                               FIXED_IO_ps_srstb,
    output [0:0]                        GPIO_0_tri_o,
    output [0:0]                        GPIO2_0_tri_o,
    // inout  [0:0]                        GPIO2_0_tri_io,
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
   input                                rst_key,

   output                               SendIRQ   
    );

/********************************/
  wire [14:0]DDR_addr;
  wire [2:0]DDR_ba;
  wire DDR_cas_n;
  wire DDR_ck_n;
  wire DDR_ck_p;
  wire DDR_cke;
  wire DDR_cs_n;
  wire [3:0]DDR_dm;
  wire [31:0]DDR_dq;
  wire [3:0]DDR_dqs_n;
  wire [3:0]DDR_dqs_p;
  wire DDR_odt;
  wire DDR_ras_n;
  wire DDR_reset_n;
  wire DDR_we_n;
  wire FCLK_CLK0_0;
  wire FIXED_IO_ddr_vrn;
  wire FIXED_IO_ddr_vrp;
  wire [53:0]FIXED_IO_mio;
  wire FIXED_IO_ps_clk;
  wire FIXED_IO_ps_porb;
  wire FIXED_IO_ps_srstb;
  wire [0:0]GPIO2_0_tri_o;
  wire [0:0]GPIO_0_tri_o;
  wire [31:0]mem_a_0;
  wire [0:0]mem_cen_0;
  reg  [31:0]mem_dq_i_0;
  wire [31:0]mem_dq_o_0;
  wire [0:0]mem_oen_0;
  wire mem_wen_0;

//*************************************************************************
reg [31:0] data_reg1;
reg [31:0] data_reg2;
reg [31:0] data_reg3;
reg [31:0] data_reg4;
reg [31:0] data_reg5;
reg [31:0] data_reg6;
reg [31:0] data_reg7;
wire [15:0]mem_a32 = mem_a_0[17:2];

always @ (posedge FCLK_CLK0_0 or negedge rst_key)
if(!rst_key)begin
  data_reg1       <= 32'd0;
  data_reg2       <= 32'd0;
  data_reg3       <= 32'd0;
  data_reg4       <= 32'd0;
  data_reg5       <= 32'd0;
  data_reg6       <= 32'd0;
  data_reg7       <= 32'd0;
end
else if(mem_wen_0==1'b0)begin
    case(mem_a32)
     16'h0:begin
        data_reg1     <=mem_dq_o_0;
     end
     16'h1:begin
        data_reg2     <=mem_dq_o_0;
     end     
     16'h2:begin
        data_reg3     <=mem_dq_o_0;
     end   
     16'h3:begin
        data_reg4     <=mem_dq_o_0;
     end   
     16'd4:begin
        data_reg5     <=mem_dq_o_0;
     end   
     16'd5:begin
        data_reg6     <=mem_dq_o_0;
     end  
     16'd6:begin
        data_reg7     <=mem_dq_o_0;
     end                                         
    default : begin
      data_reg1     <= data_reg1;
      data_reg2     <= data_reg2;
      data_reg3     <= data_reg3;
      data_reg4     <= data_reg4;
      data_reg5     <= data_reg5;   
      data_reg6     <= data_reg6;
      data_reg7     <= data_reg7;        
    end   
  endcase
end
else begin
  data_reg1       <= data_reg1;
  data_reg2       <= data_reg2;
  data_reg3       <= data_reg3;
  data_reg4       <= data_reg4;
  data_reg5       <= data_reg5;
  data_reg6       <= data_reg6;
  data_reg7       <= data_reg7; 
end

//检测停止采样信号的上升沿
reg  data_reg5_1;
reg  data_reg5_2;
always @ (posedge FCLK_CLK0_0 or negedge rst_key)
if(!rst_key)begin
	data_reg5_1 		<= 0;
    data_reg5_2 		<= 0;
end
else begin
    data_reg5_1 		<= data_reg5;
    data_reg5_2 		<= data_reg5_1;
end

assign StopOrder 		= (!data_reg5_2) & data_reg5_1;

//检测开始采样信号的上升沿
wire SendOver_wire;
assign SendOver_wire 	= GPIO2_0_tri_o;

reg  SendOver_reg1;
reg  SendOver_reg2;
wire SendOver1;
always @ (posedge FCLK_CLK0_0 or negedge rst_key)
if(!rst_key)begin
	SendOver_reg1 		<= 0;
    SendOver_reg2 		<= 0;
end
else begin
    SendOver_reg1 		<= SendOver_wire;
    SendOver_reg2 		<= SendOver_reg1;
end

assign SendOver1 		= (!SendOver_reg2) & SendOver_reg1;


reg SendOver;
always @ (posedge FCLK_CLK0_0 or negedge rst_key) 
if(!rst_key)begin
	SendOver 			<= 0;
end
else if(FeatureExtraction_flag_reg)begin
    SendOver 			<= 0;
end
else if(SendOver1)begin
    SendOver 			<= SendOver1;
end                                                
else begin
    SendOver 			<= SendOver;
end

always @ (posedge FCLK_CLK0_0 or negedge rst_key)
if(!rst_key)begin
	mem_dq_i_0 			<= 32'd0;
end
else if(mem_oen_0==1'b0)begin
    case(mem_a32)
      16'd0:begin
         mem_dq_i_0 	<=Period_condition;
      end
      16'd1:begin
         mem_dq_i_0 	<=MonopulsePosition;
      end     
      16'd2:begin
         mem_dq_i_0 	<=Front_area;
      end   
      16'd3:begin
         mem_dq_i_0 	<=Behind_area;
      end   
      16'd4:begin
         mem_dq_i_0 	<=Total_area;
      end
      16'd5:begin
         mem_dq_i_0 	<=Peak_value;
      end     
      16'd6:begin
         mem_dq_i_0 	<=Second_moment;
      end   
      16'd7:begin
         mem_dq_i_0 	<=Third_moment[31:0];
      end          
      16'd8:begin
         mem_dq_i_0 	<=Third_moment[32];
      end
      16'd9:begin
         mem_dq_i_0 	<=Fourth_moment[31:0];
      end     
      16'd10:begin
         mem_dq_i_0 	<=Fourth_moment[40:32];
      end   
      16'd11:begin
         mem_dq_i_0 	<=Monopulse_num;
      end  
      16'd12:begin
         mem_dq_i_0 	<=ProcessNum;
      end 
      16'd13:begin
         mem_dq_i_0 	<=~SendOver;
      end        
      16'd14:begin
         mem_dq_i_0 	<=ProcessOver;
      end                             
      default : begin 
      	 mem_dq_i_0  	<= mem_dq_i_0;       
      end     
  endcase
end
else begin
	mem_dq_i_0  		<= mem_dq_i_0; 
end
//*************************************************************************
// wire [131:0] probe0;
// ila_0 ila_0 (
//   .clk(FCLK_CLK0_0), // input wire clk
//   .probe0(probe0) // input wire [99:0] probe0
// );
// assign probe0[31:0]=mem_a_0;
// assign probe0[63:32]=mem_dq_o_0;
// assign probe0[95:64]=mem_dq_i_0;
// assign probe0[96]=mem_cen_0;
// assign probe0[97]=mem_oen_0;
// assign probe0[98]=mem_wen_0;


// wire [0:0]  GPIO2_0_tri_io;
//   IOBUF GPIO2_0_tri_iobuf_0
//        (.I(GPIO2_0_tri_o_0),
//         .IO(GPIO2_0_tri_io[0]),
//         .O(GPIO2_0_tri_i_0),
//         .T(GPIO2_0_tri_t_0));
  system system_i
       (.DDR_addr(DDR_addr),
        .DDR_ba(DDR_ba),
        .DDR_cas_n(DDR_cas_n),
        .DDR_ck_n(DDR_ck_n),
        .DDR_ck_p(DDR_ck_p),
        .DDR_cke(DDR_cke),
        .DDR_cs_n(DDR_cs_n),
        .DDR_dm(DDR_dm),
        .DDR_dq(DDR_dq),
        .DDR_dqs_n(DDR_dqs_n),
        .DDR_dqs_p(DDR_dqs_p),
        .DDR_odt(DDR_odt),
        .DDR_ras_n(DDR_ras_n),
        .DDR_reset_n(DDR_reset_n),
        .DDR_we_n(DDR_we_n),
        .FCLK_CLK0_0(FCLK_CLK0_0),
        .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
        .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
        .FIXED_IO_mio(FIXED_IO_mio),
        .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),
        .GPIO2_0_tri_o(GPIO2_0_tri_o),
        .GPIO_0_tri_o(GPIO_0_tri_o),
        .SendIRQ(SendIRQ),
        .mem_a_0(mem_a_0),
        .mem_cen_0(mem_cen_0),
        .mem_dq_i_0(mem_dq_i_0),
        .mem_dq_o_0(mem_dq_o_0),
        .mem_oen_0(mem_oen_0),
        .mem_wen_0(mem_wen_0));



// /*******************AD*************************/
wire [7:0]                             adc_data;
wire                                   clk_250m; // 250MHz
/*****************************************************************
**********************AD采样*******************************
*****************************************************************/

IBUFDS
#(
    .DIFF_TERM    ("TRUE"), 
    .IBUF_LOW_PWR ("FALSE"),
    .IOSTANDARD   ("DEFAULT")
)
dac_clk_in 
(
    .I            (pld_clk_p),
    .IB           (pld_clk_n),
    
    .O            (clk_250m)
);

//-----------adc--------------
wire dco; // 125MHz
IBUFDS
#(
    .DIFF_TERM    ("TRUE"), 
    .IBUF_LOW_PWR ("FALSE"),
    .IOSTANDARD   ("DEFAULT")
)
adc_clk_in 
(
    .I            (dco_p),
    .IB           (dco_n),
    
    .O            (dco)
);

wire [9:0]        dac_data;
AD9481 AD9481_1
(
    .clk_250m                 (clk_250m), 
    .dco                      (dco),
    .pen                      (pen), 
    .pll_ce                   (pll_ce), 
    .pll_rst_n                (pll_rst_n), 
    .adc_pd                   (adc_pd), 
    .adc_p1                   (adc_p1),
    .adc_p2                   (adc_p2),
    .adc_data                 (adc_data),
    .dac_pll_locked           (dac_pll_locked),
    .dac_rst                  (dac_rst),
    .dac_p1                   (dac_p1),
    .dac_p2                   (dac_p2),
    .dac_data                 (dac_data)                  
);


wire  [31:0]              SendToArm_Data;
wire  [31:0]              MonopulsePosition;
wire  [15:0]              Front_area;
wire  [15:0]              Behind_area;
wire  [15:0]              Total_area;
wire  [7:0]               Peak_value;
wire  [23:0]              Second_moment;
wire  [32:0]              Third_moment;
wire  [40:0]              Fourth_moment;
wire  [15:0]              Monopulse_num;
wire  [15:0]              Period_condition;
wire                      FeatureExtraction_flag_reg;
wire                      StartSample;
wire                      SendToArm_begin;
wire  [9:0]               PulseNum;
wire  [3:0]               DDR_State;
wire                      ProcessOver;
wire  [7:0]               MonopulseExThreshould;
wire  [7:0]               MonopulseExHold;
wire  [7:0]               MonopulseMultiThreshould;
wire  [7:0]               MonopulseEndHold;
wire  [7:0]               GentalThreshould;
wire  [7:0]               GentalThreshouldNum;
wire                      StopOrder;


assign SendIRQ    = FeatureExtraction_flag_reg;
example_top example_top
  (
/*******************AD*************************/
    .adc_data                       (adc_data),
/*******************DDR3***********************/
   // Inouts
    .ddr3_dq                        (ddr3_dq),
    .ddr3_dqs_n                     (ddr3_dqs_n),
    .ddr3_dqs_p                     (ddr3_dqs_p),
    .ddr3_addr                      (ddr3_addr),
    .ddr3_ba                        (ddr3_ba),
    .ddr3_ras_n                     (ddr3_ras_n),
    .ddr3_cas_n                     (ddr3_cas_n),
    .ddr3_we_n                      (ddr3_we_n),
    .ddr3_reset_n                   (ddr3_reset_n),
    .ddr3_ck_p                      (ddr3_ck_p),
    .ddr3_ck_n                      (ddr3_ck_n),
    .ddr3_cke                       (ddr3_cke),   
    .ddr3_cs_n                      (ddr3_cs_n),  
    .ddr3_dm                        (ddr3_dm),   
    .ddr3_odt                       (ddr3_odt),
    .tg_compare_error               (tg_compare_error),
    .init_calib_complete            (init_calib_complete),
   
    .clk100m_i                      (clk100m_i),
    .FCLK_CLK0                      (FCLK_CLK0_0),
    .rst_key                        (rst_key),
    .SendToArm_Data                 (SendToArm_Data),
    .Period_condition               (Period_condition),
    .MonopulsePosition              (MonopulsePosition),
    .Monopulse_num                  (Monopulse_num),     //涓€涓懆鏈熷唴鍗曡剦鍐茬殑涓暟
    .Front_area                     (Front_area), //波前面积
    .Behind_area                    (Behind_area), //波后面积
    .Total_area                     (Total_area), //总面��
    .Peak_value                     (Peak_value), //最大��
    .Second_moment                  (Second_moment), //二阶��
    .Third_moment                   (Third_moment), //三阶��
    .Fourth_moment                  (Fourth_moment), //四阶��
    .clk_250m                       (clk_250m),
    .FeatureExtraction_flag_reg     (FeatureExtraction_flag_reg),
    .StartSample1                   (StartSample1),
    .SendToArm_begin                (SendToArm_begin),
    .PulseNum                       (PulseNum),
    .DDR_State                      (DDR_State),
    .SendOver                       (SendOver),
    .ProcessOver                    (ProcessOver),
    .ProcessNum                     (ProcessNum),
    .MonopulseExThreshould          (MonopulseExThreshould),
    .MonopulseExHold                (MonopulseExHold),
    .MonopulseMultiThreshould       (MonopulseMultiThreshould),
    .MonopulseEndHold               (MonopulseEndHold),
    .GentalThreshould               (GentalThreshould),
    .GentalThreshouldNum            (GentalThreshouldNum),
    .StopOrder                      (StopOrder)
   // System reset - Default polarity of sys_rst pin is Active Low.
   // System reset polarity will change based on the option 
   // selected in GUI.
   //input                                        sys_rst
   );

assign StartSample       			= GPIO_0_tri_o;
//检测开始采样信号的上升沿
reg  StartSample_reg1;
reg  StartSample_reg2;
wire StartSample1;
always @ (posedge FCLK_CLK0_0 or negedge rst_key)
if(!rst_key)begin
	StartSample_reg1 				<= 0;
    StartSample_reg2 				<= 0;
end
else begin
    StartSample_reg1 				<= StartSample;
    StartSample_reg2 				<= StartSample_reg1;
end

assign StartSample1                 = (!StartSample_reg2) & StartSample_reg1;
assign MonopulseExThreshould        = data_reg1[7:0];
assign MonopulseExHold              = data_reg2[7:0];
assign MonopulseMultiThreshould     = data_reg3[7:0];
assign MonopulseEndHold             = data_reg4[7:0];
assign GentalThreshould             = data_reg6[7:0];
assign GentalThreshouldNum          = data_reg7[7:0];
// assign StopOrder                    = data_reg5[0];
// assign GPIO2_0_tri_o_0   = ~SendOver;//SendToArm_begin;

endmodule






