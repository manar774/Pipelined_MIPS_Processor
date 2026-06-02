module forwardingUnit(
	input [2:0] rs,
	input [2:0] rt,
	input [2:0] rdMem,
	input [2:0] rdWb,
    	input regWrite_MEM,
	input regWrite_WB,
	input regdst,
	input [2:0] rs_ID,
	input [2:0] rt_ID,
	input reset,
    	output reg forwardAlurs,
    	output reg forwardAlurt,
    	output reg forwardMemrs,
    	output reg forwardMemrt,
	output reg forwardBranchRs,
	output reg forwardBranchRt
);
always @(*) begin
    forwardAlurs      = 0;
    forwardAlurt      = 0;
    forwardMemrs      = 0;
    forwardMemrt      = 0;
    forwardBranchRs   = 0;
    forwardBranchRt   = 0;


    if (!reset) begin

        if (regWrite_MEM && rdMem != 0) begin
            if (rdMem == rs) 
                forwardAlurs = 1;
	    else
		forwardAlurs = 0;
            if (rdMem == rt)
                forwardAlurt = 1;
	    else
		forwardAlurt = 0;
        end


        if (regWrite_WB && rdWb != 0) begin
            if (rdWb == rs)
                forwardMemrs = 1;
	    else
		forwardMemrs = 0;
            if (rdWb == rt)
                forwardMemrt = 1;
	    else
		forwardMemrt = 0;
        end


        if (regWrite_MEM && rdMem != 0) begin
            if (rdMem == rs_ID)
                forwardBranchRs = 1;
	    else
		forwardBranchRs = 0;
            if (rdMem == rt_ID)
                forwardBranchRt = 1;
	    else
		forwardBranchRs = 0;
        end
    end
end

endmodule
