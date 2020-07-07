function [T, R, lambda, M1, M2] = reconstruction(T1, T2, R1, R2, correspondences, K)
    %% Preparation
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

