start_frame = 960;
N = 2;
imreader = ImageReader('C:\Users\Daniel\Desktop\Studium\Master\1. Semester\02 Computer Vision\Challenge\Datasets\P1E_S1', 1, 3, start_frame, N)

[tensor_left, tensor_right] = imreader.next();

[tensor_l_out, tensor_r_out, tensor_l_scaled, tensor_r_scaled, scaling_factor] = prepare_images(tensor_left, tensor_right);

rois = find_roi(tensor_l_scaled, tensor_r_scaled, scaling_factor, true);

fgm = generate_mask(tensor_l_out, tensor_r_out, rois, true);

figure
imshow(uint8(fgm) * 255 * 0.3 + tensor_left(:,:,1:3) * 0.7);

