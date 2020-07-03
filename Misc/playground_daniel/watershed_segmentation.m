function Labels = watershed_segmentation(image_in)
%WATERSHED_SEGMENTATION Finds segments along edges
%   left    Left channel tensor
%   right   Right channel tensor

%% Generate markers
[fgm, bgm] = generate_markers(image_in);
%I = labeloverlay(image_in,fgm);
%figure
%imshow(I)

%% Image preprocessing
I = rgb2gray(image_in);

%% Image segmentation

% Calculate magnitude of gradient
gmag = imgradient(I, 'intermediate');

% Compute the watershed-based segmentation
gmag2 = imimposemin(gmag, bgm | fgm);
Labels = watershed(gmag2);

end

