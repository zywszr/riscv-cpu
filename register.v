
`include "define.v"

module register (
	input	wire				clk_in,
	input	wire				rst_in,

	input	wire	[`RegBus]	waddr1_in,
	input	wire	[`RegData]	wdata1_in,
	input	wire				we1_in,

	input	wire	[`RegBus]	waddr2_in,
	input	wire	[`RegData]	wdata2_in,
	input	wire				we2_in,

	input	wire				re1_in,
	input	wire	[`RegBus]	raddr1_in,
	output	reg		[`RegData]	rdata1_out,
	output	reg					re1_out,

	input	wire				re2_in,
	input	wire	[`RegBus]	raddr2_in,
	output	reg		[`RegData]	rdata2_out,
	output	reg					re2_out
);

reg	[`RegData]	regs[0:31];

always @ (posedge clk_in) begin
	if (rst_in == 1'b0) begin
		if (we1_in == 1'b1 && (waddr1_in != `RegZero)) begin
			regs[waddr1_in] <= wdata1_in;
		end
	end
end

always @ (*) begin
	if (rst_in == 1'b1) begin
		rdata1_out	= `ZeroWord;
		re1_out		= 1'b0;
	end else begin
		if (re1_in == 1'b1) begin
			if (raddr1_in == 5'h00) begin
			    rdata1_out	= `ZeroWord;
				re1_out		= 1'b1;
			end else begin
				if (raddr1_in == waddr2_in) begin 
					if (we2_in == 1'b1) begin
					    rdata1_out	= wdata2_in;
						re1_out		= 1'b1;
					end else begin
						rdata1_out  = `ZeroWord;	
						re1_out		= 1'b0;
					end
				end else if (raddr1_in == waddr1_in) begin
					if (we1_in == 1'b1) begin
						rdata1_out	= wdata1_in;
						re1_out		= 1'b1;
					end else begin		
						rdata1_out	= `ZeroWord;
						re1_out		= 1'b0;
					end
				end else begin
				    rdata1_out	= regs[raddr1_in];
					re1_out		= 1'b1;
				end
			end
		end else begin
		    rdata1_out	= `ZeroWord;
			re1_out		= 1'b1;
		end
	end
end

always @ (*) begin
	if (rst_in == 1'b1) begin
		rdata2_out	= `ZeroWord;
		re2_out		= 1'b0;
	end else begin
        if (re2_in == 1'b1) begin
            if (raddr2_in == 5'h00) begin
                rdata2_out  = `ZeroWord;
                re2_out     = 1'b1;
            end else begin
                if (raddr2_in == waddr2_in) begin
                    if (we2_in == 1'b1) begin
                        rdata2_out  = wdata2_in;
                        re2_out     = 1'b1;
                    end else begin
                        rdata2_out  = `ZeroWord;
                        re2_out     = 1'b0;
                    end
                end else if (raddr2_in == waddr1_in) begin
                    if (we1_in == 1'b1) begin
                        rdata2_out  = wdata1_in;                        
                        re2_out     = 1'b1;
                    end else begin
                        rdata2_out  = `ZeroWord;
                        re2_out     = 1'b0;        
                    end
                end else begin
                    rdata2_out  = regs[raddr2_in];
                    re2_out     = 1'b1;
                end
            end
        end else begin
            rdata2_out  = `ZeroWord;
            re2_out     =    1'b1;
        end
	end
end

endmodule
