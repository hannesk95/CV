function [mask] = segmentation()

    close all;
    clear;

    %% Read in images
    I1 = imread('00000674_C1.jpg');
    I2 = imread('00000675_C1.jpg');
    
    %% Convert to grayscale.
    I1gray = rgb2gray(I1);
    I2gray = rgb2gray(I2);
    
    %% Find features in both images
    features1 = harris_detector(I1gray, 'segment_length',9,'k',0.1,'min_dist',8,'N',80,'tile_size', 17);
    features2 = harris_detector(I2gray, 'segment_length',9,'k',0.1,'min_dist',8,'N',80,'tile_size', 17);
    
    figure;
    imshowpair(I1, I2, 'montage');
    hold on;
    [~, x_image, ~] = size(I1);
    x1 = features1(1,:);
    y1 = features1(2,:);
    plot(x1,y1,'go');
    x2 = features2(1,:) + x_image;
    y2 = features2(2,:);
    plot(x2,y2,'ro');
    title('Features in both images');
    hold off;
    
    %% Find correspondences
    correspondences = point_correspondence(I1gray,I2gray,features1,features2,'window_length',19,'min_corr', 0.90,'do_plot',false);
    
    figure;
    showMatchedFeatures(I1, I2, correspondences(1:2,:).', correspondences(3:4,:).');
    legend('correspondences in I1', 'correspondences in I2');
    title('Correspondences');
    
    %% Process correspondences
    N = size(correspondences,2);
%     min = Inf;
%     max = 0;
%     mean = 0;
%     
%     for i = 1 : N
%         dist = sqrt((correspondences(1,i)-correspondences(3,i))^2+(correspondences(2,i)-correspondences(4,i))^2);
%         mean = mean + dist;
%         if dist < min
%             min = dist;
%         end
%         if dist > max
%             max = dist;
%         end       
%     end
%     
%     mean = mean/N;
    
    foreground = zeros(2, N);
    background = zeros(2, N);
    nFG = 0;
    nBG = 0;
    
    thresh = 4;
    thresh2 = 15;
    
    for i = 1 : N
        dist = sqrt((correspondences(1,i)-correspondences(3,i))^2+(correspondences(2,i)-correspondences(4,i))^2);
        if dist > thresh && dist < thresh2
            nFG = nFG + 1;
            foreground(:,nFG) = correspondences(1:2, i);
        else
            nBG = nBG + 1;
            background(:,nBG) = correspondences(1:2, i);
        end
    end
    
    foreground = foreground(:,1:nFG);
    background = background(:,1:nBG);
    
    figure;
    imshow(I1);
    hold on;
    x1 = foreground(1,:);
    y1 = foreground(2,:);
    plot(x1,y1,'go');
    x2 = background(1,:);
    y2 = background(2,:);
    plot(x2,y2,'ro');
    title('Features mapped as background (red) and foreground (green)');
    hold off;
    
    %% 
    
    L = superpixels(I1,500);

    foregroundX = foreground(1,:);
    foregroundY = foreground(2,:);
    foregroundInd = sub2ind(size(I1),foregroundY,foregroundX);

    backgroundX = background(1,:);
    backgroundY = background(2,:);
    backgroundInd = sub2ind(size(I1),backgroundY,backgroundX);

    BW = lazysnapping(I1,L,foregroundInd,backgroundInd);
    
    figure;
    imshow(labeloverlay(I1,BW,'Colormap',[0 1 0]))
    
end


function features = harris_detector(input_image, varargin)
    % In this function you are going to implement a Harris detector that extracts features
    % from the input_image.
    
    % Input parser
    defaultSegmentLength = 15;
    defaultK = 0.05;
    defaultTau = 10^6;
    defaultDoPlot = false;
    defaultMinDist = 20;
    defaultTileSize = [200 200];
    defaultN = 5;

    p = inputParser;
    validSegmentLength = @(x) isnumeric(x) && mod(x,2) && (x > 1);
    validK = @(x) (x>=0) && (x<=1);
    validTau = @(x) isnumeric(x) && (x > 0);
    validDoPlot = @(x) islogical(x);
    validMinDist = @(x) isnumeric(x) && (x >= 1);
    validTileSize = @(x) isnumeric(x);
    validN = @(x) isnumeric(x) && (x >= 1);
    
    addParameter(p,'segment_length',defaultSegmentLength,validSegmentLength);
    addParameter(p,'k',defaultK,validK);
    addParameter(p,'tau',defaultTau,validTau);
    addParameter(p,'do_plot',defaultDoPlot,validDoPlot);
    addParameter(p,'min_dist', defaultMinDist, validMinDist);
    addParameter(p,'tile_size', defaultTileSize, validTileSize);
    addParameter(p,'N', defaultN, validN);
    
    parse(p,varargin{:});
    
    segment_length = p.Results.segment_length; 
    k = p.Results.k;
    tau = p.Results.tau;
    do_plot = p.Results.do_plot;
    min_dist = p.Results.min_dist;
    tile_size = p.Results.tile_size;
    N = p.Results.N;
    
    [sizeValidX, sizeValidY] = size(defaultTileSize);
    [sizeInputX, sizeInputY] = size(tile_size);
    
    if (sizeValidX ~= sizeInputX) || (sizeValidY ~= sizeInputY)
        tile_size = defaultTileSize;
    end
    
    % Preparation for feature extraction
    % Check if it is a grayscale image
    [~, ~, channels] = size(input_image);
    if channels ~= 1
        error('Image format has to be NxMx1')
    end
    
    % Convert to double
    input_image = double(input_image);
    
    % Approximation of the image gradient
    [Ix, Iy] = sobel_xy(input_image);
    
    % Weighting
    w = 1 : segment_length;
    center = (segment_length + 1)/2;
    i = w - center;
    sigma = segment_length/2;
    x = exp(-i.^2 / (2*sigma^2));
    C = 1/sum(x);
    w = C * exp(-i.^2/(2*sigma^2));
        
    % Harris Matrix G
    G11 = conv2(w,w,Ix.^2,'same');
    G22 = conv2(w,w,Iy.^2,'same');
    G12 = conv2(w,w,Ix.*Iy,'same');
            
    detG = G11.*G22 - G12.*G12;
    trG = G11 + G22;
    
    H = detG - k * trG.^2;
    
    % Feature extraction with the Harris measurement
    corners = H;
    
    [rowsH, columnsH] = size(H);
    
    for i = 1 : rowsH
        for j = 1 : columnsH
            if H(i,j) < tau
                corners(i,j) = 0;
            end
        end
    end
    
    [rowC, colC] = find(corners);
    features = [colC.'; rowC.'];
                
    % Feature preparation
    [rowsCor, colomnsCor] = size(corners);
    corners = [zeros(min_dist, colomnsCor+2*min_dist);
               zeros(rowsCor, min_dist) corners zeros(rowsCor, min_dist);
               zeros(min_dist, colomnsCor+2*min_dist)];    
    
    [~, sorted_index] = sort(corners(:), 'descend');
    nonZero = nnz(corners);
    sorted_index = sorted_index(1:nonZero);
        
    % Accumulator array
    tiles_in_colomn = ceil(size(input_image,1)/tile_size(1));
    tiles_in_row = ceil(size(input_image,2)/tile_size(2));
    acc_array = zeros(tiles_in_colomn, tiles_in_row);
    
    number_tiles = tiles_in_colomn * tiles_in_row;
    max_number_features = number_tiles * N; % N = max_number_features_per_tile
    
    features = zeros(2, min(max_number_features, size(sorted_index,1)));
        
    % Feature detection with minimal distance and maximal number of features per tile
    % get the pixel coordinated of the features
    [row_pixel, colomn_pixel] = ind2sub(size(corners), sorted_index);
    
    % get the tile coordinates of the features
    row_tile = ceil((row_pixel-min_dist) / tile_size(1));
    colomn_tile = ceil((colomn_pixel-min_dist) / tile_size(2));

    % get filter for min_dist
    Cake = cake(min_dist);
    
    number_features = 0;
    
    for i = 1 : size(sorted_index, 1)
        % check if corner has already been filtered out
        if corners(row_pixel(i), colomn_pixel(i)) == 0
            continue
        else
            % filter out all corners within min_dist
            corners(row_pixel(i)-min_dist:row_pixel(i)+min_dist, colomn_pixel(i)-min_dist:colomn_pixel(i)+min_dist) = corners(row_pixel(i)-min_dist:row_pixel(i)+min_dist, colomn_pixel(i)-min_dist:colomn_pixel(i)+min_dist) .* Cake;
        end
        
        % check for maximum features per tile
        if acc_array(row_tile(i), colomn_tile(i)) < N
            acc_array(row_tile(i), colomn_tile(i)) = 1 + acc_array(row_tile(i), colomn_tile(i));
            number_features = number_features + 1;
            features(:, number_features) = [colomn_pixel(i)-min_dist; row_pixel(i)-min_dist];
        end
    end
    
    features = features(:,1:number_features);
    
    % Plot
    if do_plot
        figure;
        imshow(input_image);
        hold on;
        [y_image, ~, ~] = size(input_image);
        x = features(1,:);
        y = y_image - features(2,:);
        plot(x,y,'o');
        hold off;
    end
end

function [Fx, Fy] = sobel_xy(input_image)
    % In this function you have to implement a Sobel filter 
    % that calculates the image gradient in x- and y- direction of a grayscale image.
    sobel_horizontal = [1 0 -1; 2 0 -2; 1 0 -1];
    sobel_vertical = [1 2 1; 0 0 0; -1 -2 -1];

    [rows, colomns] = size(input_image);
    Fx = zeros(rows, colomns); 
    Fy = zeros(rows, colomns);

    image_extended = zeros(rows+2, colomns+2);
    image_extended(2:rows+1, 2:colomns+1) = input_image;

    [i, j] = size(image_extended);
    
    for row = 2 : i-1
        for colomn = 2 : j-1
            for k = -1 : 1
                for l = -1 : 1
                    Fx(row-1, colomn-1) = Fx(row-1, colomn-1) + image_extended(row-k, colomn-l) * sobel_horizontal(k+2, l+2);
                    Fy(row-1, colomn-1) = Fy(row-1, colomn-1) + image_extended(row-k, colomn-l) * sobel_vertical(k+2, l+2);
                end
            end
        end
    end  
end

function Cake = cake(min_dist)
    % The cake function creates a "cake matrix" that contains a circular set-up of zeros
    % and fills the rest of the matrix with ones. 
    % This function can be used to eliminate all potential features around a stronger feature
    % that don't meet the minimal distance to this respective feature.
    Cake = zeros(min_dist*2+1, min_dist*2+1);
    center = min_dist+1;
    for row = 1 : (min_dist*2+1)
        for column = 1 : (min_dist*2+1)
            dist_x = abs(center-column);
            dist_y = abs(center-row);
            dist = sqrt(dist_x^2 + dist_y^2);
            if dist > min_dist
                Cake(row, column) = 1;
            end
        end
    end
    
    Cake = logical(Cake);
    
end

function cor = point_correspondence(I1, I2, Ftp1, Ftp2, varargin)
    % In this function you are going to compare the extracted features of a stereo recording
    % with NCC to determine corresponding image points.
    
    % Input parser
    defaultWindowLength = 25;
    defaultMinCorr = 0.95;
    defaultDoPlot = false;

    p = inputParser;
    validWindowLength = @(x) isnumeric(x) && mod(x,2) && (x > 1);
    validMinCorr = @(x) isnumeric(x) && (x > 0) && (x < 1);
    validDoPlot = @(x) islogical(x);
    addParameter(p,'window_length',defaultWindowLength,validWindowLength);
    addParameter(p,'min_corr',defaultMinCorr,validMinCorr);
    addParameter(p,'do_plot',defaultDoPlot,validDoPlot);
    parse(p,varargin{:});
   
    window_length = p.Results.window_length; 
    min_corr = p.Results.min_corr;
    do_plot = p.Results.do_plot;
    
    Im1 = double(I1);
    Im2 = double(I2);
        
    % Feature preparation
    % define the minimum distance if the feature pixel to the border
    min_dist = (window_length + 1) / 2;
    
    % get the number of rows and colomns of the pictures
    [rows, colomns] = size(I1);
    
    % initialization before processing features from image 1
    length_fpt1 = size(Ftp1,2);
    Ftp1_new = zeros(2,length_fpt1);
    no_pts1 = 0;
    
    % check every x-y-position of the features from image 1
    for i = 1 : length_fpt1
        if (Ftp1(1,i) < min_dist) || (Ftp1(1,i) > (colomns-min_dist)) || (Ftp1(2,i) < min_dist) || (Ftp1(2,i) > (rows-min_dist))
            % x or y position too close to image border -> don't use feature
        else
            % add feature to new list and increment counter
            no_pts1 = no_pts1 + 1;
            Ftp1_new(:,no_pts1) = Ftp1(:,i); 
        end
    end
    
    % assign the new relevant from the temporary array to the real one
    Ftp1 = Ftp1_new(:,1:no_pts1);
    
    % initialization before processing features from image 2
    length_fpt2 = size(Ftp2,2);
    Ftp2_new = zeros(2,length_fpt2);
    no_pts2 = 0;
    
    % check every x-y-position of the features from image 2
    for i = 1 : length_fpt2
        if (Ftp2(1,i) < min_dist) || (Ftp2(1,i) > (colomns-min_dist)) || (Ftp2(2,i) < min_dist) || (Ftp2(2,i) > (rows-min_dist))
            % x or y position too close to image border -> don't use feature
        else
            % add feature to new list and increment counter
            no_pts2 = no_pts2 + 1;
            Ftp2_new(:,no_pts2) = Ftp2(:,i); 
        end
    end
    
    % assign the new relevant from the temporary array to the real one
    Ftp2 = Ftp2_new(:,1:no_pts2);

    % Normalization
    half_window_size = (window_length-1) / 2;
    
    Mat_feat_1 = zeros(window_length*window_length, no_pts1);
    Mat_feat_2 = zeros(window_length*window_length, no_pts2);
    
    for i = 1 : no_pts1
        W = Im1(Ftp1(2,i)-half_window_size:Ftp1(2,i)+half_window_size, Ftp1(1,i)-half_window_size:Ftp1(1,i)+half_window_size);
        W_mean = mean(W,'all')*ones(window_length);
        W_std = std(W,0,'all');
        W_normalized = 1/W_std * (W-W_mean);
        Mat_feat_1(:,i) = W_normalized(:);
    end
    
    for i = 1 : no_pts2
        W = Im2(Ftp2(2,i)-half_window_size:Ftp2(2,i)+half_window_size, Ftp2(1,i)-half_window_size:Ftp2(1,i)+half_window_size);
        W_mean = mean(W,'all')*ones(window_length);
        W_std = std(W,0,'all');
        W_normalized = 1/W_std * (W-W_mean);
        Mat_feat_2(:,i) = W_normalized(:);
    end
    
    % NCC calculations
    NCC_matrix = zeros(size(Mat_feat_2,2),size(Mat_feat_1,2));
    
    for i = 1 : size(Mat_feat_2,2)
        for j = 1 : size(Mat_feat_1,2)
            W = reshape(Mat_feat_2(:,i),[window_length, window_length]);
            V = reshape(Mat_feat_1(:,j),[window_length, window_length]);
            NCC_matrix(i,j) = 1/(window_length*window_length-1) * trace(W.'*V);
            if NCC_matrix(i,j) < min_corr
                NCC_matrix(i,j) = 0;
            end
        end
    end
    
    [~, sorted_index] = sort(NCC_matrix(:), 'descend');
    nonZero = nnz(NCC_matrix);
    sorted_index = sorted_index(1:nonZero);
    
    % Correspondeces
    % get the rows and colomns out of sorted_index for the NCC_matrix
    [row_NCC, colomn_NCC] = ind2sub(size(NCC_matrix), sorted_index);
    
    [rowsNCC, ~] = size(NCC_matrix);
    
    cor = zeros(4,size(sorted_index,1));
    number_correspondences = 0;
    
    for i = 1 : size(sorted_index,1)
        % check if feature has not yet been matched
        if NCC_matrix(row_NCC(i), colomn_NCC(i)) ~= 0
            % set the NCC for this feature of image 1 to 0
            NCC_matrix(:,colomn_NCC(i)) = zeros(rowsNCC, 1);
            % save coordinates of corresponded features
            number_correspondences = number_correspondences + 1;
            cor(:,number_correspondences) = [Ftp1(:,colomn_NCC(i)); Ftp2(:,row_NCC(i))];
        end
    end
    
    cor = cor(:, 1:number_correspondences);
    
    % Visualize the correspoinding image point pairs
    if do_plot
        
        imshow(Im1);
        hold on;
        imshow(Im2); 
        alpha(0.5);
        [y_image, ~] = size(Im1);
        for i = 1 : size(cor,2)
            plot(cor(1,i), y_image - cor(2,i),'r*');
            plot(cor(3,i), y_image - cor(4,i),'g*');
            plot([cor(1,i), cor(3,i)], [y_image - cor(2,i), y_image - cor(4,i)], 'b');
        end
        hold off;
    end
end

function  [correspondences_robust, largest_set_F] = F_ransac(correspondences, varargin)
    % This function implements the RANSAC algorithm to determine 
    % robust corresponding image points
        
    %Input parser
    defaultEpsilon = 0.5;
    defaultP = 0.5;
    defaultTolerance = 0.01;

    par = inputParser;
    validEpsilon = @(x) isnumeric(x) && (x > 0) && (x < 1);
    validP = @(x) isnumeric(x) && (x > 0) && (x < 1);
    validTolerance = @(x) isnumeric(x);
    addParameter(par,'epsilon',defaultEpsilon,validEpsilon);
    addParameter(par,'p',defaultP,validP);
    addParameter(par,'tolerance',defaultTolerance,validTolerance);
    parse(par,varargin{:});
   
    epsilon = par.Results.epsilon; 
    p = par.Results.p;
    tolerance = par.Results.tolerance;
    
    x1_pixel = zeros(3,size(correspondences,2));
    x2_pixel = zeros(3,size(correspondences,2));
    
    for i = 1 : size(correspondences,2)
        x1_pixel(:,i) = [correspondences(1:2,i); 1];
        x2_pixel(:,i) = [correspondences(3:4,i); 1];
    end
        
    % RANSAC algorithm preparation
    k = 8;
    
    s = log(1-p) / log(1-(1-epsilon)^k);
    
    largest_set_size = 0;
    
    largest_set_dist = Inf;
    
    largest_set_F = zeros(3,3);
    
    % RANSAC algorithm
    correspondences_robust = zeros(4, size(correspondences,2));
    
    for i = 1 : s
        
        %%% STEP 1
        % choose k different indexes for randomly correspondences
        all_idx_different = 0;
        while ~all_idx_different
            idx = randi(size(correspondences,2), 1, k);
            all_idx_different = ~all(diff(sort(idx)));
        end
        
        % create new matrix for the k correspondences
        corr_k = zeros(4,k);
        for j = 1 : k
            corr_k(:,j) = correspondences(:,idx(j));
        end
        
        % calculate fundamental matrix with those k correspondences
        F = epa(corr_k);
        
        %%% STEP 2
        % calculate the sampson distance for all correspondences
        sd = sampson_dist(F, x1_pixel, x2_pixel);
        
        %%% STEP 3 & 4
        % initialize number of correspondences with low sd, consensus set and total distance
        number_corr = 0;
        consensus_set = zeros(4, size(correspondences,2));
        distances = 0;
        
        % loop through the correspondences
        for m = 1 : size(sd,2)
            % if sampson distance is below tolerance, than add the correspondence pair to the consensus set
            if sd(m) < tolerance
                number_corr = number_corr + 1;
                consensus_set(:,number_corr) = correspondences(:,m);
                distances = distances + sd(m);
            end
        end
        % delete all unfilled correspondences
        consensus_set = consensus_set(:,1:number_corr);
        
        %%% STEP 5 & 6
        % compare current set with largest set
        if (number_corr > largest_set_size) || (number_corr == largest_set_size && distances < largest_set_dist)
            % update the values for the largest_*
            largest_set_size = number_corr;
            largest_set_dist = distances;
            largest_set_F = F;
            correspondences_robust(:, 1:number_corr) = consensus_set;
        end
        
    end
    
    correspondences_robust = correspondences_robust(:, 1:largest_set_size);    
end

function sd = sampson_dist(F, x1_pixel, x2_pixel)
    % This function calculates the Sampson distance based on the fundamental matrix F
    e3_hat = [0, -1, 0; 1, 0, 0; 0, 0, 0];

    a = F*x1_pixel;
    a = x2_pixel.'*a;
    a = diag(a);
    a = a.*a;
    a = a.';
    b = e3_hat*F*x1_pixel;
    b = b(1,:).^2+b(2,:).^2+b(3,:).^2;
    c = x2_pixel.'*F*e3_hat;
    c = c.';
    c = c(1,:).^2+c(2,:).^2+c(3,:).^2;

    sd = a./(b+c);
end

function [EF] = epa(correspondences, K)
    % Depending on whether a calibrating matrix 'K' is given,
    % this function calculates either the essential or the fundamental matrix
    % with the eight-point algorithm.
        
    A = zeros(size(correspondences,2), 9);
    x1 = zeros(3, size(correspondences,2));
    x2 = zeros(3, size(correspondences,2));
    
    for i = 1 : size(correspondences,2)
        x1(:,i) = [correspondences(1:2, i); 1];
        x2(:,i) = [correspondences(3:4, i); 1];
        if exist('K', 'var')
            x1(:,i) = inv(K)*x1(:,i);
            x2(:,i) = inv(K)*x2(:,i);
        end
        kr = kron(x1(:,i),x2(:,i));
        kr = kr.';
        A(i,:) = kr;
    end
    
    [~,~,V] = svd(A);
        
    % Estimation of the matrices
    % G^S is the 9th vector of V from svd(A). Reshaping to 3x3
    G = reshape(V(:,9),[3,3]);
    
    % SVD of G
    [U_G, S_G, V_G] = svd(G);
    
    if exist('K','var')
        % as G is typically no essential matrix, set singular values manually: S11=S22=1 and S33=0
        S_G(1,1) = 1;
        S_G(2,2) = 1;
        S_G(3,3) = 0;
    else
        % as G is typically no fundamental matrix, set singular values manually: S33=0
        S_G(3,3) = 0;
    end
    
    % calculate essential matrix: E = U_G * S_G (manipulated) * V_G^T
    EF = U_G * S_G * V_G.';
end

function [T1, R1, T2, R2, U, V] = TR_from_E(E)
    % This function calculates the possible values for T and R 
    % from the essential matrix
    [U, S, V] = svd(E);
    if det(U) < 0
        U = U * diag([1 1 -1]);
    end
    if det(V) < 0
        V = V * diag([1 1 -1]);
    end
    
    R_Z1 = [0 -1 0; 1 0 0; 0 0 1];
    R_Z2 = [0 1 0; -1 0 0; 0 0 1];
    
    R1 = U * R_Z1.' * V.';
    R2 = U * R_Z2.' * V.';
    
    T1_Dach = U * R_Z1 * S * U.';
    T2_Dach = U * R_Z2 * S * U.';
    
    T1 = [T1_Dach(3,2); T1_Dach(1,3); T1_Dach(2,1)];
    T2 = [T2_Dach(3,2); T2_Dach(1,3); T2_Dach(2,1)];
end

function [T, R, lambda] = reconstruction(T1, T2, R1, R2, correspondences)    
    % Preparation
    T_cell = {T1, T2, T1, T2};
    R_cell = {R1, R1, R2, R2};
    
    N = size(correspondences, 2);
    
    d_cell = {zeros(N, 2), zeros(N, 2), zeros(N, 2), zeros(N, 2)};
    
    x1 = [correspondences(1:2, :); ones(1, N)];
    x2 = [correspondences(3:4, :); ones(1, N)];
    
    for i = 1 : N
        x1(:,i) = [correspondences(1:2, i); 1];
        x2(:,i) = [correspondences(3:4, i); 1];
%         x1(:,i) = inv(K)*x1(:,i);
%         x2(:,i) = inv(K)*x2(:,i);
    end
    
    % Reconstruction
    N = size(correspondences, 2);
    M1 = cell(1, 4);
    M2 = cell(1, 4);
    d = cell(1, 4);
    index = 0;
    for i = 1 : 4
        % Calculate M1
        r1 = cross(x2, R_cell{i}*x1);
        t1 = cross(x2, T_cell{i}*ones(1,N));
        M1{i} = zeros(3*N, N+1);
        for j = 1 : N
            M1{i}(3*j-2:3*j, j) = r1(:,j);
        end
        M1{i}(:,N+1) = reshape(t1, numel(t1), 1);
        
        % Calculate M2
        r2 = cross(x1, R_cell{i}.'*x2);
        t2 = cross(-x1, R_cell{i}.'*T_cell{i}*ones(1,N));
        M2{i} = zeros(3*N, N+1);
        for j = 1 : N
            M2{i}(3*j-2:3*j, j) = r2(:,j);
        end
        M2{i}(:,N+1) = reshape(t2, numel(t2), 1);
        
        d{i} = zeros(N+1, 2);
        
        % Calculate d1 by svd(M1)
        [~, ~, V1] = svd(M1{i});
        d{i}(:,1) = 1/V1(N+1, N+1) * V1(:,N+1);
        
        % Calculate d2 by svd(M2)
        [~, ~, V2] = svd(M2{i});
        d{i}(:,2) = 1/V2(N+1, N+1) * V2(:,N+1);
        
        d_cell{i} = d{i}(1:N, :);
        
        if sum(d_cell{i}(:,1)) > 0 && sum(d_cell{i}(:,2)) > 0
            index = i;
        end
    end
    
    T = T_cell{index};
    R = R_cell{index};
    lambda = d_cell{index};
end


