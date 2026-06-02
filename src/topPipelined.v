module top (
    input clk,
    input reset
);

// Internal wires

// Fetch Stage
wire [19:0] instruction_out;
wire [19:0] read_data;
wire [19:0] branchadd, jump_add, pc_plus4;
wire overflow;

// Decode Stage
wire [2:0] rs, rt, rd;
wire [1:0] aluOp, forwardA, forwardB;
wire [19:0] extended_imm, branchAdd, MEMF;
wire [19:0] readData1, readData2, ALU_MEM;
wire [3:0] funct;
wire [19:0] pc4;
wire memWrite, memRead, memToReg, regDst, swiSel, jmnSel, pmcSel, aluSrc, regWrite, jump;

// Execute Stage
wire [2:0] writeRegMem, writeRegWb;
wire [19:0] writeDataWb, aluResultWb;

// Forwarding Unit
wire forwardAlurs, forwardAlurt;
wire forwardMemrs, forwardMemrt;
wire forwardBranchRs, forwardBranchRt;

// Hazard Unit
wire stallIF, stallID, stallIE;
wire flushIF, flushID, flushIE, flushIMEM;
wire jump_en, branch, pmcMem, jmnMem;
wire jmn_en = jmnMem;  // Assigning hazard unit output to fetch input

// Control for pipeline stages
wire flushIDIE = flushID;  // alias
wire stallIDIE = stallID;
wire flushExMem = flushIE;
wire stallExMem = stallIE;
wire flushMemWb = flushIMEM;
wire stallMemWb = 0;


// Forwarding Unit
forwardingUnit fu (
    .rs(rs),
    .rt(rt),
    .rdMem(writeRegMem),
    .rdWb(writeRegWb),
    .regWrite_MEM(regWrite_mem),
    .regWrite_WB(regWriteWb),
    .regdst(regDst),
    .rs_ID(instruction_out[15:13]),
    .rt_ID(instruction_out[12:10]),
    .reset(reset),
    .forwardAlurs(forwardA[0]),
    .forwardAlurt(forwardB[0]),
    .forwardMemrs(forwardA[1]),
    .forwardMemrt(forwardB[1]),
    .forwardBranchRs(forwardBranchRs),
    .forwardBranchRt(forwardBranchRt)
);

hazardUnit hu (
    .forwardExrt(forwardB[0]),
    .forwardExrs(forwardA[0]),
    .mem2regMem(memToReg_mem),
    .stallIF(stallIF),
    .stallID(stallID),
    .stallIE(stallIE),
    .flushID(flushID),
    .flushIF(flushIF),
    .flushIE(flushIE),
    .flushIMEM(flushIMEM),
    .jump(jump_en),
    .branch(branch),
    .pmcMem(pmcSel_out),
    .jmnMem(jmnSel_out),
    .reset(reset),
    .enable(enable)
);


// Fetch Stage
FetchStage fs (
    .clk(clk),
    .reset(reset),
    .jump_en(jump_en),
    .jmn_en(jmnSel_out),
    .branch_en(branch),
    .read_data(read_data),
    .branchAdd(branchAdd),
    .jump_add(jump_add),
    .instruction_out(instruction_out),
    .pc_plus4(pc_plus4),
    .overflow(overflow),
    .enable(enable),
    .flush(flushIF),
    .stall(stallIF)
);


decodingBlock db (
    .clk(clk),
    .forwardALUDA(forwardBranchRs),
    .forwardALUDB(forwardBranchRt),
    .reset(reset),
    .flush(flushIDIE),
    .stall(stallIDIE),
    .opCode(instruction_out[19:16]),
    .readReg1(instruction_out[15:13]),
    .readReg2(instruction_out[12:10]),
    .writeRegWb(writeRegWb),
    .writeDataWb(writeDataWb),
    .imm(instruction_out[9:0]),
    .ALU_F(ALU_MEM),
    .pc_plus4(pc_plus4),
    .instruction_out(instruction_out),
    .aluOp(aluOp),
    .memWrite(memWrite),
    .memToReg(memToReg),
    .memRead(memRead),
    .regDst(regDst),
    .swiSel(swiSel),
    .jmnSel(jmnSel),
    .pmcSel(pmcSel),
    .aluSrc(aluSrc),
    .regWrite(regWrite),
    .readData1(readData1),
    .readData2(readData2),
    .extended_imm(extended_imm),
    .jump_add(jump_add),
    .branchAdd(branchAdd),
    .jump_in(jump_en),
    .rs(rs),
    .rt(rt),
    .rd(rd),
    .funct(funct),
    .pc4(pc4),
    .branch(branch),
    .regWriteWb(regWriteWb)
);
// Execute Stage
execute ex (
    .memWrite(memWrite),
    .memRead(memRead),
    .clk(clk),
    .memToreg(memToReg),
    .pmcSel(pmcSel),
    .ALUsrc(aluSrc),
    .regDst(regDst),
    .swiSel(swiSel),
    .jmnSel(jmnSel),
    .reset(reset),
    .flushExMem(flushExMem),
    .stallExMem(stallExMem),
    .flushMemWb(flushMemWb),
    .stallMemWb(stallMemWb),
     .writeRegMem(writeRegMem),
    .regWrite(regWrite),
    .ALUop(aluOp),
    .forwardA(forwardA),
    .forwardB(forwardB),
    .funct(funct),
    .readData1(readData1),
    .regWrite_mem(regWrite_mem), 
    .regWriteWb(regWriteWb),
    .imm(extended_imm),
    .readData2(readData2),
    .memToReg_mem(memToReg_mem),
    .pc4(pc4),
    .rs(rs),
    .rt(rt),
    .rd(rd),
    .writeReg(writeRegWb),
    .writeDataReg(writeDataWb),
    .readDataMem(read_data),
    .aluResultWb(aluResultWb),
    .pmcSel_out(pmcSel_out),
    .ALUF(ALU_MEM),
    .MEMF(MEMF),
    .jmn_out(jmnSel_out)
);

endmodule

