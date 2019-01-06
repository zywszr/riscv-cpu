
`define ZeroWord	32'h00000000
`define ZeroByte    8'h00
`define	OpZero		3'b000
`define	FunZero		3'b000
`define	RegZero		5'h00

`define LoreLength	2:0
`define MEMwr		1:0
`define MemoryAddr	31:0
`define MemoryData	31:0
`define MemoryBus	7:0
`define InstAddr	31:0
`define InstData	31:0
`define RegData		31:0
`define RegBus		4:0
`define OpBus		2:0
`define FunBus		2:0
`define ImmBus		31:0

`define IMM			7'b0010011
`define OP			7'b0110011
`define JAL			7'b1101111
`define JALR		7'b1100111
`define BRANCH		7'b1100011
`define LOAD		7'b0000011
`define STORE		7'b0100011
`define LUI			7'b0110111
`define AUIPC		7'b0010111

`define	ADDI		3'b000
`define SLTI		3'b010
`define	SLTIU		3'b011
`define	ANDI		3'b111
`define ORI			3'b110
`define XORI		3'b100
`define SLLI		3'b001
`define	ADD			3'b000
`define	SLT			3'b010
`define	SLTU		3'b011
`define	AND			3'b111
`define	OR			3'b110
`define	XOR			3'b100
`define	SLL			3'b001
`define	SRL			3'b101
`define	BEQ			3'b000
`define	BNE			3'b001
`define	BLT			3'b100
`define	BLTU		3'b110
`define	BGE			3'b101
`define	BGEU		3'b111

`define EXE_ARTH	3'b000
`define EXE_LOGIC	3'b001
`define EXE_SHIFT	3'b010
`define	EXE_COMP	3'b011
`define EXE_BRANCH	3'b100
`define	EXE_LORE	3'b101

// Arithmetic
`define	EXE_ADD		3'b000	
`define	EXE_SUB		3'b001

// Logic
`define EXE_AND		3'b000
`define EXE_OR		3'b001
`define EXE_XOR		3'b010

// Shift
`define EXE_SLL		3'b000
`define EXE_SRL		3'b001
`define EXE_SRA		3'b010

// Compare
`define	EXE_SLT		3'b000
`define EXE_SLTU	3'b001

// Branch
`define EXE_JAL		3'b000
`define EXE_JALR	3'b001
`define EXE_BEQ		3'b010
`define	EXE_BNE		3'b011
`define	EXE_BLT		3'b100
`define	EXE_BGE		3'b101
`define	EXE_BLTU	3'b110
`define	EXE_BGEU	3'b111

// Load & Store
`define	EXE_LB		3'b000 
`define	EXE_LH		3'b001
`define	EXE_LW		3'b010
`define	EXE_LBU		3'b011
`define	EXE_LHU		3'b100
`define	EXE_SB		3'b101
`define	EXE_SH		3'b110
`define	EXE_SW		3'b111
