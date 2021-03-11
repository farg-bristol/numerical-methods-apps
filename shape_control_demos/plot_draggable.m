function ph = plot_draggable(varargin)
%% Plot an interactive draggable line with a callback function
%
% USAGE:
%  plot([ax],x,y,[linespec],[@callback], [Name-Value args...])
%
% Laurence Kedward 2021
    
    if isa(varargin{1},'matlab.graphics.axis.Axes')

        ax = varargin{1};
        o = 2;

    else

        ax = gca;
        o = 1;

    end %if

    xvals = varargin{o};
    yvals = varargin{o+1};

    o = o + 2;

    args = {};
    if nargin >= o && ischar(varargin{o})

        line_spec_chars = '-:.o+*.x_|sd^v><phymcfrgbwk';

        is_line_spec = all(arrayfun( @(c) any(c==line_spec_chars),varargin{o}));

        if is_line_spec

            args = {varargin{o}};
            o = o + 1;

        end %if

    end %if

    drag_function = [];
    if nargin >= o && isa(varargin{o},'function_handle')

        drag_function = varargin{o};
        o = o + 1;

    end %if

    args = [args,{'hittest','on','buttondownfcn',@btn_down_fcn}];

    if nargin >= o

        args = [args, varargin{o:end}];

    end %if

     ph = plot(ax,xvals,yvals,args{:});

    function btn_down_fcn(src,ev)
        set(ancestor(src,'figure'),'windowbuttonmotionfcn',{@on_drag,src})
        set(ancestor(src,'figure'),'windowbuttonupfcn',@btn_up_fcn)
    end %function

    function btn_up_fcn(fig,ev)
        set(fig,'windowbuttonmotionfcn','')
        set(fig,'windowbuttonupfcn','')
    end %function

    function on_drag(fig,ev,src)
        %%
        % Based on: https://uk.mathworks.com/matlabcentral/answers/340393-is-there-a-way-to-click-and-drag-points-on-a-graph-to-change-it
        %

        %get current axes and coords
        h1=get(src,'Parent');
        coords=get(h1,'currentpoint');

        %get all x and y data 
        x=src.XData;
        y=src.YData;

        %check which data point has the smallest distance to the dragged point
        x_diff=abs(x-coords(1,1,1));
        y_diff=abs(y-coords(1,2,1));
        [~, index]=min(x_diff+y_diff);

        %create new x and y data and exchange coords for the dragged point
        x_new=x;
        y_new=y;
        x_new(index)=coords(1,1,1);
        y_new(index)=coords(1,2,1);

        %update plot
        set(src,'xdata',x_new,'ydata',y_new);

        % User-defined callback
        if ~isempty(drag_function)
            drag_function(x_new,y_new);
        end %if

    end %function

end %function
