
`include "define.v"

module ID (
	input	wire				rst_in,
	input	wire	[`InstAddr]	pc_in,
	input	wire	[`InstData]	inst_in,
	input	wire				rec_in,

	input	wire	[`RegData]	reg_d1_in,
	input	wire				reg_en1_in,
	output	reg					reg_re1_out,
	output	reg		[`RegBus]	reg_a1_out,

	input	wire	[`RegData]	reg_d2_in,
	input	wire				reg_en2_in,
	output	reg					reg_re2_out,
	output	reg		[`RegBus]	reg_a2_out,
	
	input	wire				branch_we_in,
	
	output	reg		[`OpBus]	op_out,
	output	reg		[`FunBus]	fun_out,
	output	reg		[`RegData]	rs1_out,
	output	reg		[`RegData]	rs2_out,
	output	reg		[`RegBus]	rd_out,
	output	reg		[`ImmBus]	imm_out,
	output	reg					rec_out,
	output	reg					blk_out
);

wire	[ 6:0]	inst1;
wire	[ 4:0]	inst2;
wire	[ 2:0]	inst3;
wire	[ 4:0]	inst4;
wire	[ 4:0]	inst5;
wire	[ 6:0]	inst6;
reg	    [31:0]  inst_imm;

assign	inst1 = inst_in[ 6: 0];
assign	inst2 = inst_in[11: 7];
assign	inst3 = inst_in[14:12];
assign	inst4 = inst_in[19:15];
assign	inst5 = inst_in[24:20];
assign	inst6 = inst_in[31:25];

always @ (*) begin
	if ((rst_in) || (!rec_in) || (branch_we_in)) begin
		op_out	    = 3'h0;
		fun_out	    = 3'h0;
		rd_out	    = 5'h00;
		imm_out	    = `ZeroWord;
	    inst_imm    = `ZeroWord;
	    reg_a1_out  = 5'h00;
	    reg_a2_out  = 5'h00;
	    reg_re1_out = 1'b0;
	    reg_re2_out = 1'b0;
	end else begin
	    op_out	    = 3'h0;
        fun_out     = 3'h0;
        rd_out      = 5'h00;
        imm_out     = `ZeroWord;
        inst_imm    = `ZeroWord;
        reg_a1_out  = 5'h00;
        reg_a2_out  = 5'h00;
        reg_re1_out = 1'b0;
        reg_re2_out = 1'b0;
		case (inst1)
			`IMM: begin
				reg_a1_out	= inst4;
				reg_re1_out	= 1'b1;
				reg_a2_out  = 5'h00;
				reg_re2_out	= 1'b0;
				rd_out		= inst2;
				imm_out		= `ZeroWord;
				inst_imm	= $signed({inst6, inst5});
				case (inst3)
					`ADDI: begin
						op_out	= `EXE_ARTH;
						fun_out = `EXE_ADD;
					end
					`SLTI: begin
						op_out	= `EXE_COMP;
						fun_out	= `EXE_SLT;
					end
					`SLTIU: begin
						op_out	= `EXE_COMP;
						fun_out	= `EXE_SLTU;
					end
					`ANDI: begin
						op_out	= `EXE_LOGIC;
						fun_out	= `EXE_AND;
					end
					`ORI: begin
						op_out	= `EXE_LOGIC;
						fun_out	= `EXE_OR;
					end
					`XORI: begin
						op_out	= `EXE_LOGIC;
						fun_out	= `EXE_XOR;
					end
					`SLLI: begin
						op_out	= `EXE_SHIFT;
						fun_out	= `EXE_SLL;
					end
					default: begin
						op_out	= `EXE_SHIFT;
						if (inst6) begin
							fun_out = `EXE_SRA;
						end else begin
							fun_out	= `EXE_SRL;
						end
					end
				endcase
			end
			`OP: begin
				reg_a1_out	= inst4;
				reg_re1_out	= 1'b1;
				reg_a2_out	= inst5;
				reg_re2_out	= 1'b1;
				rd_out		= inst2;
				imm_out		= `ZeroWord;
				inst_imm    = `ZeroWord;
				case (inst3)
					`ADD: begin
						op_out	= `EXE_ARTH;
						if (inst6) begin
							fun_out	= `EXE_SUB;
						end else begin
							fun_out = `EXE_ADD;
						end
					end
					`SLT: begin
						op_out	= `EXE_COMP;
						fun_out	= `EXE_SLT;
					end
					`SLTU: begin
						op_out	= `EXE_COMP;
						fun_out	= `EXE_SLTU;
					end
					`AND: begin
						op_out	= `EXE_LOGIC;
						fun_out	= `EXE_AND;
					end
					`OR: begin
						op_out	= `EXE_LOGIC;
						fun_out	= `EXE_OR;
					end
					`XOR: begin
						op_out	= `EXE_LOGIC;
						fun_out	= `EXE_XOR;
					end
					`SLL: begin
						op_out	= `EXE_SHIFT;
						fun_out	= `EXE_SLL;
					end
					default: begin
						op_out	= `EXE_SHIFT;
						if (inst6) begin
							fun_out	= `EXE_SRA;
						end else begin
							fun_out	= `EXE_SRL;
						end
					end
				endcase
			end
			`JAL: begin
				op_out		= `EXE_BRANCH;
				fun_out		= `EXE_JAL;
				reg_a1_out  = 5'h00;
				reg_re1_out	= 1'b0;
				reg_a2_out  = 5'h00;
				reg_re2_out	= 1'b0;
				rd_out		= inst2;
				imm_out		= pc_in + 32'h4;
				inst_imm	= $signed({inst_in[31], inst4, inst3, inst_in[20], inst_in[30:21], 1'h0});
			end
			`JALR: begin
				op_out		= `EXE_BRANCH;
				fun_out		= `EXE_JALR;
				reg_a1_out	= inst4;
				reg_re1_out	= 1'b1;
				reg_a2_out  = 5'h00;
				reg_re2_out	= 1'b0;
				rd_out		= inst2;	
				imm_out		= pc_in + 32'h4;
				inst_imm	= $signed({inst6, inst5});
			end
			`BRANCH: begin
				op_out		= `EXE_BRANCH;
				fun_out		= `FunZero;
				reg_a1_out	= inst4;
				reg_re1_out	= 1'b1;
				reg_a2_out	= inst5;
				reg_re2_out	= 1'b1;
				rd_out		= 5'h00; 
				inst_imm 	= $signed({inst_in[31], inst_in[7], inst_in[30:25], inst_in[11:8], 1'h0});
				imm_out		= pc_in + inst_imm;
				case (inst3)
					`BEQ:	fun_out = `EXE_BEQ; 
					`BNE:	fun_out = `EXE_BNE;
                    `BLT:	fun_out	= `EXE_BLT;
                    `BLTU:	fun_out = `EXE_BLTU;
                    `BGE:	fun_out = `EXE_BGE;
                    `BGEU:	fun_out = `EXE_BGEU;
					default: begin end
				endcase
			end
			`LOAD: begin
				op_out		= `EXE_LORE;
				reg_a1_out	= inst4;
				reg_re1_out	= 1'b1;
				reg_a2_out  = 5'h00;
				reg_re2_out	= 1'b0;
				rd_out		= inst2;
				imm_out		= `ZeroWord;
				inst_imm	= $signed({inst6, inst5});
				fun_out     = 3'h0;
				case (inst3)
					3'b000: begin
						fun_out	= `EXE_LB;
					end
					3'b001: begin
						fun_out	= `EXE_LH;
					end
					3'b010: begin
						fun_out	= `EXE_LW;
					end
					3'b100: begin
						fun_out	= `EXE_LBU;
					end
					3'b101: begin
						fun_out	= `EXE_LHU;
					end
					default: begin end
				endcase
			end
			`STORE: begin
				op_out		= `EXE_LORE;
				reg_a1_out	= inst4;
				reg_re1_out	= 1'b1;
				reg_a2_out	= inst5;
				reg_re2_out	= 1'b1;
				rd_out		= 5'h00;
				imm_out		= $signed({inst_in[31:25], inst2});
				inst_imm	= `ZeroWord;
				fun_out     = 3'h0;
				case (inst3)
					3'b000: begin
						fun_out = `EXE_SB;
					end
					3'b001: begin
						fun_out = `EXE_SH;
					end
					3'b010: begin
						fun_out = `EXE_SW;
					end
					default: begin end
				endcase
			end
			`LUI, `AUIPC: begin
				op_out		= `EXE_ARTH;
				fun_out		= `EXE_ADD;
				reg_a1_out  = 5'h00;
				reg_re1_out	= 1'b0;
				reg_a2_out  = 5'h00;
				reg_re2_out	= 1'b0;
				rd_out		= inst2;
				imm_out		= `ZeroWord;
				inst_imm	= {inst_in[31:12], 12'h000};
			end
			default: begin
			end		
		endcase
	end
end

always @ (*) begin
	if ((rst_in) || (!rec_in) || (branch_we_in)) begin
		rs1_out	= `ZeroWord;
	end else if (reg_re1_out) begin
        if (reg_en1_in) begin
            rs1_out	= reg_d1_in;
        end else begin
            rs1_out	= `ZeroWord;
        end
    end else if(inst1 == `AUIPC || inst1 == `JAL) begin
        rs1_out	= pc_in;
    end else begin
        rs1_out	= `ZeroWord;
    end
end

always @ (*) begin
	if ((rst_in) || (!rec_in) || (branch_we_in)) begin
		rs2_out	= `ZeroWord;
	end else if(reg_re2_out) begin
        if (reg_en2_in) begin
            rs2_out	= reg_d2_in;
        end else begin
            rs2_out	= `ZeroWord;
        end
    end else begin
        rs2_out	= inst_imm;
    end
end

always @ (*) begin
    if ((rst_in) || (!rec_in) || (branch_we_in)) begin
        blk_out = 1'b0;
        rec_out = 1'b0;
    end else begin  
        if (((reg_re1_out) && (!reg_en1_in)) || ((reg_re2_out) && (!reg_en2_in))) begin
            blk_out = 1'b1;
            rec_out = 1'b0;
        end else begin
            blk_out = 1'b0;
            rec_out = 1'b1;
        end
    end
end

endmodule
