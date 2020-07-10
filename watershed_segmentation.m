function Labels = watershed_segmentation(I, do_plot)
%WATERSHED_SEGMENTATION Finds segments along edges
%   left    Left channel tensor
%   right   Right channel tensor

%% Generate markers
[fgm, bgm] = generate_markers(I);
if do_plot
    I2 = labeloverlay(I,fgm);
    figure
    imshow(I2)
end

%% Image segmentation

% Calculate magnitude of gradient
gmag = imgradient(I, 'sobel');

% Compute the watershed-based segmentation
gmag2 = imimposemin(gmag, bgm | fgm);
Labels = watershed(gmag2);

end

