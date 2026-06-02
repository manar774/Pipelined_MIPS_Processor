module hazardUnit
(      
input forwardExrt,
input forwardExrs,
input mem2regMem,
output reg stallIF,
output reg stallID,
output reg stallIE,
output reg flushID,
output reg flushIF,
output reg flushIE,
output reg flushIMEM,
input jump,
input branch,
input pmcMem,
input jmnMem,
input reset,
output reg enable
 
);
always@(*) 
begin
	stallIF = 0;
	stallID= 0;
	stallIE= 0;
	flushID= 0;
	flushIF= 0;
	flushIE= 0;
	flushIMEM= 0;

	
	//LW
	if((forwardExrt || forwardExrs) && mem2regMem) begin
	stallID = 1;
	flushIE = 1;
	stallIF = 1;
	end	

	//jump
	if(jump)
	flushIF = 1;

	//branch
	if(branch)
	flushIF = 1;

	//PMC
	if(pmcMem) begin
	flushID = 1;
	flushIF = 1;
	flushIE = 1;
	flushIMEM = 1;
	end

	//JMN
	if(jmnMem) begin
	flushID = 1;
	flushIF = 1;
	flushIE = 1;
	flushIMEM = 1;
	end
enable = stallID;
end
endmodule
