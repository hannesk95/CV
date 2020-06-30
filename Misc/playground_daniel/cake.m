function Cake = cake(min_dist)
    % The cake function creates a "cake matrix" that contains a circular set-up of zeros
    % and fills the rest of the matrix with ones. 
    % This function can be used to eliminate all potential features around a stronger feature
    % that don't meet the minimal distance to this respective feature.
    
    % Parabelwerte mit Scheitelpunkt bei min_dist
    parabel = (linspace(0, 2*min_dist, 2*min_dist + 1) - min_dist) .^ 2;
    
    % Quadratischer Abstand zum Mittelpunkt der Matrix als Summe der quadrierten Abstände
    distances2 = parabel' + parabel;
    
    % 1 Werte bei Abstand kleiner min_dist
    Cake = distances2 > min_dist ^ 2;
end