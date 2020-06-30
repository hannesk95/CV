function [fgm, bgm] = generate_markers(left,right)
    N = size(left,3) / 3 - 1;
    I1 = left(:,:, 1:3);
    I1 = rgb2gray(I1); 
    I1 = imadjust(I1);
    
    %% Preprocessing
    % Opening-by-Reconstruction
    se = strel('disk',5);
    Ie = imerode(I1,se);
    Iobr = imreconstruct(Ie,I1);
    
    % Opening-Closing by Reconstruction
    Iobrd = imdilate(Iobr,se);
    Iobrcbr = imreconstruct(imcomplement(Iobrd),imcomplement(Iobr));
    Iobrcbr = imcomplement(Iobrcbr);
    
    %% Generate foreground markers
    fgm1 = imregionalmax(Iobrcbr);

    % Shrink markers by a closing followed by an erosion
    se2 = strel(ones(5,5));
    fgm2 = imclose(fgm1,se2);
    fgm3 = imerode(fgm2,se2);

    % Remove isolated pixels
    fgm = bwareaopen(fgm3,20);
    
    %% Generate background markers    
    bw = imbinarize(Iobrcbr, 'adaptive','ForegroundPolarity','bright','Sensitivity',0.8);

    % Computing the "skeleton by influence zones"
    D = bwdist(bw);
    DL = watershed(D);
    bgm = DL == 0;
end

