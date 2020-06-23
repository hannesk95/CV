%% Computer Vision Challenge 2020 config.m

%% Generall Settings
% Group number:
group_number = 4;

% Group members:
members = {'Hacket Franziska', 'Blümcke Patrick', 'Muhr Florian', 'Stümke Daniel', 'Kiechle Johannes'};

% Email-Address (from Moodle!):
mail = {'franziska.hacket@tum.de', 'patrick.bluemcke@tum.de', 'daniel.stuemke@tum.de', 'f.muhr@tum.de'};


%% Setup Image Reader
% Specify Scene Folder
src = "Path/to/my/ChokePoint/P1E_S1";

% Select Cameras
% L =
% R =

% Choose a start point
% start = randi(1000)

% Choose the number of succseeding frames
% N =

ir = ImageReader(src, L, R, start, N);


%% Output Settings
% Output Path
dst = "output.avi";

% Load Virual Background
% bg = imread("Path\to\my\virtual\background")

% Select rendering mode
mode = "substitute";

% Create a movie array
% movie =

% Store Output?
store = true;
