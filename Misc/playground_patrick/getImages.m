function [i1,i2] = getImages(imgNum)
    switch imgNum
        case 1
            i1 = imread('00000215.jpg');
            i2 = imread('00000216.jpg');
        case 2
            i1 = imread('00000160.jpg');
            i2 = imread('00000161.jpg');
        case 3 
            i1 = imread('00000377.jpg');
            i2 = imread('00000378.jpg');
        case 4 
            i1 = imread('00000784.jpg');
            i2 = imread('00000785.jpg');
        case 5
            i1 = imread('00000955.jpg');
            i2 = imread('00000956.jpg');
        case 6
        	i1 = imread('00000197.jpg');
            i2 = imread('00000198.jpg');
        case 7
            i1 = imread('00000511.jpg');
            i2 = imread('00000512.jpg');
    end
end

