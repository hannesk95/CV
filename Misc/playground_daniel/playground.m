img1 = imread('C:\Users\Daniel\Desktop\Studium\Master\1. Semester\02 Computer Vision\Challenge\Datasets\P1E_S1\P1E_S1_C1\00000820.jpg');
img2 = imread('C:\Users\Daniel\Desktop\Studium\Master\1. Semester\02 Computer Vision\Challenge\Datasets\P1E_S1\P1E_S1_C1\00000821.jpg');
img3 = imread('C:\Users\Daniel\Desktop\Studium\Master\1. Semester\02 Computer Vision\Challenge\Datasets\P1E_S1\P1E_S1_C1\00000822.jpg');
img4 = imread('C:\Users\Daniel\Desktop\Studium\Master\1. Semester\02 Computer Vision\Challenge\Datasets\P1E_S1\P1E_S1_C1\00000823.jpg');

gray1 = img1(:,:,1) * 0.299 + img1(:,:,2) * 0.587 + img1(:,:,3) * 0.114;
gray2 = img2(:,:,1) * 0.299 + img2(:,:,2) * 0.587 + img2(:,:,3) * 0.114;
gray3 = img3(:,:,1) * 0.299 + img3(:,:,2) * 0.587 + img3(:,:,3) * 0.114;
gray4 = img4(:,:,1) * 0.299 + img4(:,:,2) * 0.587 + img4(:,:,3) * 0.114;

% Make images zero mean
zero_mean1 = gray1 - mean(gray1(:));
zero_mean2 = gray2 - mean(gray2(:));
zero_mean3 = gray3 - mean(gray3(:));
zero_mean4 = gray4 - mean(gray4(:));

% Calcluate difference images
img_diff = (zero_mean4 - zero_mean1) .^ 2;

% Remove distortion by gauss filtering
img_diff = imgaussfilt(img_diff, 40);

% Extract dynamic regions of image
dyn_region = img_diff > 5;

% Make region rectangular
left = find(sum(dyn_region) > 0,1,'first');
right = find(sum(dyn_region) > 0,1,'last');
top = find(sum(dyn_region') > 0,1,'first');
bottom = find(sum(dyn_region') > 0,1,'last');
%dyn_region(top:bottom, left:right) = 1;

% Show dynamic region
figure(1)
subplot(2,2,1)
imshow(uint8(dyn_region) .* img1)
subplot(2,2,2)
imshow(uint8(dyn_region) .* img2)
subplot(2,2,3)
imshow(uint8(dyn_region) .* img3)
subplot(2,2,4)
imshow(uint8(dyn_region) .* img4)

% Extract dynamic image parts
clip1 = img1(top:bottom, left:right);
clip2 = img2(top:bottom, left:right);
clip3 = img3(top:bottom, left:right);
clip4 = img4(top:bottom, left:right);

% Calculate harris-features
features1 = harris_detector(clip1,'segment_length',9,'k',0.05,'min_dist',50,'N',20,'do_plot',false);
features2 = harris_detector(clip2,'segment_length',9,'k',0.05,'min_dist',50,'N',20,'do_plot',false);
features3 = harris_detector(clip3,'segment_length',9,'k',0.05,'min_dist',50,'N',20,'do_plot',false);
features4 = harris_detector(clip4,'segment_length',9,'k',0.05,'min_dist',50,'N',20,'do_plot',false);


cor12 = point_correspondence(clip1,clip2,features1,features2,'window_length',25,'min_corr', 0.90,'do_plot',true)
cor13 = point_correspondence(clip1,clip3,features1,features3,'window_length',25,'min_corr', 0.90,'do_plot',true)
cor14 = point_correspondence(clip1,clip4,features1,features4,'window_length',25,'min_corr', 0.90,'do_plot',true)
