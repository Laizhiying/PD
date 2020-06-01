`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/09/26 14:39:57
// Design Name: 
// Module Name: AD9481
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module AD9481
(
    input 			    clk_250m,  //为250Mhz
	
	output wire         pen, //LT1963A低压差线性稳压器的关闭功能引脚(|SHDN)，低电平有效，当引脚为低电平时稳压器不工作
	
	output wire 		pll_ce, //CDCM61004的控制使能，置1为使能
	output wire 		pll_rst_n, //低电平有效，低电平复位，高电平正常工作
	
	input 				dco, //AD输出数据输出时钟，DCO周期是CLK的2倍，DCO-(DCO_p)为正A输出，为负B输出。这俩差分信号互补
	input 		[7:0]	adc_p1,adc_p2, //AD输出的差分数据，两个差分输出根据DCO的来决定当前时刻哪个输出
	output wire 		adc_pd,  //FPGA置1设置AD为powerdown
    output reg  [7:0]   adc_data,  //将上面的差分输出结合为最后的输出                      
	
    input 				dac_pll_locked,
    output wire 		dac_rst,
    output reg  [9:0]  	dac_p1,dac_p2,
    output [9:0] 		dac_data
    // output				ad_joint_flag
	
);
assign pen = 1'b1;

// Put pll into normal status.
assign pll_ce = 1'b1;
assign pll_rst_n = 1'b1;

	

assign adc_pd = 1'b0;


always @(posedge clk_250m)
begin
    if (dco)
    begin	
        adc_data <= adc_p1;
    end
    else
    begin
        adc_data <= adc_p2;
    end
end
// reg	[127:0]			adc_joint_data;
// reg [4:0]			joint_count=0;
// always @(posedge clk_250m)
// begin
// 	joint_count <= joint_count + 5'd1;
// 	case(joint_count)
// 	5'd0,
//     if (joint_count < 5'd7)
//     begin	
//         adc_joint_data <= adc_data;
//     end
//     else
//     begin
//         adc_data <= adc_p2;
//     end
// end
//-----------dac--------------
reg [23:0] cnt;
always @(posedge clk_250m)
begin
   if(cnt<24'hffff)
   begin
       cnt <= cnt + 24'd1;
   end
   else
   begin 
       cnt <= cnt;
   end
end
   
assign dac_rst = (cnt == 24'hffff) ? 1'b0 : 1'b0;

reg up;
always @(posedge clk_250m)
begin
    if(dac_ramp==8'd0)
    begin
        up <= 1'b1;
    end
    else if(dac_ramp==8'd200)
    begin
        up <= 1'b0;
    end   
    else
    begin
        up <= up;
    end         
end        

reg [7:0] dac_ramp;
always @(posedge clk_250m)
begin
    if(up)
    begin
        dac_ramp <= dac_ramp + 8'b1;
    end
    else
    begin
        dac_ramp <= dac_ramp - 8'b1;
    end
end
    
wire [9:0] dac_data;
assign dac_data[7:0] = dac_ramp + 10'h20;
assign dac_data[9:8] = 2'b11;

          
reg phase_dac;
always @(posedge clk_250m)
begin
	phase_dac <= phase_dac + 1'b1;
end

wire [9:0] dac_data;
reg  [9:0] dac_p1_t,dac_p2_t;
always @(posedge clk_250m)
begin
	if (!phase_dac)
	begin	
		dac_p1_t <= dac_data;
	end
	else
	begin
		dac_p2_t <= dac_data;
	end
end	

always @(posedge clk_250m)
begin
	if(!dac_pll_locked)
	begin
		dac_p1 <= dac_p1_t;
		dac_p2 <= dac_p2_t;
	end
	else
	begin
		dac_p1 <= dac_p1;
		dac_p2 <= dac_p2;
	end
end
//-----------ila--------------
//ila_1 adc_ila
//(
//    .clk		(clk_200m),
    
//    .probe0		(adc_data),
//    .probe1		(adc_p1),
//    .probe2		(adc_p2),
//    .probe3		(dco)
//);
// ila_ad ila_ad (
//     .clk		(clk_200m),
    
//     .probe0		(adc_data),
//     .probe1		(adc_p1),
//     .probe2		(adc_p2),
//     .probe3		(dco)
// );

    
endmodule

