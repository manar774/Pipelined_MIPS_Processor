module mux(input ctrl, input [19:0] op1, op2, output [19:0] result);
  assign result = ctrl ? op2 : op1;
endmodule
