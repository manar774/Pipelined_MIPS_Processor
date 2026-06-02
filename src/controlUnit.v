// Control Unit Module
module controlUnit (
    input wire [3:0] opCode,
    output reg [1:0] aluOp,
    output reg regWrite, extd, aluSrc, memWrite, memToReg, memRead, branch, jump, regDst, swiSel, jmnSel, pmcSel
);
    always @(*) begin
        case(opCode)

        // R-type Instructions Control Signals
        4'b0000: begin
            regDst = 1;
            jump = 0;
            branch = 0;
            extd = 0;
            memRead = 0;
            memToReg = 0;
            aluOp = 2'b10;
            memWrite = 0;
            aluSrc = 0;
            regWrite = 1;
            swiSel = 0;
            jmnSel = 0;
            pmcSel = 0;
        end

        // ADDI Instruction Control Signals
        4'b0001: begin
            regDst = 0;
            jump = 0;
            branch = 0;
            extd = 1;
            memRead = 0;
            memToReg = 0;
            aluOp = 2'b00;
            memWrite = 0;
            aluSrc = 1;
            regWrite = 1;
            swiSel = 0;
            jmnSel = 0;
            pmcSel = 0;
        end

        // ANDI Instruction Control Signals
        4'b0011: begin
            regDst = 0;
            jump = 0;
            branch = 0;
            extd = 0;
            memRead = 0;
            memToReg = 0;
            aluOp = 2'b11;
            memWrite = 0;
            aluSrc = 1;
            regWrite = 1;
            swiSel = 0;
            jmnSel = 0;
            pmcSel = 0;
        end

        // LW Instruction Control Signals
        4'b1001: begin
            regDst = 0;
            jump = 0;
            branch = 0;
            extd = 1;
            memRead = 1;
            memToReg = 1;
            aluOp = 2'b00;
            memWrite = 0;
            aluSrc = 1;
            regWrite = 1;
            swiSel = 0;
            jmnSel = 0;
            pmcSel = 0;
        end

        // SW Instruction Control Signals
        4'b1010: begin
            regDst = 0;
            jump = 0;
            branch = 0;
            extd = 1;
            memRead = 0;
            memToReg = 0;
            aluOp = 2'b00;
            memWrite = 1;
            aluSrc = 1;
            regWrite = 0;
            swiSel = 0;
            jmnSel = 0;
            pmcSel = 0;
        end

        // BEQ Instruction Control Signals
        4'b1011: begin
            regDst = 0;
            jump = 0;
            branch = 1;
            extd = 1;
            memRead = 0;
            memToReg = 0;
            aluOp = 2'b01;
            memWrite = 0;
            aluSrc = 0;
            regWrite = 0;
            swiSel = 0;
            jmnSel = 0;
            pmcSel = 0;
        end

        // JUMP Instruction Control Signals
        4'b1100: begin
            regDst = 0;
            jump = 1;
            branch = 0;
            extd = 1;
            memRead = 0;
            memToReg = 0;
            aluOp = 2'b00;
            memWrite = 0;
            aluSrc = 0;
            regWrite = 0;
            swiSel = 0;
            jmnSel = 0;
            pmcSel = 0;
        end

        // SWI Instruction Control Signals
        4'b1101: begin
            regDst = 0;
            jump = 0;
            branch = 0;
            extd = 1;
            memRead = 0;
            memToReg = 0;
            aluOp = 2'b00;
            memWrite = 1;
            aluSrc = 1;
            regWrite = 1;
            swiSel = 1;
            jmnSel = 0;
            pmcSel = 0;
        end

        // JMN Instruction Control Signals
        4'b1110: begin
            regDst = 0;
            jump = 0;
            branch = 0;
            extd = 1;
            memRead = 1;
            memToReg = 0;
            aluOp = 2'b00;
            memWrite = 0;
            aluSrc = 1;
            regWrite = 0;
            swiSel = 0;
            jmnSel = 1;
            pmcSel = 0;
        end

        // PMC Instruction Control Signals
        4'b1111: begin
            regDst = 0;
            jump = 0;
            branch = 0;
            extd = 1;
            memRead = 1;
            memToReg = 0;
            aluOp = 2'b00;
            memWrite = 1;
            aluSrc = 1;
            regWrite = 0;
            swiSel = 0;
            jmnSel = 1;
            pmcSel = 1;
        end

        // Default Control Signals
        default: begin
            regDst = 0;
            jump = 0;
            branch = 0;
            extd = 0;
            memRead = 0;
            memToReg = 0;
            aluOp = 2'b00;
            memWrite = 0;
            aluSrc = 0;
            regWrite = 0;
            swiSel = 0;
            jmnSel = 0;
            pmcSel = 0;
        end
        endcase
    end
endmodule
