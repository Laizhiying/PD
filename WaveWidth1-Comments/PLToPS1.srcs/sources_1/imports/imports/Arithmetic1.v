module Arithmetic1
(
	Clk_arithmetic,
	clk_arith,//没用
	Rst,
	Monopulse_data_in, //从单脉冲提取模块发送过来的数据
	GentalThreshould, //稳定值
	Monopulse_num, //单脉冲的点数
	Front_area, //波前面积
	Behind_area, //波后面积
	Total_area, //总面积
	Front_Width, //波前
	Behind_Width, //波后
	Total_Width, //总长度
	Peak_value, //峰值
	Second_moment, //二阶矩
	Third_moment, //三阶矩
	Fourth_moment, //四阶矩
	Read_num, //没用
	Mean_value, //均值整数2
	Mean_value_remainders, //均值的余数
	ii,
	Square_data, //平方值
	FeatureExtraction_flag,	//单脉冲提取状态，1为提取结束
	FeatureExtraction_flag_reg, //特征提取状态，1为提取结束
	Arithmetic_State, //特征提取状态
	Read_Over_flag, //没用
	time_cnt,
	time_cnt_n,
	Monopulse_num_reg
	// Over_flag
//	Period_flag
	
);

//特征提取的状态
//前面的两个idle为了等待FeatureExtraction_flag和FeatureExtraction_flag_reg回到原来的状态，等待下一次开始特征提取的触发
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

input  	  	[15:0]			Monopulse_data_in; 
input 		[7:0] 			GentalThreshould;
input 						Rst;

(*mark_debug="true"*)output reg					FeatureExtraction_flag_reg;
reg					        FeatureExtraction_flag_reg_reg;
output reg 	[15:0]			Monopulse_num;
output reg 	[15:0]			Front_area;
output reg 	[15:0]			Behind_area;
output reg 	[15:0]			Total_area;
output reg 	[15:0]			Front_Width;
output reg 	[15:0]			Behind_Width;
output reg 	[15:0]			Total_Width;
output reg 	[7:0]			Peak_value;
output reg 	[23:0]			Second_moment;
output reg 	[32:0]			Third_moment; //修改数据宽度后，下面的cube_data和cube_data_n的数据宽度也需要修改
output reg 	[40:0]			Fourth_moment;
output reg  				Read_Over_flag; //没用 
reg  						Read_Over_flag_reg; //没用 
// output 						Over_flag;


reg 		[7:0] 			Monopulse_data [0:250];//保存单脉冲，用于计算多阶矩
// reg 		[7:0] 			Monopulse_data_reg [0:250];
output reg 	[15:0] 			Read_num; //没用
output reg 	[2:0] 			Arithmetic_State;
reg 		[2:0] 			Arithmetic_State_reg;
reg 		[7:0]			Peak_value_reg;
reg 		[7:0]			Peak_value_Width;//等于Peak_value，当时为计算波前长度
reg 		[7:0]			Peak_value_Width_reg;
reg 		[15:0]			Front_area_reg;
reg 		[15:0]			Behind_area_reg;
reg 		[15:0]			Total_area_reg; 
reg 		[15:0]			Front_Width_reg;
reg 		[15:0]			Behind_Width_reg;
reg 		[15:0]			Total_Width_reg; 
output reg 	[7:0] 			Mean_value;
reg			[7:0] 			Mean_value_reg;
output reg 	[7:0] 			Mean_value_remainders; 
reg 		[7:0] 			Mean_value_remainders_reg;
output reg	[15:0]			time_cnt; //计时
output reg	[15:0]			time_cnt_n;	
output reg	[15:0]			Monopulse_num_reg;
reg 		[15:0] 			Read_num_reg;

// assign Over_flag 				= FeatureExtraction_flag_reg;
reg 			time_clear;//time_cnt清零标志
reg 			time_clear_reg;

wire [15:0] 		Monopulse_data_in_absolute;//单脉冲的绝对值
wire [16:0] 		Monopulse_data_in_subtract;//单脉冲减去稳定值
assign Monopulse_data_in_subtract 	= Monopulse_data_in - GentalThreshould;
assign Monopulse_data_in_absolute  	= Monopulse_data_in_subtract[16]?((~Monopulse_data_in_subtract)+1'd1):Monopulse_data_in_subtract[15:0];//对Monopulse_data_in_subtract取绝对值
always @ (posedge Clk_arithmetic or negedge Rst)
if(!Rst)begin
	Arithmetic_State 						<= IDLE1;
end
else begin
	Arithmetic_State						<= Arithmetic_State_reg;
end
wire 		 	BeginOverNum   = FeatureExtraction_flag&&(!FeatureExtraction_flag_reg);//Arithmetic_State由begin跳到start的条件
wire [15:0] 	StartOverNum   = Monopulse_num+2;//这个值是根据接收和计算的时间，根据查看时序得到的值
wire [15:0] 	MeanOverNum    = Monopulse_num+8;//根据计算所需时间和查看时序得到的值
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
			Arithmetic_State_reg 			<= (BeginOverNum)?Start:Arithmetic_State;//Arithmetic_State由begin跳到start，表示可以开始接收单脉冲数据了，
																					 //前面的两个空闲状态是为了等到这个条件回到初始状态，以便等待下次触发状态转移
		end
		Start:begin //开始接收单脉冲数据，在这个状态下计算波前波后面积以及波前波后的长度和找到峰值，计算完跳到Total_Over
			Arithmetic_State_reg 			<= (time_cnt == StartOverNum)?Total_Over:Arithmetic_State;
		end
		Total_Over:begin //根据上个状态的波前波后值计算总面积和总长度，加法只需要一个时钟周期就行，这里有两个周期
			Arithmetic_State_reg 			<= (time_cnt == 0)?Remainder_Over:Arithmetic_State;
		end
		Remainder_Over:begin //根据上一个状态计算的总面积计算均值的余数，使用/符号直接计算所需要的时间为一个时钟周期，以面积换取速度，可修改为用ip核计算
			Arithmetic_State_reg 			<= (time_cnt == 1)?Mean_Over:Arithmetic_State;
		end
		Mean_Over:begin //根据上个状态计算的余数判断四舍五入，计算均值，也是使用/符号计算，只需要一个时钟周期
			Arithmetic_State_reg 		    <= (time_cnt == 0)?Multiple_Over:Arithmetic_State;
			// Arithmetic_State_reg 		    <= (time_cnt == Monopulse_num+4)?Mean_Over:Arithmetic_State;
		end
		Multiple_Over:begin //计算二三四阶矩
            Arithmetic_State_reg	 	    <= (time_cnt >= MeanOverNum)?IDLE1:Arithmetic_State;
            // Arithmetic_State_reg	 	    <= (time_cnt >= (Monopulse_num+Monopulse_num+12))?IDLE:Mean_Over;
		end
		default: Arithmetic_State_reg 		<= Arithmetic_State;
	endcase	
end		

//Monopulse_num、time_clear、FeatureExtraction_flag_reg三个值的改变
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
		FeatureExtraction_flag_reg_reg 		<= 0;//清零
        Monopulse_num_reg               	<= Monopulse_num; 
        time_clear_reg                 		<= (!FeatureExtraction_flag)?1:0;
      
	end
	Begin:begin
		FeatureExtraction_flag_reg_reg 		<= 0;
        Monopulse_num_reg               	<= Monopulse_num; 
        time_clear_reg                 		<= (!FeatureExtraction_flag)?1:0;//当FeatureExtraction_flag为0时，也就是回到初始状态后，time_clear置1，使time_cnt清零
	end
	Start:begin
		Monopulse_num_reg 					<= (time_cnt == 16'd0)?Monopulse_data_in:Monopulse_num;//发送的第一个值为单脉冲的点数
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
        FeatureExtraction_flag_reg_reg  	<= (time_cnt >= MeanOverNum)?1:0;//当计算完二三四阶矩后说明特征提取结束
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

//计时
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
		time_cnt 							<= time_cnt + 16'd1;//开始接受数据了，计算接受数据花费的时间
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

//将单脉冲的绝对值保存
(*mark_debug="true"*)reg [7:0] 	Monopulse_data_vi;//没用
always @ (posedge Clk_arithmetic)
begin
	if((Arithmetic_State == Start)&&(time_cnt >= 16'd3))begin//大于等于3应该是为了空出时间计算绝对值，计算绝对值按理应该修改为时序电路，之前我好像修改为时序电路结果出错了，忘了。。。。
		Monopulse_data[time_cnt-3]  		<= Monopulse_data_in_absolute[7:0];
		Monopulse_data_vi 					<= Monopulse_data_in_absolute[7:0];
	end
	else begin
		Monopulse_data[time_cnt-3]  		<= Monopulse_data[time_cnt-3];
		Monopulse_data_vi 					<= Monopulse_data[time_cnt-3];
	end
end	


//计算波前波后总面积，峰值以及均值
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
assign StartJudge 				= (time_cnt>=3)&&(Monopulse_num!=0);//开始接收单脉冲的绝对值数据
assign FrontAreaChange 			= ((time_cnt>=3)&&(Monopulse_num!=0)&&(Monopulse_data_in_absolute>Peak_value))?1:0;//波前面积改变的条件，遇见大于峰值的点就说明前面的都属于波前的点
assign FrontWidthChange 		= ((time_cnt>=3)&&(Monopulse_num!=0)&&(Monopulse_data_in_absolute>Peak_value_Width))?1:0;//波前长度改变的条件，同上

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
		Peak_value_reg 			   			<= (time_cnt==0)?0:((StartJudge&&(Monopulse_data_in_absolute>Peak_value))?Monopulse_data_in_absolute:Peak_value);//找到峰值
		Front_area_reg 						<= (time_cnt==0)?0:((FrontAreaChange)?(Front_area + Behind_area + Monopulse_data_in_absolute):Front_area);//遇到比之前的峰值更大的数据说明波前面积等于之前计算的波后面积加上这个新的峰值
		Behind_area_reg 					<= (time_cnt==0)?0:(StartJudge?((Monopulse_data_in_absolute>Peak_value)?0:(Behind_area + Monopulse_data_in_absolute)):Behind_area);//改变条件和波前的一样，只是代码不一样，可改为一样，遇到比峰值小的开始累加，直至遇到比峰值大的点，即满足条件时，波后面积清零
		Total_area_reg 						<= 0;
		Peak_value_Width_reg 				<= (time_cnt==0)?1:((StartJudge&&(Monopulse_data_in_absolute>Peak_value_Width))?Monopulse_data_in_absolute:Peak_value_Width);//这三个同上面的
		Front_Width_reg 					<= (time_cnt==0)?0:((FrontWidthChange)?(Front_Width + Behind_Width + 16'd1):Front_Width);
		Behind_Width_reg 					<= (time_cnt==0)?0:(StartJudge?((Monopulse_data_in_absolute>Peak_value_Width)?0:(Behind_Width + 16'd1)):Behind_Width);
		Total_Width_reg 					<= 0;
	end
	Total_Over:begin
		Peak_value_reg 			   			<= Peak_value;
		Front_area_reg 						<= Front_area;
		Behind_area_reg 					<= Behind_area;
		Total_area_reg 						<= Behind_area + Front_area;//计算总面积
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
		Mean_value_remainders_reg 			<= Total_area%Monopulse_num;//计算余数
		Monopulse_num_half_reg 				<= Monopulse_num>>1;//单脉冲点数的一半
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
		Mean_value_reg 						<= (Mean_value_remainders > Monopulse_num_half)?((Total_area/Monopulse_num)+1):(Total_area/Monopulse_num);//计算四舍五入的均值		
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


//计算二三四阶矩，太麻烦，可直接修改为有符号的计算
output reg 	[15:0]		ii;
reg [9:0]				SubtractionMean_data1;//单脉冲减去均值的绝对值
(*mark_debug="true"*)reg [9:0]				SubtractionMean_data2;//单脉冲减去均值的绝对值
(*mark_debug="true"*)reg [8:0] 				SubtractionMean_data_n;//单脉冲的绝对值减去计算的均值
(*mark_debug="true"*)output reg [20:0] 		Square_data;
(*mark_debug="true"*)reg [32:0] 			Cube_data;
reg [31:0] 									Cube_data_n;
(*mark_debug="true"*)reg [40:0] 			Biquadrate_data;
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

assign Complement_Subtraction = (~SubtractionMean_data_n)+1'd1;//单脉冲减去均值的补码
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
			SubtractionMean_data_n_reg 		<= Monopulse_data[ii] - Mean_value;//单脉冲减去均值
		else
			SubtractionMean_data_n_reg 		<= SubtractionMean_data_n;
			
		SubtractionMean_data1_reg 			<= SubtractionMean_data_n[8]?{1'b0,Complement_Subtraction}:{1'b0,SubtractionMean_data_n};//计算单脉冲减去均值的绝对值
		SubtractionMean_data2_reg 			<= SubtractionMean_data1;//保存为了计算三次方
		Sign_bit1_reg 						<= SubtractionMean_data_n[8]?1:0;//保存单脉冲减去均值的值的正负，为了计算三次方
		Sign_bit2_reg 						<= Sign_bit1;
		Sign_bit3_reg 						<= Sign_bit2;//这俩也是为了延时计算三次方
		Square_data_reg 					<= SubtractionMean_data1 * SubtractionMean_data1;//计算平方
		Cube_data_n_reg 					<= Square_data * SubtractionMean_data2;//计算三次方
		Cube_data_reg 						<= Sign_bit3?{1'b1,Complement_Cube}:{1'b0,Cube_data_n};//还原三次方的原码
		// Cube_data_reg 						<= SubtractionMean_data_n * SubtractionMean_data_n * SubtractionMean_data_n;
		Biquadrate_data_reg 				<= Square_data * Square_data;//四次方计算
		if(ii<Monopulse_num+3)
			Second_moment_reg 				<= Square_data + Second_moment;//累加计算二阶距
		else
			Second_moment_reg 				<= Second_moment;
		if(ii<Monopulse_num+5)
			Third_moment_reg 				<= Cube_data + Third_moment;//累加计算三阶距
		else
			Third_moment_reg 				<= Third_moment;
		if(ii<Monopulse_num+4)
			Fourth_moment_reg 				<= Biquadrate_data + Fourth_moment;//累加计算四阶距
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
