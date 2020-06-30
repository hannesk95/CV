clear;
clc;
close All;

%% 
[i1,i2] = getImages(3);

%% Create overestimating mask
[delta] = getDifference(i1,i2);
[maskOverestimating] = getOverestimatingMask(delta, 31, 3);

%% Calculate and filter delta edges
[edges_i2] = getEdges(i2);
[edges_i1] = getEdges(i1);

edges_delta = (edges_i2 - edges_i1).*(edges_i2 - edges_i1);



contours = bwboundaries(edges_delta, 'noholes');

th = 30;
remove = zeros(size(contours));
for i = 1:length(contours)
    c = contours{i};
    if(size(c, 1) < th)
        remove(i) = 1;
    end
end
contours(logical(remove), :) = [];

contours_image = zeros(size(edges_delta));

for i = 1:length(contours)
    c = contours{i};
    for j = 1:size(c, 1)
        contours_image(c(j,1), c(j,2)) = 1;
    end
end

%% Remove "wrong edges"
masked_contours_image = contours_image;
masked_contours_image(~maskOverestimating) = 0;

%% Remove Edges from i2
sum(sum(contours_image))
contours_image(edges_i2==1) = 0;
sum(sum(contours_image))

%% Try to close holes - create kernels

% Horizontal Kernel
size_Hor = 5;
th_Hor = 2;
kernelHor = zeros(size_Hor);
kernelHor(floor(size_Hor/2) +1, :) = ones(1, size_Hor);
% 
% % Vertical Kernel
% size_Vert = 5;
% th_Vert = 2;
% kernelVert = zeros(size_Vert);
% kernelVert(:, floor(size_Vert/2) +1) = ones(size_Hor, 1);
% 
% % / - Kernel
% size_Diag = 5;
% th_Diag = 2;
% kernelDiag = diag(ones(1, size_Diag));
% 
% % \ - Kernel
% size_RevDiag = 5;
% th_RevDiag = 2;
% kernelRevDiag = zeros(size_RevDiag);
% for i = 1:size_RevDiag
%     kernelRevDiag(size_RevDiag-i+1, i) = 1;
% end

%% Try to close holes - apply kernels and thresholds
% 
% % Horizontal Kernel
% masked_contours_image = conv2(masked_contours_image, kernelHor, 'same');
% masked_contours_image(masked_contours_image < th_Hor) = 0;
% masked_contours_image(masked_contours_image >= th_Hor) = 1;
% 
% % Vertical Kernel
% masked_contours_image = conv2(masked_contours_image, kernelVert, 'same');
% masked_contours_image(masked_contours_image < th_Vert) = 0;
% masked_contours_image(masked_contours_image >= th_Vert) = 1;
% 
% % / - Kernel
% masked_contours_image = conv2(masked_contours_image, kernelDiag, 'same');
% masked_contours_image(masked_contours_image < th_Diag) = 0;
% masked_contours_image(masked_contours_image >= th_Diag) = 1;
% 
% % \ - Kernel
% masked_contours_image = conv2(masked_contours_image, kernelRevDiag, 'same');
% masked_contours_image(masked_contours_image < th_RevDiag) = 0;
% masked_contours_image(masked_contours_image >= th_RevDiag) = 1;

%% Refine Mask
[mask] = getRefinedMaskWithEdges(maskOverestimating, masked_contours_image, 1);
[mask] = getRefinedMaskWithEdges(mask, masked_contours_image, 2);
[mask] = getRefinedMaskWithEdges(mask, masked_contours_image, 3);
[mask] = getRefinedMaskWithEdges(mask, masked_contours_image, 4);


%% Show results
figure(1)
imshow(edges_delta)
title('unfiltered delta edges')

figure(2)
imshow(contours_image)
title('filtered delta edges')

figure(3)
imshow(masked_contours_image)
title('filtered delta edges with mask')

figure(4)
imshow(render(i1,mask, 0, 'foreground'))
title('edge-refined mask on original image')

figure(5)
imshow(delta)
title('delta image')


