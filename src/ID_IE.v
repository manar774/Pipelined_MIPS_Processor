module ID_IE (
    input wire clk,
    input wire reset,
    input wire flush,
    input wire stall,
    input wire regWrite_in,
    
    input wire [1:0] aluOp_in,
    input wire memWrite_in, memToReg_in, memRead_in, regDst_in, swiSel_in, jmnSel_in, pmcSel_in, aluSrc_in,jump_in,
    input wire [19:0] readData1_in, readData2_in, extended_imm_in, pc4_in,
    input wire [2:0] rs, rt, rd,
    input wire [3:0] funct_in,

    output reg [1:0] aluOp_out,
    output reg memWrite_out, memToReg_out, memRead_out, regDst_out, swiSel_out, jmnSel_out, pmcSel_out, aluSrc_out,jump,
    output reg [19:0] readData1_out, readData2_out, extended_imm_out, pc4,
    output reg [2:0] rs_out, rt_out, rd_out,
    output reg regWrite,
    output reg [3:0] funct
);


always @(posedge clk) begin
    if (reset || flush) begin
        aluOp_out <= 2'b00;
        memWrite_out <= 0;
        memToReg_out <= 0;
        memRead_out <= 0;
        regDst_out <= 0;
        swiSel_out <= 0;
        jmnSel_out <= 0;
        pmcSel_out <= 0;
        aluSrc_out <= 0;
        readData1_out <= 20'b0;
        readData2_out <= 20'b0;
        extended_imm_out <= 20'b0;
        rs_out <= 3'b000;
        rt_out <= 3'b000;
        rd_out <= 3'b000;
	regWrite <= 0;
	funct <= 0;
	pc4 <= 0;
	jump <= 0;

    end else if (!stall) begin
        aluOp_out <= aluOp_in;
        memWrite_out <= memWrite_in;
        memToReg_out <= memToReg_in;
        memRead_out <= memRead_in;
        regDst_out <= regDst_in;
        swiSel_out <= swiSel_in;
        jmnSel_out <= jmnSel_in;
        pmcSel_out <= pmcSel_in;
        aluSrc_out <= aluSrc_in;
        readData1_out <= readData1_in;
        readData2_out <= readData2_in;
        extended_imm_out <= extended_imm_in;
        rs_out <= rs;
        rt_out <= rt;
        rd_out <= rd;
	regWrite <= regWrite_in;
	funct <= funct_in;
	pc4 <= pc4_in;
	jump <= jump_in;
    end
    // else: stall active, retain previous values
end

endmodule

