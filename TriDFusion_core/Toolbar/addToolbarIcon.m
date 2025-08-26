function hBtn = addToolbarIcon(panelH, iconFile, hoverIconFile, pressedIconFile, label, tooltip, callbackFcn, varargin)
%function hBtn = addToolbarIcon(panelH, iconFile, hoverIconFile, pressedIconFile, label, tooltip, callbackFcn, varargin)
%Add a blended icon button to a uipanel toolbar.
%
%   hBtn = addToolbarIcon(panelH, iconFile, pressedIconFile, tooltip, callbackFcn)
%   auto–detects indexed/grayscale/truecolor, reads alpha if any,
%   composites transparent areas onto the panel background color,
%   and lays out buttons left-to-right.
%
%   hBtn = addToolbarIcon(...,'Separator',true) adds a 1px separator.
%
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2025, Daniel Lafontaine, on behalf of the TriDFusion development team.
% 
% This file is part of The Triple Dimention Fusion (TriDFusion).
% 
% TriDFusion development has been led by:  Daniel Lafontaine
% 
% TriDFusion is distributed under the terms of the Lesser GNU Public License. 
% 
%     This version of TriDFusion is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
% TriDFusion is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
% without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
% See the GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with TriDFusion.  If not, see <http://www.gnu.org/licenses/>. 

    % Parse optional parameters: separator flag and width

    p = inputParser;
    addParameter(p,'Separator',false,@islogical);
    addParameter(p,'SeparatorWidth',2,@(x) isnumeric(x) && isscalar(x) && x>=0);
    parse(p,varargin{:});
    sep    = p.Results.Separator;
    sepW   = p.Results.SeparatorWidth;
   
    x = getappdata(panelH,'NextIconX');
    if isempty(x)
      x = 5; 
    end
    
    ph = get(panelH,'Position');
    ph = ph(4);
    
    % Draw separator if called

    uiSep = [];
    if sep

        sepH = ph-4;
        uiSep = ...
            uicontrol('Parent', panelH, ...
                      'Style'          , 'text',...
                      'Units'          , 'pixels', ...
                      'Position'       , [x,2,sepW,sepH],...
                      'BackgroundColor', [.6 .6 .6], ...
                      'HitTest'        , 'off');

        if x == 5 
            set(uiSep, 'Visible', 0);
        else
            x = x + sepW + 5;
        end

        setappdata(uiSep, 'OriginalSize', [x,2,sepW,sepH]);        
    end

    d   = viewerToolbarIconSize('get');
    bg  = reshape(get(panelH,'BackgroundColor'),1,1,3);

    C = makeIcon(iconFile,    [d, d], bg, 1);
    D = makeIcon(hoverIconFile,[d, d], bg, 1);
    E = makeIcon(pressedIconFile,[d, d], bg, 1);
    F = makeIcon(iconFile,[d, d], bg, 0.5);
    
    icon.default = C;
    icon.hover   = D;
    icon.hover_orig = D; % For plot edit toolbar
    icon.pressed = E;
    icon.pressed_orig = E; % For plot edit toolbar
    icon.disable = F;
    icon.selectedIcon = [];
    icon.isSelected = false;
    icon.separator = uiSep;
    icon.label = label;

    fig = ancestor(panelH,'figure');
    
    tt = uicontrol(fig, ...
    'Style'             , 'text', ...
    'Tag'               , 'ToolbarTooltip', ...
    'Visible'           , 'off', ...
    'BackgroundColor'   , [1 1 0.9], ...
    'Units'             , 'pixels', ...
    'FontSize'          , 10, ...
    'HorizontalAlignment','left', ...
    'Max'               , 2, ...              % allow 2 lines
    'String'            , '' ...  
    );

    % Wrap to 100 chararter max 
    wrapped = textwrap(tt, {sprintf(' %s',tooltip)}, 100);
        
    % Set the actual strings
    set(tt, 'String', wrapped);
    
    % Hide until hover
    set(tt, 'Visible' , 'off');

    icon.tooltip = tt;

    ax = axes( ...
       'Parent'   , panelH, ...
       'Units'    , 'pixels', ...
       'Position' , [x, floor((ph-d)/2), d, d], ...
       'Visible'  , 'off', ...
       'HitTest'  , 'off'  ...
    );
    
    hBtn = imshow(C, ...
        'Parent'       , ax, ...
        'InitialMagnification',100, ...
        'Border'       ,'tight' ...
    );

    set(hBtn, ...
        'UserData'     , icon, ...
        'ButtonDownFcn', callbackFcn, ...
        'HitTest'      , 'on', ...
        'PickableParts', 'all' ...
    );

    setToolbarObjectTooltipPosition(panelH, hBtn);

    % Advance X for next icon
    setappdata(panelH,'NextIconX', x + d + 5);
    
    set(hBtn, 'Tag', 'toolbarIconBtn');
    setappdata(hBtn, 'OriginalSize', [x, floor((ph-d)/2), d, d]);    


end
