module mcu_mux(
               input  wire [15:0]  mem_addr     , 
               input  wire [ 7:0]  mem_data_out ,
               output reg  [ 7:0]  mem_data_in  , 
               input  wire         mem_wr_n     , 
               input  wire         mem_rd_n     , 
               
	       //port sigal
	       output wire         port_wr_n    ,
	       output wire         port_rd_n    ,
	       output wire [ 6:0]  port_addr    ,
	       output wire [ 7:0]  port_wr_data ,
	       input  wire [ 7:0]  port_rd_data 
				               );
  
  //decode signal
  wire ex_ram_sel;
  wire port_sel;

  //--------------------decode--------------
  //extern ram: 0x0000~0x7fff   reserved
  //port      : 0x8000~0x807f   ******************************     ************************************** 
  //                             port_addr[6:5] port_selected       port_addr[4:3]   bit_en/reg_en
  //                                 00             port a              00             reg_addr       (1)    
  //				     01             port b              01             port_dir_bit_en(2) 
  //                                 10             port c              10             port_out_bit_en(2)
  //                                 11             port d              11             port_in_bit_en (2)
  //			        ******************************     **************************************
  //                              Note:(1) reg_addr stand for port_addr[2:0] is reg address(000:port_dir,
  //                                       001:port_out,010:port_in,others:reserved)
  //                                   (2) port_XX_bit_en stand for that port_addr[2:0] is bit address(000:port_XX[0],
  //                                       001:port_XX[1],010:port_XX[2],...,111:port_XX[7])
  //--------------------decode--------------
  assign ex_ram_sel = (~mem_addr[15]);
  assign port_sel   = (mem_addr[15:7] == 9'h100);

  //port a signal
  assign port_wr_n    = port_sel ? mem_wr_n      : 1'b1;
  assign port_rd_n    = port_sel ? mem_rd_n      : 1'b1;
  assign port_addr    = port_sel ? mem_addr[6:0] : 2'b0;
  assign port_wr_data = port_sel ? mem_data_out  : 8'b0;
  
  always@(*) begin
    if(ex_ram_sel)
      mem_data_in = 8'b0;
    else if(port_sel)
      mem_data_in = port_rd_data;
    else
      mem_data_in = 8'b0;
  end
  
endmodule
