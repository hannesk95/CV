start_frame = 555;
imreader = ImageReader('C:\Users\Daniel\Desktop\Studium\Master\1. Semester\02 Computer Vision\Challenge\Datasets\P1E_S1', 1, 2, start_frame, 2)

[tensor_left, tensor_right] = imreader.next();

segmentation(tensor_left, tensor_right);

% N = size(tensor_left,3) / 3 - 1;
% 
% figure
% image_left = tensor_left(:, :, 1:3);
% imshow(image_left)
% image_left = rgb2gray(image_left);
% labels = watershed_segmentation(image_left);
% Lrgb = label2rgb(labels,'jet','w','shuffle');
% figure
% imshow(Lrgb)