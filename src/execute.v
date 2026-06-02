module execute(
input  memWrite, memRead, clk, memToreg, pmcSel, ALUsrc, regDst, swiSel, jmnSel, reset, flushExMem, stallExMem, flushMemWb, stallMemWb, regWrite,
input [1:0] ALUop, forwardA, forwardB, 
input [3:0] funct, 
input [19:0] readData1, imm, readData2, pc4,
input wire [2:0] rs, rt, rd,
output wire regWrite_mem, regWriteWb, memToReg_mem, pmcSel_out, jmn_out,
output wire [2:0] writeReg,
output wire [2:0] writeRegMem,
output [19:0] writeDataReg, readDataMem, aluResultWb, ALUF, MEMF );

wire [2:0] ctrl_out, writeReg_EX;
wire [19:0] ALU_out;
wire [19:0] data_out;
wire [19:0] r;
wire [19:0] w;
wire [19:0] writeDataMemory;
wire [19:0] op2b;
wire [19:0] op1, op2;
wire [19:0] op1b;
wire [19:0] op2bf;
wire memWrite_mem, memRead_mem;
wire regDst_mem, swiSel_mem, jmnSel_mem, pmcSel_mem, aluSrc_mem;
wire [2:0] rd_mem;
wire [19:0] ALU_out_mem, readData2_mem, pc4_mem, readDataMem_mem, readDataWb;

//Mux for destination Register
WriteRegisterSelector instance2 (rt , rd, rs, regDst, swiSel, writeReg_EX); 

//ALU input choice
ALUctrl ctrl(ALUop, funct, ctrl_out);
mux mu7(ALUsrc, op2b, imm, op2);

//Forwarding for ALU
//2nd inputA
mux mu8(forwardB[1], readData2, MEMF , op2bf);
mux mu4(forwardB[0], op2bf, ALUF, op2b);
//1st input
mux mu5(forwardA[1], readData1, MEMF, op1b);
mux mu6(forwardA[0], op1b, ALUF, op1);

//ALU
ALU alu(op1, op2, ctrl_out, ALU_out, zero);

//EX-MEM Pipelining register
EX_MEM_Register ex_mem (
    clk,
    reset,
    flushExMem,
    stallExMem,
    regWrite,
    memWrite, memToreg, memRead,
    regDst, swiSel, jmnSel, pmcSel, ALUsrc,
    writeReg_EX,
    ALU_out, 
    op2b, pc4, 
    memWrite_mem, memToReg_mem, memRead_mem,
    regDst_mem, swiSel_mem, jmnSel_mem, pmcSel_mem, aluSrc_mem, regWrite_mem,
    rd_mem,
    ALU_out_mem, readData2_mem, pc4_mem
);
assign writeRegMem = rd_mem;
assign ALUF = ALU_out_mem; 
mux mu1(pmcSel_mem, ALU_out_mem, readData2_mem ,r);
mux mu3(pmcSel_mem, readData2_mem, pc4_mem, writeDataMemory);  
dataMemory dm(memWrite_mem, memRead_mem, clk, r, writeDataMemory, ALU_out_mem, readDataMem_mem);
MEM_WB_Register memWB (
    clk,
    reset,
    flushMemWb,
    stallMemWb,

    // Control signals from Memory stage
    memToReg_mem,
    regWrite_mem, pmcSel_mem, jmnSel_mem,
    rd_mem,

    // Data signals from Memory stage
    readDataMem_mem,
    ALU_out_mem,

    // Outputs to Write Back stage
    memToRegWb,
    regWriteWb, pmcSel_out, jmn_out,
    writeReg,
    readDataMem,
    aluResultWb
);


mux mu2(memToRegWb, aluResultWb, readDataMem, writeDataReg);
assign MEMF = writeDataReg;


endmodule


