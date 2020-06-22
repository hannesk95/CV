classdef ImageReader
  % Add class description here
  %
  %
   properties
       N
       start
   end
   methods
      function obj = ImageReader(src, L, R, start, N)
        fprintf('ImageReader("%s", %d, %d, %d, %d)\n', src, L, R, start, N)
        obj.N = N;
        obj.start = start;
      end
      function [left, right, loop] = next(obj)
          left = zeros(600,800,(obj.N + 1)*3);
          right = zeros(600,800,(obj.N + 1)*3);
          fprintf('next(), start: %d\n', obj.start);
          loop = false;
      end
   end
end
