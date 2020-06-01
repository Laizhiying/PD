module Monopulse_extraction_1
(
	Clk,
	Rst,
	Extract_en,
	Data_in,
	Period_count,
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
	Read_Over_flag,
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
input 					Read_Over_flag;
input 		[31:0]      ReadPosition;

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
reg			[2:0]		Falling_edge_num;	
output reg 	[15:0]		Count;

output reg	[5:0] 		Period_condition;
reg			[5:0] 		Period_condition_reg;
output reg  [31:0] 		MonopulsePosition;
reg  		[31:0] 		MonopulsePosition_reg;




parameter 	IDLE = 2'd0,
			RiseEdge = 2'd1,
			FallingEdge = 2'd2;
					
parameter   Period_end = 16'h0200,
			Period_mid = 16'h0100;


reg 			FeatureExtraction_flag_n;			
always @ (posedge Clk or negedge Rst)
if(!Rst)begin
	WaveState 					<= IDLE;
	FeatureExtraction_flag 		<= 0;
	Period_condition 	 		<= 0;
	MonopulsePosition 			<= 0;
end
else begin
	WaveState 					<= WaveState_reg;
	FeatureExtraction_flag 		<= FeatureExtraction_flag_n;
	Period_condition 	 		<= Period_condition_reg;
	MonopulsePosition 	 		<= MonopulsePosition_reg;
end


always @ (*)
if(!Rst)begin
	WaveState_reg 					<= IDLE;
	FeatureExtraction_flag_n 		<= 0;
	Period_condition_reg 			<= 0;
	MonopulsePosition_reg 			<= 0;
end
else begin 
	if(Extract_en)begin
	    FeatureExtraction_flag_n 		            <= 0;
	    if(Data_in >16'd255)begin
	    	Period_condition_reg 					<= Period_count;
	    end
		else if(Data_in >= 16'd80) //判断当前点是否大于阈值，若大于则判断为疑似单脉冲
		case(WaveState)
			IDLE:begin
				WaveState_reg 						<= RiseEdge;
				MonopulsePosition_reg 				<= ReadPosition;
			end
			RiseEdge:begin
				WaveState_reg 						<= WaveState;
				MonopulsePosition_reg 				<= ReadPosition;
			end
			FallingEdge:		//
				if(Falling_edge_num < 3'd5)begin
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
				//MonopulsePosition_reg 				<= ReadPosition;
			end
			RiseEdge:begin	//否则如果在判断单脉冲的过程中，则判断为下降沿�?�?	
				if((Pulse_point_num > 6)&&(Pulse_point_num < 100))
					WaveState_reg 					<= FallingEdge;
				else
					WaveState_reg 					<= IDLE;
			end
			FallingEdge:		//否则判断为背景噪声不�?
				if(Falling_edge_num == 3'd5)
				begin
					WaveState_reg 					<= IDLE;
					FeatureExtraction_flag_n 		<= 1;
				end
				else begin
					WaveState_reg                   <= WaveState;
					FeatureExtraction_flag_n 		<= 0;
				end
					// if(Falling_edge_num < 3'd5)
					// begin
						// WaveState <= RiseEdge;
					// end
					// else
					//	WaveState <= WaveState;
			default: WaveState_reg 					<= IDLE;
		endcase
	end
	else if(FeatureExtraction_flag_reg)     ///////////////////////////////////////////////////
		FeatureExtraction_flag_n 					<= 0;
	else 
		FeatureExtraction_flag_n 					<= FeatureExtraction_flag;
end


always @ (posedge Clk or negedge Rst)
if(!Rst)begin
	Monopulse_num 					  <= 0;
	Pulse_point_num 				  <= 16'd2;
	Monopulse_data_1 				  <= 0;
	Falling_edge_num 				  <= 0;
end
else begin
	if(Extract_en)begin
		case(WaveState)
			IDLE:
			begin
				if(FeatureExtraction_flag_reg)begin	
					Pulse_point_num   				<= 16'd2;
					Monopulse_data[0] 				<= 0;
					Monopulse_data[1] 				<= 0;
					Monopulse_data[2] 				<= 0;
				end
				else
				if(!FeatureExtraction_flag)begin
					Pulse_point_num   				<= 16'd2;
					Monopulse_data_1  				<= Data_in;
					Monopulse_data[1] 				<= Monopulse_data_1;
					Monopulse_data[0] 				<= Monopulse_data[1];
					Monopulse_data_01 				<= Monopulse_data_1;
					Monopulse_data_00 				<= Monopulse_data[1];
				end
			end
			RiseEdge:begin			
				if(Pulse_point_num == 16'd2)begin				
					Monopulse_data[2] 				<= Monopulse_data_1;
					Monopulse_data[3] 				<= Data_in;
					Pulse_point_num   				<= Pulse_point_num + 16'd2;
				end
				else begin
					Falling_edge_num                <= 0;
					Monopulse_data[Pulse_point_num] <= Data_in;
					Pulse_point_num                 <= Pulse_point_num + 16'd1;
				end
			end
			FallingEdge:begin
				Falling_edge_num                	<= Falling_edge_num + 3'd1;
				Pulse_point_num                 	<= Pulse_point_num + 16'd1;
				Monopulse_data[Pulse_point_num] 	<= Data_in;
			end
			default:begin
				Pulse_point_num   					<= 16'd2;
				Monopulse_data_1  					<= Data_in;
				Monopulse_data[1] 					<= Monopulse_data_1;
				Monopulse_data[0] 					<= Monopulse_data[1];
			end
		endcase
	end
end


always @ (posedge Clk or negedge Rst)
if(!Rst)begin
	Monopulse_data1 			<= 0;
	Count 						<= 0;	
end
else begin
	if(FeatureExtraction_flag&&(Count<=Pulse_point_num+1))begin
		if(Count == 16'd0)begin
			Count 				<= Count + 16'd1;
			Monopulse_data1 	<= Pulse_point_num;
		end
		else if(Count == 16'd1)begin
			Count 				<= Count + 16'd1;
		end
		else begin
			Count 				<= Count + 16'd1;
			Monopulse_data1 	<= Monopulse_data[Count-2];
		end
	end
	else if(!FeatureExtraction_flag)
		Count 					<= 0;
	else begin
		Count 					<= Count;
	end
end


endmodule
