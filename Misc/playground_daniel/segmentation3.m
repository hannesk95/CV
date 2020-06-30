function [mask] = segmentation3(left,right)
  N = size(left,3) / 3 - 1;
  
%   
% %   i1 = left(:,:,1:3);
% %   i2 = left(:,:,4:6);
%   i1 = zeros(600,800,3);
%   i2 = zeros(600,800,3);
%   %% calc edge delta
%   edges_delta = edge(rgb2gray(i1) ,'Canny') - edge(rgb2gray(i2) ,'Canny');
%   
%   
%   %% Create overestimating mask
% [delta] = getDifference(i1,i2);
% [maskOverestimating] = getOverestimatingMask(delta, 31, 3);
% 
% 
%   %% Clean up delta
% contours = bwboundaries(edges_delta, 'noholes');
% 
% th = 30;
% remove = zeros(size(contours));
% for i = 1:length(contours)
%     c = contours{i};
%     if(size(c, 1) < th)
%         remove(i) = 1;
%     end
% end
% contours(logical(remove), :) = [];
% 
% contours_image = zeros(size(edges_delta));
% 
% for i = 1:length(contours)
%     c = contours{i};
%     for j = 1:size(c, 1)
%         contours_image(c(j,1), c(j,2)) = 1;
%     end
% end
% 
% %% Remove "wrong edges"
% masked_contours_image = contours_image;
% masked_contours_image(~maskOverestimating) = 0;
% 
% 
% imshow(masked_contours_image)
% 


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
