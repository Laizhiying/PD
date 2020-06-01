module Arithmetic1
(
	Clk_arithmetic,
	clk_arith,
	Rst,
	Monopulse_data_in, //???¨¨?¡ë??????ddr2???¨¨????????
	GentalThreshould,
	Monopulse_num, //???¨¨?¡ë???????????¡ã???ddr2????????????
	Front_area, //????¡ë?¨¦???¡ì?
	Behind_area, //??????¨¦???¡ì?
	Total_area, //?¢ã?¨¦????????
	Total_area_reg,
	// Front_Width,
	// Behind_Width,
	// Total_Width,
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
	Arithmetic_State,
	// Read_Over_flag,
	time_cnt,
	time_cnt_n,
	Monopulse_num_reg,
	Over_flag
//	Period_flag
	
);

parameter 		IDLE1 = 3'd0,
				IDLE2 = 3'd1,
				Begin = 3'd3,
				Start = 3'd2,
				Total_Over = 3'd6,
				Remainder_Over = 3'd7,
				Mean_Over = 3'd5,
				Multiple_Over = 3'd4;
			 
input						Clk_arithmetic;	
input 						clk_arith;		 
input 						FeatureExtraction_flag;

input  	  	[15:0]			Monopulse_data_in; //??????¨¨?¡ë????¡§???-¨¨??????????¡ã???
input 						Rst;
input 		[7:0] 			GentalThreshould;

output reg					FeatureExtraction_flag_reg;
reg					        FeatureExtraction_flag_reg_reg;
output reg 	[15:0]			Monopulse_num;
output reg 	[15:0]			Front_area;
output reg 	[15:0]			Behind_area;
output reg 	[15:0]			Total_area;
reg 	[15:0]			Front_Width;
reg 	[15:0]			Behind_Width;
reg 	[15:0]			Total_Width;
output reg 	[7:0]			Peak_value;
output reg 	[23:0]			Second_moment;
output reg 	[32:0]			Third_moment; //修改数据宽度后，下面的cube_data和cube_data_n的数据宽度也需要修改
output reg 	[40:0]			Fourth_moment;
// output reg  				Read_Over_flag;
reg  						Read_Over_flag_reg; 
output 						Over_flag;


reg 		[7:0] 			Monopulse_data [0:250];
// reg 		[7:0] 			Monopulse_data_reg [0:250];
output reg 	[15:0] 			Read_num; //???DDR2???¨¨????-????????¡ã
output reg 	[2:0] 			Arithmetic_State;
reg 		[2:0] 			Arithmetic_State_reg;
reg 		[7:0]			Peak_value_reg;
reg 		[7:0]			Peak_value_Width;
reg 		[7:0]			Peak_value_Width_reg;
reg 		[15:0]			Front_area_reg;
reg 		[15:0]			Behind_area_reg;
output reg 		[15:0]			Total_area_reg; 
reg 		[15:0]			Front_Width_reg;
reg 		[15:0]			Behind_Width_reg;
reg 		[15:0]			Total_Width_reg; 
output reg 	[7:0] 			Mean_value; //?????????
reg			[7:0] 			Mean_value_reg;
output reg 	[7:0] 			Mean_value_remainders; //?????????
reg 		[7:0] 			Mean_value_remainders_reg;
output reg	[15:0]			time_cnt;			//?????????¨¦???¡À?¨¨????¡ã??????
output reg	[15:0]			time_cnt_n;			//time_cnt?????????????????????
output reg	[15:0]			Monopulse_num_reg;
reg 		[15:0] 			Read_num_reg;

// assign Over_flag 				= FeatureExtraction_flag_reg;
reg 			time_clear;
reg 			time_clear_reg;
reg             start_count;
reg             start_count_reg;

wire [15:0] 		Monopulse_data_in_absolute;
wire [16:0] 		Monopulse_data_in_subtract;
assign Monopulse_data_in_subtract 	= Monopulse_data_in - GentalThreshould;
assign Monopulse_data_in_absolute  	= Monopulse_data_in_subtract[16]?((~Monopulse_data_in_subtract)+1'd1):Monopulse_data_in_subtract[15:0];
always @ (posedge Clk_arithmetic or negedge Rst)
if(!Rst)begin
	Arithmetic_State 						<= IDLE1;
end
else begin
	Arithmetic_State						<= Arithmetic_State_reg;
end
//???????"?¨¨¡¤? IDLE
wire 		 	BeginOverNum   = FeatureExtraction_flag&&(!FeatureExtraction_flag_reg);
wire [15:0] 	StartOverNum   = Monopulse_num+2;
// wire [15:0] 	ReadOverNum    = Monopulse_num+6;
wire [15:0] 	MeanOverNum    = Monopulse_num+8;
always @ (Arithmetic_State or BeginOverNum or time_cnt)
begin
	case(Arithmetic_State)
		IDLE1:begin
            Arithmetic_State_reg         	<= (Arithmetic_State == IDLE1)?IDLE2:Arithmetic_State;
		end
		IDLE2:begin
            Arithmetic_State_reg         	<= (Arithmetic_State == IDLE2)?Begin:Arithmetic_State;
		end
		Begin:begin
			Arithmetic_State_reg 			<= (BeginOverNum)?Start:Arithmetic_State;
		end
		Start:begin
			Arithmetic_State_reg 			<= (time_cnt == StartOverNum)?Total_Over:Arithmetic_State;
		end
		Total_Over:begin
			Arithmetic_State_reg 			<= (time_cnt == 0)?Remainder_Over:Arithmetic_State;
		end
		Remainder_Over:begin
			Arithmetic_State_reg 			<= (time_cnt == 1)?Mean_Over:Arithmetic_State;
		end
		Mean_Over:begin
			Arithmetic_State_reg 		    <= (time_cnt == 0)?Multiple_Over:Arithmetic_State;
			// Arithmetic_State_reg 		    <= (time_cnt == Monopulse_num+4)?Mean_Over:Arithmetic_State;
		end
		Multiple_Over:begin
            Arithmetic_State_reg	 	    <= (time_cnt >= MeanOverNum)?IDLE1:Arithmetic_State;
            // Arithmetic_State_reg	 	    <= (time_cnt >= (Monopulse_num+Monopulse_num+12))?IDLE:Mean_Over;
		end
		default: Arithmetic_State_reg 		<= Arithmetic_State;
	endcase	
end		

always @ (posedge Clk_arithmetic or negedge Rst)
if(!Rst)begin
	Monopulse_num 							<= 0;
	time_clear 								<= 0;
	FeatureExtraction_flag_reg      		<= 0;
end
else begin
	Monopulse_num 							<= Monopulse_num_reg;
	time_clear 								<= time_clear_reg;
	FeatureExtraction_flag_reg      		<= FeatureExtraction_flag_reg_reg;
end

always @ (*)
begin
	case(Arithmetic_State)
	IDLE1:begin
		FeatureExtraction_flag_reg_reg 		<= FeatureExtraction_flag_reg;
        Monopulse_num_reg               	<= Monopulse_num; 
        time_clear_reg                 		<= (!FeatureExtraction_flag)?1:0;
	end
	IDLE2:begin
		FeatureExtraction_flag_reg_reg 		<= 0;
        Monopulse_num_reg               	<= Monopulse_num; 
        time_clear_reg                 		<= (!FeatureExtraction_flag)?1:0;
      
	end
	Begin:begin
		FeatureExtraction_flag_reg_reg 		<= 0;
        Monopulse_num_reg               	<= Monopulse_num; 
        time_clear_reg                 		<= (!FeatureExtraction_flag)?1:0;
	end
	Start:begin
		Monopulse_num_reg 					<= (time_cnt == 16'd0)?Monopulse_data_in:Monopulse_num;
		time_clear_reg 	 					<= 1;
		FeatureExtraction_flag_reg_reg  	<= 0;
	end
	Total_Over:begin
		Monopulse_num_reg 			    	<= Monopulse_num;
		time_clear_reg 				    	<= 1;
		FeatureExtraction_flag_reg_reg  	<= 0;
	end
	Remainder_Over:begin
		Monopulse_num_reg 			    	<= Monopulse_num;
		time_clear_reg 				    	<= 1;
		FeatureExtraction_flag_reg_reg  	<= 0;
	end
	Mean_Over:begin
		Monopulse_num_reg 			    	<= Monopulse_num;
		time_clear_reg 				    	<= 0;
		FeatureExtraction_flag_reg_reg  	<= 0;
	end

	Multiple_Over:begin
        FeatureExtraction_flag_reg_reg  	<= (time_cnt >= MeanOverNum)?1:0;
        Monopulse_num_reg               	<= Monopulse_num;
        time_clear_reg                  	<= 0;
	end
	default:begin
		FeatureExtraction_flag_reg_reg 		<= FeatureExtraction_flag_reg;
        Monopulse_num_reg               	<= Monopulse_num; 
        time_clear_reg                 		<= time_clear;
	end
	endcase	
end		
always @ (posedge Clk_arithmetic or negedge Rst)
if(!Rst)begin
	time_cnt 								<= 16'h0;
end
else begin
	case(Arithmetic_State)	
	IDLE1:begin
		time_cnt 							<= 16'd0;
	end
	IDLE2:begin
		time_cnt 							<= 16'd0;
	end
	Begin:begin
		time_cnt 							<= 16'd0;
	end
	Start:begin
		time_cnt 							<= time_cnt + 16'd1;
	end
	Total_Over:begin
		time_cnt 							<= time_clear?16'd0:(time_cnt + 16'd1);
	end
	Remainder_Over:begin
		time_cnt 							<= 16'd1;
	end
	Mean_Over:begin
		time_cnt 							<= time_clear?16'd0:(time_cnt + 16'd1);
	end
	Multiple_Over:begin
		time_cnt 							<= time_clear?16'd0:(time_cnt + 16'd1);
	end
	default: time_cnt 						<= 16'd0;			
	endcase
end

always @ (posedge Clk_arithmetic)
begin
	if((Arithmetic_State == Start)&&(time_cnt >= 16'd3))begin
		Monopulse_data[time_cnt-3]  		<= Monopulse_data_in_absolute[7:0];
		Monopulse_data_vi 					<= Monopulse_data_in_absolute[7:0];
	end
	else begin
		Monopulse_data[time_cnt-3]  		<= Monopulse_data[time_cnt-3];
		Monopulse_data_vi 					<= Monopulse_data[time_cnt-3];
	end
end	
/* ???????"?¨¨¡¤?,? ????????????????¨¨????¡ã??¡§???jisuan */
reg 		[15:0]		Monopulse_num_half;
reg 		[15:0]		Monopulse_num_half_reg;

always @ (posedge Clk_arithmetic or negedge Rst)
if(!Rst)begin
	Total_area 								<= 0;
	Front_area 								<= 0;
	Behind_area 							<= 0;
	Peak_value_Width						<= 0; 
	Front_Width 							<= 0;
	Behind_Width 							<= 0;
	Total_Width 							<= 0;
	Peak_value 								<= 0;
	Mean_value_remainders 					<= 0;
	Monopulse_num_half 	 					<= 0;
	Mean_value 								<= 0;
end
else begin
	Total_area 								<= Total_area_reg;
	Peak_value 			   					<= Peak_value_reg;
	Front_area								<= Front_area_reg;
	Behind_area 							<= Behind_area_reg;
	Peak_value_Width 		 				<= Peak_value_Width_reg;
	Front_Width 							<= Front_Width_reg;
	Behind_Width 							<= Behind_Width_reg;
	Total_Width 							<= Total_Width_reg;
	Mean_value_remainders 					<= Mean_value_remainders_reg;
	Monopulse_num_half 	 					<= Monopulse_num_half_reg;
	Mean_value 								<= Mean_value_reg;
	// end
end
wire StartJudge;
wire FrontAreaChange;
wire FrontWidthChange;
wire Mean_value_n;

reg [7:0] 	Monopulse_data_vi;
// reg [7:0] 	Monopulse_data_vi_reg;

assign StartJudge 				= (time_cnt>=3)&&(Monopulse_num!=0);
assign FrontAreaChange 			= ((time_cnt>=3)&&(Monopulse_num!=0)&&(Monopulse_data_in_absolute>Peak_value))?1:0;
assign FrontWidthChange 		= ((time_cnt>=3)&&(Monopulse_num!=0)&&(Monopulse_data_in_absolute>Peak_value_Width))?1:0;

always @ (*)
begin
	case(Arithmetic_State)	
	IDLE1:begin
		Peak_value_reg 			   			<= Peak_value;
		Front_area_reg 						<= Front_area;
		Behind_area_reg 					<= Behind_area;
		Total_area_reg 						<= Total_area;
		Peak_value_Width_reg 				<= Peak_value_Width;
		Front_Width_reg 					<= Front_Width;
		Behind_Width_reg 					<= Behind_Width;
		Total_Width_reg 					<= Total_Width;
		Mean_value_reg 						<= Mean_value;
		Mean_value_remainders_reg 			<= Mean_value_remainders;
		Monopulse_num_half_reg				<= Monopulse_num_half;
	end
	IDLE2:begin
		Peak_value_reg 			   			<= Peak_value;
		Front_area_reg 						<= Front_area;
		Behind_area_reg 					<= Behind_area;
		Total_area_reg 						<= Total_area;
		Peak_value_Width_reg 				<= Peak_value_Width;
		Front_Width_reg 					<= Front_Width;
		Behind_Width_reg 					<= Behind_Width;
		Total_Width_reg 					<= Total_Width;
		Mean_value_reg 						<= Mean_value;
		Mean_value_remainders_reg 			<= Mean_value_remainders;
		Monopulse_num_half_reg				<= Monopulse_num_half;
	end
	Begin:begin
		Peak_value_reg 			   			<= Peak_value;
		Front_area_reg 						<= Front_area;
		Behind_area_reg 					<= Behind_area;
		Total_area_reg 						<= Total_area;
		Peak_value_Width_reg 				<= Peak_value_Width;
		Front_Width_reg 					<= Front_Width;
		Behind_Width_reg 					<= Behind_Width;
		Total_Width_reg 					<= Total_Width;
		Mean_value_reg 						<= Mean_value;
		Mean_value_remainders_reg 			<= Mean_value_remainders;
		Monopulse_num_half_reg				<= Monopulse_num_half;
	end
	Start:begin
		Peak_value_reg 			   			<= (time_cnt==0)?0:((StartJudge&&(Monopulse_data_in_absolute>Peak_value))?Monopulse_data_in_absolute:Peak_value);
		Front_area_reg 						<= (time_cnt==0)?0:((FrontAreaChange)?(Front_area + Behind_area + Monopulse_data_in_absolute):Front_area);
		Behind_area_reg 					<= (time_cnt==0)?0:(StartJudge?((Monopulse_data_in_absolute>Peak_value)?0:(Behind_area + Monopulse_data_in_absolute)):Behind_area);
		Total_area_reg 						<= 0;
		Peak_value_Width_reg 				<= (time_cnt==0)?1:((StartJudge&&(Monopulse_data_in_absolute>Peak_value_Width))?Monopulse_data_in_absolute:Peak_value_Width);
		Front_Width_reg 					<= (time_cnt==0)?0:((FrontWidthChange)?(Front_Width + Behind_Width + 16'd1):Front_Width);
		Behind_Width_reg 					<= (time_cnt==0)?0:(StartJudge?((Monopulse_data_in_absolute>Peak_value_Width)?0:(Behind_Width + 16'd1)):Behind_Width);
		Total_Width_reg 					<= 0;
	end
	Total_Over:begin
		Peak_value_reg 			   			<= Peak_value;
		Front_area_reg 						<= Front_area;
		Behind_area_reg 					<= Behind_area;
		Total_area_reg 						<= Behind_area + Front_area;
		Peak_value_Width_reg 				<= Peak_value_Width;
		Front_Width_reg 					<= Front_Width;
		Behind_Width_reg 					<= Behind_Width;
		Total_Width_reg 					<= Front_Width + Behind_Width;
	end
	Remainder_Over:begin
		Peak_value_reg 			   			<= Peak_value;
		Front_area_reg 						<= Front_area;
		Behind_area_reg 					<= Behind_area;
		Total_area_reg 						<= Total_area;
		Peak_value_Width_reg 				<= Peak_value_Width;
		Front_Width_reg 					<= Front_Width;
		Behind_Width_reg 					<= Behind_Width;
		Total_Width_reg 					<= Total_Width;
		Mean_value_remainders_reg 			<= Total_area%Monopulse_num;
		Monopulse_num_half_reg 				<= Monopulse_num>>1;
	end
	Mean_Over:begin
		Peak_value_reg 			   			<= Peak_value;
		Front_area_reg 						<= Front_area;
		Behind_area_reg 					<= Behind_area;
		Total_area_reg 						<= Total_area;
		Peak_value_Width_reg 				<= Peak_value_Width;
		Front_Width_reg 					<= Front_Width;
		Behind_Width_reg 					<= Behind_Width;
		Total_Width_reg 					<= Total_Width;
		Mean_value_reg 						<= (Mean_value_remainders > Monopulse_num_half)?((Total_area/Monopulse_num)+1):(Total_area/Monopulse_num);		
	end
	default:begin
		Peak_value_reg 			   			<= Peak_value;
		Front_area_reg 						<= Front_area;
		Behind_area_reg 					<= Behind_area;
		Total_area_reg 						<= Total_area;
		Peak_value_Width_reg 				<= Peak_value_Width;
		Front_Width_reg 					<= Front_Width;
		Behind_Width_reg 					<= Behind_Width;
		Total_Width_reg 					<= Total_Width;
		Mean_value_remainders_reg 			<= Mean_value_remainders;
		Monopulse_num_half_reg				<= Monopulse_num_half;
	end	
	endcase
end		

output reg 	[15:0]		ii;
reg [9:0]				SubtractionMean_data1;
reg [9:0]				SubtractionMean_data2;
reg [8:0] 				SubtractionMean_data_n;
output reg [20:0] 		Square_data;
reg [32:0] 			Cube_data;
reg [31:0] 									Cube_data_n;
reg [40:0] 			Biquadrate_data;
reg											Sign_bit1;
reg											Sign_bit2;
reg											Sign_bit3;


reg [23:0]			Second_moment_reg;
reg [32:0]			Third_moment_reg; //修改数据宽度后，下面的cube_data和cube_data_n的数据宽度也需要修改
reg [40:0]			Fourth_moment_reg;
reg [15:0]			ii_reg;
reg	[9:0]			SubtractionMean_data1_reg;
reg	[9:0]			SubtractionMean_data2_reg;
reg [8:0] 			SubtractionMean_data_n_reg;
reg [20:0] 			Square_data_reg;
reg [32:0] 			Cube_data_reg;
reg [31:0] 			Cube_data_n_reg;
reg [40:0] 			Biquadrate_data_reg;
reg					Sign_bit1_reg;
reg					Sign_bit2_reg;
reg					Sign_bit3_reg;

wire [8:0] 			Complement_Subtraction;
wire [31:0] 		Complement_Cube;

assign Complement_Subtraction = (~SubtractionMean_data_n)+1'd1;
assign Complement_Cube 		  = (~Cube_data_n)+1'd1;

always @ (posedge Clk_arithmetic or negedge Rst)
if(!Rst)begin
	Second_moment 							<= 0;
	Third_moment 							<= 0;
	Fourth_moment 							<= 0;
	ii 										<= 0;
	SubtractionMean_data_n 					<= 0;
	Cube_data_n 							<= 0;
	Square_data		 						<= 0;
	Cube_data								<= 0;
	Biquadrate_data 						<= 0;
	Sign_bit1 								<= 0;
	Sign_bit2								<= 0;
	Sign_bit3 								<= 0;
	SubtractionMean_data1 					<= 0;
	SubtractionMean_data2 					<= 0;
end
else begin
	Second_moment 							<= Second_moment_reg;
	Third_moment 							<= Third_moment_reg;
	Fourth_moment 							<= Fourth_moment_reg;
	ii 										<= ii_reg;
	SubtractionMean_data_n 					<= SubtractionMean_data_n_reg;
	Cube_data_n 							<= Cube_data_n_reg;
	Square_data		 						<= Square_data_reg;
	Cube_data								<= Cube_data_reg;
	Biquadrate_data 						<= Biquadrate_data_reg;
	Sign_bit1 								<= Sign_bit1_reg;
	Sign_bit2								<= Sign_bit2_reg;
	Sign_bit3 								<= Sign_bit3_reg;
	SubtractionMean_data1 					<= SubtractionMean_data1_reg;
	SubtractionMean_data2 					<= SubtractionMean_data2_reg;
end
always @ (*)
begin
	case(Arithmetic_State)	
	Mean_Over:begin
		Second_moment_reg 					<= 0;
		Third_moment_reg 					<= 0;
		Fourth_moment_reg 					<= 0;
		ii_reg 								<= 0;
		SubtractionMean_data_n_reg 			<= 0;
		Cube_data_n_reg 					<= 0;
		Square_data_reg		 				<= 0;
		Cube_data_reg 						<= 0;
		Biquadrate_data_reg 				<= 0;
		Sign_bit1_reg 						<= 0;
		Sign_bit2_reg 						<= 0;
		Sign_bit3_reg 						<= 0;
		SubtractionMean_data1_reg 			<= 0;
		SubtractionMean_data2_reg 			<= 0;
	end
	Multiple_Over:begin
		if(ii<Monopulse_num)
			SubtractionMean_data_n_reg 		<= Monopulse_data[ii] - Mean_value;
		else
			SubtractionMean_data_n_reg 		<= SubtractionMean_data_n;
			
		SubtractionMean_data1_reg 			<= SubtractionMean_data_n[8]?{1'b0,Complement_Subtraction}:{1'b0,SubtractionMean_data_n};
		SubtractionMean_data2_reg 			<= SubtractionMean_data1;
		Sign_bit1_reg 						<= SubtractionMean_data_n[8]?1:0;
		Sign_bit2_reg 						<= Sign_bit1;
		Sign_bit3_reg 						<= Sign_bit2;
		Square_data_reg 					<= SubtractionMean_data1 * SubtractionMean_data1;
		Cube_data_n_reg 					<= Square_data * SubtractionMean_data2;//??????????????
		Cube_data_reg 						<= Sign_bit3?{1'b1,Complement_Cube}:{1'b0,Cube_data_n};
		// Cube_data_reg 						<= SubtractionMean_data_n * SubtractionMean_data_n * SubtractionMean_data_n;
		Biquadrate_data_reg 				<= Square_data * Square_data;
		if(ii<Monopulse_num+3)
			Second_moment_reg 				<= Square_data + Second_moment;
		else
			Second_moment_reg 				<= Second_moment;
		if(ii<Monopulse_num+5)
			Third_moment_reg 				<= Cube_data + Third_moment;
		else
			Third_moment_reg 				<= Third_moment;
		if(ii<Monopulse_num+4)
			Fourth_moment_reg 				<= Biquadrate_data + Fourth_moment;
		else
			Fourth_moment_reg 				<= Fourth_moment;
		ii_reg <= ii+1;
	end
	default:begin
		Second_moment_reg 					<= Second_moment;
		Third_moment_reg 					<= Third_moment;
		Fourth_moment_reg 					<= Fourth_moment;
	end		
	endcase
end

endmodule
