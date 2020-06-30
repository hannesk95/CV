

%% =========================== Prep =================================
clear;
close all;
clc;


%% ====================== Build Test Variables ======================
i1 = imread('00000160.jpg'); % An image without anyone in it
i2 = imread('00000161.jpg'); % An image with someone in it

d = i1-i2;

d1 = d(:,:,1);
d2 = d(:,:,2);
d3 = d(:,:,3);

BW1 = edge(d1,'Canny');
BW2 = edge(d2,'Canny');
BW3 = edge(d3,'Canny');

Or = BW1 | BW2 | BW3;
And = BW1 .* BW2.* BW3;
Add = BW1 + BW2 + BW3;

subplot(2,2,1)
imshow(Or)

subplot(2,2,2)
imshow(And)

subplot(2,2,3)
imshow(Add)

subplot(2,2,4)



return





[B,L] = bwboundaries(BW2,'noholes');

imshow(label2rgb(L, @jet, [.5 .5 .5]))
hold on
for k = 1:length(B)
   boundary = B{k};
   plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2)
end
