rgb = imread('C:\Users\Daniel\Desktop\Studium\Master\1. Semester\02 Computer Vision\Challenge\Datasets\P1E_S1\P1E_S1_C1\00001172.jpg');

I = rgb2gray(rgb);

L = watershed_segmentation(I);

Lrgb = label2rgb(L,'jet','w','shuffle');
figure
imshow(Lrgb)
title('Colored Watershed Label Matrix')