//`define FPGA
//`define FPGA_DEBUG

module chip_top(input  wire                  clk     ,
                input  wire                  rstn_ex ,
		        output                    dout        );

  /***************************signal**********************************/
  //interrupt
  wire                       int0_n       ;
  wire                       int1_n       ;
  
  //serial port 0
  wire                       rxd0_in      ;
  wire                       rxd0_out     ;
  wire                       txd0         ;
  
  //timer0/1
  wire                       t0           ;
  wire                       t1           ;
  wire                       t0_out       ;
  wire                       t1_out       ;
  
  //interal ram , no read enable signal
  wire [ 7:0]                ram_addr     ;
  wire [ 7:0]                ram_data_out ;
  wire [ 7:0]                ram_data_in  ;
  wire                       ram_wen      ;
  
  //interal rom
  wire [`ROM_ADDR_WIDTH-1:0] rom_addr     ;
  wire [ 7:0]                rom_data     ;
  wire                       rom_rd_n     ;
  
  //sfr signal
  wire [ 7:0]                sfr_addr;     
  wire [ 7:0]                sfr_data_out ;
  wire [ 7:0]                sfr_data_in  ;
  wire                       sfr_wr       ;
  wire                       sfr_rd       ;
  
  //external ram interface   or user-defined peripheral reg
  wire [15:0]                mem_addr     ;
  wire [ 7:0]                mem_data_out ;
  wire [ 7:0]                mem_data_in  ;
  wire                       mem_wr_n     ;
  wire                       mem_rd_n     ;

  //port  signal
  wire                       port_wr_n    ; 
  wire                       port_rd_n    ; 
  wire [ 6:0]                port_addr    ; 
  wire [ 7:0]                port_wr_data ;
  wire [ 7:0]                port_rd_data ;

  wire [`PRT_A_WID-1:0]      porta_d      ;
  wire [`PRT_A_WID-1:0]      porta_i      ;
  wire [`PRT_A_WID-1:0]      porta_o      ;
  wire [`PRT_B_WID-1:0]      portb_d      ;
  wire [`PRT_B_WID-1:0]      portb_i      ;
  wire [`PRT_B_WID-1:0]      portb_o      ;
  wire led_sfr_cs;
  /************************assignment***************************/
  //interrupt
  assign int0_n = 1'b1;
  assign int1_n = 1'b1;
  
  //serial port 0
  assign rxd0_in = 1'b0;
  
  //timer0/1
  assign t0 = 1'b1;
  assign t1 = 1'b1;
  
  //sfr signal
  //assign sfr_data_in = 8'b0;

  `ifdef FPGA_DEBUG
    wire jtag_rstn;
    wire tck;
    wire jtag_wr;
    wire [15:0] jtag_addr;
    wire [ 7:0] jtag_data;
    wire clk_sw;
    
    wire debug_ram_clk;
    
    assign debug_ram_clk = clk_sw ? tck : clk;
    
    assign rst_n = rstn_ex & jtag_rstn;
  `else
    assign rst_n = rstn_ex;
  `endif

  mcu u_mcu(
            .clk          (clk         ), 
            .por_n        (rstn_syn    ), 
            .rst_in_n     (rstn_syn    ), 
            .rst_out_n    (            ), 
            .test_mode_n  (1'b1        ), 
             
            .stop_mode_n  (            ), 
            .idle_mode_n  (            ),         
             
            //int
            .int0_n       (int0_n      ), 
            .int1_n       (int1_n      ), 
            .int2         (1'b0        ), 
            .int3_n       (1'b1        ), 
            .int4         (1'b0        ), 
            .int5_n       (1'b1        ), 
            
            .pfi          (1'b0        ),  //power failed
            .wdti         (1'b0        ),  //watchdog
            
            //serial port
            .rxd0_in      (rxd0_in     ), 
            .rxd0_out     (rxd0_out    ), 
            .txd0         (txd0        ), 
            
            .rxd1_in      (1'b0        ), 
            .rxd1_out     (            ), 
            .txd1         (            ), 
            
            //timer/counter input/output
            .t0           (t0          ), 
            .t1           (t1          ), 
            .t2           (1'b0        ), 
            .t2ex         (1'b0        ),
	    
            .t0_out       (t0_out      ), 
            .t1_out       (t1_out      ), 
            .t2_out       (            ), 
	    
            // interal ram interface
            .iram_addr    (ram_addr    ), 
            .iram_data_out(ram_data_out),  //mcu data to iram 
            .iram_data_in (ram_data_in ),  //iram data to mcu
            .iram_we_n    (ram_wen     ),
            
            // interal rom interface
            .irom_addr    (rom_addr    ), 
            .irom_data    (rom_data    ), 
            .irom_rd_n    (rom_rd_n    ),

	    //sfr interface
            .sfr_addr     (sfr_addr    ), 
            .sfr_data_out (sfr_data_out), 
            .sfr_data_in  (sfr_data_in ), 
            .sfr_wr       (sfr_wr      ), 
            .sfr_rd       (sfr_rd      ),
            
            //external ram interface or user-defined peripheral reg
            .mem_addr     (mem_addr    ), 
            .mem_data_out (mem_data_out), 
            .mem_data_in  (mem_data_in ), 
            .mem_wr_n     (mem_wr_n    ), 
            .mem_rd_n     (mem_rd_n    )
	                               );

  //mcu internal ram
  `ifndef FPGA
  ram     #(.data_width(8),.data_depth(256),.addr_width(8))
      u_ram(.clk (~clk        ),
            .addr(ram_addr    ),
	    .cen (1'b0        ),
	    .wen (ram_wen     ),
	    .d   (ram_data_out),
	    .q   (ram_data_in )
                              ); 
  `else
  ram u_ram(.address (ram_addr    ),
	    .clock   (~clk        ),
	    .data    (ram_data_out),
	    .wren    (~ram_wen    ),
	    .q       (ram_data_in )
	                          );
  `endif
        
  //mcu internal rom
  `ifndef FPGA  
    rom     #(.data_width(`ROM_DATA_WIDTH),.data_depth(`ROM_DATA_DEPTH),.addr_width(`ROM_ADDR_WIDTH))
        u_rom(.clk (clk         ),
              .addr(rom_addr    ),
              .cen (rom_rd_n    ),
              .q   (rom_data    )
                                );
  `else
    `ifndef FPGA_DEBUG
      rom u_rom(.address(rom_addr ),
                .clken  (~rom_rd_n),
                .clock  (clk      ),
                .q      (rom_data )
                                  );
    `else   //download hex from jtag to debug_ram_inst
      jtag_inst0 u_jtag_inst0(.tck   (tck      ),
                              .wr    (jtag_wr  ),
                              .addr  (jtag_addr),
                              .data  (jtag_data),
		              .rst_n (jtag_rstn),
		              .clk_sw(clk_sw   )    //1: select the tck 0:select the system clk
		                               );

      debug_ram	debug_ram_inst (.address (clk_sw ? jtag_addr : rom_addr),
                                .clken   (jtag_wr|~rom_rd_n            ),
	                        .clock   (debug_ram_clk                ),
	                        .data    (jtag_data                    ),
	                        .wren    (jtag_wr                      ),
	                        .q       (rom_data                     )
	                                                               );
    `endif
  `endif

  mcu_mux u_mcu_mux(
                    .mem_addr     (mem_addr    ) , 
                    .mem_data_out (mem_data_out) ,
                    .mem_data_in  (mem_data_in ) , 
                    .mem_wr_n     (mem_wr_n    ) , 
                    .mem_rd_n     (mem_rd_n    ) , 
                    
	            .port_wr_n    (port_wr_n   ) ,
	            .port_rd_n    (port_rd_n   ) ,
	            .port_addr    (port_addr   ) ,
	            .port_wr_data (port_wr_data) ,
	            .port_rd_data (port_rd_data) 
				               ) ;

  port_all u_port(//port sigal
	          .rst_n   (rstn_syn    ),
	          .clk     (clk         ),
	          .wr_n    (port_wr_n   ),
	          .rd_n    (port_rd_n   ),
	          .addr    (port_addr   ),
	          .wr_data (port_wr_data),
	          .rd_data (port_rd_data),
	          .porta_d (porta_d     ),
                  .porta_i (porta_i     ),
                  .porta_o (porta_o     ),
                  .portb_d (portb_d     ),
                  .portb_i (portb_i     ),
		            .portb_o (portb_o     ) 
                                        );
 

 
  rst_syn u_rst_syn(.rst_n   (rst_n   ),
                    .clk     (clk     ),
                    .rstn_syn(rstn_syn)
                                      );
  LED		LED1(
			.clk(clk),
			.rst_n(rstn_syn),
			.sfr_addr(sfr_addr),
			.led_sfr_cs(led_sfr_cs),
			.led_data_in(sfr_data_out),
			.led_data_out(sfr_data_in),
			.sfr_wr(sfr_wr),
			.sfr_rd(sfr_rd),
			.dout(dout),
			);
  
  
  
  
  
  
  
  //genvar i;
  
  //port a
/*  assign porta_i = porta;
  generate 
    for(i=0;i<`PRT_A_WID;i=i+1) begin:as_porta
      assign porta[i] = porta_d[i] ? porta_o[i] : 1'bz; 
    end
  endgenerate
  
  //port b
  assign portb_i = portb;
  generate 
    for(i=0;i<`PRT_B_WID;i=i+1) begin:as_portb
      assign portb[i] = portb_d[i] ? portb_o[i] : 1'bz; 
    end
  endgenerate*/
endmodule
