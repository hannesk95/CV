function [roi, top_left, bottom_right] = find_roi(I1, I2, tile_size, threshold)
    I1 = rgb2gray(I1);
    I2 = rgb2gray(I2);
    
    %% Find dynamic regions
    kx = size(I1, 2) / tile_size(1);
    ky = size(I1, 1) / tile_size(2);
    rx = ceil(kx) * tile_size(1) - size(I1, 2) + 1;
    ry = ceil(ky) * tile_size(2) - size(I1, 1) + 1;
    t1 = (1 - rx / 2) : tile_size(1) : (size(I1, 2) + rx / 2 - tile_size(1));
    t2 = (1 - ry / 2) : tile_size(2) : (size(I1, 1) + ry / 2 - tile_size(2)); 
    ncc_matrix = zeros(length(t2), length(t1));
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
            ncc_matrix(tile_y, tile_x) = ncc;
       end
    end
    
    if nargin < 4
        threshold = mean(ncc_matrix(:));
    end    
    roi = ncc_matrix < threshold;
    
    [top_left, bottom_right] = generate_boundarybox(roi);
    
    top_left = ceil([ t1(top_left(1)), t2(top_left(2)) ]);
    top_left = max(top_left, [1 1]);
    bottom_right = ceil([ t1(bottom_right(1)) + tile_size(1), t2(bottom_right(2)) + tile_size(2) ]);
    bottom_right = min(bottom_right, size(I1'));
end
