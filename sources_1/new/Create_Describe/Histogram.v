`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/30 19:51:27
// Design Name: 
// Module Name: Histogram
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


module Histogram(
	clk, rst,
	rst_hist,
	valid_rd,
	data_rd,
	valid_hist,
	dir_add,
	dir_hist		
    );
parameter DW = 8,
					CNT_DW = 16;
input clk,rst;
input rst_hist;
input valid_rd;
input [DW+4-1:0]	data_rd;
output reg valid_hist;
output reg [CNT_DW-1:0] dir_add;
output reg [16*CNT_DW-1:0] dir_hist;	
reg [CNT_DW-1:0] dir[0:15];
reg [CNT_DW-1:0] dir_add_reg;      
always@(posedge clk or negedge rst)
	if(!rst | rst_hist)
		begin
		dir[0]<={CNT_DW{1'b0}};            
		dir[1]<={CNT_DW{1'b0}};            
		dir[2]<={CNT_DW{1'b0}};            
		dir[3]<={CNT_DW{1'b0}};            
		dir[4]<={CNT_DW{1'b0}};            
		dir[5]<={CNT_DW{1'b0}};            
		dir[6]<={CNT_DW{1'b0}};            
		dir[7]<={CNT_DW{1'b0}};            
		dir[8]<={CNT_DW{1'b0}};            
		dir[9]<={CNT_DW{1'b0}};            
		dir[10]<={CNT_DW{1'b0}};          
		dir[11]<={CNT_DW{1'b0}};          
		dir[12]<={CNT_DW{1'b0}};          
		dir[13]<={CNT_DW{1'b0}};          
		dir[14]<={CNT_DW{1'b0}};          
		dir[15]<={CNT_DW{1'b0}};  
		dir_add_reg<={CNT_DW{1'b0}};    
		end
	else if(valid_rd)
		begin
		dir_add_reg<=dir_add_reg+data_rd[DW+4-1:4];
		case(data_rd[3:0])
		0:dir[0]<=dir[0]+data_rd[DW+4-1:4];
		1:dir[1]<=dir[1]+data_rd[DW+4-1:4];
		2:dir[2]<=dir[2]+data_rd[DW+4-1:4];
		3:dir[3]<=dir[3]+data_rd[DW+4-1:4];
		4:dir[4]<=dir[4]+data_rd[DW+4-1:4];
		5:dir[5]<=dir[5]+data_rd[DW+4-1:4];
		6:dir[6]<=dir[6]+data_rd[DW+4-1:4];
		7:dir[7]<=dir[7]+data_rd[DW+4-1:4];
		8:dir[8]<=dir[8]+data_rd[DW+4-1:4];
		9:dir[9]<=dir[9]+data_rd[DW+4-1:4];
		10:dir[10]<=dir[10]+data_rd[DW+4-1:4];
		11:dir[11]<=dir[11]+data_rd[DW+4-1:4];
		12:dir[12]<=dir[12]+data_rd[DW+4-1:4];
		13:dir[13]<=dir[13]+data_rd[DW+4-1:4];
		14:dir[14]<=dir[14]+data_rd[DW+4-1:4];
		15:dir[15]<=dir[15]+data_rd[DW+4-1:4];
		endcase
		end

always@(posedge clk or negedge rst)
	if(!rst)
		begin
		valid_hist<=1'b0;
		dir_add<={CNT_DW{1'b0}};
		end
	else if(rst_hist)
		begin
		valid_hist<=1'b1;
		dir_add<=dir_add_reg;
		end
	else
		begin
		valid_hist<=1'b0 ;
		dir_add<=dir_add;
		end	
generate
genvar i;
for(i=0;i<16;i=i+1)
	begin
	always@(posedge clk or negedge rst)
		if(!rst)
			dir_hist[(i+1)*CNT_DW-1:i*CNT_DW]<={CNT_DW{1'b0}};
		else if(rst_hist)
			dir_hist[(i+1)*CNT_DW-1:i*CNT_DW]<=dir[i];
		else
			dir_hist[(i+1)*CNT_DW-1:i*CNT_DW]<=dir_hist[(i+1)*CNT_DW-1:i*CNT_DW];
	end
endgenerate		
//reg [CNT_DW-1:0] add[0:13], add;
//generate
//genvar i;
//for(i=0;i<8;i=i+1)
//	begin
//	always@(*)
//		if(!rst)
//			add[i]=0;
//		else 
//			add[i]=dir[2*i]+dir[2*i+1];
//	end
//endgenerate
//generate
//genvar j;
//for(j=8;j<12;j=j+1)
//	begin
//	always@(*)
//		if(!rst)
//			add[j]=0;
//		else 
//			add[j]=add[2*(j-8)]+add[2*(j-8)+1];
//	end
//endgenerate
//	always@(*)
//	if(!rst)
//		begin
//		add[12]=0;
//		add[13]=0;
//		add=0;
//		end
//	else 
//		begin
//		add[12]=add[8]+add[9];
//		add[13]=add[10]+add[11];
//		add=add[12]+add[13];
//		end
endmodule
