`timescale 1ns / 1ps

module rotate(
	clk, rst,
	valid_sort,
	data_sort,
	dir,
	dir_add,
	valid_one,
	dir_one
    );
parameter CNT_DW = 16,
					DW = 8;
input clk, rst;
input valid_sort;
input [3:0] data_sort;
input [16*CNT_DW-1:0] dir;
input [CNT_DW-1:0] dir_add;
output reg valid_one;
output reg [16*DW-1:0] dir_one;
wire [8*CNT_DW-1:0] dir1, dir2;
reg [CNT_DW-1:0]dir_part[0:15];
reg [CNT_DW+DW-1:0] dir_rot[0:15];
reg valid_part, valid_rot;
reg valid_cnt_dividend, valid_dividend;
reg [3:0] cnt_dividend;
reg [CNT_DW+DW-1:0] data_dividend;
wire valid_div;
reg [3:0] cnt_div;
wire [DW-1:0] data_div;
reg [DW-1:0] dir_div[0:15];
wire [39:0] m_axis_dout_tdata;
reg en_one;

assign dir1 = dir[16*CNT_DW-1:8*CNT_DW];
assign dir2 = dir[8*CNT_DW-1:0]; 
always@(posedge clk or negedge rst)
	if(!rst)
		begin
		valid_cnt_dividend<=1'b0;
		cnt_dividend<=4'd0;
		end
	else if(valid_rot)
		begin
		valid_cnt_dividend<=1'b1;
		cnt_dividend<=4'd0;
		end
	else if(valid_cnt_dividend&&cnt_dividend==15)
		begin
		valid_cnt_dividend<=1'b0;
		cnt_dividend<=cnt_dividend;
		end	
	else if(valid_cnt_dividend)
		begin
		valid_cnt_dividend<=1'b1;
		cnt_dividend<=cnt_dividend+1;
		end
	else 
		begin
		valid_cnt_dividend<=1'b0;
		cnt_dividend<=cnt_dividend;
		end
always@(posedge clk or negedge rst)
	if(!rst)
		begin
		valid_dividend<=1'b0;
		data_dividend<={CNT_DW+DW{1'b0}};
		end
	else if(valid_cnt_dividend)	
		begin
		valid_dividend<=1'b1;
		data_dividend<=dir_rot[cnt_dividend];
		end
	else
		begin
		valid_dividend<=1'b0;
		data_dividend<=data_dividend;
		end
always@(posedge clk or negedge rst)
	if(!rst)
		cnt_div<=4'd0;
	else if(valid_div)
		cnt_div<=cnt_div+1;
	else
		cnt_div<=cnt_div;
always@(posedge clk or negedge rst)
	if(!rst)
		en_one<=1'b0;
	else if(cnt_div==15)
		en_one<=1'b1;
	else
		en_one<=1'b0;					
always@(posedge clk or negedge rst)
	if(!rst)
		begin
		valid_part<=1'b0;
		valid_rot<=1'b0;
		valid_one<=1'b0;
		end
	else
		begin
		valid_part<=valid_sort;
		valid_rot<=valid_part;
		valid_one<=en_one;
		end
		
generate
genvar i;
	for(i=0;i<16;i=i+1)
		begin
			begin
			if(i<8)
			always@(posedge clk or negedge rst)
					if(!rst)
						dir_part[i]<={CNT_DW{1'b0}};
					else if(valid_sort)
						dir_part[i]<=dir1[(i+1)*CNT_DW-1:i*CNT_DW];
					else
						dir_part[i]<=	dir_part[i];	
			else
			always@(posedge clk or negedge rst)
					if(!rst)
						dir_part[i]<={CNT_DW{1'b0}};
					else if(valid_sort)
						dir_part[i]<=dir2[((i-8)+1)*CNT_DW-1:(i-8)*CNT_DW];
					else
						dir_part[i]<=	dir_part[i];	
			end			
		always@(posedge clk or negedge rst)
			if(!rst)
				dir_rot[i]<=0;
			else
				dir_rot[i]<=((i+data_sort)>15)?{dir_part[i+data_sort-16], 8'b0}:{dir_part[i+data_sort], 8'b0};
		end			 
endgenerate				
		
Div div (
  .aclk(clk),                                      // input wire aclk
  .s_axis_divisor_tvalid(valid_dividend),    // input wire s_axis_divisor_tvalid
  .s_axis_divisor_tdata(dir_add),      // input wire [15 : 0] s_axis_divisor_tdata
  .s_axis_dividend_tvalid(valid_dividend),  // input wire s_axis_dividend_tvalid
  .s_axis_dividend_tdata(data_dividend),    // input wire [23 : 0] s_axis_dividend_tdata
  .m_axis_dout_tvalid(valid_div),          // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata(m_axis_dout_tdata)            // output wire [39 : 0] m_axis_dout_tdata
);		
assign data_div = m_axis_dout_tdata[23:16];
always@(posedge clk or negedge rst) 
	if(!rst)
		dir_div[cnt_div]<={DW{1'b0}};		
	 else if(valid_div)
		dir_div[cnt_div]<=data_div;
	else
		dir_div[cnt_div]<=dir_div[cnt_div];
generate
genvar j;
	for(j=0;j<16;j=j+1)
		begin	 	
		always@(posedge clk or negedge rst) 
			if(!rst)
		 		dir_one[(j+1)*DW-1:j*DW]<={DW{1'b0}};
		 	else if(en_one)
		 		dir_one[(j+1)*DW-1:j*DW]<=dir_div[j];
		 	else
		 		dir_one[(j+1)*DW-1:j*DW]<=dir_one[(j+1)*DW-1:j*DW];
		 end
endgenerate


endmodule
