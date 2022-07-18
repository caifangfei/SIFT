`timescale 1ns / 1ps

module Sobel(
	clk, rst,
	valid_in,
	data_in,
	valid_sob,
	mor,
	the
    );
parameter  WIDE = 256,
					  HIGN = 256,
					  DW = 8,
					  CNT_DW = 16;
input clk, rst;
input valid_in;
input [DW-1:0] data_in;
output reg valid_sob;
output reg [DW-1:0] mor;
output reg [3:0] the;
reg valid_row[0:5];
reg [DW-1:0] data_row[0:5];
wire valid_cal[0:1];
wire [DW-1:0] data_cal[0:1];
reg [CNT_DW-1:0] cnt_w, cnt_h;
wire valid_xy;
reg valid_mor;
reg signed [DW-1:0] data_x, data_y;

Line_buff buff1(
 .clk(clk) ,
 .rst(rst),
 .valid_in(valid_in),
 .data_in(data_in),
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
				data_row[j]<={DW{1'b0}};
				valid_row[j]<=1'b0;
				end
			else if(j==0)
				begin
				data_row[j]<=data_in;
				valid_row[j]<=valid_in;
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
	
	always @(posedge clk or negedge rst)
		if(!rst | !valid_row[2])
			begin
			cnt_h<={CNT_DW{1'b0}};
			cnt_w<={CNT_DW{1'b0}};
			end
		else if(cnt_h==(HIGN-1)&&cnt_w==(WIDE-1))
			begin
			cnt_h<={CNT_DW{1'b0}};
			cnt_w<={CNT_DW{1'b0}};
			end
		else if(cnt_w==(WIDE-1))
			begin
			cnt_h<=cnt_h+1'd1;
			cnt_w<={CNT_DW{1'b0}};
			end
		else 
			begin
			cnt_h<=cnt_h;
			cnt_w<=cnt_w+1;
			end
	assign valid_xy = (valid_row[2]&&(cnt_w>0)&&(cnt_h>0)&&(cnt_w<WIDE-1)&&(cnt_h<HIGN-1))?1:0;
	always@(posedge clk or negedge rst)
		if(!rst)
			valid_mor<=1'b0;
		else
			valid_mor<=valid_row[2];
	always@(posedge clk or negedge rst)
		if(!rst)
			begin
			data_x<=0;
			data_y<=0;
			end
		else if(valid_xy)
			begin
			data_x<=data_cal[0]-data_row[3];
			data_y<=data_row[4]-data_row[0];
			end
		else
			begin
			data_x<=0;
			data_y<=0;
			end
			
	wire signed [19:0] cor_the;
	wire signed [DW-1:0] cor_mor;
	wire valid_cor;
	Cordic_top cor(
		   .rst(rst), 
		   .clk(clk),
		   .in_x(data_x), 
		   .in_y(data_y), 
		   .in_z(20'b0),
		   .in_valid(valid_mor),
		   .out_x(cor_mor), 
		   .out_z(cor_the),
		   .out_valid(valid_cor)
			);	
	defparam cor.DW = DW;	 
	
	always@(posedge clk or negedge rst)
		if(!rst)
			begin
			mor<=20'b0;
			valid_sob<=1'b0;
			end
		else
			begin
			mor<=	cor_mor;
			valid_sob<=valid_cor;
			end
		
	always@(posedge clk or negedge rst)
		if(!rst)
			the<=4'd0;
		else if(cor_the>=20'h0&&cor_the<20'h8000)
			the<=4'd0;
		else if(cor_the>=20'h8000&&cor_the<20'h18000)
			the<=4'd1;			
		else if(cor_the>=20'h18000&&cor_the<20'h28000)
			the<=4'd2;    
		else if(cor_the>=20'h28000&&cor_the<20'h38000)	
			the<=4'd3;     
		else if(cor_the>=20'h38000&&cor_the<20'h48000)	
			the<=4'd4;     
		else if(cor_the>=20'h48000&&cor_the<20'h58000)	
			the<=4'd5;    
		else if(cor_the>=20'h58000&&cor_the<20'h68000)	
			the<=4'd6;     
		else if(cor_the>=20'h68000&&cor_the<20'h78000)	
			the<=4'd7;	
		else if(cor_the>=20'h78000&&cor_the<20'h88000)	
			the<=4'd8;     
		else if(cor_the>=20'h88000&&cor_the<20'h98000)	
			the<=4'd9;		
		else if(cor_the>=20'h98000&&cor_the<20'ha8000)	
			the<=4'd10;     
		else if(cor_the>=20'ha8000&&cor_the<20'hb8000)	
			the<=4'd11;		
		else if(cor_the>=20'hb8000&&cor_the<20'hc8000)	
			the<=4'd12;			
		else if(cor_the>=20'hc8000&&cor_the<20'hd8000)
			the<=4'd13;    
		else if(cor_the>=20'hd8000&&cor_the<20'he8000)	
			the<=4'd14;    
		else if(cor_the>=20'he8000&&cor_the<20'hf8000)	
			the<=4'd15;      
		else if(cor_the>=20'hf8000&&cor_the<=20'hfffff)	
			the<=4'd0; 			
		else
			the<=4'd0;		
																				
endmodule
