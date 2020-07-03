function [mask] = segmentation(left,right)
  N = size(left,3) / 3;
  img_width = size(left, 2);
  img_height = size(left, 1);
  
  %% Scale down input images
  scaling_factor = 0.5;  
  scaled_size = ceil([img_height img_width] * scaling_factor);
  scaled_left = uint8(zeros([scaled_size, N*3]));
  scaled_right = uint8(zeros([scaled_size, N*3]));
  
  for i = 1:N
      img_input = left(:,:,(1:3) + ((i-1) * 3));
      img_scaled = imresize(img_input, scaling_factor, 'nearest');
      w = size(img_scaled, 2);
      h = size(img_scaled, 1);
      scaled_left(1:h,1:w,(1:3) + ((i-1) * 3)) = img_scaled;
      img_input = right(:,:,(1:3) + ((i-1) * 3));
      img_scaled = imresize(img_input, scaling_factor, 'nearest');
      scaled_right(1:h,1:w,(1:3) + ((i-1) * 3)) = img_scaled;
  end
  
  
  %% Find region of interest
  [~, top_left_roi, bottom_right_roi]  = find_roi(scaled_left, scaled_right, [80, 60]);
  
  I = zeros(size(scaled_left, 1), size(scaled_left, 2));
  I(top_left_roi(2):bottom_right_roi(2),top_left_roi(1):bottom_right_roi(1)) = 1;
  %figure
  %imshow(uint8(I*255) *0.3 + scaled_left(:,:,1:3) * 0.7);
  
  %% Remove everything not in the ROI  
  scaled_left = scaled_left(top_left_roi(2):bottom_right_roi(2),top_left_roi(1):bottom_right_roi(1), :);
  scaled_right = scaled_right(top_left_roi(2):bottom_right_roi(2),top_left_roi(1):bottom_right_roi(1), :);
  
  %% Search for a more detailed ROI
  tile_w = 5;
  tile_h = 5;
  [roi_detail, ~, ~] = find_roi(scaled_left, scaled_right, [tile_w tile_h], 0);
  
  %figure
  %imshow(roi_detail);
  
  % Remove isolated pixels
  roi_detail = bwareaopen(roi_detail, 2);
  
  % Connect marked tiles with small distance
  se = strel(ones(5,2));
  I = imclose(roi_detail, se);
  
  %figure
  %imshow(I);
  
  % Find countours around "blobs"
  CC = bwconncomp(I);
  
  % If there are no contours leave function
  if CC.NumObjects == 0
      mask = zeros(img_height, img_width);
      return
  end
  
  % Extract the biggest "blob"
  numPixels = cellfun(@numel,CC.PixelIdxList);
  [~,idx] = max(numPixels);
  pixels = CC.PixelIdxList{idx};
  [rows, cols] = ind2sub(size(roi_detail), pixels');
  
  % Convert tile coordinates to pixel coordinates
  rows = rows * tile_h - tile_h / 2;
  cols = cols * tile_w - tile_w / 2;
  
  % Translate pixel coordinates into scaled image coordinates
  %rows = rows + top_left_roi(2) - 1;
  %cols = cols + top_left_roi(1) - 1;
  
  % Rescale pixel coordinates into original image coordinates
  rows = round(rows / scaling_factor);
  cols = round(cols / scaling_factor);
  
  % Fill polygon area covering biggest "blob"
  contour = boundary(cols', rows', 0.3);
  mask_detail = zeros(ceil([size(scaled_left, 1) / scaling_factor, size(scaled_left, 2) / scaling_factor]));
  mask_detail = roipoly(mask_detail,cols(contour)',rows(contour)');
  
  %% Remove everything not in the detailed ROI
  [top_left_detail, bottom_right_detail] = generate_boundarybox(mask_detail);
  
  mask_detail = mask_detail(top_left_detail(2):bottom_right_detail(2),top_left_detail(1):bottom_right_detail(1));
  
  %% Extract detailed area from original image
  translation = top_left_detail + top_left_roi / scaling_factor - [2 2];
  translation = floor(translation);
  
  left_detail = left(1 + translation(2):translation(2) + size(mask_detail, 1),1 + translation(1):translation(1) + size(mask_detail, 2), 1:3);
  
  %figure; 
  %imshow(uint8(mask_detail*255) * 0.3 + left_detail * 0.7)
  
  %% Segmentation of the detailed image area
  labels = watershed_segmentation(left_detail);
  
  %Lrgb = label2rgb(labels,'jet','w','shuffle');
  %figure
  %imshow(Lrgb * 0.3 + left_detail * 0.7);
  %figure
  %imshow(Lrgb - uint8(~mask_detail)*150);
  
  %% Check which segments are (mostly) inside of the mask
  N_segments = max(labels(:));
  segment_area = zeros(1, N_segments);
  segment_weight = zeros(1, N_segments);
  for i = 1:N_segments
      region_pixels = labels(:) == i;
      in_mask = nnz(mask_detail(region_pixels));
      segment_weight(i) = in_mask / nnz(mask_detail);
      segment_area(i) = in_mask / nnz(region_pixels);
  end
  
  %% Remove segments which are overlaping with the mask too much
  if N_segments > 1
    mask_detail = ismember(labels, find(segment_area > 0.8 | segment_weight > 0.20)) .* mask_detail;
    
    % Dilate mask to remove ridge lines
    se = strel('disk', 1);
    mask_detail = imdilate(mask_detail,se);     
  end
  
  %% Generate foreground mask
  mask = zeros(img_height, img_width);
  
  mask(1 + translation(2):translation(2) + size(mask_detail, 1),1 + translation(1):translation(1) + size(mask_detail, 2)) = mask_detail;
  
end
