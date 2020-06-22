classdef ImageReader < handle
  % Add class description here
  %
  %
   properties
       N
       counter
   end
   methods
      function obj = ImageReader(src, L, R, start, N)
        fprintf('ImageReader("%s", %d, %d, %d, %d)\n', src, L, R, start, N)
        obj.N = N;
        obj.counter = 0;
      end
      function [left, right, loop] = next(obj)
          left = zeros(600,800,(obj.N + 1)*3);
          right = zeros(600,800,(obj.N + 1)*3);
          loop = mod(obj.counter, 101) == 100;
          obj.counter = obj.counter + 1;
          fprintf('next(), counter: %d\n', obj.counter);
      end
      function setCurrentFrame(obj, frameIndex)
          fprintf('setCurrentFrame(%d)\n', frameIndex);
          obj.counter = frameIndex;
      end
   end
end
