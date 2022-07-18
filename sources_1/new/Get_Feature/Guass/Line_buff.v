`timescale 1ns / 1ps

module Line_buff(
	clk ,rst,
	valid_in,
	data_in,
	valid_out,
	data_out
    );
    parameter NUM = 160,
                        DW = 16;
    input clk, rst;
    input valid_in;
    input [DW-1:0] data_in;
    output reg valid_out;
    output reg [DW-1:0] data_out;    
    reg [DW-1:0] data_tem[0:NUM-1];       
    reg valid_tem[0:NUM-1]; 
    
    generate
    genvar i;
    for(i=0;i<NUM-1;i=i+1)
    	begin
    	always@(posedge clk or negedge rst)
    		if(!rst)
    			begin
    			valid_tem[i]<=1'b0;
    			data_tem[i]<= {DW{1'b0}};
    			end
		   else if(i==0)
    			begin
				valid_tem[i]<=valid_in;
				data_tem[i]<=data_in;
			    end	
		   else 
    			begin
				valid_tem[i]<=valid_tem[i-1];
				data_tem[i]<=data_tem[i-1];
			    end	
		end
   endgenerate
   always@(posedge clk or negedge rst)
		if(!rst)
			begin
			valid_out<=1'b0;
			data_out<={DW{1'b0}};
			end
	   else 
			begin
			valid_out<=valid_tem[NUM-2];
			data_out<=data_tem[NUM-2];
			end	
endmodule
