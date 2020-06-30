function [mask] = segmentation4(left,right)
  N = size(left,3) / 3 - 1;
  
  %% Segmentation of the image
  labels = watershed_segmentation(left, right);
  
  
  %% Find region of interest
  roi = find_roi(left, right);
  
  N_regions = max(labels(:));
  foreground_labels = zeros(1, N_regions);
  
  for i = 1:N_regions
      region_pixels = labels(:) == i;
      in_roi = sum(roi(region_pixels));
      if in_roi / sum(region_pixels) > 0.7
          foreground_labels(i) = 1;
      end
  end
  
  foreground_labels = find(foreground_labels);
  
  mask = ismember(labels, foreground_labels);
    
  %% Dilate mask
  se = strel('disk',1);
  mask = imdilate(mask,se);
  
  
  Lrgb = label2rgb(labels,'jet','w','shuffle');
  figure
  imshow(Lrgb * 0.7 + uint8(roi*255) * 0.3)  
end
