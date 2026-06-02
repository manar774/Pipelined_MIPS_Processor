
module IF_ID (
    input wire clk,
    input wire reset,
    input wire flush,
    input wire stall,                
    input wire [19:0] instruction_in,    
    input wire [19:0] pc_plus4_in,        

    output reg [19:0] instruction_out,    
    output reg [19:0] pc_plus4        
);
    always @(posedge clk or posedge reset) 
	begin
        if (reset || flush) begin
            instruction_out <= 32'b0;
            pc_plus4    <= 32'b0;
        end
 
        else if (!stall) begin
            instruction_out <= instruction_in;
            pc_plus4 <= pc_plus4_in;
        end
    end
endmodule
