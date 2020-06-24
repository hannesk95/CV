clear;
close all;
clc;

image_num = 4; 

%% Load Image
switch image_num
    case 1
        i1 = imread('00000215.jpg');
        i2 = imread('00000216.jpg');
    case 2
        i1 = imread('00000160.jpg');
        i2 = imread('00000161.jpg');
    case 3 
        i1 = imread('00000377.jpg');
        i2 = imread('00000378.jpg');
    case 4 
        i1 = imread('00000784.jpg');
        i2 = imread('00000785.jpg');
    case 5
        i1 = imread('00000955.jpg');
        i2 = imread('00000956.jpg');
    case 6
        i1 = imread('00000197.jpg');
        i2 = imread('00000198.jpg');
    case 7
        i1 = imread('00000197.jpg');
        i2 = imread('00000198.jpg');
    case 8
        i1 = imread('00000511.jpg');
        i2 = imread('00000512.jpg');

end

%% Build differences
d = double(rgb2gray(i1-i2))./255.0;

%% Apply Lowpass
sigma = 20;
d = imgaussfilt(d,sigma);

%% Create Preliminary overestimating mask
th = 3/255;
mask = d>th;


%% Detect Corners within the mask
i = double(rgb2gray(i1))./255.0;
edges = edge(i ,'Canny').* mask;

%% Show results
figure(1)
imshow(edges)

[result] = render(i1,mask, 0, 'foreground');

figure(2)
subplot(1,2,1)
imshow(result*0.5 + edges*0.5)

subplot(1,2,2)
imshow(i1)