function Labels = watershed_segmentation(left,right)
%WATERSHED_SEGMENTATION Finds segments along edges
%   left    Left channel tensor
%   right   Right channel tensor

%% Generate markers
[fgm, bgm] = generate_markers(left, right);
%I2 = labeloverlay(left(:,:,1:3),fgm);
%figure
%imshow(I2)

%% Image preprocessing
I = left(:,:, 1:3);
I = rgb2gray(I);

%% Image segmentation

% Calculate magnitude of gradient
gmag = imgradient(I, 'intermediate');

% Compute the watershed-based segmentation
gmag2 = imimposemin(gmag, bgm | fgm);
Labels = watershed(gmag2);

end

