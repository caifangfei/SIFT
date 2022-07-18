`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/01 18:37:09
// Design Name: 
// Module Name: Guass_filt
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


module Guass_filt(
	clk, rst,
	valid_in,
	data_in,
	valid_gus,
	data_gus
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
output reg valid_gus;
output reg [DW-1:0] data_gus;
wire valid_1D;
wire [DW-1:0] data_1D;
wire [DW-1:0] data_cal_r[0:R-2];
wire [8+(DW-1):0] data_cal[0:R-2];
wire valid_cal[0:R-2];
reg [CNT_DW-1:0] cnt_w, cnt_h;		
reg [8+(DW-1):0] data_add0, data_add1, data_add2, data_add3, data_add4, data_add5, data_add;
reg [2:0] valid_gus_r;
reg [8+(DW-1):0] data_gus_r[0:2];
reg [CNT_DW-1:0] cnt_h_r[0:2];
 Guass_filt_1D 
 	#(WIDE,  HIGN, DW, CNT_DW, KERNEL, SUM, R)
 	D(
	.clk(clk), 
	.rst(rst),
	.valid_in(valid_in),
	.data_in(data_in),
	.valid_1D(valid_1D),
	.data_1D(data_1D)
    );
	
always @(posedge clk or negedge rst)
     	if(!rst | !valid_1D)
     		begin
     		cnt_h<=0;
     		cnt_w<=0;
     		end
     	else if(cnt_w==(WIDE-1)&&cnt_h==(HIGN-1))
     		begin
     		cnt_h<=0;
     		cnt_w<=0;
     		end
     	else  if(cnt_w==(WIDE-1))
     		begin
     		cnt_w<=0;
     		cnt_h<=cnt_h+1;
     		end
		else
			begin
			cnt_w<=cnt_w+1;
			cnt_h<=cnt_h;
			end

     always @(posedge clk or negedge rst)
     	if(!rst)
     		begin
     		valid_gus_r<=0;
     		valid_gus<=0;
     		end
     	else
     		begin
     		valid_gus_r<={valid_gus_r[1:0], valid_cal[2]};
     		valid_gus<=valid_gus_r[2];
     		end
	 generate
	 genvar j;
	 for(j=0;j<3;j=j+1)
	 	begin
		always @(posedge clk or negedge rst)
			if(!rst)
				begin
				cnt_h_r[j]<=0;
				data_gus_r[j]<=0;
				end
			else if(j==0)
				begin
				cnt_h_r[j]<=cnt_h;
				data_gus_r[j]<=data_cal_r[2];
				end  
			else 
				begin
				cnt_h_r[j]<=cnt_h_r[j-1];
				data_gus_r[j]<=data_gus_r[j-1];
				end  	  	
		end
	endgenerate
     generate
     genvar i;
     for(i=0;i<R-1;i=i+1)		
     	 begin
			 if(i==0)
				 begin
				   Line_buff buff1(
				  .clk(clk) ,
				  .rst(rst),
				  .valid_in(valid_1D),
				  .data_in(data_1D),
				  .valid_out(valid_cal[i]),
				  .data_out(data_cal_r[i])
							 );
					defparam buff1.NUM = WIDE;			
					defparam buff1.DW = DW;	
					assign data_cal[i] = data_cal_r[i]*KERNEL[8*(i+2)-1:8*(i+1)];
					end
			else
				 begin
				  Line_buff buff2(
				 .clk(clk) ,
				 .rst(rst),
				 .valid_in(valid_cal[i-1]),
				 .data_in(data_cal_r[i-1]),
				 .valid_out(valid_cal[i]),
				 .data_out(data_cal_r[i])
							 );
			    defparam buff2.NUM = WIDE;			
			    defparam buff2.DW = DW;	
				assign data_cal[i] = data_cal_r[i]*KERNEL[8*(i+2)-1:8*(i+1)];	
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
     		data_add0<=data_1D*KERNEL[7:0];
     		data_add1<=data_cal[0]+data_cal[1];
     		data_add2<=data_cal[2]+data_cal[3];
     		data_add3<=data_cal[4]+data_cal[5];
     		data_add4<=data_add0+data_add1;
     		data_add5<=data_add2+data_add3;
     		data_add<=data_add4+data_add5;
     		end
     always@(posedge clk or negedge rst)
     	if(!rst)
     		data_gus<=0;
    	else if(valid_gus_r[2]&&(cnt_h_r[2]>=3&&cnt_h_r[2]<=5)||(cnt_h_r[2]>=0&&cnt_h_r[2]<=2))
    		data_gus<=data_gus_r[2];
     	else if(valid_gus_r[2])
     		data_gus<=data_add/SUM;
		else
			data_gus<=0;
endmodule
