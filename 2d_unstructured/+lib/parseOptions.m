function options = parseOptions(defaults,varargin)
%% parseOptions
%   Parse optional settings into default options structure
%
%   INPUTS:
%    - defaults: structure or object containing default fields & values
%    - varargin: structure or name-value pairs containing custom user vals
%
%   OUTPUTS:
%    - options: structure or object with custom user values applied
%
%   EXAMPLE:
%    - For class objects top set public properties:
%           obj = utils.parseOptions(obj,varargin{:});
%
%  Laurence Kedward 2018


if isobject(defaults)
    % Defaults are from object
    defaultFields = properties(defaults);
    
elseif isstruct(defaults)
    % Defaults are in structure
    defaultFields = fieldnames(defaults);
    
else
    % Unknown defaults input
    es.identifier = 'parseOptions:unknownDefaultsFormat';
    es.message = 'Expecting structure or object for defaults.';
    error(es);
    
end %if

% Initial output is default structure / object
options = defaults;

if isempty(varargin)
    return
end %if

if strcmp(varargin{end},'merge')
    varargin(end) = [];
    if isobject(defaults)
        warning('utils:parseOptions','Can''t merge into object');
        doMerge = false;
    else
        doMerge = true;
    end %if
else
    doMerge = false;
end %if

% Need to check again (because varargin modified)
if isempty(varargin)
    return
end %if



% Parse name-value pairs if using
if length(varargin) > 1
    userOptions = [];
    for i=1:2:length(varargin)-1
        if isfield(options,varargin{i}) || isprop(options,varargin{i}) || doMerge
            userOptions.(varargin{i}) = varargin{i+1};
        end %if
    end %for
    
else
    if isstruct(varargin{1})
        userOptions = varargin{1};
    elseif isempty(varargin{1})
        return
    else
        error('utils:parseOptions','Expecting name-value list or options structure.');
    end %if
    
end %if


% Parse user options structure
for i=1:length(defaultFields)
    if isfield(userOptions,defaultFields{i})

        options = copyVal( ...
            options,defaultFields{i},userOptions.(defaultFields{i}));
    
    end %if
end %for

if doMerge
    
    userFields = fieldnames(userOptions);
    for i=1:length(userFields)
        if ~isfield(options,userFields{i})
            options = copyVal( ...
                options, userFields{i}, userOptions.(userFields{i}));
        end %if
    end %for
end %if
    



end %function

function dest = copyVal(dest, destField, val)
%% Recursive value copying
%
%   If val is scalar: dest.(destField) = val
%   If val is a structure: recursively copy field values
%

if ~isfield(dest,destField)
    dest.(destField) = [];
end %if


if isstruct(val)
    
    vFields = fields(val);
    for i=1:length(vFields)
        
        dest.(destField) = copyVal(dest.(destField),vFields{i},val.(vFields{i}));
        
    end %for

else
    
    dest.(destField) = val;
    
end %if


end %function