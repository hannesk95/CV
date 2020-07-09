function [result] = render(frame,mask, bg, render_mode)
%RENDER Replaces, depending on mode, the background or foreground (or both) of variable frame
%with sth. different (also specified by mode)
% frame: [0,1], 3-channel, 600x800 image 
% mask: logical, 600x800, 0: background, 1: foreground
% bg: NXMx3, [0,1], image to be used as background if mode is 'substitute'
%   if mode is 'video', bg should be a NxMx3xF- Array, where F is the number
%   of frames, bg can then be both [0,255] or [0,1], but the latter is
%   preferred
% mode: Details what is replaced by what, can take 5 different values: 
% - 'foreground' - Set background black
% - 'background' - Set foreground black
% - 'overlay' - Set background and foreground to different colors
% - 'substitute' - Use rgb-image passed in bg as background
% result: The resulting image, 600x800x3, [0,1]

%% Convert frame to double, [0,1] if not already double
if((~isfloat(frame)) || (max(max(max(frame))) > 1))
    frame = double(frame)./255.0;
end

%% Convert bg to double, [0,1] if not already double
if (~isfloat(bg)) || (max(max(max(bg))) > 1)
    bg = double(bg)./255.0;
end

%% Alter image
result = zeros(size(frame));
switch render_mode
	case 'foreground' % Set background black
        for i = 1:3 % For some reason it does not seem to work without loop (with 600x800x3-Mask, R2017b)
            result(:, :, i) = frame(:, :, i) .* mask;
        end
        
	case 'background' % Set foreground black
        for i = 1:3 % For some reason it does not seem to work without loop (with 600x800x3-Mask, R2017b)
            result(:, :, i) = frame(:, :, i) .* ~mask;
        end
        
	case 'overlay' % Set background and foreground to different colors
        % background: black, foreground: white
        for i = 1:3 % For some reason it does not seem to work without loop (with 600x800x3-Mask, R2017b)
            result(:, :, i) = frame(:, :, i) & ~mask;
        end
        
	case 'substitute' % Use rgb-image passed in bg as background
        % Resize bg
        bg = imresize(bg,[600 800]); 
        % Sometimes, resized image can have values slightly larger than
        % 1(i.e. 1.01) or slightly smaller than 0
        % These values are then just clipped, a normalization and/or mean shift seems overkill
        % and might also not be desirable (larger values probably just easily detectable numerical errors)
        bg(bg>1.0) = 1.0;
        bg(bg<0.0) = 0.0;
        
        % Apply bg
        for i = 1:3 % For some reason it does not seem to work without loop (with 600x800x3-Mask, R2017b)
            result(:, :, i) = frame(:, :, i) .* mask + ~mask.*bg(:, :, i);
        end
        
    otherwise
        % Notify user of unknown mode
        warning('Unknown mode, thus result is unaltered image')
        result = frame; 
    end

end

