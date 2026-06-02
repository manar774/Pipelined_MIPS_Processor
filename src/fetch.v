module ProgramCounterMux(
    input [19:0] jump_add, read_data, branch_add,  // from memory, ALU
    input [19:0] pc_plus4,
    input jump_en, jmn_en, branch_en,
    output [19:0] pc_next
);
    assign pc_next = jmn_en    ? read_data    :
                     jump_en   ? jump_add     :
                     branch_en ? branch_add   :
                                  pc_plus4;
endmodule 
 
module ProgramCounter(
    input clk, reset, enable,
    input [19:0] pc_in,
    output reg [19:0] pc_out
);
    always @(posedge clk or posedge reset) 
    begin
        if (reset)
            pc_out <= 20'd0;
        else if(!enable)
            pc_out <= pc_in; 
    end
endmodule

module LeftShifter_2bit(
    input [19:0] in_data,
    output reg [19:0] out_data
);
    always @(*)
    begin
        out_data = in_data << 2;
    end 
endmodule 

module InstructionMemory (
    input [17:0] addr,
    output reg [19:0] instr
);
    reg [19:0] inst_mem [0:128]; 

    initial begin
        inst_mem[0]  = 20'h03102; // R-type: add    0000 000 000 000 000 0000
        inst_mem[3]  = 20'h03101; // R-type: or     0000 001 100 010 000 0001
        inst_mem[2]  = 20'h03100; // R-type: and    0000 001 100 010 000 0000
        inst_mem[1]  = 20'h03106; // R-type: sub    0000 001 100 010 000 0110
        inst_mem[4]  = 20'h03107; // R-type: slt

        inst_mem[5]  = 20'h1508A; // I-type: addi   0001 010 100 001 000 1010
        inst_mem[6]  = 20'h3508B; // I-type: andi   0011 010 100 001 000 1011

        inst_mem[8]  = 20'h91004; // I-type: lw     1001 000 100 000 000 0100
        inst_mem[7]  = 20'hA1C04; // I-type: sw     1010 000 111 000 000 0100

        inst_mem[11]  = 20'hC200D; // I-type: j     1100 001 000 000 000 1101
        inst_mem[10] = 20'hB2111; // I-type: beq    1011 001 000 010 001 0001

        inst_mem[9] = 20'hD3005; // I-type: swi     1101 001 100 000 000 0101
        inst_mem[13] = 20'hE1014; // I-type: jmn    1110 000 100 000 001 0100
        inst_mem[15] = 20'hF0C0A; // I-type: pmc    1111 000 011 000 000 1010 
    end

    always @(*) begin
            instr = inst_mem[addr];
    end
endmodule

module PcAdder (
    input [19:0] pc_in,  
    output [19:0] pc_plus4,
    output overflow
);
    wire [20:0] result_extended;

    assign result_extended = pc_in + 20'd4;  
    assign pc_plus4 = result_extended[19:0];  
    assign overflow = result_extended[20];   // overflow if the 21st bit is set
endmodule

module FetchStage (
    input clk, reset, enable, stall, flush,
    input jump_en, jmn_en, branch_en,
    input [19:0] read_data, branchAdd, jump_add,  
    output [19:0] instruction_out, pc_plus4,   
    output overflow);

    wire [19:0] pc_out, pc_next, pc_plus4_in, instruction_in;
    PcAdder Adder (pc_out, pc_plus4_in, overflow);

    
    ProgramCounter PC (clk, reset, enable, pc_next, pc_out);
   
   ProgramCounterMux Mux (jump_add, read_data, branchAdd,
        pc_plus4_in, jump_en, jmn_en, branch_en,pc_next );

   InstructionMemory IM ( pc_out[19:2], instruction_in);

    IF_ID IFD (
    clk,
    reset,
    flush,
    stall,                
    instruction_in,    
    pc_plus4_in,        
    instruction_out,    
    pc_plus4        
);

endmodule
