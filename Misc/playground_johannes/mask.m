function [person_seg_mask] = mask(left, right)

    %i1 = imread('00000215.jpg');
    i1 = left(:,:,1:3);
    i2 = left(:,:,4:6);

    gray1 = rgb2gray(i1);
    gray2 = rgb2gray(i2);

    %% Build differences
    d_color = i1-i2;
    d_gray = gray1 - gray2; 

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
    
    labeled_image = bwlabel(gray1_masked, 8);
    stats = regionprops(labeled_image, 'Area');
    maxArea = max([stats.Area]);
    idx = find([stats.Area] == maxArea);
    person_seg_mask = ismember(labeled_image, idx);
    
    SE = strel('square', 20);
    person_seg_mask = imdilate(person_seg_mask,SE);
end
