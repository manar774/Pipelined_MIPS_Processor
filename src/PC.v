module PC(input jump, branch, zero, pmc_one, pmc_two, ji, clk, rst, input [18:0] adder, jumpAddress, signExtend, memory, output reg [18:0] instructionAddress, pc_plus);

assign bneCtrl = branch & zero;
reg [18:0] next_state, branch_mux, jump_mux, ji_mux;

//Sequential logic
always @(posedge clk or posedge rst) 
begin
    if(rst)
	instructionAddress <= 0;
    else
	instructionAddress <= next_state;
end



//Combinational logic
always @(*)
begin
	pc_plus = instructionAddress + 4;

	if(bneCtrl)
	branch_mux = adder;
	else
	branch_mux = pc_plus;

	if(jump)
	jump_mux = jumpAddress;
	else
	jump_mux = branch_mux;
	
	if(ji)
	ji_mux = memory;
	else
	ji_mux = jump_mux;

	next_state = ji_mux;
end

endmodule

 
