start_frame = 800;
imreader = ImageReader('C:\Users\Daniel\Desktop\Studium\Master\1. Semester\02 Computer Vision\Challenge\Datasets\P1E_S1', 1, 3, start_frame, 2)

[tensor_left, tensor_right] = imreader.next();

mask = segmentation(tensor_left, tensor_right);

figure
imshow(uint8(mask * 255) * 0.5 + tensor_left(:,:,1:3) * 0.5);