`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/06 08:32:59
// Design Name: 
// Module Name: Cordic_top
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


module Cordic_top(
   rst, clk,
   in_x, in_y, in_z,
   in_valid,
   out_x, out_z,
   out_valid
    );
    parameter DW = 16,
                         NORM = 20;
    input clk, rst;
    input signed [DW-1:0] in_x, in_y;
    input signed [NORM-1:0] in_z;
    input in_valid;
    output [DW-1:0] out_x;
    output [NORM-1:0] out_z;
    output out_valid;
    wire pre_out_valid;
    wire [DW-1:0] pre_out_x, pre_out_y;
    wire [NORM-1:0] core_out_x, core_out_z;
    wire [NORM-1:0] post_out_x, post_out_z;
    wire core_out_valid;
    wire [2:0] inf;
	 
	defparam pre.DW = DW;
	defparam core.DW = DW; 
	defparam post.DW = DW;  			  			  			  			  			        
		   Coridc_pre pre(
		    .rst(rst), 
		    .clk(clk),
		    .in_valid(in_valid),
		    .in_x(in_x), 
		    .in_y(in_y),
		    .out_x(pre_out_x), 
		    .out_y(pre_out_y),
		    .inf(inf),
		    .out_valid(pre_out_valid)
		     );   

		    Cordic_core core(
		         .rst(rst),
		         .clk(clk),
		         .in_x(pre_out_x), 
		         .in_y(pre_out_y), 
		         .in_z(in_z),
		         .in_valid(pre_out_valid),
		         .out_x(core_out_x),
		         .out_z(core_out_z),
		         .out_valid(core_out_valid)
		         );
		         
		 Cordic_post post(
				  .rst(rst), 
				  .clk(clk),
				  .in_x(core_out_x), 
				  .in_z(core_out_z),
				  .in_valid(core_out_valid),
				  .inf(inf),
				  .out_x(post_out_x), 
				  .out_z(post_out_z),
				  .out_valid(out_valid)
				 );      
		 assign out_z = post_out_z;
		 assign out_x = post_out_x[NORM-1:NORM-DW];
endmodule
