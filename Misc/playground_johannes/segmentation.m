%% Cleanup
clear
close all
clc

%% Load images
image_num = 4;

switch image_num
    case 1
        i1 = imread('00000215.jpg');
        i2 = imread('00000216.jpg');
    case 2
        i1 = imread('00000160.jpg');
        i2 = imread('00000161.jpg');
    case 3 
        i1 = imread('00000293.jpg');
        i2 = imread('00000294.jpg');
    case 4 
        i1 = imread('00000836.jpg');
        i2 = imread('00000837.jpg');
    case 5
        i1 = imread('00000965.jpg');
        i2 = imread('00000966.jpg');
end

gray1 = rgb2gray(i1);
gray2 = rgb2gray(i2);

figure();
imshow(gray1)

%% Build differences
d_color = i1-i2;
d_gray = gray1 - gray2;

figure();
imshow(d_color)

figure();
imshow(d_gray)

d1 = d_color(:,:,1);
d2 = d_color(:,:,2);
d3 = d_color(:,:,3);


%% Apply Lowpass
n = 75;
boxKernel = 1/(n*n)*ones(n);
d1 = conv2(d1, boxKernel, 'same');
d2 = conv2(d2, boxKernel, 'same');
d3 = conv2(d3, boxKernel, 'same');


%% Create Preliminary overestimating mask
th = 2;
mask = d1>th | d2>th | d3>th;

%% Create masked grayscale images, therefore removing correspondences which are not within the mask
gray1_masked = gray1;
gray2_masked = gray2;

gray1_masked(~mask) = 0;
gray2_masked(~mask) = 0;

figure();
imshow(gray1_masked)

%%  Count number of segments found by overestimating mask
%   only keep biggest
%   adopt mask to ROI

labeled_image = bwlabel(gray1_masked, 8);
stats = regionprops(labeled_image, 'Area');
maxArea = max([stats.Area]);
idx = find([stats.Area] == maxArea);
person_seg_mask = ismember(labeled_image, idx);
SE = strel('square', 20);
person_seg_mask = imdilate(person_seg_mask,SE);

figure();
imshow(person_seg_mask)

person_seg_image = gray1;
person_seg_image(~person_seg_mask) = 0;

figure();
imshow(person_seg_image)

%% Process ROI

person_bw = imbinarize(person_seg_image);%, 'adaptive');

figure();
imshow(person_bw)

%person_bw = medfilt2(person_bw);
SE = strel('square', 3);
person_bw_eroded = imerode(person_bw,SE);

person_boundary = person_bw - person_bw_eroded;
figure();
imshow(person_boundary)

mask_new = mask();
