function ROIs = find_roi(tensor_l, tensor_r, scaling_factor, do_plot)
    if nargin < 4
        do_plot = false;
    end

    N = size(tensor_l, 3) - 1;
    img_width = size(tensor_l, 2);
    img_height = size(tensor_l, 1);
    
    % If we want to extend this function to return more than 1 ROI
    max_rois = 1;
    % ROIs contains { N x 1 is empty (logical), 2 x 2 x N boundary_box, 2 x n x N contour points }
    % for each ROI
    ROIs = cell(max_rois, 3);
    for i = 1:max_rois
        ROIs(i, :) = { false(N,1), zeros(2,2,N), cell(N,1) };
    end
    
    for i = 1:N
        I1 = tensor_l(:,:,i);
        I2 = tensor_l(:,:,i+1);
        
        %I1 = imgaussfilt(I1, 1);
        %I2 = imgaussfilt(I2, 1);
        
        I1 = I1 - sqrt(var(double(I1(:))));
        I2 = I2 - sqrt(var(double(I2(:))));
        
        tile_w = 10;
        tile_h = 10;
        ncc_matrix = correlation(I1,I2, [tile_w tile_h]);
        
        [rows, cols] = ind2sub(size(ncc_matrix), 1:numel(ncc_matrix));
        pts = [rows; cols];
        pts3d = [rows / size(ncc_matrix, 1);cols / size(ncc_matrix, 1);ncc_matrix(:)'];        
        
        [labels,codebook] = simple_k_means(pts3d, 2, [0.5,0.5;0.5,0.5;-1,1], 0, 3 );        
        [~, idx_foreground] = min(codebook(3,:));
                
        if do_plot
            figure
            I = zeros(size(ncc_matrix));
            I(labels == idx_foreground) = 1;
            subplot(2,2,1)
            imshow(I)
        end
        
        pts = pts(:,labels == idx_foreground);
        pts3d = pts3d(:,labels == idx_foreground);
        [core, border, noise] = simple_dbscan(pts3d(1:2,:),0.15,4);
                        
        I = zeros(size(ncc_matrix));
        I(sub2ind(size(I),pts(1,[core border noise]),pts(2,[core border noise]))) = 1;
        
        if do_plot
            subplot(2,2,2)
            imshow(I)
        end
        
        % Connect marked tiles with small distance
        se = strel(ones(4,1));
        I = imclose(I, se);
        
        if do_plot
            subplot(2,2,3)
            imshow(I)
        end
        
        % Find countours around "blobs"
        CC = bwconncomp(I);

        % If there are no contours continue with next frame
        if CC.NumObjects == 0
            is_empty = cell2mat(ROIs(1,1));
            is_empty(i) = true;
            ROIs(1,1) = { is_empty };
            continue
        end
        
        % Extract the biggest "blob"
        numPixels = cellfun(@numel,CC.PixelIdxList);
        [~,idx] = max(numPixels);
        pixels = CC.PixelIdxList{idx};
        [tile_rows, tile_cols] = ind2sub(size(I), pixels');
        
        pts2 = [tile_cols * tile_w; tile_rows * tile_h] - [tile_w / 2; tile_h / 2];
        
        % Scale to original size
        pts2 = pts2 / scaling_factor;
        
        % Boundary Box
        boundary_box = [ [ min(pts2(1,:)) min(pts2(2,:)) ]; ... % top-left
                       [ max(pts2(1,:)) max(pts2(2,:)) ] ];   % bottom-right
        boundary_boxes = cell2mat(ROIs(1,2));
        boundary_boxes(:,:,i) = boundary_box;
        ROIs(1,2) = { boundary_boxes };
        
        % Contour points
        contour = boundary(pts2(1,:)', pts2(2,:)', 1);
        contour_points = ROIs{1,3};
        contour_points{i} = { [pts2(1,contour); pts2(2,contour)] };
        ROIs(1,3) = { contour_points };
        
    end
end

