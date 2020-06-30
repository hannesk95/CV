start_frame = 880;
imreader = ImageReader('C:\Users\Daniel\Desktop\Studium\Master\1. Semester\02 Computer Vision\Challenge\Datasets\P1E_S1', 2, 3, start_frame, 2)

[tensor_left, tensor_right] = imreader.next();

%tensor_left = tensor_left(100:end, 300:700, :);

mask = segmentation3(tensor_left, tensor_right);
figure
imshow(uint8(mask) .* tensor_left(:,:,1:3));
