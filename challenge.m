%% Computer Vision Challenge 2020 challenge.m
clear;
close all;
clc;

%% Start configuration
config

%% Initialization and start timer

% Initialize video writer if necessary
if store
    v = VideoWriter(dst);
    open(v);
end

% initialize image counter
numProcessed = 0;

% Start timer
tic;

%% Generate Movie
loop = 0;
while loop ~= 1
    % Get next image tensors
    [left, right, loop] = ir.next();

    % Generate binary mask
    mask = segmentation(left, right);
    
    % Render new frame
    movie = render(left(:,:,1:3),mask, bg, mode);
    
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
if store
    close(v);
end
clearvars -except movie group_number members mail 