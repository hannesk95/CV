function output = sharpen_image(image)
%SHARPEN_IMAGE Sharpens the given image
%   Detailed explanation goes here
kernel = [  1,   1,   1; ...
            1,  -8,   1; ...
            1,   1,   1  ];
img_laplace = conv2(image, kernel, 'same');
sharp = double(image);
output = sharp - img_laplace;
output = uint8(output);
end

