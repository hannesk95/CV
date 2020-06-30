clear
close all
clc

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

img1 = i1;
img2 = i2;
clear i1 i2;
gray1 = img1(:,:,1) * 0.299 + img1(:,:,2) * 0.587 + img1(:,:,3) * 0.114;
gray2 = img2(:,:,1) * 0.299 + img2(:,:,2) * 0.587 + img2(:,:,3) * 0.114;

% Make images zero mean
zero_mean1 = gray1 - mean(gray1(:));
zero_mean2 = gray2 - mean(gray2(:));

% Calcluate difference images
img_diff = (zero_mean2 - zero_mean1) .^ 2;

% Remove distortion by gauss filtering
img_diff = imgaussfilt(img_diff, 40);

% Extract dynamic regions of image
dyn_region = img_diff > 5;

% Make region rectangular
left = find(sum(dyn_region) > 0,1,'first');
right = find(sum(dyn_region) > 0,1,'last');
top = find(sum(dyn_region') > 0,1,'first');
bottom = find(sum(dyn_region') > 0,1,'last');
%dyn_region(top:bottom, left:right) = 1;

% Show dynamic region
figure(1)
subplot(2,2,1)
imshow(uint8(dyn_region) .* img1)
subplot(2,2,2)
imshow(uint8(dyn_region) .* img2)

% Extract dynamic image parts
clip1 = img1(top:bottom, left:right);
clip2 = img2(top:bottom, left:right);

% Calculate harris-features
s_L = 7; % Segment length
k = 0.05;
m_d = 9; % Minimum distance between features
N = 80; % Max features per tile
features1 = harris_detector(clip1,'segment_length',s_L,'k',k,'min_dist',m_d,'N',N,'do_plot',false);
features2 = harris_detector(clip2,'segment_length',s_L,'k',k,'min_dist',m_d,'N',N,'do_plot',false);


cor12 = point_correspondence(clip1,clip2,features1,features2,'window_length',25,'min_corr', 0.90,'do_plot',true);

%% Find small-moving correspondences, save in corDyn
figure(7);
imshow(clip1)
hold on 
th_min = 2.5;
th_max = 40;
selection = (vecnorm(cor12(1:2,:)-cor12(3:4,:)) > th_min) & (vecnorm(cor12(1:2,:)-cor12(3:4,:)) < th_max);

corDyn = cor12(:,selection);
plot(corDyn(1,:), corDyn(2,:), 'g *');
sum(selection)

%% Build triangles
for i = 1:size(corDyn, 2)
    min_D1 = 600*800;
    min_D2 = 600*800;
    min_I1 = 0;
    min_I2 = 0;
   
    % Find two closest features
    for j = 1:size(corDyn, 2)
        d = norm(corDyn(1:2, i) - corDyn(1:2, j));
        if(d < min_D1 && d > 0)
           min_D2 = min_D1;
           min_D1 = d;
           
           min_I2 = min_I1;
           min_I1 = j;
 
        elseif(d < min_D2 && d > 0)
            min_D2 = d;
            min_I2 = j;
        end
    end
    
    points = corDyn(1:2, [i, min_I1, min_I2, i]);
    
    fill(points(1, :),points(2, :),'r')
    
end






