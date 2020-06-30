function [mask] = getOverestimatingMask(deltaImage,n, th)
%GETOVERESTIMATINGMASK Summary of this function goes here
%   Detailed explanation goes here
%% Segment image
d1 = deltaImage(:,:,1);
d2 = deltaImage(:,:,2);
d3 = deltaImage(:,:,3);

%% Apply Lowpass
boxKernel = 1/(n*n)*ones(n);
d1 = conv2(d1, boxKernel, 'same');
d2 = conv2(d2, boxKernel, 'same');
d3 = conv2(d3, boxKernel, 'same');

%% Create Preliminary overestimating mask
mask = d1>th | d2>th | d3>th;

end

