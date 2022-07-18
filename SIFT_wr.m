
clear, clc;
%读取图片
img1 = imread('C:\Users\Lenovo-PC\Pictures\image1.bmp');
imshow(img1);
I1 = rgb2gray(img1);
%计算维度，高X长X维度，提取色彩RGB888
[h,w,z]=size(img1);
img2 = imread('C:\Users\Lenovo-PC\Pictures\image2.bmp');
imshow(img2);
I2 = rgb2gray(img2);
%计算维度，高X长X维度，提取色彩RGB888

fid1=fopen('D:\Vivado_2018.3\Vivado_DOC\IMG_prc\SIFT\image1.txt','w+');
fid2=fopen('D:\Vivado_2018.3\Vivado_DOC\IMG_prc\SIFT\image2.txt','w+');
for i=1:h
    for j=1:w
    fprintf(fid1,'%x\n',I1(i,j));
    fprintf(fid2,'%x\n',I2(i,j));
    end
end
fclose(fid1);
fclose(fid2);