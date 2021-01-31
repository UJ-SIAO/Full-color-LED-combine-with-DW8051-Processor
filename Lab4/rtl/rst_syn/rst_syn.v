`define RST_DELAY 50

module rst_syn(input  wire rst_n  ,
               input  wire clk    ,
               output reg  rstn_syn
                          );
  
  reg rstn_syn0;
  reg [5:0] count;

  
  always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
      rstn_syn <= 1'b0;
    else if(!(|count)) 
      rstn_syn <= 1'b1;
  end
  
  always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
      count <= `RST_DELAY;
    else if((|count))
      count <= count - 1;
  end
 

endmodule
