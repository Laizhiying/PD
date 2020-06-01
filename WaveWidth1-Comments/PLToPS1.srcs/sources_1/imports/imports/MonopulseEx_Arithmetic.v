module MonopulseEx_Arithmetic
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
	Pulse_point_num,		//鏈鍗曡剦鍐茬殑閲囨牱鐐规暟
	FeatureExtraction_flag,			//灏嗘彁鍙栫殑鍗曡剦鍐茬殑涓暟浠ュ強鍗曡剦鍐查噰鏍风偣閫佸幓鐗瑰緛鎻愬彇
	FeatureExtraction_flag_reg,
	WaveState,
	Monopulse_data_1,
	Monopulse_data_00,
	Monopulse_data_01,
	Period_condition,
	ReadPosition,
	MonopulsePosition,

	/************************/
	clk_arith,
	Monopulse_num,		 //涓€涓懆鏈熷唴鍗曡剦鍐茬殑涓暟
	Front_area, //波前面积
	Behind_area, //波后面积
	Total_area, //总面��
	Front_Width,
	Behind_Width,
	Total_Width,
	Peak_value, //最大��
	Second_moment, //二阶��
	Third_moment, //三阶��
	Fourth_moment, //四阶��
	Read_num,
	Mean_value,
	Mean_value_remainders,
	ii,
	Square_data,
	Arithmetic_State,
	Read_Over_flag,
	Count,
	time_cnt,
	time_cnt_n,
	Monopulse_num_reg
	// Over_flag
	
);

input 					Clk;
input					Rst;
input					Extract_en;
input	[15:0]			Data_in;
input   [5:0] 			Period_count;
input   [31:0] 			ReadPosition;
input   [3:0] 			DDR_State;
input   [7:0]			MonopulseExThreshould;
input   [7:0]			MonopulseExHold;
input   [7:0]			MonopulseMultiThreshould;
input   [7:0]			MonopulseEndHold;
input  	[7:0]           GentalThreshould;
input  	[7:0]           GentalThreshouldNum;

output 	[15:0]			Monopulse_data1;
output 					FeatureExtraction_flag;
output 					FeatureExtraction_flag_reg;
output 	[15:0] 			Pulse_point_num;
output  [7:0]			Monopulse_data_01;
output  [7:0]			Monopulse_data_00;
output 	[1:0]			WaveState;
output 	[7:0]			Monopulse_data_1;
output  [15:0] 			Period_condition;
output  [31:0] 			MonopulsePosition;

/*********************************************/
input 					clk_arith;
output  [15:0]			Front_area;
output  [15:0]			Behind_area;
output  [15:0]			Total_area;
output  [15:0]			Front_Width;
output  [15:0]			Behind_Width;
output  [15:0]			Total_Width;
output  [7:0]			Peak_value;
output  [23:0]			Second_moment;
output  [32:0]			Third_moment;
output  [40:0]			Fourth_moment;
output 	[15:0]			Monopulse_num;
output  [15:0]			Monopulse_num_reg;
output  [15:0] 			Read_num; //从DDR2中读取的个数
output  [7:0] 			Mean_value;
output  [7:0] 			Mean_value_remainders;
output  [20:0] 			Square_data;
output  [15:0]			ii;
output  [2:0] 			Arithmetic_State;
output 					Read_Over_flag;
output	[15:0]			Count;
output 	[15:0]			time_cnt;
output 	[15:0]			time_cnt_n;
// output 					Over_flag;


Monopulse_extraction_1 Monopulse_extraction_1
(
	.Clk                            (Clk),
	.Rst                            (Rst),
	.Extract_en                     (Extract_en),
	.Data_in                        (Data_in),
	.Period_count                   (Period_count),
	.Monopulse_data1                (Monopulse_data1),
	.DDR_State                      (DDR_State),
	.MonopulseExThreshould 			(MonopulseExThreshould),
	.MonopulseExHold 				(MonopulseExHold),
	.MonopulseMultiThreshould       (MonopulseMultiThreshould),
  	.MonopulseEndHold               (MonopulseEndHold),
  	.GentalThreshould               (GentalThreshould),
    .GentalThreshouldNum            (GentalThreshouldNum),
	.Pulse_point_num                (Pulse_point_num),		//本次单脉冲的采样点数
//	.Monopulse_num,		 //一个周期内单脉冲的个数
	.FeatureExtraction_flag         (FeatureExtraction_flag),			//将提取的单脉冲的个数以及单脉冲采样点送去特征提取
	.FeatureExtraction_flag_reg     (FeatureExtraction_flag_reg),
	.WaveState                      (WaveState),
	.Monopulse_data_1               (Monopulse_data_1),
	.Monopulse_data_00              (Monopulse_data_00),
	.Monopulse_data_01              (Monopulse_data_01),
	.Period_condition               (Period_condition),
	.Read_Over_flag 			    (Read_Over_flag),
	.ReadPosition 					(ReadPosition),
	.MonopulsePosition				(MonopulsePosition),
	.Count 							(Count)
	
	
);

					
Arithmetic1 Arithmetic1
(
	.Clk_arithmetic                 (Clk),
	.clk_arith 						(clk_arith),
	.Rst 						    (Rst),
	.Monopulse_data_in 			    (Monopulse_data1), //单脉冲从ddr2中读��
	.GentalThreshould               (GentalThreshould),
	.Monopulse_num 				    (Monopulse_num), //单脉冲的个数从ddr2中提��
	.Front_area                     (Front_area), //波前面积
	.Behind_area                    (Behind_area), //波后面积
	.Total_area                     (Total_area), //总面��
	.Front_Width 					(Front_Width),
	.Behind_Width 					(Behind_Width),
	.Total_Width 					(Total_Width),
	.Peak_value                     (Peak_value), //最大��
	.Second_moment                  (Second_moment), //二阶��
	.Third_moment                   (Third_moment), //三阶��
	.Fourth_moment                  (Fourth_moment), //四阶��
	.Read_num                       (Read_num),
	.Mean_value                     (Mean_value),
	.Mean_value_remainders          (Mean_value_remainders),
	.ii                             (ii),
	.Square_data                    (Square_data),
	.FeatureExtraction_flag         (FeatureExtraction_flag),			//将提取的单脉冲的个数以及单脉冲采样点送去特征提取
	.FeatureExtraction_flag_reg     (FeatureExtraction_flag_reg),
	.Arithmetic_State               (Arithmetic_State),
	.Read_Over_flag 			    (Read_Over_flag),
	.time_cnt 						(time_cnt),
	.time_cnt_n 					(time_cnt_n),
	.Monopulse_num_reg				(Monopulse_num_reg)
	// .Over_flag 						(Over_flag)
	//.Period_flag 				   (Period_flag)
);

endmodule
