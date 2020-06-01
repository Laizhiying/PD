module Monopulse_extraction_1
(
	Clk,
	Rst,
	Extract_en,//开始提取单脉冲的使能
	Data_in,//输入数据
	Period_count,//周期数
	DDR_State,//ddr的状态
	MonopulseExThreshould,//单脉冲提取的阈值
	MonopulseExHold,//下降沿时小于单脉冲提取的阈值前的点数
	MonopulseMultiThreshould,//下降沿后又出现大于单脉冲提取的阈值，这之间的点数小于这个值
	MonopulseEndHold,
	GentalThreshould,//稳定值
  	GentalThreshouldNum,//小于稳定值的数量
	Monopulse_data1,//本次提取的单脉冲数据
	Pulse_point_num,//本次提取的单脉冲的点数
	Monopulse_num,//没用了
	FeatureExtraction_flag,//单脉冲提取结束标志
	FeatureExtraction_flag_reg,//特征提取结束标志
	WaveState,//单脉冲提取的状态
	Monopulse_data_1,//暂存数据
	Monopulse_data_00,//暂存数据，没啥用
	Monopulse_data_01,//暂存数据，没用
	Period_condition,//周期数
	Read_Over_flag,//没用
	ReadPosition,//没用
	MonopulsePosition,//相位信息
	Count//计数
	
);

input 					Clk;
input					Rst;
input					Extract_en;
input		[15:0]		Data_in;
input 		[5:0]  		Period_count;
input     				FeatureExtraction_flag_reg; //ç‰¹å¾æå–å®Œä¸º1
input 					Read_Over_flag;
input 		[31:0]      ReadPosition;
input 		[3:0] 		DDR_State;
input 		[7:0] 		MonopulseExThreshould;
input 		[7:0] 		MonopulseExHold;
input 		[7:0] 		MonopulseMultiThreshould;
input 		[7:0] 		MonopulseEndHold;
input  		[7:0]       GentalThreshould;
input  		[7:0]       GentalThreshouldNum;

output reg	[15:0]		Monopulse_data1; //å°†å•è„‰å†²é€ç»™ç‰¹å¾æå–æ¨¡å—ï¼Œç¬¬ä¸?ä¸ªæ•°æ®ä¸ºPulse_point_num
output reg	[5:0]		Monopulse_num;
output reg				FeatureExtraction_flag; //å•è„‰å†²æå–å®Œä¸?1

output reg	[15:0] 		Pulse_point_num; //æœ¬ä¸ªå•è„‰å†²çš„ä¸ªæ•°

output reg  [7:0]		Monopulse_data_01; //
output reg  [7:0]		Monopulse_data_00;

reg			[7:0]		Monopulse_data[0:250]; //保存提取的单脉冲的数据
output reg	[1:0]		WaveState;
reg			[1:0]		WaveState_reg;

output reg	[7:0]		Monopulse_data_1; //è¾“å…¥Data_inå…ˆèµ‹å€¼ç»™Monopulse_data_1
reg			[7:0]		Falling_edge_num;//小于阈值后的点数
reg			[7:0]		Gentle_num;//小于稳定值的点数
output reg 	[15:0]		Count;

output reg	[5:0] 		Period_condition;
reg			[5:0] 		Period_condition_reg;
output reg  [31:0] 		MonopulsePosition;
reg  		[31:0] 		MonopulsePosition_reg;
reg 		[2:0] 		PositionState;//一个周期到之后的状态（被修改过后可以取消，只有周期数了，没啥用）
reg 		[2:0] 		PositionState_reg;

parameter   PositionIDLE = 3'd0,
			Period_end = 3'd1,
			PositionGet1 = 3'd2,
			PositionGet2 = 3'd3;

//单脉冲提取的状态
parameter 	IDLE = 2'd0,
			RiseEdge = 2'd1,//大于阈值后进入
			FallingEdge = 2'd2;//小于阈值后进入

reg 			FeatureExtraction_flag_n;			

//相位清零
wire MonopulsePosition_clear;
assign MonopulsePosition_clear = (Data_in == 16'd256)&&(PositionState == PositionIDLE);

//从读取的数据计算相位
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

//当读取到256时表示下一个数据是周期（没有相位后只读周期数太麻烦，可修改或者直接删去，周期数是不需要的信息）
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
		    	PositionState_reg  					<= Period_end;//表示下一个状态是读取周期数
		    end
		    else begin
				PositionState_reg 					<= PositionState;
			end
		end
		Period_end:begin
			PositionState_reg 						<= PositionGet1;//下一个状态读取相位的前16位
		end
		PositionGet1:begin
			PositionState_reg 						<= PositionGet2;//下一个状态读取相位的后16位
		end
		PositionGet2:begin
			PositionState_reg 						<= PositionIDLE;//读取结束，返回
		end
		default:begin
			PositionState_reg 						<= PositionState;
		end
	endcase
else begin
	PositionState_reg 								<= PositionState;
end

//读取周期数
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

//单脉冲提取状态转移
always @ (posedge Clk or negedge Rst)
if(!Rst)begin
	WaveState 							<= IDLE;
end
else begin
	WaveState 							<= WaveState_reg;
end
always @ (*)
if(Extract_en&&(PositionState == PositionIDLE))begin//提取使能并且读取的数据不是一个周期后的后三个数据
	if((Data_in >= MonopulseExThreshould)&&(Data_in <= 16'd255)) //当读取的数据大于阈值并小于255时
	case(WaveState)
		IDLE:begin
			WaveState_reg 						<= RiseEdge;//状态由idle变为RiseEdge
		end
		RiseEdge:begin
			WaveState_reg 						<= WaveState;//如果原来就是RiseEdge，则不变
		end
		FallingEdge:		//如果原来是FallingEdge，判断如果两个大于阈值之间间隔点数小于MonopulseMultiThreshould，则判断为同一个脉冲，否则跳到IDLE
			if(Falling_edge_num < MonopulseMultiThreshould)begin //MonopulseMultiThreshould-10
				WaveState_reg 					<= RiseEdge;
			end
			else
				WaveState_reg 					<= IDLE;
		default: WaveState_reg 					<= WaveState;
	endcase
	else //当读取的数据小于阈值时
	case(WaveState)
		IDLE:begin
			WaveState_reg 						<= IDLE;//原来为IDLE，则不变
		end
		RiseEdge:begin	//原来为RiseEdge
			if((Pulse_point_num > MonopulseExHold)&&(Pulse_point_num < 100))//如果前面小于阈值前的点数大于MonopulseExHold，则跳到FallingEdge
				WaveState_reg 					<= FallingEdge;
			else
				WaveState_reg 					<= IDLE;//否则舍弃此单脉冲，跳到IDLE
		end
		FallingEdge:		//原来为FallingEdge，如果小于稳定值的点数大于GentalThreshouldNum，则判断单脉冲提取结束
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

//FeatureExtraction_flag：单脉冲提取结束，FeatureExtraction_flag的变化
always @ (posedge Clk or negedge Rst)
if(!Rst)begin
	FeatureExtraction_flag 				<= 0;
end
else begin
	FeatureExtraction_flag 				<= FeatureExtraction_flag_n;
end
always @ (*)
if((Gentle_num >= GentalThreshouldNum)&&(WaveState == FallingEdge))begin //MonopulseEndHold-20当单脉冲提取结束，FeatureExtraction_flag置1
	FeatureExtraction_flag_n 					<= 1;
end				
else if(FeatureExtraction_flag_reg)begin//当FeatureExtraction_flag_reg为1表示特征提取结束，FeatureExtraction_flag置0
	FeatureExtraction_flag_n 					<= 0;
end
else begin
	FeatureExtraction_flag_n 					<= FeatureExtraction_flag;
end

//保存单脉冲数据，计算单脉冲的点数，计算小于阈值后的点数，计算小于稳定值的点数；
//Monopulse_data[]保存单脉冲数据；
//Pulse_point_num保存单脉冲的点数，起始值为4，表示提前取大于阈值的前4个点；
//Falling_edge_num保存小于阈值后的点数；
//Gentle_num保存小于稳定值的点数；
always @ (posedge Clk or negedge Rst)
if(!Rst)begin
	Falling_edge_num 					<= 8'd0;
	Pulse_point_num   					<= 16'd4;
end
else if(Extract_en)begin//单脉冲提取使能后
	case(WaveState)
	IDLE:begin		
		Falling_edge_num                	<= 0;
		// Pulse_point_num   					<= 16'd4;
		if(FeatureExtraction_flag_reg)begin	//特征提取结束表示单脉冲已经全部发送完，数组复位，进不来这个if'语句，可删去
			//Pulse_point_num   				<= 16'd2;
			Monopulse_data[0] 				<= 0;
			Monopulse_data[1] 				<= 0;
			Monopulse_data[2] 				<= 0;
			Monopulse_data[3] 				<= 0;
			Monopulse_data[4] 				<= 0;
		end
		else
		if(!FeatureExtraction_flag)begin //这个条件是多余的，如果正常状态，Extract_en为1时FeatureExtraction_flag就为0，可删去
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

//将保存好的单脉冲数据发送给特征提取模块
(*mark_debug="true"*)wire [15:0] send_count;
assign send_count = Pulse_point_num+3;//发送的个数
always @ (posedge Clk or negedge Rst)
if(!Rst)begin
	Monopulse_data1 			<= 0;
	Count 						<= 0;	
end
else begin
	if(FeatureExtraction_flag&&(Count<=send_count))begin
		if(Count == 16'd0)begin
			Count 				<= Count + 16'd1;
			Monopulse_data1 	<= Pulse_point_num;//发送的第一个值为单脉冲的点数
		end
		else if(Count == 16'd1)begin//空出这俩周期是为了什么我也忘了。。。
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
