
`include "define.v"

module cpu (
	input	wire		clk_in,		// system clock signal
	input	wire		rst_in,		// reset signal
	input	wire		rdy_in,		// ready signal (pause cpu when low)

	input	wire [ 7:0]	mem_din,	// data input bus
	output	wire [ 7:0] mem_dout,	// data output bus
	output	wire [31:0] mem_a,		// address bus (only 17:0 is used)
	output	wire		mem_wr,		// write/read signal (1 for write)

	output	wire [31:0] dbgreg_dout // cpu register output (debugging demo)
);

// implementation goes here

// Specifications:
// - Pause cpu (freeze pc, registers, etc.) when rdy_in is low
// - Memory read takes 2 cycles (wait till next cycle), write takes 1 cycle (no need to wait)
// - Memory is of size 128KB, with valid address ranging from 0x0 to 0x20000
// - I/O port is mapped to address higher than 0x30000 (mem_a[17:16]=2`b11)
// - 0x30000 read: read a byte from input
// - 0x30000 write: write a byte to output (write 0x00 is ignored)
// - 0x30004 read: read clocks passed since cpu starts (in dword, 4 bytes)
// - 0x30004 write: indicates program stop (will output '\0' through uart tx)

wire	[`MemoryBus]	ctrl_mem_d;
wire	[`MemoryAddr]	ctrl_mem_a;
wire					ctrl_mem_wr;

assign mem_dout	= ctrl_mem_d;
assign mem_a	= ctrl_mem_a;
assign mem_wr	= ctrl_mem_wr;


wire	[`InstData]		ctrl_inst;
wire	[`MemoryData]	ctrl_MEM_d;
wire					ctrl_MEM_en;
wire                    ctrl_MEM_wr;
wire					ctrl_clk;

wire	[`InstAddr]     if_mem_a;
wire                    if_blk;
wire					id_blk;
wire	[`MemoryAddr]	MEM_a;
wire	[`MemoryData]	MEM_d;
wire	[`LoreLength]	MEM_l;
wire	[`MEMwr]		MEM_wr;

memory_controller memory_controller0 (
	.clk_in(clk_in),
	.rst_in(rst_in),
	.rdy_in(rdy_in),
	.blk_in(if_blk),
	.pc_in(if_mem_a),
	.inst_out(ctrl_inst),
	.MEM_a_in(MEM_a),
	.MEM_d_in(MEM_d),
	.MEM_l_in(MEM_l),
	.MEM_wr_in(MEM_wr),
	.MEM_d_out(ctrl_MEM_d),
	.MEM_en_out(ctrl_MEM_en),
	.MEM_wr_out(ctrl_MEM_wr),
	.mem_d_in(mem_din),
	.mem_d_out(ctrl_mem_d),
	.mem_a_out(ctrl_mem_a),
	.mem_wr_out(ctrl_mem_wr),
	.clk_out(ctrl_clk)
);

wire	[`InstAddr] if_pc;
wire	[`InstData] if_inst;
wire				if_rec;

wire	[`InstAddr]	ex_branch_pc;
wire				ex_branch_we;

IF IF0 (
	.clk_in(ctrl_clk),
	.rst_in(rst_in),
	.blk_in(id_blk),
	.branch_we_in(ex_branch_we),
	.branch_pc_in(ex_branch_pc),
	.mem_d_in(ctrl_inst),
	.mem_a_out(if_mem_a),
	.pc_out(if_pc),
	.inst_out(if_inst),
	.rec_out(if_rec),
	.blk_out(if_blk)
);

wire	[`InstAddr] if_id_pc;
wire	[`InstData]	if_id_inst;
wire				if_id_rec;

IF_ID IF_ID0 (
	.clk_in(ctrl_clk),
	.rst_in(rst_in),
	.if_pc(if_pc),
	.if_inst(if_inst),
	.rec_in(if_rec),
	.blk_in(id_blk),
	.id_pc(if_id_pc),
	.id_inst(if_id_inst),
	.rec_out(if_id_rec)
);
		
wire				id_reg_re1;
wire	[`RegBus]	id_reg_a1;
wire				id_reg_re2;
wire	[`RegBus]	id_reg_a2;

wire	[`OpBus]	id_op;
wire	[`FunBus]	id_fun;
wire	[`RegData]	id_rs1;
wire	[`RegData]	id_rs2;
wire	[`RegBus]	id_rd;
wire	[`ImmBus]	id_imm;
wire				id_rec;

wire	[`RegData]	reg_d1;
wire	[`RegData]	reg_d2;
wire				reg_en1;
wire				reg_en2;

ID ID0 (
	.rst_in(rst_in),
	.pc_in(if_id_pc),
	.inst_in(if_id_inst),
	.rec_in(if_id_rec),
	.reg_d1_in(reg_d1),
	.reg_en1_in(reg_en1),
	.reg_re1_out(id_reg_re1),
	.reg_a1_out(id_reg_a1),
	.reg_d2_in(reg_d2),
	.reg_en2_in(reg_en2),
	.reg_re2_out(id_reg_re2),
	.reg_a2_out(id_reg_a2),
	.branch_we_in(ex_branch_we),
	.op_out(id_op),
	.fun_out(id_fun),
	.rs1_out(id_rs1),
	.rs2_out(id_rs2),
	.rd_out(id_rd),
	.imm_out(id_imm),
	.rec_out(id_rec),
	.blk_out(id_blk)
);

wire	[`OpBus]	id_ex_op;
wire	[`FunBus]	id_ex_fun;
wire	[`RegData]	id_ex_rs1;
wire	[`RegData]	id_ex_rs2;
wire	[`RegBus]	id_ex_rd;
wire	[`ImmBus]	id_ex_imm;
wire				id_ex_rec;

ID_EX ID_EX0 (
	.clk_in(ctrl_clk),
	.rst_in(rst_in),
	.op_in(id_op),
	.fun_in(id_fun),
	.rs1_in(id_rs1),
	.rs2_in(id_rs2),
	.rd_in(id_rd),
	.imm_in(id_imm),
	.rec_in(id_rec),
	.op_out(id_ex_op),
	.fun_out(id_ex_fun),
	.rs1_out(id_ex_rs1),
	.rs2_out(id_ex_rs2),
	.rd_out(id_ex_rd),
	.imm_out(id_ex_imm),
	.rec_out(id_ex_rec)
);

wire	[`OpBus]	ex_op;
wire	[`FunBus]	ex_fun;
wire	[`ImmBus]	ex_res;
wire	[`ImmBus]	ex_imm;
wire	[`RegBus]	ex_rd;
wire				ex_rec;
wire				ex_reg_we;

EX EX0 (
	.rst_in(rst_in),
	.op_in(id_ex_op),
	.fun_in(id_ex_fun),
	.A_in(id_ex_rs1),
	.B_in(id_ex_rs2),
	.rd_in(id_ex_rd),
	.imm_in(id_ex_imm),
	.rec_in(id_ex_rec),
	.op_out(ex_op),
	.fun_out(ex_fun),
	.res_out(ex_res),
	.imm_out(ex_imm),
	.rd_out(ex_rd),
	.rec_out(ex_rec),
	.reg_we_out(ex_reg_we),
	.branch_pc_out(ex_branch_pc),
	.branch_we_out(ex_branch_we)	
);

wire	[`OpBus]	ex_mem_op;
wire	[`FunBus]	ex_mem_fun;
wire	[`ImmBus]	ex_mem_res;
wire	[`ImmBus]	ex_mem_imm;
wire	[`RegBus]	ex_mem_rd;
wire				ex_mem_rec;

EX_MEM EX_MEM0 (
	.clk_in(ctrl_clk),
	.rst_in(rst_in),
	.op_in(ex_op),
	.fun_in(ex_fun),
	.res_in(ex_res),
	.imm_in(ex_imm),
	.rd_in(ex_rd),
	.rec_in(ex_rec),
	.op_out(ex_mem_op),
	.fun_out(ex_mem_fun),
	.res_out(ex_mem_res),
	.imm_out(ex_mem_imm),
	.rd_out(ex_mem_rd),
	.rec_out(ex_mem_rec)
);

wire	[`RegBus]		mem_rd;
wire	[`ImmBus]		mem_reg_d;
wire					mem_reg_we;

MEM MEM0 (
	.rst_in(rst_in),
	.op_in(ex_mem_op),
	.fun_in(ex_mem_fun),
	.res_in(ex_mem_res),
	.imm_in(ex_mem_imm),
	.rd_in(ex_mem_rd),
	.rec_in(ex_mem_rec),
	.mem_d_in(ctrl_MEM_d),
	.mem_en_in(ctrl_MEM_en),
	.mem_wr_in(ctrl_MEM_wr),
	.mem_a_out(MEM_a),
	.mem_d_out(MEM_d),
	.mem_l_out(MEM_l),
	.mem_wr_out(MEM_wr),
	.rd_out(mem_rd),
	.reg_d_out(mem_reg_d),
	.reg_we_out(mem_reg_we)
);	

assign dbgreg_dout = if_id_inst;
		
register register0 (
	.clk_in(ctrl_clk),
	.rst_in(rst_in),
	.waddr1_in(mem_rd),
	.wdata1_in(mem_reg_d),
	.we1_in(mem_reg_we),
	.waddr2_in(ex_rd),
	.wdata2_in(ex_res),
	.we2_in(ex_reg_we),
	.re1_in(id_reg_re1),
	.raddr1_in(id_reg_a1),
	.rdata1_out(reg_d1),
	.re1_out(reg_en1),
	.re2_in(id_reg_re2),
	.raddr2_in(id_reg_a2),
	.rdata2_out(reg_d2),
	.re2_out(reg_en2)
);

endmodule
