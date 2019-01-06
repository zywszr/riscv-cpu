
`include "define.v"

module IF_ID (
	input	wire				clk_in,
	input	wire				rst_in,

	input	wire	[`InstAddr]	if_pc,
	input	wire	[`InstData]	if_inst,
	input	wire				rec_in,
    input   wire                blk_in,

	output	reg		[`InstAddr]	id_pc,
	output	reg		[`InstData]	id_inst,
	output	reg					rec_out
);

always	@ (posedge clk_in or posedge rst_in)	begin
	if (rst_in || (!rec_in)) begin
		id_pc	<= `ZeroWord;
		id_inst	<= `ZeroWord;
		rec_out	<= 1'b0;
	end else begin
	    if (blk_in == 1'b0) begin
		    id_pc	<= if_pc;
		    id_inst	<= if_inst;
		    rec_out	<= 1'b1;
		end 
	end
end

endmodule
