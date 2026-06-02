module jump(input[12:0] jump, input[4:0] pc4, output [19:0] out);
wire [14:0] w ;
assign w = jump << 2;
assign out = {pc4 , w};
endmodule

