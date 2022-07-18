`timescale 1ns / 1ps

module Match(
	clk, rst,
	valid_in,
	data_in1, data_in2,
	valid_match,
	match_addr
    );
parameter WIDE = 256,    
					HIGN = 256, 
					DW = 8, 
					CNT_DW = 16;
localparam	DELAY = 10; 
input clk, rst;
input valid_in;
input [DW-1:0] data_in1, data_in2;
output reg valid_match;
output reg [CNT_DW+2*DW-1:0] match_addr;
wire valid_desc_end1, valid_desc_end2;
reg [1:0] cnt_desc_end;
reg valid_match_begin;
reg en_match;
reg [8:0] addr_rd_desc1, addr_rd_desc2;
wire [8:0] max_seed1, max_seed2;
wire [CNT_DW-1:0] data_seed1, data_seed2;	
wire [511:0] data_rd_desc1, data_rd_desc2;
always @(posedge clk or negedge rst)			
	if(!rst)
		cnt_desc_end<=2'd0;
	else if(cnt_desc_end==2)
		cnt_desc_end<=2'd0;
	else if(valid_desc_end1 || valid_desc_end2)
		cnt_desc_end<=cnt_desc_end+2'd1;
	else
		cnt_desc_end<=cnt_desc_end;	
always @(posedge clk or negedge rst)	
	if(!rst)
		valid_match_begin<=1'b0;	
	else if(cnt_desc_end==2)
		valid_match_begin<=1'b1;
	else
		valid_match_begin<=1'b0;	
always @(posedge clk or negedge rst)
	if(!rst | !en_match)		
		begin
		addr_rd_desc1<=9'd0;
		addr_rd_desc2<=9'd0;
		end
	else if(addr_rd_desc1==(max_seed1-1)&&addr_rd_desc2==(max_seed2-1))	
		begin
		addr_rd_desc1<=9'd0;
		addr_rd_desc2<=9'd0;
		end
	else if(addr_rd_desc1==(max_seed1-1))
		begin
		addr_rd_desc1<=9'd0;
		addr_rd_desc2<=addr_rd_desc2+9'd1;
		end
	else
		begin
		addr_rd_desc1<=addr_rd_desc1+9'd1;
		addr_rd_desc2<=addr_rd_desc2;
		end	
always @(posedge clk or negedge rst)
	if(!rst)
		en_match<=1'b0;
	else if(addr_rd_desc1==(max_seed1-1)&&addr_rd_desc2==(max_seed2-1))
		en_match<=1'b0;
	else if(valid_match_begin)
		en_match<=1'b1;	
	else
		en_match<=en_match;

 Get_describe
 #(WIDE, HIGN, DW, CNT_DW)
 get_desc1(
	.clk(clk), 
	.rst(rst),
	.valid_in(valid_in),
	.data_in(data_in1),
	.cnt_seed(max_seed1),
	.valid_rd_desc(en_match),
	.addr_rd_desc(addr_rd_desc1),
	.data_rd_feature(data_seed1),
	.data_rd_desc(data_rd_desc1),
	.valid_end(valid_desc_end1)
    );

 Get_describe
 #(WIDE, HIGN, DW, CNT_DW)
 get_desc2(
	.clk(clk), 
	.rst(rst),
	.valid_in(valid_in),
	.data_in(data_in2),
	.cnt_seed(max_seed2),
	.valid_rd_desc(en_match),
	.addr_rd_desc(addr_rd_desc2),
	.data_rd_feature(data_seed2),
	.data_rd_desc(data_rd_desc2),
	.valid_end(valid_desc_end2)
    ); 

reg [2*DW-1:0] dist[0:63];
reg [19:0] add1[0:31], add2[0:15], add3[0:7], add4[0:3], add5[0:1], add;
reg [2*CNT_DW-1:0] seed[0:6];
reg [7:0]valid_add_r;
wire valid_com;
reg valid_add;

generate
genvar i, j, k, l, m, n, r;
for(i=0;i<64;i=i+1)
	begin
	always@(posedge clk or negedge rst)
		if(!rst)
			dist[i]<=0;
		else 
			dist[i]<=(data_rd_desc1[8*(i+1)-1:8*i]>data_rd_desc2[8*(i+1)-1:8*i])? (data_rd_desc1[8*(i+1)-1:8*i]-data_rd_desc2[8*(i+1)-1:8*i])*(data_rd_desc1[8*(i+1)-1:8*i]-data_rd_desc2[8*(i+1)-1:8*i]): (data_rd_desc2[8*(i+1)-1:8*i]-data_rd_desc1[8*(i+1)-1:8*i])*(data_rd_desc2[8*(i+1)-1:8*i]-data_rd_desc1[8*(i+1)-1:8*i]) ;           
	end
for(j=0;j<32;j=j+1)
	begin	
	always@(posedge clk or negedge rst)
		if(!rst)
			add1[j]<=0;
		else
			add1[j]<=dist[2*j+1]+dist[2*j];
	end
for(k=0;k<16;k=k+1)
	begin	
	always@(posedge clk or negedge rst)
		if(!rst)
			add2[k]<=0;
		else
			add2[k]<=add1[2*k+1]+add1[2*k];
	end
for(l=0;l<8;l=l+1)
	begin	
	always@(posedge clk or negedge rst)
		if(!rst)
			add3[l]<=0;
		else
			add3[l]<=add2[2*l+1]+add2[2*l];
	end	
for(m=0;m<4;m=m+1)
	begin	
	always@(posedge clk or negedge rst)
		if(!rst)
			add4[m]<=0;
		else
			add4[m]<=add3[2*m+1]+add3[2*m];
	end		
for(n=0;n<2;n=n+1)
	begin	
	always@(posedge clk or negedge rst)
		if(!rst)
			add5[n]<=0;
		else
			add5[n]<=add4[2*n+1]+add4[2*n];
	end
for(r=0;r<7;r=r+1)
	begin	
	always@(posedge clk or negedge rst)
		if(!rst)
			seed[r]<=0;
		else if(r==0)
			seed[r]<={data_seed2, data_seed1};
		else
			seed[r]<=seed[r-1];
	end	
endgenerate

assign valid_com = (addr_rd_desc1==9'd8)?1'b1:1'b0;
always@(posedge clk or negedge rst)
	if(!rst)
		valid_add_r<=1'b0;
	else
		valid_add_r<={valid_add_r[6:0], en_match};
always@(posedge clk or negedge rst)
	if(!rst)
		begin
		add<=20'd0;
		valid_add<=1'b0;
		end
	else
		begin
		add<=add5[0]+add5[1];
		valid_add<=valid_add_r[7];
		end

reg [19:0] com_add, hypo_add;
reg [2*CNT_DW-1:0] addr_add;
always@(posedge clk or negedge rst)
	if(!rst | !valid_add)
		begin
		com_add<={20{1'b1}};
		hypo_add<={20{1'b1}};
		addr_add<={2*CNT_DW{1'b0}};
		end
	else if(addr_rd_desc1==9'd9)
		begin
		com_add<=add;
		hypo_add<=add;
		addr_add<=seed[6];
		end		
	else if(add<com_add)
		begin
		com_add<=add;
		hypo_add<=(com_add<hypo_add)?com_add:hypo_add;
		addr_add<=seed[6];
		end
	else if(add<hypo_add)
		begin
		com_add<=com_add;
		hypo_add<=add;
		addr_add<=addr_add;
		end	
	else
		begin
		com_add<=com_add;
		hypo_add<=hypo_add;
		addr_add<=addr_add;
		end		

always@(posedge clk or negedge rst)
	if(!rst | !valid_com)		
		begin
		valid_match<=0;
		match_addr<=0;
		end
	else if(com_add<6000&&2*com_add<hypo_add)
		begin
		valid_match<=1;
		match_addr<=addr_add;
		end
	else
		begin
		valid_match<=0;
		match_addr<=0;
		end		
endmodule
