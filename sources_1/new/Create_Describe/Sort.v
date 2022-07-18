`timescale 1ns / 1ps

module Sort(
	clk, rst,
	valid_in,
	dir_hist,
	valid_sort,
	data_sort			
    );
parameter CNT_DW = 16;
input clk,rst;
input valid_in;
input [16*CNT_DW-1:0] dir_hist;	
output reg valid_sort;
output reg [3:0] data_sort;
reg [CNT_DW+4-1:0] sort1[0:7], sort2[0:3], sort3[0:1];
reg [2:0] valid_sort_reg;
//generate
//genvar i, j;
//for(i=0;i<16;i=i+1)
//  	begin	 
//	for(j=0;j<16;j=j+1)
//		begin   
//		 always @(posedge clk or negedge rst)
//			if(!rst | !valid_in)
//				max[i][j]<=0;
//			else if(i<j&&(dir[i]>dir[j]))
//				max[i][j]<=1;
//			else if(i<j&&(dir[i]<=dir[j]))
//				max[i][j]<=0;
//			else if(i==j)
//				max[i][j]<=0;
//			else if(i>j&&(dir[i]>=dir[j]))
//				max[i][j]<=1;
//			else
//				max[i][j]<=0;
//		end
//	end
//endgenerate

always@(posedge clk or negedge rst)
	if(!rst)
		begin
		sort1[0]<={CNT_DW+4{1'b0}};
		sort1[1]<={CNT_DW+4{1'b0}};
		sort1[2]<={CNT_DW+4{1'b0}};
		sort1[3]<={CNT_DW+4{1'b0}};
		sort1[4]<={CNT_DW+4{1'b0}};
		sort1[5]<={CNT_DW+4{1'b0}};
		sort1[6]<={CNT_DW+4{1'b0}};
		sort1[7]<={CNT_DW+4{1'b0}};		
		end
	else if( valid_in)
		begin
		sort1[0][CNT_DW+3:4]<=(dir_hist[CNT_DW-1:0]>dir_hist[2*CNT_DW-1:CNT_DW])?dir_hist[CNT_DW-1:0]:dir_hist[2*CNT_DW-1:CNT_DW];
		sort1[0][3:0]<=(dir_hist[CNT_DW-1:0]>dir_hist[2*CNT_DW-1:CNT_DW])?4'd0:4'd1;
		sort1[1][CNT_DW+3:4]<=(dir_hist[3*CNT_DW-1:2*CNT_DW]>dir_hist[4*CNT_DW-1:3*CNT_DW])?dir_hist[3*CNT_DW-1:2*CNT_DW]:dir_hist[4*CNT_DW-1:3*CNT_DW];
		sort1[1][3:0]<=(dir_hist[3*CNT_DW-1:2*CNT_DW]>dir_hist[4*CNT_DW-1:3*CNT_DW])?4'd2:4'd3;
		sort1[2][CNT_DW+3:4]<=(dir_hist[5*CNT_DW-1:4*CNT_DW]>dir_hist[6*CNT_DW-1:5*CNT_DW])?dir_hist[5*CNT_DW-1:4*CNT_DW]:dir_hist[6*CNT_DW-1:5*CNT_DW];
		sort1[2][3:0]<=(dir_hist[5*CNT_DW-1:4*CNT_DW]>dir_hist[6*CNT_DW-1:5*CNT_DW])?4'd4:4'd5;
		sort1[3][CNT_DW+3:4]<=(dir_hist[7*CNT_DW-1:6*CNT_DW]>dir_hist[8*CNT_DW-1:7*CNT_DW])?dir_hist[7*CNT_DW-1:6*CNT_DW]:dir_hist[8*CNT_DW-1:7*CNT_DW];
		sort1[3][3:0]<=(dir_hist[7*CNT_DW-1:6*CNT_DW]>dir_hist[8*CNT_DW-1:7*CNT_DW])?4'd6:4'd7;
		sort1[4][CNT_DW+3:4]<=(dir_hist[9*CNT_DW-1:8*CNT_DW]>dir_hist[10*CNT_DW-1:9*CNT_DW])?dir_hist[9*CNT_DW-1:8*CNT_DW]:dir_hist[10*CNT_DW-1:9*CNT_DW];
		sort1[4][3:0]<=(dir_hist[9*CNT_DW-1:8*CNT_DW]>dir_hist[10*CNT_DW-1:9*CNT_DW])?4'd8:4'd9;
		sort1[5][CNT_DW+3:4]<=(dir_hist[11*CNT_DW-1:10*CNT_DW]>dir_hist[12*CNT_DW-1:11*CNT_DW])?dir_hist[11*CNT_DW-1:10*CNT_DW]:dir_hist[12*CNT_DW-1:11*CNT_DW];
		sort1[5][3:0]<=(dir_hist[11*CNT_DW-1:10*CNT_DW]>dir_hist[12*CNT_DW-1:11*CNT_DW])?4'd10:4'd11;
		sort1[6][CNT_DW+3:4]<=(dir_hist[13*CNT_DW-1:12*CNT_DW]>dir_hist[14*CNT_DW-1:13*CNT_DW])?dir_hist[13*CNT_DW-1:12*CNT_DW]:dir_hist[14*CNT_DW-1:13*CNT_DW];
		sort1[6][3:0]<=(dir_hist[13*CNT_DW-1:12*CNT_DW]>dir_hist[14*CNT_DW-1:13*CNT_DW])?4'd12:4'd13;
		sort1[7][CNT_DW+3:4]<=(dir_hist[15*CNT_DW-1:14*CNT_DW]>dir_hist[16*CNT_DW-1:15*CNT_DW])?dir_hist[15*CNT_DW-1:14*CNT_DW]:dir_hist[16*CNT_DW-1:15*CNT_DW];
		sort1[7][3:0]<=(dir_hist[15*CNT_DW-1:14*CNT_DW]>dir_hist[16*CNT_DW-1:15*CNT_DW])?4'd14:4'd15;		
		end	
		
always@(posedge clk or negedge rst)
	if(!rst)
		begin
		sort2[0]<={CNT_DW+4{1'b0}};
		sort2[1]<={CNT_DW+4{1'b0}};
		sort2[2]<={CNT_DW+4{1'b0}};
		sort2[3]<={CNT_DW+4{1'b0}};	
		sort3[0]<={CNT_DW+4{1'b0}};			
		sort3[1]<={CNT_DW+4{1'b0}};
		data_sort<=4'd0;
		end
	else
		begin					
		sort2[0][CNT_DW+3:4]<=(sort1[0][CNT_DW+3:4]>sort1[1][CNT_DW+3:4])?sort1[0][CNT_DW+3:4]:sort1[1][CNT_DW+3:4];
		sort2[0][3:0]<=(sort1[0][CNT_DW+3:4]>sort1[1][CNT_DW+3:4])?sort1[0][3:0]:sort1[1][3:0];
		sort2[1][CNT_DW+3:4]<=(sort1[2][CNT_DW+3:4]>sort1[3][CNT_DW+3:4])?sort1[2][CNT_DW+3:4]:sort1[3][CNT_DW+3:4];
		sort2[1][3:0]<=(sort1[2][CNT_DW+3:4]>sort1[3][CNT_DW+3:4])?sort1[2][3:0]:sort1[3][3:0];
		sort2[2][CNT_DW+3:4]<=(sort1[4][CNT_DW+3:4]>sort1[5][CNT_DW+3:4])?sort1[4][CNT_DW+3:4]:sort1[5][CNT_DW+3:4];
		sort2[2][3:0]<=(sort1[4][CNT_DW+3:4]>sort1[5][CNT_DW+3:4])?sort1[4][3:0]:sort1[5][3:0];
		sort2[3][CNT_DW+3:4]<=(sort1[6][CNT_DW+3:4]>sort1[7][CNT_DW+3:4])?sort1[6][CNT_DW+3:4]:sort1[7][CNT_DW+3:4];	
		sort2[3][3:0]<=(sort1[6][CNT_DW+3:4]>sort1[7][CNT_DW+3:4])?sort1[6][3:0]:sort1[7][3:0];
		sort3[0][CNT_DW+3:4]<=(sort2[0][CNT_DW+3:4]>sort2[1][CNT_DW+3:4])?sort2[0][CNT_DW+3:4]:sort2[1][CNT_DW+3:4];
		sort3[0][3:0]<=(sort2[0][CNT_DW+3:4]>sort2[1][CNT_DW+3:4])?sort2[0][3:0]:sort2[1][3:0];
		sort3[1][CNT_DW+3:4]<=(sort2[2][CNT_DW+3:4]>sort2[3][CNT_DW+3:4])?sort2[2][CNT_DW+3:4]:sort2[3][CNT_DW+3:4];
		sort3[1][3:0]<=(sort2[2][CNT_DW+3:4]>sort2[3][CNT_DW+3:4])?sort2[2][3:0]:sort2[3][3:0];
		data_sort<=(sort3[0][CNT_DW+3:4]>sort3[1][CNT_DW+3:4])?sort3[0][3:0]:sort3[1][3:0];
		end		
always@(posedge clk or negedge rst)
	if(!rst)
		begin
		valid_sort_reg<=3'd0;
		valid_sort<=1'b0;
		end
	else
		begin
		valid_sort_reg<={valid_sort_reg[1:0] , valid_in};
		valid_sort<=valid_sort_reg[2];
		end
	
	endmodule		