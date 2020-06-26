%% Cleanup
clear
close all
clc

%% Image loading
image_num = 7;

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


%% Find edges 
edges = edge(gray1 ,'Canny').* mask;


%% Find dynamic correspondences, save in corDyn
figure(7);
imshow(i1 * 0.5 + uint8(255*edges)*0.5);
hold on 
th_min = 2.5;
th_max = 40;
selection = (vecnorm(cor12(1:2,:)-cor12(3:4,:)) > th_min) & (vecnorm(cor12(1:2,:)-cor12(3:4,:)) < th_max);

corDyn = cor12(:,selection);
plot(corDyn(1,:), corDyn(2,:), 'g *');
disp('Num features likely on foreground: ' + string(sum(selection)))


%% Edge classification - not working yet

corDyn2 = corDyn(1:2, :);
corDyn2 = corDyn2';

[B,L] = bwboundaries(edges, 'noholes');
contours_human = zeros(1, length(B));


hold on
for k = 1:length(B)
   boundary = B{k};
   for j = 1: size(corDyn2, 1)
      l1 = find(boundary(:, 1) == corDyn2(j, 1));
      l2 = find(boundary(:, 2) == corDyn2(j, 2));
      
      if (~isempty(l1) && ~isempty(l2))
          contours_human(j) = 1;
      end
   end
   plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2)
end


