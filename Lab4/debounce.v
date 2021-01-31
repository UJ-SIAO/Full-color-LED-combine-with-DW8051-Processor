module  debounce (
	clk,
	rst,
	key_in,
	key_out
);

input clk;
input rst;
input key_in;
output key_out;

reg key_out;
reg [17:0]debounce;
reg flag=1'b0;
reg buff1;
reg buff2;
reg buff3;
reg buff4;

always@(posedge clk or negedge rst)
begin
	if(!rst)
			debounce[17:0]=18'b0;
	else
	begin
		if(debounce[17:0]!=18'd250)//250000
		begin
			debounce[17:0]<=debounce+1;
			flag<=1'b0;
		end
		else
		begin
			debounce[17:0]<=18'b0;
			flag<=1'b1;
		end
	end
end

always@(posedge clk or negedge rst)
begin
	if(!rst)
	begin
		buff1<=1;
		buff2<=1;
		buff3<=1;
		buff4<=1;
	end
	else
	begin
		if(flag)
		begin
			buff1<=key_in;
			buff2<=buff1;
			buff3<=buff2;
			buff4<=buff3;
		end
		else
		begin 
			buff1<=buff1;
			buff2<=buff2;
			buff3<=buff3;
			buff4<=buff4;
		end
	end
end
always@(posedge clk or negedge rst)
begin
	if(!rst)
		key_out<=1;
	else
	begin
		if(!buff1 && !buff2 && !buff3 && !buff4)
			key_out<=0;
		else
			key_out<=1;
	end
end
endmodule 