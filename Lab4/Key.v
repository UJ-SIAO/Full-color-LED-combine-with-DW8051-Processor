module Key(
			clk,
			rst_n,
			key0,
			key1,
			sfr_addr,
			key_sfr_cs,
			key_data_in,
			key_data_out,
			sfr_wr,
			sfr_rd
			);

input clk;
input rst_n;
input [7:0]sfr_addr;
input [7:0]key_data_in;
input sfr_wr;
input sfr_rd;
input key0;
input key1;

output key_sfr_cs;
output [7:0]key_data_out;

wire key_sfr_cs;
reg [7:0]key_data_out;

wire de_key0;
wire de_key1;
wire pos_key0;
wire neg_key0;
wire pos_key1;
wire neg_key1;

wire key_status_cs;
wire key_status_wr;

/*debounce	keyA(
						.clk(clk),
						.rst(rst_n),
						.key_in(key0),
						.key_out(de_key0)
				);
debounce	keyB(
						.clk(clk),
						.rst(rst_n),
						.key_in(key1),
						.key_out(de_key1)
				);*/

edge_detect edge_key0(
						.clk(clk),
						.rst_n(rst_n),
						.data_in(key0),
						.pos_edge(pos_key0),
						.neg_edge(neg_key0) 
					);
edge_detect edge_key1(
						.clk(clk),
						.rst_n(rst_n),
						.data_in(key1),
						.pos_edge(pos_key1),
						.neg_edge(neg_key1) 
					);
/*edge_detect edge_key0(
						.clk(clk),
						.rst_n(rst_n),
						.data_in(de_key0),
						.pos_edge(pos_key0),
						.neg_edge(neg_key0) 
					);
edge_detect edge_key1(
						.clk(clk),
						.rst_n(rst_n),
						.data_in(de_key1),
						.pos_edge(pos_key1),
						.neg_edge(neg_key1) 
					);*/
					
assign key_status_cs 	= (sfr_addr==8'hC6) ? 1: 0 ; 
assign key_status_wr	= key_status_cs 	& sfr_wr ;
assign key_sfr_cs		= key_status_cs;

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		key_data_out<=0;
	else begin
		if(pos_key0)begin
			key_data_out<=8'h01;
		end
		else if (pos_key1)begin
			key_data_out<=8'h02;
		end
		else if (key_status_cs && sfr_rd)
			key_data_out<=8'h00;
	end
end   




endmodule