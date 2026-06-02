module dataMemory(
input  memWrite, memRead, clk,
input [19:0] r, writeData, w,   
output reg [19:0] readData 
);
reg [19:0] mem [0:128];

initial begin
	mem[20] = 20'h0003F;
	mem[3] = 20'h00000;
end
//sequential
always @(posedge clk)
begin
	if (memWrite)
	mem[w] <= writeData;
end  

always @(*)
begin
	if(memRead)
	readData =  mem[r];
	else
	readData = 0;
end

endmodule
