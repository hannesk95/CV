function [mask] = segmentation(left,right)
  N = size(left,3) / 3 - 1;
  image_size = [size(left, 1) size(left, 2)];
  
  %% Find region of interest
  [~, top_left, bottom_right]  = find_roi(left, right, [floor(image_size(2) / 5), floor(image_size(1) / 5)]);
  
  
  %% Remove everything not in the ROI  
  left = left(top_left(2):bottom_right(2),top_left(1):bottom_right(1), :);
  right = right(top_left(2):bottom_right(2),top_left(1):bottom_right(1), :);
  
    
  %% Search for a more detailed ROI
  [roi_detail, ~, ~] = find_roi(left, right, [5 5], 0);
  
  % Connect marked tiles with small distance
  se = strel(ones(10));
  I = imclose(roi_detail, se);
  
  % Find countours around "blobs"
  CC = bwconncomp(I);
  
  % If there are no contours leave function
  if CC.NumObjects == 0
      mask = zeros(image_size);
      return
  end
  
  % Extract the biggest "blob"
  numPixels = cellfun(@numel,CC.PixelIdxList);
  [~,idx] = max(numPixels);
  pixels = CC.PixelIdxList{idx};
  [rows, cols] = ind2sub(size(roi_detail), pixels');
  
  % Fill polygon area covering biggest "blob"
  contour = boundary(cols', rows', 0.3);
  mask_small = zeros(size(roi_detail));
  mask_small = roipoly(mask_small,cols(contour)',rows(contour)');
  
  %% Remove everything not in the detailed ROI
  [small_top_left, small_bottom_right] = generate_boundarybox(mask_small);
  
  left = left(small_top_left(2):small_bottom_right(2),small_top_left(1):small_bottom_right(1), :);
  right = right(small_top_left(2):small_bottom_right(2),small_top_left(1):small_bottom_right(1), :);
  
  mask_small = mask_small(small_top_left(2):small_bottom_right(2),small_top_left(1):small_bottom_right(1));
  
  %% Segmentation of the image
  labels = watershed_segmentation(left, right);
  N_segments = max(labels(:)); 
  
  %% Check which segments are (mostly) inside of the "blob"
  segment_area = ones(1, N_segments);
  prototype = mask_small;
  for i = 1:N_segments
      region_pixels = labels(:) == i;
      in_prototype = sum(prototype(region_pixels));
      segment_area(i) = in_prototype / sum(region_pixels);
  end
  
  %% Generate mask
  mask_big = zeros(image_size);
  
  %% Dilate mask
  se = strel('disk',1);
  mask = imdilate(mask,se);
=======
  if N_segments > 1  
      %Lrgb = label2rgb(labels,'jet','w','shuffle');
      %figure
      %imshow(Lrgb * 0.3 + left(:,:,1:3) * 0.7);
      
      mask_small = ismember(labels, find(segment_area > 0.8)) .* mask_small;
      
      % Dilate mask
      se = strel('disk', 5);
      mask_small = imdilate(mask_small,se);
      
      %figure
      %imshow(uint8(mask_small) .* left(:,:,1:3));
      
      % Insert small mask into big mask
      total_translation = top_left + small_top_left - [2 2];
      mask_big(total_translation(2):total_translation(2)+size(mask_small,1)-1,total_translation(1):total_translation(1)+size(mask_small,2)-1) = mask_small;
  end       
  
  mask = mask_big;  
end
