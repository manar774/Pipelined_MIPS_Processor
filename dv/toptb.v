`timescale 1ns/1ps
module toptb (
);
    reg clk, reset;

    top uut (.clk(clk), .reset(reset));

    wire memWrite, memToReg, memRead, branch, jump, regDst, swiSel, jmnSel, pmcSel, aluSrc;
    wire [1:0] aluOp;
    wire [19:0] instruction_out;
    wire [19:0] extended_imm;
    wire [19:0] readData1, readData2, writeDataReg, readDataMem;
    wire [19:0] pc_plus4;
    wire zero, overflow;

    assign memWrite = uut.memWrite;
    assign memToReg = uut.memToReg;
    assign memRead = uut.memRead;
    assign branch = uut.branch;
    assign jump = uut.jump;
    assign regDst = uut.regDst;
    assign swiSel = uut.swiSel;
    assign jmnSel = uut.jmnSel;
    assign pmcSel = uut.pmcSel;
    assign aluSrc = uut.aluSrc;
    assign aluOp = uut.aluOp;
    assign instruction_out = uut.instruction_out;
    assign extended_imm = uut.extended_imm;
    assign readData1 = uut.readData1;
    assign readData2 = uut.readData2;
    assign writeDataReg = uut.writeDataReg;
    assign readDataMem = uut.readDataMem;
    assign pc_plus4 = uut.pc_plus4;
    assign zero = uut.zero;
    assign overflow = uut.overflow;

    initial begin
        clk = 0;
        forever #100 clk = ~clk;
    end

    initial begin
        reset = 1;
        #100;
        reset = 0;
        #3000;
    end
endmodule
