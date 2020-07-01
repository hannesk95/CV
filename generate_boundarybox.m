function [top_left, bottom_right] = generate_boundarybox(I)
  image_size = size(I);

  p1 = find(I == 1, 1);
  p2 = find(I == 1, 1, 'last');
  p3 = find(I' == 1, 1);
  p4 = find(I' == 1, 1, 'last');

  [y1, x1] = ind2sub(size(I), p1);
  [y2, x2] = ind2sub(size(I), p2);
  [x3, y3] = ind2sub(size(I'), p3);
  [x4, y4] = ind2sub(size(I'), p4);

  x_values = [x1 x2 x3 x4];
  y_values = [y1 y2 y3 y4];
  top_left = [min(x_values) min(y_values)];
  bottom_right = [max(x_values) max(y_values)];
    
  if isempty(top_left)
    top_left = [1 1];
  end
  if isempty(bottom_right)
    bottom_right = [image_size(2) image_size(1)];
  end
end

