module signExtend (
    input wire [9:0] imm,
    input wire extd,
    output reg [19:0] extended_imm
);
    always @(*) begin
        extended_imm = (extd == 0) ? {10'b0, imm} : {{10{imm[9]}}, imm};
    end
endmodule
