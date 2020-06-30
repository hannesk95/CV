function [corDyn, corStat] = getCorrespondences(i1, i2, s_L, k, m_d, N, th_min, th_max)

    %% Create masked grayscale images, therefore removing correspondences which are not within the mask
    gray1 = rgb2gray(i1);
    gray2 = rgb2gray(i2);
    
    %% Calculate harris-features
    features1 = harris_detector(gray1, 'segment_length',s_L,'k',k,'min_dist',m_d,'N',N,'do_plot',false);
    features2 = harris_detector(gray2, 'segment_length',s_L,'k',k,'min_dist',m_d,'N',N,'do_plot',false);

    cor12 = point_correspondence(gray1, gray2, features1, features2, 'window_length', 25, 'min_corr', 0.90, 'do_plot', false);
    
    %% Find dynamic correspondences, save in corDyn
    selection = (vecnorm(cor12(1:2,:)-cor12(3:4,:)) > th_min) & (vecnorm(cor12(1:2,:)-cor12(3:4,:)) < th_max);

    corDyn = cor12(:,selection);
    corStat = cor12(:, ~selection);
end

