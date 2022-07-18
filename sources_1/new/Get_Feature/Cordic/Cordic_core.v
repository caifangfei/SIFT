`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/03 20:33:48
// Design Name: 
// Module Name: Cordic_core
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Cordic_core(
    rst,clk,
    in_x, in_y, in_z,
    in_valid,
    out_x,
    out_z,
    out_valid
    );
     parameter    PIPELINE = 15,//Number of iterations
                            NORM = 20,//normalized bit width
                            DW = 16,
                            SUB = NORM - DW;//NORM-16     
     input rst, clk;
     input [DW-1:0] in_x, in_y;
     input [NORM-1:0] in_z;
     input in_valid;
     output reg signed [NORM-1:0] out_x, out_z;
     output reg out_valid;
     wire signed [NORM-1:0] in_x_r[PIPELINE:0], in_y_r[PIPELINE:0], in_z_r[PIPELINE:0];  
     wire in_valid_r[PIPELINE:1];
     wire out_valid_r;
     integer i;
     
     assign in_x_r[0] =(SUB>0)?{in_x, {SUB{1'b0}}}:in_x;    
     assign in_y_r[0] =(SUB>0)?{in_y, {SUB{1'b0}}}:in_y;
     assign in_z_r[0]=in_z; 
     assign in_x_r[1] =in_x_r[0]+in_y_r[0];    
     assign in_y_r[1] =in_y_r[0]-in_x_r[0];       
     assign in_z_r[1] = (in_y||in_x)?(in_z_r[0]+20'h20000):0;
     assign in_valid_r[1]=in_valid;
     assign out_valid_r=in_valid_r[PIPELINE];  
			  
     always@(posedge clk or negedge rst)
        if(!rst | !out_valid_r)
           begin
           out_valid<=0;
		   out_x<=20'b0;
		   out_z<=20'b0;           
           end
        else
           begin
		   out_valid<=out_valid_r;
           out_x<=in_x_r[PIPELINE];
           out_z<=in_z_r[PIPELINE];
			end       
			
        generate
        genvar n;
           begin
			   for(n=1;n<PIPELINE;n=n+1)
			   begin
			    defparam unit.DW = DW;
			    defparam unit.PIPENOW = n;
				Cordic_ir_unit unit(
				  .rst(rst), 
				  .clk(clk),
				  .in_x(in_x_r[n]), 
				  .in_y(in_y_r[n]), 
				  .in_z(in_z_r[n]),
				  .in_valid(in_valid_r[n]),
				  .out_x(in_x_r[n+1]), 
				  .out_y(in_y_r[n+1]), 
				  .out_z(in_z_r[n+1]),
				  .out_valid(in_valid_r[n+1])
					 );
			 end 
		 end  
     endgenerate                                    
endmodule
