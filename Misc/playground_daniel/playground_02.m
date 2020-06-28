%rgb = imread('C:\Users\Daniel\Desktop\Studium\Master\1. Semester\02 Computer Vision\Challenge\Datasets\P1E_S1\P1E_S1_C1\00001172.jpg');
rgb = imread('C:\Users\Daniel\Desktop\Studium\Master\1. Semester\02 Computer Vision\Challenge\Datasets\P1E_S1\P1E_S1_C1\00000628.jpg');

I = rgb2gray(rgb);

I = imadjust(I);

I = sharpen_image(double(I));
I = imgaussfilt(double(I), 1);
I = uint8(I);

%imshow(I)

%[Fx, Fy] = sobel_xy(I);
%gmag = Fx .^ 2 + Fy .^ 2;


gmag = imgradient(I, 'intermediate');
figure
imshow(gmag,[])

se = strel('disk',5);
Ie = imerode(I,se);
Iobr = imreconstruct(Ie,I);
figure
imshow(Iobr)
title('Opening-by-Reconstruction')

Iobrd = imdilate(Iobr,se);
Iobrcbr = imreconstruct(imcomplement(Iobrd),imcomplement(Iobr));
Iobrcbr = imcomplement(Iobrcbr);
figure
imshow(Iobrcbr)
title('Opening-Closing by Reconstruction')

fgm = imregionalmax(Iobrcbr);
figure
imshow(fgm)
title('Regional Maxima of Opening-Closing by Reconstruction')

I2 = labeloverlay(I,fgm);
figure
imshow(I2)
title('Regional Maxima Superimposed on Original Image')

se2 = strel(ones(5,5));
fgm2 = imclose(fgm,se2);
fgm3 = imerode(fgm2,se2);

fgm4 = bwareaopen(fgm3,20);
I3 = labeloverlay(I,fgm4);
figure
imshow(I3)
title('Modified Regional Maxima Superimposed on Original Image')


bw = imbinarize(Iobrcbr, 'adaptive','ForegroundPolarity','bright','Sensitivity',0.75);
figure
imshow(bw)
title('Thresholded Opening-Closing by Reconstruction')

D = bwdist(bw);
DL = watershed(D);
bgm = DL == 0;
imshow(bgm)
title('Watershed Ridge Lines)')

gmag2 = imimposemin(gmag, bgm | fgm4);
L = watershed(gmag2);
labels = imdilate(L==0,ones(3,3)) + 2*bgm + 3*fgm4;
I4 = labeloverlay(I,labels);
figure
imshow(I4)
title('Markers and Object Boundaries Superimposed on Original Image')

Lrgb = label2rgb(L,'jet','w','shuffle');
figure
imshow(Lrgb)
title('Colored Watershed Label Matrix')