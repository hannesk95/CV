start_frame = 480;
imreader = ImageReader('C:\Users\Daniel\Desktop\Studium\Master\1. Semester\02 Computer Vision\Challenge\Datasets\P1E_S1', 1, 2, start_frame, 2)

[tensor_left, tensor_right] = imreader.next();

I1 = tensor_left(:,:,1:3);
I2 = tensor_left(:,:,4:6);
I1 = rgb2gray(I1);
I2 = rgb2gray(I2);

features_I1 = harris_detector(I1,'tile_size',50,'segment_length',9,'k',0.05,'min_dist',10,'N',20,'do_plot',true);
features_I2 = harris_detector(I2,'tile_size',50,'segment_length',9,'k',0.05,'min_dist',10,'N',20,'do_plot',true);
correspondences = point_correspondence(I1,I2,features_I1,features_I2,'window_length',25,'min_corr', 0.9,'do_plot',true);

x1 = correspondences(1:2, :);
x2 = correspondences(3:4, :);

corr = correspondences;
corr(:, all(x1 == x2)) = [];


correspondences_robust = F_ransac(corr, 'tolerance', 0.05, 'p', 0.8);


figure
imshow(I1); 
hold on 
h = imshow(I2); 
set(h, 'AlphaData', 0.5) 
for n = 1:size(correspondences_robust, 2)
    X = correspondences_robust(1:2, n);
    Y = correspondences_robust(3:4, n);  
    x = [X(1), Y(1)];
    y = [X(2), Y(2)];
    plot(x, y, 'g', 'LineWidth', 3);
    plot(X(1), X(2), 'rx', 'LineWidth', 3, 'MarkerSize', 10);
    plot(Y(1), Y(2), 'bx', 'LineWidth', 3, 'MarkerSize', 10);
end

K = diag([1, 1, 1]);
E = epa(correspondences_robust);
[T1, R1, T2, R2, U, V] = TR_from_E(E);
[T, R, lambda, M1, M2] = reconstruction(T1, T2, R1, R2, correspondences, K);

lambda = lambda(:, 1);
threshold = 10^-3;
near = find(lambda < threshold);
far = find(lambda > threshold);

figure
imshow(I1); 
hold on 
for n = 1:size(near)
    i = near(n);
    X = correspondences(1:2, i); 
    x = X(1);
    y = X(2);
    plot(x, y, 'gx', 'LineWidth', 3);
end
for n = 1:size(far)
    i = far(n);
    X = correspondences(1:2, i); 
    x = X(1);
    y = X(2);
    plot(x, y, 'rx', 'LineWidth', 3);
end

function [T1, R1, T2, R2, U, V] = TR_from_E(E)
    % This function calculates the possible values for T and R 
    % from the essential matrix
    [U,Sigma,V] = svd(E);
    
    % Ensure SO(3)
    if det(V) < 0
        V = V * diag([1,1,-1]);
    end
    if det(U) < 0
        U = U * diag([1,1,-1]);
    end
    
    M1 =  [  0, -1,  0; ...
             1,  0,  0; ...
             0,  0,  1 ];
    M2 =  [  0,  1,  0; ...
            -1,  0,  0; ...
             0,  0,  1 ];
                  
    R1 = U * M1' * V';
    R2 = U * M2' * V';
    T1_hat = U * M1 * Sigma * U';
    T2_hat = U * M2 * Sigma * U';
    T1 = [ T1_hat(3,2); T1_hat(1,3); T1_hat(2,1)];
    T2 = [ T2_hat(3,2); T2_hat(1,3); T2_hat(2,1)];
end

function [T, R, lambda, M1, M2] = reconstruction(T1, T2, R1, R2, correspondences, K)
    %% Preparation from task 4.2
    % T_cell    cell array with T1 and T2 
    % R_cell    cell array with R1 and R2
    % d_cell    cell array for the depth information
    % x1        homogeneous calibrated coordinates
    % x2        homogeneous calibrated coordinates
    N = size(correspondences, 2);
        
    x1 = ones(3, N);
    x2 = ones(3, N);
    x1(1:2, :) = correspondences(1:2, :);
    x2(1:2, :) = correspondences(3:4, :);
    
    x1 = inv(K) * x1;
    x2 = inv(K) * x2;
        
    T_cell = { T1, T2, T1, T2 };
    R_cell = { R1, R1, R2, R2 };
    d_cell = cell(1, 4);
    d_cell(:) = { zeros(N,2) };   
    
    %% Reconstruction
    N = size(correspondences, 2);
    best_i = 0;
    max_d = -inf;
    for i = 1:4
        T_guess = cell2mat(T_cell(i));
        R_guess = cell2mat(R_cell(i));
        
        M1 = zeros(3, N * (N+1));
        M1(:, 1:N+1:end-N) = cross(x2, R_guess * x1);
        M1(:, end-N+1:end) = cross(x2, T_guess*ones(1, N));
        M1 = reshape(M1, [N * 3, N+1]);
        
        [U, Sigma, V] = svd(M1);       
        d1 = V(1:end,end);
        d1 = d1 / d1(end);
        
        M2 = zeros(3, N * (N+1));
        M2(:, 1:N+1:end-N) = cross(x1, R_guess' * x2);
        M2(:, end-N+1:end) = -cross(x1, (R_guess' * T_guess)*ones(1, N));
        M2 = reshape(M2, [N * 3, N+1]);
        
        [U, Sigma, V] = svd(M2);       
        d2 = V(1:end,end);
        d2 = d2 / d2(end);
        
        lambda1 = d1(1:end-1);
        lambda2 = d2(1:end-1);
        
        d = max(sum(lambda1), sum(lambda2));
        if d > max_d
            best_i = i;
            max_d = d;
        end
        
        d_cell(i) = { [lambda1, lambda2] };        
    end
    
    T = cell2mat(T_cell(best_i));
    R = cell2mat(R_cell(best_i));
    lambda = cell2mat(d_cell(best_i));
end