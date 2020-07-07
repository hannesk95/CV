function [labels, cluster_means] = simple_k_means(pts, k, initial_vectors, convergence_threshold, max_iterations)
    cluster_means = initial_vectors;
    distances = zeros(k, size(pts,2));
    prev_distortion = inf;
    
    for it = 1:max_iterations
    
        for i = 1:k

            cluster_mean = cluster_means(:,i);
            distance_vectors = pts - cluster_mean;
            distance_vectors = distance_vectors .^ 2;
            distances(i,:) = sum(distance_vectors);

        end

        [~,labels] = min(distances);

        curr_distortion = 0;

        for i = 1:k
            cluster_vectors = pts(:,labels == i);
            cluster_mean = mean(cluster_vectors')';
            cluster_means(:,i) = cluster_mean;

            cluster_distortion = cluster_vectors - cluster_mean;
            cluster_distortion = cluster_distortion .^ 2;
            cluster_distortion = sum(cluster_distortion(:));

            curr_distortion = curr_distortion + cluster_distortion;
        end

        distortion_diff = prev_distortion - curr_distortion;
        prev_distortion = curr_distortion;
        
        if distortion_diff < convergence_threshold
            break;
        end
    end
end

