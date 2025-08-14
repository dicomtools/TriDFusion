function setPlaybackToolbar(sVisible)
%function setPlaybackToolbar(sVisible)
%Init and View ON/OFF Playback Toolbar.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2020, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    uiTopToolbar = uiTopToolbarPtr('get');
    if isempty(uiTopToolbar)
        return;
    end

    mViewPlayback = viewPlaybackObject('get');

    if strcmp(sVisible, 'off')
        mViewPlayback.Checked = 'off';
        playback3DToolbar('set', false);
    else
        mViewPlayback.Checked = 'on';
        playback3DToolbar('set', true);
    end

    acPlayback = playbackMenuObject('get');
    if isempty(acPlayback)

        setappdata(uiTopToolbar,'NextIconX',5);
    
        sRootPath  = viewerRootPath('get');
        sIconsPath = sprintf('%s/icons/', sRootPath);
    
        % backward
        mBackward = addToolbarIcon(uiTopToolbar, ...
            fullfile(sIconsPath,'backward_grey.png'), ...
            fullfile(sIconsPath,'backward_blue.png'), ...
            fullfile(sIconsPath,'backward_white.png'), ...
            'Backward', ...
            'Backward', @playbackCallback, ...
            'Separator', true, ... 
            'SeparatorWidth', 2);

        acPlayback{1} = mBackward;

        % play
        mPlay = addToolbarIcon(uiTopToolbar, ...
            fullfile(sIconsPath,'play_grey.png'), ...
            fullfile(sIconsPath,'play_green.png'), ...
            fullfile(sIconsPath,'play_white.png'), ...
            'Play', ...
            'Play', @playbackCallback);   
        acPlayback{2} = mPlay;
    
        % foward
        mFoward = addToolbarIcon(uiTopToolbar, ...
            fullfile(sIconsPath,'foward_grey.png'), ...
            fullfile(sIconsPath,'foward_blue.png'), ...
            fullfile(sIconsPath,'foward_white.png'), ...
            'Foward', ...
            'Foward', @playbackCallback);   
        acPlayback{3} = mFoward;
    
        % record
        mRecord = addToolbarIcon(uiTopToolbar, ...
            fullfile(sIconsPath,'record_grey.png'), ...
            fullfile(sIconsPath,'record_red.png'), ...
            fullfile(sIconsPath,'record_white.png'), ...
            'Record', ...
            'Record', @playbackCallback); 
         acPlayback{4} = mRecord;
   
        % Speed Down
        mSpeedDown = addToolbarIcon(uiTopToolbar, ...
            fullfile(sIconsPath,'arrow-down_grey.png'), ...
            fullfile(sIconsPath,'arrow-down_orange.png'), ...
            fullfile(sIconsPath,'arrow-down_white.png'), ...
            'Speed-Down', ...
            'Speed Down', @playbackCallback); 
        acPlayback{5} = mSpeedDown;
 
        % Speed Up
        mSpeedUp = addToolbarIcon(uiTopToolbar, ...
            fullfile(sIconsPath,'arrow-up_grey.png'), ...
            fullfile(sIconsPath,'arrow-up_orange.png'), ...
            fullfile(sIconsPath,'arrow-up_white.png'), ...
            'Speed-Up', ...
            'Speed Up', @playbackCallback);
        acPlayback{6} = mSpeedUp;
    
        % Zoom Out
        mZoomOut = addToolbarIcon(uiTopToolbar, ...
            fullfile(sIconsPath,'zoom-out_grey.png'), ...
            fullfile(sIconsPath,'zoom-out_blue.png'), ...
            fullfile(sIconsPath,'zoom-out_white.png'), ...
            'Zoom-Out', ...
            'Zoom Out', @playbackCallback);
        acPlayback{7} = mZoomOut;
 
        % Zoom In
        mZoomIn = addToolbarIcon(uiTopToolbar, ...
            fullfile(sIconsPath,'zoom-in_grey.png'), ...
            fullfile(sIconsPath,'zoom-in_blue.png'), ...
            fullfile(sIconsPath,'zoom-in_white.png'), ...
            'Zoom-In', ...
            'Zoom In', @playbackCallback);
        acPlayback{8} = mZoomIn;
    
        % Gate
        mGate = addToolbarIcon(uiTopToolbar, ...
            fullfile(sIconsPath,'time_grey.png'), ...
            fullfile(sIconsPath,'time_light_grey.png'), ...
            fullfile(sIconsPath,'time_white.png'), ...
            'Gate', ...
            'Gate', @playbackCallback); 
        acPlayback{9} = mGate;

        gateIconMenuObject('set', mGate);

        playbackMenuObject('set', acPlayback);


    else
        panelH = uiTopToolbarPtr('get');
 
        bExit = false;
        for i = 1:numel(acPlayback)
            hBtn = acPlayback{i};
            if ishghandle(hBtn)
                if strcmpi(get(hBtn, 'Visible'), sVisible)
                    bExit = true;
                    break;
                end
            end
        end

        if bExit == true
            return;
        end

        setToolbarObjectVisibility(panelH, acPlayback, sVisible);        
       
    end

    function playbackCallback(hObject, ~)

        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true

            sObjectTooltip = strjoin(strtrim(hObject.UserData.tooltip.String));

            switch  sObjectTooltip

                case 'Play'

                    if  multiFrame3DRecord('get') == false

                        icon = get(mPlay, 'UserData');

                        if multiFrame3DPlayback('get') == false

                            set(mPlay, 'CData', icon.pressed);

                            multiFrame3DPlayback('set', true);

                            if mGate.UserData.isSelected == true

                                multiGate3D(mPlay);
                            else
                                multiFrame3D(mPlay);
                            end
                        else
                            set(mPlay, 'CData', icon.default);
                            multiFrame3DPlayback('set', false);
                        end
                    end


                 case 'Foward'

                     if multiFrame3DPlayback('get') == false && ...
                        multiFrame3DRecord('get')   == false

                        origC   = get(mFoward, 'CData');
                        
                        % toggle it on-screen
                        toggleToolbarIcon(mFoward);
                        
                        % force the figure to redraw NOW
                        drawnow;
                        
                        % schedule a one-shot timer to restore the icon after 0.1 s
                        t = timer( ...
                            'StartDelay'   , 0.1, ...
                            'ExecutionMode', 'singleShot', ...
                            'TimerFcn'     , @(~,~) set(mFoward, 'CData', origC) ...
                        );
                        start(t);
                     
                        if mGate.UserData.isSelected == true

                            oneGate3D(sObjectTooltip);
                        else
                            
                            if multiFrame3DIndex('get') == 120

                                multiFrame3DIndex('set', 1);
                             else
                                multiFrame3DIndex('set', multiFrame3DIndex('get')+1);
                             end

                             oneFrame3D();
                        end

                    end


                 case 'Backward'

                     if multiFrame3DPlayback('get') == false && ...
                        multiFrame3DRecord('get')   == false

                        origC   = get(mBackward, 'CData');
                        
                        % toggle it on-screen
                        toggleToolbarIcon(mBackward);
                        
                        % force the figure to redraw NOW
                        drawnow;
                        
                        % schedule a one-shot timer to restore the icon after 0.1 s
                        t = timer( ...
                            'StartDelay'   , 0.1, ...
                            'ExecutionMode', 'singleShot', ...
                            'TimerFcn'     , @(~,~) set(mBackward, 'CData', origC) ...
                        );
                        start(t);

                        if mGate.UserData.isSelected == true

                            oneGate3D(sObjectTooltip);
                        else
                            if multiFrame3DIndex('get') == 1

                               multiFrame3DIndex('set', 120);
                            else
                               multiFrame3DIndex('set', multiFrame3DIndex('get')-1);
                            end

                            oneFrame3D();
                        end
                    end

                     % set(mBackward, 'State', 'off');

                 case 'Record'

                    if multiFrame3DPlayback('get') == false

                        icon = get(mRecord, 'UserData');

                        if multiFrame3DRecord('get') == false

                            set(mRecord, 'CData', icon.pressed);

                            filter = {'*.avi';'*.mp4';'*.gif';'*.dcm';'*.jpg';'*.bmp';'*.png'};
                            info = dicomMetaData('get');

                            sCurrentDir  = viewerRootPath('get');

                            sMatFile = [sCurrentDir '/' 'lastGifDir.mat'];
                            % load last data directory
                            if exist(sMatFile, 'file')

                                load('-mat', sMatFile);
                                if exist('animatedGifLastUsedDir', 'var')
                                   sCurrentDir = animatedGifLastUsedDir;
                                end
                                if sCurrentDir == 0
                                    sCurrentDir = pwd;
                                end
                            end

                            [file, path, indx] = uiputfile(filter, 'Save Images', sprintf('%s/%s_%s_%s_3D_Playback_TriDFusion' , sCurrentDir, cleanString(info{1}.PatientName), cleanString(info{1}.PatientID), cleanString(info{1}.SeriesDescription)) );

                            if file ~= 0

                                multiFrame3DRecord('set', true);

                                if mGate.UserData.isSelected == true

%                                    set(uiSeriesPtr('get'), 'Enable', 'off');
                                    recordMultiGate3D(mRecord, path, file, filter{indx});
                                else
                                    recordMultiFrame3D(mRecord, path, file, filter{indx});
                                end

%                                set(uiSeriesPtr('get'), 'Enable', 'on');
                                multiFrame3DRecord('set', false);
                                set(mRecord, 'CData', icon.default);

                                try
                                    animatedGifLastUsedDir = [path '/'];
                                    save(sMatFile, 'animatedGifLastUsedDir');
                                    
                                catch ME
                                    logErrorToFile(ME); 
                                    progressBar(1 , sprintf('Warning: Cant save file %s', sMatFile));
%                                    h = msgbox(sprintf('Warning: Cant save file %s', sMatFile), 'Warning');
%                                    if integrateToBrowser('get') == true
%                                        sLogo = './TriDFusion/logo.png';
%                                    else
%                                        sLogo = './logo.png';
%                                    end

%                                    javaFrame = get(h, 'JavaFrame');
%                                    javaFrame.setFigureIcon(javax.swing.ImageIcon(sLogo));
                                end
                            else

                                set(mRecord, 'CData', icon.default);
                            end
                        else
                            multiFrame3DRecord('set', false);
                            set(mRecord, 'CData', icon.default);
                        end
                    end

                case 'Speed Down'

                    origC   = get(mSpeedDown, 'CData');
                    
                    % toggle it on-screen
                    toggleToolbarIcon(mSpeedDown);
                    
                    % force the figure to redraw NOW
                    drawnow;
                    
                    % schedule a one-shot timer to restore the icon after 0.1 s
                    t = timer( ...
                        'StartDelay'   , 0.1, ...
                        'ExecutionMode', 'singleShot', ...
                        'TimerFcn'     , @(~,~) set(mSpeedDown, 'CData', origC) ...
                    );
                    start(t);

                    if multiFrame3DSpeed('get') < 2

                        multiFrame3DSpeed('set', multiFrame3DSpeed('get')+0.01);
                    end

                    if isequal(mSpeedDown.CData, mSpeedDown.UserData.pressed)
                        
                        icon = get(mSpeedDown, 'UserData');
                        set(mSpeedDown, 'CData', icon.default);
                    end

                case 'Speed Up'

                    origC   = get(mSpeedUp, 'CData');
                    
                    % toggle it on-screen
                    toggleToolbarIcon(mSpeedUp);
                    
                    % force the figure to redraw NOW
                    drawnow;
                    
                    % schedule a one-shot timer to restore the icon after 0.1 s
                    t = timer( ...
                        'StartDelay'   , 0.1, ...
                        'ExecutionMode', 'singleShot', ...
                        'TimerFcn'     , @(~,~) set(mSpeedUp, 'CData', origC) ...
                    );
                    start(t);

                    if multiFrame3DSpeed('get') > 0.01

                        multiFrame3DSpeed('set', multiFrame3DSpeed('get')-0.01);
                    end                   

                    if isequal(mSpeedUp.CData, mSpeedUp.UserData.pressed)
                        
                        icon = get(mSpeedUp, 'UserData');
                        set(mSpeedUp, 'CData', icon.default);
                    end

                case 'Zoom In'

                    % grab the original icon
                    origC = get(mZoomIn, 'CData');
                    
                    % toggle it on-screen
                    toggleToolbarIcon(mZoomIn);

                    % force the figure to redraw NOW
                    drawnow;
                    
                    % schedule a one-shot timer to restore the icon after 0.1 s
                    t = timer( ...
                        'StartDelay'   , 0.1, ...
                        'ExecutionMode', 'singleShot', ...
                        'TimerFcn'     , @(~,~) set(mZoomIn, 'CData', origC) ...
                    );
                    start(t);

                    multiFrame3DZoom('set', multiFrame3DZoom('get')/1.2);

                    if multiFrame3DZoom('get') > 1.2
                        multiFrame3DZoom('set', multiFrame3DZoom('get')/1.2);
                    end

                    if multiFrame3DPlayback('get') == false && ...
                        multiFrame3DRecord('get')  == false
                        zoom3D('in', 1.2);
                    end

                    initGate3DObject('set', true);

                    if isequal(mZoomIn.CData, mZoomIn.UserData.pressed)

                        icon = get(mZoomIn, 'UserData');
                        set(mZoomIn, 'CData', icon.default);
                    end

                case 'Zoom Out'

                    % grab the original icon
                    origC = get(mZoomOut, 'CData');
                    
                    % toggle it on-screen
                    toggleToolbarIcon(mZoomOut);

                    % force the figure to redraw NOW
                    drawnow;
                    
                    % schedule a one-shot timer to restore the icon after 0.1 s
                    t = timer( ...
                        'StartDelay'   , 0.1, ...
                        'ExecutionMode', 'singleShot', ...
                        'TimerFcn'     , @(~,~) set(mZoomOut, 'CData', origC) ...
                    );
                    start(t);

                    multiFrame3DZoom('set', multiFrame3DZoom('get')*1.2);

                     if multiFrame3DPlayback('get') == false && ...
                        multiFrame3DRecord('get')   == false
                        zoom3D('out', 1.2);
                     end

                     initGate3DObject('set', true);

                     if isequal(mZoomOut.CData, mZoomOut.UserData.pressed)

                        icon = get(mZoomOut, 'UserData');
                        set(mZoomOut, 'CData', icon.default);
                     end

                case 'Gate'
                    
                    icon = get(mGate, 'UserData');

                    multiFrame3DPlayback('set', false);

                    multiFramePlayback('set', false); 

                    if ~isequal(mGate.CData, mGate.UserData.pressed)
                        mGate.UserData.isSelected = true;
                        set(mGate, 'CData', icon.pressed);
                    else
                        mGate.UserData.isSelected = false;                       
                        set(mGate, 'CData', icon.default);
                    end

                    mGate.UserData.selectedIcon = get(mGate,'CData');  
            end
        else

            sObjectTooltip = strjoin(strtrim(hObject.UserData.tooltip.String));

            switch  sObjectTooltip

                case 'Play'

                    if  multiFrameRecord('get') == false

                        icon = get(mPlay, 'UserData');

                        if multiFramePlayback('get') == false
    
                            set(mPlay, 'CData', icon.pressed);

                            multiFramePlayback('set', true);

                            if mGate.UserData.isSelected == true

                                set(uiSeriesPtr('get'), 'Enable', 'off');
                                multiGate(mPlay);
                            else
                                if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 4) ~= 1
                                    multiFrameScreenCapture(mPlay);
                                else
                                    multiFrame(mPlay);
                                end

                            end
                        else
                            set(mPlay, 'CData', icon.default);
                            
                            set(uiSeriesPtr('get'), 'Enable', 'on');
                            multiFramePlayback('set', false);   
                        end
                    end

                 case 'Foward'

                     if multiFramePlayback('get') == false && ...
                        multiFrameRecord('get')   == false

                        origC   = get(mFoward, 'CData');
                        
                        % toggle it on-screen
                        toggleToolbarIcon(mFoward);
                        
                        % force the figure to redraw NOW
                        drawnow;
                        
                        % schedule a one-shot timer to restore the icon after 0.1 s
                        t = timer( ...
                            'StartDelay'   , 0.1, ...
                            'ExecutionMode', 'singleShot', ...
                            'TimerFcn'     , @(~,~) set(mFoward, 'CData', origC) ...
                        );
                        start(t);

                        if mGate.UserData.isSelected == true

                            if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 3) ~= 1

                                oneGate(sObjectTooltip);
                            end
                               
                        else
                            if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 4) ~= 1

                                screenCaptureFrame('Next');
                            else
                                if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 3) ~= 1
                                    
                                    oneFrame(sObjectTooltip);
                                end
                            end
                        end
                       
                        if isequal(mFoward.CData, mFoward.UserData.pressed)
    
                            icon = get(mFoward, 'UserData');
                            set(mFoward, 'CData', icon.default);
                        end
                     end           


                 case 'Backward'

                     if multiFrame3DPlayback('get') == false && ...
                        multiFrame3DRecord('get')   == false

                        origC   = get(mBackward, 'CData');
                        
                        % toggle it on-screen
                        toggleToolbarIcon(mBackward);
                        
                        % force the figure to redraw NOW
                        drawnow;
                        
                        % schedule a one-shot timer to restore the icon after 0.1 s
                        t = timer( ...
                            'StartDelay'   , 0.1, ...
                            'ExecutionMode', 'singleShot', ...
                            'TimerFcn'     , @(~,~) set(mBackward, 'CData', origC) ...
                        );
                        start(t);

                        if mGate.UserData.isSelected == true
                           
                            if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 3) ~= 1

                                oneGate(sObjectTooltip);
                            end
                        else
                            if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 4) ~= 1
                                screenCaptureFrame('Previous');
                            else
                                if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 3) ~= 1
                                    oneFrame(sObjectTooltip);
                                end
                            end
                        end

                        if isequal(mBackward.CData, mBackward.UserData.pressed)
    
                            icon = get(mBackward, 'UserData');
                            set(mBackward, 'CData', icon.default);
                        end

                     end                     

                 case 'Record'

                    if multiFramePlayback('get') == false

                        icon = get(mRecord, 'UserData');

                        if multiFrameRecord('get') == false

                            toggleToolbarIcon(mRecord);
                            
                            set(mRecord, 'CData', icon.pressed);
                             
                            drawnow;

                            filter = {'*.avi';'*.mp4';'*.gif';'*.dcm';'*.jpg';'*.bmp';'*.png'};
                            info = dicomMetaData('get');

                            sCurrentDir  = viewerRootPath('get');

                            sMatFile = [sCurrentDir '/' 'lastGifDir.mat'];
                            % load last data directory
                            if exist(sMatFile, 'file')

                                load(sMatFile, 'animatedGifLastUsedDir');
                                if exist('animatedGifLastUsedDir', 'var')

                                   sCurrentDir = animatedGifLastUsedDir;
                                end
                                
                                if sCurrentDir == 0
                                    sCurrentDir = pwd;
                                end
                            end

                            [file, path, indx] = uiputfile(filter, 'Save Images', sprintf('%s/%s_%s_%s_2D_Playback_TriDFusion' , sCurrentDir, cleanString(info{1}.PatientName), cleanString(info{1}.PatientID), cleanString(info{1}.SeriesDescription)) );

                            if file ~= 0

                                multiFrameRecord('set', true);

                                if mGate.UserData.isSelected == true
                                    set(uiSeriesPtr('get'), 'Enable', 'off');
                                    recordMultiGate(mRecord, path, file, filter{indx});
                                else
                                    recordMultiFrame(mRecord, path, file, filter{indx});
                                end

                                set(uiSeriesPtr('get'), 'Enable', 'on');
                                multiFrameRecord('set', false);
                                set(mRecord, 'CData', icon.default);

                                try
                                    animatedGifLastUsedDir = [path '/'];
                                    save(sMatFile, 'animatedGifLastUsedDir');

                                catch ME
                                    logErrorToFile(ME); 
                                    progressBar(1 , sprintf('Warning: Cant save file %s', sMatFile));
                                end
                            else

                                set(mRecord, 'CData', icon.default);
                            end
                        else
                            multiFrameRecord('set', false);
                            set(mRecord, 'CData', icon.default);
                        end
                    end

                case 'Speed Down'

                    origC   = get(mSpeedDown, 'CData');
                    
                    % toggle it on-screen
                    toggleToolbarIcon(mSpeedDown);
                    
                    % force the figure to redraw NOW
                    drawnow;
                    
                    % schedule a one-shot timer to restore the icon after 0.1 s
                    t = timer( ...
                        'StartDelay'   , 0.1, ...
                        'ExecutionMode', 'singleShot', ...
                        'TimerFcn'     , @(~,~) set(mSpeedDown, 'CData', origC) ...
                    );
                    start(t);
               
                    if multiFrameSpeed('get') < 2

                        multiFrameSpeed('set', multiFrameSpeed('get')+0.01);
                    end

                    if isequal(mSpeedDown.CData, mSpeedDown.UserData.pressed)

                        icon = get(mSpeedDown, 'UserData');
                        set(mSpeedDown, 'CData', icon.default);
                    end

                case 'Speed Up'

                    % grab the original icon
                    origC = get(mSpeedUp, 'CData');
                    
                    % toggle it on-screen
                    toggleToolbarIcon(mSpeedUp);

                    % force the figure to redraw NOW
                    drawnow;
                    
                    % schedule a one-shot timer to restore the icon after 0.1 s
                    t = timer( ...
                        'StartDelay'   , 0.1, ...
                        'ExecutionMode', 'singleShot', ...
                        'TimerFcn'     , @(~,~) set(mSpeedUp, 'CData', origC) ...
                    );
                    start(t);

                    if size(dicomBuffer('get'), 3) ~=1

                        if multiFrameSpeed('get') > 0.01

                            multiFrameSpeed('set', multiFrameSpeed('get')-0.01);
                        end
                    end

                    if isequal(mSpeedUp.CData, mSpeedUp.UserData.pressed)

                        icon = get(mSpeedUp, 'UserData');
                        set(mSpeedUp, 'CData', icon.default);
                    end
 
                case 'Zoom In'
                    
                    % grab the original icon
                    origC = get(mZoomIn, 'CData');
                    
                    % toggle it on-screen
                    toggleToolbarIcon(mZoomIn);

                    % force the figure to redraw NOW
                    drawnow;
                    
                    % schedule a one-shot timer to restore the icon after 0.1 s
                    t = timer( ...
                        'StartDelay'   , 0.1, ...
                        'ExecutionMode', 'singleShot', ...
                        'TimerFcn'     , @(~,~) set(mZoomIn, 'CData', origC) ...
                    );
                    start(t);

                    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

                    pAxe = gca(fiMainWindowPtr('get'));

                    multiFrameZoom('set', 'out', 1);

                    if multiFrameZoom('get', 'axe') ~= pAxe

                        multiFrameZoom('set', 'in', 1);
                    end

                    dZFactor = multiFrameZoom('get', 'in')+0.025;

                    multiFrameZoom('set', 'in', dZFactor);

                    switch pAxe
    
                        case axePtr('get', [], dSeriesOffset)
    
                            axesHandle = axePtr('get', [], dSeriesOffset);
    
                        case axes1Ptr('get', [], dSeriesOffset)
    
                            axesHandle = axes1Ptr('get', [], dSeriesOffset);
    
                        case axes2Ptr('get', [], dSeriesOffset)
    
                            axesHandle = axes2Ptr('get', [], dSeriesOffset);
                            
                        case axes3Ptr('get', [], dSeriesOffset)
    
                            axesHandle = axes3Ptr('get', [], dSeriesOffset);
                            
                        case axesMipPtr('get', [], dSeriesOffset)
    
                            axesHandle = axesMipPtr('get', [], dSeriesOffset);
                            
                        otherwise
    
                            axesHandle = axes3Ptr('get', [], dSeriesOffset);
    
                    end 

                    if isempty(getappdata(axesHandle, 'matlab_graphics_resetplotview'))
                        
                        initAxePlotView(axesHandle);
                    end

                    % Get the current axes limits
                    xLim = get(axesHandle, 'XLim');
                    yLim = get(axesHandle, 'YLim');

                    % Handle infinite limits by replacing with reasonable defaults
        
                    if any(isinf(xLim))
                       
                        xData = get(axesHandle.Children, 'XData');  % Assuming children are the plotted data
                        xLim = [min(cell2mat(xData),[],"all"), max(cell2mat(xData),[],"all")];      % Set to the range of the data
                    end
                    
                    if any(isinf(yLim))
                   
                        yData = get(axesHandle.Children, 'YData');  % Assuming children are the plotted data
                        yLim = [min(cell2mat(yData),[],"all"), max(cell2mat(yData),[],"all")];      % Set to the range of the data
                    end

                    % Compute the center of the current axes
                    xCenter = mean(xLim);
                    yCenter = mean(yLim);
    
                    % Calculate the new limits based on the zoom factor
                    newXLim = xCenter + (xLim - xCenter) / dZFactor;  % Zoom in/out
                    newYLim = yCenter + (yLim - yCenter) / dZFactor;
    
                    % Apply the new limits to the axes
                    set(axesHandle, 'XLim', newXLim, 'YLim', newYLim);
                    
                    multiFrameZoom('set', 'axe', axesHandle);

                    if isequal(mZoomIn.CData, mZoomIn.UserData.pressed)

                        icon = get(mZoomIn, 'UserData');
                        set(mZoomIn, 'CData', icon.default);
                    end

                case 'Zoom Out'

                    % grab the original icon
                    origC = get(mZoomOut, 'CData');
                    
                    % toggle it on-screen
                    toggleToolbarIcon(mZoomOut);

                    % force the figure to redraw NOW
                    drawnow;
                    
                    % schedule a one-shot timer to restore the icon after 0.1 s
                    t = timer( ...
                        'StartDelay'   , 0.1, ...
                        'ExecutionMode', 'singleShot', ...
                        'TimerFcn'     , @(~,~) set(mZoomOut, 'CData', origC) ...
                    );
                    start(t);

                    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

                    pAxe = gca(fiMainWindowPtr('get'));


                    multiFrameZoom('set', 'in', 1);

                    if multiFrameZoom('get', 'axe') ~= pAxe

                        multiFrameZoom('set', 'out', 1);
                    end

                    dZFactor = multiFrameZoom('get', 'out');

                    if dZFactor > 0.025

                        dZFactor = dZFactor-0.025;

                        multiFrameZoom('set', 'out', dZFactor);
                    end

                    switch pAxe
    
                        case axePtr('get', [], dSeriesOffset)
    
                            axesHandle = axePtr('get', [], dSeriesOffset);
    
                        case axes1Ptr('get', [], dSeriesOffset)
    
                            axesHandle = axes1Ptr('get', [], dSeriesOffset);
    
                        case axes2Ptr('get', [], dSeriesOffset)
    
                            axesHandle = axes2Ptr('get', [], dSeriesOffset);
                            
                        case axes3Ptr('get', [], dSeriesOffset)
    
                            axesHandle = axes3Ptr('get', [], dSeriesOffset);
                            
                        case axesMipPtr('get', [], dSeriesOffset)
    
                            axesHandle = axesMipPtr('get', [], dSeriesOffset);
                            
                        otherwise
    
                            axesHandle = axes3Ptr('get', [], dSeriesOffset);
    
                    end 

                    if isempty(getappdata(axesHandle, 'matlab_graphics_resetplotview')) 
                        
                        initAxePlotView(axesHandle);
                    end

                    % Get the current axes limits
                    xLim = get(axesHandle, 'XLim');
                    yLim = get(axesHandle, 'YLim');
                    
                    % Handle infinite limits by replacing with reasonable defaults
        
                    if any(isinf(xLim))
                       
                        xData = get(axesHandle.Children, 'XData');  % Assuming children are the plotted data
                        xLim = [min(cell2mat(xData),[],"all"), max(cell2mat(xData),[],"all")];      % Set to the range of the data
                    end
                    
                    if any(isinf(yLim))
                   
                        yData = get(axesHandle.Children, 'YData');  % Assuming children are the plotted data
                        yLim = [min(cell2mat(yData),[],"all"), max(cell2mat(yData),[],"all")];      % Set to the range of the data
                    end 

                    % Compute the center of the current axes
                    xCenter = mean(xLim);
                    yCenter = mean(yLim);
    
                    % Calculate the new limits based on the zoom factor
                    newXLim = xCenter + (xLim - xCenter) / dZFactor;  % Zoom in/out
                    newYLim = yCenter + (yLim - yCenter) / dZFactor;
    
                    % Apply the new limits to the axes
                    set(axesHandle, 'XLim', newXLim, 'YLim', newYLim);
                    
                    multiFrameZoom('set', 'axe', axesHandle);

                    if isequal(mZoomOut.CData, mZoomOut.UserData.pressed)

                        icon = get(mZoomOut, 'UserData');
                        set(mZoomOut, 'CData', icon.default);
                    end

                case 'Gate'

                    icon = get(mGate, 'UserData');

                    multiFrame3DPlayback('set', false);

                    multiFramePlayback('set', false); 

                    if ~isequal(mGate.CData, mGate.UserData.pressed)
                        mGate.UserData.isSelected = true;
                        set(mGate, 'CData', icon.pressed);
                   else
                        mGate.UserData.isSelected = false;                       
                        set(mGate, 'CData', icon.default);
                    end

                    mGate.UserData.selectedIcon = get(mGate,'CData');           
             end

        end

    end
end
