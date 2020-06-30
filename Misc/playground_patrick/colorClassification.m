%% Cleanup
clear
close all
clc

%% Image loading
image_num = 2;

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
        i1 = imread('00000511.jpg');
        i2 = imread('00000512.jpg');
end

gray1 = rgb2gray(i1);
gray2 = rgb2gray(i2);

%% Build differences
d = i1-i2;

d1 = d(:,:,1);
d2 = d(:,:,2);
d3 = d(:,:,3);

%% Apply Lowpass
n = 51;
boxKernel = 1/(n*n)*ones(n);
d1 = conv2(d1, boxKernel, 'same');
d2 = conv2(d2, boxKernel, 'same');
d3 = conv2(d3, boxKernel, 'same');

%% Create Preliminary overestimating mask
th = 3;
mask = d1>th | d2>th | d3>th;

%% Create masked grayscale images, therefore removing correspondences which are not within the mask
gray1_masked = gray1;
gray2_masked = gray2;

gray1_masked(~mask) = 0;
gray2_masked(~mask) = 0;

%% Calculate harris-features
s_L = 7; % Segment length
k = 0.05;
m_d = 9; % Minimum distance between features
N = 80; % Max features per tile
features1 = harris_detector(gray1_masked, 'segment_length',s_L,'k',k,'min_dist',m_d,'N',N,'do_plot',false);
features2 = harris_detector(gray2_masked, 'segment_length',s_L,'k',k,'min_dist',m_d,'N',N,'do_plot',false);


cor12 = point_correspondence(gray1, gray2, features1, features2, 'window_length', 25, 'min_corr', 0.90, 'do_plot', false);


%% Find dynamic correspondences, save in corDyn
figure(7);
imshow(i1);
hold on 
th_min = 2.5;
th_max = 40;
selection = (vecnorm(cor12(1:2,:)-cor12(3:4,:)) > th_min) & (vecnorm(cor12(1:2,:)-cor12(3:4,:)) < th_max);

dynCor = cor12(:,selection);
plot(dynCor(1,:), dynCor(2,:), 'm *');
disp('Num features likely on foreground: ' + string(sum(selection)))

%% Do Color-Based filtering

colorDelta_TH = 20;

mask_color = zeros(size(mask));

for i = 1:20:size(i1,1)
    disp(i)
    for j = 1:20:size(i1,2)
        if(mask(i,j)) % only look at points cleared by preliminary mask
            % find closest correspondence
            [~, index] = min(vecnorm(dynCor(1:2, :) - [j;i]));
            c1 = squeeze(double(i1(i, j, :))./255);
            c2 = squeeze(double(i1(dynCor(2, index), dynCor(1, index), :))./255);
            temp = sRGB2CIEDeltaE(c1', c2','cielab');
            
            if(temp < colorDelta_TH)
                plot(j, i, 'g *')
            else
                plot(j, i, 'r *')
            end
            
        end
    end
end

title('Color-based filtering with threshold ' + string(colorDelta_TH))

%% Post-Script Cleanup


clear boxKernel cor12 d d1 d2 d3 features1 features2 gray1 gray2 image_num m_d 
