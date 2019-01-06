
`include "define.v"

module EX (
	input	wire				rst_in,

	input	wire	[`OpBus]	op_in,
	input	wire	[`FunBus]	fun_in,
	input	wire	[`RegData]	A_in,
	input	wire	[`RegData]	B_in,
	input	wire	[`RegBus]	rd_in,	
	input	wire	[`ImmBus]	imm_in,
	input	wire				rec_in,

	output	reg		[`OpBus]	op_out,
	output	reg		[`FunBus]	fun_out,
	output	reg		[`ImmBus]	res_out,
	output	reg		[`ImmBus]	imm_out,
	output	reg		[`RegBus]	rd_out,
	output	reg					rec_out,
	output	reg					reg_we_out,
	output	reg		[`InstAddr]	branch_pc_out,
	output	reg					branch_we_out	
);

always @ (*) begin
	if (rst_in || (!rec_in)) begin
		op_out		= `OpZero;
		fun_out		= `FunZero;
		res_out		= `ZeroWord;
		imm_out		= `ZeroWord;
		rd_out		= `RegZero;
		rec_out		= 1'b0;
		reg_we_out	= 1'b0;
	end else begin
		op_out	= op_in;
		fun_out	= fun_in;
		rd_out	= rd_in;
		rec_out	= 1'b1;
		case (op_in)
			`EXE_ARTH: begin
			    imm_out	= `ZeroWord;
			    reg_we_out = 1'b1;
				case (fun_in)
					`EXE_ADD: begin
						res_out	= A_in + B_in;
					end
					`EXE_SUB: begin
						res_out	= A_in - B_in;
					end
					default: begin
					end
				endcase
			end
			`EXE_LOGIC: begin
			    imm_out	= `ZeroWord;
			    reg_we_out = 1'b1;
				case (fun_in)
					`EXE_AND: begin
						res_out	= A_in & B_in;
					end
					`EXE_OR: begin
						res_out	= A_in | B_in;
					end
					`EXE_XOR: begin
						res_out	= A_in ^ B_in;
					end
					default: begin
					end
				endcase
			end
			`EXE_SHIFT: begin
			    imm_out	= `ZeroWord;
			    reg_we_out = 1'b1;
				case (fun_in)
					`EXE_SLL: begin
						res_out	= A_in << B_in[4:0];
					end
					`EXE_SRL: begin
						res_out	= A_in >> B_in[4:0];
					end
					`EXE_SRA: begin
						res_out	= ($signed(A_in)) >>> B_in[4:0];
					end
					default: begin
					end
				endcase
			end
			`EXE_COMP: begin
			    imm_out	= `ZeroWord;
			    reg_we_out = 1'b1;
				case (fun_in)
					`EXE_SLT: begin
						res_out	= ($signed(A_in) < $signed(B_in));
					end
					`EXE_SLTU: begin
						res_out	= (A_in < B_in);
					end
					default: begin
					end
				endcase
			end
			`EXE_BRANCH: begin
			    imm_out	= `ZeroWord;
				case (fun_in)
					`EXE_JAL, `EXE_JALR: begin
						reg_we_out	= 1'b1;
						res_out		= imm_in;
					end
					default: begin
						reg_we_out	= 1'b0;
						res_out		= `ZeroWord;
					end
				endcase
			end
			`EXE_LORE: begin
				reg_we_out = 1'b0; 
				if (fun_in <= 3'b100) begin
					imm_out	= `ZeroWord;
					res_out	= A_in + B_in;
				end else begin
					imm_out	= B_in;
					res_out	= A_in + imm_in;
				end
			end
			default: begin
			    res_out		= `ZeroWord;
                imm_out     = `ZeroWord;
                reg_we_out	= 1'b0;
			end		
		endcase
	end
end

always @ (*) begin
	if ((rst_in) || (!rec_in)) begin
		branch_we_out = 1'b0;
		branch_pc_out = `ZeroWord;
	end else begin
	    branch_we_out = 1'b0;
        branch_pc_out = `ZeroWord;
        if (op_in == `EXE_BRANCH) begin
        	if (fun_in <= `EXE_JALR) begin
        		branch_we_out = 1'b1;
        	end else begin
        		branch_pc_out = imm_in;
        	end
        	case (fun_in)
				`EXE_JAL: begin
				    branch_pc_out = A_in + B_in;
				end
				`EXE_JALR: begin
				    branch_pc_out = ((A_in + B_in) >> 1'b1) << 1'b1;
				end		
		        `EXE_BEQ: begin	
		        	branch_we_out = (A_in == B_in);
		        end
		        `EXE_BNE: begin
		        	branch_we_out = (A_in != B_in);
		        end
		        `EXE_BLT: begin
		        	branch_we_out = ($signed(A_in) < $signed(B_in));
		        end
		        `EXE_BLTU: begin
		        	branch_we_out = (A_in < B_in);
		        end
		        `EXE_BGE: begin
		        	branch_we_out = ($signed(A_in) >= $signed(B_in));
		        end
		        `EXE_BGEU: begin
		        	branch_we_out = (A_in >= B_in);
				end
				default: begin
				end 
			endcase
        end 
	end
end

endmodule
