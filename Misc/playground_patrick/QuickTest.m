clear;
clc;
close All;

%% 
[i1,i2] = getImages(3);

[delta] = getDifference(i1,i2);

[edges_Difference] = getEdges(delta);
[edges_Image] = getEdges(i1);

[maskOverestimating] = getOverestimatingMask(delta, 31, 3);

edges_Difference(~maskOverestimating) = 0;
edges_Image(~maskOverestimating) = 0;

% [mask] = getRefinedMaskWithEdges(maskOverestimating, edges_Image, 1);
% [mask] = getRefinedMaskWithEdges(mask, edges_Image, 2);
% [mask] = getRefinedMaskWithEdges(mask, edges_Image, 3);
% [mask] = getRefinedMaskWithEdges(mask, edges_Image, 4);


[corDyn, corStat] = getCorrespondences(i1, i2, 7, 0.05, 9, 80, 2.5, 40);

contours = bwboundaries(edges_Image, 'noholes');
size(contours, 1)
contours = removeContoursTouchingMask(contours, maskOverestimating);

figure(1);
[result] = render(i1,maskOverestimating, 0, 'foreground');
imshow(result* 0.5 + edges_Image*0.5);


