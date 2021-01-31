module LED_v2(
			clk,
			rst_n,
			sfr_addr,
			led_sfr_cs,
			led_data_in,
			led_data_out,
			sfr_wr,
			sfr_rd,
			dout
			);

input clk;
input rst_n;
input [7:0]sfr_addr;
input [7:0]led_data_in;
input sfr_wr;
input sfr_rd;

output led_sfr_cs;
output [7:0]led_data_out;
output dout;

wire led_sfr_cs;
reg [7:0]led_data_out;
reg dout;

wire led_control_cs;
wire red_cs;
wire green_cs;
wire blue_cs;
wire key_status_cs;
wire led_control_wr;
wire led_control_rd;
wire red_wr;
wire green_wr;
wire blue_wr;


reg  [4:0]led_control_data;
wire [23:0]data_temp;
reg	 [7:0]blue_data[8:0];
reg	 [7:0]red_data[8:0];
reg	 [7:0]green_data[8:0];
reg  [3:0]led;
reg  [3:0]led_temp;
reg  [31:0]logic_count;
reg  [4:0]bit_count;
reg  start;


assign led_control_cs	= (sfr_addr==8'hC2) ? 1: 0 ;
assign red_cs 			= (sfr_addr==8'hC3) ? 1: 0 ;
assign green_cs 		= (sfr_addr==8'hC4) ? 1: 0 ;
assign blue_cs 			= (sfr_addr==8'hC5) ? 1: 0 ;
assign key_status_cs 	= (sfr_addr==8'hC6) ? 1: 0 ;

assign led_control_wr	= led_control_cs	& sfr_wr ;
assign red_wr			= red_cs 			& sfr_wr ;
assign green_wr			= green_cs 			& sfr_wr ;
assign blue_wr			= blue_cs			& sfr_wr ;

always@(posedge clk or negedge rst_n) begin //read control
	if(!rst_n)
		led_control_data<=0;
	else begin	
		if(led_control_wr)begin
			led	<= led_data_in[2:0];
			led_control_data[4]		<= led_data_in[4]  ; 		
		end
	end
end

always@(posedge clk or negedge rst_n) begin 
	if(!rst_n)begin
	end
	else begin
		if(red_wr)
			red_data[led]<=led_data_in;
		else if(green_wr)
			green_data[led]<=led_data_in;
		else if(blue_wr)
			blue_data[led]<=led_data_in;
		else begin
			red_data[8]		<=red_data[led];
			green_data[8]	<=green_data[led];
			blue_data[8]	<=blue_data[led];
		end
	end
end

always@(posedge clk or negedge rst_n) begin 
	if(!rst_n)
		led_temp<=0;
	else begin
		if( bit_count == 24 )
			led_temp<=led_temp+1;
		else if (start == 0 )
			led_temp<=0;
	end
end

assign data_temp[7:0]	= blue_data[led_temp];
assign data_temp[15:8]	= red_data[led_temp];
assign data_temp[23:16]	= green_data[led_temp];

always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		logic_count<=0;
	else begin
		if(logic_count >= 63 && led_temp <= led)
			logic_count<=0;
		else if(start)
			logic_count<=logic_count+1;
	end
end

always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		start<=0;
	else begin
		if(led_control_data[4] == 1)
			start<=1;
		else if (led < led_temp && logic_count == 63)
			start<=0;
		
	end
end

always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		dout<=0;
	else begin
		if(start && led_temp <= led)begin
			if(data_temp[23-bit_count])begin
				if(logic_count<=40)
					dout<=1;
				else
					dout<=0;
			end
			else begin
				if(logic_count<=20)
					dout<=1;
				else
					dout<=0;
			end		
		end
		else
			dout <= 0;
	
	end
end

always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		bit_count<=0;
	else begin
		if(logic_count == 63 && led_temp <= led)
			bit_count<=bit_count+1;
		else if (bit_count == 24)
			bit_count<=0;
			
	end
end


endmodule