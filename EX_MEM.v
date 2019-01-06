
`include "define.v"

module EX_MEM (
	input	wire				clk_in,
	input	wire				rst_in,

	input	wire	[`OpBus]	op_in,
	input	wire	[`FunBus]	fun_in,
	input	wire	[`ImmBus]	res_in,
	input	wire	[`ImmBus]	imm_in,
	input	wire	[`RegBus]	rd_in,
	input	wire				rec_in,

	output	reg		[`OpBus]	op_out,
	output	reg		[`FunBus]	fun_out,
	output	reg		[`ImmBus]	res_out,
	output	reg		[`ImmBus]	imm_out,
	output	reg		[`RegBus]	rd_out,
	output	reg					rec_out	
);
 
always @ (posedge clk_in or posedge rst_in) begin
	if (rst_in || (!rec_in)) begin
		op_out	<= `OpZero;
		fun_out	<= `FunZero;
		res_out	<= `ZeroWord;
		imm_out	<= `ZeroWord;
		rd_out	<= `RegZero;
		rec_out	<= 1'b0;
	end else begin
		op_out	<= op_in;
		fun_out	<= fun_in;
		res_out	<= res_in;
		imm_out	<= imm_in;
		rd_out	<= rd_in;
		rec_out	<= 1'b1;
	end
end	

endmodule
