clc;
clear all;
close all;
 
medfilt_v_load1 = imread('C:\Users\Lenovo-PC\Pictures\image1.bmp');
medfilt_v_load2 = imread('C:\Users\Lenovo-PC\Pictures\image2.bmp');
pic=cat(2,medfilt_v_load1, medfilt_v_load2);
figure;
imshow(pic);
hold on;
rd1 = load('D:\Vivado_2018.3\Vivado_DOC\IMG_prc\SIFT_fuse\image_out1.txt'); 
rd2 = load('D:\Vivado_2018.3\Vivado_DOC\IMG_prc\SIFT_fuse\image_out2.txt'); 
len = length(rd1);
for i=1:len
    w1(i)=mod(rd1(i),256)+1;
    h1(i)=fix(rd1(i)/256)+1;
    w2(i)=mod(rd2(i),256)+1+256;
    h2(i)=fix(rd2(i)/256)+1; 
    plot([w1(i),w2(i)],[h1(i),h2(i)]);
    hold on;
end 


