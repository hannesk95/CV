function mask = segmentation(left, right)
    % Convert images to grayscale and scale to desired size
    [tensor_l_out, tensor_l_scaled, scaling_factor] = prepare_images(left);

    % Search for a region of interest
    rois = find_roi(tensor_l_scaled, scaling_factor);

    % Calculate foreground mask using the left images and the region of interest
    mask = generate_mask(tensor_l_out, rois);
end

