module Arithmetic1
(
	Clk_arithmetic,
	Rst,
	Monopulse_data_in, //???¨¨?¡ë??????ddr2???¨¨????????
	Monopulse_num, //???¨¨?¡ë???????????¡ã???ddr2????????????
	Front_area, //????¡ë?¨¦???¡ì?
	Behind_area, //??????¨¦???¡ì?
	Total_area, //?¢ã?¨¦????????
	Peak_value, //????¡è¡ì??????
	Second_moment, //???¨¦????????
	Third_moment, //??¡ë¨¦????????
	Fourth_moment, //???¨¦????????
	Read_num,
	Mean_value,
	Mean_value_remainders,
	ii,
	Square_data,
	FeatureExtraction_flag,			//?¡ã??????-??????¨¨?¡ë???????????¡ã?????????¨¨?¡ë???¨¦??? ¡¤???¨¦¢ã?????¡ë?????????-
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

input  	  	[15:0]			Monopulse_data_in; //??????¨¨?¡ë????¡§???-¨¨??????????¡ã???
input 						Rst;

output reg					FeatureExtraction_flag_reg;
reg					        FeatureExtraction_flag_reg_reg;
output reg 	[15:0]			Monopulse_num;
output reg 	[15:0]			Front_area;
output reg 	[15:0]			Behind_area;
output reg 	[15:0]			Total_area;
output reg 	[7:0]			Peak_value;
output reg 	[23:0]			Second_moment;
output reg 	[32:0]			Third_moment; //修改数据宽度后，下面的cube_data和cube_data_n的数据宽度也需要修改
output reg 	[40:0]			Fourth_moment;
output reg  				Read_Over_flag;
reg  						Read_Over_flag_reg; 
output 						Over_flag;


reg 		[7:0] 			Monopulse_data [0:250];
output reg 	[15:0] 			Read_num; //???DDR2???¨¨????-????????¡ã
output reg 	[2:0] 			Arithmetic_State;
reg 		[2:0] 			Arithmetic_State_reg;
reg 		[7:0]			Peak_value_reg;
reg 		[15:0]			Front_area_reg;
reg 		[15:0]			Behind_area_reg;
output reg 	[15:0]			Total_area_reg; 
output reg 	[7:0] 			Mean_value; //?????????
reg			[7:0] 			Mean_value_reg;
output reg 	[7:0] 			Mean_value_remainders; //?????????
reg 		[7:0] 			Mean_value_remainders_reg;
output reg	[15:0]			time_cnt;			//?????????¨¦???¡À?¨¨????¡ã??????
output reg	[15:0]			time_cnt_n;			//time_cnt?????????????????????
output reg	[15:0]			Monopulse_num_reg;
reg 		[15:0] 			Read_num_reg;
wire						FeatureExtraction_flag_n;
//output 		[15:0] 			Period_flag;

assign FeatureExtraction_flag_n = FeatureExtraction_flag;
assign Over_flag 				= FeatureExtraction_flag_reg;
reg 			time_clear;
reg 			time_clear_reg;
reg             start_count;
reg             start_count_reg;
/* ?-?????"?¨¨¡¤?,?"¡§??????Arithmetic_State????????¡§¨¨????????*/
always @ (posedge Clk_arithmetic or negedge Rst)
begin
	if(!Rst)begin
		Arithmetic_State 				<= IDLE;
		Monopulse_num 					<= 0;
		Read_Over_flag 					<= 0;
		time_clear 						<= 0;
		FeatureExtraction_flag_reg      <= 0;
		start_count                     <= 0;
	end
	else begin
		Arithmetic_State				<= Arithmetic_State_reg;
		Monopulse_num 					<= Monopulse_num_reg;
		Read_Over_flag 					<= Read_Over_flag_reg;
		time_clear 						<= time_clear_reg;
		FeatureExtraction_flag_reg      <= FeatureExtraction_flag_reg_reg;
		start_count                     <= start_count_reg;
	end
end
//???????"?¨¨¡¤?
always @ (*)
begin
	case(Arithmetic_State)
		IDLE:begin
			FeatureExtraction_flag_reg_reg 	<= 0;
            Monopulse_num_reg               <= Monopulse_num; 
            Read_Over_flag_reg              <= 0;
            Arithmetic_State_reg         	<= (FeatureExtraction_flag_n)&&(!FeatureExtraction_flag_reg)?Start:IDLE;
            //Arithmetic_State_reg         	<= (!FeatureExtraction_flag_n)?IDLE:((start_count)?Start:IDLE);
            time_clear_reg                 	<= (!FeatureExtraction_flag_n)?1:0;
            start_count_reg             	<= (!FeatureExtraction_flag_n)&&(FeatureExtraction_flag_reg)?0:((start_count)?0:1);

		end
		Start:begin
			Monopulse_num_reg 				<= (time_cnt == 0)?Monopulse_data_in:Monopulse_num;
			Arithmetic_State_reg 			<= ((time_cnt != 0)&&(time_cnt >= Monopulse_num+2))?Read_Over:Arithmetic_State;
			Read_Over_flag_reg 				<= ((time_cnt != 0)&&(time_cnt >= Monopulse_num+2))?1:0;
			time_clear_reg 	 				<= ((time_cnt != 0)&&(time_cnt >= Monopulse_num+2))?1:0;
			FeatureExtraction_flag_reg_reg  <= 0;

		end
		Read_Over:begin
			Arithmetic_State_reg 		    <= (time_cnt == 0)?Mean_Over:Arithmetic_State;
			Monopulse_num_reg 			    <= Monopulse_num;
			time_clear_reg 				    <= (time_cnt == 0)?1:0;
			Read_Over_flag_reg              <= 0;
			FeatureExtraction_flag_reg_reg  <= 0;
		end

		Mean_Over:begin
            Arithmetic_State_reg	 	    <= (time_cnt >= (Monopulse_num+8))?IDLE:Arithmetic_State;
            FeatureExtraction_flag_reg_reg  <= (time_cnt >= (Monopulse_num+8))?1:0;
            Read_Over_flag_reg              <= (time_cnt >= (Monopulse_num+8))?0:Read_Over_flag;
            Monopulse_num_reg               <= Monopulse_num;
            time_clear_reg                  <= (time_cnt >= (Monopulse_num+8))?1:0;

		end
		default: Arithmetic_State_reg 		<= IDLE;
	endcase	
end		

reg [15:0] 			Read_num_n;		
/* ?-?????"?¨¨¡¤?,?"¡§??????time_cnt????????¡§¨¨????????*/
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


/* ???????"?¨¨¡¤?,?"¡§????"????????????????¨¦???¡À?¨¨????¡ã??¡§ */
always @ (*)
begin
	case(Arithmetic_State)	
		IDLE:begin
			time_cnt_n 		<= 16'h0;
		end
		Start:begin
			time_cnt_n 		<= time_cnt + 16'h1;
		end
		Read_Over:
			time_cnt_n 		<= time_clear?16'h0:(time_cnt + 16'h1);
		Mean_Over:
			time_cnt_n 		<= time_clear?16'h0:(time_cnt + 16'h1);
		default: time_cnt_n 	<= 16'h0;			
	endcase
end
/* ???????"?¨¨¡¤?,? ????????????????¨¨????¡ã??¡§???jisuan */
reg 		[15:0]		Monopulse_num_half;
reg 		[15:0]		Monopulse_num_half_reg;
output reg 	[15:0]		ii;
reg			[10:0]		SubtractionMean_data1;
reg			[10:0]		SubtractionMean_data2;
reg 		[9:0] 		SubtractionMean_data_n;
output reg 	[20:0] 		Square_data;
reg 		[32:0] 		Cube_data;
reg 		[31:0] 		Cube_data_n;
reg 		[40:0] 		Biquadrate_data;
reg						Sign_bit1;
reg						Sign_bit2;
reg						Sign_bit3;

always @ (posedge Clk_arithmetic or negedge Rst)
begin
	if(!Rst)begin
		Total_area 					<= 0;
		Front_area 					<= 0;
		Behind_area 				<= 0;
		Total_area 					<= 0;
		Peak_value 					<= 0;
	end
	else begin
		Total_area 					<= Total_area_reg;
		Peak_value 			   		<= Peak_value_reg;
		Front_area					<= Front_area_reg;
		Behind_area 				<= Behind_area_reg;
		Mean_value_remainders 		<= Mean_value_remainders_reg;
		Monopulse_num_half 	 		<= Monopulse_num_half_reg;
		Mean_value 					<= Mean_value_reg;
	end
end

always @ (*)
begin
	case(Arithmetic_State)	
	IDLE:begin
		Peak_value_reg 			   			<= Peak_value;
		Front_area_reg 						<= Front_area;
		Behind_area_reg 					<= Behind_area;
		Total_area_reg 						<= Total_area;
		Mean_value_reg 						<= Mean_value;
		Mean_value_remainders_reg 			<= Mean_value_remainders;
		Monopulse_num_half_reg				<= Monopulse_num_half;
	end
	Start:begin
		Monopulse_data[time_cnt-2] 			<= ((time_cnt>=2)&&(Monopulse_num!=0))?Monopulse_data_in:Monopulse_data[time_cnt-2];
		Peak_value_reg 			   			<= (time_cnt==0)?0:(((time_cnt>=2)&&(Monopulse_num!=0)&&(Monopulse_data_in>Peak_value))?Monopulse_data_in:Peak_value);
		Front_area_reg 						<= (time_cnt==0)?0:(((time_cnt>=2)&&(Monopulse_num!=0)&&(Monopulse_data_in>Peak_value))?(Front_area + Behind_area + Monopulse_data_in):Front_area);
		Behind_area_reg 					<= (time_cnt==0)?0:((time_cnt>=2)&&(Monopulse_num!=0)?((Monopulse_data_in>Peak_value)?0:(Behind_area + Monopulse_data_in)):Behind_area);
		Total_area_reg 						<= (time_cnt==0)?0:((time_cnt>=2)&&(Monopulse_num!=0)?(Total_area + Monopulse_data_in):Total_area);
	end
	Read_Over:begin
		Peak_value_reg 			   			<= Peak_value;
		Front_area_reg 						<= Front_area;
		Behind_area_reg 					<= Behind_area;
		Total_area_reg 						<= Total_area;
		Mean_value_reg 						<= (Mean_value_remainders > Monopulse_num_half)?((Total_area/Monopulse_num)+1):(Total_area/Monopulse_num);
		Mean_value_remainders_reg 			<= Total_area%Monopulse_num;
		Monopulse_num_half_reg 				<= Monopulse_num>>1;
	end
	default:begin
		Peak_value_reg 			   			<= Peak_value;
		Front_area_reg 						<= Front_area;
		Behind_area_reg 					<= Behind_area;
		Total_area_reg 						<= Total_area;
		Mean_value_remainders_reg 			<= Mean_value_remainders;
		Monopulse_num_half_reg				<= Monopulse_num_half;
	end	
	endcase
end		

always @ (posedge Clk_arithmetic or negedge Rst)
if(!Rst)begin
		Second_moment 			<= 0;
		Third_moment 			<= 0;
		Fourth_moment 			<= 0;
		SubtractionMean_data1 	<= 0;
		SubtractionMean_data2 	<= 0;
	end
else begin
	case(Arithmetic_State)	
	IDLE:begin
		Second_moment 					<= Second_moment;
		Third_moment 					<= Third_moment;
		Fourth_moment 					<= Fourth_moment;
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
	Start:begin
		Second_moment 					<= 0;
		Third_moment 					<= 0;
		Fourth_moment 					<= 0;
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
	Read_Over:begin
		Second_moment 					<= 0;
		Third_moment 					<= 0;
		Fourth_moment 					<= 0;
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
	Mean_Over:begin
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
		Cube_data_n 					<= Square_data * SubtractionMean_data2;//??????????????
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


endmodule
