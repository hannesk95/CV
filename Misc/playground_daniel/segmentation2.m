function [mask] = segmentation2(left,right)
  N = size(left,3) / 3 - 1;
    
  
  %% Segmentation of the image
  I = rgb2gray(left(:,:,1:3));
  labels = watershed_segmentation(left, right);
  Lrgb = label2rgb(labels,'jet','w','shuffle');
  figure
  imshow(Lrgb)  
  
  %% Determine correlations
  tile_size = [30, 30];
  [corr, t1, t2] = correlation(left, right, tile_size);  
  N_segments = max(labels(:));
  segment_values = zeros(N_segments, 1);
  for i = 1:N
    for ix = 1:length(t1)
        for iy = 1:length(t2)
            % calculate tile center position
            tx = t1(ix);
            ty = t2(iy);
            % calculate tile edge positions
            left = ceil(tx);
            right = left + tile_size(1) - 1;
            top = ceil(ty);
            bottom = top + tile_size(2) - 1;
            % Limit values
            if left < 1
                left = 1;
            end
            if right > size(I, 2)
                right = size(I, 2);
            end
            if top < 1
                top = 1;
            end
            if bottom > size(I, 1)
                bottom = size(I, 1);
            end
            % Find labels in tile
            tile_labels = labels(top:bottom, left:right);
            tile_labels(tile_labels(:) == 0) = [];
            % Add correlation values
            ncc = corr(ix, iy);
            segment_values(tile_labels) = segment_values(tile_labels) + (ncc + 1) ^ 2;
        end
    end
  end
  
  
  mask = ismember(labels, [ 1 ]);
  
  %% Dilate mask
  se = strel('disk',10);
  mask = imdilate(mask,se);
  figure
  imshow(mask)
end
