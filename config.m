%% Computer Vision Challenge 2020 config.m

%% Generall Settings
% Group number:
group_number = 4;

% Group members:
members = {'Hacket Franziska', 'BlÃ¼mcke Patrick', 'Muhr Florian', 'StÃ¼mke Daniel', 'Kiechle Johannes'};

% Email-Address (from Moodle!):
mail = {'franziska.hacket@tum.de', 'patrick.bluemcke@tum.de', 'daniel.stuemke@tum.de', 'f.muhr@tum.de', 'johannes.kiechle@tum.de'};


%% Setup Image Reader
% Specify Scene Folder
src = "Path/to/my/ChokePoint/P1E_S1";

% Select Cameras
L = 1;
R = 2;

% Choose a start point
start = 1;

% Choose the number of succseeding frames
N = 3;

ir = ImageReader(src, L, R, start, N);


%% Output Settings
% Output Path
dst = "output.avi";

% Load Virual Background
bg = 0;
% bg = imread("Path\to\my\virtual\background")

% Select rendering mode
mode = "substitute";

% Store Output?
store = true;
