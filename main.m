start_frame = 1084;
N = 3;
imreader = ImageReader('C:\Users\Daniel\Desktop\Studium\Master\1. Semester\02 Computer Vision\Challenge\Datasets\P1E_S1', 1, 3, start_frame, N)
reader_time = 0;
segm_time = 0;

for i = 1:1
    tic
    [tensor_left, tensor_right] = imreader.next();
    reader_time = reader_time + toc;
    
    tic    
    [tensor_l_out, tensor_l_scaled, scaling_factor] = prepare_images(tensor_left);
    rois = find_roi(tensor_l_scaled, scaling_factor, true);
    fgm = generate_mask(tensor_l_out, rois, true);    
    segm_time = segm_time + toc;
end

reader_time
segm_time

figure
imshow(uint8(fgm) * 255 * 0.3 + tensor_left(:,:,1:3) * 0.7);

