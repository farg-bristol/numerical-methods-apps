function varargout = mesh_generator(varargin)
% MESH_GENERATOR MATLAB code for mesh_generator.fig
%      MESH_GENERATOR, by itself, creates a new MESH_GENERATOR or raises the existing
%      singleton*.
%
%      H = MESH_GENERATOR returns the handle to a new MESH_GENERATOR or the handle to
%      the existing singleton*.
%
%      MESH_GENERATOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MESH_GENERATOR.M with the given input arguments.
%
%      MESH_GENERATOR('Property','Value',...) creates a new MESH_GENERATOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mesh_generator_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mesh_generator_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mesh_generator

% Last Modified by GUIDE v2.5 16-Nov-2020 14:45:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mesh_generator_OpeningFcn, ...
                   'gui_OutputFcn',  @mesh_generator_OutputFcn, ...
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


% --- Executes just before mesh_generator is made visible.
function mesh_generator_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mesh_generator (see VARARGIN)

% Choose default command line output for mesh_generator
handles.output = hObject;

if ~isfolder('configurations')
    mkdir('configurations');
end %if

if ~isfolder('scratch')
    mkdir('scratch');
end %if

handles.configs = load_configs();
handles.aerofoils = load('aerofoils');
handles.mesh = [];

% Update handles structure
guidata(hObject, handles);

refreshui_configs(handles);
% refreshui_bodies(handles);


% UIWAIT makes mesh_generator wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function configs = load_configs()
    
    configs = {};
    config_files = dir('configurations');
    for i=1:length(config_files)

        if contains(config_files(i).name,'.mat')

            c = load(['configurations',filesep,config_files(i).name]);

            if isfield(c,'body_config')

                configs{end+1} = c.body_config;

            end %if

        end %if

    end %for

function refreshui_configs(handles)
    
    items = '';
    for i=1:length(handles.configs)
        
        items = [items,handles.configs{i}.name,newline];
        
    end %for
    
    handles.listbox1.String = strtrim(items);
    handles.listbox1.Value = 1;
    handles.uipanel2.Visible = 'off';
    handles.uipanel5.Visible = 'off';
    
    if isempty(handles.listbox1.String)
        handles.text23.String = 'Press ''New'' to create a new configuration';
    else
        handles.text23.String = 'Select a configuration in the listbox to use, or create a new one';
    end %if
    
function set_config_edited(handles)

    handles.listbox1.Enable = 'off';
    handles.pushbutton1.Enable = 'off';
    handles.pushbutton2.Enable = 'off';
    handles.pushbutton10.Enable = 'on';
    
    
% function config = select_config(handles)
% 
%     idx = handles.listbox1.Value;
%     if isempty(idx); return; end %if
%     config = handles.configs{idx};
%     
%     handles.edit1.String = config.name;
%     
%     refreshui_bodies(handles);
    
function refreshui_bodies(handles)
    
    if isempty(handles.listbox1.String); return; end %if
    idx = handles.listbox1.Value;
    
    c = handles.configs{idx};
    
    items = '';
    for i=1:length(c.bodies)
        
        items = [items,c.bodies{i}.name,newline];
        
    end %for
    
    handles.listbox2.String = strtrim(items);
    handles.listbox2.Value = 1;
    
    handles.checkbox2.Enable = 'off';
    handles.slider1.Enable = 'off';
    handles.slider2.Enable = 'off';
    handles.slider3.Enable = 'off';
    handles.slider4.Enable = 'off';
    
    if isempty(handles.listbox2.String)
        handles.pushbutton9.Enable = 'off';
        handles.text23.String = 'Press ''add'' to add a new body';
    else
        handles.pushbutton9.Enable = 'on';
        handles.text23.String = 'Select a body in the listbox to edit it';
    end %if
    
    
function config = plotting(handles,config)
    
    cla(handles.axes1);
    hold(handles.axes1,'on');
    for i=1:length(config.bodies)    
        
        coords = config.bodies{i}.coords;
        config.bodies{i}.plot_handle = plot(coords(:,1),coords(:,2));
        
    end %for
    
    xlim(handles.axes1,'auto');
    axis(handles.axes1,'equal');
    
    if ~isempty(handles.mesh)
        
        handles.checkbox1.Enable = 'on';
         
        if handles.checkbox1.Value
            patch(handles.axes1,'Vertices',handles.mesh.vertices,...
                'Faces',handles.mesh.cell_verts,'FaceColor','white');

            xlim(handles.axes1,[-1.5 2]);
        end %if
        
    else
        
        handles.checkbox1.Enable = 'off';
        
    end %if
    
    
function coords = get_body_coords(body)
    
    coords = body.af;
    if body.flip_horiz
        coords(:,2) = -coords(:,2);
    end %if
    
    theta = body.rotation*pi/180;
    R = [cos(theta) -sin(theta); sin(theta) cos(theta)];

    coords = body.scale*(R*coords')' + body.offset;
    
    

    
function new_configuration(handles)
    
    configs = load_configs();
    
    prompt = {'Enter new configuration name:'};
    dlgtitle = 'New configuration';
    inputs = inputdlg(prompt,dlgtitle);
    if isempty(inputs); return; end %if
    
    stem = inputs{1};

    body_config.name = stem;
    
    dup = 1;
    match = true;
    while match
        
        match = false;
        for i=1:length(configs)
            if strcmp(configs{i}.name,body_config.name)
                match = true;
                break
            end %if
        end %for
        
        if match
            body_config.name = [stem,'_',num2str(dup)];
            dup = dup + 1;
        end %if
        
    end %while
    
    body_config.bodies = {};
    
    save(['configurations',filesep,body_config.name],'body_config');

    
function delete_configuration(handles)
    
    if isempty(handles.listbox1.String); return; end %if
    idx = handles.listbox1.Value;
    
    c = handles.configs{idx};

    answer = questdlg(['Are you sure you want to delete the configuration: "',...
                        c.name,'"?']);

    if strcmp(answer,'Yes')
        delete(['configurations',filesep,c.name,'.mat']);
    end %if

   

    
function select_body(handles,config)

    if isempty(handles.listbox2.String); return; end %if
    idx = handles.listbox2.Value;
    
    body = config.bodies{idx};
    
    handles.checkbox2.Enable = 'on';
    handles.checkbox2.Value = body.flip_horiz;
    
    handles.slider1.Enable = 'on';
    handles.slider1.Value = body.scale;
    handles.text6.String = num2str(body.scale);
    
    handles.slider2.Enable = 'on';
    handles.slider2.Value = body.rotation;
    handles.text8.String = num2str(body.rotation);
    
    handles.slider3.Enable = 'on';
    handles.slider3.Value = body.offset(1);
    handles.text10.String = num2str(body.offset(1));
    
    handles.slider4.Enable = 'on';
    handles.slider4.Value = body.offset(2);
    handles.text12.String = num2str(body.offset(2));
    
    for i=1:length(config.bodies)
        
        set(config.bodies{i}.plot_handle,'LineWidth',1);
        
    end %for
    
    set(config.bodies{idx}.plot_handle,'LineWidth',4);

function body = update_body(handles,body)
    
    body.flip_horiz = handles.checkbox2.Value;
    body.scale = handles.slider1.Value;
    body.rotation = handles.slider2.Value;
    body.offset(1) = handles.slider3.Value;
    body.offset(2) = handles.slider4.Value;
    body.coords = get_body_coords(body);
    
    set(body.plot_handle,'XData',body.coords(:,1));
    set(body.plot_handle,'YData',body.coords(:,2));
    
function body = new_body(handles,config)
    
    body = [];

    indx = listdlg('PromptString',{'Select an aerofoil to add'},...
           'SelectionMode','single','ListString',{'LOAD FROM FILE...',handles.aerofoils.names{:}})-1;
    if isempty(indx); return; end %if
    
    if indx == 0
        
        [file, path] = uigetfile('*');

        if path == 0; return; end %if
        
        try
            fh = fopen([path,file],'r');
            C = textscan(fh,'%f %f','HeaderLines',2);
            fclose(fh);
            
            body.af = [C{1}, C{2}];
            body.af_name = file;
        catch e
            disp(e);
            errordlg('Error while loading aerofoil file.')
        end %try
        
    else
        
        body.af = handles.aerofoils.aerofoils{indx};
        body.af_name = handles.aerofoils.names{indx};
        
    end %if
    
    stem = body.af_name;
    name = stem;
    match = true;
    j = 2;
    while match
        
        match = false;
        for i=1:length(config.bodies)
            if strcmp(config.bodies{i}.name,name)
                match = true;
                break
            end %if
        end%for
        
        if match
            name = [stem,'_',num2str(j)];
            j = j + 1;
        end %if
        
    end %while
    
    
    body.name = name;
    body.flip_horiz = 0;
    body.offset = [0,0];
    body.rotation = 0.0;
    body.scale = 1.0;
    body.coords = get_body_coords(body);

   
function config = delete_body(handles,config)
    
    if isempty(handles.listbox2.String); return; end %if
    bid = handles.listbox2.Value;
    
    config.bodies(bid) = [];
    
    



% --- Outputs from this function are returned to the command line.
function varargout = mesh_generator_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
set_config_edited(handles);

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


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1
% config = select_config(handles);

if isempty(handles.listbox1.String); return; end %if
idx = handles.listbox1.Value;


handles.uipanel2.Visible = 'on';
handles.uipanel5.Visible = 'on';
handles.edit1.String = handles.configs{idx}.name;
    
refreshui_bodies(handles);
handles.configs{idx} = plotting(handles,handles.configs{idx});

guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
new_configuration(handles);
handles.configs = load_configs();
refreshui_configs(handles);
guidata(hObject, handles);


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delete_configuration(handles)
handles.configs = load_configs();
refreshui_configs(handles);
guidata(hObject, handles);


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2

if isempty(handles.listbox1.String); return; end %if
idx = handles.listbox1.Value;

c = handles.configs{idx};

select_body(handles,c);

% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.listbox1.String); return; end %if
idx = handles.listbox1.Value;
    
body = new_body(handles,handles.configs{idx});
if isempty(body); return; end %if

handles.configs{idx}.bodies{end+1} = body;
refreshui_bodies(handles)
handles.configs{idx} = plotting(handles,handles.configs{idx});
guidata(hObject, handles);

set_config_edited(handles)

% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.listbox1.String); return; end %if
cid = handles.listbox1.Value;

handles.configs{cid} = delete_body(handles,handles.configs{cid});
refreshui_bodies(handles);
handles.configs{cid} = plotting(handles,handles.configs{cid});
guidata(hObject,handles);

set_config_edited(handles);


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


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


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfolder('meshes')
    mkdir('meshes');
end %if

if isempty(handles.listbox1.String); return; end %if
cid = handles.listbox1.Value;

config = handles.configs{cid};

boundaries = {};
for i=1:length(config.bodies)
    
    boundaries{end+1} = config.bodies{i}.coords;
    
end %for

nlev = sscanf(handles.popupmenu1.String{handles.popupmenu1.Value},'%d');

commandwindow;
f = waitbar(.0,'Running mesh generator...');
lib.grid_gen('scratch',boundaries,'nlev',nlev);
figure(handles.output);
close(f);

handles.pushbutton13.Enable = 'on';
handles.mesh = lib.load_griduns(['scratch',filesep,'griduns']);
handles.mesh = lib.gen_cellgrid(handles.mesh);

mesh_name = [config.name,'_r',num2str(nlev)];

copyfile(['scratch',filesep,'griduns'],['meshes',filesep,mesh_name]);

handles.text23.String = ['Mesh "',mesh_name,'" generated with ',...
                          num2str(handles.mesh.ncell),...
                          ' cells.'];

handles.mesh.mesh_file = mesh_name;
handles.checkbox1.Value = 1;
handles.configs{cid} = plotting(handles,config);
guidata(hObject,handles);


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.text6.String = num2str(get(hObject,'Value'));

if isempty(handles.listbox1.String); return; end %if
cid = handles.listbox1.Value;

if isempty(handles.listbox2.String); return; end %if
bid = handles.listbox2.Value;

set_config_edited(handles);

handles.configs{cid}.bodies{bid} = update_body(handles,handles.configs{cid}.bodies{bid});

guidata(hObject,handles);

    
% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.text8.String = num2str(get(hObject,'Value'));

if isempty(handles.listbox1.String); return; end %if
cid = handles.listbox1.Value;

if isempty(handles.listbox2.String); return; end %if
bid = handles.listbox2.Value;

set_config_edited(handles);

handles.configs{cid}.bodies{bid} = update_body(handles,handles.configs{cid}.bodies{bid});
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.text10.String = num2str(get(hObject,'Value'));

if isempty(handles.listbox1.String); return; end %if
cid = handles.listbox1.Value;

if isempty(handles.listbox2.String); return; end %if
bid = handles.listbox2.Value;

set_config_edited(handles);

handles.configs{cid}.bodies{bid} = update_body(handles,handles.configs{cid}.bodies{bid});
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider4_Callback(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.text12.String = num2str(get(hObject,'Value'));

if isempty(handles.listbox1.String); return; end %if
cid = handles.listbox1.Value;

if isempty(handles.listbox2.String); return; end %if
bid = handles.listbox2.Value;


set_config_edited(handles);

handles.configs{cid}.bodies{bid} = update_body(handles,handles.configs{cid}.bodies{bid});
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function slider4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.listbox1.String); return; end %if
cid = handles.listbox1.Value;


body_config = handles.configs{cid};
body_config.name = handles.edit1.String;
save(['configurations',filesep,body_config.name],'body_config');

handles.configs = load_configs();
refreshui_configs(handles);
guidata(hObject, handles);

handles.listbox1.Enable = 'on';
handles.pushbutton1.Enable = 'on';
handles.pushbutton2.Enable = 'on';
handles.pushbutton10.Enable = 'off';


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1

if isempty(handles.listbox1.String); return; end %if
cid = handles.listbox1.Value;


handles.configs{cid} = plotting(handles,handles.configs{cid});
guidata(hObject,handles);


% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

run_solver('mesh_file',['meshes',filesep,handles.mesh.mesh_file]);


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2

if isempty(handles.listbox1.String); return; end %if
cid = handles.listbox1.Value;

if isempty(handles.listbox2.String); return; end %if
bid = handles.listbox2.Value;

set_config_edited(handles);

handles.configs{cid}.bodies{bid} = update_body(handles,handles.configs{cid}.bodies{bid});

guidata(hObject,handles);
