function varargout = Shift(varargin)
%SHIFT M-file for Shift.fig
%      SHIFT, by itself, creates a new SHIFT or raises the existing
%      singleton*.
%
%      H = SHIFT returns the handle to a new SHIFT or the handle to
%      the existing singleton*.
%
%      SHIFT('Property','Value',...) creates a new SHIFT using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to Shift_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      SHIFT('CALLBACK') and SHIFT('CALLBACK',hObject,...) call the
%      local function named CALLBACK in SHIFT.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Shift

% Last Modified by GUIDE v2.5 13-Jun-2014 13:59:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Shift_OpeningFcn, ...
                   'gui_OutputFcn',  @Shift_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before Shift is made visible.
function Shift_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for Shift
handles.datatype=3;
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Shift wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Shift_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function dist_slider_Callback(hObject, eventdata, handles)
% hObject    handle to dist_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

set(handles.dist, 'String',num2str(get(hObject,'Value')));



% --- Executes during object creation, after setting all properties.
function dist_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dist_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function file1_Callback(hObject, eventdata, handles)
% hObject    handle to file1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of file1 as text
%        str2double(get(hObject,'String')) returns contents of file1 as a double


% --- Executes during object creation, after setting all properties.
function file1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to file1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in browse1.
function browse1_Callback(hObject, eventdata, handles)
% hObject    handle to browse1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file, pathname]= uigetfile({'*.loc;*.loc3','Loc File'; '*.*','All (*.*)'}, 'Pick the spots coordinate file');
set(handles.file1, 'String', fullfile(pathname, file));



function file2_Callback(hObject, eventdata, handles)
% hObject    handle to file2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of file2 as text
%        str2double(get(hObject,'String')) returns contents of file2 as a double


% --- Executes during object creation, after setting all properties.
function file2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to file2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cancel.
function cancel_Callback(hObject, eventdata, handles)
% hObject    handle to cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg('Are you sure you want to close this program?',...
    'Close Request','Yes','No','Yes');
switch selection
    case 'Yes',
        close gcf;
    case 'No'
        return
end %switch


% --- Executes on button press in submit.
function submit_Callback(hObject, eventdata, handles)
% hObject    handle to submit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
locfile1= get(handles.file1, 'String');
locfile2= get(handles.file2, 'String');
distance= str2double(get(handles.dist, 'String'));
datatype=handles.datatype;

correct_file = get(handles.correction,'Value')-1;
[ref, mean_shift]=pixel_shift(locfile1, locfile2, datatype, correct_file, distance);
type={cellfun(@(a,b) a{b}, {get(handles.type1, 'String')}, {get(handles.type1,'Value')},'UniformOutput' , false),cellfun(@(a,b) a{b}, {get(handles.type2, 'String')}, {get(handles.type2,'Value')},'UniformOutput' , false)};
filename=strcat(type{1}{1}, '_',type{2}{1},'.shift');
fileID= fopen(filename,'w');
fprintf(fileID, '%s-%s\r\n',type{ref}{1}, type{3-ref}{1});
fprintf(fileID, '%.3f ',mean_shift);
fclose(fileID);



% --- Executes on selection change in correction.
function correction_Callback(hObject, eventdata, handles)
% hObject    handle to correction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns correction contents as cell array
%        contents{get(hObject,'Value')} returns selected item from correction


% --- Executes during object creation, after setting all properties.
function correction_CreateFcn(hObject, eventdata, handles)
% hObject    handle to correction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in browse2.
function browse2_Callback(hObject, eventdata, handles)
% hObject    handle to browse2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file, pathname]= uigetfile({'*.loc;*.loc3','Loc File'; '*.*','All (*.*)'}, 'Pick the spots coordinate file');
set(handles.file2, 'String', fullfile(pathname, file));


function dist_Callback(hObject, eventdata, handles)
% hObject    handle to dist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dist as text
%        str2double(get(hObject,'String')) returns contents of dist as a double
min=get(handles.dist_slider,'Min'); max=get(handles.dist_slider,'Max');
val= str2double(get(hObject,'String'));
if(min<=val & val<=max)
    set(handles.dist_slider, 'Value', val);
else
    warndlg('Warning, value exceeds bounds, it''ll be reset to 0', 'Value');
    set(handles.dist, 'String', num2str(0));
    set(handles.dist_slider, 'Value', 0);
end

% --- Executes during object creation, after setting all properties.
function dist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in uipanel4.
function uipanel4_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel4 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'deuxD'
        handles.datatype=2;
    case 'troisD'
        handles.datatype=3;
end
guidata(hObject, handles);


% --- Executes when uipanel4 is resized.
function uipanel4_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to uipanel4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in type1.
function type1_Callback(hObject, eventdata, handles)
% hObject    handle to type1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns type1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from type1


% --- Executes during object creation, after setting all properties.
function type1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to type1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in type2.
function type2_Callback(hObject, eventdata, handles)
% hObject    handle to type2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns type2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from type2


% --- Executes during object creation, after setting all properties.
function type2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to type2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
