module decodingBlock (
    input clk,
    input forwardALUDA,
    input forwardALUDB, reset, flush, stall, regWriteWb,
    input wire [3:0] opCode,
    input wire [2:0] readReg1, readReg2, writeRegWb,
    input wire [19:0] writeDataWb,
    input wire [9:0] imm,
    input wire [19:0] ALU_F,
    input wire [19:0] pc_plus4,
    input wire [19:0] instruction_out,
    output wire [1:0] aluOp,
    output wire memWrite, memToReg, memRead, regDst, swiSel, jmnSel, pmcSel, aluSrc, regWrite,jump_in,branch,
    output wire [19:0] readData1, readData2, extended_imm, jump_add, pc4,
    output wire [19:0] branchAdd,
    output wire [2:0] rs, rt, rd,
    output wire [3:0] funct
    
);
	wire [1:0] aluOp_in;
	wire regWrite_in;
	wire extd;
	wire aluSrc_in;
	wire memWrite_in;
	wire memToReg_in;
	wire memRead_in;
	wire branch_en_in;
	wire regDst_in;
	wire swiSel_in;
	wire jmnSel_in;
	wire pmcSel_in;

        wire [19:0] readD1, readData1_in, readData2_in, extended_imm_in;
        wire [19:0] readD2;
	wire zero;
	wire branch_en;
	wire [19:0] shifted_imm;
	wire jump;
	
	controlUnit instance1 (
    	opCode,
    	aluOp_in,
    	regWrite_in,
    	extd,
    	aluSrc_in,
    	memWrite_in,
    	memToReg_in,
    	memRead_in,
    	branch_en,
    	jump_in,
    	regDst_in,
    	swiSel_in,
    	jmnSel_in,
    	pmcSel_in
	);


	regMemory instance3 (readReg1, readReg2, writeRegWb, writeDataWb,
        readD1, readD2, regWriteWb, clk);
	mux mu1(forwardALUDA, readD1, ALU_F, readData1_in);
	mux mu2(forwardALUDB, readD2, ALU_F, readData2_in);  
	signExtend instance4 ( imm, extd, extended_imm_in );
	assign zero = (readData1_in == readData2_in) ? 1'b1 : 1'b0;
	assign branch = zero & branch_en;

        assign shifted_imm = extended_imm_in << 2;
        assign branchAdd = pc_plus4+shifted_imm;

jump j (
    .jump(instruction_out[12:0]),
    .pc4(pc_plus4[19:15]),
    .out(jump_add)
);

ID_IE IDE (
    clk,
    reset,
    flush,
    stall,
    regWrite_in,
    
    aluOp_in,
    memWrite_in, memToReg_in, memRead_in, regDst_in, swiSel_in, jmnSel_in, pmcSel_in, aluSrc_in,jump_in,
    readData1_in, readData2_in, extended_imm_in, pc_plus4,
    readReg1, readReg2, instruction_out[9:7], instruction_out[3:0],

    aluOp,
    memWrite, memToReg, memRead, regDst, swiSel, jmnSel, pmcSel, aluSrc,jump,
    readData1, readData2, extended_imm, pc4,
    rs, rt, rd,
    regWrite, funct
);



endmodule
