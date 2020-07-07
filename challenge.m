%% Computer Vision Challenge 2020 challenge.m
clear;
close all;
clc;


%% Configuration
config.m

%% Initialize and start timer

% Initialize ImageReader
ir = ImageReader(src, L, R, start, N);

% Initialize video writer if necessary
if store
    v = VideoWriter(dst);
end

% initialize image counter
numProcessed = 0;

% Start timer
tic;

%% Generate Movie
loop = 0;
while loop ~= 1
    % Get next image tensors
    [left, right, loop] = imreader.next();

    % Generate binary mask
    mask = segmentation(left, right);
    
    % Render new frame
    movie = render(left,mask, backgroundImage, renderMode);
    
    % Write new frame to movie if necessary
    if store
        writeVideo(v,movie);
    end
    
    numProcessed = numProcessed + 1;
end

%% Stop timer here
elapsed_time = toc;
disp('Elapsed time: ' + string(elapsed_time) + '(for ' + string(numProcessed) + ' frames)');


%% Cleanup

% Write Movie to Disk if necessary
close(v);

clearvars -except movie group number members mail 