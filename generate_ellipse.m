function mask = generate_ellipse(width, height)
    parabola1 = (linspace(0, 2, height) - 1) .^ 2;
    parabola2 = (linspace(0, 2, width) - 1) .^ 2;    
    mask = parabola1' + parabola2 <= 1;
end

