function mask = generate_ellipse(width, height)
    parabel1 = (linspace(0, 2, height) - 1) .^ 2;
    parabel2 = (linspace(0, 2, width) - 1) .^ 2;    
    mask = parabel1' + parabel2 <= 1;
end

