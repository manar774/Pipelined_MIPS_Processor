`timescale 1ns / 1ps

module tb_execute;

    // Inputs
    reg clk, reset, flushExMem, stallExMem, flushMemWb, stallMemWb;
    reg memWrite, memRead, memToreg, pmcSel, ALUsrc, regDst, swiSel, jmnSel, regWrite;
    reg [1:0] ALUop, forwardA, forwardB;
    reg [3:0] funct;
    reg [19:0] readData1, readData2, imm, pc4, ALUF, MEMF;
    reg [2:0] rs, rt, rd;

    // Outputs
    wire [2:0] writeReg;
    wire [19:0] writeDataReg, readDataMem, aluResultWb;

    // Instantiate DUT
    execute uut (
        .memWrite(memWrite), .memRead(memRead), .clk(clk),
        .memToreg(memToreg), .pmcSel(pmcSel), .ALUsrc(ALUsrc),
        .regDst(regDst), .swiSel(swiSel), .jmnSel(jmnSel),
        .reset(reset), .flushExMem(flushExMem), .stallExMem(stallExMem),
        .flushMemWb(flushMemWb), .stallMemWb(stallMemWb), .regWrite(regWrite),
        .ALUop(ALUop), .forwardA(forwardA), .forwardB(forwardB),
        .funct(funct), .readData1(readData1), .imm(imm), .readData2(readData2),
        .pc4(pc4), .ALUF(ALUF), .MEMF(MEMF), .rs(rs), .rt(rt), .rd(rd),
        .writeReg(writeReg), .writeDataReg(writeDataReg),
        .readDataMem(readDataMem), .aluResultWb(aluResultWb)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Stimulus
    initial begin
        // Initialize control and data
        reset        = 1;
        flushExMem   = 0;
        stallExMem   = 0;
        flushMemWb   = 0;
        stallMemWb   = 0;

        memWrite     = 0;
        memRead      = 0;
        memToreg     = 0;
        pmcSel       = 0;
        ALUsrc       = 0;
        regDst       = 1;  // Use rd
        swiSel       = 0;
        jmnSel       = 0;
        regWrite     = 1;

        ALUop        = 2'b10;      // R-type
        forwardA     = 2'b00;      // No forwarding
        forwardB     = 2'b00;

        funct        = 4'b0010;    // ADD

        readData1    = 20'd1;
        readData2    = 20'd2;
        imm          = 20'd0;
        pc4          = 20'd0;
        ALUF         = 20'd0;
        MEMF         = 20'd0;

        rs = 3'd1;
        rt = 3'd2;
        rd = 3'd3;

        #10 reset = 0;

        // Wait a few cycles for result to propagate
        #50;

        $display("======== EXECUTE STAGE TEST ========");
        $display("readData1    = %d", readData1);
        $display("readData2    = %d", readData2);
        $display("ALU Result   = %d", aluResultWb);
        $display("WriteReg     = %d", writeReg);
        $display("====================================");

        $finish;
    end

endmodule

