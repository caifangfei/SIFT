# SIFT
A real-time sift matching algorithm
This is a real-time implementation method of sift matching algorithm, which is composed of FPGA.

Convert RGB pictures into 8-bit gray-scale pictures through MATLAB, and then Generate TXT data file, and set it as image1.txt and image2.txt.
Transmit data to FPGA through USB, and then transmit the matched positions back to PC after FPGA processing.
let matlab read these positions and display them on the picture.

The project is divided into four parts: constructing Gaussian pyramid, generating Key points, generating descriptor and matching. 
Gauss pyramid I use a group of four layers, because it is simple.
DOG:The same Gauss kernel filters out four pictures, subtracts two from two to build a dog pyramid, and three dog pictures are generated on four levels. 
key points:A dog pixel is larger than the upper, lower, left and right 26 points, which is the key point.
feature points: replace  16 square subdomains with Four concentric circles. The diameter of the circle is selected according to the sigma of the Gaussian kernel. 
Because the code is all written in Verilog, in order to further simplify the code, I changed the concentric circle into octagon, and only need to change the position when rotating to the main direction, such as 90 °.By the way, I use 9, 8, 5, 2 twice as Octagon side length, then change 16 direction，sum the moduli respectively.

I first used Matlab to write SIFT algorithm. When transplanting it to FPGA, FPGA does not need floating point, and I multiply 256 decimals into integers to save resources.
Matlab part：sift_ WR is to convert RGB image into grayscale data for output;sift_ RD is the reading position, connecting the position to which the two pictures are matched;sift is the SIFT algorithm I first wrote, which can be transplanted to FPGA.

In FPGA, there is creat_Describe generate descriptor and get_Feature gets two parts of feature points. 
Get_feature:Guass and CORDIC are Gaussian filter and modulus are used to calculate the direction of pixel points, Sobel algorithm is used to calculate the gradient, compare--the current point with the surrounding 26 values, and select feature points. 
Creat_Describe:The most troublesome thing is seed_Addr, select the octagon subdomain. The selected 4 octagons and 16 direction histograms directly form the 64 dimensional descriptor. Histogram--calculate the histogram, the sum of modulus values in 16 directions in the sub domain, and the largest one is the main direction. Sort is used to compare the size and select the main direction. Rotate--rotates to the main direction.
Get_ Describe--calculates the top-level file and generates a descriptor. Finally, there is a normalization process, which is also the most resource consuming part. There are four dividers. Match--It is a match. Select the nearest neighbor and the next nearest neighbor to get the matching position.
