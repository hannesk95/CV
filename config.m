%% Computer Vision Challenge 2020 config.m

%% Generall Settings
% Group number:
% group_number = 0;

% Group members:
% members = {'Max Mustermann', 'Johannes Daten'};

% Email-Address (from Moodle!):
% mail = {'ga99abc@tum.de', 'daten.hannes@tum.de'};


%% Setup Image Reader
% Specify Scene Folder
src = "Path/to/my/ChokePoint/P1E_S1";

% Select Cameras
L = 1
R = 2

% Choose a start point
start = 1

% Choose the number of succseeding frames
N = 3

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
