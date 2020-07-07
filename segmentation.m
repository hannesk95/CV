function mask = segmentation(tensor_left, tensor_right)
    [tensor_l_out, tensor_r_out, tensor_l_scaled, tensor_r_scaled, scaling_factor] = prepare_images(tensor_left, tensor_right);

    rois = find_roi(tensor_l_scaled, tensor_r_scaled, scaling_factor);

    mask = generate_mask(tensor_l_out, tensor_r_out, rois);
end

