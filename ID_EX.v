
`include "define.v"

module ID_EX (
	input	wire				clk_in,
	input	wire				rst_in,
	input	wire	[`OpBus]	op_in,
	input	wire	[`FunBus]	fun_in,
	input	wire	[`RegData]	rs1_in,
	input	wire	[`RegData]	rs2_in,
	input	wire	[`RegBus]	rd_in,
	input	wire	[`ImmBus]	imm_in,
	input	wire				rec_in,
		
	output	reg		[`OpBus]	op_out,
	output	reg		[`FunBus]	fun_out,
	output	reg		[`RegData]	rs1_out,
	output	reg		[`RegData]	rs2_out,
	output	reg		[`RegBus]	rd_out,
	output	reg		[`ImmBus]	imm_out,
	output	reg					rec_out
);

always @ (posedge clk_in or posedge rst_in) begin
	if (rst_in || (!rec_in)) begin
		op_out	<= 3'h0;
		fun_out	<= 3'h0;
		rs1_out	<= `ZeroWord;
		rs2_out	<= `ZeroWord;
		rd_out	<= `RegZero;
		imm_out	<= `ZeroWord;
		rec_out	<= 1'b0;
	end else begin
		op_out	<= op_in;
		fun_out	<= fun_in;
		rs1_out	<= rs1_in;
		rs2_out	<= rs2_in;
		rd_out	<= rd_in;
		imm_out	<= imm_in;
		rec_out	<= 1'b1;
	end
end

endmodule
