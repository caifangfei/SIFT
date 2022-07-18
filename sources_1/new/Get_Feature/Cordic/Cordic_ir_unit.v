`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/03 16:36:57
// Design Name: 
// Module Name: Cordic_ir_unit
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


module Cordic_ir_unit(
    rst, clk,
    in_x, in_y, in_z,
    in_valid,
    out_x, out_y, out_z,
    out_valid
    );
    parameter PIPELINE = 15,//Number of iterations
                         PIPENOW=1,
                         NORM = 20,
                         DW = 16,//normalized bit width
                         SUB = NORM - DW;//NORM-16
   input clk, rst;
   input signed [NORM-1:0] in_z;
   input signed [NORM-1:0] in_x, in_y;
   input in_valid;
   output reg signed [NORM-1:0] out_x, out_y, out_z;
   output reg out_valid;
   reg signed [NORM-1:0] disp_x, disp_y, disp_z;
   
   always @(*)
 	   if(!rst)
 	   	    disp_x = {NORM{1'b0}};
 	   else if(in_x[NORM-1])
 	   	    disp_x = {{PIPENOW{1'b1}},in_x[NORM-1:PIPENOW]};
 	   else
 	   	    disp_x = {{PIPENOW{1'b0}},in_x[NORM-1:PIPENOW]};
   always @(*)
 	   if(!rst)
 	   	    disp_y = {NORM{1'b0}};
 	   else if(in_y[NORM-1])
 	   	    disp_y = {{PIPENOW{1'b1}},in_y[NORM-1:PIPENOW]};
 	   else
 	   	    disp_y = {{PIPENOW{1'b0}},in_y[NORM-1:PIPENOW]};
   always @(*)
 	   if(!rst)
 	   	    disp_z = {NORM{1'b0}};
 	   else if(in_y||in_x)
 	   	    disp_z = z_atan(PIPENOW);
 	   else
 	   	    disp_z = {NORM{1'b0}};
 	   	     	   	     	   	    
   function [NORM-1:0] z_atan;
   input [3:0] i;
   begin
      case(i)
      0: z_atan=20'h20000;
      1: z_atan=20'h12e40;
      2: z_atan=20'h9fb4;
      3: z_atan=20'h5111;
      4: z_atan=20'h28b1;
      5: z_atan=20'h145d;
      6: z_atan=20'ha2f;
      7: z_atan=20'h518;
      8: z_atan=20'h28c;
      9: z_atan=20'h146;
      10: z_atan=20'ha3;
      11: z_atan=20'h51;
      12: z_atan=20'h29;
      13: z_atan=20'h14;
      14: z_atan=20'ha;
      15: z_atan=20'h5;
      16: z_atan=20'h3;
      17: z_atan=20'h1;
      default:z_atan=0;
      endcase
   end
   endfunction
 
 always @(posedge clk or negedge rst)
    if(!rst)
         begin
         out_x<={NORM{1'b0}};
         out_y<={NORM{1'b0}};
         out_z<={NORM{1'b0}};
         out_valid<=1'b0;
         end
     else if(in_y[NORM-1])
         begin
         out_x<=(in_x-disp_y);
         out_y<=(in_y+disp_x);
         out_z<=(in_z-disp_z);
         out_valid<=in_valid;
         end
     else
         begin
         out_x<=(in_x+disp_y);
         out_y<=(in_y-disp_x);
         out_z<=(in_z+disp_z);
         out_valid<=in_valid;
         end     
      
endmodule
