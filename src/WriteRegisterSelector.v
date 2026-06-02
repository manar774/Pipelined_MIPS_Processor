module WriteRegisterSelector (
    input [2:0] rt,     // instruction[12:10]
    input [2:0] rd,
    input [2:0] rs,     // instruction[9:7]
    input RegDst,       // 1 = use rd (R-type), 0 = use rt (I-type)
    input swi_en,      
    output [2:0] write_reg
);
    assign write_reg = swi_en ? rs :
                       RegDst  ? rd :
                                 rt;
endmodule
