module EX_MEM_Register (
    input wire clk,
    input wire reset,
    input wire flush,
    input wire stall,
    input wire regWrite_in,
    input wire memWrite_in, memToReg_in, memRead_in,
    input wire regDst_in, swiSel_in, jmnSel_in, pmcSel_in, aluSrc_in,

    input wire [2:0] rd,
    input wire [19:0] ALU_out, readData2, pc4,

    output reg memWrite_out, memToReg_out, memRead_out,
    output reg regDst_out, swiSel_out, jmnSel_out, pmcSel_out, aluSrc_out, regWrite,

    output reg [2:0] rd_out,
    output reg [19:0] ALU_out_out, readData2_out, pc4_out
);

always @(posedge clk) begin
    if (reset) begin
        memWrite_out   <= 0;
        memToReg_out   <= 0;
        memRead_out    <= 0;
        regDst_out     <= 0;
        swiSel_out     <= 0;
        jmnSel_out     <= 0;
        pmcSel_out     <= 0;
        aluSrc_out     <= 0;
        regWrite       <= 0;
        rd_out         <= 3'b000;
        ALU_out_out    <= 20'b0;
        readData2_out  <= 20'b0;
        pc4_out        <= 20'b0;
    end else if (stall) begin
        // hold previous values (do nothing)
    end else if (flush) begin
        memWrite_out   <= 0;
        memToReg_out   <= 0;
        memRead_out    <= 0;
        regDst_out     <= 0;
        swiSel_out     <= 0;
        jmnSel_out     <= 0;
        pmcSel_out     <= 0;
        aluSrc_out     <= 0;
        regWrite       <= 0;
        rd_out         <= 3'b000;
        ALU_out_out    <= 20'b0;
        readData2_out  <= 20'b0;
        pc4_out        <= 20'b0;
    end else begin
        memWrite_out   <= memWrite_in;
        memToReg_out   <= memToReg_in;
        memRead_out    <= memRead_in;
        regDst_out     <= regDst_in;
        swiSel_out     <= swiSel_in;
        jmnSel_out     <= jmnSel_in;
        pmcSel_out     <= pmcSel_in;
        aluSrc_out     <= aluSrc_in;
        regWrite       <= regWrite_in;
        rd_out         <= rd;
        ALU_out_out    <= ALU_out;
        readData2_out  <= readData2;
        pc4_out        <= pc4;
    end
end

endmodule

