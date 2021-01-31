
module port#(parameter port_width = 8)
            (//port sigal
	     input  wire                  clk     ,
	     input  wire                  rst_n   ,
	     input  wire                  wr_n    ,
	     input  wire                  rd_n    ,
	     input  wire [4:0]            addr    ,
	     input  wire [7:0]            wr_data ,
	     output reg  [7:0]            rd_data ,
	     output wire [port_width-1:0] port_d  ,
	     input  wire [port_width-1:0] port_i  ,
	     output wire [port_width-1:0] port_o
                                                  );

  localparam port_width_c = 8-port_width;
  
  //decode addr signal
  wire port_dir_sel;
  wire port_out_sel;
  wire port_in_sel;
  

  //bit address
  wire bit_addr_en;
  wire port_dir_b_sel;
  wire port_out_b_sel;
  wire port_in_b_sel;

  
  //************************************** 
  //  addr[4:3]           bit_en/reg_en
  //     00                 reg_addr       (1) 
  //     01             port_dir_bit_en(2) 
  //     10             port_out_bit_en(2)
  //     11             port_in_bit_en (2)
  //**************************************
  //      Note:(1) reg_addr stand for addr[2:0] is reg address(000:port_dir,
  //               001:port_out,010:port_in,others:reserved)
  //           (2) port_XX_bit_en stand for that addr[2:0] is bit address(000:port_XX[0],
  //               001:port_XX[1],010:port_XX[2],...,111:port_XX[7])
  
  
  //--------------------(addr[4:3]==00)-------------------
  //   addr[3:0]      reg         w/r    reset value
  //      0         port_dir      w/r       8'h00
  //      1         port_out      w/r       8'h00
  //      2         port_in        r        8'h00
  //    others      reserved
  //------------------------------------------------------
  
  reg [port_width-1:0] port_dir;        //port direction reg , 1:out , 0:in
  reg [port_width-1:0] port_out;        //port out data reg        
  
  reg [port_width-1:0] port_ff,port_in; //port in data reg
  
  genvar i;
  

  //bit address
  assign bit_addr_en    = |addr[4:3];
  assign port_dir_b_sel = (addr[4:3] == 3'h1);
  assign port_out_b_sel = (addr[4:3] == 3'h2);
  assign port_in_b_sel  = (addr[4:3] == 3'h3);
  
  
  //decode addr
  assign port_dir_sel = (addr[2:0] == 3'h0);
  assign port_out_sel = (addr[2:0] == 3'h1);
  assign port_in_sel  = (addr[2:0] == 3'h2);

  //out
  assign port_o       = port_out;
  assign port_d       = port_dir;
  
  //read
  always@(posedge clk or negedge rst_n) begin
    if(!rst_n) 
      rd_data <= 8'b0;
    else if(!rd_n) begin
      if(bit_addr_en) begin
        if(port_dir_b_sel) begin
	  rd_data <= {7'b0,port_dir[addr[2:0]]};
	end
	else if(port_out_b_sel) begin
	  rd_data <= {7'b0,port_out[addr[2:0]]};
	end
	else if(port_in_b_sel) begin
	  rd_data <= {7'b0,port_in[addr[2:0]]};
	end
      end
      else begin
        if(port_dir_sel) 
          rd_data <= {{port_width_c{1'b0}},port_dir};
        else if(port_out_sel) 
          rd_data <= {{port_width_c{1'b0}},port_out};
        else if(port_in_sel)
          rd_data <= {{port_width_c{1'b0}},port_in};
      end
    end
  end  

  
  //write direction reg
  always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
      port_dir <= 8'b0;
    else if(!wr_n) begin
      if(port_dir_b_sel)
        port_dir[addr[2:0]] <= wr_data[0];
      else if((!bit_addr_en) && port_dir_sel)
        port_dir <= wr_data[port_width-1:0];
    end
  end
  
  //write data reg
  always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
      port_out <= 8'b0;
    else if(!wr_n) begin
      if(port_out_b_sel)
        port_out[addr[2:0]] <= wr_data[0];
      else if((!bit_addr_en) && port_out_sel)
        port_out <= wr_data[port_width-1:0];
    end
  end
  
  //port synchronous
  generate 
    for(i=0;i<port_width;i=i+1) begin:port_syn
      always@(posedge clk or negedge rst_n) begin
        if(!rst_n)
          {port_ff[i],port_in[i]} <= 2'b0;
        else if(!port_dir[i])
          {port_in[i],port_ff[i]} <= {port_ff[i],port_i[i]};
      end
    end
  endgenerate
  /*
  always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
      {port_ff[0],port_in[0]} <= 2'b0;
    else if(!port_dir[0])
      {port_in[0],port_ff[0]} <= {port_ff[0],port[0]};
  end
  always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
      {port_ff[1],port_in[1]} <= 2'b0;
    else if(!port_dir[1])
      {port_in[1],port_ff[1]} <= {port_ff[1],port[1]};
  end
  always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
      {port_ff[2],port_in[2]} <= 2'b0;
    else if(!port_dir[2])
      {port_in[2],port_ff[2]} <= {port_ff[2],port[2]};
  end
  always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
      {port_ff[3],port_in[3]} <= 2'b0;
    else if(!port_dir[3])
      {port_in[3],port_ff[3]} <= {port_ff[3],port[3]};
  end
  always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
      {port_ff[4],port_in[4]} <= 2'b0;
    else if(!port_dir[4])
      {port_in[4],port_ff[4]} <= {port_ff[4],port[4]};
  end
  always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
      {port_ff[5],port_in[5]} <= 2'b0;
    else if(!port_dir[5])
      {port_in[5],port_ff[5]} <= {port_ff[5],port[5]};
  end
  always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
      {port_ff[6],port_in[6]} <= 2'b0;
    else if(!port_dir[6])
      {port_in[6],port_ff[6]} <= {port_ff[6],port[6]};
  end
  always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
      {port_ff[7],port_in[7]} <= 2'b0;
    else if(!port_dir[7])
      {port_in[7],port_ff[7]} <= {port_ff[7],port[7]};
  end
  */
endmodule
