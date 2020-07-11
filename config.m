%% Computer Vision Challenge 2020 config.m

%% Generall Settings
% Group number:
group_number = 4;

% Group members:
members = {'Hacket Franziska', 'Bluemcke Patrick', 'Muhr Florian', 'Stuemke Daniel', 'Kiechle Johannes'};

% Email-Address (from Moodle!):
mail = {'franziska.hacket@tum.de', 'patrick.bluemcke@tum.de', 'daniel.stuemke@tum.de', 'f.muhr@tum.de', 'johannes.kiechle@tum.de'};

% Add function folder to MATLAB-path
addpath([pwd , '\func'])

%% Setup Image Reader

% Specify scene folder
src = "Path/to/my/ChokePoint/P1E_S1";

% Select left & right cameras
L = 1;
R = 2;

% Choose an image starting point
start = 1;

% Choose the number of succeeding frames
N = 3;

% Create image reader object
ir = ImageReader(src, L, R, start, N);

%% Output Settings

% Specify output path and name
dest = "./output.avi";

%% Load Virual Background

% [INFO]: If virtual background is wanted, allocate desired background-
% image to 'bg' variable and replace rendering mode below to 'substitute'.
% Otherwise for person segmentation only : 'bg' = 0 and select 
% rendering 'mode' = foreground

bg = 0;
% bg = imread("Path\to\my\virtual\background")

%% Select rendering mode

% Possible modes: foreground, background, overlay, substitute
render_mode = "foreground";

% Store Output?
store = true;
