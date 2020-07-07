function [core, border, noise] = simple_dbscan(pts, epsilon, minPts)
    core = zeros(1,size(pts,2));
    border = zeros(1,size(pts,2));
    noise = zeros(1,size(pts,2));
    
    distance_matrix = zeros(size(pts, 2));
    
    for i = 1:size(pts,2)
        x1 = pts(:,i);
        for j = 1:size(pts,2)
            x2 = pts(:,j);
            distance = x1 - x2;
            distance = distance .^ 2;
            distance = sum(distance);
            distance = sqrt(distance);
            distance_matrix(i,j) = distance;
        end
    end
    
    n_core = 0;
    n_border = 0;
    n_noise = 0;
    for i = 1:size(pts, 2)
        row = distance_matrix(i, :);
        neighbors = find(row < epsilon);
        if length(neighbors) >= minPts
            n_core = n_core + 1;
            core(n_core) = i;
        elseif any(ismember(neighbors, core))
            n_border = n_border + 1;
            border(n_border) = i;
        else
            n_noise = n_noise + 1;
            noise(n_noise) = i;
        end
    end
    
    core(n_core+1:end) = [];
    border(n_border+1:end) = [];
    noise(n_noise+1:end) = [];
    
end

