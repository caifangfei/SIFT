`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/06/24 15:30:37
// Design Name: 
// Module Name: compare_one
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


module compare_one(
	clk, rst,
	valid_dog,
    data_dog,
	valid_cal0,
	valid_row2,
	data_row0, data_row1, data_row2, data_row3, data_row4, data_row5,
	data_cal0, data_cal1
    );
parameter   WIDE = 256,
					  HIGN = 256,
					  DW = 8,
					  CNT_DW = 16;   
  input clk, rst;	
  input valid_dog;
  input signed [DW-1:0] data_dog;	
  output valid_cal0;
  output valid_row2;
  output signed [DW-1:0] data_row0, data_row1, data_row2, data_row3, data_row4, data_row5;
  output signed [DW-1:0] data_cal0, data_cal1;
  reg valid_row[0:5];
  reg signed [DW-1:0] data_row[0:5];
  wire valid_cal[0:1];
  wire signed [DW-1:0] data_cal[0:1];
 
  assign data_row0 = data_row[0];
  assign data_row1 = data_row[1];
  assign data_row2 = data_row[2];
  assign data_row3 = data_row[3];
  assign data_row4 = data_row[4];
  assign data_row5 = data_row[5];
  assign data_cal0 = data_cal[0];
  assign data_cal1 = data_cal[1];
  assign valid_cal0 = valid_cal[0];
  assign valid_row2 = valid_row[2];
   Line_buff buff1(
	 .clk(clk) ,
	 .rst(rst),
	 .valid_in(valid_dog),
	 .data_in(data_dog),
	 .valid_out(valid_cal[0]),
	 .data_out(data_cal[0])
				 );
	defparam buff1.NUM = WIDE;			
	defparam buff1.DW = DW;	
  Line_buff buff2(
	 .clk(clk) ,
	 .rst(rst),
	 .valid_in(valid_cal[0]),
	 .data_in(data_cal[0]),
	 .valid_out(valid_cal[1]),
	 .data_out(data_cal[1])
				 );
	defparam buff2.NUM = WIDE;			
	defparam buff2.DW = DW;	
	       
generate
genvar j;
for(j=0;j<6;j=j+1)
	begin
	  always@(posedge clk or negedge rst)
		if(!rst)
			begin
			data_row[j]<=0;
			valid_row[j]<=0;
			end
		else if(j==0)
			begin
			data_row[j]<=data_dog;
			valid_row[j]<=valid_dog;
			end		
		else if(j==2)
			begin
			data_row[j]<=data_cal[0];
			valid_row[j]<=valid_cal[0];
			end	
		else if(j==4)
			begin
			data_row[j]<=data_cal[1];
			valid_row[j]<=valid_cal[1];
			end			
		else 
			begin
			data_row[j]<=data_row[j-1];
			valid_row[j]<=valid_row[j-1];
			end									
	end
endgenerate
	
endmodule
