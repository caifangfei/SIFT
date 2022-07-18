`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/28 14:15:35
// Design Name: 
// Module Name: Canny_tb
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


module SIFT_tb;
parameter  WIDE = 256,
                      HIGN = 256,
                      DW = 8,
                      CNT_DW=16;
	   reg clk, rst;
	   wire [DW-1:0] data_in1, data_in2;
	   reg valid_in;
	   reg [DW-1:0] reg1_1, reg1_2;
	   reg [CNT_DW-1:0] reg2_1, reg2_2;
	   reg [DW-1:0] mem1[WIDE*HIGN-1:0], mem2[WIDE*HIGN-1:0];
	   wire valid_out;
	   reg valid_out_r;
//       wire [DW-1:0] data_out;
       wire [CNT_DW-1:0] data_out1;
       wire [CNT_DW-1:0] data_out2;
	   integer fp_w1, fp_w2;  
	   integer cnt_w, cnt_r;   
	   
   always #10 clk=~clk;
   initial
       begin
       clk=1;
       rst=0;
       cnt_w = 0;
       cnt_r = 0;
       fp_w1=$fopen("D:/Vivado_2018.3/Vivado_DOC/IMG_prc/SIFT_fuse/image_out1.txt","w"); 
       fp_w2=$fopen("D:/Vivado_2018.3/Vivado_DOC/IMG_prc/SIFT_fuse/image_out2.txt","w"); 
       $readmemh("D:/Vivado_2018.3/Vivado_DOC/IMG_prc/SIFT_fuse/image1.txt", mem1);
       $readmemh("D:/Vivado_2018.3/Vivado_DOC/IMG_prc/SIFT_fuse/image2.txt", mem2); 
       #50 rst=1;
       #13568000
       $fclose(fp_w1);
       $fclose(fp_w2);
      $finish;
       end
  
         assign data_in1 =(valid_in)?reg1_1:0;
         assign data_in2 =(valid_in)?reg1_2:0;
         always@(posedge clk or negedge rst)
             if(!rst)
             	begin
                 reg1_1<=0;
                 reg1_2<=0;
                 valid_in<=0;
                 cnt_r<=0;
                 end
            else if(cnt_r < WIDE*HIGN )
				begin
                reg1_1<=mem1[cnt_r];
                reg1_2<=mem2[cnt_r];
				cnt_r <= cnt_r + 1; 
				valid_in<=1;
				end		
		    else
				begin
//				 $fclose(fp_r);
				 valid_in<=0;
				end 
			
          always@(posedge clk or negedge rst)
			if(!rst)
			   begin
			   reg2_1<=0;
			   reg2_2<=0;
			   valid_out_r<=0;
			   end
		   else   
		       begin
		       valid_out_r<=valid_out;
		       reg2_1<=data_out1;
		       reg2_2<=data_out2;
		       end
          always@(posedge clk or negedge rst)
			if(valid_out_r)
				begin
                $fwrite(fp_w1,"%d\n", reg2_1);
                $fwrite(fp_w2,"%d\n", reg2_2);
				end	

wire [31:0] data_match;
assign data_out2 = data_match[31:16];
assign data_out1 = data_match[15:0];
Match match(
	.clk(clk), 
	.rst(rst),
	.valid_in(valid_in),
	.data_in1(data_in1), 
	.data_in2(data_in2),
	.valid_match(valid_out),
	.match_addr(data_match)
    );
defparam match.WIDE = WIDE;   
defparam match.HIGN = HIGN; 
defparam match.DW = DW;

endmodule
