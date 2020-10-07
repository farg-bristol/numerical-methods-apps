function varargout = solver1d(varargin)
%% 1D Burgers equation applet
%
%
% Laurence Kedward, October 2020

% ------ Begin initialization code - DO NOT EDIT -------
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @solver1d_OpeningFcn, ...
                   'gui_OutputFcn',  @solver1d_OutputFcn, ...
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
% ------ End initialization code - DO NOT EDIT ------


function pushbutton2_Callback(hObject, eventdata, handles)
%% 'RUN'/'STOP' Button click
%

if handles.running
    handles.running = false;
    guidata(hObject,handles);
    return
else
    handles.running = true;
    guidata(hObject,handles);
end %if

set_ui(handles);

write_message(handles,'Ready')
write_warning(handles,'')
write_error(handles,'');

ax1 = handles.axes1;
ax3 = handles.axes3;
c = get_config(handles);

% Initial conditions
x = linspace(0,1,c.npts);
c.dx = 1/c.npts;
u0 = init_conditions(x,c.init);
u = u0;

cla(ax1);
linePlot = plot(ax1,x,u,'.-');
hold(ax1,'on');
exactPlot = plot(ax1,x,u0,'--');
grid(ax1,'on');

if (strcmp(c.eqn,'LINEAR_WAVE_EQN'))
    legend(ax1,'u_n','Exact solution');
else
    legend(ax1,'u_n','Initial condition');
end %if

res = 0;
res_convergence = zeros(1,c.max_iter);
resPlot = semilogy(ax3,1:c.max_iter,res_convergence,'.-');
grid(ax3,'on');

% ------ Time-marching loop ------
for n=1:c.max_iter
    
    % Check if stop button clicked
    handles = guidata(hObject);
    if ~handles.running
        reset_ui(hObject,handles);
        return
    end %if
    
    % Calculate u_new 
    try
        switch (c.eqn)
            case ('LINEAR_WAVE_EQN')
                [u_new, dt] = LinearWaveEqn.update_u(u,c);
            case ('INVISCID_BURGERS')
                [u_new, dt] = InviscidBurgersEqn.update_u(u,c);
        end %switch
    catch e
        reset_ui(hObject,handles);
        write_error(handles,e.message)
    end %try
    
    % Calculate residual
    res = sqrt(mean((u_new-u).^2));
    
    % Update u
    u = u_new;
    
    % Update plot of u
    set(linePlot,'YData',u);
    
    % Plot exact solution (linear equation only)
    if (strcmp(c.eqn,'LINEAR_WAVE_EQN'))
        u_exact = LinearWaveEqn.exact_solution(x,c.init,c.wavespeed,n*dt);
        set(exactPlot,'YData',u_exact);
    end %if
    
    % Write convergence info
    msg = ['Timestep (dt)       : ',num2str(dt),newline, ...
           'Iteration           : ',num2str(n),newline, ....
           'RMS residual (log10): ',num2str(log10(res))];
    write_message(handles,msg);
    
    % Check for divergence
    if log10(res) > 0
        write_warning(handles,'WARNING: Positive residual (diverging solution)');
    elseif isnan(res)
        reset_ui(hObject,handles);
        write_error(handles,'ERROR: Solution diverged');
    else
        write_warning(handles,'');
    end %if
       
    % Check for convergence
    if log10(res) < c.min_res
        break;
    end %if
    
    % Update residual plot
    res_convergence(n) = res;
    set(resPlot,'YData',res_convergence);
    
    drawnow;
    pause(1/c.playback_speed);
    
end %for
% ------ End time-marching loop ------

% Write final convergence information
if log10(res) < c.min_res
    msg = '*** SOLVER CONVERGED ***';
       
else
    msg = '*** MAX ITERATIONS ***';
end %if

msg = [msg, newline, ...
        'Iterations performed: ',num2str(n),newline, ....
        'RMS residual (log10): ',num2str(log10(res))];
    
write_message(handles,msg);
reset_ui(hObject,handles);


function set_ui(handles)
%% Refresh user interface when inputs change
%
ax1 = handles.axes1;
ax2 = handles.axes2;
c = get_config(handles);

if strcmp(c.eqn,'LINEAR_WAVE_EQN')
    handles.edit2.Enable = 'on';
else
    handles.edit2.Enable = 'off';
end %if

if strcmp(c.scheme,'FTCS')
    handles.checkbox1.Enable = 'on';
else
    handles.checkbox1.Enable = 'off';
    handles.checkbox1.Value = false;
end %if

cla(ax1);
x = linspace(0,1,c.npts);
u0 = init_conditions(x,c.init);
plot(ax1,x,u0,'--','DisplayName','Initial condition');

cla(ax2);
xlim(ax2,[0,1]);
ylim(ax2,[0,1]);
switch(c.eqn)
    case ('LINEAR_WAVE_EQN')
        eqn_str = LinearWaveEqn.latex_eqn();
    case ('INVISCID_BURGERS')
        eqn_str = InviscidBurgersEqn.latex_eqn();
end %switch
text(ax2,0.1,0.5,eqn_str, ...
             'Interpreter','latex','FontSize',18);

if ~handles.running
    handles.pushbutton2.String = 'Run';
    return
else
    handles.pushbutton2.String = 'Stop';
end %if


function reset_ui(hObject,handles)
%% Reset the run button and state
handles.running = false;
guidata(hObject,handles);
handles.pushbutton2.String = 'Run';


function c = get_config(handles)
%%  Get run configuration from the user interface inputs
%
c.wavespeed = get_number(handles,handles.edit2,'wavespeed');
c.CFL = get_number(handles,handles.edit1,'CFL',[0 inf]);

c.npts = get_number(handles,handles.edit3,'Number of grid points',[0 inf]);
c.max_iter = get_number(handles,handles.edit4,'Maximum iterations',[0 inf]);
c.min_res = get_number(handles,handles.edit5,'Minimum residual',[-15 1]);

switch handles.popupmenu1.Value
    case (1)
        c.eqn = 'LINEAR_WAVE_EQN';
    case (2)
        c.eqn = 'INVISCID_BURGERS';
    
end %switch

switch handles.popupmenu3.Value
    case (1)
        c.scheme = 'FTBS';
    case (2)
        c.scheme = 'FTFS';
    case (3)
        c.scheme = 'FTCS';
    case (4)
        c.scheme = 'UPWIND';
end %switch

switch handles.popupmenu4.Value
    case (1)
        c.init = 'STEP';
    case (2)
        c.init = 'RAMP';
    case (3)
        c.init = 'BUMP';
    case (4)
        c.init = 'SINE';
end %switch

c.artificial_dissipation = handles.checkbox1.Value;

c.playback_speed = get_number(handles,handles.edit8,'Playback speed',[0 1e4]);


function v = get_number(handles,edit_handle,descriptor,bounds)
%% Retrieve a number from the user interface and validate format
%
v = str2double(edit_handle.String);
if isnan(v)
    write_error(handles, ['ERROR: Wrong type for input "',descriptor,'"'])
end %if

if nargin > 3
    if v < bounds(1) || v > bounds(2)
        write_error(handles, ['ERROR: Input "',descriptor,'" is out of bounds ([',num2str(bounds),'])']);
    end %if
end %if


function write_message(handles,msg)
%% Write a message to 'solver outputs' panel
%
handles.text12.String = msg;


function write_warning(handles,msg)
%% Write a warning message to 'solver outputs' panel
%
handles.text15.String = msg;
handles.text15.ForegroundColor = [1 0.41 0.16];


function write_error(handles,msg)
%% Write an error message to 'solver outputs' panel and halt
%
handles.text15.String = msg;
handles.text15.ForegroundColor = 'red';
error(msg);


%% ------------------------- CALLBACKS -------------------------

function solver1d_OpeningFcn(hObject, eventdata, handles, varargin)
%% Executes just before solver1d is made visible.
% Choose default command line output for solver1d
handles.output = hObject;
handles.running = false;

% Update handles structure
guidata(hObject, handles);

% Initialise UI
set_ui(handles);

function varargout = solver1d_OutputFcn(hObject, eventdata, handles) 
%% Outputs from this function are returned to the command line.
varargout{1} = handles.output;

% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
set_ui(handles)

% --- Executes on selection change in popupmenu4.
function popupmenu4_Callback(hObject, eventdata, handles)
set_ui(handles)

% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
set_ui(handles)

function popupmenu1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function popupmenu2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function popupmenu3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit5_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit7_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit8_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function popupmenu4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit1_Callback(hObject, eventdata, handles)

function edit2_Callback(hObject, eventdata, handles)

function edit3_Callback(hObject, eventdata, handles)

function edit4_Callback(hObject, eventdata, handles)

function edit5_Callback(hObject, eventdata, handles)

function edit8_Callback(hObject, eventdata, handles)

function checkbox1_Callback(hObject, eventdata, handles)
