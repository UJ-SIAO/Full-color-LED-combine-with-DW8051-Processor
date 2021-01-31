module Lab4(clk,
			rst_n,
			key1,
			key0,
			dout);

input clk,rst_n;
input key0;
input key1;
output dout;

//----------------------------------------
  reg por_n; 
   wire rst_n; 
   reg test_mode_n; 
   wire stop_mode_n; 
   wire idle_mode_n; 
   wire [7:0] sfr_addr; 
   wire [7:0] sfr_data_out; 
   wire [7:0] sfr_data_in; 
   wire sfr_wr; 
   wire sfr_rd; 
   wire [15:0] mem_addr; 
   wire [7:0] mem_data_out; 
   wire [7:0] mem_data_in; 
   wire mem_wr_n; 
   wire mem_rd_n; 
   wire mem_pswr_n;    
   wire mem_psrd_n; 
   wire mem_ale; 
   wire int0_n; 
   wire int1_n; 
   wire int2; 
   wire int3_n; 
   wire int4; 
   wire int5_n; 
   wire pfi; 
   wire wdti; 
   wire rxd0_in; 
   wire rxd0_out, txd0; 
   wire rxd1_in; 
   wire rxd1_out, txd1; 
   wire t0; 
   wire t1; 
   wire t2; 
   wire t2ex; 
   wire t0_out, t1_out, t2_out; 
   wire port_pin_reg_n, p0_mem_reg_n, p0_addr_data_n, p2_mem_reg_n; 
   wire [7:0] iram_addr, iram_data_out, iram_data_in; 
   wire iram_rd_n, iram_we1_n, iram_we2_n; 
   wire [12:0] irom_addr; 
   wire [7:0] irom_data_out; 
   wire irom_rd_n, irom_cs_n; 
   wire [7:0] P0,P1,P2,P3;
DW8051_core u0 ( 
               .clk (clk), 
               .por_n (rst_n), 
               .rst_in_n (rst_n), 
               .rst_out_n (rst_out_n), 
               .test_mode_n (1'b1), 
               .stop_mode_n (stop_mode_n), 
               .idle_mode_n (idle_mode_n), 
               .sfr_addr (sfr_addr), 
               .sfr_data_out (sfr_data_out), 
               .sfr_data_in (sfr_data_in), 
               .sfr_wr (sfr_wr), 
               .sfr_rd (sfr_rd), 
               .mem_addr (mem_addr), 
               .mem_data_out (mem_data_out), 
               .mem_data_in (mem_data_in), 
               .mem_wr_n (mem_wr_n), 
               .mem_rd_n (mem_rd_n), 
               .mem_pswr_n (mem_pswr_n), 
               .mem_psrd_n (mem_psrd_n), 
               .mem_ale (mem_ale), 
               .mem_ea_n (1'b1),
               .int0_n (int0_n), 
               .int1_n (int1_n), 
               .int2 (int2), 
               .int3_n (int3_n), 
               .int4 (int4), 
               .int5_n (int5_n), 
               .pfi (pfi), 
               .wdti (wdti), 
               .rxd0_in (rxd0_in), 
               .rxd0_out (rxd0_out), 
               .txd0 (txd0), 
               .rxd1_in (rxd1_in), 
               .rxd1_out (rxd1_out), 
               .txd1 (txd1), 
               .t0 (t0), 
               .t1 (t1), 
               .t2 (t2), 
               .t2ex (t2ex), 
               .t0_out (t0_out), 
               .t1_out (t1_out), 
               .t2_out (t2_out), 
               .port_pin_reg_n (port_pin_reg_n), 
               .p0_mem_reg_n (p0_mem_reg_n), 
               .p0_addr_data_n (p0_addr_data_n), 
               .p2_mem_reg_n (p2_mem_reg_n), 
               .iram_addr (iram_addr), 
               .iram_data_out (iram_data_out), 
               .iram_data_in (iram_data_in), 
               .iram_rd_n (), 
               .iram_we1_n (iram_we1_n), 
               .iram_we2_n (iram_we2_n), 
               .irom_addr (irom_addr), 
               .irom_data_out (irom_data_out), 
               .irom_rd_n (irom_rd_n), 
               .irom_cs_n (irom_cs_n) 
               );
			   
   int_mem      u3_int_mem(
                        .clk(clk),
                        .addr(iram_addr),
                        .data_in(iram_data_in),
                        .data_out(iram_data_out),
                        .we1_n(iram_we1_n),
                        .we2_n(iram_we2_n),
                        .rd_n(iram_rd_n));  
                        
                                        
   ext_mem      u2_ext_mem(
                        .addr(mem_addr),
                        .data_in(mem_data_out),
                        .data_out(mem_data_in),
                        .wr_n(mem_wr_n),
                        .rd_n(mem_rd_n));    
                        
                          
  rom_mem       u4_rom_mem(
                        .addr(irom_addr),
                        .data_out(irom_data_out),                    
                        .rd_n(irom_rd_n),
                        .cs_n(irom_cs_n));                                                        

	 wire led_sfr_cs;
	  LED		LED1(
				.clk(clk),
				.rst_n(rst_n),
				.sfr_addr(sfr_addr),
				.led_sfr_cs(led_sfr_cs),
				.led_data_in(sfr_data_out),
				.led_data_out(),
				.sfr_wr(sfr_wr),
				.sfr_rd(sfr_rd),
				.dout(dout)
				);
	 wire key_sfr_cs;
	 Key		u_key(
						.clk(clk),
						.rst_n(rst_n),
						.key0(key0),
						.key1(key1),
						.sfr_addr(sfr_addr),
						.key_sfr_cs(key_sfr_cs),
						.key_data_in(),
						.key_data_out(sfr_data_in),
						.sfr_wr(sfr_wr),
						.sfr_rd(sfr_rd)
						);


endmodule