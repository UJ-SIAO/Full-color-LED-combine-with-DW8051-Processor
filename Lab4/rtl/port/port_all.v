module port_all(
	        input  wire                  clk    ,
	        input  wire                  rst_n  ,
	        input  wire                  wr_n   ,
	        input  wire                  rd_n   ,
	        input  wire [6:0]            addr   ,
	        input  wire [7:0]            wr_data,
	        output wire [7:0]            rd_data,
	        output wire [`PRT_A_WID-1:0] porta_d, 
                input  wire [`PRT_A_WID-1:0] porta_i, 
		output wire [`PRT_A_WID-1:0] porta_o,
		output wire [`PRT_B_WID-1:0] portb_d, 
                input  wire [`PRT_B_WID-1:0] portb_i, 
		output wire [`PRT_B_WID-1:0] portb_o
                                                   );

  //decode signal
  wire porta_sel;
  wire portb_sel;
  
  //port a signal
  wire       porta_wr_n   ; 
  wire       porta_rd_n   ; 
  wire [4:0] porta_addr   ; 
  wire [7:0] porta_wr_data;
  wire [7:0] porta_rd_data;


  //port b signal
  wire       portb_wr_n   ; 
  wire       portb_rd_n   ; 
  wire [4:0] portb_addr   ; 
  wire [7:0] portb_wr_data;
  wire [7:0] portb_rd_data;

  //decode
  assign porta_sel = (addr[6:5] == 2'b0);
  assign portb_sel = (addr[6:5] == 2'b1);

  //port a
  assign porta_wr_n    =  porta_sel ? wr_n :    1'b1;
  assign porta_rd_n    =  porta_sel ? rd_n :    1'b1;
  assign porta_addr    =  porta_sel ? addr :    5'b0;
  assign porta_wr_data =  porta_sel ? wr_data : 8'b0;
  
  //port b
  assign portb_wr_n    =  portb_sel ? wr_n :    1'b1;
  assign portb_rd_n    =  portb_sel ? rd_n :    1'b1;
  assign portb_addr    =  portb_sel ? addr :    5'b0;
  assign portb_wr_data =  portb_sel ? wr_data : 8'b0;


  assign rd_data       = porta_sel ? porta_rd_data : portb_sel ? portb_rd_data :8'b0;
  
  port        #(.port_width(`PRT_A_WID))
        port_a (//port a sigal
	        .rst_n   (rst_n        ),
	        .clk     (clk          ),
	        .wr_n    (porta_wr_n   ),
	        .rd_n    (porta_rd_n   ),
	        .addr    (porta_addr   ),
	        .wr_data (porta_wr_data),
	        .rd_data (porta_rd_data),
		.port_d  (porta_d      ),
                .port_i  (porta_i      ),
                .port_o  (porta_o      )
                                       );
 
  port        #(.port_width(`PRT_B_WID))
        port_b (//port b sigal
	        .rst_n   (rst_n        ),
	        .clk     (clk          ),
	        .wr_n    (portb_wr_n   ),
	        .rd_n    (portb_rd_n   ),
	        .addr    (portb_addr   ),
	        .wr_data (portb_wr_data),
	        .rd_data (portb_rd_data),
	        .port_d  (portb_d      ),
                .port_i  (portb_i      ),
                .port_o  (portb_o      )
                                       );

endmodule
