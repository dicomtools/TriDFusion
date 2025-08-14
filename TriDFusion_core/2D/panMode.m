function panMode(figH, dSeriesOffset, mode)
% PANMODE   Toggle left-drag pan and right-drag vertical zoom on a figure.
%             Restores original mouse callbacks on 'off'.
%
%   panMode(figH, dSeriesOffset, 'on')   – enables:
%       • Left-click + drag → pan (adjPan)
%       • Right-click + vertical drag → zoom (adjZoom)
%
%   panMode(figH, dSeriesOffset, 'off')  – disables both and restores
%       the figure’s original button callbacks.

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
            setappdata(figH, 'PanModeState', state);
            % Install our unified handlers
            set(figH, ...
                'WindowButtonDownFcn',   @btnDown,  ...
                'WindowButtonMotionFcn', [],        ...
                'WindowButtonUpFcn',     @btnUp);

        case 'off'
            % Retrieve state and restore callbacks
            state = getappdata(figH, 'PanModeState');
            if isstruct(state)
                set(figH, ...
                    'WindowButtonDownFcn',   state.origWBDF,  ...
                    'WindowButtonMotionFcn', state.origWBM,   ...
                    'WindowButtonUpFcn',     state.origWBUF);
                rmappdata(figH, 'PanModeState');
            end
            state = struct();

        otherwise
            error('panMode: mode must be ''on'' or ''off''');
    end
end

%% Callback: mouse button down → start pan or zoom
function btnDown(src, evt)
    state = getappdata(src, 'PanModeState');
    sel = get(src, 'SelectionType');
    switch sel
        case 'normal'  % left-click → pan
            state.action = 'pan';
            adjPan(get(src,'CurrentPoint'));
            set(src, 'WindowButtonMotionFcn', @motion);
        case 'alt'     % right-click → zoom
            state.action = 'zoom';
            adjZoom(get(src,'CurrentPoint'));
            set(src, 'WindowButtonMotionFcn', @motion);
        otherwise
            state.action = '';
    end
    setappdata(src, 'PanModeState', state);
end

%% Callback: mouse motion → continue pan or zoom
function motion(src, ~)
    state = getappdata(src, 'PanModeState');
    switch state.action
        case 'pan'
            adjPan();
        case 'zoom'
            adjZoom();
    end
end

%% Callback: mouse button up → end current action
function btnUp(src, evt)
    state = getappdata(src, 'PanModeState');
    state.action = '';
    % Clear motion handler
    set(src, 'WindowButtonMotionFcn', '');
    % Store updated state
    setappdata(src, 'PanModeState', state);
end