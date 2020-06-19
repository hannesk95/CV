%% =========================== Prep =================================
clear;
close all;
clc;


%% ====================== Build Test Variables ======================
th = 18;

bg = imread('00000000.jpg'); % An image without anyone in it
fg = imread('00000151.jpg'); % An image with someone in it

bg_simple = imread('00000001.jpg'); % Some background of size 600x800x3
bg_too_small = imread('Mountain_small.jpg'); % Some background which is smaller than 600x800 (but still 3-channel)
bg_too_large = imread('Mountain_large.jpg'); % Some background which is larger than 600x800 (but still 3-channel)

% Import Video
Penguins = importdata('Penguins.mp4');

% separate channels of background
bg_r = bg(:,:,1);
bg_g = bg(:,:,2);
bg_b = bg(:,:,3);

% separate channels of image
fg_r = fg(:,:,1);
fg_g = fg(:,:,2);
fg_b = fg(:,:,3);

% Channel-wise deltas
d_r = bg_r-fg_r;
d_g = bg_g-fg_g;
d_b = bg_b-fg_b;

mask = zeros(size(bg_r));
mask(d_r > th | d_g > th | d_r > th) = 1;



%% ========================== Do Tests ==============================

result_foreground = render(fg,mask, bg, 'foreground');
result_background = render(fg,mask, bg, 'background');
result_overlay = render(fg,mask, bg, 'overlay');

result_substitute_simple = render(fg,mask, bg_simple, 'substitute');
result_substitute_resize_to_smaller = render(fg,mask, bg_too_large, 'substitute');
result_substitute_resize_to_larger = render(fg,mask, bg_too_small, 'substitute');

pengu = render(fg,mask, Penguins, 'video');

%% ======================== Show Test Results =======================
figure()
imshow(mask)
title('Maske')

figure()
subplot(3,2,1)
imshow(result_foreground);
title('foreground');

subplot(3,2,2)
imshow(result_background);
title('background');

subplot(3,2,3)
imshow(result_overlay);
title('overlay');

subplot(3,2,4)
imshow(result_substitute_simple);
title('substitute simple');

subplot(3,2,5)
imshow(result_substitute_resize_to_smaller);
title('substitute make smaller');

subplot(3,2,6)
imshow(result_substitute_resize_to_larger);
title('substitute make larger');