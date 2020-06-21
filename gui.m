function varargout = gui(varargin)
% GUI MATLAB code for gui.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui

% Last Modified by GUIDE v2.5 21-Jun-2020 14:27:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui (see VARARGIN)

% Choose default command line output for gui
handles.output = hObject;

handles.imagereader = 0;

addlistener(handles.text_start,'String','PostSet',@(hObj, evnt)imagereader_callback(hObj, evnt, handles.text_start));
addlistener(handles.text_directory,'String','PostSet',@(hObj, evnt)imagereader_callback(hObj, evnt, handles.text_start));

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Updates imagereader property.
function imagereader_callback(hObj, evnt, h)
config
if ~exist('N')
    N = 1;
    fprintf("Using default value N = %d\n", N)
end
if ~exist('L') || ~exist('R')
    L = 1;
    R = 3;
    fprintf("Using default values L = %d and R = %d\n", L, R)
end
handles = guidata(h);
start = str2double(get(handles.text_start,'String'));
src = get(handles.text_directory,'String')
if strlength(src) > 0
    handles.imreader = ImageReader(src, L, R, start, N);
end
guidata(h, handles)



% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in button_change_directory.
function button_change_directory_Callback(hObject, eventdata, handles)
% hObject    handle to button_change_directory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
directory = uigetdir
if directory ~= 0
    set(handles.text_directory, 'String', directory);
end



function text_directory_Callback(hObject, eventdata, handles)
% hObject    handle to text_directory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of text_directory as text
%        str2double(get(hObject,'String')) returns contents of text_directory as a double


% --- Executes during object creation, after setting all properties.
function text_directory_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_directory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in button_change_background.
function button_change_background_Callback(hObject, eventdata, handles)
% hObject    handle to button_change_background (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file, path] = uigetfile({'*.jpg';'*.jpeg';'*.bmp';'*.*'}, 'Hintergrundbild auswählen')
if file ~= 0 && path ~= 0
    set(handles.text_background, 'String', append(path,file));
end


function text_background_Callback(hObject, eventdata, handles)
% hObject    handle to text_background (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of text_background as text
%        str2double(get(hObject,'String')) returns contents of text_background as a double


% --- Executes during object creation, after setting all properties.
function text_background_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_background (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function text_start_Callback(hObject, eventdata, handles)
% hObject    handle to text_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of text_start as text
%        str2double(get(hObject,'String')) returns contents of text_start as a double
number = str2double(get(hObject,'String'));
if isnan(number) || number < 0
    number = 0;
end
set(hObject, 'String', sprintf("%d", int32(number)))


% --- Executes during object creation, after setting all properties.
function text_start_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in button_start_decr.
function button_start_decr_Callback(hObject, eventdata, handles)
% hObject    handle to button_start_decr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
number = str2double(get(handles.text_start,'String'));
if number > 0
    set(handles.text_start,'String', sprintf("%d", number - 1));
end

% --- Executes on button press in button_start_inc.
function button_start_inc_Callback(hObject, eventdata, handles)
% hObject    handle to button_start_inc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
number = str2double(get(handles.text_start,'String'));
set(handles.text_start,'String', sprintf("%d", number + 1));

% --- Executes on selection change in popup_mode.
function popup_mode_Callback(hObject, eventdata, handles)
% hObject    handle to popup_mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popup_mode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_mode


% --- Executes during object creation, after setting all properties.
function popup_mode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in button_play.
function button_play_Callback(hObject, eventdata, handles)
% hObject    handle to button_play (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.button_pause, 'Enable', 'on');
set(handles.button_stop, 'Enable', 'on');
set(hObject, 'Enable', 'off');


% --- Executes on button press in button_pause.
function button_pause_Callback(hObject, eventdata, handles)
% hObject    handle to button_pause (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.button_play, 'Enable', 'on');
set(hObject, 'Enable', 'off');


% --- Executes on button press in button_stop.
function button_stop_Callback(hObject, eventdata, handles)
% hObject    handle to button_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.button_play, 'Enable', 'on');
set(handles.button_pause, 'Enable', 'off');
set(hObject, 'Enable', 'off');


% --- Executes on button press in checkbox_loop.
function checkbox_loop_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_loop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_loop


% --- Executes on button press in button_save.
function button_save_Callback(hObject, eventdata, handles)
% hObject    handle to button_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
