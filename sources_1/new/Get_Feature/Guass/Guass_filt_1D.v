`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/01 19:42:28
// Design Name: 
// Module Name: Guass_filt_1D
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


module Guass_filt_1D(
	clk, rst,
	valid_in,
	data_in,
	valid_1D,
	data_1D
    );
parameter  WIDE = 230,
					  HIGN = 235,
					  DW = 16,
					  CNT_DW=16,
					  KERNEL=56'h01_0D_2B_3F_2B_0D_01,
					  SUM = 177,
					  R =7;
input clk, rst;
input valid_in;
input [DW-1:0] data_in;
output reg valid_1D;
output reg [DW-1:0] data_1D;
reg [DW-1:0] data_row_r[0:R-2];
wire [8+(DW-1):0] data_row[0:R-2];
reg [R-2:0] valid_row;
reg [CNT_DW-1:0] cnt_w;		
reg [8+(DW-1):0] data_add0, data_add1, data_add2, data_add3, data_add4, data_add5, data_add;
always @(posedge clk or negedge rst)
	if(!rst | !valid_in)
		cnt_w<=0;
	else if(cnt_w==(WIDE-1))
		cnt_w<=0;
	else
		cnt_w<=cnt_w+1;
always @(posedge clk or negedge rst)
	if(!rst)
		valid_row<=0;
	else
		valid_row<={valid_row[R-3:0], valid_in};
always @(posedge clk or negedge rst)
	if(!rst)
		valid_1D<=0;
	else
		valid_1D<=valid_row[R-2];
generate
genvar i;
for(i=0;i<R-1;i=i+1)		
	begin
	if(i==0)
		begin
		always@(posedge clk or negedge rst)
			if(!rst)
				data_row_r[i]<=0;
			else
				data_row_r[i]<=data_in;
		assign data_row[i] = data_row_r[i]*KERNEL[8*(i+2)-1:8*(i+1)];
		end
	else
		begin
		always@(posedge clk or negedge rst)
			if(!rst)
				data_row_r[i]<=0;
			else
				data_row_r[i]<=data_row_r[i-1];	
		assign data_row[i] = data_row_r[i]*KERNEL[8*(i+2)-1:8*(i+1)];	
		end
	end
endgenerate
always @(posedge clk or negedge rst)
	if(!rst)
		begin
		data_add0<=0;
		data_add1<=0;
		data_add2<=0;
		data_add3<=0;
		data_add4<=0;
		data_add5<=0;
		data_add<=0;
		end
	else
		begin
		data_add0<=data_in*KERNEL[7:0];
		data_add1<=data_row[0]+data_row[1];
		data_add2<=data_row[2]+data_row[3];
		data_add3<=data_row[4]+data_row[5];
		data_add4<=data_add0+data_add1;
		data_add5<=data_add2+data_add3;
		data_add<=data_add4+data_add5;		
		end
always@(posedge clk or negedge rst)
	if(!rst)
		data_1D<=0;
	else if(valid_row[R-2]&&(cnt_w>=6&&cnt_w<=8)||(cnt_w>=3&&cnt_w<=5))
		data_1D<=data_row_r[R-2];
	else if(valid_row[R-2])
		data_1D<=data_add/SUM;
	else
		data_1D<=0;
endmodule
