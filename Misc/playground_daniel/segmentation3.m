function [mask] = segmentation3(left,right)
  N = size(left,3) / 3 - 1;
    
  
  %% Segmentation of the image
  I = rgb2gray(left(:,:,1:3));
  labels = watershed_segmentation(left, right);
  Lrgb = label2rgb(labels,'jet','w','shuffle');
  figure
  imshow(Lrgb .* 0.3 + 0.7 * I )  
  
  %% Determine correlations  
  N_segments = max(labels(:));
  segment_correlations = zeros(N_segments, N);
  for i = 1:N_segments
      segment_pixels = find(labels == i);
      for j = 1:N
          I2 = rgb2gray(left(:,:, (1:3) + (3*j)));
          pixel_values1 = I(segment_pixels);
          pixel_values2 = I2(segment_pixels);
          w1 = normalize_window(pixel_values1);
          w2 = normalize_window(pixel_values2);
          % Calculate difference
          tr = (w1(:))' * w2(:);
          ncc = 1/(numel(w1) - 1) * tr;
          segment_correlations(i,j) = ncc;
      end      
  end
  
  correlation_variance = zeros(N,1);
  for i = 1:N
      v = segment_correlations(:, i);
      correlation_variance(i) = var(v);
  end
  
  segment_correlations = sum(segment_correlations')';
  
  mask = ismember(labels, find(segment_correlations < 0.75));
  
  %% Dilate mask
  se = strel('disk',1);
  mask = imdilate(mask,se);
  figure
  imshow(mask)
end
