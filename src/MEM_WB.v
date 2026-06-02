module MEM_WB_Register (
    input wire clk,
    input wire reset,
    input wire flush,
    input wire stall,

    // Control signals from Memory stage
    input wire memToReg_in,
    input wire regWrite_in, pmcSel_in, jmn_in,
    input wire [2:0] rd,

    // Data signals from Memory stage
    input wire [19:0] readData_in,
    input wire [19:0] aluResult_in,

    // Outputs to Write Back stage
    output reg memToReg,
    output reg regWrite, pmcSel, jmn,
    output reg [2:0] rd_out,
    output reg [19:0] readData_out,
    output reg [19:0] aluResult_out
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        memToReg     <= 0;
        regWrite     <= 0;
        rd_out       <= 3'b000;
        readData_out <= 20'b0;
        aluResult_out<= 20'b0;
	jmn <= 0;
	pmcSel <= 0;
    end else if (flush) begin
        memToReg     <= 0;
        regWrite     <= 0;
        rd_out       <= 3'b000;
        readData_out <= 20'b0;
        aluResult_out<= 20'b0;
	jmn <= 0;
	pmcSel <= 0;
    end else begin
        memToReg     <= memToReg_in;
        regWrite     <= regWrite_in;
        rd_out       <= rd;
        readData_out <= readData_in;
        aluResult_out<= aluResult_in;
	jmn <= jmn_in;
	pmcSel <= pmcSel_in;
    end
end

endmodule

