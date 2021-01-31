module LED(
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

reg [31:0]logic_count; 
reg logic1;
reg logic0;
reg led_rest;
reg [31:0]led_rest_count;
reg addr_0xC2_led_control;
reg addr_0xC3_red;
reg addr_0xC4_green;
reg addr_0xC5_blue;
reg addr_0xC6_key_status;
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
wire key_status_wr;
reg [23:0]data_temp;
reg [23:0]data[7:0];
reg [23:0]data_t[7:0];
reg [23:0]data_out;
reg [7:0]red_data;
reg [7:0]green_data;
reg [7:0]blue_data;
reg [7:0]led_control_data;
reg start;
reg bits;
reg trest;
reg [9:0]bit_count;
reg led_count;
reg reset;
reg [2:0]led;


reg [3:0]state;
reg [3:0]next_state;
/*parameter count=0;
parameter one_wave=1;
parameter zero_wave=2;
parameter rst=3;*/
parameter rst=8;
parameter led0=0;
parameter led1=1;
parameter led2=2;
parameter led3=3;
parameter led4=4;
parameter led5=5;
parameter led6=6;
parameter led7=7;

 
//logic 0 H=>0.4u=>20 + L=>0.85u>=>43
//logic 1 H=>0.8u=>40 + L=>0.45u=>23
//reset 60us=>3000
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		logic_count<=0;
	else begin
		if(start)begin
			if(logic_count==63)
				logic_count<=0;
			else
				logic_count<=logic_count+1;
		end
		else
			logic_count<=0;
	end
end

always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		led_rest_count<=0;
	else begin
		if(reset)begin
			led_rest_count<=led_rest_count+1;
		end
		else
			led_rest_count<=0;
	end
end


assign led_control_cs	= (sfr_addr==8'hC2) ? 1: 0 ;
assign red_cs 			= (sfr_addr==8'hC3) ? 1: 0 ;
assign green_cs 		= (sfr_addr==8'hC4) ? 1: 0 ;
assign blue_cs 			= (sfr_addr==8'hC5) ? 1: 0 ;
assign key_status_cs 	= (sfr_addr==8'hC6) ? 1: 0 ;
assign led_sfr_cs		= key_status_cs|blue_cs|green_cs|red_cs|led_control_cs;

assign led_control_wr	= led_control_cs	& sfr_wr ;
assign red_wr			= red_cs 			& sfr_wr ;
assign green_wr			= green_cs 			& sfr_wr ;
assign blue_wr			= blue_cs			& sfr_wr ;
assign key_status_wr	= key_status_cs 	& sfr_wr ;
assign led_control_rd	= led_control_cs	& sfr_rd ;

always@(posedge clk or negedge rst_n) begin //read red
	if(!rst_n)
		red_data<=0;
	else begin
		if(red_wr)
			red_data<=led_data_in;
		else
			red_data<=red_data;
	end
end
always@(posedge clk or negedge rst_n) begin //read green
	if(!rst_n)
		green_data<=0;
	else begin
		if(green_wr)
			green_data<=led_data_in;
		else
			green_data<=green_data;
	end
end
always@(posedge clk or negedge rst_n) begin //read blue
	if(!rst_n)
		blue_data<=0;
	else begin
		if(blue_wr)
			blue_data<=led_data_in;
		else
			blue_data<=blue_data;
	end
end

/*always@(posedge clk or negedge rst_n) begin //combine GRB
	if(!rst_n)
		data_temp<=1;
	else begin
		if(red_wr || green_wr || blue_wr)begin
			data_temp[7:0]<=blue_data[7:0];
			data_temp[15:8]<=red_data[7:0];
			data_temp[23:16]<=green_data[7:0];
		end
		else
			data_temp<=data_temp;
	end
end*/

/*always@(posedge clk or negedge rst_n) begin 
	if(!rst_n)begin
		data_t[0]<=0;
		data_t[1]<=0;
		data_t[2]<=0;
		data_t[3]<=0;
		data_t[4]<=0;
		data_t[5]<=0;
		data_t[6]<=0;
		data_t[7]<=0;
		led<=0;
	end
	else begin
		if(led_control_data[2:0]==0 && led_control_data[4])begin	
			led<=0;
			if(data_t[0] == data[0])
				data_t[0]<=data_t[0];
			else
				data_t[0]<=data[0];	
		end
		else if (led_control_data[2:0]==1 && led_control_data[4])begin 
			led<=1;
			if(data_t[1] == data[1])begin
				data_t[1]<=data_t[1];
			end
			else begin
				data_t[1]<=data[1];
			end
		end
		else if (led_control_data[2:0]==2 && led_control_data[4])begin 
			led<=2;
			if(data_t[2] == data[2])begin
				data_t[2]<=data_t[2];
			end
			else begin
				data_t[2]<=data[2];
			end
		end
		else if (led_control_data[2:0]==3 && led_control_data[4])begin 
			led<=3;
			if(data_t[3] == data[3])begin
				data_t[3]<=data_t[3];
			end
			else begin
				data_t[3]<=data[3];
			end
		end
		else if (led_control_data[2:0]==4 && led_control_data[4])begin 
			led<=4;
			if(data_t[4] == data[4])begin
				data_t[4]<=data_t[4];
			end
			else begin
				data_t[4]<=data[4];
			end
		end
		else if (led_control_data[2:0]==5 && led_control_data[4])begin 
			led<=5;
			if(data_t[5] == data[5])begin
				data_t[5]<=data_t[5];
			end
			else begin
				data_t[5]<=data[5];
			end
		end
		else if (led_control_data[2:0]==6 && led_control_data[4])begin 
			led<=6;
			if(data_t[6] == data[6])begin
				data_t[6]<=data_t[6];
			end
			else begin
				data_t[6]<=data[6];
			end
		end
		else if (led_control_data[2:0]==7 && led_control_data[4])begin 
			led<=7;
			if(data_t[7] == data[7])begin
				data_t[7]<=data_t[7];
			end
			else begin
				data_t[7]<=data[7];
			end
		end
	end
end*/

always@(posedge clk or negedge rst_n) begin 
	if(!rst_n)begin
		data_t[0]<=0;
		data_t[1]<=0;
		data_t[2]<=0;
		data_t[3]<=0;
		data_t[4]<=0;
		data_t[5]<=0;
		data_t[6]<=0;
		data_t[7]<=0;
		led<=0;
	end
	else begin
		if(state == led0)begin
			data_t[0]<=data[0];
			data_t[1]<=data[1];
			data_t[2]<=data[2];
			data_t[3]<=data[3];
			data_t[4]<=data[4];
			data_t[5]<=data[5];
			data_t[6]<=data[6];
			data_t[7]<=data[7];	
		end
		else begin
			data_t[0]<=data_t[0];
			data_t[1]<=data_t[1];
			data_t[2]<=data_t[2];
			data_t[3]<=data_t[3];
			data_t[4]<=data_t[4];
			data_t[5]<=data_t[5];
			data_t[6]<=data_t[6];
			data_t[7]<=data_t[7];	
		end
	end
end

always@(posedge clk or negedge rst_n) begin 
	if(!rst_n)begin
		data[0]<=0;
		data[1]<=0;
		data[2]<=0;
		data[3]<=0;
		data[4]<=0;
		data[5]<=0;
		data[6]<=0;
		data[7]<=0;
	end
	else begin
		if(led_control_data[2:0]==0)begin
			data[0]<={green_data,red_data,blue_data};
			data[1]<=0;
			data[2]<=0;
			data[3]<=0;
			data[4]<=0;
			data[5]<=0;
			data[6]<=0;
			data[7]<=0;	
		end
		else if(led_control_data[2:0]==1)begin
			
			data[1]<={green_data,red_data,blue_data};
			data[2]<=0;
			data[3]<=0;
			data[4]<=0;
			data[5]<=0;
			data[6]<=0;
			data[7]<=0;	
		end
		else if(led_control_data[2:0]==2)begin

			data[2]<={green_data,red_data,blue_data};
			data[3]<=0;
			data[4]<=0;
			data[5]<=0;
			data[6]<=0;
			data[7]<=0;		
		end
		else if(led_control_data[2:0]==3)begin

			data[3]<={green_data,red_data,blue_data};
			data[4]<=0;
			data[5]<=0;
			data[6]<=0;
			data[7]<=0;	
		end
		else if(led_control_data[2:0]==4)begin

			data[4]<={green_data,red_data,blue_data};
			data[5]<=0;
			data[6]<=0;
			data[7]<=0;	
		end
		else if(led_control_data[2:0]==5)begin

			data[5]<={green_data,red_data,blue_data};
			data[6]<=0;
			data[7]<=0;	
		end
		else if(led_control_data[2:0]==6)begin

			data[6]<={green_data,red_data,blue_data};
			data[7]<=0;
		end
		/*else if(led_control_data[2:0]==7 && state==rst )begin
			data[0]<=0;
			data[1]<=0;
			data[2]<=0;
			data[3]<=0;
			data[4]<=0;
			data[5]<=0;
			data[6]<=0;
			data[7]<=0;	
		end*/
		else if(led_control_data[2:0]==7)begin

			data[7]<={green_data,red_data,blue_data};
		end

	end
end

always@(posedge clk or negedge rst_n) begin //read control
	if(!rst_n)
		led_control_data<=0;
	else begin
		
		if(led_control_wr)begin
			led_control_data[2:0]	<= led_data_in[2:0];
			led_control_data[4]		<= led_data_in[4]  ; 		
		end
		/*else if (state == rst )
			led_control_data<=0;*/
		else
			led_control_data<=led_control_data;
	end
end

always@(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		dout<=0;
		start<=0;
		reset<=0;
		data_out<=0;
	end
	else begin
		case(state)
			rst:begin
				next_state <= (data_t[led] == data[led]) ? rst : led0 ;	//(led_rest_count<3000) ? rst : led0 ;
				dout<=0;
				start<=0;
				reset<=1;
			end
			led0:begin
				next_state <= led1;
				start<=1;
				data_out<=data_t[0];
				if(data_out[23-bit_count])begin
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
			led1:begin
				next_state <= led2;
				start<=1;
				data_out<=data_t[1];
				if(data_out[23-bit_count])begin
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
			led2:begin
				next_state <= led3;
				start<=1;
				data_out<=data_t[2];
				if(data_out[23-bit_count])begin
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
			led3:begin
				next_state <= led4;
				start<=1;
				data_out<=data_t[3];
				if(data_out[23-bit_count])begin
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
			led4:begin
				next_state <= led5;
				start<=1;
				data_out<=data_t[4];
				if(data_out[23-bit_count])begin
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
			led5:begin
				next_state <= led6;
				start<=1;
				data_out<=data_t[5];
				if(data_out[23-bit_count])begin
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
			led6:begin
				next_state <= led7;
				start<=1;
				data_out<=data_t[6];
				if(data_out[23-bit_count])begin
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
			led7:begin
				next_state <= rst;
				start<=1;
				data_out<=data_t[7];
				if(data_out[23-bit_count])begin
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
		endcase
	end
end

always@(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		state<=rst;
		bit_count<=0;
	end
	else begin
		if(state==rst)begin
			bit_count<=0;
			if(led_control_data[4])
				state<=next_state;
		end
		else if (state == led0)begin
			if(logic_count==63 && bit_count==23)begin
				state<=next_state;
				bit_count<=0;
			end
			else if(logic_count == 63)
				bit_count<=bit_count+1;			
		end
		else if (state == led1)begin
			if(logic_count==63 && bit_count==23)begin
				state<=next_state;
				bit_count<=0;
			end
			else if(logic_count == 63)
				bit_count<=bit_count+1;			
		end
		else if (state == led2)begin
			if(logic_count==63 && bit_count==23)begin
				state<=next_state;
				bit_count<=0;
			end
			else if(logic_count == 63)
				bit_count<=bit_count+1;			
		end
		else if (state == led3)begin
			if(logic_count==63 && bit_count==23)begin
				state<=next_state;
				bit_count<=0;
			end
			else if(logic_count == 63)
				bit_count<=bit_count+1;			
		end
		else if (state == led4)begin
			if(logic_count==63 && bit_count==23)begin
				state<=next_state;
				bit_count<=0;
			end
			else if(logic_count == 63)
				bit_count<=bit_count+1;			
		end
		else if (state == led5)begin
			if(logic_count==63 && bit_count==23)begin
				state<=next_state;
				bit_count<=0;
			end
			else if(logic_count == 63)
				bit_count<=bit_count+1;			
		end
		else if (state == led6)begin
			if(logic_count==63 && bit_count==23)begin
				state<=next_state;
				bit_count<=0;
			end
			else if(logic_count == 63)
				bit_count<=bit_count+1;			
		end
		else if (state == led7)begin
			if(logic_count==63 && bit_count==23)begin
				state<=next_state;
				bit_count<=0;
			end
			else if(logic_count == 63)
				bit_count<=bit_count+1;			
		end
	end
end









endmodule
