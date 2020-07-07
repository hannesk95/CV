function mask = generate_prototype(width, height)
    parabel = 1 - (linspace(0, 1, width) - 0.5) .^ 2 * 4;
    mask = ones(height,1) * parabel;
end

