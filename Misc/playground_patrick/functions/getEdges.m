function [edges] = getEdges(image)
    edges = edge(rgb2gray(image) ,'Canny');
end

