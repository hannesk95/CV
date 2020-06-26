function Labels = watershed_segmentation(image)
%WATERSHED_SEGMENTATION Finds segments along edges
%   image    Grayscale input image

%% Image Preprocessing

% increase contrast
I = imadjust(image);

% magnify edges
I = sharpen_image(double(I));
I = uint8(I);

% Calculate magnitude of gradient
[Fx, Fy] = sobel_xy(I);
gmag = Fx .^ 2 + Fy .^ 2;


%% Marker Generation

% Opening-by-Reconstruction
se = strel('disk',8);
Ie = imerode(I,se);
Iobr = imreconstruct(Ie,I);

% Opening-Closing by Reconstruction
Iobrd = imdilate(Iobr,se);
Iobrcbr = imreconstruct(imcomplement(Iobrd),imcomplement(Iobr));
Iobrcbr = imcomplement(Iobrcbr);

% Regional Maxima of Opening-Closing by Reconstruction
fgm = imregionalmax(Iobrcbr);

% Shrink markers by a closing followed by an erosion
se2 = strel(ones(5,5));
fgm2 = imclose(fgm,se2);
fgm3 = imerode(fgm2,se2);

% Remove isolated pixels
fgm4 = bwareaopen(fgm3,20);
I3 = labeloverlay(I,fgm4);

% Mark the dark pixels as background
bw = imbinarize(Iobrcbr, 'adaptive','ForegroundPolarity','bright','Sensitivity',0.65);

%% Segmentation

% Computing the "skeleton by influence zones"
D = bwdist(bw);
DL = watershed(D);
bgm = DL == 0;

% Compute the watershed-based segmentation
gmag2 = imimposemin(gmag, bgm | fgm4);
Labels = watershed(gmag2);

end

