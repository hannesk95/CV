clear;
clc;
close All;

%% 
[i1,i2] = getImages(2);

[delta] = getDifference(i1,i2);


sigma = 4;
I2 = imgaussfilt(i2,sigma);
I1 = imgaussfilt(i1,sigma);

[delta] = getDifference(I1,I2);

[maskOverestimating] = getOverestimatingMask(delta, 5, 4);

imshow(delta)

figure(2)
imshow(render(i1,maskOverestimating, 0, 'foreground'))