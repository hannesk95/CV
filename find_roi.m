function ROIs = find_roi(tensor_l_scaled_gray, scaling_factor, do_plot)
    if nargin < 3
        do_plot = false;
    end

    N = size(tensor_l_scaled_gray, 3) - 1;
    
    % If we want to extend this function to return more than 1 ROI
    max_rois = 1;
    % ROIs contains { 2 x 2 boundary_box, 2 x n contour points }
    % for each ROI
    ROIs = cell(max_rois, 2);
    
    % Number of found ROIs
    n_rois = 0;
    
    % If 1 or more consecutive images are available
    if N > 0 
        
        % Extract first gray image in scaled size
        I1 = tensor_l_scaled_gray(:,:,1); 

        % Storeage for ncc matricies
        ncc_matricies = cell(1,N);

        % NCC tile size
        tile_w = 15;
        tile_h = 15;

        for i = 1:N
            
            % Extract consecutive image
            I2 = tensor_l_scaled_gray(:,:,i+1);

            % Calculate cross correlation between images
            ncc_matrix = correlation(I1,I2, [tile_w tile_h]);
            
            % Save ncc matrix
            ncc_matricies{i} = ncc_matrix;
        end
        
        
        % Sum over all ncc matricies
        ncc_sum = zeros(size(ncc_matrix));
        for i = 1:N
            ncc_sum = ncc_sum + cell2mat(ncc_matricies(i));
        end
       
        % Compare ncc values with threshold
        I = ncc_sum <= 0.5;
        
        if do_plot
            figure
            subplot(2,2,1)
            imshow(I)
            title('Binarized ncc matrix')
        end
        
        % Remove isolated pixels/tiles
        I = bwareaopen(I, 5);        
        
        if do_plot
            subplot(2,2,2)
            imshow(I)
            title('Remove isolated pixels')
        end
        
        % Connect tiles which are close together
        se = strel('disk', 5);
        I = imclose(I,se);
        
        if do_plot
            subplot(2,2,3)
            imshow(I)
            title('Closing')
        end
        
        % Find countours around "blobs"
        CC = bwconncomp(I);

        % If there are contours
        if CC.NumObjects > 0

            % Extract the biggest "blob"
            numPixels = cellfun(@numel,CC.PixelIdxList);
            [~,idx] = max(numPixels);
            pixels = CC.PixelIdxList{idx};
            [tile_rows, tile_cols] = ind2sub(size(I), pixels');


            % Convert from tile positions back to pixel positions
            pts2 = [tile_cols * tile_w; tile_rows * tile_h] - [tile_w / 2; tile_h / 2];

            % Scale to original size
            pts2 = pts2 / scaling_factor;

            % Boundary Box
            boundary_box = [ [ min(pts2(1,:)) min(pts2(2,:)) ]; ... % top-left
                           [ max(pts2(1,:)) max(pts2(2,:)) ] ];   % bottom-right


            % Contour points
            contour = boundary(pts2(1,:)', pts2(2,:)', 0.3);              
            contour_points = [pts2(1,contour); pts2(2,contour)];
        
            % Add region of Interest to ROI array
            n_rois = n_rois + 1;
            ROIs(n_rois, :) = { boundary_box, contour_points };
            
        end
    
    end             
    
    % Remove unused ROIs
    ROIs = ROIs(1:n_rois,:);
end