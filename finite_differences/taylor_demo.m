function varargout = taylor_demo(varargin)
% MATLAB code for Taylor series demo

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @app_OpeningFcn, ...
                   'gui_OutputFcn',  @app_OutputFcn, ...
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


function refresh(handles)
%% Update plots on user input
%
import TaylorPack.*

ax1 = handles.axes1;
ax2 = handles.axes2;
ax3 = handles.axes3;

cla(ax1);
cla(ax2);

% Get user inputs
n = handles.slider2.Value;
eqn = handles.popupmenu2.Value;
x0 = handles.slider3.Value;

% Plot the function
npts = 50;
[lb, ub] = get_bounds(eqn);
x = point_dist(npts,lb,ub,x0);
y = fx(eqn,x,0);
plot(ax1,x,y,'LineWidth',2);
ylim(ax1,'auto');
xlim(ax1,'auto');
lims = ylim(ax1);
ylim(ax1,lims);

% Evaluate Taylor series approximation around x0
yt = taylors(@(xx,ii) fx(eqn,xx,ii),x0,x,n);

% Plot Taylor series approximation
hold(ax1,'on');
plot(ax1,x,yt,'r--','LineWidth',2);
plot(ax1,x0,fx(eqn,x0,0),'ro','MarkerSize',7);

grid(ax1,'on')
xlabel(ax1,'X');

% Plot error
dx = x-x0;
error = max(eps,abs(yt-y));
loglog(ax2,dx(dx>0),error(dx>0),'LineWidth',2);
grid(ax2,'on');
xlabel(ax2,'X - X_0');
ylim(ax2,[1e-16 1]);

% Plot the Taylor series analytic equation
xlim(ax3,[0,1]);
ylim(ax3,[0,1])
cla(ax3);
eqstr = taylor_equation(n);
text(ax3,0.01,0.5,['$',eqstr,'$'],'Interpreter','latex','FontSize',12);


function reset_ui(handles)
%% Reset UI on selector change
import TaylorPack.*

eqn = handles.popupmenu2.Value;

[lb, ub] = get_bounds(eqn);

handles.slider3.Min = lb;
handles.slider3.Max = ub;
handles.slider3.Value = 0;

handles.text5.String = num2str(0);

%%                 APP INITIALISATION & CALLBACKS

% --- Executes just before app is made visible.
function app_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for app
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

reset_ui(handles);
refresh(handles);

% UIWAIT makes app wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = app_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;


function popupmenu2_Callback(hObject, eventdata, handles)
% function selector

reset_ui(handles);
refresh(handles);

function popupmenu2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function slider2_Callback(hObject, eventdata, handles)
% number of terms slider
%  enforces integer constraint
val=round(hObject.Value);
hObject.Value=val;
handles.text3.String = num2str(val);

refresh(handles);

function slider2_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function slider3_Callback(hObject, eventdata, handles)
% x_0 slider
handles.text5.String = num2str(hObject.Value);
refresh(handles);

function slider3_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
