%% Computer Vision Challenge 2020 config.m

%% Generall Settings
% Group number:
group_number = 4;

% Group members:
members = {'Hacket Franziska', 'Bluemcke Patrick', 'Muhr Florian', 'Stuemke Daniel', 'Kiechle Johannes'};

% Email-Address (from Moodle!):
mail = {'franziska.hacket@tum.de', 'patrick.bluemcke@tum.de', 'daniel.stuemke@tum.de', 'f.muhr@tum.de', 'johannes.kiechle@tum.de'};


%% Setup Image Reader
% Specify Scene Folder
src = "C:\Users\Johan\Desktop\ChokePointData\P1E_S1";

% Select Cameras
L = 1;
R = 2;

% Choose a start point
start = 2200;

% Choose the number of succseeding frames
N = 2;

ir = ImageReader(src, L, R, start, N);


%% Output Settings
% Output Path
dst = "output.avi";

%% Load Virual Background
% [INFO]: If virtual background is aspired, allocate intended background-
% image to 'bg' variable and replace rendering mode below to 'substitute'.
% Otherwise for person segmentation only : 'bg' = 0 with rendering ...
% 'mode' = foreground

bg = 0;
% bg = imread("Path\to\my\virtual\background")

%% Select rendering mode
% Possible modes: foreground, background, overlay, substitute
mode = "foreground";

% Store Output?
store = true;
