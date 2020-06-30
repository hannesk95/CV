function H = simple_harris_detector(input_image, segment_length, k)
    % Approximation of the image gradient
    [Ix, Iy] = sobel_xy(input_image);
    
    % Weighting
    kn = linspace(-k, k, segment_length);
    C = 1/sum(exp(-(kn).^2 / 2));
    w = C*exp(-(kn).^2 / 2);
    
    % Harris Matrix G
    Ix2 = Ix .^ 2;
    Iy2 = Iy .^ 2;
    Ixy = Ix .* Iy;
    
    G11 = conv2(w', w, Ix2, 'same');
    G22 = conv2(w', w, Iy2, 'same');
    G12 = conv2(w', w, Ixy, 'same');
    
    H = G11 .* G22 - G12 .^2 - k * (G11 + G22) .^2;
end