`timescale 1ns / 1ps

module compare(
	clk, rst,
	valid_dog,
    data_dog1, data_dog2, data_dog3,
	cpr_end,
	cnt_seed,
	valid_max,
	addr_max
    );
parameter  WIDE = 256,
					  HIGN = 256,
					  DW = 8,
					  CNT_DW = 16;   
  input clk, rst;	
  input valid_dog;
  input signed [DW-1:0] data_dog1, data_dog2, data_dog3;	
  output reg valid_max;
  output reg cpr_end;
  output reg [8:0] cnt_seed;
  output reg [CNT_DW-1:0] addr_max;
  wire valid_row2;
  wire signed [DW-1:0] data_row[0:2][0:5];
  wire valid_cal0;
  wire signed [DW-1:0] data_cal[0:2][0:1];
  reg [CNT_DW-1:0] cnt_w, cnt_h;

 compare_one
 #(WIDE,  HIGN, DW, CNT_DW )
one1 (
	.clk(clk), .rst(rst),
	.valid_dog(valid_dog),
	.data_dog(data_dog1),
	.valid_cal0(valid_cal0),
	.valid_row2(valid_row2),
	.data_row0(data_row[0][0]),. data_row1(data_row[0][1]), .data_row2(data_row[0][2]), .data_row3(data_row[0][3]), .data_row4(data_row[0][4]), .data_row5(data_row[0][5]),
	.data_cal0(data_cal[0][0]), .data_cal1(data_cal[0][1])
	);

	 compare_one
	 #(WIDE,  HIGN, DW, CNT_DW )
	one2 (
		.clk(clk), .rst(rst),
		.valid_dog(valid_dog),
		.data_dog(data_dog2),
		.valid_cal0(),
		.valid_row2(),
		.data_row0(data_row[1][0]),. data_row1(data_row[1][1]), .data_row2(data_row[1][2]), .data_row3(data_row[1][3]), .data_row4(data_row[1][4]), .data_row5(data_row[1][5]),
		.data_cal0(data_cal[1][0]), .data_cal1(data_cal[1][1])
		);		

	 compare_one
	 #(WIDE,  HIGN, DW, CNT_DW )
	one3 (
		.clk(clk), .rst(rst),
		.valid_dog(valid_dog),
		.data_dog(data_dog3),
		.valid_cal0(),
		.valid_row2(),
		.data_row0(data_row[2][0]),. data_row1(data_row[2][1]), .data_row2(data_row[2][2]), .data_row3(data_row[2][3]), .data_row4(data_row[2][4]), .data_row5(data_row[2][5]),
		.data_cal0(data_cal[2][0]), .data_cal1(data_cal[2][1])
		);	
	
	always @(posedge clk or negedge rst)
		if(!rst | !valid_row2)
			begin
			cnt_h<=0;
			cnt_w<=0;
			end
		else if(cnt_h==(HIGN-1)&&cnt_w==(WIDE-1))
			begin
			cnt_h<=0;
			cnt_w<=0;
			end
		else if(cnt_w==(WIDE-1))
			begin
			cnt_h<=cnt_h+1;
			cnt_w<=0;
			end
		else 
			begin
			cnt_h<=cnt_h;
			cnt_w<=cnt_w+1;
			end
	
	always@(posedge clk or negedge rst)
		if(!rst)
			begin
			valid_max<=0;
			addr_max<=0;
			end
		else if((data_row[1][2]>1)&&(cnt_w>17&&cnt_w<WIDE-18)&&(cnt_h>17&&cnt_h<HIGN-18)
					&&(data_row[1][2]>data_dog2&&data_row[1][2]>data_row[1][0]&&data_row[1][2]>data_row[1][1]&&data_row[1][2]>data_cal[1][0]&&data_row[1][2]>data_row[1][3]&&data_row[1][2]>data_cal[1][1]&&data_row[1][2]>data_row[1][4]&&data_row[1][2]>data_row[1][5])	
							&&(data_row[1][2]>data_dog1&&data_row[1][2]>data_row[0][0]&&data_row[1][2]>data_row[0][1]&&data_row[1][2]>data_cal[0][0]&&data_row[1][2]>data_row[0][2]&&data_row[1][2]>data_row[0][3]&&data_row[1][2]>data_cal[0][1]&&data_row[1][2]>data_row[0][4]&&data_row[1][2]>data_row[0][5])	
								&&(data_row[1][2]>data_dog3&&data_row[1][2]>data_row[2][0]&&data_row[1][2]>data_row[2][1]&&data_row[1][2]>data_cal[2][0]&&data_row[1][2]>data_row[2][2]&&data_row[1][2]>data_row[2][3]&&data_row[1][2]>data_cal[2][1]&&data_row[1][2]>data_row[2][4]&&data_row[1][2]>data_row[2][5])	)
											begin
											valid_max<=1;
											addr_max<=cnt_h*WIDE+cnt_w;																		
											end
	 else
		 begin
		 valid_max<=0;
		 addr_max<=0;
		 end
	
	always @(posedge clk or negedge rst)
		if(!rst)
			cnt_seed<=9'b0;
		else if(valid_max)
			cnt_seed<=cnt_seed+9'd1;
		else
			cnt_seed<=cnt_seed;	
	always @(posedge clk or negedge rst)
		if(!rst)
			cpr_end<=1'b0;
		else if((~valid_cal0)&valid_row2)
			cpr_end<=1'b1;
		else 
			cpr_end<=1'b0;
			
endmodule
