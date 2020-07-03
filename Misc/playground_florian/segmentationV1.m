function [mask] = segmentationV1(left,right)
    % Add function description here
    % V1.0: For detecting single persons only
    %
    %% Compute difference image for each color channel
    % Initialize difference image with first image of each tensor
    diff_left  = left(:,:,1:3);
%     diff_right = right(:,:,1:3);
    
    % Iterate over all all remaining images in the tensor
    N = (size(left, 3)/3) - 1;
    for i = 1:N
        % Compute the difference image as the difference of each image from the first image
        diff_left  = uint8( abs( int8(diff_left) - int8(left(:,:, (1:3)+(3*i))) ) );
%         diff_right = uint8( abs( int8(diff_right) - int8(right(:,:, (1:3)+(3*i))) ) );
    end 
    
    % +++++++++++ CHANGE THIS IN FUTURE +++++++++++++++++
    % For even N, compute the difference once more (does not work otherwise)
    if mod(N, 2) == 0
        diff_left  = uint8( abs( int8(diff_left) - int8(left(:,:, (1:3)+(3*i))) ) );
%         diff_right = uint8( abs( int8(diff_right) - int8(right(:,:, (1:3)+(3*i))) ) );
    end
    
    % Convert to grayscale
    diff_left = rgb2gray(diff_left);
%     diff_right = rgb2gray(diff_right);

    % Convert image to binary image
    diff_left_bin  = imbinarize(diff_left);
%     diff_right_bin = imbinarize(diff_right);
    
    % Apply median filter to each channel to get remove of salt & pepper noise
    % Test show, applying 3 times is best
    diff_left_bin = medfilt2(diff_left_bin, [2,2]);
%     diff_right_bin = medfilt2(diff_right_bin, [2,2]);   
    
    % Find position of non-zero entries in the difference images
    [row_l, col_l] = find(diff_left_bin);   % for left difference image
%     [row_r, col_r] = find(diff_right_bin);  % for right difference image
    % Sort the rows in ascending order
    [row_l, idx_l] = sort(row_l);
%     [row_r, idx_r] = sort(row_r);
    % Sort columns according to rows
    col_l = col_l(idx_l);    
%     col_r = col_r(idx_r);
    % Get all unique entries in row_l and row_r
    row_l_unique = unique(row_l);
%     row_r_unique = unique(row_r);
    
    % Iterate over each row that contains a non-zero entry in the binary
    % difference images
    for i = 1:length(unique((row_l)))
        % Check which entries in row_l correspond to the current row
        entries = row_l == row_l_unique(i);
        % Check all non-zero entries within the row and save the most left
        % point (mlp) and the most right point (mrp)
        mlp_l(i) = min(col_l(entries));
        mrp_l(i) = max(col_l(entries));
        % Check if both points have the same value
        if mlp_l(i) == mrp_l(i) && i > 1
            if mlp_l(i) - mlp_l(i-1) < mrp_l(i) - mrp_l(i-1)
                mrp_l(i) = mrp_l(i-1);
            else
                mlp_l(i) = mlp_l(i-1);
            end
        end
    end
    % Smoothen the polygon
    [mlp_l, mrp_l] = smoothenPolygon(mlp_l, mrp_l, row_l);
%     % Repeat the process for the right difference image
%     for i = 1:length(unique((row_r)))
%         entries = (row_r == row_r_unique(i));
%         mlp_r(i) = min(col_r(entries));
%         mrp_r(i) = max(col_r(entries));
%     end
%     [mlp_r, mrp_r] = smoothenPolygon(mlp_r, mrp_r, row_r);
    % For both difference images, define a polygon around the non-zero
    % entries using the previously found mlp and mrp
    y_l = [row_l_unique(end:-1:1); row_l_unique; row_l_unique(end)];
    x_l = [mlp_l(end:-1:1), mrp_l, mlp_l(end)].';
%     y_r = [row_r_unique(end:-1:1); row_r_unique; row_r_unique(end)];
%     x_r = [mlp_r(end:-1:1), mrp_r, mlp_r(end)].';
    
    % Create mask out of polygon
    mask = poly2mask(x_l, y_l, 600, 800);
    
    mask = fillPolygon(mask, 30);
    
    % Plot results
    figure
    imshow(0.5*im2double(rgb2gray(left(:,:,1:3))) + 0.5*mask);
  
end

function [mlp, mrp] = smoothenPolygon(mlp, mrp, row)
    % Compute mean 
    mean_val = mean([mlp, mrp]);
    % Repeat 5 times
    for j = 1:5   
        for i = 2:length(unique((row)))-1
            if mrp(i) - mean_val > mean_val - mlp(i)
                tmp =  mean([mlp(i-1), mean_val - (mrp(i) - mean_val), mlp(i+1)]);
                if tmp > 0
                    mlp(i) = min(mlp(i), tmp);
                end
            else
                tmp = mean([mrp(i-1), mean_val - (mean_val - mlp(i)), mrp(i+1)]);
                if tmp < 800
                    mrp(i) = max(mrp(i), tmp);
                end
            end
        end
    end
end

function mask_new = fillPolygon(mask, a)
% mask: current mask, type: logical
% rad : length of square

% Transform rad to even number
if mod(a, 2) == 1 
    a = a - 1;
end
% Pad image
mask_tmp = zeros(size(mask) + a);
% Place original mask inside mask_tmp
mask_tmp(a/2 + 1 : end - a/2, a/2 + 1 : end - a/2) = logical(mask);

% Iterate over every pixel in mask
for i = 1:size(mask, 1)
    for j = 1:size(mask, 2)
        % Check if pixels in surroundings are also zero
        surr = mask_tmp(i : i + a, j: j + a);
        % Check how many percent of the pixels in the surrounding are
        % one
        perc = sum(surr, 'all')/numel(surr);
        % If more than 50% are one and the considered pixel is zero, set the pixel to one
        if mask_tmp(a/2 + i, a/2 + j) == 0 && perc > 0.7
            mask_tmp(a/2 + i, a/2 + j) = 1;
        % If less than 33% are one and the considered pixel is one, set the pixel to zero
        elseif mask_tmp(a/2 + i, a/2 + j) == 1 && perc < 0.3
            mask_tmp(a/2 + i, a/2 + j) = 0;
        end
    end   
end

% Get new mask
mask_new = mask_tmp(a/2 + 1 : end - a/2, a/2 + 1 : end - a/2);

end

