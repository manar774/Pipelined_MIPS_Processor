module instr_mem (
    input  [18:0] address,      
    output [18:0] instr     
);

    reg [18:0] mem [0:128];  
    assign instr = mem[address];  

endmodule
