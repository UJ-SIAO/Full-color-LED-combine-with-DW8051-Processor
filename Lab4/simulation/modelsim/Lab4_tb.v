`timescale 1 ns / 1 ns 
module Lab4_tb();
	reg clk;
	reg rst_n;
	reg KEY0;
	reg KEY1;
	wire dout;



	Top8051	u(	
			.clk(clk),
			.rst_n(rst_n),
			.key1(KEY1),
			.key0(KEY0),
			.dout(dout)
			);

   
   
	always
	begin
		#10 clk=~clk;
	end	
   
   

	initial
	begin
		rst_n=1;
		clk=1;
		KEY0=1;
		KEY1=1;
		#10
		rst_n=0;
		#10
		rst_n=1;
		
		#5_000_000;
		press_key0;
		press_key0;
		press_key0;
		press_key0;
		press_key1;
		press_key1;
		press_key0;
		press_key1;
		press_key0;
		press_key0;
		press_key0;
		press_key0;
		press_key1;
	end
	
	task press_key0;
	begin
		KEY0 = 0;
			#1_000_000;
		KEY0=1;
		#50_000;
	end
	endtask
	   
	task press_key1;
	begin
		KEY1 = 0;
			#1_000_000;
		KEY1=1;
		#50_000;
	end
	endtask
endmodule
