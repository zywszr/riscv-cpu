
`include "define.v"

module IF (
	input	wire				clk_in,
	input	wire				rst_in,
				
	input	wire				blk_in,
	input	wire				branch_we_in,
	input	wire	[`InstAddr]	branch_pc_in,
				
	input	wire	[`InstData]	mem_d_in,
	output	wire	[`InstAddr]	mem_a_out,

	output	wire	[`InstAddr]	pc_out,
	output	reg		[`InstData]	inst_out,
	output	reg					rec_out,
	output  reg                 blk_out
);

reg [`InstAddr] q_pc, d_pc;

always @ (posedge clk_in or posedge rst_in) begin
	if (rst_in) begin
		q_pc	<= `ZeroWord - 32'h4;
	end else begin
		q_pc	<= d_pc;
	end
end

always @ (*) begin
	if (rst_in) begin
		d_pc		= `ZeroWord;
		inst_out	= `ZeroWord;
		rec_out		= 1'b0;
		blk_out     = blk_in;
	end else begin
		rec_out		= 1'b1;
		inst_out	= mem_d_in;
		if (branch_we_in) begin
			d_pc 	= branch_pc_in;
			blk_out	= 1'b0;
		end else begin
			blk_out = blk_in;
			if (blk_in) begin
				d_pc = q_pc;
			end else begin
				d_pc = q_pc + 32'h4;
			end
		end
	end
end

assign mem_a_out	= d_pc;
assign pc_out		= d_pc;

endmodule
