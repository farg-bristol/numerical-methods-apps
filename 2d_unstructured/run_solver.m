function varargout = run_solver(varargin)
% RUN_SOLVER MATLAB code for run_solver.fig
%      RUN_SOLVER, by itself, creates a new RUN_SOLVER or raises the existing
%      singleton*.
%
%      H = RUN_SOLVER returns the handle to a new RUN_SOLVER or the handle to
%      the existing singleton*.
%
%      RUN_SOLVER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RUN_SOLVER.M with the given input arguments.
%
%      RUN_SOLVER('Property','Value',...) creates a new RUN_SOLVER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before run_solver_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to run_solver_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help run_solver

% Last Modified by GUIDE v2.5 15-Nov-2020 12:19:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @run_solver_OpeningFcn, ...
                   'gui_OutputFcn',  @run_solver_OutputFcn, ...
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


% --- Executes just before run_solver is made visible.
function run_solver_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to run_solver (see VARARGIN)

% Choose default command line output for run_solver
handles.output = hObject;

handles.mesh = [];
handles.vol_results = [];
handles.surf_results = [];
handles.history = [];

defaults.mesh_file = '';
config = lib.parseOptions(defaults,varargin{:});
handles.edit1.String = config.mesh_file;

if ~isempty(handles.edit1.String)
    handles = load_mesh(handles);
    
end %if


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes run_solver wait for user response (see UIRESUME)
% uiwait(handles.figure1);


function handles = load_mesh(handles)

mesh_file = handles.edit1.String;
[~,mesh_name] = fileparts(mesh_file);

f = waitbar(.0,'Loading grid file...');
cleanupObj = onCleanup(@() close(f));

try
    handles.mesh = lib.load_griduns(mesh_file);
catch e
    disp(e);
    errordlg(['Error while trying to load mesh''',mesh_name,'''']);
end %try

waitbar(.5,f,'Processing...');

handles.mesh = lib.gen_cellgrid(handles.mesh);
handles.mesh.mesh_name = mesh_name;
handles.pushbutton1.Enable = 'on';
handles.pushbutton5.Enable = 'on';
handles.pushbutton4.Enable = 'off';
handles.pushbutton6.Enable = 'off';

handles.text13.String = ['Mesh file: ''',handles.mesh.mesh_name,'''',newline,...
                         'Vertices: ',num2str(handles.mesh.nvert),newline,...
                         'Cells: ',num2str(handles.mesh.ncell),newline,...
                         'Faces: ',num2str(handles.mesh.nedge)];

function handles = load_results(handles)

mach = sscanf(handles.edit3.String,'%f');
run_dir = handles.edit11.String;
mesh_file = [run_dir,filesep,'griduns'];
dat_file = [run_dir,filesep,'flow.dat'];
surf_file = [run_dir,filesep,'surfaceFlow.plt'];

if ~isfolder(run_dir)
    errordlg('Output directory not found.');
end %if

if ~isfile(mesh_file)
    errordlg('No mesh file found in output directory.');
end %if

if ~isfile(dat_file) || ~isfile(surf_file)
    errordlg('No results found in output directory.');
end %if

f = waitbar(.0,'Loading data files...');
cleanupObj = onCleanup(@() close(f));

waitbar(0.3,f);
handles.vol_results = lib.load_volume_results(dat_file,handles.mesh,mach);

waitbar(0.6,f);
handles.surf_results = lib.load_surface_results(surf_file);

waitbar(0.99,f);







% --- Outputs from this function are returned to the command line.
function varargout = run_solver_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

run_dir = handles.edit11.String;
mesh_file = handles.edit1.String;

if ~isfolder(run_dir)
    mkdir(run_dir);
end %if

if isfile(mesh_file)
    copyfile(mesh_file,[run_dir,filesep,'griduns']);
else
    errordlg(['Unable to find mesh file ''',mesh_file,'''']);
end %if


config.restart =  handles.checkbox1.Value;
config.aoa = sscanf(handles.edit2.String,'%f');
config.mach = sscanf(handles.edit3.String,'%f');
config.maxiter = sscanf(handles.edit5.String,'%u');
config.minres = sscanf(handles.edit6.String,'%d');
config.cfl = sscanf(handles.edit4.String,'%f');
config.k1 = sscanf(handles.edit7.String,'%f');
config.k2 = sscanf(handles.edit8.String,'%f');
config.mg_level = sscanf(handles.edit9.String,'%u');
config.mg_prolong_damp = sscanf(handles.edit10.String,'%f');


commandwindow;
f = waitbar(.0,'Running solver...');
cleanupObj = onCleanup(@() close(f));
stat = lib.run_solver(run_dir,config);
figure(handles.output);

if stat ~= 0
    
    warndlg('The solver exited with an error status. See command window for more information.');
    
end %if

history = lib.load_convergence_history([run_dir,filesep,'flowHistory.plt']);
handles.history = history;
handles.pushbutton6.Enable = 'on';
guidata(hObject,handles);


handles.text13.String = ['Iterations: ',num2str(length(history.iterations)),newline,...
                         'Residual (log10): ',num2str(log10(history.residual(end))),newline,...
                         'CL: ',num2str(history.CL(end)),newline,...
                         'CD: ',num2str(history.CD(end)),newline,...
                         'CM: ',num2str(history.CM(end))];


function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file, path] = uigetfile('meshes/*.*');

if path == 0; return; end %if

handles.edit1.String = [path,file];
handles.checkbox1.Value = 0;

handles = load_mesh(handles);
guidata(hObject,handles);


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1



function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double


% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Volume field (Cp)
% Volume field (mach)
% Surface Cp
% Surface Mach
% Surface coordinates
% Residual convergence

figure;
if handles.popupmenu1.Value == 1 || handles.popupmenu1.Value == 2
    
    % Volume 
    if handles.popupmenu1.Value == 1
        lib.plot_results(handles.vol_results.cp,handles.mesh);
    elseif handles.popupmenu1.Value == 2
        lib.plot_results(handles.vol_results.mach,handles.mesh);
    end %if
    
    hold on;
    colorbar;
    plot(handles.surf_results.x,handles.surf_results.y,'.-');
    axis equal;
    xlim([-1.5 2]);
    
elseif handles.popupmenu1.Value == 3 || handles.popupmenu1.Value == 4
    
    %  
    if handles.popupmenu1.Value == 3
        plot(handles.surf_results.x,handles.surf_results.cp,'.-');
        set(gca,'YDir','reverse');
    elseif handles.popupmenu1.Value == 4
        plot(handles.surf_results.x,handles.surf_results.mach,'.-');
    end %if
    
elseif handles.popupmenu1.Value == 5
    
    plot(handles.surf_results.x,handles.surf_results.y,'.-');
    
elseif handles.popupmenu1.Value == 6
    
    semilogy(handles.history.iterations,handles.history.residual,'.-');
    grid on;
    
end %if



% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% mesh_file = handles.edit1.String;
% [~,mesh_name] = fileparts(mesh_file);
% 
% f = waitbar(.0,'Loading grid file...');
% grid = lib.load_griduns(mesh_file);
% waitbar(.5,f,'Processing...');
% grid = lib.gen_cellgrid(grid);
% close(f);

grid = handles.mesh;

figure;
patch('Vertices',grid.vertices,'Faces',grid.cell_verts,'FaceColor','white');
axis equal;
xlim([-1.5 2]);




% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


handles = load_results(handles);
guidata(hObject,handles);
handles.pushbutton4.Enable = 'on';
