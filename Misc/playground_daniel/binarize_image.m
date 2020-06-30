function output = binarize_image(image)
%BINARIZE_IMAGE Converts image to black-white using otsu threshold
%   image    Sharpened grayscale input image
level = graythresh(image);
output = imbinarize(image,level);
end

