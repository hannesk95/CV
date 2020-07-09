function mask = generate_weighting(width, height)
    parabel1 = (linspace(0, 1, height) - .5) .^ 2 - 0.25;
    parabel2 = (linspace(0, 1, width) - .5) .^ 2 - 0.25;    
    mask = (parabel1' + parabel2) * -2;
end

