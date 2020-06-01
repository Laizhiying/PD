module Monopulse_extraction_1
(
	Clk,
	Rst,
	Extract_en,
	Data_in,
	Period_count,
	DDR_State,
	MonopulseExThreshould,
	MonopulseExHold,
	MonopulseMultiThreshould,
	MonopulseEndHold,
	GentalThreshould,
	GentalThreshouldNum,
	Monopulse_data1,
	Pulse_point_num,		//本次单脉冲的采样点数
	Monopulse_num,		 //�?个周期内单脉冲的个数
	FeatureExtraction_flag,			//将提取的单脉冲的个数以及单脉冲采样点送去特征提取
	FeatureExtraction_flag_reg,
	WaveState,
	Monopulse_data_1,
	Monopulse_data_00,
	Monopulse_data_01,
	Period_condition,
	// Read_Over_flag,
	ReadPosition,
	MonopulsePosition,
	Count
	
);

input 					Clk;
input					Rst;
input					Extract_en;
input		[15:0]		Data_in;
input 		[5:0]  		Period_count;
input     				FeatureExtraction_flag_reg; //特征提取完为1
// input 					Read_Over_flag;
input 		[31:0]      ReadPosition;
input 		[3:0] 		DDR_State;
input 		[7:0] 		MonopulseExThreshould;
input 		[7:0] 		MonopulseExHold;
input 		[7:0] 		MonopulseMultiThreshould;
input 		[7:0] 		MonopulseEndHold;
input 		[7:0] 		GentalThreshould;
input 		[7:0] 		GentalThreshouldNum;

output reg	[15:0]		Monopulse_data1; //将单脉冲送给特征提取模块，第�?个数据为Pulse_point_num
output reg	[5:0]		Monopulse_num;
output reg				FeatureExtraction_flag; //单脉冲提取完�?1

output reg	[15:0] 		Pulse_point_num; //本个单脉冲的个数

output reg  [7:0]		Monopulse_data_01; //
output reg  [7:0]		Monopulse_data_00;

reg			[7:0]		Monopulse_data[0:250]; //
output reg	[1:0]		WaveState;
reg			[1:0]		WaveState_reg;

output reg	[7:0]		Monopulse_data_1; //输入Data_in先赋值给Monopulse_data_1
reg			[7:0]		Falling_edge_num;	
reg			[7:0]		Gentle_num;
output reg 	[15:0]		Count;

output reg	[5:0] 		Period_condition;
reg			[5:0] 		Period_condition_reg;
output reg  [31:0] 		MonopulsePosition;
reg  		[31:0] 		MonopulsePosition_reg;
reg 		[2:0] 		PositionState;
reg 		[2:0] 		PositionState_reg;

parameter   PositionIDLE = 3'd0,
			Period_end = 3'd1,
			PositionGet1 = 3'd2,
			PositionGet2 = 3'd3;

parameter 	IDLE = 2'd0,
			RiseEdge = 2'd1,
			FallingEdge = 2'd2;

reg 			FeatureExtraction_flag_n;			

wire MonopulsePosition_clear;
assign MonopulsePosition_clear = (Data_in == 16'd256)&&(PositionState == PositionIDLE);
always @ (posedge Clk or negedge Rst)
if(!Rst)begin
	MonopulsePosition 					<= 32'd0;
end
else begin
	MonopulsePosition 					<= MonopulsePosition_reg;
end
always @ (*)
if(DDR_State == 0)begin
	MonopulsePosition_reg  					<= 0;
end
else if(Extract_en)begin
	if(MonopulsePosition_clear)begin
    	MonopulsePosition_reg  					<= 0;
    end
    else begin
		MonopulsePosition_reg 					<= MonopulsePosition + 32'd1;
	end
end
else begin
	MonopulsePosition_reg 						<= MonopulsePosition;
end


always @ (posedge Clk or negedge Rst)
if(!Rst)begin
	PositionState 						<= PositionIDLE;
end
else begin
	PositionState 						<= PositionState_reg;
end
always @ (*) 
if(Extract_en)
	case(PositionState)
		PositionIDLE:begin
			if(Data_in == 16'd256)begin
		    	PositionState_reg  					<= Period_end;
		    end
		    else begin
				PositionState_reg 					<= PositionState;
			end
		end
		Period_end:begin
			PositionState_reg 						<= PositionGet1;
		end
		PositionGet1:begin
			PositionState_reg 						<= PositionGet2;
		end
		PositionGet2:begin
			PositionState_reg 						<= PositionIDLE;
		end
			default:begin
				PositionState_reg 						<= PositionState;
			end
	endcase
else begin
	PositionState_reg 								<= PositionState;
end

always @ (posedge Clk  or negedge Rst)
if(!Rst)begin
	Period_condition 	 				<= 6'd0;
end
else begin
	Period_condition 	 				<= Period_condition_reg;
end
always @ (*)
if(Extract_en)begin
	case(PositionState)
		IDLE:begin
			Period_condition_reg 					<= Period_condition;
			// MonopulsePosition_reg 	 				<= MonopulsePosition;
		end
		Period_end:begin
			Period_condition_reg 					<= Data_in;
			// MonopulsePosition_reg 					<= MonopulsePosition;
		end
		PositionGet1:begin		//
			Period_condition_reg 					<= Period_condition;
			// MonopulsePosition_reg[31:16] 			<= Data_in;
		end
		PositionGet2:begin		//
			Period_condition_reg 					<= Period_condition;
			// MonopulsePosition_reg[15:0] 			<= Data_in;
		end
		default: begin
			Period_condition_reg 					<= Period_condition;
			// MonopulsePosition_reg 					<= MonopulsePosition;
		end
	endcase
end

always @ (posedge Clk or negedge Rst)
if(!Rst)begin
	WaveState 							<= IDLE;
end
else begin
	WaveState 							<= WaveState_reg;
end
always @ (*)
if(Extract_en&&(PositionState == PositionIDLE))begin
	if((Data_in >= MonopulseExThreshould)&&(Data_in <= 16'd255)) //
	case(WaveState)
		IDLE:begin
			WaveState_reg 						<= RiseEdge;
		end
		RiseEdge:begin
			WaveState_reg 						<= WaveState;
		end
		FallingEdge:		//
			if(Falling_edge_num < MonopulseMultiThreshould)begin //MonopulseMultiThreshould-10
				WaveState_reg 					<= RiseEdge;
			end
			else
				WaveState_reg 					<= WaveState;
		default: WaveState_reg 					<= WaveState;
	endcase
	else 
	case(WaveState)
		IDLE:begin
			WaveState_reg 						<= IDLE;
		end
		RiseEdge:begin	//否则如果在判断单脉冲的过程中，则判断为下降沿�?�?	
			if((Pulse_point_num > MonopulseExHold)&&(Pulse_point_num < 100))
				WaveState_reg 					<= FallingEdge;
			else
				WaveState_reg 					<= IDLE;
		end
		FallingEdge:		//否则判断为背景噪声不�?
			if(Gentle_num >= GentalThreshouldNum) //MonopulseEndHold-20
			begin
				WaveState_reg 					<= IDLE;
			end
			else begin
				WaveState_reg                   <= WaveState;
			end
		default: WaveState_reg 					<= IDLE;
	endcase
end

always @ (posedge Clk or negedge Rst)
if(!Rst)begin
	FeatureExtraction_flag 				<= 0;
end
else begin
	FeatureExtraction_flag 				<= FeatureExtraction_flag_n;
end
always @ (*)
if((Gentle_num >= GentalThreshouldNum)&&(WaveState == FallingEdge))begin //MonopulseEndHold-20
	FeatureExtraction_flag_n 					<= 1;
end				
else if(FeatureExtraction_flag_reg)begin     ///////////////////////////////////////////////////
	FeatureExtraction_flag_n 					<= 0;
end
else begin
	FeatureExtraction_flag_n 					<= FeatureExtraction_flag;
end

always @ (posedge Clk or negedge Rst)
if(!Rst)begin
	Falling_edge_num 					<= 8'd0;
	Pulse_point_num   					<= 16'd4;
end
else if(Extract_en)begin
	case(WaveState)
	IDLE:begin		
		Falling_edge_num                	<= 0;
		// Pulse_point_num   					<= 16'd4;
		if(FeatureExtraction_flag_reg)begin	
			//Pulse_point_num   				<= 16'd2;
			Monopulse_data[0] 				<= 0;
			Monopulse_data[1] 				<= 0;
			Monopulse_data[2] 				<= 0;
			Monopulse_data[3] 				<= 0;
			Monopulse_data[4] 				<= 0;
		end
		else
		if(!FeatureExtraction_flag)begin
			Pulse_point_num   				<= 16'd4;
			Monopulse_data_1  				<= Data_in;
			Monopulse_data[3] 				<= Monopulse_data_1;
			Monopulse_data[2] 				<= Monopulse_data[3];
			Monopulse_data[1] 				<= Monopulse_data[2];
			Monopulse_data[0] 				<= Monopulse_data[1];
			Monopulse_data_01 				<= Monopulse_data_1;
			Monopulse_data_00 				<= Monopulse_data[1];
		end
	end
	RiseEdge:begin		
		Falling_edge_num                	<= 0;	
		Gentle_num 							<= 8'd0;
		if(Pulse_point_num == 16'd4)begin				
			Monopulse_data[4] 				<= Monopulse_data_1;
			Monopulse_data[5] 				<= Data_in;
			Pulse_point_num   				<= Pulse_point_num + 16'd2;
		end
		else begin
			Monopulse_data[Pulse_point_num] <= Data_in;
			Pulse_point_num                 <= Pulse_point_num + 16'd1;
		end
	end
	FallingEdge:begin
		Falling_edge_num                	<= Falling_edge_num + 8'd1;
		Pulse_point_num                 	<= Pulse_point_num + 16'd1;
		Monopulse_data[Pulse_point_num] 	<= Data_in;
		Gentle_num 							<= (Data_in<=GentalThreshould)?(Gentle_num + 8'd1):8'd0;
	end
	default:begin
		Pulse_point_num   					<= 16'd4;
		Monopulse_data_1  					<= Data_in;
		Monopulse_data[1] 					<= Monopulse_data_1;
		Monopulse_data[0] 					<= Monopulse_data[1];
	end
	endcase
end

wire [15:0] send_count;
assign send_count = Pulse_point_num+3;
always @ (posedge Clk or negedge Rst)
if(!Rst)begin
	Monopulse_data1 			<= 0;
	Count 						<= 0;	
end
else begin
	if(FeatureExtraction_flag&&(Count<=send_count))begin
		if(Count == 16'd0)begin
			Count 				<= Count + 16'd1;
			Monopulse_data1 	<= Pulse_point_num;
		end
		else if(Count == 16'd1)begin
			Count 				<= Count + 16'd1;
		end
		else if(Count == 16'd2)begin
			Count 				<= Count + 16'd1;
		end
		else begin
			Count 				<= Count + 16'd1;
			Monopulse_data1 	<= Monopulse_data[Count-3];
		end
	end
	else if(!FeatureExtraction_flag)
		Count 					<= 0;
	else begin
		Count 					<= Count;
	end
end


endmodule
