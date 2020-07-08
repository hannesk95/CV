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

        % Adjust brightness
        I1 = I1 - sqrt(var(double(I1(:))));

        % Storeage for foreground tiles
        pts_all = [];

        % NCC tile size
        tile_w = 10;
        tile_h = 10;

        for i = 1:N
            
            % Extract consecutive image
            I2 = tensor_l_scaled_gray(:,:,i+1);

            % Adjust brightness
            I2 = I2 - sqrt(var(double(I2(:))));

            % Calculate cross correlation between images
            ncc_matrix = correlation(I1,I2, [tile_w tile_h]);
            
            % Get the row and column of every tile in the ncc matrix
            [rows, cols] = ind2sub(size(ncc_matrix), 1:numel(ncc_matrix));
            pts = [rows; cols];
            
            % Add the ncc value as 3rd dimension to every point and
            % normalize the value ranges
            pts3d = [rows / size(ncc_matrix, 1);cols / size(ncc_matrix, 1);ncc_matrix(:)'];        

            % Cluster points based on their 3d position into two clusters,
            % use two initial codebook vectors centered in x/y direction
            % and laying at the edges of the z directions
            [labels,codebook] = simple_k_means(pts3d, 2, [0.5,0.5;0.5,0.5;-1,1], 0, 10 );   
            
            % The cluster which has the smallest mean in the 3rd dimension
            % (ncc value dimension) is assumed to be foreground
            [ncc_foreground, idx_foreground] = min(codebook(3,:));
            
            if ncc_foreground > 0.25
                % The small correlation cluster still has a relatively
                % high correlation, its probably shadows or light
                % flickering
                idx_foreground = 0;
            end
            
            if do_plot
                % Plot the detected foreground tiles
                figure
                I = zeros(size(ncc_matrix));
                I(labels == idx_foreground) = 1;
                subplot(1,2,1)
                imshow(I)
                title('Detected foreground tiles')
            end

            % Keep only the tile positions of foreground tiles
            pts = pts(:,labels == idx_foreground);
            pts3d = pts3d(:,labels == idx_foreground);
            
            % Use a distance based scan on the x/y plane to get rid of
            % noise which maybe has been assigned to the foreground cluster
            [core, border, noise] = simple_dbscan(pts3d(1:2,:),0.15,20);        

            % We keep the core and border points
            pts_x = pts(1,[core border]);
            pts_y = pts(2,[core border]);
            
            if do_plot
                % Plot the foreground tiles which are cleaned from outliers
                I = zeros(size(ncc_matrix));
                I(sub2ind(size(I),pts_x(:),pts_y(:))) = 1;
                subplot(1,2,2)
                imshow(I)
                title('Detected foreground tiles w.o. outliers')
            end

            % Add the detected foreground tiles to the storeage
            pts_all = [pts_all, [pts_x; pts_y]];
        end
        
        % Generate a binary image from all detected foreground tiles
        I = zeros(size(ncc_matrix));
        I(sub2ind(size(I),pts_all(1,:),pts_all(2,:))) = 1;
        
        if do_plot
            % Plot the accumulated foreground tiles image
            figure
            subplot(1,2,1)
            imshow(I)
            title('All detected foreground tiles w.o. outliers')
        end
        
        
        % Connect marked tiles with small distance
        se = strel(ones(4,1));
        I = imclose(I, se);

        if do_plot
            % Plot the connected tiles
            subplot(1,2,2)
            imshow(I)
            title('Foreground tiles after closing')
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
            contour = boundary(pts2(1,:)', pts2(2,:)', 1);              
            contour_points = [pts2(1,contour); pts2(2,contour)];
        
            % Add region of Interest to ROI array
            n_rois = n_rois + 1;
            ROIs(n_rois, :) = { boundary_box, contour_points };
            
        end
    
    end             
    
    % Remove unused ROIs
    ROIs = ROIs(1:n_rois,:);
end