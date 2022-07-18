`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/07/01 13:36:49
// Design Name: 
// Module Name: SIFT_top


module Get_describe(
	clk, 
	rst,
	valid_in,
	data_in,
	cnt_seed,
	valid_rd_desc,	
	addr_rd_desc,
	data_rd_feature,
	data_rd_desc,
	valid_end
    );
parameter WIDE = 256,
					HIGN = 256,
					DW = 8,
					CNT_DW = 16;

input clk, rst;
input valid_in;
input [DW-1:0] data_in;
output [8:0] cnt_seed;
input valid_rd_desc;
input [8:0] addr_rd_desc;
output [CNT_DW-1:0] data_rd_feature;
output [511:0] data_rd_desc;
output valid_end;
wire valid_dog;
wire signed [DW-1:0]  data_dog1, data_dog2, data_dog3;
wire [DW-1:0] data_gus2;
DOG dog(
  	.clk(clk), 
  	.rst(rst),
  	.valid_in(valid_in),
  	.data_in(data_in),
  	.valid_dog(valid_dog),
  	.data_dog1(data_dog1),
  	.data_dog2(data_dog2),
  	.data_dog3(data_dog3),
  	.data_gus2(data_gus2)
      );	
    defparam dog.WIDE = WIDE;
    defparam dog.HIGN = HIGN; 
    defparam dog.KERNEL1 = 56'h06_0F_1B_20_1B_0F_06;
	defparam dog.KERNEL2 = 56'h03_0F_27_37_27_0F_03;
	defparam dog.KERNEL3 = 56'h06_0F_1C_23_1C_0F_06;
	defparam dog.KERNEL4 = 56'h07_0D_13_16_13_0D_07;
    defparam dog.SUM1 = 128;
	defparam dog.SUM2 = 169;
	defparam dog.SUM3 = 133;
	defparam dog.SUM4 = 100;
	
	wire valid_sob;
    wire [DW-1:0] mor;
    wire [3:0] the;
    Sobel sob(
    	.clk(clk), 
    	.rst(rst),
    	.valid_in(valid_dog),
    	.data_in(data_gus2),
    	.valid_sob(valid_sob),
    	.mor(mor),
    	.the(the)
        );
     defparam sob.WIDE = WIDE;
     defparam sob.HIGN = HIGN; 
     defparam sob.DW = DW;	
     
  reg [CNT_DW-1:0] cnt_sob_wr;
  wire [DW+4-1:0] data_cor;  
  wire [DW+4-1:0] rd_cor;
  assign data_cor = {mor, the};
  always @(posedge clk or negedge rst)
  	if(!rst)
  		cnt_sob_wr<=0;
	else if(valid_sob)
		cnt_sob_wr<=cnt_sob_wr+1;
	else
		cnt_sob_wr<=cnt_sob_wr;

wire valid_addr1;
wire [CNT_DW-1:0] addr_rd_sob;
wire [DW+4-1:0] data_rd_sob;
RAM_sob ram_sob (
  .clka(clk),    // input wire clka
  .ena(valid_sob),      // input wire ena
  .wea(valid_sob),      // input wire [0 : 0] wea
  .addra(cnt_sob_wr),  // input wire [15 : 0] addra
  .dina(data_cor),    // input wire [11 : 0] dina
  .clkb(clk),    // input wire clkb
  .enb(valid_addr1),      // input wire enb
  .addrb(addr_rd_sob),  // input wire [15 : 0] addrb
  .doutb(data_rd_sob)  // output wire [11 : 0] doutb
);

  wire valid_max;
  wire cpr_end;
  wire [8:0] cnt_seed;
  wire [CNT_DW-1:0] addr_max;
  compare 
  #(WIDE,HIGN,DW ,CNT_DW )
  com(
     	.clk(clk), 
     	.rst(rst),
     	.valid_dog(valid_dog),
        .data_dog1(data_dog1), 
        .data_dog2(data_dog2), 
        .data_dog3(data_dog3),
     	.cpr_end(cpr_end),
     	.cnt_seed(cnt_seed),
     	.valid_max(valid_max),
     	.addr_max(addr_max)
         );
 
 wire valid_rd_seed;
 wire valid_rd_feature;
 wire [8:0] addr_rd_seed;    
 wire [8:0] addr_rd_feature;    
 wire [CNT_DW-1:0] data_rd_seed;
 wire [CNT_DW-1:0] data_rd_feature;
 assign valid_rd_feature = valid_rd_seed | valid_rd_desc;
 assign addr_rd_feature = (valid_rd_seed)?addr_rd_seed:addr_rd_desc;
 assign data_rd_seed = (valid_rd_seed)?data_rd_feature:{CNT_DW{1'b0}};
 RAM_feature ram_feature (
      .clka(clk),    // input wire clka
	  .ena(valid_max),      // input wire ena
	  .wea(valid_max),      // input wire [0 : 0] wea
	  .addra(cnt_seed),  // input wire [8 : 0] addra
	  .dina(addr_max),    // input wire [15 : 0] dina
	  .clkb(clk),    // input wire clkb
	  .enb(valid_rd_feature),      // input wire enb
	  .addrb(addr_rd_feature),  // input wire [8 : 0] addrb
	  .doutb(data_rd_feature)  // output wire [15 : 0] doutb
);		

wire valid_addr2, valid_addr3, valid_addr4;
 seed_addr
#(WIDE, HIGN, CNT_DW , 9, 18, 1189)
 seed(
	.clk(clk) ,
	.rst(rst),
	.cpr_end(cpr_end),
	.cnt_seed(cnt_seed),
	.valid_rd_seed(valid_rd_seed),
	.addr_rd_seed(addr_rd_seed),
	.data_rd_seed(data_rd_seed),
	.valid_addr1(valid_addr1),
	.valid_addr2(valid_addr2),
	.valid_addr3(valid_addr3),
	.valid_addr4(valid_addr4),	
	.addr_rd_sob(addr_rd_sob)
    );  
    
reg valid_hist_in_reg1, valid_hist_in_reg2, valid_hist_in_reg3, valid_hist_in_reg4;  
reg valid_hist_in1, valid_hist_in2, valid_hist_in3, valid_hist_in4; 
wire rst_hist;
always @(posedge clk or negedge rst)
	if(!rst)
		begin
		valid_hist_in1<=1'b0;
		valid_hist_in2<=1'b0;
		valid_hist_in3<=1'b0;
		valid_hist_in4<=1'b0;
		valid_hist_in_reg1<=1'b0;
		valid_hist_in_reg2<=1'b0;
		valid_hist_in_reg3<=1'b0;
		valid_hist_in_reg4<=1'b0;
		end
	else
		begin
		valid_hist_in_reg1<=valid_addr1;
		valid_hist_in_reg2<=valid_addr2;
		valid_hist_in_reg3<=valid_addr3;
		valid_hist_in_reg4<=valid_addr4;
		valid_hist_in1<=valid_hist_in_reg1;
		valid_hist_in2<=valid_hist_in_reg2;
		valid_hist_in3<=valid_hist_in_reg3;
		valid_hist_in4<=valid_hist_in_reg4;
		end				
assign rst_hist = (valid_hist_in1)&(~valid_hist_in_reg1);
wire valid_hist;
wire [CNT_DW-1:0] dir_add1, dir_add2, dir_add3, dir_add4;
wire [16*CNT_DW-1:0] dir_hist1, dir_hist2, dir_hist3, dir_hist4;
Histogram
#(DW, CNT_DW)
hist1 (
	.clk(clk), 
	.rst(rst),
	.rst_hist(rst_hist),
	.valid_rd(valid_hist_in1),
	.data_rd(data_rd_sob),
	.valid_hist(valid_hist),
	.dir_add(dir_add1),
	.dir_hist(dir_hist1)		
    );	
Histogram
#(DW, CNT_DW)
hist2 (
	.clk(clk), 
	.rst(rst),
	.rst_hist(rst_hist),
	.valid_rd(valid_hist_in2),
	.data_rd(data_rd_sob),
	.valid_hist(),
	.dir_add(dir_add2),
	.dir_hist(dir_hist2)		
    );	
Histogram
#(DW, CNT_DW)
hist3 (
	.clk(clk), 
	.rst(rst),
	.rst_hist(rst_hist),
	.valid_rd(valid_hist_in3),
	.data_rd(data_rd_sob),
	.valid_hist(),
	.dir_add(dir_add3),
	.dir_hist(dir_hist3)		
    );	
Histogram
#(DW, CNT_DW)
hist4 (
	.clk(clk), 
	.rst(rst),
	.rst_hist(rst_hist),
	.valid_rd(valid_hist_in4),
	.data_rd(data_rd_sob),
	.valid_hist(),
	.dir_add(dir_add4),
	.dir_hist(dir_hist4)		
    );	    

reg [16*CNT_DW-1:0] add_dir_hist1, add_dir_hist2, add_dir_hist;
reg valid_add_hist1, valid_add_hist;
//generate
//genvar i;
//for(i=0;i<16;i=i+1)
//	begin
//	always @(posedge clk or negedge rst)
//		if(!rst)
//			begin
//			add_dir_hist1[(i+1)*CNT_DW-1:i*CNT_DW]<= {CNT_DW{1'b0}};
//			add_dir_hist2[(i+1)*CNT_DW-1:i*CNT_DW]<= {CNT_DW{1'b0}};
//			add_dir_hist[(i+1)*CNT_DW-1:i*CNT_DW]<= {CNT_DW{1'b0}};
//			end
//		else
//			begin
//			add_dir_hist1[(i+1)*CNT_DW-1:i*CNT_DW]<={1'b0, dir_hist1[(i+1)*CNT_DW-1:i*CNT_DW+1]}+dir_hist2[(i+1)*CNT_DW-1:i*CNT_DW];
//			add_dir_hist2[(i+1)*CNT_DW-1:i*CNT_DW]<={dir_hist3[(i+1)*CNT_DW-2:i*CNT_DW], 1'b0}+{dir_hist4[(i+1)*CNT_DW-3:i*CNT_DW], 2'b0};
//			add_dir_hist[(i+1)*CNT_DW-1:i*CNT_DW]<=add_dir_hist1[(i+1)*CNT_DW-1:i*CNT_DW]+add_dir_hist2[(i+1)*CNT_DW-1:i*CNT_DW];
//			end
//	end
//endgenerate

always @(posedge clk or negedge rst)
	if(!rst)
		begin
		add_dir_hist1<= {16*CNT_DW{1'b0}};
		add_dir_hist2<= {16*CNT_DW{1'b0}};
		add_dir_hist<= {16*CNT_DW{1'b0}};
		end
	else
		begin
		add_dir_hist1<=dir_hist1+{dir_hist2[16*CNT_DW-2:0], 1'b0};
		add_dir_hist2<={dir_hist3[16*CNT_DW-3:0], 2'b0}+{dir_hist4[16*CNT_DW-4:0], 3'b0};
		add_dir_hist<=add_dir_hist1+add_dir_hist2;
		end
always @(posedge clk or negedge rst)
	if(!rst)
		begin
		valid_add_hist1<=1'b0;
		valid_add_hist<=1'b0;
		end
	else
		begin
		valid_add_hist1<=valid_hist;
		valid_add_hist<=valid_add_hist1;		
		end

wire valid_sort;
wire [3:0] data_sort;		
Sort sort(
	.clk(clk), 
	.rst(rst),
	.valid_in(valid_add_hist),
	.dir_hist(add_dir_hist),
	.valid_sort(valid_sort),
	.data_sort(data_sort)			
    );	
    	
 wire valid_one;
 wire [16*DW-1:0] dir_one1, dir_one2, dir_one3, dir_one4;   
rotate rot1(
	.clk(clk), 
	.rst(rst),
	.valid_sort(valid_sort),
	.data_sort(data_sort),
	.dir(dir_hist1),
	.dir_add(dir_add1),
	.valid_one(valid_one),
	.dir_one(dir_one1)
    );
rotate rot2(
	.clk(clk), 
	.rst(rst),
	.valid_sort(valid_sort),
	.data_sort(data_sort),
	.dir(dir_hist2),
	.dir_add(dir_add2),
	.valid_one(),
	.dir_one(dir_one2)
    );
rotate rot3(
	.clk(clk), 
	.rst(rst),
	.valid_sort(valid_sort),
	.data_sort(data_sort),
	.dir(dir_hist3),
	.dir_add(dir_add3),
	.valid_one(),
	.dir_one(dir_one3)
    );
rotate rot4(
	.clk(clk), 
	.rst(rst),
	.valid_sort(valid_sort),
	.data_sort(data_sort),
	.dir(dir_hist4),
	.dir_add(dir_add4),
	.valid_one(),
	.dir_one(dir_one4)
    );    

//4*16*DW
wire [511:0]  describe;
reg [8:0] addr_wr_seed;
assign describe = {dir_one4, dir_one3, dir_one2, dir_one1};
always @(posedge clk or negedge rst)
	if(!rst)
		addr_wr_seed<=9'd0;
	else if(valid_one)
		addr_wr_seed<=addr_wr_seed+9'd1;
	else
		addr_wr_seed<=addr_wr_seed;
RAM_describe ram_desc (
  .clka(clk),    // input wire clka
  .ena(valid_one),      // input wire ena
  .wea(valid_one),      // input wire [0 : 0] wea
  .addra(addr_wr_seed),  // input wire [8 : 0] addra
  .dina(describe),    // input wire [511 : 0] dina
  .clkb(clk),    // input wire clkb
  .enb(valid_rd_desc),      // input wire enb
  .addrb(addr_rd_desc),  // input wire [8 : 0] addrb
  .doutb(data_rd_desc)  // output wire [511 : 0] doutb
);  

reg valid_rd_seed_reg;
wire valid_end;
always @(posedge clk or negedge rst)
	if(!rst)
		valid_rd_seed_reg<=1'b0;
	else
		valid_rd_seed_reg<=valid_rd_seed;
assign valid_end = (valid_rd_seed_reg)&(~valid_rd_seed);

endmodule
