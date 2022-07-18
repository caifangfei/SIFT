clear, clc;
img1 = imread('C:\Users\Lenovo-PC\Pictures\img1.bmp');
I1 = rgb2gray(img1);
img2 = imread('C:\Users\Lenovo-PC\Pictures\img2.bmp');
I2 = rgb2gray(img2);
[h,w,z]=size(I1);
[h2,w2,z2]=size(I2);

for i=2:2:h
    for j=2:2:w
        I3(i/2,j/2) = I1(i,j);
    end
end
for i=2:2:h
    for j=2:2:w
        I4(i/2,j/2) = I2(i,j);
    end
end

figure(2);
pic=cat(2,img1, img2);
imshow(pic);
hold on;

[addr_h1,addr_w1,addr_seed1,cnt_seed1,dis_one1,sort1,histo_m1,histo1_1,addr1] = match(I1);
one(:,:) = dis_one1(:,1,:);
[addr_h2,addr_w2,addr_seed2,cnt_seed2,dis_one2,sort2,histo_m2,histo1_2,addr2] = match(I2);
% [~,addr_h3,addr_w3,addr_seed3,cnt_seed3,dis_one3] = match(I3);
% [~,addr_h4,addr_w4,addr_seed4,cnt_seed4,dis_one4] = match(I4);

% addr_hl = zeros(1,cnt_seed1+cnt_seed3);
% addr_wl = zeros(1,cnt_seed1+cnt_seed3);
% dis_onel = zeros(1,cnt_seed1+cnt_seed3);
% addr_h2 = zeros(1,cnt_seed2+cnt_seed4);
% addr_w2 = zeros(1,cnt_seed2+cnt_seed4);
% dis_one2 = zeros(1,cnt_seed2+cnt_seed4);
for i1=1:cnt_seed1
        addr_hl(i1) = addr_h1(i1);
        addr_wl(i1) = addr_w1(i1);
        dis_onel(:,i1,:) = dis_one1(:,i1,:);
end
for i2=1:cnt_seed2
        addr_hr(i2) = addr_h2(i2);
        addr_wr(i2) = addr_w2(i2);
        dis_oner(:,i2,:) = dis_one2(:,i2,:);
end
dis1(:,:) = dis_onel(:,1,:);
dis2(:,:) = dis_oner(:,3,:);
cnt_match = 0;
dis0 = 0;
        for k=1:4
            for j=1:16
                dis0 = dis0+(dis1(k,j)-dis2(k,j)).^2;
            end
        end
distan = zeros(cnt_seed1,cnt_seed2);
for i1=1:cnt_seed1
    for i2=1:cnt_seed2
        for k=1:4
            for j=1:16
                distan(i1,i2) = distan(i1,i2)+(dis_onel(k,i1,j)-dis_oner(k,i2,j)).^2;
            end
        end
        if(i2==1)
            get(i1) = distan(i1,i2);
            hypo(i1) = distan(i1,i2);
            get_i1(i1) = i1;
            get_i2(i1) = i2;
        else
            if(distan(i1,i2)<get(i1))
                if(get(i1)<hypo(i1))
                hypo(i1) = get(i1);
                end
                get(i1) = distan(i1,i2);
                get_i1(i1) = i1;
                get_i2(i1) = i2;
            else if(distan(i1,i2)<hypo(i1))
                    hypo(i1) = distan(i1,i2);
                end
                
            end
        end
    end
    if(get(i1)<6000&&2*get(i1)<hypo(i1))
        cnt_match = cnt_match+1;
        a(cnt_match) = get_i1(i1);
        b(cnt_match) = get_i2(i1);
        c(cnt_match) = get(i1);
        d(cnt_match) = hypo(i1);
    end
end

for m=1:cnt_match
    y1(m) = addr_hl(a(m));
    x1(m) = addr_wl(a(m));
    y2(m) = addr_hr(b(m));
    x2(m) = addr_wr(b(m))+w; 
    plot([x1(m),x2(m)],[y1(m),y2(m)]);
    hold on;
end

% for m=1:cnt_seed1
% 	x1=addr_w1(m);
%     y1=addr_h1(m);
%     plot(x1,y1,'*');
%     hold on;
% end
% for n=1:cnt_seed2
%     x2=addr_w2(n)+w;
%     y2=addr_h2(n);
%     plot(x2,y2,'+');
%     hold on;
% end

function [addr_h,addr_w,addr_seed,cnt_seed,dis_one,sort,histo_m,histo4,addr4] = match(I)
I=double(I);
[h,w,z]=size(I);
% her1 = [23,60,108,131,108,61,23];
% her2 = [8,44,120,167,120,44,8];
% her3 = [21,58,110,135,110,58,21];
% her4 = [34,66,99,113,99,66,34];
her1 = [6,15,27,32,27,15,6];
her2 = [3,15,39,55,39,15,3];
her3 = [6,15,28,35,28,15,6];
her4 = [7,13,19,22,19,13,7];

[gua1] = guass(I, her1);
[gua2] = guass(I, her2);
[gua3] = guass(I, her3);
[gua4] = guass(I, her4);

dog1 = int8(gua2-gua1);
dog2 = int8(gua3-gua2);
dog3 = int8(gua4-gua3);
cnt_seed = 0;
cnt_d=0;
for i=19:h-18
    for j=19:w-18 
        if(dog2(i,j)>1&&dog2(i,j)>dog2(i-1,j-1)&&dog2(i,j)>dog2(i-1,j)&&dog2(i,j)>dog2(i-1,j+1)&&dog2(i,j)>dog2(i,j-1)&&dog2(i,j)>dog2(i,j+1)&&dog2(i,j)>dog2(i+1,j-1)&&dog2(i,j)>dog2(i+1,j)&&dog2(i,j)>dog2(i+1,j+1))
            if(dog2(i,j)>dog1(i-1,j-1)&&dog2(i,j)>dog1(i-1,j)&&dog2(i,j)>dog1(i-1,j+1)&&dog2(i,j)>dog1(i,j-1)&&dog2(i,j)>dog1(i,j)&&dog2(i,j)>dog1(i,j+1)&&dog2(i,j)>dog1(i+1,j-1)&&dog2(i,j)>dog1(i+1,j)&&dog2(i,j)>dog1(i+1,j+1))
                if(dog2(i,j)>dog3(i-1,j-1)&&dog2(i,j)>dog3(i-1,j)&&dog2(i,j)>dog3(i-1,j+1)&&dog2(i,j)>dog3(i,j-1)&&dog2(i,j)>dog3(i,j)&&dog2(i,j)>dog3(i,j+1)&&dog2(i,j)>dog3(i+1,j-1)&&dog2(i,j)>dog3(i+1,j)&&dog2(i,j)>dog3(i+1,j+1))
                   cnt_seed = cnt_seed+1;
                   addr_h(cnt_seed) = i;
                   addr_w(cnt_seed) = j;
                   addr_seed(cnt_seed) = (i-1)*w+j-1;    
                end
            end
        end
    end
end
dog2_s = int16(gua2);
mor = zeros(h,w);
the = zeros(h,w);
new_the = zeros(h,w);
for i=2:h-1
    for j=2:w-1
        x = dog2_s(i,j+1)-dog2_s(i,j-1);
        y = dog2_s(i-1,j)-dog2_s(i+1,j);
        mor(i,j) = fix(sqrt(double(x^2+y^2)));
        the(i,j) = atan2(double(y),double(x));
        for k=1:16
            def(k) = 2*3.1416/16*k-2*3.1416/32-3.1416;
            if(k==16&&the(i,j)>=def(k))
                new_the(i,j) = 8;
            end
            if(the(i,j)<def(k))
                new_the(i,j) = k+7;
                if(new_the(i,j)>15)
                    new_the(i,j) = new_the(i,j)-16;
                end
                break;
            end
        end
    end
end
for i = 1:cnt_seed
    [addr1(i,:),histo1(i,:)] = histogram(addr_h(i),addr_w(i),new_the,mor,w,9);
    [addr2(i,:),histo2(i,:)] = histogram(addr_h(i),addr_w(i),new_the,mor,w,8);
    [addr3(i,:),histo3(i,:)] = histogram(addr_h(i),addr_w(i),new_the,mor,w,5);
    [addr4(i,:),histo4(i,:)] = histogram(addr_h(i),addr_w(i),new_the,mor,w,2);
    histo_m(i,:) = histo1(i,:)+2*histo2(i,:)+4*histo3(i,:)+8*histo4(i,:);
    max = 0;
    for j = 1:16
        if(histo_m(i,j)>max)
            max = histo_m(i,j);
            sort(i) = j-1;
        end
    end
    for j = 1:16
        sort_dis = j+sort(i);
        if(sort_dis>16)
            sort_dis = sort_dis-16;
        end
        distr(1,i,j) = histo1(i,sort_dis);
        distr(2,i,j) = histo2(i,sort_dis);
        distr(3,i,j) = histo3(i,sort_dis);
        distr(4,i,j) = histo4(i,sort_dis);
    end
    for j = 1:16
        for k=1:4
            sum_dis(k,i) = sum(distr(k,i,:));
            dis_one(k,i,j) = fix(distr(k,i,j).*256./sum_dis(k,i));
        end
    end
end
end

function [addr,histo] = histogram(seed_h,seed_w,map_the,map_cor,wide,size)
cnt_addr = 0;
for h = -2*size:-size
    for w=-3*size-h:3*size+h
        cnt_addr = cnt_addr+1;
        the(cnt_addr) = map_the(seed_h+h,seed_w+w);
        cor(cnt_addr) = map_cor(seed_h+h,seed_w+w);
        addr(cnt_addr) = (seed_h+h-1)*wide+seed_w+w-1;
    end
end
for h = -size+1:size-1
    for w = -2*size:2*size
        cnt_addr = cnt_addr+1;
        the(cnt_addr) = map_the(seed_h+h,seed_w+w);
        cor(cnt_addr) = map_cor(seed_h+h,seed_w+w);
        addr(cnt_addr) = (seed_h+h-1)*wide+seed_w+w-1;
    end
end
for h = size:2*size
    for w=-3*size+h:3*size-h
        cnt_addr = cnt_addr+1;
        the(cnt_addr) = map_the(seed_h+h,seed_w+w);
        cor(cnt_addr) = map_cor(seed_h+h,seed_w+w);
        addr(cnt_addr) = (seed_h+h-1)*wide+seed_w+w-1;
    end
end
histo = zeros(1,16);
for t = 1:cnt_addr
    num = the(t)+1;
    histo(num) = histo(num)+cor(t);
end
end
function [gua] = guass(pic, her)
gua_w = pic;
[h,w,z]=size(pic);
s = 0;
for i=1:7
    s = her(i)+s;
end
for i=1:h
    for j=4:w-3
        gua_w(i,j) = fix((pic(i,j-3)*her(1)+pic(i,j-2)*her(2)+pic(i,j-1)*her(3)+pic(i,j)*her(4)+pic(i,j+1)*her(5)+pic(i,j+2)*her(6)+pic(i,j+3)*her(7))/s);
    end
end
gua = gua_w;
for j=1:w
    for i=4:h-3
        gua(i,j) = fix((gua_w(i-3,j)*her(1)+gua_w(i-2,j)*her(2)+gua_w(i-1,j)*her(3)+gua_w(i,j)*her(4)+gua_w(i+1,j)*her(5)+gua_w(i+2,j)*her(6)+gua_w(i+3,j)*her(7))/s);
    end
end
end
