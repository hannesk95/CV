function [fgm, bgm] = generate_markers(I)
    
    %% Preprocessing
    % Opening-by-Reconstruction
    se = strel('disk',3);
    Ie = imerode(I,se);
    Iobr = imreconstruct(Ie,I);
    
    % Opening-Closing by Reconstruction
    Iobrd = imdilate(Iobr,se);
    Iobrcbr = imreconstruct(imcomplement(Iobrd),imcomplement(Iobr));
    Iobrcbr = imcomplement(Iobrcbr);
    
    %% Generate foreground markers
    fgm1 = imregionalmax(Iobrcbr);

    % Shrink markers by a closing followed by an erosion
    %se2 = strel('disk', 1);
    %fgm2 = imclose(fgm1,se2);
    %fgm3 = imerode(fgm2,se2);
    fgm3 = fgm1;
    
    % Remove isolated pixels
    fgm = bwareaopen(fgm3, 3);
    
    %% Generate background markers    
    bw = imbinarize(Iobrcbr, 'adaptive','ForegroundPolarity','bright','Sensitivity',0.8);

    % Computing the "skeleton by influence zones"
    D = bwdist(bw);
    DL = watershed(D);
    bgm = DL == 0;
end

