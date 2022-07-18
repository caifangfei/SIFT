`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/03 14:14:11
// Design Name: 
// Module Name: Coridc_pre
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


module Coridc_pre(
    rst, clk,
    in_valid,
    in_x, in_y,
    out_x, out_y,
    inf,
    out_valid
    );
    parameter DW = 16;
    input rst, clk;
    input in_valid;
    input signed [DW-1:0] in_x, in_y;
    output signed [DW-1:0] out_x, out_y;
    output [2:0] inf;
    output reg out_valid;
    reg signed [DW-1:0] out_x_r, out_y_r;
    reg sign_x, sign_y;
    wire flag;
//    function signed [15:0] abs;
//       input signed [15:0] a;
//       begin
//          if(a[15])
//             abs=~a+1;
//          else
//             abs=a;
//       end
//    endfunction
    //calculate abs and sign
always @(posedge clk or negedge rst)
	if(!rst | !in_valid)
		 begin
		 sign_x<=0;
		 sign_y<=0;
		 end
	 else 
		 begin
		 sign_x<=in_x[DW-1];//1 is - , 0 is +
		 sign_y<=in_y[DW-1];
		 end
always @(posedge clk or negedge rst)
	if(!rst | !in_valid)
		out_x_r<={DW{1'B0}};
	else if(in_x[DW-1])
         out_x_r<=~in_x+1;
    else
    	 out_x_r<= in_x;
always @(posedge clk or negedge rst)
	if(!rst | !in_valid)
		out_y_r<={DW{1'B0}};
	else if(in_y[DW-1])
         out_y_r<=~in_y+1;
    else
    	 out_y_r<= in_y;    	 
		 
//get valid
    always @(posedge clk or negedge rst)
       if(!rst)   
          out_valid<=1'b0;
       else
          out_valid<=in_valid;      
//get output
    assign out_x=(out_x_r>=out_y_r)?out_x_r:out_y_r;
    assign out_y=(out_x_r>=out_y_r)?out_y_r:out_x_r;  
    assign flag= (out_x_r>=out_y_r)?0:1;        
    assign inf={sign_x,sign_y,flag};      
endmodule
