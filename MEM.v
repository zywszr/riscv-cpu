
`include "define.v"

module MEM (
	input	wire					rst_in,
	
	input	wire	[`OpBus]		op_in,
	input	wire	[`FunBus]		fun_in,
	input	wire	[`ImmBus]		res_in,
	input	wire	[`ImmBus]		imm_in,
	input	wire	[`RegBus]		rd_in,
	input	wire					rec_in,

	input	wire	[`MemoryData]	mem_d_in,
	input	wire					mem_en_in,
	input   wire                    mem_wr_in,
	output	reg		[`MemoryAddr]	mem_a_out,
	output	reg		[`MemoryData]	mem_d_out,
	output	reg		[`LoreLength]	mem_l_out,
	output	reg		[`MEMwr]		mem_wr_out,

	output	reg		[`RegBus]		rd_out,
	output	reg		[`ImmBus]		reg_d_out,
	output	reg						reg_we_out
);

always @ (*) begin
	if (rst_in || (!rec_in) || (!mem_wr_in)) begin
		mem_a_out	= `ZeroWord;
		mem_d_out	= `ZeroWord;
		mem_l_out	= 3'h0;
		mem_wr_out	= 2'b00;
	end else begin
		if (op_in == `EXE_LORE) begin
			mem_a_out = res_in;
			if (fun_in <= 3'b100) begin
				mem_wr_out	= 2'b01;
				mem_d_out   = `ZeroWord;
			end else begin			
				mem_wr_out	= 2'b10;
				mem_d_out	= imm_in;
			end
			case (fun_in)
				`EXE_LB:   mem_l_out = 3'h1;
				`EXE_LH:   mem_l_out = 3'h2;
				`EXE_LW:   mem_l_out = 3'h4;
				`EXE_LBU:  mem_l_out = 3'h1;
				`EXE_LHU:  mem_l_out = 3'h2;
				`EXE_SB:   mem_l_out = 3'h1;
				`EXE_SH:   mem_l_out = 3'h2;
				`EXE_SW:   mem_l_out = 3'h4;
				default: begin
				end
			endcase
		end else begin
			mem_a_out  = `ZeroWord;
			mem_d_out  = `ZeroWord;
			mem_l_out  = 3'h0;
			mem_wr_out = 2'b00;
		end
	end
end

always @ (*) begin
	if (rst_in || (!rec_in)) begin
		rd_out		= `RegZero;
		reg_d_out	= `ZeroWord;
		reg_we_out	= 1'b0;
	end else begin
        rd_out      = rd_in;
		if (op_in == `EXE_LORE) begin
			reg_d_out = `ZeroWord;
			if (fun_in <= 3'b100 && mem_en_in) begin
				reg_we_out	= 1'b1;
				case (fun_in)
					`EXE_LB:	reg_d_out = $signed(mem_d_in[31:24]);
					`EXE_LH:	reg_d_out = $signed(mem_d_in[31:16]);
					`EXE_LW:	reg_d_out = $signed(mem_d_in[31:0]);
					`EXE_LBU:	reg_d_out = mem_d_in[31:24];
					`EXE_LHU:	reg_d_out = mem_d_in[31:16];
					default: begin   
					end
				endcase
			end else begin
				reg_we_out	= 1'b0;
			end
		end else begin
			reg_d_out	= res_in;
			reg_we_out	= 1'b1;
		end
	end
end

endmodule