`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/27 21:58:52
// Design Name: 
// Module Name: seed_one_addr
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


module seed_one_addr(
	clk, rst,
	cpr_end,
	data_mem,
	cnt_wr,
	cnt_rd,
	valid_addr1,
	valid_addr2,
	valid_addr3,
	valid_addr4,
	data_addr
    );
parameter WIDE = 256,
					HIGN = 256,
					LEN_MAX = 8,
					LEN_MIN = 4,
					CNT_DW = 16,
					NUM_SEED = 249,
					NUM_WAIT = 2,
					DEF = 1;
input clk, rst;
input cpr_end;	
input [CNT_DW-1:0] data_mem;
input [8:0] cnt_wr;
output reg valid_addr1, valid_addr2, valid_addr3, valid_addr4;
output reg [8:0] cnt_rd;
output reg [CNT_DW-1:0] data_addr;
reg signed [7:0] cnt_w, cnt_h;
wire signed [7:0] cnt_w_n, cnt_h_n;
reg [15:0] cnt_seed;	
reg [7:0] cnt_len;
wire [7:0] cnt_len2_p, cnt_len2_n, cnt_len3_p, cnt_len3_n, cnt_len4_p, cnt_len4_n;
wire [7:0] cnt_len2, cnt_len3, cnt_len4;
reg valid_seed, valid_wait;
reg [15:0] cnt_wait;
reg [1:0] now, next;
localparam  IDLE = 2'd0,
 					SEED = 2'd2,
 					WAIT = 2'd1;					

always @(posedge clk or negedge rst)
	if(!rst)
		now<=IDLE;
	else 
		now<=next;
always @(*)
	if(!rst)
		next=IDLE;
	else 
		case(now)
		IDLE:
			if(cpr_end&&DEF)
				next=WAIT;
			else if(cpr_end&&!DEF)
				next=SEED;
			else 
				next=IDLE;
		WAIT:
			if(cnt_wait==(NUM_WAIT-1))
				next=SEED;
			else
				next=WAIT;			
		SEED:
			if(cnt_seed==(NUM_SEED-1)&&(cnt_rd==(cnt_wr-1)))
				next=IDLE;
			else if(cnt_seed==(NUM_SEED-1))
				next=WAIT;
			else
				next=SEED;
		default:
			next=IDLE;
		endcase
always@(posedge clk or negedge rst)
	if(!rst)
		begin
		valid_wait<=0;
		valid_seed<=0;
		end
	else 
		case(next)
		IDLE:
			begin
			valid_wait<=0;
			valid_seed<=0;
			end
		WAIT:
			begin
			valid_wait<=1;
			valid_seed<=0;
			end			
		SEED:
			begin
			valid_wait<=0;
			valid_seed<=1;
			end				
		default:
			begin
			valid_wait<=0;
			valid_seed<=0;
			end	
		endcase

always @(posedge clk or negedge rst)
	if(!rst)
		begin
		cnt_seed<=0;
		cnt_rd<=0;
		end
	else if( valid_seed&&cnt_rd==(cnt_wr-1)&&cnt_seed==(NUM_SEED-1))
		begin
		cnt_seed<=0;
		cnt_rd<=cnt_rd;
		end
	else if( valid_seed&&cnt_seed==(NUM_SEED-1))
		begin
		cnt_seed<=0;
		cnt_rd<=cnt_rd+1;
		end
	else if( valid_seed)
		begin
		cnt_seed<=cnt_seed+1;
		cnt_rd<=cnt_rd;
		end
	else
		begin
		cnt_seed<=0;
		cnt_rd<=cnt_rd;
		end	
always @(posedge clk or negedge rst)
	if(!rst | !valid_wait)		
		cnt_wait<=0;
	else if(cnt_wait==(NUM_WAIT-1))	
		cnt_wait<=0;
	else 
		cnt_wait<=cnt_wait+1;

always @(posedge clk or negedge rst)
	if(!rst)
		begin
		valid_addr1<=0;
		valid_addr2<=0;
		valid_addr3<=0;
		valid_addr4<=0;
		end
	else
		begin
		valid_addr1<=valid_seed;
		valid_addr2<=((cnt_w<=cnt_len2 || cnt_w_n<=cnt_len2)&&(cnt_h<=LEN_MAX-2 && cnt_h_n<=LEN_MAX-2))?valid_seed:0;
		valid_addr3<=((cnt_w<=cnt_len3 || cnt_w_n<=cnt_len3)&&(cnt_h<=LEN_MAX-8 && cnt_h_n<=LEN_MAX-8))?valid_seed:0;
		valid_addr4<=((cnt_w<=cnt_len4 || cnt_w_n<=cnt_len4)&&(cnt_h<=LEN_MAX-14 && cnt_h_n<=LEN_MAX-14))?valid_seed:0;
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
	else if(cnt_seed==(NUM_SEED-1))
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
		data_addr<=0;
	else if(cnt_h>0&&cnt_w>0)
		data_addr<=data_mem+WIDE*cnt_h+cnt_w;
	else if(cnt_h>0&&cnt_w<=0)
		data_addr<=data_mem+WIDE*cnt_h-cnt_w_n;
	else if(cnt_h<=0&&cnt_w>0)
		data_addr<=data_mem-WIDE*cnt_h_n+cnt_w;
	else
		data_addr<=data_mem-WIDE*cnt_h_n-cnt_w_n;
							
endmodule
