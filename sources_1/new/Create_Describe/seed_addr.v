`timescale 1ns / 1ps

module seed_addr(
	clk ,rst,
	cpr_end,
	cnt_seed,
	valid_rd_seed,
	addr_rd_seed,
	data_rd_seed,
	valid_addr1,
	valid_addr2,
	valid_addr3,
	valid_addr4,	
	addr_rd_sob
    );
parameter WIDE = 256,
					HIGN =256,
					CNT_DW = 16,
					LEN_MIN = 4,
					LEN_MAX = 8,
					NUM_SUBIN = 249;	
input clk, rst;
input cpr_end;
input [8:0] cnt_seed;
output reg valid_rd_seed;
output reg [8:0] addr_rd_seed;
input [CNT_DW-1:0] data_rd_seed;
output reg valid_addr1;
output reg valid_addr2;
output reg valid_addr3;
output reg valid_addr4;
output reg [CNT_DW-1:0] addr_rd_sob;
reg signed [7:0] cnt_w, cnt_h;
wire signed [7:0] cnt_w_n, cnt_h_n;
reg [15:0] cnt_subin;	
reg [7:0] cnt_len;
wire [7:0] cnt_len2_p, cnt_len2_n, cnt_len3_p, cnt_len3_n, cnt_len4_p, cnt_len4_n;
wire [7:0] cnt_len2, cnt_len3, cnt_len4;	
reg valid_seed;
reg valid_addr1_reg;			
reg valid_addr2_reg;		
reg valid_addr3_reg;
reg valid_addr4_reg;

always @(posedge clk or negedge rst)
	if(!rst | !valid_rd_seed)		
		begin
		cnt_subin<=16'b0;
		addr_rd_seed<=9'b0;
		end
	else if(cnt_subin==NUM_SUBIN+1&&addr_rd_seed==(cnt_seed-1))	
		begin
		cnt_subin<=16'b0;
		addr_rd_seed<=9'b0;
		end
	else if(cnt_subin==NUM_SUBIN+1)
		begin
		cnt_subin<=16'b0;
		addr_rd_seed<=addr_rd_seed+1'd1;
		end
	else
		begin
		cnt_subin<=cnt_subin+1'd1;
		addr_rd_seed<=addr_rd_seed;
		end	
always @(posedge clk or negedge rst)
	if(!rst)
		valid_rd_seed<=1'b0;
	else if(cnt_subin==NUM_SUBIN+1&&addr_rd_seed==(cnt_seed-1))
		valid_rd_seed<=1'b0;
	else if(cpr_end)
		valid_rd_seed<=1'b1;	
	else
		valid_rd_seed<=valid_rd_seed;
always @(posedge clk or negedge rst)
	if(!rst)		
		valid_seed<=1'b0;
	else if(cnt_subin==0)
		valid_seed<=1'b0;
	else
		valid_seed<=valid_rd_seed;

always @(posedge clk or negedge rst)
	if(!rst | !valid_seed)
		begin	
		valid_addr1<=1'b0;
		valid_addr2<=1'b0;
		valid_addr3<=1'b0;
		valid_addr4<=1'b0;
		end
	else
		begin
		valid_addr1<=valid_seed;
		valid_addr2<=((cnt_w<=cnt_len2 || cnt_w_n<=cnt_len2)&&(cnt_h<=LEN_MAX-2 && cnt_h_n<=LEN_MAX-2))?valid_seed:1'b0;
		valid_addr3<=((cnt_w<=cnt_len3 || cnt_w_n<=cnt_len3)&&(cnt_h<=LEN_MAX-8 && cnt_h_n<=LEN_MAX-8))?valid_seed:1'b0;
		valid_addr4<=((cnt_w<=cnt_len4 || cnt_w_n<=cnt_len4)&&(cnt_h<=LEN_MAX-14 && cnt_h_n<=LEN_MAX-14))?valid_seed:1'b0;		
		end
assign cnt_len2_p = (cnt_h-(LEN_MIN-1)>0)?3*(LEN_MIN-1)-cnt_h:LEN_MAX-2;
assign cnt_len2_n = (cnt_h_n-(LEN_MIN-1)>0)?3*(LEN_MIN-1)-cnt_h_n:LEN_MAX-2;
assign cnt_len2 = (cnt_len2_p>cnt_len2_n)?cnt_len2_n:cnt_len2_p;
assign cnt_len3_p = (cnt_h-(LEN_MIN-4)>0)?3*(LEN_MIN-4)-cnt_h:LEN_MAX-8;
assign cnt_len3_n = (cnt_h_n-(LEN_MIN-4)>0)?3*(LEN_MIN-4)-cnt_h_n:LEN_MAX-8;
assign cnt_len3 = (cnt_len3_p>cnt_len3_n)?cnt_len3_n:cnt_len3_p;
assign cnt_len4_p = (cnt_h-(LEN_MIN-7)>0)?3*(LEN_MIN-7)-cnt_h:LEN_MAX-14;
assign cnt_len4_n = (cnt_h_n-(LEN_MIN-7)>0)?3*(LEN_MIN-7)-cnt_h_n:LEN_MAX-14;
assign cnt_len4 = (cnt_len4_p>cnt_len4_n)?cnt_len4_n:cnt_len4_p;
assign cnt_w_n = ~cnt_w+1;
assign cnt_h_n = ~cnt_h+1;
always @(posedge clk or negedge rst)
	if(!rst | !valid_seed)
		begin
		cnt_w<=LEN_MIN;
		cnt_h<=LEN_MAX;
		cnt_len<=LEN_MIN;
		end	
	else if(cnt_h>(LEN_MAX-LEN_MIN)&&cnt_len==cnt_w_n)
		begin
		cnt_w<=cnt_len+1;
		cnt_h<=cnt_h-1;
		cnt_len<=cnt_len+1;
		end		
	else if(cnt_h_n>(LEN_MAX-LEN_MIN-1)&&cnt_len==cnt_w_n)
		begin
		cnt_w<=cnt_len-1;
		cnt_h<=cnt_h-1;
		cnt_len<=cnt_len-1;
		end
	else if(cnt_len==cnt_w_n)
		begin
		cnt_w<=cnt_len;
		cnt_h<=cnt_h-1;
		cnt_len<=cnt_len;
		end	
	else 
		begin
		cnt_w<=cnt_w-1;
		cnt_h<=cnt_h;
		cnt_len<=cnt_len;
		end	
always @(posedge clk or negedge rst)
	if(!rst | !valid_seed)		
		addr_rd_sob<={CNT_DW{1'b0}};
	else if(cnt_h>0&&cnt_w>0)
		addr_rd_sob<=data_rd_seed+WIDE*cnt_h+cnt_w;
	else if(cnt_h>0&&cnt_w<=0)
		addr_rd_sob<=data_rd_seed+WIDE*cnt_h-cnt_w_n;
	else if(cnt_h<=0&&cnt_w>0)
		addr_rd_sob<=data_rd_seed-WIDE*cnt_h_n+cnt_w;
	else
		addr_rd_sob<=data_rd_seed-WIDE*cnt_h_n-cnt_w_n;

endmodule
