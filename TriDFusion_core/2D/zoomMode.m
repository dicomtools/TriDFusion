function zoomMode(figH, dSeriesOffset, mode)
%function zoomMode(figH, dSeriesOffset, mode)
%Ajust 2D zoom using mouse left click, pan on right click.
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

    persistent state;
    if isempty(state)
        state = struct();
    end

    switch lower(mode)
        case 'on'
            % Save original callbacks
            state.origWBDF = get(figH, 'WindowButtonDownFcn');
            state.origWBUF = get(figH, 'WindowButtonUpFcn');
            state.origWBM  = get(figH, 'WindowButtonMotionFcn');
            state.dSeriesOffset = dSeriesOffset;
            state.action = '';
            setappdata(figH, 'ZoomModeState', state);
            % Install our unified handlers
            set(figH, ...
                'WindowButtonDownFcn',   @btnDown,  ...
                'WindowButtonMotionFcn', [],        ...
                'WindowButtonUpFcn',     @btnUp);

        case 'off'
            % Retrieve state and restore callbacks
            state = getappdata(figH, 'ZoomModeState');
            if isstruct(state)
                set(figH, ...
                    'WindowButtonDownFcn',   state.origWBDF,  ...
                    'WindowButtonMotionFcn', state.origWBM,   ...
                    'WindowButtonUpFcn',     state.origWBUF);
                rmappdata(figH, 'ZoomModeState');
            end
            state = struct();

        otherwise
            error('zoomMode: mode must be ''on'' or ''off''');
    end
end

% Callback: mouse button down → start zoom or pan
function btnDown(src, ~)
    state = getappdata(src, 'ZoomModeState');
    sel = get(src, 'SelectionType');
    switch sel
        case 'normal'  % left-click → zoom
            state.action = 'zoom';
            adjZoom(get(src,'CurrentPoint'));
            set(src, 'WindowButtonMotionFcn', @motion);
        case 'alt'     % right-click → pan
            state.action = 'pan';
            adjPan(get(src,'CurrentPoint'));
            set(src, 'WindowButtonMotionFcn', @motion);
        otherwise
            state.action = '';
    end
    setappdata(src, 'ZoomModeState', state);
end

% Callback: mouse motion → continue zoom or pan
function motion(src, ~)
    state = getappdata(src, 'ZoomModeState');
    switch state.action
        case 'zoom'
            adjZoom();
        case 'pan'
            adjPan();
    end
end

% Callback: mouse button up → end current action
function btnUp(src, ~)

    state = getappdata(src, 'ZoomModeState');
    % action = state.action;
    state.action = '';
    % Clear motion handler
    set(src, 'WindowButtonMotionFcn', '');
    % Store updated state
    setappdata(src, 'ZoomModeState', state);

    windowButton('set', 'up');
end