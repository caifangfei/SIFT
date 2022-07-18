`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/04 14:53:42
// Design Name: 
// Module Name: Cordic_post
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


module Cordic_post(
     rst, clk,
     in_x, in_z,
     in_valid,
     inf,
     out_x, out_z,
     out_valid
    );
    parameter    PIPELINE = 15,//Number of iterations
                            NORM = 20,
                            DW = 16,//normalized bit width
                            SUB = NORM - DW;//NORM-16    
   parameter    NUM_90 = 20'h40000, 
                          NUM_180 = 20'h80000, 
                          NUM_360=20'h0;                      
   input rst, clk;
   input signed [NORM-1:0] in_x, in_z;
   input in_valid;
   input [2:0] inf;
   output reg signed [NORM-1:0] out_x;
   output reg signed [NORM-1:0] out_z;
   output reg out_valid;
   
   reg [2:0] inf_r[0:PIPELINE-1];
   wire signed [NORM-1:0] in_x1, in_x2, in_x3, in_x4;
   reg signed [NORM-1:0] out_x_r;
   wire signed [NORM-1:0] in_z1, in_z2, in_z3;
   
   assign in_x1 = (in_x[NORM-1]==0)?({1'b0,{in_x[NORM-1:1]}}+{3'b0,{in_x[NORM-1:3]}}):({1'b1,{in_x[NORM-1:1]}}+{3'b1,{in_x[NORM-1:3]}});
   assign in_x2 = (in_x[NORM-1]==0)?({6'b0,{in_x[NORM-1:6]}}+{9'b0,{in_x[NORM-1:9]}}):({6'b1,{in_x[NORM-1:6]}}+{9'b1,{in_x[NORM-1:9]}}); 
   assign in_x3 = in_x1-in_x2;
   assign in_x4 = (in_x3[NORM-1]==0)?{12'b0,{in_x3[NORM-1:12]}}:{12'b1,{in_x3[NORM-1:12]}};
   assign in_z1 = (inf_r[PIPELINE-1][0])?(NUM_90-in_z):in_z;             
   assign in_z2 = (inf_r[PIPELINE-1][2])?(NUM_180-in_z1):in_z1; 
   assign in_z3 = (inf_r[PIPELINE-1][1])?(NUM_360-in_z2):in_z2;  
   
   always @(posedge clk or negedge rst)
      if(!rst | !in_valid)
         begin
         out_x<=0; 
		 out_z<=0;  
		 out_valid<=0;        
         end     
      else
         begin
		 out_x<=(in_x3-in_x4); 
         out_z<=in_z3;  
         out_valid<=in_valid; 
         end
   
   generate
   genvar i;
   	  for(i=0;i<PIPELINE;i=i+1)  
   	  	  begin
   	  	  always @(posedge clk or negedge rst)  
			  if(!rst)   
				  inf_r[i]<=0;  
			  else if(i==0)
				  inf_r[i]<=inf;   
			  else
			  	  inf_r[i]<=inf_r[i-1];   
		  end
	endgenerate
//   integer i;    
//   always @(posedge clk or negedge rst)  
//       if(!rst)   
//      	  inf_r[0]<=0;  
//      else 
//      	  inf_r[0]<=inf; 
//   always @(posedge clk or negedge rst)
//       for(i=1;i<=PIPELINE;i=i+1)
//       if(!rst)   
//      	  inf_r[i]<=0;  
//       else
//          inf_r[i+1]<=inf_r[i];
         
      endmodule
