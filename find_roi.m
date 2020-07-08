function ROIs = find_roi(tensor_l_rgb, tensor_l_scaled_gray, scaling_factor, do_plot)
    if nargin < 4
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
     
    
    % Try to detect people in image
    if false%n_rois == 0
        
        % Extract first rgb image in original size
        I1 = tensor_l_rgb(:,:,1:3);      

        detector = peopleDetectorACF;

        [bounding_boxes,scores] = detect(detector,I1);

        for i = 1:length(scores)
            n_rois = n_rois + 1;

            boundary_box = [ bounding_boxes(i,1), bounding_boxes(i,2); ...
                    bounding_boxes(i,1) + bounding_boxes(i,3), bounding_boxes(i,2) + bounding_boxes(i,4) ];

            contour_points = zeros(2,0);

            ROIs(n_rois, :) = { boundary_box, contour_points };

            if n_rois == max_rois
                return;
            end
        end
        
    end
    
    % If no people found try 2nd approach
    if N > 0 && n_rois == 0
        
        % Extract first gray image in scaled size
        I1 = tensor_l_scaled_gray(:,:,1);  

        % Adjust brightness
        I1 = I1 - sqrt(var(double(I1(:))));

        % Storeage for foreground points
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

            [rows, cols] = ind2sub(size(ncc_matrix), 1:numel(ncc_matrix));
            pts = [rows; cols];
            pts3d = [rows / size(ncc_matrix, 1);cols / size(ncc_matrix, 1);ncc_matrix(:)'];        

            [labels,codebook] = simple_k_means(pts3d, 2, [0.5,0.5;0.5,0.5;-1,1], 0, 10 );        
            [ncc_foreground, idx_foreground] = min(codebook(3,:));
            
            if ncc_foreground > 0.25
                % The small correlation cluster still has a relatively
                % high correlation, its probably shadows or light
                % flickering
                idx_foreground = 0;
            end
            
            if do_plot
                figure
                I = zeros(size(ncc_matrix));
                I(labels == idx_foreground) = 1;
                subplot(1,2,1)
                imshow(I)
            end

            pts = pts(:,labels == idx_foreground);
            pts3d = pts3d(:,labels == idx_foreground);
            [core, border, noise] = simple_dbscan(pts3d(1:2,:),0.15,20);        

            pts_x = pts(1,[core border]);
            pts_y = pts(2,[core border]);
            
            if do_plot
                I = zeros(size(ncc_matrix));
                I(sub2ind(size(I),pts_x(:),pts_y(:))) = 1;
                subplot(1,2,2)
                imshow(I)
            end

            pts_all = [pts_all, [pts_x; pts_y]];
        end
        
        I = zeros(size(ncc_matrix));
        I(sub2ind(size(I),pts_all(1,:),pts_all(2,:))) = 1;
        
        if do_plot
            figure
            subplot(1,2,1)
            imshow(I)
        end
        
        
        % Connect marked tiles with small distance
        se = strel(ones(4,1));
        I = imclose(I, se);

        if do_plot
            subplot(1,2,2)
            imshow(I)
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

            pts2 = [tile_cols * tile_w; tile_rows * tile_h] - [tile_w / 2; tile_h / 2];

            % Scale to original size
            pts2 = pts2 / scaling_factor;

            % Boundary Box
            boundary_box = [ [ min(pts2(1,:)) min(pts2(2,:)) ]; ... % top-left
                           [ max(pts2(1,:)) max(pts2(2,:)) ] ];   % bottom-right


            % Contour points
            contour = boundary(pts2(1,:)', pts2(2,:)', 1);              
            contour_points = [pts2(1,contour); pts2(2,contour)];
        
            n_rois = n_rois + 1;
            ROIs(n_rois, :) = { boundary_box, contour_points };
            
        end
    
    end   
          
    
    % Remove unused ROIs
    ROIs = ROIs(1:n_rois,:);
end