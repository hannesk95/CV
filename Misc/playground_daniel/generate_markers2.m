function [fgm, bgm] = generate_markers(left,right)
    N = size(left,3) / 3 - 1;
    I1 = left(:,:, 1:3);
    I2 = left(:,:, (1:3) + N * 3);
    I1 = rgb2gray(I1);
    I2 = rgb2gray(I2);
    I1_sharp = sharpen_image(I1);
    I2_sharp = sharpen_image(I2);
    
    %% Generate foreground markers
    fgm = zeros(size(I1));
    tile_size = [20, 20];
    kx = size(I1, 2) / tile_size(1);
    ky = size(I1, 1) / tile_size(2);
    rx = ceil(kx) * tile_size(1) - size(I1, 2) + 1;
    ry = ceil(ky) * tile_size(2) - size(I1, 1) + 1;
    t1 = (1 - rx / 2) : tile_size(1) : (size(I1, 2) + rx / 2 - tile_size(1));
    t2 = (1 - ry / 2) : tile_size(2) : (size(I1, 1) + ry / 2 - tile_size(2)); 
    for tile_x = 1:length(t1)
       for tile_y = 1:length(t2)
           % calculate tile center position
            cx = t1(tile_x);
            cy = t2(tile_y);
            % calculate tile edge positions
            left = ceil(cx);
            right = left + tile_size(1) - 1;
            top = ceil(cy);
            bottom = top + tile_size(2) - 1;
            % Limit values
            if left < 1
                left = 1;
            end
            if right > size(I1, 2)
                right = size(I1, 2);
            end
            if top < 1
                top = 1;
            end
            if bottom > size(I1, 1)
                bottom = size(I1, 1);
            end
            % Get tile windows
            w1 = normalize_window(I1_sharp(top:bottom, left:right));
            w2 = normalize_window(I2_sharp(top:bottom, left:right));
            % Calculate difference
            tr = (w1(:))' * w2(:);
            ncc = 1/(numel(w1) - 1) * tr;
            % Compare difference to threshold and draw marker
            threshold = 0;
            if ncc < threshold
                fgm(top:bottom, left:right) = ones(size(w1)) - ncc ;
            end
       end
    end
    
    se = strel(ones(10, 10));
    fgm1 = imgaussfilt(fgm, 20);
    fgm2 = fgm1;%imopen(fgm1, se);
    fgm3 = fgm2 / max(fgm2(:));
    fgm4 = imbinarize(fgm3, 0.9);    
    
    fgm =fgm4;
    
    %% Generate background markers
    
    % Opening-by-Reconstruction
    se = strel('disk',5);
    Ie = imerode(I1,se);
    Iobr = imreconstruct(Ie,I1);
    
    % Opening-Closing by Reconstruction
    Iobrd = imdilate(Iobr,se);
    Iobrcbr = imreconstruct(imcomplement(Iobrd),imcomplement(Iobr));
    Iobrcbr = imcomplement(Iobrcbr);
    
    bw = imbinarize(Iobrcbr, 'adaptive','ForegroundPolarity','bright','Sensitivity',0.8);

    % Computing the "skeleton by influence zones"
    D = bwdist(bw);
    DL = watershed(D);
    bgm = DL == 0;
end

