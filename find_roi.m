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

        % Storeage for foreground tiles
        pts_all = [];

        % NCC tile size
        tile_w = 20;
        tile_h = 20;

        for i = 1:N
            
            % Extract consecutive image
            I2 = tensor_l_scaled_gray(:,:,i+1);

            % Calculate cross correlation between images
            ncc_matrix = correlation(I1,I2, [tile_w tile_h]);
            
            % Store ncc values as vector
            ncc_values = ncc_matrix(:)';      

            % Cluster points based on their ncc values into k clusters
            k = 5;
            ncc_min = min(ncc_values);
            ncc_max = max(ncc_values);            
            [labels,codebook] = simple_k_means(ncc_values, k, linspace(ncc_min,ncc_max,k), 0, 50 );    
            
            % Remove codebook entries for empty clusters
            codebook(isnan(codebook)) = [];
            
            % Clusters with small ncc are assumed to be foreground
            clusters = max(1, floor(numel(codebook) / 2));
            idx_foreground = 1:clusters;
            
            if codebook(idx_foreground(end)) > 0.35
                % The small correlation cluster still has a relatively
                % high correlation, its probably shadows or light
                % flickering
                idx_foreground = 0;
            end
            
            % Draw foreground tiles into binary image
            I = zeros(size(ncc_matrix));
            I(ismember(labels,idx_foreground)) = 1;
            
            if do_plot
                % Plot the detected foreground tiles
                figure                
                subplot(1,2,1)
                imshow(I)
                title('Detected foreground tiles')
            end
            
            % Remove isolated foreground tiles
            I = bwareaopen(I, 20);           
            
            if do_plot
                % Plot the foreground tiles which are cleaned from outliers
                subplot(1,2,2)
                imshow(I)
                title('Detected foreground tiles w.o. outliers')
            end

            % Add the detected foreground tiles to the storeage
            pts_all = [pts_all; find(I(:) ~= 0)];
        end
        
        % Generate a binary image from all detected foreground tiles
        I = zeros(size(ncc_matrix));
        I(pts_all) = 1;
        
        if do_plot
            % Plot the accumulated foreground tiles image
            figure
            subplot(1,2,1)
            imshow(I)
            title('All detected foreground tiles')
        end
        
        % Connect tiles which are close to each other
        I = imclose(I,2);
        
        if do_plot
            % Plot the accumulated foreground tiles image
            subplot(1,2,2)
            imshow(I)
            title('All foreground tiles after closing')
        end

        % Find pixel positions of foreground area(s)
        pixels = find(I(:) ~= 0);

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
            contour = boundary(pts2(1,:)', pts2(2,:)', 0.5);              
            contour_points = [pts2(1,contour); pts2(2,contour)];
        
            % Add region of Interest to ROI array
            n_rois = n_rois + 1;
            ROIs(n_rois, :) = { boundary_box, contour_points };
            
        end
    
    end             
    
    % Remove unused ROIs
    ROIs = ROIs(1:n_rois,:);
end