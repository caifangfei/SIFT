`timescale 1ns / 1ps


module DOG(
	clk, rst,
	valid_in,
	data_in,
	valid_dog,
	data_dog1,
	data_dog2,
	data_dog3,
	data_gus2
    );
parameter   WIDE = 230,
					  HIGN = 235,
					  KERNEL1 = 56'h01_0D_2B_3F_2B_0D_01,
					  KERNEL2 = 56'h04_0E_1F_28_1F_0E_04,
					  KERNEL3 = 56'h06_0D_15_19_15_0D_06,
					  KERNEL4 = 56'h06_0A_0E_0F_0E_0A_06,
					  SUM1 = 177,
					  SUM2 = 138,
					  SUM3 = 105,
					  SUM4 = 75;
  localparam  DW = 8,
					  CNT_DW = 16,
                      R =7;
  input clk, rst;
  input valid_in;
  input [DW-1:0] data_in;
  output reg valid_dog;
  output reg signed [DW-1:0] data_dog1, data_dog2, data_dog3;	
  output reg [DW-1:0] data_gus2;
  wire [DW-1:0] data_gus[0:3];
  wire valid_gus;
					
always @(posedge clk or negedge rst)
	if(!rst)
		begin
		valid_dog<=0;
		data_dog1<=0;
		data_dog2<=0;
		data_dog3<=0;
		data_gus2<=0;
		end
	else 
		begin
		valid_dog<=valid_gus;
		data_dog1<=data_gus[1]-data_gus[0];
		data_dog2<=data_gus[2]-data_gus[1];
		data_dog3<=data_gus[3]-data_gus[2];
		data_gus2<=data_gus[1];
		end	
				
 	Guass_filt
  #(WIDE,  HIGN, DW, CNT_DW, KERNEL1, SUM1, R)
	  filt1(
		.clk(clk), 
		.rst(rst),
		.valid_in(valid_in),
		.data_in(data_in),
		.valid_gus(valid_gus),
		.data_gus(data_gus[0])
		);	
  	
  		Guass_filt
  	#(WIDE,  HIGN, DW, CNT_DW, KERNEL2 , SUM2, R)
		filt2(
			.clk(clk), 
			.rst(rst),
			.valid_in(valid_in),
			.data_in(data_in),
			.valid_gus(),
			.data_gus(data_gus[1])
			);	
  		
		Guass_filt
	#(WIDE,  HIGN, DW, CNT_DW, KERNEL3, SUM3, R)
  		filt3(
  			.clk(clk), 
  			.rst(rst),
  			.valid_in(valid_in),
  			.data_in(data_in),
  			.valid_gus(),
  			.data_gus(data_gus[2])
  			);	
  			
		Guass_filt
	#(WIDE,  HIGN, DW, CNT_DW, KERNEL4, SUM4, R)
		filt4(
			.clk(clk), 
			.rst(rst),
			.valid_in(valid_in),
			.data_in(data_in),
			.valid_gus(),
			.data_gus(data_gus[3])
			);	
 						 
endmodule
