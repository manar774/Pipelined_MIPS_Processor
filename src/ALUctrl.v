module ALUctrl(input [1:0] ALUop, input [3:0] funct, output reg [2:0] ctrl);

always @(*) begin

case (ALUop)

	//Add for load and sw
        2'b00: begin
	ctrl = 3'b010;
	end 

	//Sub for BEQ
	2'b01: begin
	ctrl = 3'b110;
	end

	//R-type funct is idential to ALU required control signal
        2'b10: begin
	ctrl = funct[2:0];
	end
	
	//ANDI
        2'b11: begin
	ctrl = 3'b000;
	end 
endcase

end

endmodule

