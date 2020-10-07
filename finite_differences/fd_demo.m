function varargout = fd_demo(varargin)
% FINITE_DIFFERENCES MATLAB code for finite_differences.fig
%      

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @finite_differences_OpeningFcn, ...
                   'gui_OutputFcn',  @finite_differences_OutputFcn, ...
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

% UI handles
ax1 = handles.axes1;
ax2 = handles.axes2;
ax3 = handles.axes3;

% Get user inputs
eqn = handles.popupmenu1.Value;
diffMode = handles.popupmenu2.Value;
diffN = handles.popupmenu3.Value;
nPts = handles.slider1.Value;
dx = step_size(handles.slider3.Value);
x0 = handles.slider2.Value;

% Reset axes
cla(ax1);
if ~handles.checkbox1.Value
    cla(ax2);
end %if
cla(ax3);

% Get finite difference coefficients
[coefs, s] = fd_coefs(diffMode,diffN,nPts);

% Plot chosen function
plot_function(ax1,eqn,x0)

% Sample function @ FD stencil points
fcn = @(xx,ii) fx(eqn,xx,ii);
xfd = x0 + dx*s;
yfd = fcn(xfd,0);
plot(ax1,xfd,yfd,'ro');

% Perform finite difference
grad_fd = fd(fcn,xfd,coefs,diffN);

% Calculate exact analytical gradient
grad = fcn(x0,diffN);

% Calculate error in gradient
error0 = max(eps,abs(grad-grad_fd));
handles.text13.String = num2str(error0,'%.2E');

% Plot error
p = plot(ax2,dx,error0,'ro');
set(get(get(p,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');

% Plot sweep in dx
plot_fd_step_sweep(ax2,x0,coefs,s,eqn,diffN,diffMode,nPts);

% Plot the finite difference symbolic equation
eqstr = fd_equation(diffN,coefs,s);
xlim(ax3,[0,1]);
ylim(ax3,[0,1]);
text(ax3,0.01,0.5,['$',eqstr,'$'],'Interpreter','latex','FontSize',12);


function plot_fd_step_sweep(ax,x0,coefs,s,eqn,diffN,diffMode,nPts)
%% Perform a sweep in step size and plot errors
%
import TaylorPack.*

fcn = @(xx,ii) fx(eqn,xx,ii);

dx_sweep = step_size(linspace(0,1,20));
fd_sweep = zeros(size(dx_sweep));
grad_sweep = zeros(size(dx_sweep));
for i=1:length(dx_sweep)
    xfd = x0 + dx_sweep(i)*s;
    fd_sweep(i) = fd(fcn,xfd,coefs,diffN);
    grad_sweep(i) = fcn(x0,diffN);
end %for

error = max(eps,abs(fd_sweep - grad_sweep));

if diffMode == 1
    leg_str = 'cen-d';
elseif diffMode == 2
    leg_str = 'fwd-d';
else
    leg_str = 'bwd-d';
end %if

leg_str = [leg_str,num2str(diffN),'-N'];
leg_str = [leg_str,num2str(nPts)];

loglog(ax,dx_sweep,error,'.-','LineWidth',2,'DisplayName',leg_str);
hold(ax,'on');

xlabel(ax,'\Delta x');
grid(ax,'on');
legend(ax,'Location','NorthWest');


function plot_function(ax,eqn,x0)
%% Plot the chosen function over a range of values
import TaylorPack.*

npts = 50;
[lb, ub] = get_bounds(eqn);

x = point_dist(npts,lb,ub,x0);
y = fx(eqn,x,0);

plot(ax,x,y,'LineWidth',2);
hold(ax,'on');
plot(ax,x0,fx(eqn,x0,0),'.','MarkerSize',15);
xlabel(ax,'x');
grid(ax,'on');


function reset_ui(handles)
%% Reset user interface on selector change
import TaylorPack.*

eqn = handles.popupmenu1.Value;
diffMode = handles.popupmenu2.Value;
diffN = handles.popupmenu3.Value;

if diffMode == 1
    % Central
    orders = 2:2:10;
    nPts = 2*floor((diffN+1)/2) - 1 + orders;
    
    handles.slider1.Min = min(nPts);
    handles.slider1.Max = max(nPts);
    handles.slider1.SliderStep(1:2) = (nPts(2)-nPts(1))/(nPts(end)-nPts(1));
    handles.slider1.Value = handles.slider1.Min;
    handles.text2.String = handles.slider1.Min;
    
else
    % Forward/backward
    handles.slider1.Min = diffN + 1;
    handles.slider1.Max = diffN + 8;
    handles.slider1.Value = handles.slider1.Min;
    handles.text2.String = handles.slider1.Min;
    handles.slider1.SliderStep(1:2) = 1/(handles.slider1.Max - handles.slider1.Min);
    
end %if

[lb, ub] = get_bounds(eqn);
handles.slider2.Min = lb;
handles.slider2.Max = ub;
if handles.slider2.Value < lb || handles.slider2.Value > ub
    handles.slider2.Value = 0.0;
end %if
handles.text4.String = num2str(handles.slider2.Value);

handles.slider3.Value = 0.95;
handles.text8.String = num2str(step_size(handles.slider3.Value),'%.2E');


function dx = step_size(val)
%% Map [0,1] to a logarithmic range of step sizes
steps = 10.^(-8:0.25:0);
dx = interp1(linspace(0,1,length(steps)),steps,val);


%%              FIGURE INITIALISATION & CALLBACKS

% --- Executes just before finite_differences is made visible.
function finite_differences_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to finite_differences (see VARARGIN)

% Choose default command line output for finite_differences
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

reset_ui(handles);
refresh(handles)

% UIWAIT makes finite_differences wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = finite_differences_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;


function popupmenu1_Callback(hObject, eventdata, handles)
% function-selector menu
reset_ui(handles);
refresh(handles);

function popupmenu1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function slider1_Callback(hObject, eventdata, handles)
% Number of points slider
%  Enforce integer constraint
unit = hObject.SliderStep(1)*(hObject.Max-hObject.Min);
val=floor(hObject.Value);
if (val > hObject.Min) && mod((val-hObject.Min),unit)~=0
    val = round((val-hObject.Min)/unit)*unit + hObject.Min;
    val = min(val,hObject.Max);
end %if
hObject.Value=val;
handles.text2.String = num2str(val);

refresh(handles);

function slider1_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function slider2_Callback(hObject, eventdata, handles)
% x0 slider
handles.text4.String = num2str(hObject.Value);
refresh(handles);

function slider2_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function popupmenu2_Callback(hObject, eventdata, handles)
% difference mode selector
reset_ui(handles);
refresh(handles);

function popupmenu2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function slider3_Callback(hObject, eventdata, handles)
% step size slider
handles.text8.String = num2str(step_size(hObject.Value),'%.2E');
refresh(handles);

function slider3_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function popupmenu3_Callback(hObject, eventdata, handles)
% derivative selector
reset_ui(handles);
refresh(handles);

function popupmenu3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
