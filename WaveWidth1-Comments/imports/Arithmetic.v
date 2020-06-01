module Arithmetic
(
	Clk_arithmetic,
	Rst,
	Monopulse_data_in, //单脉冲从ddr2中读��
	Monopulse_num, //单脉冲的个数从ddr2中提��
	Front_area, //波前面积
	Behind_area, //波后面积
	Total_area, //总面��
	Peak_value, //最大��
	Second_moment, //二阶��
	Third_moment, //三阶��
	Fourth_moment, //四阶��
	Read_num,
	Mean_value,
	Mean_value_remainders,
	ii,
	Square_data,
	FeatureExtraction_flag,			//将提取的单脉冲的个数以及单脉冲采样点送去特征提取
	FeatureExtraction_flag_reg,
	Total_area_reg,
	Arithmetic_State,
	Read_Over_flag,
	time_cnt,
	time_cnt_n,
	Monopulse_num_reg,
	Over_flag
//	Period_flag
	
);

parameter 		IDLE = 3'd0,
//				Begin = 3'd1,
				Start = 3'd1,
				Read_Over = 3'd2,
				Mean_Over = 3'd3,
				Subtraction_Over = 3'd4,
				Multiple_Over = 3'd5;
			 
input						Clk_arithmetic;			 
input 						FeatureExtraction_flag;

input  	  	[15:0]			Monopulse_data_in; //从单脉冲模块过来的数据
input 						Rst;

output reg					FeatureExtraction_flag_reg;
output reg 	[15:0]			Monopulse_num;
output reg 	[15:0]			Front_area;
output reg 	[15:0]			Behind_area;
output reg 	[15:0]			Total_area;
output reg 	[7:0]			Peak_value;
output reg 	[23:0]			Second_moment;
output reg 	[31:0]			Third_moment;
output reg 	[40:0]			Fourth_moment;
output reg  				Read_Over_flag;
reg  						Read_Over_flag_reg; 
output 						Over_flag;


reg 		[7:0] 			Monopulse_data [0:250];
output reg 	[15:0] 			Read_num; //从DDR2中读取的个数
output reg 	[2:0] 			Arithmetic_State;
reg 		[2:0] 			Arithmetic_State_reg;
reg 		[7:0]			Peak_value_reg;
//reg [5:0]	Peak_site;
reg 		[15:0]			Front_area_reg;
reg 		[15:0]			Behind_area_reg;
output reg 	[15:0]			Total_area_reg; 
output reg 	[7:0] 			Mean_value; //均��
reg			[7:0] 			Mean_value_reg;
output reg 	[7:0] 			Mean_value_remainders; //均��
output reg	[15:0]			time_cnt;			//状态机附属计数��
output reg	[15:0]			time_cnt_n;			//time_cnt的下一个状��
output reg	[15:0]			Monopulse_num_reg;
reg 		[15:0] 			Read_num_reg;
wire						FeatureExtraction_flag_n;
//output 		[15:0] 			Period_flag;

assign FeatureExtraction_flag_n = FeatureExtraction_flag;
assign Over_flag 				= FeatureExtraction_flag_reg;

/* 时序电路,用来给Arithmetic_State寄存器赋��*/
always @ (posedge Clk_arithmetic or negedge Rst)
begin
	if(!Rst)begin
		Arithmetic_State 				<= IDLE;
		Monopulse_num 					<= 0;
		Read_Over_flag 					<= 0;
	end
	else begin
		Arithmetic_State				<= Arithmetic_State_reg;
		Monopulse_num 					<= Monopulse_num_reg;
		Read_Over_flag 					<= Read_Over_flag_reg;
	end
end
//组合电路
always @ (*)
begin
	// if(!Rst)begin
	// 	Arithmetic_State_reg 				<= IDLE;
	// 	Monopulse_num_reg 					<= 0;
	// 	Read_Over_flag_reg 					<= 0;
	// end
	// else 
	case(Arithmetic_State)
		IDLE:begin
			FeatureExtraction_flag_reg 		<= 0;
			Monopulse_num_reg 				<= 0;
			if(!FeatureExtraction_flag_n)begin
				Arithmetic_State_reg 		<= IDLE;
			end
			else if(time_cnt == 16'd2)begin
				Arithmetic_State_reg 		<= Start;
			end
			else begin
				Arithmetic_State_reg 		<= IDLE;
			end
		end
		Start:begin
			if(time_cnt == 0)begin 	//读取第一个数据，为本次单脉冲的个��
				Monopulse_num_reg 			<= Monopulse_data_in;
			end
			else if(time_cnt == Monopulse_num)begin
				Arithmetic_State_reg 		<= Read_Over;
				Monopulse_num_reg 			<= Monopulse_num;
				Read_Over_flag_reg 			<= 1;
			end
			else begin
				Arithmetic_State_reg 		<= Arithmetic_State;
				Monopulse_num_reg 			<= Monopulse_num;
			end
		end
		Read_Over:
			if(time_cnt == 16'd3)begin
				Arithmetic_State_reg 		<= Mean_Over;
				Monopulse_num_reg 			<= Monopulse_num;
			end
			else begin
				Arithmetic_State_reg 		<= Arithmetic_State;
				Monopulse_num_reg 			<= Monopulse_num;
			end
		Mean_Over:
			if(time_cnt == Monopulse_num+8)begin
				Arithmetic_State_reg	 	<= IDLE;
				FeatureExtraction_flag_reg 	<= 1;
				Read_Over_flag_reg			<= 0;
				Monopulse_num_reg 			<= 0;
			end
			else begin
				Arithmetic_State_reg 		<= Arithmetic_State;
				Monopulse_num_reg			<= Monopulse_num;
			end
		default: Arithmetic_State_reg 		<= IDLE;
	endcase	
end		

reg [15:0] 			Read_num_n;		
/* 时序电路,用来给time_cnt寄存器赋��*/
always @ (posedge Clk_arithmetic or negedge Rst)
begin
	if(!Rst)begin
		//Read_num <= 16'd0;
		time_cnt <= 16'h0;
	end
	else begin
		//Read_num <= Read_num_n;
		time_cnt <= time_cnt_n;
	end
end

/* 组合电路,用来生成状态机的附属计数器 */
always @ (*)
begin
	case(Arithmetic_State)	
		IDLE:begin
			//Read_num_n 			<= 0;
			if(time_cnt == 16'd2)
				time_cnt_n 		<= 16'h0;
			else
				time_cnt_n 		<= time_cnt + 16'h1;
		end
		Start:begin
			//Read_num_n 			<= Read_num + 1;
			if(time_cnt == Monopulse_num)
				time_cnt_n 		<= 16'h0;
			else
				time_cnt_n 		<= time_cnt + 16'h1;
		end
		Read_Over:
			if(time_cnt == 16'd3)
				time_cnt_n 		<= 16'h0;
			else
				time_cnt_n 		<= time_cnt + 16'h1;
		Mean_Over:
			if(time_cnt == Monopulse_num+8)
				time_cnt_n 		<= 16'h0;
			else
				time_cnt_n 		<= time_cnt + 16'h1;
		default: time_cnt_n 	<= 16'h0;			
	endcase
end

/* 组合电路,根据状态机与计数器来jisuan */
reg 		[15:0]		Monopulse_num_half;
output reg 	[15:0]		ii;
reg			[10:0]		SubtractionMean_data1;
reg			[10:0]		SubtractionMean_data2;
reg 		[9:0] 		SubtractionMean_data_n;
output reg 	[20:0] 		Square_data;
reg 		[31:0] 		Cube_data;
reg 		[30:0] 		Cube_data_n;
reg 		[40:0] 		Biquadrate_data;
reg						Sign_bit1;
reg						Sign_bit2;
reg						Sign_bit3;

always @ (*)
begin
	if(!Rst)begin
		Total_area <= 0;
	end
	else 
	if(Arithmetic_State == Mean_Over)begin
		Total_area <= 0;
	end
	else
		Total_area <= Total_area_reg;
end

always @ (posedge Clk_arithmetic or negedge Rst)
if(!Rst)begin
		Read_num 				<= 0;
		Front_area_reg 			<= 0;
		Behind_area_reg 		<= 0;
		Total_area_reg 			<= 0;
		Peak_value_reg 			<= 0;
		Second_moment 			<= 0;
		Third_moment 			<= 0;
		Fourth_moment 			<= 0;
		Mean_value 				<= 0;
		Mean_value_remainders 	<= 0;
		Monopulse_num_half 		<= 0;
		SubtractionMean_data1 	<= 0;
		SubtractionMean_data2 	<= 0;
	end
else begin
	case(Arithmetic_State)	
		IDLE:begin
			Total_area_reg 						<= 0;
			Read_num 							<= 0;
		end
		Start:begin
			Read_num 							<= Read_num + 1;
			if((time_cnt!=0)&&(time_cnt!=0))begin	
				Monopulse_data[time_cnt-1] 		<= Monopulse_data_in;
				Peak_value_reg 			   		<= Monopulse_data_in;
				Front_area_reg 					<= Front_area;
				Behind_area_reg 				<= Behind_area + Monopulse_data_in;
				Total_area_reg 					<= Total_area + Monopulse_data_in;
			end
			// else begin
			// 	Peak_value_reg 			   		<= Peak_value_n;
			// 	Front_area_reg 					<= Front_area;
			// 	Behind_area_reg 				<= Behind_area;
			// 	Total_area_reg 					<= Total_area;
			// end
		end
		Read_Over:
			if(time_cnt == 16'h0)begin
				Mean_value_reg 					<= 0;
				Mean_value 						<= 0;
				Mean_value_remainders 			<= 0;
				Monopulse_num_half 				<= 0;
				Total_area_reg 					<= Total_area_reg;
				Peak_value 						<= Peak_value_n;
			end
			else begin
				Total_area_reg			 		<= Total_area_reg;
				Mean_value_reg 					<= Total_area/Monopulse_num;
				Mean_value_remainders 			<= Total_area%Monopulse_num;
				Monopulse_num_half 				<= Monopulse_num>>1;
				if(Mean_value_remainders > Monopulse_num_half)
					Mean_value 					<= Mean_value_reg + 1;
				else
					Mean_value 					<= Mean_value_reg;
			end
		Mean_Over:
			if(time_cnt == 16'h0)begin			
				Second_moment 					<= 0;
				Third_moment 					<= 0;
				Fourth_moment 					<= 0;
				//Read_num 						<= 0;
				Front_area_reg 					<= 0;
				Behind_area_reg 				<= 0;
				ii 								<= 0;
				SubtractionMean_data_n 			<= 0;
				Cube_data_n 					<= 0;
				Square_data		 				<= 0;
				Biquadrate_data 				<= 0;
				Cube_data 						<= 0;
				Biquadrate_data 				<= 0;
				Sign_bit1 						<= 0;
				Sign_bit2 						<= 0;
				Sign_bit3 						<= 0;
				SubtractionMean_data1 			<= 0;
				SubtractionMean_data2 			<= 0;
			end
			else begin
				if(ii<Monopulse_num)
					SubtractionMean_data_n 		<= Monopulse_data[ii] - Mean_value;
				else
					SubtractionMean_data_n 		<= SubtractionMean_data_n;
					
				SubtractionMean_data1 			<= SubtractionMean_data_n[9]?{1'b0,(~SubtractionMean_data_n)+1'd1}:{1'd0,SubtractionMean_data_n};
				SubtractionMean_data2 			<= SubtractionMean_data1;
				Sign_bit1 						<= SubtractionMean_data_n[9]?1:0;
				Sign_bit2 						<= Sign_bit1;
				Sign_bit3 						<= Sign_bit2;
				Square_data 					<= SubtractionMean_data1 * SubtractionMean_data1;
				Cube_data_n 					<= Square_data * SubtractionMean_data2;//��һ��
				Cube_data 						<= Sign_bit3?{1'b1,(~Cube_data_n)+1'd1}:{1'd0,Cube_data_n};
				Biquadrate_data 				<= Square_data * Square_data;
				if(ii<Monopulse_num+3)
					Second_moment 				<= Square_data + Second_moment;
				else
					Second_moment 				<= Second_moment;
				if(ii<Monopulse_num+5)
					Third_moment 				<= Cube_data + Third_moment;
				else
					Third_moment 				<= Third_moment;
				if(ii<Monopulse_num+4)
					Fourth_moment 				<= Biquadrate_data + Fourth_moment;
				else
					Fourth_moment 				<= Fourth_moment;
				ii <= ii+1;
			end
		default:	;		
	endcase
end
/*
always @ (posedge Clk_arithmetic or negedge Rst)
if(!Rst)begin
		Read_num 				<= 0;
		Front_area_reg 			<= 0;
		Behind_area_reg 		<= 0;
		Total_area_reg 			<= 0;
		Peak_value_reg 			<= 0;
		Second_moment 			<= 0;
		Third_moment 			<= 0;
		Fourth_moment 			<= 0;
		Mean_value 				<= 0;
		Mean_value_remainders 	<= 0;
		Monopulse_num_half 		<= 0;
		SubtractionMean_data1 	<= 0;
		SubtractionMean_data2 	<= 0;
	end
else begin
	case(Arithmetic_State)	
		IDLE:begin
			Total_area_reg 						<= 0;
			Read_num 							<= 0;
		end
		Start:begin
			Read_num 							<= Read_num + 1;
			if((time_cnt!=0)&&(time_cnt!=0))begin	
				Monopulse_data[time_cnt-1] 		<= Monopulse_data_in;
				Peak_value_reg 			   		<= Monopulse_data_in;
				Front_area_reg 					<= Front_area;
				Behind_area_reg 				<= Behind_area + Monopulse_data_in;
				Total_area_reg 					<= Total_area + Monopulse_data_in;
			end
			else begin
				Peak_value_reg 			   		<= Peak_value_n;
				Front_area_reg 					<= Front_area;
				Behind_area_reg 				<= Behind_area;
				Total_area_reg 					<= Total_area;
			end
		end
		Read_Over:
			if(time_cnt == 16'h0)begin
				Mean_value_reg 					<= 0;
				Mean_value 						<= 0;
				Mean_value_remainders 			<= 0;
				Monopulse_num_half 				<= 0;
				Total_area_reg 					<= Total_area_reg;
				Peak_value 						<= Peak_value_n;
			end
			else begin
				Total_area_reg			 		<= Total_area_reg;
				Mean_value_reg 					<= Total_area/Monopulse_num;
				Mean_value_remainders 			<= Total_area%Monopulse_num;
				Monopulse_num_half 				<= Monopulse_num>>1;
				if(Mean_value_remainders > Monopulse_num_half)
					Mean_value 					<= Mean_value_reg + 1;
				else
					Mean_value 					<= Mean_value_reg;
			end
		Mean_Over:
			if(time_cnt == 16'h0)begin			
				Second_moment 					<= 0;
				Third_moment 					<= 0;
				Fourth_moment 					<= 0;
				//Read_num 						<= 0;
				Front_area_reg 					<= 0;
				Behind_area_reg 				<= 0;
				ii 								<= 0;
				SubtractionMean_data_n 			<= 0;
				Cube_data_n 					<= 0;
				Square_data		 				<= 0;
				Biquadrate_data 				<= 0;
				Cube_data 						<= 0;
				Biquadrate_data 				<= 0;
				Sign_bit1 						<= 0;
				Sign_bit2 						<= 0;
				Sign_bit3 						<= 0;
				SubtractionMean_data1 			<= 0;
				SubtractionMean_data2 			<= 0;
			end
			else begin
				if(ii<Monopulse_num)
					SubtractionMean_data_n 		<= Monopulse_data[ii] - Mean_value;
				else
					SubtractionMean_data_n 		<= SubtractionMean_data_n;
					
				SubtractionMean_data1 			<= SubtractionMean_data_n[9]?{1'b0,(~SubtractionMean_data_n)+1'd1}:{1'd0,SubtractionMean_data_n};
				SubtractionMean_data2 			<= SubtractionMean_data1;
				Sign_bit1 						<= SubtractionMean_data_n[9]?1:0;
				Sign_bit2 						<= Sign_bit1;
				Sign_bit3 						<= Sign_bit2;
				Square_data 					<= SubtractionMean_data1 * SubtractionMean_data1;
				Cube_data_n 					<= Square_data * SubtractionMean_data2;//��һ��
				Cube_data 						<= Sign_bit3?{1'b1,(~Cube_data_n)+1'd1}:{1'd0,Cube_data_n};
				Biquadrate_data 				<= Square_data * Square_data;
				if(ii<Monopulse_num+3)
					Second_moment 				<= Square_data + Second_moment;
				else
					Second_moment 				<= Second_moment;
				if(ii<Monopulse_num+5)
					Third_moment 				<= Cube_data + Third_moment;
				else
					Third_moment 				<= Third_moment;
				if(ii<Monopulse_num+4)
					Fourth_moment 				<= Biquadrate_data + Fourth_moment;
				else
					Fourth_moment 				<= Fourth_moment;
				ii <= ii+1;
			end
		default:	;		
	endcase
end
*/
reg 	[7:0]			Peak_value_n;
//得到最大值及其位��
//always @ (posedge Clk_arithmetic or negedge Rst)
always @(Rst or Peak_value_reg or Arithmetic_State)
if(!Rst)begin
	Peak_value_n 			<= 0;
	Front_area 				<= 0;
	Behind_area 			<= 0;
end
else begin
	if((Peak_value_n < Peak_value_reg)&&(Arithmetic_State == Start))begin
		Peak_value_n 		<= Peak_value_reg;
		Front_area 			<= Front_area_reg + Behind_area_reg;
		Behind_area 		<= 0;
	end
	else if(Arithmetic_State == Mean_Over)begin
		Front_area 			<= 0;
		Behind_area 		<= 0;
		Peak_value_n 		<= 0;
	end
	else begin
		Peak_value_n 		<= Peak_value_n;
		Behind_area 		<= Behind_area_reg;		
	end
end


endmodule
