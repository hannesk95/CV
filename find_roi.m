function [roi, top_left, bottom_right] = find_roi(left, right, tile_size, threshold)
    N = size(left,3) / 3 - 1;
    I1 = left(:,:, 1:3);
    I2 = left(:,:, (1:3) + N * 3);
    I1 = rgb2gray(I1);
    I2 = rgb2gray(I2);
    image_size = size(I1);
    
    %% Find dynamic regions
    roi = zeros(size(I1));
    %tile_size = [floor(size(I1, 2) / 5), floor(size(I1, 1) / 5)];
    kx = size(I1, 2) / tile_size(1);
    ky = size(I1, 1) / tile_size(2);
    rx = ceil(kx) * tile_size(1) - size(I1, 2) + 1;
    ry = ceil(ky) * tile_size(2) - size(I1, 1) + 1;
    t1 = (1 - rx / 2) : tile_size(1) : (size(I1, 2) + rx / 2 - tile_size(1));
    t2 = (1 - ry / 2) : tile_size(2) : (size(I1, 1) + ry / 2 - tile_size(2)); 
    ncc_matrix = zeros(length(t1), length(t2));
    for tile_x = 1:length(t1)
       for tile_y = 1:length(t2)
           % calculate tile center position
            cx = t1(tile_x);
            cy = t2(tile_y);
            % calculate tile edge positions
            left = ceil(cx);
            right = left + tile_size(1) - 1;
            top = ceil(cy);
            bottom = top + tile_size(2) - 1;
            % Limit values
            if left < 1
                left = 1;
            end
            if right > size(I1, 2)
                right = size(I1, 2);
            end
            if top < 1
                top = 1;
            end
            if bottom > size(I1, 1)
                bottom = size(I1, 1);
            end
            % Get tile windows
            w1 = normalize_window(I1(top:bottom, left:right));
            w2 = normalize_window(I2(top:bottom, left:right));
            % Calculate difference
            tr = (w1(:))' * w2(:);
            ncc = 1/(numel(w1) - 1) * tr;
            ncc_matrix(tile_x, tile_y) = ncc;
            roi(top:bottom, left:right) = ones(size(w1)) * ncc;
       end
    end
    
    if nargin < 4
        threshold = mean(ncc_matrix(:));
    end    
    roi = roi < threshold;
    
    [top_left, bottom_right] = generate_boundarybox(roi);
end
