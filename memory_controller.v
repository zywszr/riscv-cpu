
`include "define.v"

module memory_controller (
	input	wire					clk_in,
	input	wire					rst_in,
	input   wire                    rdy_in,

	input	wire					blk_in,
	input	wire	[`InstAddr]		pc_in, 
	output	wire	[`InstData]		inst_out,	
	
	input	wire	[`MemoryAddr]	MEM_a_in,
	input	wire	[`MemoryData]	MEM_d_in,
	input	wire	[`LoreLength]	MEM_l_in,	// 要访问的地址长度
	input	wire	[`MEMwr]		MEM_wr_in,	// 读取，写入，无操作
	output	wire	[`MemoryData]	MEM_d_out,
	output	reg						MEM_en_out,	
    output  reg                     MEM_wr_out,
    
	input	wire	[`MemoryBus]	mem_d_in,
	output	wire	[`MemoryBus]	mem_d_out,
	output	wire	[`MemoryAddr]	mem_a_out,
	output	wire					mem_wr_out,

	output	wire					clk_out
);

reg	[3:0]           q_cnt,		d_cnt; // 计数器
reg [`InstData]     q_inst,     d_inst;
reg [`MemoryData]   q_MEM_d,    d_MEM_d;
reg [`MemoryAddr]   q_mem_a,	d_mem_a;
reg [`MemoryBus]	q_mem_d,	d_mem_d;
reg					q_mem_wr,	d_mem_wr;				
reg                 q_rdy;	

always @ (posedge clk_in) begin
	if (rst_in) begin
		q_cnt		<= 4'h6;
		q_rdy       <= 1'b1;
		q_inst      <= `ZeroWord;
		q_MEM_d     <= `ZeroWord;
		q_mem_a		<= `ZeroWord;
		q_mem_d		<= `ZeroByte;
		q_mem_wr	<= 1'b0;
	end else begin
	    if (rdy_in == 1'b0) begin
	        q_cnt   <= 4'h6;
	    end else begin
	        q_cnt   <= d_cnt;
	    end
		q_rdy       <= rdy_in;
        q_inst      <= d_inst;
        q_MEM_d     <= d_MEM_d;
        q_mem_a		<= d_mem_a;
		q_mem_d		<= d_mem_d;
		q_mem_wr	<= d_mem_wr;
	end
end

always @ (*) begin
	if (rst_in) begin
		d_MEM_d	    = `ZeroWord;
		d_mem_d		= `ZeroByte;
		d_mem_a		= `ZeroWord;
		d_mem_wr	= 1'b0;
		d_cnt		= 4'h6;
		MEM_en_out	= 1'b0;
		MEM_wr_out  = 1'b1;
		d_inst      = `ZeroWord;
	end else begin
      	
        d_MEM_d	    = q_MEM_d;
        d_mem_d   	= `ZeroByte;
        d_mem_wr	= 1'b0;
        d_cnt       = 4'h6;
        d_inst      = q_inst;
		
		if (q_cnt <= 4'h5) begin
			MEM_wr_out = 1'b1;
		end else begin
			MEM_wr_out = 1'b1;
		end
		
        case (q_cnt)
			4'b0000: begin
				if (blk_in) begin
				    d_mem_a	= `ZeroWord;
					d_cnt 	= 4'h6; 		
				end else begin
					d_mem_a	= pc_in;
					d_cnt	= 4'h1;
				end
			end
			4'b0001: begin
				d_mem_a	= pc_in + 32'h1;
				d_cnt	= 4'h2;
			end
			4'b0010: begin
				d_mem_a	= pc_in + 32'h2;
				d_inst	= {mem_d_in, q_inst[31:8]};
				d_cnt 	= 4'h3;
			end
			4'b0011: begin
				d_mem_a = pc_in + 32'h3;
				d_inst	= {mem_d_in, q_inst[31:8]};
				d_cnt	= 4'h4;
			end
			4'b0100: begin
			    d_mem_a	= q_mem_a;
				d_inst	= {mem_d_in, q_inst[31:8]};
				d_cnt	= 4'h5;
			end
			4'b0101: begin
			    d_mem_a	= q_mem_a;
				d_inst	= {mem_d_in, q_inst[31:8]};
				d_cnt	= 4'h6;
			end
			
			4'b0110: begin		
				if (MEM_wr_in == 2'b00) begin
			        d_mem_a = q_mem_a;
					d_cnt 	= 4'h0;
				end else begin	
					d_mem_a	= MEM_a_in;
					if (MEM_wr_in == 2'b01) begin
						d_cnt = 4'h7;
					end else begin
						d_mem_d   = MEM_d_in[7:0];
						d_mem_wr  = 1'b1;
						if (MEM_l_in == 3'h1) begin
							d_cnt = 4'h0;
						end else begin
							d_cnt = 4'h7;
						end
					end
				end
			end
			4'b0111: begin
				if (MEM_wr_in == 2'b01) begin			
					if (MEM_l_in > 3'h1) begin
						d_mem_a = MEM_a_in + 32'h1;	
					end else begin
					    d_mem_a	= q_mem_a;
					end
					d_cnt = 4'h8;
				end else begin
					d_mem_a		= MEM_a_in + 32'h1;
					d_mem_d		= MEM_d_in[15:8];
					d_mem_wr	= 1'b1;
					if (MEM_l_in == 3'h2) begin
						d_cnt = 4'h0;
					end else begin
						d_cnt = 4'h8;
					end
				end
			end
			4'b1000: begin
				if (MEM_wr_in == 2'b01) begin			    
					d_MEM_d = {mem_d_in, q_MEM_d[31:8]};
					if (MEM_l_in > 3'h2) begin
						d_mem_a = MEM_a_in + 32'h2;
					end else begin
					    d_mem_a	= q_mem_a;
					end
					if (MEM_l_in == 3'h1) begin
						d_cnt = 4'h0;
					end else begin
						d_cnt = 4'h9;
					end
				end else begin		
					d_mem_a 	= MEM_a_in + 32'h2;
					d_mem_d		= MEM_d_in[23:16];
					d_mem_wr	= 1'b1;
					if (MEM_l_in == 3'h3) begin
						d_cnt = 4'h0;
					end else begin
						d_cnt = 4'h9;
					end
				end
			end
			4'b1001: begin
				if (MEM_wr_in == 2'b01) begin
				    d_MEM_d = {mem_d_in, q_MEM_d[31:8]};
					if (MEM_l_in > 3'h3) begin
						d_mem_a = MEM_a_in + 32'h3;
					end else begin
					    d_mem_a	= q_mem_a;
					end
					if (MEM_l_in == 3'h2) begin
						d_cnt = 4'h0;
					end else begin
						d_cnt = 4'ha;
					end
				end else begin
				    d_mem_a 	= MEM_a_in + 32'h3;
					d_mem_d		= MEM_d_in[31:24];
					d_mem_wr	= 1'b1;
					d_cnt		= 4'h0;
				end
			end
			4'b1010: begin
			    d_mem_a	= q_mem_a;
			    d_MEM_d = {mem_d_in, q_MEM_d[31:8]};
				if (MEM_l_in == 3'h3) begin
					d_cnt = 4'h0;
				end else begin
					d_cnt = 4'hb;
				end
			end 
			4'b1011: begin
			    d_mem_a	= q_mem_a;
			    d_MEM_d = {mem_d_in, q_MEM_d[31:8]};
				d_cnt	= 4'h0;
			end
			default: begin
			end
		endcase
		
		if (q_cnt >= 4'h6 && MEM_wr_in == 2'b01 && q_cnt < MEM_l_in + 7) begin
			MEM_en_out = 1'b0;
		end else begin
			MEM_en_out = 1'b1;
		end
		
	end
end

assign clk_out		= (q_cnt == 4'h6) && (q_rdy);
assign mem_a_out    = q_mem_a;
assign mem_d_out    = q_mem_d;
assign mem_wr_out   = q_mem_wr;
assign inst_out     = d_inst;
assign MEM_d_out    = d_MEM_d;

endmodule
