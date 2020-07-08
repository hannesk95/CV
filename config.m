%% Computer Vision Challenge 2020 config.m

%% General Settings
% Group number:
group_number = 4;

% Group members:
members = {'Hacket Franziska', 'Bluemcke Patrick', 'Muhr Florian', 'Stuemke Daniel', 'Kiechle Johannes'};

% Email-Address (from Moodle!):
mail = {'franziska.hacket@tum.de', 'patrick.bluemcke@tum.de', 'daniel.stuemke@tum.de', 'f.muhr@tum.de', 'johannes.kiechle@tum.de'};


%% Setup Image Reader
% Specify Scene Folder
src = "../ChokePoint/P1E_S1";

% Select Cameras
L = 1;
R = 2;

% Choose a start point
start = 2270;

% Choose the number of succseeding frames
N = 2;

ir = ImageReader(src, L, R, start, N);


%% Output Settings
% Output Path
dst = "output.avi";

% Load Virtual Background
bg = imread("../Background.jpg");

% Select rendering mode: 'foreground', 'background', 'substitute' or
% 'overlay'
mode = "substitute";

% Store Output?
store = true;
