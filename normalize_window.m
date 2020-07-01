function output = normalize_window(window)
    window = double(window);
    zero_mean_image = window - mean(window(:));
    variance_of_image = sqrt(1/(numel(window)-1) * sum(zero_mean_image(:) .^ 2));
    output = zero_mean_image / variance_of_image;
    % Replace nan values (produced with variance = 0) with 1
    output(isnan(output(:))) = 1;
end

