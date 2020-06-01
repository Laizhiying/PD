module Phase
(
	Clk_Phase,
	Rst,
	Signal_50HZ,
	StartSample,
	DDR_State,
	// sync_extern_out,
	sync_led,
	Period_count,
	OnePeriodFlag,
	OneSampleFlag
);

input 					Clk_Phase;
input					Rst;
input					Signal_50HZ;
input 					StartSample;
input [3:0] 			DDR_State;

output 					sync_led;
(*mark_debug="true"*)output reg [5:0]			Period_count;
(*mark_debug="true"*)output 					OnePeriodFlag;
(*mark_debug="true"*)output reg					OneSampleFlag;	


reg [1:0] 				sync_state;		
reg [7:0] 				sync_freq;	


/********生成10k的时钟对工频相位检测*********/
/*同步相位的上升沿约为20us，至少以50khz的频率进行检测，采用10khz*/
reg [13:0]		Freq10k_count;
reg 			clk_10k;
parameter 		PERIOD_10K = 13'd5000;

always@(posedge Clk_Phase or negedge Rst)
if(!Rst)begin
	clk_10k <= ~clk_10k;
	Freq10k_count <= 14'd0;
end
else begin
	if(Freq10k_count < PERIOD_10K)begin
		Freq10k_count <= Freq10k_count + 14'd1;
	end
	else begin
		clk_10k <= ~clk_10k;
		Freq10k_count <= 14'd0;
	end
end


/********利用上面生成的10khz的时钟对工频周期进行同步**********/
// reg [5:0]		Period_count;	
reg 			sync_clk_reg1 ;
reg 			sync_clk_reg2 ;
reg 			sync_clk_reg3 ;
wire 			sync_clk_out ;
always @ (posedge clk_10k or negedge Rst)//10kµÄÍ¬²½ÐÅºÅ
begin
	if(!Rst)
		sync_clk_reg1 <= 1'b0 ;
	else
		sync_clk_reg1 <= Signal_50HZ ;
end
always @ (posedge clk_10k or negedge Rst)
begin
	if(!Rst)
		sync_clk_reg2 <= 1'b0 ;
	else
		sync_clk_reg2 <= sync_clk_reg1 ;
end
always @ (posedge clk_10k or negedge Rst)
begin
	if(!Rst)
		sync_clk_reg3 <= 1'b0 ;
	else
		sync_clk_reg3 <= sync_clk_reg2 ;
end
assign sync_clk_out = sync_clk_reg1&sync_clk_reg2&sync_clk_reg3 ;


/*******用100mhz检测同步后的工频周期的上升沿********/
reg 			clk50hz_rise1;
reg 			clk50hz_rise2;
wire 			clk50hz_rise;
always@(posedge Clk_Phase or negedge Rst)
begin
	if(!Rst)begin
		clk50hz_rise1 		<= 0;
		clk50hz_rise2 		<= 0;
	end
	else begin
		clk50hz_rise1 		<= sync_clk_out;
		clk50hz_rise2 		<= clk50hz_rise1;
	end
end
assign clk50hz_rise 		=  clk50hz_rise1&(~clk50hz_rise2);


/********根据上升沿计算第几个工频周期***********/
// reg [5:0] 		Period_count;
always@(posedge Clk_Phase or negedge Rst)
begin
	if(!Rst)begin
		Period_count 		<= 0;
	end
	else if(DDR_State == 1)begin
		Period_count 		<= 6'd0;
	end
	else if(clk50hz_rise)begin
		Period_count 		<= Period_count + 6'd1;
	end	
	else begin
		Period_count 		<= Period_count;
	end
end


/*******当到达25个周期时表示一次采样结束********/
parameter 		ONESAMPLECOUNT = 6'd25;
always@(posedge Clk_Phase or negedge Rst)
begin
	if(!Rst)begin
		OneSampleFlag 		<= 0;
	end
	else if(DDR_State == 1)begin
		OneSampleFlag 		<= 0;
	end
	else if(Period_count == ONESAMPLECOUNT)begin
		OneSampleFlag 		<= 1;
	end
	else begin
		OneSampleFlag 		<= 0;
	end
end

/****外部工频周期的LED显示****/
reg [7:0] 			temp ;
reg 				sync_led_r ;
always @ (posedge sync_clk_out or negedge Rst)
begin
    if(!Rst)begin
        temp 				<= 8'd0 ;
        sync_led_r 			<= 1'd1 ;
    end
    else begin
        if(temp<25)begin
            temp 			<= temp +1'b1 ;
        end
        else begin
		    sync_led_r 		<= ~sync_led_r ;
            temp 			<= 8'd0 ;
		end
    end
end



// assign sync_extern_out 		= sync_clk_out;
assign sync_led 			= sync_led_r;
assign OnePeriodFlag 		= clk50hz_rise;

endmodule
