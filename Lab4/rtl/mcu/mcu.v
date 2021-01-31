module mcu(
           input  wire                       clk          , 
           input  wire                       por_n        , 
           input  wire                       rst_in_n     , 
           output wire                       rst_out_n    , 
           input  wire                       test_mode_n  , 
                                               
           output wire                       stop_mode_n  , 
           output wire                       idle_mode_n  ,         
                         
           //int
           input  wire                       int0_n       , 
           input  wire                       int1_n       , 
           input  wire                       int2         , 
           input  wire                       int3_n       , 
           input  wire                       int4         , 
           input  wire                       int5_n       , 
           
           input  wire                       pfi          ,  //power failed
           input  wire                       wdti         ,  //watchdog
           
           //serial port
           input  wire                       rxd0_in      , 
           output wire                       rxd0_out     , 
           output wire                       txd0         , 
                         
           input  wire                       rxd1_in      , 
           output wire                       rxd1_out     , 
           output wire                       txd1         , 
           
           //timer/counter input/output
           input  wire                       t0           , 
           input  wire                       t1           , 
           input  wire                       t2           , 
           input  wire                       t2ex         , 
           output wire                       t0_out       , 
           output wire                       t1_out       , 
           output wire                       t2_out       , 
                         
           // interal ram interface
           output wire [ 7:0]                iram_addr    , 
           output wire [ 7:0]                iram_data_out,  //mcu data to iram 
           input  wire [ 7:0]                iram_data_in ,  //iram data to mcu
           output wire                       iram_we_n    ,
           
           // interal rom interface
           output wire [`ROM_ADDR_WIDTH-1:0] irom_addr    , 
           input  wire [ 7:0]                irom_data    , 
           output wire                       irom_rd_n    ,

	   //sfr interface
           output wire [ 7:0]                sfr_addr     , 
           output wire [ 7:0]                sfr_data_out , 
           input  wire [ 7:0]                sfr_data_in  , 
           output wire                       sfr_wr       , 
           output wire                       sfr_rd       ,
           
           //external ram interface or user-defined peripheral reg
           output wire [15:0]                mem_addr     , 
           output wire [ 7:0]                mem_data_out , 
           input  wire [ 7:0]                mem_data_in  , 
           output wire                       mem_wr_n     , 
           output wire                       mem_rd_n 
                                                       );

  wire [15:0] irom_addr_a;

  assign irom_addr=irom_addr_a[`ROM_ADDR_WIDTH-1:0];
  
  DW8051_core u_DW8051_core(.clk            (clk           ) , 
		            .por_n          (por_n         ) ,  //mandatory for init , active at least 2 clk
                            .rst_in_n       (rst_in_n      ) ,  //active at least 8 clk 
                            .rst_out_n      (rst_out_n     ) ,
                            .test_mode_n    (test_mode_n   ) ,  //test mode for scan
                                                           
                            .stop_mode_n    (stop_mode_n   ) ,  //reset to exit stop mode
                            .idle_mode_n    (idle_mode_n   ) ,  //exit when reset or enabled interrupt occurs
                                                           
                            .sfr_addr       (sfr_addr      ) ,
                            .sfr_data_out   (sfr_data_out  ) ,
                            .sfr_data_in    (sfr_data_in   ) ,
                            .sfr_wr         (sfr_wr        ) ,
                            .sfr_rd         (sfr_rd        ) ,
                                                           
                            .mem_addr       (mem_addr      ) ,
                            .mem_data_out   (mem_data_out  ) ,
                            .mem_data_in    (mem_data_in   ) ,
                            .mem_wr_n       (mem_wr_n      ) ,
                            .mem_rd_n       (mem_rd_n      ) ,
                            .mem_pswr_n     (mem_pswr_n    ) ,
                            .mem_psrd_n     (mem_psrd_n    ) ,
                            .mem_ale        (              ) ,
                            .mem_ea_n       (1'b1          ) ,
                                                           
                            .int0_n         (int0_n        ) ,		// External Interrupt 0, std
                            .int1_n         (int1_n        ) ,		// External Interrupt 1, std
                            .int2           (int2          ) ,		// External Interrupt 2, ext
                            .int3_n         (int3_n        ) ,		// External Interrupt 3, ext
                            .int4           (int4          ) ,		// External Interrupt 4, ext
                            .int5_n         (int5_n        ) ,		// External Interrupt 5, ext
                                                           
                            .pfi            (pfi           ) ,		// power fail interrupt, ext
                            .wdti           (wdti          ) ,		// watchdog timer intr, ext
                                                           
                            .rxd0_in        (rxd0_in       ) ,		// serial port 0 input
                            .rxd0_out       (rxd0_out      ) ,		// serial port 0 output
                            .txd0           (txd0          ) ,		// serial port 0 output
                                                           
                            .rxd1_in        (rxd1_in       ) ,		// serial port 1 input
                            .rxd1_out       (rxd1_out      ) ,		// serial port 1 output
                            .txd1           (txd1          ) ,		// serial port 1 output
                                                           
                            .t0             (t0            ) ,		// Timer 0 external input
                            .t1             (t1            ) ,		// Timer 1 external input
                            .t2             (t2            ) ,		// Timer/Counter2 ext.input
                            .t2ex           (t2ex          ) ,		// Timer/Counter2 capt./reload
                            .t0_out         (t0_out        ) ,		// Timer/Counter0 ext. output
                            .t1_out         (t1_out        ) ,		// Timer/Counter1 ext. output
                            .t2_out         (t2_out        ) ,		// Timer/Counter2 ext. output
                                                           
                            .port_pin_reg_n (              ) ,
                            .p0_mem_reg_n   (              ) ,
                            .p0_addr_data_n (              ) ,
                            .p2_mem_reg_n   (              ) ,
                                                           
		            .iram_addr      (iram_addr     ) ,
		            .iram_data_out  (iram_data_in  ) ,
		            .iram_data_in   (iram_data_out ) ,
		            .iram_rd_n      (              ) ,
		            .iram_we1_n     (              ) ,
		            .iram_we2_n     (iram_we_n     ) ,
                                                           
		            .irom_addr      (irom_addr_a   ) ,
		            .irom_data_out  (irom_data     ) ,
		            .irom_rd_n      (irom_rd_n     ) ,
		            .irom_cs_n      (              )
		                                           );
endmodule
