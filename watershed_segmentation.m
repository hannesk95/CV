function Labels = watershed_segmentation(I)
%WATERSHED_SEGMENTATION Finds segments along edges
%   left    Left channel tensor
%   right   Right channel tensor

%% Generate markers
[fgm, bgm] = generate_markers(I);
%I = locallapfilt(I, 0.4, 0.5);
%I = labeloverlay(image_in,fgm);
%figure
%imshow(I)

%% Image segmentation

% Calculate magnitude of gradient
gmag = imgradient(I, 'intermediate');

% Compute the watershed-based segmentation
gmag2 = imimposemin(gmag, bgm | fgm);
Labels = watershed(gmag2);

end

