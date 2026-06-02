module ALU(input [19 : 0] A,input [19:0] B, input [2:0] ALUctrl, output reg [19 : 0] result, output reg zero);

    always @(*) begin
        case (ALUctrl)
            3'b000: result = A & B;       
            3'b001: result = A | B;      
            3'b010: result = A + B;      
	    3'b110: result = A - B;
	    3'b111: result = (A < B) ? 1 : 0;        
            default: result = 4'b0000;
        endcase
        
        // Set Zero flag
        zero = (result == 0) ? 1'b1 : 1'b0;
    end
endmodule

