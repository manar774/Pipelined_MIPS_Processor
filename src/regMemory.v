module regMemory (
    readReg1, readReg2, writeReg, writeData, readData1, readData2, regWrite, clk
);
    parameter regWidth = 20;
    parameter regDepth = 8;
    parameter regAddr = 3;
    input clk;
    input regWrite;
    input wire [regAddr - 1:0] readReg1, readReg2, writeReg;
    input wire [regWidth - 1:0] writeData;
    output reg [regWidth - 1:0] readData1, readData2;
    reg [regWidth - 1:0] memory [0:regDepth - 1];
    initial begin
        memory[0] = 0;
        memory[1] = 20'h00001;
        memory[2] = 20'h00002;
        memory[3] = 20'h00003;
        memory[4] = 20'h00004;
        memory[5] = 20'h00005;
        memory[6] = 20'h00006;
        memory[7] = 20'h00007;
    end
    always @(*) begin
    readData1 = (readReg1 == 0) ? 32'b0 : memory[readReg1];
    readData2 = (readReg2 == 0) ? 32'b0 : memory[readReg2];
    end

    always @(negedge clk) begin
        memory[writeReg] = (regWrite == 1) ? writeData : memory[writeReg];
    end
endmodule
