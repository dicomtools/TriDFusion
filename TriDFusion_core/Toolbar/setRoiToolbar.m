function setRoiToolbar(sVisible)
%function setRoiToolbar(sVisible)
%Init and View ON/OFF ROIs Toolbar.
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

    mViewRoi = viewRoiObject('get');

    if strcmp(sVisible, 'off')
        mViewRoi.Checked = 'off';
        roiToolbar('set', false);
    else
        mViewRoi.Checked = 'on';
        roiToolbar('set', true);
    end

    acRoiMenu = roiMenuObject('get');
    if isempty(acRoiMenu)
        sRootPath  = viewerRootPath('get');
        sIconsPath = sprintf('%s/icons/', sRootPath);

        % draw line
        mMeasure = addToolbarIcon(uiTopToolbar, ...
            fullfile(sIconsPath,'measure_grey.png'), ...
            fullfile(sIconsPath,'measure_cyan.png'), ...
            fullfile(sIconsPath,'measure_white.png'), ...
            'Line', ...
            'Line Measurement (M): Draw a line by clicking and dragging. Measurement appears, and right-click to view the profile.', ...
            @drawlineCallback, ...
            'Separator', true, ... 
            'SeparatorWidth', 2);
        acRoiMenu{1} = mMeasure;
    
        % freehand
        mFreehand = addToolbarIcon(uiTopToolbar, ...
            fullfile(sIconsPath,'freehand_grey.png'), ...
            fullfile(sIconsPath,'freehand_cyan.png'), ...
            fullfile(sIconsPath,'freehand_white.png'), ...
            'Freehand', ...
            'Draw Freehand (D): Draw a freeform shape by clicking and dragging; release to finish.', ...
            @drawfreehandCallback);
        acRoiMenu{2} = mFreehand;
    
        % polygon
        mPolygon = addToolbarIcon(uiTopToolbar, ...
            fullfile(sIconsPath,'polygon_grey.png'), ...
            fullfile(sIconsPath,'polygon_cyan.png'), ...
            fullfile(sIconsPath,'polygon_white.png'), ...
            'Polygon', ...
            'Draw Polygon (P): Draw a polygon by clicking to set each vertex; double-click to complete.', ...
            @drawpolygonCallback);
        acRoiMenu{3} = mPolygon;
    
        % circle
        mCircle = addToolbarIcon(uiTopToolbar, ...
            fullfile(sIconsPath,'circle_grey.png'), ...
            fullfile(sIconsPath,'circle_cyan.png'), ...
            fullfile(sIconsPath,'circle_white.png'), ...
            'Circle', ...
            'Draw Circle', ...
            @drawcircleCallback);  
        acRoiMenu{4} = mCircle;
    
        % elipse
        mEllipse = addToolbarIcon(uiTopToolbar, ...
            fullfile(sIconsPath,'elipse_grey.png'), ...
            fullfile(sIconsPath,'elipse_cyan.png'), ...
            fullfile(sIconsPath,'elipse_white.png'), ...
            'Elipse', ...
            'Draw Elipse', ...
            @drawellipseCallback);  
        acRoiMenu{5} = mEllipse;
    
        % rectangle
        mRectangle = addToolbarIcon(uiTopToolbar, ...
            fullfile(sIconsPath,'rectangle_grey.png'), ...
            fullfile(sIconsPath,'rectangle_cyan.png'), ...
            fullfile(sIconsPath,'rectangle_white.png'), ...
            'Rectangle', ...
            'Draw Rectangle', ...
            @drawrectangleCallback);      
        acRoiMenu{6} = mRectangle;
    
        % Sphere
        mSphere = addToolbarIcon(uiTopToolbar, ...
            fullfile(sIconsPath,'sphere_grey.png'), ...
            fullfile(sIconsPath,'sphere_cyan.png'), ...
            fullfile(sIconsPath,'sphere_white.png'), ...
            'Sphere', ...
            'Draw Sphere (E): Click on the image to create a sphere. Modify its diameter from the View/Contour Panel.', ...
            @drawsphereCallback); 
        acRoiMenu{7} = mSphere;
    
        % Click voi
        mClickVoi = addToolbarIcon(uiTopToolbar, ...
            fullfile(sIconsPath,'clickvoi_grey.png'), ...
            fullfile(sIconsPath,'clickvoi_cyan.png'), ...
            fullfile(sIconsPath,'clickvoi_white.png'), ...
            'Click-VOI', ...
            'Click-VOI (V): Create a VOI by clicking on the image. Adjust it relative to the maximum value in the View/Contour Panel.', ...
            @drawClickVoiCallback); 
        acRoiMenu{8} = mClickVoi;
    
        % Infinite
        mInfinite = addToolbarIcon(uiTopToolbar, ...
            fullfile(sIconsPath,'infinite_grey.png'), ...
            fullfile(sIconsPath,'infinite_light_grey.png'), ...
            fullfile(sIconsPath,'infinite_white.png'), ...
            'Infinite', ...
            'Infinite mode', ...
            @setContinuousCallback);
        acRoiMenu{9} = mInfinite;
    
        % Interpolate
        mInterpolate = addToolbarIcon(uiTopToolbar, ...
            fullfile(sIconsPath,'interpolate_grey.png'), ...
            fullfile(sIconsPath,'interpolate_cyan.png'), ...
            fullfile(sIconsPath,'interpolate_white.png'), ...
            'Interpolate', ...
            'Interpolate (X): Generate VOI by interpolating between ROIs.', ...
            @setInterpolateCallback); 
        acRoiMenu{10} = mInterpolate;
    
        % Farthest distances
        mFarthest = addToolbarIcon(uiTopToolbar, ...
            fullfile(sIconsPath,'farthest_grey.png'), ...
            fullfile(sIconsPath,'farthest_light_grey.png'), ...
            fullfile(sIconsPath,'farthest_cyan.png'), ...
            'Farthest', ...
            'View Farthest Distances.', ...
            @viewFarthestDistancesCallback); 
        acRoiMenu{11} = mFarthest;
    
        % Brush
        m2DBrush = addToolbarIcon(uiTopToolbar, ...
            fullfile(sIconsPath,'brush_grey.png'), ...
            fullfile(sIconsPath,'brush_cyan.png'), ...
            fullfile(sIconsPath,'brush_white.png'), ...
            '2D-Brush', ...
            '2D Brush (B): Click on the image to activate the brush. Hold Ctrl and scroll to adjust brush diameter.', ...
            @set2DBrushCallback); 
        acRoiMenu{12} = m2DBrush;
    
        % Knife
        m2DKnife = addToolbarIcon(uiTopToolbar, ...
            fullfile(sIconsPath,'knife_grey.png'), ...
            fullfile(sIconsPath,'knife_light_grey.png'), ...
            fullfile(sIconsPath,'knife_white.png'), ...
            'Knife', ...
            'Knife (K): Split the contour into two objects by drawing a line across it.', ...
            @set2DScissorCallback); 
        acRoiMenu{13} = m2DKnife;
        
        % Statistics
        mStatistics = addToolbarIcon(uiTopToolbar, ...
            fullfile(sIconsPath,'statistics_grey.png'), ...
            fullfile(sIconsPath,'statistics_light_grey.png'), ...
            fullfile(sIconsPath,'statistics_white.png'), ...
            'Statistics', ...
            'Display Statistics.', ...
            @figRoiDialogCallback); 
        acRoiMenu{14} = mStatistics;

        roiMenuObject('set', acRoiMenu);
    else
        panelH = uiTopToolbarPtr('get');
 
        bExit = false;
        for i = 1:numel(acRoiMenu)
            hBtn = acRoiMenu{i};
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

        setToolbarObjectVisibility(panelH, acRoiMenu, sVisible);

    end

    function releaseRoiAxeWait(pMenu)

        axeClicked('set', true);
        uiresume(fiMainWindowPtr('get'));

        set(mMeasure  , 'CData', mMeasure.UserData.default);
        set(mFreehand , 'CData', mFreehand.UserData.default);
        set(mPolygon  , 'CData', mPolygon.UserData.default);
        set(mCircle   , 'CData', mCircle.UserData.default);
        set(mEllipse  , 'CData', mEllipse.UserData.default);
        set(mRectangle, 'CData', mRectangle.UserData.default);
        set(mSphere   , 'CData', mSphere.UserData.default);
        set(mClickVoi , 'CData', mClickVoi.UserData.default);   

        set(pMenu, 'CData', pMenu.UserData.pressed);

    end

    function drawlineCallback(~,~)

        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true || ...
           isVsplash('get')          == true
            % set(t8, 'State', 'off');
            
            set(mMeasure, 'CData', mMeasure.UserData.default);
            return;
        end

        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

%               releaseRoiAxeWait(t8);
    % robotReleaseKey();
        % axeClicked('set', true);
        % uiresume(fiMainWindowPtr('get'));

        % if strcmpi(get(t8, 'State'), 'off')
        if isequal(mMeasure.CData, mMeasure.UserData.pressed)

 %           robotReleaseKey();

            % set(t8, 'State', 'off');
            % roiSetAxeBorder(false);
            set(mMeasure, 'CData', mMeasure.UserData.default);

            windowButton('set', 'up');
            mouseFcn('set');
            mainToolBarEnable('on');
            setCrossVisibility(true);

            return;
        end

        releaseRoiAxeWait(mMeasure);

%         robotReleaseKey();

        setCrossVisibility(false);

        % triangulateCallback();

        doWhileContinuous = true;
        while doWhileContinuous == true

            if contourVisibilityRoiPanelValue('get') == false

                contourVisibilityRoiPanelValue('set', true);
                set(chkContourVisibilityPanelObject('get'), 'Value', true);

                % refreshImages();

                if size(dicomBuffer('get', [], dSeriesOffset), 3) ~= 1

                    plotRotatedRoiOnMip(axesMipPtr('get', [], dSeriesOffset), dicomBuffer('get', [], dSeriesOffset), mipAngle('get'));
                end
            end

     %       w=waitforbuttonpress;
            axeClicked('set', false);
            doWhile = true;
            while doWhile == true
                uiwait(fiMainWindowPtr('get'));
                if axeClicked('get') == true
                    doWhile = false;
                    if strcmpi(windowButton('get'), 'up')
                        doWhileContinuous = false;
                    end
        %            axeClicked('set', false);
                end
            end

            if ~isvalid(mMeasure)
                return;
            end

            % if strcmpi(get(t8, 'State'), 'off')
            if isequal(mMeasure.CData, mMeasure.UserData.default)
                return;
            end
     %       if w == 0
            if  strcmpi(windowButton('get'), 'down')

                atRoiInputBack = roiTemplate('get', dSeriesOffset);
                % atVoiInputBack = voiTemplate('get', dSeriesOffset);

                robotClick();

                pAxe = getAxeFromMousePosition(dSeriesOffset);

                switch pAxe

                    case axePtr('get', [], dSeriesOffset)
                    case axes1Ptr('get', [], dSeriesOffset)
                    case axes2Ptr('get', [], dSeriesOffset)
                    case axes3Ptr('get', [], dSeriesOffset)

                    otherwise
                        return;
                end

                mainToolBarEnable('off');
                mouseFcn('reset');

                % roiSetAxeBorder(true, pAxe);

         %       while strcmpi(get(t8, 'State'), 'on')

                    a = drawline(pAxe, 'Color', [0.0000, 0.9608, 0.8275], 'lineWidth', 1, 'Tag', num2str(generateUniqueNumber(false)), 'LabelVisible', 'on');
                    a.LabelVisible = 'on';
                    if ~isvalid(mMeasure)
                        return;
                    end

                    % if strcmpi(get(t8, 'State'), 'off')
                    if isequal(mMeasure.CData, mMeasure.UserData.default)
                        % roiSetAxeBorder(false);

                   %     windowButton('set', 'up');
                   %     mouseFcn('set');
                   %     mainToolBarEnable('on');
                   %     setCrossVisibility(1);

                        return;
                    end

                    dLength = computeRoiLineLength(a);
                    a.Label = [num2str(dLength) ' mm'];

                    addRoi(a, dSeriesOffset, 'Unspecified');

%                    setVoiRoiSegPopup();

                    uimenu(a.UIContextMenu, 'Label', 'Copy Contour' , 'UserData', a, 'Callback', @copyRoiCallback, 'Separator', 'on');
                    uimenu(a.UIContextMenu, 'Label', 'Paste Contour', 'UserData', a, 'Callback', @pasteRoiCallback);
                    uimenu(a.UIContextMenu, 'Label', 'Paste Mirror', 'UserData', a, 'Callback', @pasteMirroirRoiCallback);

                    uimenu(a.UIContextMenu,'Label', 'Snap To Circles'   , 'UserData',a, 'Callback',@snapLinesToCirclesCallback, 'Separator', 'on');
                    uimenu(a.UIContextMenu,'Label', 'Snap To Rectangles', 'UserData',a, 'Callback',@snapLinesToRectanglesCallback);

                    uimenu(a.UIContextMenu,'Label', 'Edit Label' , 'UserData',a, 'Callback',@editLabelCallback, 'Separator', 'on');

                    uimenu(a.UIContextMenu,'Label', 'Hide/View Label', 'UserData',a, 'Callback',@hideViewLabelCallback);
                    uimenu(a.UIContextMenu,'Label', 'Edit Color'     , 'UserData',a, 'Callback',@editColorCallback);

                    constraintMenu(a);

                    cropMenu(a);

                    uimenu(a.UIContextMenu,'Label', 'Display Statistics' , 'UserData',a, 'Callback',@figRoiDialogCallback, 'Separator', 'on');

%                    set(fiMainWindowPtr('get'), 'WindowScrollWheelFcn' , @wheelScroll);
                    % refreshImages();

                    if size(dicomBuffer('get', [], dSeriesOffset), 3) ~= 1

                        plotRotatedRoiOnMip(axesMipPtr('get', [], dSeriesOffset), dicomBuffer('get', [], dSeriesOffset), mipAngle('get'));
                    end

                    % if strcmpi(get(tContinuous, 'State'), 'off')
                    if isequal(mInfinite.CData, mInfinite.UserData.default)

                        doWhileContinuous = false;
                    end

         %       end

                % roiSetAxeBorder(false);

                % Set undo event

                atRoiInput = roiTemplate('get', dSeriesOffset);
                % atVoiInput = voiTemplate('get', dSeriesOffset);

                dUID = generateUniqueNumber(false);

                roiTemplateEvent('add', dSeriesOffset, atRoiInputBack, atRoiInput, dUID);
                % voiTemplateEvent('add', dSeriesOffset, atVoiInputBack, atVoiInput, dUID);

                enableUndoVoiRoiPanel();

                % End set undo event

                windowButton('set', 'up');
                mouseFcn('set');
                mainToolBarEnable('on');
            end
        end

        % set(t8, 'State', 'off');
        set(mMeasure, 'CData', mMeasure.UserData.default);

        setCrossVisibility(true);

    end

    function drawfreehandCallback(~, ~)

        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true || ...
           isVsplash('get')          == true

            set(mFreehand, 'CData', mFreehand.UserData.default);
            return;
        end

        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

        % releaseRoiAxeWait(t);

        % robotReleaseKey();
        % axeClicked('set', true);
        % uiresume(fiMainWindowPtr('get'));

        % if strcmpi(get(t, 'State'), 'off')
        if isequal(mFreehand.CData, mFreehand.UserData.pressed)
%                   robotReleaseKey();

            % set(t, 'State', 'off');
            % roiSetAxeBorder(false);
            set(mFreehand, 'CData', mFreehand.UserData.default);

            windowButton('set', 'up');
            mouseFcn('set');
            mainToolBarEnable('on');
            setCrossVisibility(true);

            return;
        end

        releaseRoiAxeWait(mFreehand);

%
%               robotReleaseKey();

        setCrossVisibility(false);

        % triangulateCallback();

        doWhileContinuous = true;
        while doWhileContinuous == true

            if contourVisibilityRoiPanelValue('get') == false

                contourVisibilityRoiPanelValue('set', true);
                set(chkContourVisibilityPanelObject('get'), 'Value', true);

                % refreshImages();

                if size(dicomBuffer('get', [], dSeriesOffset), 3) ~= 1

                    plotRotatedRoiOnMip(axesMipPtr('get', [], dSeriesOffset), dicomBuffer('get', [], dSeriesOffset), mipAngle('get'));
                end
            end

     %       w=waitforbuttonpress;

            axeClicked('set', false);

            % if bGetAxeFromMousePosition == true

                doWhile = true;
            % else
            %     doWhile = false;
            % end

            while doWhile == true
                uiwait(fiMainWindowPtr('get'));
                if axeClicked('get') == true
                    doWhile = false;
                    if strcmpi(windowButton('get'), 'up')
                        doWhileContinuous = false;
                    end
                end
            end

            if ~isvalid(mFreehand)
                return;
            end

            % if strcmpi(get(t, 'State'), 'off')
            if isequal(mFreehand.CData, mFreehand.UserData.default)
                return;
            end

%import java.awt.event.*;
%mouse = Robot;
%mouse.mouseRelease(InputEvent.BUTTON3_MASK);
% mouse.mousePress(InputEvent.BUTTON3_MASK);

     %       if w == 0
            if  strcmpi(windowButton('get'), 'down')

                atRoiInputBack = roiTemplate('get', dSeriesOffset);
                % atVoiInputBack = voiTemplate('get', dSeriesOffset);

                robotClick();

    %                 gca = getAxeFromMousePosition(get(uiSeriesPtr('get'), 'Value'));
                pAxe = getAxeFromMousePosition(dSeriesOffset);

                switch pAxe

                    case axePtr('get', [], dSeriesOffset)
                    case axes1Ptr('get', [], dSeriesOffset)
                    case axes2Ptr('get', [], dSeriesOffset)
                    case axes3Ptr('get', [], dSeriesOffset)

                    otherwise
                        return;
                end

                mainToolBarEnable('off');
                mouseFcn('reset');

                % roiSetAxeBorder(true, pAxe);

   %              while strcmpi(get(t, 'State'), 'on')

                a = drawfreehand(pAxe, ...
                                'Smoothing'     , 1, ...
                                'Color'         , [0.0000, 0.9608, 0.8275], ...
                                'LineWidth'     , 1, ...
                                'Label'         , roiLabelName(), ...
                                'LabelVisible'  , 'off', ...
                                'Tag'           , num2str(generateUniqueNumber(false)), ...
                                'FaceSelectable', 1, ...
                                'FaceAlpha'     , 0 ...
                                );

                if numel(a.Position) >2

                    a.FaceAlpha = roiFaceAlphaValue('get');

                    a.Waypoints(:) = false;
    %test hf=a;
                    if ~isvalid(mFreehand)

                        return;
                    end

                    % if strcmpi(get(t, 'State'), 'off')
                    if isequal(mFreehand.CData, mFreehand.UserData.default)

                        % roiSetAxeBorder(false);

                 %       windowButton('set', 'up');
                 %       mouseFcn('set');
                 %       mainToolBarEnable('on');
                 %       setCrossVisibility(1);

                        return;
                    end

                    addRoi(a, dSeriesOffset, 'Unspecified');

                    addRoiMenu(a);

                    % addlistener(a, 'WaypointAdded'  , @waypointEvents);
                    % addlistener(a, 'WaypointRemoved', @waypointEvents);


% %                     voiDefaultMenu(a);
% %
% % %                    setVoiRoiSegPopup();
% %
% %                     roiDefaultMenu(a);
% %
% %                     uimenu(a.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData',a, 'Callback', @hideViewFaceAlhaCallback);
% %                     uimenu(a.UIContextMenu,'Label', 'Clear Waypoints' , 'UserData',a, 'Callback', @clearWaypointsCallback);
% %
% %                     constraintMenu(a);
% %
% %                     cropMenu(a);
% %
% %                     uimenu(a.UIContextMenu,'Label', 'Display Statistics' , 'UserData',a, 'Callback',@figRoiDialogCallback, 'Separator', 'on');

%                    set(fiMainWindowPtr('get'), 'WindowScrollWheelFcn' , @wheelScroll);
     %               refreshImages();

                    if size(dicomBuffer('get', [], dSeriesOffset), 3) ~= 1

                        plotRotatedRoiOnMip(axesMipPtr('get', [], dSeriesOffset), dicomBuffer('get', [], dSeriesOffset), mipAngle('get'));
                    end

                    % if strcmpi(get(tContinuous, 'State'), 'off')
                    if isequal(mInfinite.CData, mInfinite.UserData.default)

                        doWhileContinuous = false;
                    end

                    % if strcmpi(get(tInterpolate, 'State'), 'on')
                    if isequal(mInterpolate.CData, mInterpolate.UserData.pressed)

                        interpolateROIsByTag(a.Tag, lastRoiTag());
                    end
             %   end
                else
                    delete(a);
                end

                % roiSetAxeBorder(false);

                % Set undo event

                atRoiInput = roiTemplate('get', dSeriesOffset);
                % atVoiInput = voiTemplate('get', dSeriesOffset);

                dUID = generateUniqueNumber(false);

                roiTemplateEvent('add', dSeriesOffset, atRoiInputBack, atRoiInput, dUID);
                % voiTemplateEvent('add', dSeriesOffset, atVoiInputBack, atVoiInput, dUID);

                enableUndoVoiRoiPanel();

                % End set undo event

                windowButton('set', 'up');
                mouseFcn('set');
                mainToolBarEnable('on');

            end
        end

        % set(t, 'State', 'off');
        set(mFreehand, 'CData', mFreehand.UserData.default);

        setCrossVisibility(true);

    end

    function drawcircleCallback(~,~)

        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true || ...
           isVsplash('get')          == true

           % set(t2, 'State', 'off');
            set(mCircle, 'CData', mCircle.UserData.default);
           return;
        end

        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

%               releaseRoiAxeWait(t2);
        % robotReleaseKey();
        % axeClicked('set', true);
        % uiresume(fiMainWindowPtr('get'));

        % if strcmpi(get(t2, 'State'), 'off')
        if isequal(mCircle.CData, mCircle.UserData.pressed)
%                    robotReleaseKey();

           % set(t2, 'State', 'off');
            set(mCircle, 'CData', mCircle.UserData.default);
            % roiSetAxeBorder(false);

            windowButton('set', 'up');
            mouseFcn('set');
            mainToolBarEnable('on');
            setCrossVisibility(true);

            return;
        end

        releaseRoiAxeWait(mCircle);

%               robotReleaseKey();

        setCrossVisibility(false);

        % triangulateCallback();

        doWhileContinuous = true;
        while doWhileContinuous == true

            if contourVisibilityRoiPanelValue('get') == false

                contourVisibilityRoiPanelValue('set', true);
                set(chkContourVisibilityPanelObject('get'), 'Value', true);

                % refreshImages();

                if size(dicomBuffer('get', [], dSeriesOffset), 3) ~= 1

                    plotRotatedRoiOnMip(axesMipPtr('get', [], dSeriesOffset), dicomBuffer('get', [], dSeriesOffset), mipAngle('get'));
                end
            end

   %         w = waitforbuttonpress;
            axeClicked('set', false);

            doWhile = true;
            while doWhile == true
                uiwait(fiMainWindowPtr('get'));
                if axeClicked('get') == true
                    doWhile = false;
                    if strcmpi(windowButton('get'), 'up')
                        doWhileContinuous = false;
                    end
                end
            end

            if ~isvalid(mCircle)
                return;
            end

            % if strcmpi(get(t2, 'State'), 'off')
            if isequal(mCircle.CData, mCircle.UserData.default)
                return;
            end

    %        if w == 0
            if  strcmpi(windowButton('get'), 'down')

                atRoiInputBack = roiTemplate('get', dSeriesOffset);
                % atVoiInputBack = voiTemplate('get', dSeriesOffset);

                robotClick();

                pAxe = getAxeFromMousePosition(dSeriesOffset);

                switch pAxe

                    case axePtr('get', [], dSeriesOffset)
                    case axes1Ptr('get', [], dSeriesOffset)
                    case axes2Ptr('get', [], dSeriesOffset)
                    case axes3Ptr('get', [], dSeriesOffset)

                    otherwise
                        return;
                end

                mainToolBarEnable('off');
                mouseFcn('reset');

                % roiSetAxeBorder(true, pAxe);

          %      while strcmpi(get(t2, 'State'), 'on')

                % hListener = addlistener(fiMainWindowPtr('get'), 'WaitStatus', 'PostSet', @(src, event) checkWaitStatus(src));

                a = drawcircle(pAxe, ...
                               'Color'         , [0.0000, 0.9608, 0.8275], ...
                               'lineWidth'     , 1, ...
                               'Label'         , roiLabelName(), ...
                               'LabelVisible'  , 'off', ...
                               'Tag'           , num2str(generateUniqueNumber(false)), ...
                               'FaceSelectable', 1, ...
                               'FaceAlpha'     , 0 ...
                               );

                % if numel(a.Position) >2

                    a.FaceAlpha = roiFaceAlphaValue('get');

                    % delete(hListener);

                    if ~isvalid(mCircle)
                        return;
                    end

                    % if strcmpi(get(t2, 'State'), 'off')
                    if isequal(mCircle.CData, mCircle.UserData.default)
                       % roiSetAxeBorder(false);

    %                            windowButton('set', 'up');
    %                            mouseFcn('set');
    %                            mainToolBarEnable('on');
    %                            setCrossVisibility(1);

                        return;
                    end

    %test he=a;
    %test addlistener(he,'MovingROI', @(varargin)editorROIMoving(he, hf));
    %test addlistener(he,'ROIMoved', @(varargin)editFreehand(hf, he));

                    addRoi(a, dSeriesOffset, 'Unspecified');

                    addRoiMenu(a);

    %                    setVoiRoiSegPopup();
                    % voiDefaultMenu(a);
                    %
                    % roiDefaultMenu(a);
                    %
                    % uimenu(a.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData',a, 'Callback', @hideViewFaceAlhaCallback);
                    %
                    % constraintMenu(a);
                    %
                    % cropMenu(a);
                    %
                    % uimenu(a.UIContextMenu,'Label', 'Display Statistics' , 'UserData',a, 'Callback',@figRoiDialogCallback, 'Separator', 'on');

    %                    set(fiMainWindowPtr('get'), 'WindowScrollWheelFcn' , @wheelScroll);
                    % refreshImages();

                    if size(dicomBuffer('get', [], dSeriesOffset), 3) ~= 1

                        plotRotatedRoiOnMip(axesMipPtr('get', [], dSeriesOffset), dicomBuffer('get', [], dSeriesOffset), mipAngle('get'));
                    end

                    % if strcmpi(get(tContinuous, 'State'), 'off')
                    if isequal(mInfinite.CData, mInfinite.UserData.default)

                        doWhileContinuous = false;
                    end

                   % if strcmpi(get(tInterpolate, 'State'), 'on')
                    if isequal(mInterpolate.CData, mInterpolate.UserData.pressed)

                        interpolateROIsByTag(a.Tag, lastRoiTag());
                    end

            %    end
                % else
                %     delete(a);
                % end

                % roiSetAxeBorder(false);

                % Set undo event

                atRoiInput = roiTemplate('get', dSeriesOffset);
                % atVoiInput = voiTemplate('get', dSeriesOffset);

                dUID = generateUniqueNumber(false);

                roiTemplateEvent('add', dSeriesOffset, atRoiInputBack, atRoiInput, dUID);
                % voiTemplateEvent('add', dSeriesOffset, atVoiInputBack, atVoiInput, dUID);

                enableUndoVoiRoiPanel();

                % End set undo event

                windowButton('set', 'up');
                mouseFcn('set');
                mainToolBarEnable('on');
            end
        end

       % set(t2, 'State', 'off');
        set(mCircle, 'CData', mCircle.UserData.default);

        setCrossVisibility(true);
    end

%            function drawcuboidCallback(~,~)
%
%                setCrossVisibility(0);

%                w = waitforbuttonpress;

%                if w == 0
%                    mainToolBarEnable('off');
%                    mouseFcn('reset');

%                    roiSetAxeBorder(1);

%                    a = drawcuboid(gca, 'Color', [0.0000, 0.9608, 0.8275], 'lineWidth', 1);
%                    set(t4, 'State', 'off');

%                    uimenu(a.UIContextMenu,'Label', 'Crop Inside' , 'UserData',a, 'Callback',@cropInsideCallback, 'Separator', 'on');
%                    uimenu(a.UIContextMenu,'Label', 'Crop Outside', 'UserData',a, 'Callback',@cropOutsideCallback);
%                    uimenu(a.UIContextMenu,'Label', 'Crop Inside all slices'    , 'UserData',a, 'Callback',@cropInsideAllSlicesCallback, 'Separator', 'on');
%                    uimenu(a.UIContextMenu,'Label', 'Crop Outside all slices'   , 'UserData',a, 'Callback',@cropOutsideAllSlicesCallback);

%                    roiSetAxeBorder(0);

%                    windowButton('set', 'up');
%                    mouseFcn('set');
%                    mainToolBarEnable('on');
%                end

%                setCrossVisibility(1);

%            end


    function drawellipseCallback(~,~)

        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true || ...
           isVsplash('get')          == true

            % set(t5, 'State', 'off');
            set(mEllipse, 'CData', mEllipse.UserData.default);
            return;
        end

        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

%             releaseRoiAxeWait(t5);
        % robotReleaseKey();
        % axeClicked('set', true);
        % uiresume(fiMainWindowPtr('get'));

       % if strcmpi(get(t5, 'State'), 'off')
        if isequal(mEllipse.CData, mEllipse.UserData.pressed)
            
%                    robotReleaseKey();

          %  set(t5, 'State', 'off');
            set(mEllipse, 'CData', mEllipse.UserData.default);
            % roiSetAxeBorder(false);

            windowButton('set', 'up');
            mouseFcn('set');
            mainToolBarEnable('on');
            setCrossVisibility(true);

            return;
        end

        releaseRoiAxeWait(mEllipse);

%              robotReleaseKey();

        setCrossVisibility(false);

        % triangulateCallback();

        doWhileContinuous = true;
        while doWhileContinuous == true

            if contourVisibilityRoiPanelValue('get') == false

                contourVisibilityRoiPanelValue('set', true);
                set(chkContourVisibilityPanelObject('get'), 'Value', true);

                % refreshImages();

                if size(dicomBuffer('get', [], dSeriesOffset), 3) ~= 1

                    plotRotatedRoiOnMip(axesMipPtr('get', [], dSeriesOffset), dicomBuffer('get', [], dSeriesOffset), mipAngle('get'));
                end
            end

            axeClicked('set', false);

            doWhile = true;
            while doWhile == true
                uiwait(fiMainWindowPtr('get'));
                if axeClicked('get') == true
                    doWhile = false;
                    if strcmpi(windowButton('get'), 'up')
                        doWhileContinuous = false;
                    end
                end
            end

            if ~isvalid(mEllipse)
                return;
            end

          %  if strcmpi(get(t5, 'State'), 'off')
            if isequal(mEllipse.CData, mEllipse.UserData.default)
                return;
            end

%                w = waitforbuttonpress;

%                if w == 0
            if  strcmpi(windowButton('get'), 'down')

                atRoiInputBack = roiTemplate('get', dSeriesOffset);
                % atVoiInputBack = voiTemplate('get', dSeriesOffset);

                robotClick();

                pAxe = getAxeFromMousePosition(dSeriesOffset);

                switch pAxe

                    case axePtr('get', [], dSeriesOffset)
                    case axes1Ptr('get', [], dSeriesOffset)
                    case axes2Ptr('get', [], dSeriesOffset)
                    case axes3Ptr('get', [], dSeriesOffset)

                    otherwise
                        return;
                end

                mainToolBarEnable('off');
                mouseFcn('reset');

                % roiSetAxeBorder(true, pAxe);

         %       while strcmpi(get(t5, 'State'), 'on')

                    a = drawellipse(pAxe, ...
                                    'Color'         , [0.0000, 0.9608, 0.8275], ...
                                    'lineWidth'     , 1, ...
                                    'Label'         , roiLabelName(), ...
                                    'LabelVisible'  , 'off', ...
                                    'Tag'           , num2str(generateUniqueNumber(false)), ...
                                    'FaceSelectable', 1, ...
                                    'FaceAlpha'     , 0 ...
                                    );
                    a.FaceAlpha = roiFaceAlphaValue('get');

                    if ~isvalid(mEllipse)
                        return;
                    end

                   % if strcmpi(get(t5, 'State'), 'off')
                    if isequal(mEllipse.CData, mEllipse.UserData.default)
                        % roiSetAxeBorder(false);

%                            windowButton('set', 'up');
%                            mouseFcn('set');
%                            mainToolBarEnable('on');
%                            setCrossVisibility(1);

                        return;
                    end

                    addRoi(a, dSeriesOffset, 'Unspecified');

                    addRoiMenu(a);

%                    setVoiRoiSegPopup();
                    % voiDefaultMenu(a);
                    %
                    % roiDefaultMenu(a);
                    %
                    % uimenu(a.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData',a, 'Callback', @hideViewFaceAlhaCallback);
                    %
                    % constraintMenu(a);
                    %
                    % cropMenu(a);
                    %
                    % uimenu(a.UIContextMenu,'Label', 'Display Statistics' , 'UserData',a, 'Callback',@figRoiDialogCallback, 'Separator', 'on');

%                    set(fiMainWindowPtr('get'), 'WindowScrollWheelFcn' , @wheelScroll  );
                    % refreshImages();

                    if size(dicomBuffer('get', [], dSeriesOffset), 3) ~= 1

                        plotRotatedRoiOnMip(axesMipPtr('get', [], dSeriesOffset), dicomBuffer('get', [], dSeriesOffset), mipAngle('get'));
                    end

                   % if strcmpi(get(tContinuous, 'State'), 'off')
                    if isequal(mInfinite.CData, mInfinite.UserData.default)

                        doWhileContinuous = false;
                    end

                 %   if strcmpi(get(tInterpolate, 'State'), 'on')
                    if isequal(mInterpolate.CData, mInterpolate.UserData.pressed)

                        interpolateROIsByTag(a.Tag, lastRoiTag());
                    end
            %    end

                % roiSetAxeBorder(false);

                % Set undo event

                atRoiInput = roiTemplate('get', dSeriesOffset);
                % atVoiInput = voiTemplate('get', dSeriesOffset);

                dUID = generateUniqueNumber(false);

                roiTemplateEvent('add', dSeriesOffset, atRoiInputBack, atRoiInput, dUID);
                % voiTemplateEvent('add', dSeriesOffset, atVoiInputBack, atVoiInput, dUID);

                enableUndoVoiRoiPanel();

                % End set undo event

                windowButton('set', 'up');
                mouseFcn('set');
                mainToolBarEnable('on');
            end
        end

       % set(t5, 'State', 'off');
        set(mEllipse, 'CData', mEllipse.UserData.default);

        setCrossVisibility(true);
    end

    function drawrectangleCallback(~,~)

        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true || ...
           isVsplash('get')          == true
           % set(t3, 'State', 'off');
            set(mRectangle, 'CData', mRectangle.UserData.default);
            return;
        end

        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

%             releaseRoiAxeWait(t3);
        % robotReleaseKey();
        % axeClicked('set', true);
        % uiresume(fiMainWindowPtr('get'));

      %  if strcmpi(get(t3, 'State'), 'off')
        if isequal(mRectangle.CData, mRectangle.UserData.pressed)
%                    robotReleaseKey();

          %  set(t3, 'State', 'off');
            set(mRectangle, 'CData', mRectangle.UserData.default);
            % roiSetAxeBorder(false);

            windowButton('set', 'up');
            mouseFcn('set');
            mainToolBarEnable('on');
            setCrossVisibility(true);

            return;
        end

        releaseRoiAxeWait(mRectangle);

%          robotReleaseKey();

        setCrossVisibility(false);

        % triangulateCallback();

        doWhileContinuous = true;
        while doWhileContinuous == true

            if contourVisibilityRoiPanelValue('get') == false

                contourVisibilityRoiPanelValue('set', true);
                set(chkContourVisibilityPanelObject('get'), 'Value', true);

                % refreshImages();

                if size(dicomBuffer('get', [], dSeriesOffset), 3) ~= 1

                    plotRotatedRoiOnMip(axesMipPtr('get', [], dSeriesOffset), dicomBuffer('get', [], dSeriesOffset), mipAngle('get'));
                end
            end

            axeClicked('set', false);

            doWhile = true;
            while doWhile == true
                uiwait(fiMainWindowPtr('get'));
                if axeClicked('get') == true
                    doWhile = false;
                    if strcmpi(windowButton('get'), 'up')
                        doWhileContinuous = false;
                    end
                end
            end

            if ~isvalid(mRectangle)
                return;
            end

           % if strcmpi(get(t3, 'State'), 'off')
            if isequal(mRectangle.CData, mRectangle.UserData.default)
                return;
            end

    %        w = waitforbuttonpress;

    %        if w == 0
            if  strcmpi(windowButton('get'), 'down')

                atRoiInputBack = roiTemplate('get', dSeriesOffset);
                % atVoiInputBack = voiTemplate('get', dSeriesOffset);

                robotClick();

                pAxe = getAxeFromMousePosition(dSeriesOffset);

                switch pAxe

                    case axePtr('get', [], dSeriesOffset)
                    case axes1Ptr('get', [], dSeriesOffset)
                    case axes2Ptr('get', [], dSeriesOffset)
                    case axes3Ptr('get', [], dSeriesOffset)

                    otherwise
                        return;
                end

                mainToolBarEnable('off');
                mouseFcn('reset');

                % roiSetAxeBorder(true, pAxe);

            %    while strcmpi(get(t3, 'State'), 'on')

                a = drawrectangle(pAxe, ...
                                  'Rotatable'     , false, ...
                                  'Color'         , [0.0000, 0.9608, 0.8275], ...
                                  'lineWidth'     , 1, ...
                                  'Label'         , roiLabelName(), ...
                                  'LabelVisible'  , 'off', ...
                                  'Tag'           , num2str(generateUniqueNumber(false)), ...
                                  'FaceSelectable', 1, ...
                                  'FaceAlpha'     , 0 ...
                                  );
                a.FaceAlpha = roiFaceAlphaValue('get');

                if ~isvalid(mRectangle)
                    return;
                end

               % if strcmpi(get(t3, 'State'), 'off')
                if isequal(mRectangle.CData, mRectangle.UserData.default)
                   % roiSetAxeBorder(false);

%                            windowButton('set', 'up');
%                            mouseFcn('set');
%                            mainToolBarEnable('on');
%                            setCrossVisibility(1);

                    return;
                end

                addRoi(a, dSeriesOffset, 'Unspecified');

                addRoiMenu(a);

%                    setVoiRoiSegPopup();
                % voiDefaultMenu(a);
                %
                % roiDefaultMenu(a);
                %
                % uimenu(a.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData',a, 'Callback', @hideViewFaceAlhaCallback);
                %
                % constraintMenu(a);
                %
                % cropMenu(a);
                %
                % uimenu(a.UIContextMenu,'Label', 'Display Statistics' , 'UserData',a, 'Callback',@figRoiDialogCallback, 'Separator', 'on');

%                    set(fiMainWindowPtr('get'), 'WindowScrollWheelFcn' , @wheelScroll);
                % refreshImages();

                if size(dicomBuffer('get', [], dSeriesOffset), 3) ~= 1

                    plotRotatedRoiOnMip(axesMipPtr('get', [], dSeriesOffset), dicomBuffer('get', [], dSeriesOffset), mipAngle('get'));
                end

               % if strcmpi(get(tContinuous, 'State'), 'off')
                if isequal(mInfinite.CData, mInfinite.UserData.default)

                    doWhileContinuous = false;
                end

                if isequal(mInterpolate.CData, mInterpolate.UserData.pressed)
               % if strcmpi(get(tInterpolate, 'State'), 'on')

                    interpolateROIsByTag(a.Tag, lastRoiTag());
                end
          %      end

                % roiSetAxeBorder(false);

                % Set undo event

                atRoiInput = roiTemplate('get', dSeriesOffset);
                % atVoiInput = voiTemplate('get', dSeriesOffset);

                dUID = generateUniqueNumber(false);

                roiTemplateEvent('add', dSeriesOffset, atRoiInputBack, atRoiInput, dUID);
                % voiTemplateEvent('add', dSeriesOffset, atVoiInputBack, atVoiInput, dUID);

                enableUndoVoiRoiPanel();

                % End set undo event

                windowButton('set', 'up');
                mouseFcn('set');
                mainToolBarEnable('on');
            end
        end

       % set(t3, 'State', 'off');
        set(mRectangle, 'CData', mRectangle.UserData.default);

        setCrossVisibility(true);
    end

    function drawpolygonCallback(~, ~)

        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true || ...
           isVsplash('get')          == true

           % set(t6, 'State', 'off');
            set(mPolygon, 'CData', mPolygon.UserData.default);
            return;
        end

        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

        % robotReleaseKey();
        % axeClicked('set', true);
        % uiresume(fiMainWindowPtr('get'));

      %  if strcmpi(get(t6, 'State'), 'off')
        if isequal(mPolygon.CData, mPolygon.UserData.pressed)
  %          robotReleaseKey();

            set(mPolygon, 'CData', mPolygon.UserData.default);
           % set(t6, 'State', 'off');
            % roiSetAxeBorder(false);

            windowButton('set', 'up');
            mouseFcn('set');
            mainToolBarEnable('on');
            setCrossVisibility(1);

            return;
        end

        releaseRoiAxeWait(mPolygon);

%             robotReleaseKey();

        setCrossVisibility(false);

        % triangulateCallback();

        doWhileContinuous = true;
        while doWhileContinuous == true

            if contourVisibilityRoiPanelValue('get') == false

                contourVisibilityRoiPanelValue('set', true);
                set(chkContourVisibilityPanelObject('get'), 'Value', true);

                % refreshImages();

                if size(dicomBuffer('get', [], dSeriesOffset), 3) ~= 1

                    plotRotatedRoiOnMip(axesMipPtr('get', [], dSeriesOffset), dicomBuffer('get', [], dSeriesOffset), mipAngle('get'));
                end
            end

            axeClicked('set', false);

            doWhile = true;
            while doWhile == true
                uiwait(fiMainWindowPtr('get'));
                if axeClicked('get') == true
                    doWhile = false;
                    if strcmpi(windowButton('get'), 'up')
                        doWhileContinuous = false;
                    end
                end
            end

            if ~isvalid(mPolygon)
                return;
            end

           % if strcmpi(get(t6, 'State'), 'off')
            if isequal(mPolygon.CData, mPolygon.UserData.default)
               return;
            end

%               w = waitforbuttonpress;

%            if w == 0
            if  strcmpi(windowButton('get'), 'down')

                atRoiInputBack = roiTemplate('get', dSeriesOffset);
                % atVoiInputBack = voiTemplate('get', dSeriesOffset);

                robotClick();
%                 gca = getAxeFromMousePosition(get(uiSeriesPtr('get'), 'Value'));

                pAxe = getAxeFromMousePosition(dSeriesOffset);

                switch pAxe

                    case axePtr('get', [], dSeriesOffset)
                    case axes1Ptr('get', [], dSeriesOffset)
                    case axes2Ptr('get', [], dSeriesOffset)
                    case axes3Ptr('get', [], dSeriesOffset)

                    otherwise
                        return;
                end

                mainToolBarEnable('off');
                mouseFcn('reset');

                % roiSetAxeBorder(true, pAxe);

            %    while strcmpi(get(t6, 'State'), 'on')

                a = drawpolygon(pAxe, ...
                                'Color'         , [0.0000, 0.9608, 0.8275], ...
                                'lineWidth'     , 1, ...
                                'Label'         , roiLabelName(), ...
                                'LabelVisible'  , 'off', ...
                                'Tag'           , num2str(generateUniqueNumber(false)), ...
                                'FaceSelectable', 1, ...
                                'FaceAlpha'     , 0 ...
                                );

                if numel(a.Position) >2

                    a.FaceAlpha = roiFaceAlphaValue('get');

                    if ~isvalid(mPolygon)
                        return;
                    end

                   % if strcmpi(get(t6, 'State'), 'off')
                    if isequal(mPolygon.CData, mPolygon.UserData.default)
                       % roiSetAxeBorder(false);

    %                            windowButton('set', 'up');
    %                            mouseFcn('set');
    %                            mainToolBarEnable('on');
    %                            setCrossVisibility(1);

                        return;
                    end

                    addRoi(a, dSeriesOffset, 'Unspecified');

                    addRoiMenu(a);

    %                    setVoiRoiSegPopup();
                    % voiDefaultMenu(a);
                    %
                    % roiDefaultMenu(a);
                    %
                    % uimenu(a.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData',a, 'Callback', @hideViewFaceAlhaCallback);
                    %
                    % constraintMenu(a);
                    %
                    % cropMenu(a);
                    %
                    %
                    % uimenu(a.UIContextMenu,'Label', 'Display Statistics' , 'UserData',a, 'Callback',@figRoiDialogCallback, 'Separator', 'on');

    %                    set(fiMainWindowPtr('get'), 'WindowScrollWheelFcn' , @wheelScroll);
                    % refreshImages();

                    if size(dicomBuffer('get', [], dSeriesOffset), 3) ~= 1

                        plotRotatedRoiOnMip(axesMipPtr('get', [], dSeriesOffset), dicomBuffer('get', [], dSeriesOffset), mipAngle('get'));
                    end

                   % if strcmpi(get(tContinuous, 'State'), 'off')
                    if isequal(mInfinite.CData, mInfinite.UserData.default)

                        doWhileContinuous = false;
                    end

                   % if strcmpi(get(tInterpolate, 'State'), 'on')
                    if isequal(mInterpolate.CData, mInterpolate.UserData.pressed)

                        interpolateROIsByTag(a.Tag, lastRoiTag());
                    end

                 %   end
                else
                    delete(a);
                end

                % roiSetAxeBorder(false);

                % Set undo event

                atRoiInput = roiTemplate('get', dSeriesOffset);
                % atVoiInput = voiTemplate('get', dSeriesOffset);

                dUID = generateUniqueNumber(false);

                roiTemplateEvent('add', dSeriesOffset, atRoiInputBack, atRoiInput, dUID);
                % voiTemplateEvent('add', dSeriesOffset, atVoiInputBack, atVoiInput, dUID);

                enableUndoVoiRoiPanel();

                % End set undo event

                windowButton('set', 'up');
                mouseFcn('set');
                mainToolBarEnable('on');

            end
        end

       % set(t6, 'State', 'off');
        set(mPolygon, 'CData', mPolygon.UserData.default);

        setCrossVisibility(true);

    end

    function drawsphereCallback(~, ~)

        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true || ...
           isVsplash('get')          == true

           % set(t11, 'State', 'off');
            set(mSphere, 'CData', mSphere.UserData.default);
            return;
        end

        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

        % robotReleaseKey();
        % axeClicked('set', true);
        % uiresume(fiMainWindowPtr('get'));

       % if strcmpi(get(t11, 'State'), 'off')
        if isequal(mSphere.CData, mSphere.UserData.pressed)
  %          robotReleaseKey();
            if ~isempty(voiTemplate('get', get(uiSeriesPtr('get'), 'Value')))
                set(uiLesionTypeVoiRoiPanelObject('get'), 'Enable', 'on');
                set(uiDeleteVoiRoiPanelObject    ('get'), 'Enable', 'on');
                set(uiAddVoiRoiPanelObject       ('get'), 'Enable', 'on');
                set(uiPrevVoiRoiPanelObject      ('get'), 'Enable', 'on');
                set(uiDelVoiRoiPanelObject       ('get'), 'Enable', 'on');
                set(uiNextVoiRoiPanelObject      ('get'), 'Enable', 'on');
                set(uiUndoVoiRoiPanelObject      ('get'), 'Enable', 'on');
            end

            set(fiMainWindowPtr('get'), 'Pointer', 'default');
            drawnow;

           % set(t11, 'State', 'off');
            set(mSphere, 'CData', mSphere.UserData.default);
            % roiSetAxeBorder(false);

            windowButton('set', 'up');
            mouseFcn('set');
            mainToolBarEnable('on');
            setCrossVisibility(true);

            return;
        end

        releaseRoiAxeWait(mSphere);

%             robotReleaseKey();

        setCrossVisibility(false);

        % triangulateCallback();

        try

        set(uiLesionTypeVoiRoiPanelObject('get'), 'Enable', 'off');
        set(uiDeleteVoiRoiPanelObject    ('get'), 'Enable', 'off');
        set(uiAddVoiRoiPanelObject       ('get'), 'Enable', 'off');
        set(uiPrevVoiRoiPanelObject      ('get'), 'Enable', 'off');
        set(uiDelVoiRoiPanelObject       ('get'), 'Enable', 'off');
        set(uiNextVoiRoiPanelObject      ('get'), 'Enable', 'off');
        set(uiUndoVoiRoiPanelObject      ('get'), 'Enable', 'off');

        set(fiMainWindowPtr('get'), 'Pointer', 'cross');
        drawnow;

        doWhileContinuous = true;
        while doWhileContinuous == true

            if contourVisibilityRoiPanelValue('get') == false

                contourVisibilityRoiPanelValue('set', true);
                set(chkContourVisibilityPanelObject('get'), 'Value', true);

                refreshImages();

                if size(dicomBuffer('get', [], dSeriesOffset), 3) ~= 1

                    plotRotatedRoiOnMip(axesMipPtr('get', [], dSeriesOffset), dicomBuffer('get', [], dSeriesOffset), mipAngle('get'));
                end
            end

            axeClicked('set', false);

            uiwait(fiMainWindowPtr('get'));

            if ~isvalid(mSphere)
                return;
            end

           % if strcmpi(get(t11, 'State'), 'off')
            if isequal(mSphere.CData, mSphere.UserData.default)
                return;
            end


     %       doWhileContinuous = true;
     %       while doWhileContinuous == true
    %               w = waitforbuttonpress;

    %            if w == 0
            if  strcmpi(windowButton('get'), 'down')

                atRoiInputBack = roiTemplate('get', dSeriesOffset);
                atVoiInputBack = voiTemplate('get', dSeriesOffset);

        %        robotClick();
                set(fiMainWindowPtr('get'), 'Pointer', 'watch');
                drawnow;

                pAxe = getAxeFromMousePosition(dSeriesOffset);

                switch pAxe

                    case axePtr('get', [], dSeriesOffset)
                    case axes1Ptr('get', [], dSeriesOffset)
                    case axes2Ptr('get', [], dSeriesOffset)
                    case axes3Ptr('get', [], dSeriesOffset)

                    otherwise
                        return;
                end

                mainToolBarEnable('off');
                mouseFcn('reset');

                % roiSetAxeBorder(true, pAxe);

            %    while strcmpi(get(t11, 'State'), 'on')

                clickedPt = get(pAxe,'CurrentPoint');

                clickedPtX = clickedPt(1,1);
                clickedPtY = clickedPt(1,2);

                atMetaData = dicomMetaData('get');
                dSliceThickness = computeSliceSpacing(atMetaData);

                aDicomBuffer = dicomBuffer('get', [], dSeriesOffset);

                switch(pAxe)

                    case axes1Ptr('get', [], dSeriesOffset) % Coronal
                        xPixel = atMetaData{1}.PixelSpacing(2);
                        yPixel = dSliceThickness;
                        zPixel = atMetaData{1}.PixelSpacing(1);

                        dBufferSize = size(aDicomBuffer, 1);

                    case axes2Ptr('get', [], dSeriesOffset) % Sagittal
                        xPixel = atMetaData{1}.PixelSpacing(1);
                        yPixel = dSliceThickness;
                        zPixel = atMetaData{1}.PixelSpacing(2);

                        dBufferSize = size(aDicomBuffer, 2);

                    otherwise % Axial
                        xPixel = atMetaData{1}.PixelSpacing(1);
                        yPixel = atMetaData{1}.PixelSpacing(2);
                        zPixel = dSliceThickness;

                        dBufferSize = size(aDicomBuffer, 3);
                end

                dSphereDiameter = sphereDefaultDiameter('get'); % in mm

                if xPixel == 0
                    xPixel = 1;
                end

                if yPixel == 0
                    yPixel = 1;
                end

                if dSphereDiameter > 0
                    dSemiAxesX = dSphereDiameter/xPixel/2; % In pixel
                    dSemiAxesY = dSphereDiameter/yPixel/2; % In pixel
                else
                    dSemiAxesX = xPixel/2;
                    dSemiAxesY = yPixel/2;
                end

                asTag = cell(dBufferSize, 1);

                sTag = num2str(generateUniqueNumber(false));

                a = images.roi.Ellipse(pAxe, ...
                                       'Center'          , [clickedPtX clickedPtY], ...
                                       'SemiAxes'        , [dSemiAxesX dSemiAxesY], ...
                                       'RotationAngle'   , 0, ...
                                       'Deletable'       , 0, ...
                                       'FixedAspectRatio', 1, ...
                                       'StripeColor'     , 'k', ...
                                       'Color'           , [0.0000, 0.9608, 0.8275], ...
                                       'lineWidth'       , 1, ...
                                       'Label'           , roiLabelName(), ...
                                       'LabelVisible'    , 'off', ...
                                       'Tag'             , sTag, ...
                                       'FaceSelectable'  , 1, ...
                                       'FaceAlpha'       , 0, ...
                                       'UserData'        , 'Sphere', ...
                                       'Visible'         , 'on' ...
                                       );
                 a.FaceAlpha = roiFaceAlphaValue('get');

                 asTag{1} = sTag;

                if ~isvalid(mSphere)
                    return;
                end

               % if strcmpi(get(t11, 'State'), 'off')
                if isequal(mSphere.CData, mSphere.UserData.default)

                    % roiSetAxeBorder(false);

    %                            windowButton('set', 'up');
    %                            mouseFcn('set');
    %                            mainToolBarEnable('on');
    %                            setCrossVisibility(1);

                    return;
                end

                addRoi(a, dSeriesOffset, 'Unspecified');

                addRoiMenu(a);

    %                    setVoiRoiSegPopup();


                % voiDefaultMenu(a);
                %
                % roiDefaultMenu(a);
                %
                % uimenu(a.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData',a, 'Callback', @hideViewFaceAlhaCallback);
                %
                % constraintMenu(a);
                %
                % cropMenu(a);
                %
                % uimenu(a.UIContextMenu,'Label', 'Display Statistics' , 'UserData',a, 'Callback',@figRoiDialogCallback, 'Separator', 'on');

    %                    set(fiMainWindowPtr('get'), 'WindowScrollWheelFcn' , @wheelScroll);
                refreshImages();
             %   end

                % roiSetAxeBorder(false);

                windowButton('set', 'up');
                mouseFcn('set');
                mainToolBarEnable('on');

                dRadius = dSphereDiameter/xPixel/2; % In pixel

                switch pAxe

                    % Coronal axe

                    case axes1Ptr('get', [], dSeriesOffset)

                        sPlane = 'coronal';

                        dSliceNb = sliceNumber('get', 'coronal' );

                        xPixelOffset = clickedPtX;
                        yPixelOffset = dSliceNb;
                        zPixelOffset = clickedPtY;

                        dPixelRatio = xPixel/yPixel;


                    % Sagittal axe

                    case axes2Ptr('get', [], dSeriesOffset)

                        sPlane = 'sagittal';

                        dSliceNb = sliceNumber('get', 'sagittal');

                        xPixelOffset = dSliceNb;
                        yPixelOffset = clickedPtX;
                        zPixelOffset = clickedPtY;

                        dPixelRatio = xPixel/yPixel;

                     % Axial axe

                    otherwise
                        sPlane = 'axial';

                        dSliceNb = sliceNumber('get', 'axial');

                        xPixelOffset = clickedPtX;
                        yPixelOffset = clickedPtY;
                        zPixelOffset = dSliceNb;

                        dPixelRatio = xPixel/yPixel;
                end

                aSphereMask = getSphereMask(aDicomBuffer, xPixelOffset, yPixelOffset, zPixelOffset, dRadius, xPixel, yPixel, zPixel);

                for zz=1:dBufferSize

                    if zz==dSliceNb
                        continue;
                    end

                    switch sPlane

                        case 'coronal' % Coronal axe
                            aSlice = permute(aSphereMask(zz,:,:), [3 2 1]);

                        case 'sagittal' % Sagittal axe
                            aSlice = permute(aSphereMask(:,zz,:), [3 1 2]);

                        otherwise % Axial axe
                            aSlice = aSphereMask(:,:,zz);
                    end

                    if any(aSlice(:) == 1)

                        isRoiValid = false;

                        boundaries = bwboundaries(aSlice, 8, 'noholes');
                        if ~isempty(boundaries)
                            isRoiValid = true;
                            thisBoundary = boundaries{1};

                            x = thisBoundary(:, 2); % x = columns.
                            y = thisBoundary(:, 1); % y = rows.
                        end

                        if isRoiValid == true

                            % Find which two boundary points are farthest from each other.
                            maxDistance = -inf;
                            for k = 1 : length(x)
                                distances = sqrt( (x(k) - x) .^ 2 + (y(k) - y) .^ 2 );
                                [thisMaxDistance, ~] = max(distances);
                                if thisMaxDistance > maxDistance
                                    maxDistance = thisMaxDistance;
                                end
                            end
                        end

                        dSemiAxesX = maxDistance/2;
                        dSemiAxesY = maxDistance/2*dPixelRatio;

                        sliceNumber('set', sPlane, zz);

                        sTag = num2str(generateUniqueNumber(false));

                        a = images.roi.Ellipse(pAxe, ...
                                               'Center'             , [clickedPtX clickedPtY], ...
                                               'SemiAxes'           , [dSemiAxesX dSemiAxesY], ...
                                               'RotationAngle'      , 0, ...
                                               'Deletable'          , 0, ...
                                               'FixedAspectRatio'   , 1, ...
                                               'InteractionsAllowed', 'none', ...
                                               'StripeColor'        , 'k', ...
                                               'Color'              , [0.0000, 0.9608, 0.8275], ...
                                               'lineWidth'          , 1, ...
                                               'Label'              , roiLabelName(), ...
                                               'LabelVisible'       , 'off', ...
                                               'Tag'                , sTag, ...
                                               'FaceSelectable'     , 1, ...
                                               'FaceAlpha'          , 0, ...
                                               'Visible'            , 'off', ...
                                               'UserData'           , 'SphereROI' ...
                                               );
                        a.FaceAlpha = roiFaceAlphaValue('get');

                        addRoi(a, dSeriesOffset, 'Unspecified');

                        asTag{zz+1} = sTag;

                    end
                end

                asTag = asTag(~cellfun(@isempty, asTag));

                if size(aDicomBuffer, 3) ~= 1
                    createVoiFromRois(dSeriesOffset, asTag, sprintf('Sphere %d mm', dSphereDiameter), [0 1 1], 'Unspecified');

                    setVoiRoiSegPopup();

                    uiDeleteVoiRoiPanel = uiDeleteVoiRoiPanelObject('get');
                    uiLesionTypeVoiRoiPanel = uiLesionTypeVoiRoiPanelObject('get');

                    if ~isempty(uiDeleteVoiRoiPanel) && ...
                       ~isempty(uiLesionTypeVoiRoiPanel)

                        atVoiInput = voiTemplate('get', dSeriesOffset);
                        dVoiOffset = numel(atVoiInput);

                        set(uiDeleteVoiRoiPanel, 'Value', dVoiOffset);

                        sLesionType = atVoiInput{dVoiOffset}.LesionType;
                        [bLesionOffset, ~, ~] = getLesionType(sLesionType);
                        set(uiLesionTypeVoiRoiPanel, 'Value', bLesionOffset);
                    end

                    plotRotatedRoiOnMip(axesMipPtr('get', [], dSeriesOffset), dicomBuffer('get', [], dSeriesOffset), mipAngle('get'));
                end

                clear aDicomBuffer;

                sliceNumber('set', sPlane, dSliceNb);

               % if strcmpi(get(tContinuous, 'State'), 'off')
                if isequal(mInfinite.CData, mInfinite.UserData.default)

                   doWhileContinuous = false;
                end

                % Set undo event

                atRoiInput = roiTemplate('get', dSeriesOffset);
                atVoiInput = voiTemplate('get', dSeriesOffset);

                dUID = generateUniqueNumber(false);

                roiTemplateEvent('add', dSeriesOffset, atRoiInputBack, atRoiInput, dUID);
                voiTemplateEvent('add', dSeriesOffset, atVoiInputBack, atVoiInput, dUID);

                enableUndoVoiRoiPanel();

                % End set undo event

                set(fiMainWindowPtr('get'), 'Pointer', 'cross');
                drawnow;
            end

        end

        catch ME
            logErrorToFile(ME);
            progressBar(1, 'Error:drawsphereCallback()');
        end

        if ~isempty(voiTemplate('get', dSeriesOffset))

            set(uiLesionTypeVoiRoiPanelObject('get'), 'Enable', 'on');
            set(uiDeleteVoiRoiPanelObject    ('get'), 'Enable', 'on');
            set(uiAddVoiRoiPanelObject       ('get'), 'Enable', 'on');
            set(uiPrevVoiRoiPanelObject      ('get'), 'Enable', 'on');
            set(uiDelVoiRoiPanelObject       ('get'), 'Enable', 'on');
            set(uiNextVoiRoiPanelObject      ('get'), 'Enable', 'on');
            set(uiUndoVoiRoiPanelObject      ('get'), 'Enable', 'on');
        end

      %  set(t11, 'State', 'off');
        set(mSphere, 'CData', mSphere.UserData.default);

        setCrossVisibility(true);

        set(fiMainWindowPtr('get'), 'Pointer', 'default');
        drawnow;
    end

    function drawClickVoiCallback(~, ~)

        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true || ...
           isVsplash('get')          == true

           % set(t12, 'State', 'off');
            set(mClickVoi, 'CData', mClickVoi.UserData.default);
            return;
        end

        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

        % if isa(actionData, 'matlab.graphics.axis.Axes')
        %
        %     bGetAxeFromMousePosition = false;
        % else
        %     bGetAxeFromMousePosition = true;
        % end

%               releaseRoiAxeWait(t);
        % robotReleaseKey();
        % axeClicked('set', true);
        % uiresume(fiMainWindowPtr('get'));

        if isequal(mClickVoi.CData, mClickVoi.UserData.pressed)
       % if strcmpi(get(t12, 'State'), 'off')
%                   robotReleaseKey();
%             if ~isempty(voiTemplate('get', get(uiSeriesPtr('get'), 'Value')))
%                 set(uiLesionTypeVoiRoiPanelObject('get'), 'Enable', 'on');
%                 set(uiDeleteVoiRoiPanelObject    ('get'), 'Enable', 'on');
%                 set(uiAddVoiRoiPanelObject       ('get'), 'Enable', 'on');
%                 set(uiPrevVoiRoiPanelObject      ('get'), 'Enable', 'on');
%                 set(uiDelVoiRoiPanelObject       ('get'), 'Enable', 'on');
%                 set(uiNextVoiRoiPanelObject      ('get'), 'Enable', 'on');
%             end

            set(fiMainWindowPtr('get'), 'Pointer', 'default');
            drawnow;

           % set(t12, 'State', 'off');
            set(mClickVoi, 'CData', mClickVoi.UserData.default);
            % roiSetAxeBorder(false);

            windowButton('set', 'up');
            mouseFcn('set');
            mainToolBarEnable('on');
            setCrossVisibility(true);

            return;
        end

        releaseRoiAxeWait(mClickVoi);

%               robotReleaseKey();

        setCrossVisibility(false);

        % triangulateCallback();

        try

%         set(uiLesionTypeVoiRoiPanelObject('get'), 'Enable', 'off');
%         set(uiDeleteVoiRoiPanelObject    ('get'), 'Enable', 'off');
%         set(uiAddVoiRoiPanelObject       ('get'), 'Enable', 'off');
%         set(uiPrevVoiRoiPanelObject      ('get'), 'Enable', 'off');
%         set(uiDelVoiRoiPanelObject       ('get'), 'Enable', 'off');
%         set(uiNextVoiRoiPanelObject      ('get'), 'Enable', 'off');

        set(fiMainWindowPtr('get'), 'Pointer', 'cross');
        drawnow;

        doWhileContinuous = true;
        while doWhileContinuous == true

            if contourVisibilityRoiPanelValue('get') == false

                contourVisibilityRoiPanelValue('set', true);
                set(chkContourVisibilityPanelObject('get'), 'Value', true);

                refreshImages();

                if size(dicomBuffer('get', [], dSeriesOffset), 3) ~= 1

                    plotRotatedRoiOnMip(axesMipPtr('get', [], dSeriesOffset), dicomBuffer('get', [], dSeriesOffset), mipAngle('get'));
                end
            end


     %       w=waitforbuttonpress;
            axeClicked('set', false);

            % if bGetAxeFromMousePosition == true
            %
                 doWhile = true;
            % else
            %     doWhile = false;
            % end

            while doWhile == true
                uiwait(fiMainWindowPtr('get'));
                if axeClicked('get') == true
                    doWhile = false;
                    if strcmpi(windowButton('get'), 'up')
                        doWhileContinuous = false;
                    end
                end
            end

            if ~isvalid(mClickVoi)
                return;
            end

           % if strcmpi(get(t12, 'State'), 'off')
            if isequal(mClickVoi.CData, mClickVoi.UserData.default)
                return;
            end

%import java.awt.event.*;
%mouse = Robot;
%mouse.mouseRelease(InputEvent.BUTTON3_MASK);
% mouse.mousePress(InputEvent.BUTTON3_MASK);

     %       if w == 0
            if  strcmpi(windowButton('get'), 'down')
%
 %               robotClick();

                atRoiInputBack = roiTemplate('get', dSeriesOffset);
                atVoiInputBack = voiTemplate('get', dSeriesOffset);

                pAxe = getAxeFromMousePosition(get(uiSeriesPtr('get'), 'Value'));

                switch pAxe

                    case axePtr('get', [], get(uiSeriesPtr('get'), 'Value'))
                        aClickedPt = get(pAxe,'CurrentPoint');

                        clickedPtX = round(aClickedPt(1,1));
                        clickedPtY = round(aClickedPt(1,2));

                    case axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
                        aClickedPt = get(pAxe,'CurrentPoint');

                        clickedPtX = round(aClickedPt(1,1));
                        clickedPtY = round(aClickedPt(1,2));

                    case axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
                        aClickedPt = get(pAxe,'CurrentPoint');

                        clickedPtX = round(aClickedPt(1,1));
                        clickedPtY = round(aClickedPt(1,2));

                    case axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
                        aClickedPt = get(pAxe,'CurrentPoint');

                        clickedPtX = round(aClickedPt(1,1));
                        clickedPtY = round(aClickedPt(1,2));

                    case axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value'))
                        triangulateImages();
                        pAxe = axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value'));
                        clickedPtX = sliceNumber('get', 'sagittal');
                        clickedPtY = sliceNumber('get', 'coronal');

                    otherwise

                        return;
                end


                mainToolBarEnable('off');
                mouseFcn('reset');

                % roiSetAxeBorder(true, pAxe);

                dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

                % aBuffer = dicomBuffer('get', [], dSeriesOffset);


                % Set ROI pael Segment btn to Cancel

                uiCreateVoiRoiPanel = uiCreateVoiRoiPanelObject('get');

                set(uiCreateVoiRoiPanel, 'String', 'Cancel');

                set(uiCreateVoiRoiPanel, 'Background', [0.3255, 0.1137, 0.1137]);

                set(uiCreateVoiRoiPanel, 'Foreground', [0.94 0.94 0.94]);

                cancelCreateVoiRoiPanel('set', false);

                % bRelativeToMax = relativeToMaxRoiPanelValue('get');
                % bInPercent     = inPercentRoiPanelValue('get');
                %
                % dSliderMin = minThresholdSliderRoiPanelValue('get');
                % dSliderMax = maxThresholdSliderRoiPanelValue('get');

                % Patch for when the user don't press enter on the edit box

                % if bInPercent == true

                    pUiRoiPanelPtr = uiRoiPanelPtr('get');

                    apChildren = pUiRoiPanelPtr.Children;

                    % uiEditMaxThresholdRoiPanel

                    uiEditMaxThresholdRoiPanel = apChildren(strcmp({apChildren.UserData}, 'edtClickVoiPercentOfMax'));

                    if ~isempty(uiEditMaxThresholdRoiPanel)

                        dPercentOfMax = str2double(get(uiEditMaxThresholdRoiPanel, 'String'));
                    else

                        dPercentOfMax = clickVoiPercentOfMaxValue('get');
                    end
                % end

                createVoiFromLocation(pAxe, clickedPtX, clickedPtY, dicomBuffer('get', [], dSeriesOffset), dPercentOfMax/100, dSeriesOffset,  pixelEdge('get'));

                cancelCreateVoiRoiPanel('set', false);

                set(uiCreateVoiRoiPanel, 'String', 'Segment');

                set(uiCreateVoiRoiPanel, 'Background', [0.6300 0.6300 0.4000]);
                set(uiCreateVoiRoiPanel, 'Foreground', [0.1 0.1 0.1]);

  %                  a.Waypoints(:) = false;
%test hf=a;
                    if ~isvalid(mClickVoi)
                        return;
                    end

                   % if strcmpi(get(t12, 'State'), 'off')
                    if isequal(mClickVoi.CData, mClickVoi.UserData.default)

                        % roiSetAxeBorder(false);

                 %       windowButton('set', 'up');
                 %       mouseFcn('set');
                 %       mainToolBarEnable('on');
                 %       setCrossVisibility(1);

                        return;
                    end


%                    set(fiMainWindowPtr('get'), 'WindowScrollWheelFcn' , @wheelScroll);
                    refreshImages();

                  %  if strcmpi(get(tContinuous, 'State'), 'off')
                    if isequal(mInfinite.CData, mInfinite.UserData.default)

                        doWhileContinuous = false;
                    end

             %   end

                % roiSetAxeBorder(false);

                % Set undo event

                atRoiInput = roiTemplate('get', dSeriesOffset);
                atVoiInput = voiTemplate('get', dSeriesOffset);

                dUID = generateUniqueNumber(false);

                roiTemplateEvent('add', dSeriesOffset, atRoiInputBack, atRoiInput, dUID);
                voiTemplateEvent('add', dSeriesOffset, atVoiInputBack, atVoiInput, dUID);

                enableUndoVoiRoiPanel();

                % End set undo event

                windowButton('set', 'up');
                mouseFcn('set');
                mainToolBarEnable('on');
            end
        end

        catch ME
            logErrorToFile(ME);
            progressBar(1, 'Error:drawClickVoiCallback()');
        end

%         if ~isempty(voiTemplate('get', get(uiSeriesPtr('get'), 'Value')))
%
%             set(uiLesionTypeVoiRoiPanelObject('get'), 'Enable', 'on');
%             set(uiDeleteVoiRoiPanelObject    ('get'), 'Enable', 'on');
%             set(uiAddVoiRoiPanelObject       ('get'), 'Enable', 'on');
%             set(uiPrevVoiRoiPanelObject      ('get'), 'Enable', 'on');
%             set(uiDelVoiRoiPanelObject       ('get'), 'Enable', 'on');
%             set(uiNextVoiRoiPanelObject      ('get'), 'Enable', 'on');
%         end

       % set(t12, 'State', 'off');
        set(mClickVoi, 'CData', mClickVoi.UserData.default);

        setCrossVisibility(true);

        set(fiMainWindowPtr('get'), 'Pointer', 'default');
        drawnow;
    end

    function viewFarthestDistancesCallback(~, ~)

       % if strcmpi(get(hObject, 'State'), 'on')
        if ~isequal(mFarthest.CData, mFarthest.UserData.pressed)

            viewFarthestDistances('set', true);

            set(mFarthest, 'CData', mFarthest.UserData.pressed);
        else
            viewFarthestDistances('set', false);

            set(mFarthest, 'CData', mFarthest.UserData.default);
        end

        if viewFarthestDistances('get') == false

            atRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

            if ~isempty(atRoiInput) && isVsplash('get') == false

                numRoiInputs = numel(atRoiInput);

                for bb = 1:numRoiInputs

                    currentRoi = atRoiInput{bb};

                    if roiHasMaxDistances(currentRoi) == true

                        currentRoi.MaxDistances.MaxXY.Line.Visible = 'off';
                        currentRoi.MaxDistances.MaxCY.Line.Visible = 'off';
                        currentRoi.MaxDistances.MaxXY.Text.Visible = 'off';
                        currentRoi.MaxDistances.MaxCY.Text.Visible = 'off';
                    end
                end
            end
        end

        if ~isempty(dicomBuffer('get'))

            refreshImages();
        end
    end

    function draw2Dbrush(pAxe)

        if isa(pAxe, 'matlab.graphics.axis.Axes')

            bGetAxeFromMousePosition = false;
        else
            bGetAxeFromMousePosition = true;
        end

        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

        % robotReleaseKey();
        % axeClicked('set', true);
        % uiresume(fiMainWindowPtr('get'));

%        % if strcmpi(get(t2Dbrush, 'State'), 'off')
%         if isequal(m2DBrush.CData, m2DBrush.UserData.pressed)
%   %          robotReleaseKey();
% 
%            % set(t2Dbrush, 'State', 'off');
%             set(m2DBrush, 'CData', m2DBrush.UserData.default);
% %            roiSetAxeBorder(false);
% 
%             windowButton('set', 'up');
%             mouseFcn('set');
%             mainToolBarEnable('on');
%             setCrossVisibility(true);
% 
%             return;
%         end

        % aImageSize = size(dicomBuffer('get', [], dSeriesOffset));

%             robotReleaseKey();

        setCrossVisibility(false);

        if bGetAxeFromMousePosition == true

            % triangulateCallback();


            axeClicked('set', false);

            uiwait(fiMainWindowPtr('get'));
        end

        if ~isvalid(m2DBrush)

            return;
        end

       % if strcmpi(get(t2Dbrush, 'State'), 'off')
        if isequal(m2DBrush.CData, m2DBrush.UserData.default)

            return;
        end

%               w = waitforbuttonpress;

%            if w == 0
        if  strcmpi(windowButton('get'), 'down')

    %        robotClick();
            if bGetAxeFromMousePosition == true

                pAxe = getAxeFromMousePosition(dSeriesOffset);
            end

            switch pAxe

                case axePtr('get', [], dSeriesOffset)
                case axes1Ptr('get', [], dSeriesOffset)
                case axes2Ptr('get', [], dSeriesOffset)
                case axes3Ptr('get', [], dSeriesOffset)

                otherwise
                    return;
            end

            mainToolBarEnable('off');
            mouseFcn('reset');

     %       roiSetAxeBorder(true, gca);

        %    while strcmpi(get(t11, 'State'), 'on')

            clickedPt  = get(pAxe,'CurrentPoint');
            clickedPtX = clickedPt(1,1);
            clickedPtY = clickedPt(1,2);

            atMetaData = dicomMetaData('get', [], dSeriesOffset);
            dSliceThickness = computeSliceSpacing(atMetaData);

            switch(pAxe)

                case axes1Ptr('get', [], dSeriesOffset) % Coronal
                    xPixel = atMetaData{1}.PixelSpacing(1);
                    yPixel = dSliceThickness;

                    % xImageSize = aImageSize(1);
%                     yImageSize = aImageSize(3);

                case axes2Ptr('get', [], dSeriesOffset) % Sagittal
                    xPixel = atMetaData{1}.PixelSpacing(2);
                    yPixel = dSliceThickness;

                    % xImageSize = aImageSize(2);
%                     yImageSize = aImageSize(3);

                otherwise % Axial
                    xPixel = atMetaData{1}.PixelSpacing(1);
                    yPixel = atMetaData{1}.PixelSpacing(2);

                    % xImageSize = aImageSize(1);
%                     yImageSize = aImageSize(2);
            end

            if xPixel == 0
                xPixel = 1;
            end

            if yPixel == 0
                yPixel = 1;
            end
% if 1
            dSphereDiameter = brush2dDefaultDiameter('get'); % in mm
% else
%             dSphereDiameter = (xImageSize/10)*xPixel;
%             brush2dDefaultDiameter('set', dSphereDiameter);
% end

            if dSphereDiameter > 0
                dSemiAxesX = dSphereDiameter/xPixel/2; % In pixel
                dSemiAxesY = dSphereDiameter/yPixel/2; % In pixel
            else
                dSemiAxesX = xPixel/2;
                dSemiAxesY = yPixel/2;
            end

            pRoiPtr  = images.roi.Ellipse(pAxe, ...
                                          'Center'             , [clickedPtX clickedPtY], ...
                                          'SemiAxes'           , [dSemiAxesX dSemiAxesY], ...
                                          'RotationAngle'      , 0, ...
                                          'Deletable'          , 0, ...
                                          'FixedAspectRatio'   , 1, ...
                                          'StripeColor'        , 'k', ...
                                          'Color'              , 'red', ...
                                          'lineWidth'          , 1, ...
                                          'Label'              , '2Dbrush', ...
                                          'LabelVisible'       , 'off', ...
                                          'InteractionsAllowed', 'none', ...
                                          'FaceSelectable'     , 0, ...
                                          'FaceAlpha'          , 0.03, ...
                                          'UserData'           , '2Dbrush', ...
                                          'Visible'            , 'on' ...
                                          );

            brush2Dptr('set', pRoiPtr);

            if ~isvalid(m2DBrush)
                return;
            end

           % if strcmpi(get(t2Dbrush, 'State'), 'off')
            if isequal(m2DBrush.CData, m2DBrush.UserData.default)

                roiSetAxeBorder(false);

%                            windowButton('set', 'up');
%                            mouseFcn('set');
%                            mainToolBarEnable('on');
%                            setCrossVisibility(1);

                return;
            end

     %       refreshImages();
         %   end

  %          roiSetAxeBorder(false);

            windowButton('set', 'up');
            mouseFcn('set');
            mainToolBarEnable('on');
        end

    end

    function draw2Dscissor()

        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true || ...
           isVsplash('get')          == true

           % set(t2Dscissor, 'State', 'off');
            set(m2DKnife, 'CData', m2DKnife.UserData.default);
            return;
        end

%               releaseRoiAxeWait(t8);
        % robotReleaseKey();
        % axeClicked('set', true);
        % uiresume(fiMainWindowPtr('get'));

        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

        if contourVisibilityRoiPanelValue('get') == false

            contourVisibilityRoiPanelValue('set', true);
            set(chkContourVisibilityPanelObject('get'), 'Value', true);

            refreshImages();

            if size(dicomBuffer('get', [], dSeriesOffset), 3) ~= 1

                plotRotatedRoiOnMip(axesMipPtr('get', [], dSeriesOffset), dicomBuffer('get', [], dSeriesOffset), mipAngle('get'));
            end
        end

 %       % if strcmpi(get(t2Dscissor, 'State'), 'off')
 %        if isequal(m2DKnife.CData, m2DKnife.UserData.default)
 % 
 % %           robotReleaseKey();
 % 
 %           % set(t2Dscissor, 'State', 'off');
 %            set(m2DKnife, 'CData', m2DKnife.UserData.default);
 %            % roiSetAxeBorder(false);
 % 
 %            windowButton('set', 'up');
 %            mouseFcn('set');
 %            mainToolBarEnable('on');
 %            setCrossVisibility(true);
 % 
 %            return;
 %        end

        % releaseRoiAxeWait(t2Dscissor);

%         robotReleaseKey();

        setCrossVisibility(false);

        % triangulateCallback();

        doWhileContinuous = true;
        while doWhileContinuous == true
     %       w=waitforbuttonpress;
            axeClicked('set', false);
            doWhile = true;
            while doWhile == true
                uiwait(fiMainWindowPtr('get'));
                if axeClicked('get') == true
                    doWhile = false;
                    if strcmpi(windowButton('get'), 'up')
                        doWhileContinuous = false;
                    end
        %            axeClicked('set', false);
                end
            end

            if ~isvalid(m2DKnife)
                return;
            end

           % if strcmpi(get(t2Dscissor, 'State'), 'off')
            if isequal(m2DKnife.CData, m2DKnife.UserData.default)
               return;
            end
     %       if w == 0
            if  strcmpi(windowButton('get'), 'down')

                % atRoiInputBack = roiTemplate('get', dSeriesOffset);
                % atVoiInputBack = voiTemplate('get', dSeriesOffset);

                robotClick();

                pAxe = getAxeFromMousePosition(get(uiSeriesPtr('get'), 'Value'));

                switch pAxe

                    case axePtr('get', [], get(uiSeriesPtr('get'), 'Value'))
                    case axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
                    case axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
                    case axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))

                    otherwise
                        return;
                end

                mainToolBarEnable('off');
                mouseFcn('reset');

                % roiSetAxeBorder(true, pAxe);

         %       while strcmpi(get(t8, 'State'), 'on')

                    pRoiPtr = drawline(pAxe, 'Color', 'red', 'lineWidth', 1, 'Tag', num2str(generateUniqueNumber(false)), 'LabelVisible', 'off');
                    pRoiPtr.LabelVisible = 'off';

                    scissor2Dptr('set', pRoiPtr);

                    if ~isvalid(m2DKnife)
                        return;
                    end

                   % if strcmpi(get(t2Dscissor, 'State'), 'off')
                    if isequal(m2DKnife.CData, m2DKnife.UserData.default)

                        % roiSetAxeBorder(false);

                        return;
                    end



%                     if strcmpi(get(tContinuous, 'State'), 'off')
                        doWhileContinuous = false;
%                     end

         %       end
                try

                sMainWindowPtrPointer = get(fiMainWindowPtr('get'), 'Pointer');
                set(fiMainWindowPtr('get'), 'Pointer', 'watch');
                drawnow;

                splitContour(pAxe, pRoiPtr);

                delete(pRoiPtr);

                % roiSetAxeBorder(false);

                % Set undo event
                % 
                % atRoiInput = roiTemplate('get', dSeriesOffset);
                % atVoiInput = voiTemplate('get', dSeriesOffset);
                % 
                % dUID = generateUniqueNumber(false);

                % roiTemplateEvent('add', dSeriesOffset, atRoiInputBack, atRoiInput, dUID, 2);
                % voiTemplateEvent('add', dSeriesOffset, atVoiInputBack, atVoiInput, dUID);

                enableUndoVoiRoiPanel();

                % End set undo event

                windowButton('set', 'up');
                mouseFcn('set');
                mainToolBarEnable('on');

                catch ME
                    logErrorToFile(ME);
                    progressBar(1, 'Error:draw2Dscissor()');
                end

                set(fiMainWindowPtr('get'), 'Pointer', sMainWindowPtrPointer);
                drawnow;
            end
        end

       % set(t2Dscissor, 'State', 'off');
        set(m2DKnife, 'CData', m2DKnife.UserData.default);

        setCrossVisibility(true);
    end

    function setContinuousCallback(~, ~)

        axeClicked('set', true);
        uiresume(fiMainWindowPtr('get'));
   
        set(mMeasure  , 'CData', mMeasure.UserData.default);
        set(mFreehand , 'CData', mFreehand.UserData.default);
        set(mPolygon  , 'CData', mPolygon.UserData.default);
        set(mCircle   , 'CData', mCircle.UserData.default);
        set(mEllipse  , 'CData', mEllipse.UserData.default);
        set(mRectangle, 'CData', mRectangle.UserData.default);
        set(mSphere   , 'CData', mSphere.UserData.default);
        set(mClickVoi , 'CData', mClickVoi.UserData.default);          

        toggleToolbarIcon(mInfinite);

        if isequal(mInfinite.CData, mInfinite.UserData.default)

            setCrossVisibility(true);
        end

        set(fiMainWindowPtr('get'), 'Pointer', 'default');
        drawnow;
    end

    function setInterpolateCallback(~, ~)

        if ~isequal(mInterpolate.CData, mInterpolate.UserData.pressed)

            set(mInterpolate, 'CData', mInterpolate.UserData.pressed);
        else
            set(mInterpolate, 'CData', mInterpolate.UserData.default);
        end
       
        lastRoiTag('');
    end

    function set2DBrushCallback(~, actionData)

        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true || ...
           isVsplash('get')          == true

          % set(hObject, 'State', 'off');
            set(m2DBrush, 'CData', m2DBrush.UserData.default);          
            return;
        end

        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

        if isa(actionData, 'matlab.graphics.axis.Axes')

            bGetAxeFromMousePosition = false;
        else
            bGetAxeFromMousePosition = true;
        end

        try
        %
        % set(fiMainWindowPtr('get'), 'Pointer', 'watch');
        % drawnow;

        % axeClicked('set', true);
        % uiresume(fiMainWindowPtr('get'));
        set(mMeasure  , 'CData', mMeasure.UserData.default);
        set(mFreehand , 'CData', mFreehand.UserData.default);
        set(mPolygon  , 'CData', mPolygon.UserData.default);
        set(mCircle   , 'CData', mCircle.UserData.default);
        set(mEllipse  , 'CData', mEllipse.UserData.default);
        set(mRectangle, 'CData', mRectangle.UserData.default);
        set(mSphere   , 'CData', mSphere.UserData.default);
        set(mClickVoi , 'CData', mClickVoi.UserData.default);    
        set(m2DKnife  , 'CData', m2DKnife.UserData.default);    

        % set(t  , 'State', 'off');
        % set(t2 , 'State', 'off');
        % set(t3 , 'State', 'off');
        % set(t5 , 'State', 'off');
        % set(t6 , 'State', 'off');
        % set(t8 , 'State', 'off');
        % set(t11, 'State', 'off');
        % set(t12, 'State', 'off');
        % set(t2Dscissor, 'State', 'off');

        % if strcmpi(get(hObject, 'State'), 'on')
        if viewFarthestDistances('get') == true

         %   set(tFarthest, 'State', 'off');
            set(mFarthest, 'CData', mFarthest.UserData.default);          

            viewFarthestDistances('set', false);

            atRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

            if ~isempty(atRoiInput)

                numRoiInputs = numel(atRoiInput);

                for bb = 1:numRoiInputs

                    currentRoi = atRoiInput{bb};

                    if roiHasMaxDistances(currentRoi) == true

                        currentRoi.MaxDistances.MaxXY.Line.Visible = 'off';
                        currentRoi.MaxDistances.MaxCY.Line.Visible = 'off';
                        currentRoi.MaxDistances.MaxXY.Text.Visible = 'off';
                        currentRoi.MaxDistances.MaxCY.Text.Visible = 'off';
                     end

                end

            end
        end

        if is2DBrush('get') == false

           % set(hObject, 'State', 'on');
            set(m2DBrush, 'CData', m2DBrush.UserData.pressed);          

            is2DBrush('set', true);

            setCrossVisibility(false);

            % set(t  , 'Enable', 'off');
            % set(t2 , 'Enable', 'off');
            % set(t3 , 'Enable', 'off');
            % set(t5 , 'Enable', 'off');
            % set(t6 , 'Enable', 'off');
            % set(t8 , 'Enable', 'off');
            % set(t11, 'Enable', 'off');
            % set(t12, 'Enable', 'off');
            % set(tFarthest, 'Enable', 'off');
            % set(t2Dscissor, 'Enable', 'off');

            set(mMeasure  , 'HitTest', 'off');
            set(mFreehand , 'HitTest', 'off');
            set(mPolygon  , 'HitTest', 'off');
            set(mCircle   , 'HitTest', 'off');
            set(mEllipse  , 'HitTest', 'off');
            set(mRectangle, 'HitTest', 'off');
            set(mSphere   , 'HitTest', 'off');
            set(mClickVoi , 'HitTest', 'off');    
            set(m2DKnife  , 'HitTest', 'off');   
            set(mFarthest , 'HitTest', 'off');          

            set(mMeasure  , 'CData', mMeasure.UserData.disable);
            set(mFreehand , 'CData', mFreehand.UserData.disable);
            set(mPolygon  , 'CData', mPolygon.UserData.disable);
            set(mCircle   , 'CData', mCircle.UserData.disable);
            set(mEllipse  , 'CData', mEllipse.UserData.disable);
            set(mRectangle, 'CData', mRectangle.UserData.disable);
            set(mSphere   , 'CData', mSphere.UserData.disable);
            set(mClickVoi , 'CData', mClickVoi.UserData.disable);
            set(m2DKnife  , 'CData', m2DKnife.UserData.disable);
            set(mFarthest , 'CData', mFarthest.UserData.disable);

            atRoiInput = roiTemplate('get', dSeriesOffset);

            if ~isempty(atRoiInput)

                for rr=1:numel(atRoiInput)
                    set(atRoiInput{rr}.Object, 'InteractionsAllowed', 'none');
                    atRoiInput{rr}.InteractionsAllowed = 'none';
                end
                roiTemplate('set', dSeriesOffset, atRoiInput);
            end

            draw2Dbrush(actionData);

           % if strcmpi(get(t2Dbrush, 'State'), 'on')
            if isequal(m2DBrush.CData, m2DBrush.UserData.pressed) % To verify

                if bGetAxeFromMousePosition == true

                    pAxe = getAxeFromMousePosition(get(uiSeriesPtr('get'), 'Value'));

                    switch pAxe

                        case axePtr('get', [], get(uiSeriesPtr('get'), 'Value'))
                        case axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
                        case axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
                        case axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))

                        otherwise
                            return;
                    end
                else
                    pAxe = actionData;
                end

                roiSetAxeBorder(true, pAxe);

                isAxe      = pAxe == axePtr  ('get', [], dSeriesOffset);
                isCoronal  = pAxe == axes1Ptr('get', [], dSeriesOffset);
                isSagittal = pAxe == axes2Ptr('get', [], dSeriesOffset);
                isAxial    = pAxe == axes3Ptr('get', [], dSeriesOffset);

                if isAxe
                    set(uiOneWindowPtr('get'), 'HighlightColor', [1 0 0]);
                    set(uiOneWindowPtr('get'), 'BorderType', 'line');
                elseif isCoronal
                    set(uiCorWindowPtr('get'), 'HighlightColor', [1 0 0]);
                    set(uiCorWindowPtr('get'), 'BorderType', 'line');
                elseif isSagittal
                    set(uiSagWindowPtr('get'), 'HighlightColor', [1 0 0]);
                    set(uiSagWindowPtr('get'), 'BorderType', 'line');
                elseif isAxial
                    set(uiTraWindowPtr('get'), 'HighlightColor', [1 0 0]);
                    set(uiTraWindowPtr('get'), 'BorderType', 'line');
                end

            end
        else
          %  set(hObject, 'State', 'off');
            set(m2DBrush, 'CData', m2DBrush.UserData.default);          

            is2DBrush('set', false);

            pRoiPtr = brush2Dptr('get');

            if ~isempty(pRoiPtr)
                delete(pRoiPtr);
                brush2Dptr('set', []);
            end

            atRoiInput = roiTemplate('get', dSeriesOffset);

            if ~isempty(atRoiInput)

                for rr=1:numel(atRoiInput)
                    if ~strcmpi(get(atRoiInput{rr}.Object, 'UserData'), 'SphereROI')

                        set(atRoiInput{rr}.Object, 'InteractionsAllowed', 'all');
                        atRoiInput{rr}.InteractionsAllowed = 'all';

                        if strcmpi(atRoiInput{rr}.Object.Type, 'images.roi.freehand') || ...
                           strcmpi(atRoiInput{rr}.Object.Type, 'images.roi.assistedfreehand')

                            if isempty(find(atRoiInput{rr}.Waypoints, 1))

                                atRoiInput{rr}.Object.Waypoints(:) = false;
                                atRoiInput{rr}.Waypoints = atRoiInput{rr}.Object.Waypoints;
                            end
                        end

                    end
                end
            end

            roiTemplate('set', dSeriesOffset, atRoiInput);

            if size(dicomBuffer('get', [], dSeriesOffset), 3) ~= 1

                plotRotatedRoiOnMip(axesMipPtr('get', [], dSeriesOffset), dicomBuffer('get', [], dSeriesOffset), mipAngle('get'));
            end

            roiSetAxeBorder(false);

            setCrossVisibility(true);

            % set(t  , 'Enable', 'on');
            % set(t2 , 'Enable', 'on');
            % set(t3 , 'Enable', 'on');
            % set(t5 , 'Enable', 'on');
            % set(t6 , 'Enable', 'on');
            % set(t8 , 'Enable', 'on');
            % set(t11, 'Enable', 'on');
            % set(t12, 'Enable', 'on');
            % set(tFarthest, 'Enable', 'on');
            % set(t2Dscissor, 'Enable', 'on');

            set(mMeasure  , 'HitTest', 'on');
            set(mFreehand , 'HitTest', 'on');
            set(mPolygon  , 'HitTest', 'on');
            set(mCircle   , 'HitTest', 'on');
            set(mEllipse  , 'HitTest', 'on');
            set(mRectangle, 'HitTest', 'on');
            set(mSphere   , 'HitTest', 'on');
            set(mClickVoi , 'HitTest', 'on');    
            set(m2DKnife  , 'HitTest', 'on');   
            set(mFarthest , 'HitTest', 'on');

            set(mMeasure  , 'CData', mMeasure.UserData.default);
            set(mFreehand , 'CData', mFreehand.UserData.default);
            set(mPolygon  , 'CData', mPolygon.UserData.default);
            set(mCircle   , 'CData', mCircle.UserData.default);
            set(mEllipse  , 'CData', mEllipse.UserData.default);
            set(mRectangle, 'CData', mRectangle.UserData.default);
            set(mSphere   , 'CData', mSphere.UserData.default);
            set(mClickVoi , 'CData', mClickVoi.UserData.default);
            set(m2DKnife  , 'CData', m2DKnife.UserData.default);
            set(mFarthest , 'CData', mFarthest.UserData.default);

        end
        %
        catch ME
            logErrorToFile(ME);
            progressBar(1, 'Error:set2DBrushCallback()');
        end

        set(fiMainWindowPtr('get'), 'Pointer', 'default');
        drawnow;
    end

    function set2DScissorCallback(~, ~)

        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true || ...
           isVsplash('get')          == true


          % set(hObject, 'State', 'off');
           set(m2DKnife, 'CData', m2DKnife.UserData.default);
           return;
        end

        try

        % set(fiMainWindowPtr('get'), 'Pointer', 'watch');
        % drawnow;

        % axeClicked('set', true);
        % uiresume(fiMainWindowPtr('get'));

        % set(t  , 'State', 'off');
        % set(t2 , 'State', 'off');
        % set(t3 , 'State', 'off');
        % set(t5 , 'State', 'off');
        % set(t6 , 'State', 'off');
        % set(t8 , 'State', 'off');
        % set(t11, 'State', 'off');
        % set(t12, 'State', 'off');
        % set(t2Dbrush, 'State', 'off');

        set(mMeasure  , 'HitTest', 'off');
        set(mFreehand , 'HitTest', 'off');
        set(mPolygon  , 'HitTest', 'off');
        set(mCircle   , 'HitTest', 'off');
        set(mEllipse  , 'HitTest', 'off');
        set(mRectangle, 'HitTest', 'off');
        set(mSphere   , 'HitTest', 'off');
        set(mClickVoi , 'HitTest', 'off');    
        set(m2DBrush  , 'HitTest', 'off');   

        if is2DScissor('get') == false

            set(m2DKnife, 'CData', m2DKnife.UserData.pressed);

            is2DScissor('set', true);

            setCrossVisibility(false);

            % set(t  , 'Enable', 'off');
            % set(t2 , 'Enable', 'off');
            % set(t3 , 'Enable', 'off');
            % set(t5 , 'Enable', 'off');
            % set(t6 , 'Enable', 'off');
            % set(t8 , 'Enable', 'off');
            % set(t11, 'Enable', 'off');
            % set(t12, 'Enable', 'off');
            % set(tFarthest, 'Enable', 'off');
            % set(t2Dbrush, 'Enable', 'off');

            set(mMeasure  , 'CData', mMeasure.UserData.disable);
            set(mFreehand , 'CData', mFreehand.UserData.disable);
            set(mPolygon  , 'CData', mPolygon.UserData.disable);
            set(mCircle   , 'CData', mCircle.UserData.disable);
            set(mEllipse  , 'CData', mEllipse.UserData.disable);
            set(mRectangle, 'CData', mRectangle.UserData.disable);
            set(mSphere   , 'CData', mSphere.UserData.disable);
            set(mClickVoi , 'CData', mClickVoi.UserData.disable);
            set(m2DBrush  , 'CData', m2DBrush.UserData.disable);
            set(mFarthest , 'CData', mFarthest.UserData.disable);
      
            draw2Dscissor();

            is2DScissor('set', false);

            set(m2DKnife, 'CData', m2DKnife.UserData.default);
        else
            set(m2DKnife , 'CData', m2DKnife.UserData.default);
    
            is2DScissor('set', false);

            windowButton('set', 'up');
            mouseFcn('set');
            mainToolBarEnable('on');
            setCrossVisibility(true);
        end

        catch ME
            logErrorToFile(ME);
            progressBar(1, 'Error:set2DScissorCallback()');
        end

        pRoiPtr = scissor2Dptr('get');

        if ~isempty(pRoiPtr)
            delete(pRoiPtr);
            scissor2Dptr('set', []);
        end
        
        roiSetAxeBorder(false);

        setCrossVisibility(true);

        % set(t  , 'Enable', 'on');
        % set(t2 , 'Enable', 'on');
        % set(t3 , 'Enable', 'on');
        % set(t5 , 'Enable', 'on');
        % set(t6 , 'Enable', 'on');
        % set(t8 , 'Enable', 'on');
        % set(t11, 'Enable', 'on');
        % set(t12, 'Enable', 'on');
        % set(tFarthest, 'Enable', 'on');
        % set(t2Dbrush, 'Enable', 'on');

        set(mMeasure  , 'HitTest', 'on');
        set(mFreehand , 'HitTest', 'on');
        set(mPolygon  , 'HitTest', 'on');
        set(mCircle   , 'HitTest', 'on');
        set(mEllipse  , 'HitTest', 'on');
        set(mRectangle, 'HitTest', 'on');
        set(mSphere   , 'HitTest', 'on');
        set(mClickVoi , 'HitTest', 'on');    
        set(m2DBrush  , 'HitTest', 'on');  

        set(mMeasure  , 'CData', mMeasure.UserData.default);
        set(mFreehand , 'CData', mFreehand.UserData.default);
        set(mPolygon  , 'CData', mPolygon.UserData.default);
        set(mCircle   , 'CData', mCircle.UserData.default);
        set(mEllipse  , 'CData', mEllipse.UserData.default);
        set(mRectangle, 'CData', mRectangle.UserData.default);
        set(mSphere   , 'CData', mSphere.UserData.default);
        set(mClickVoi , 'CData', mClickVoi.UserData.default);
        set(m2DBrush  , 'CData', m2DBrush.UserData.default);
        set(mFarthest , 'CData', mFarthest.UserData.default);

        set(fiMainWindowPtr('get'), 'Pointer', 'default');
        drawnow;
    end

    % function checkWaitStatus(src)
    %     a=1
    %     f = fiMainWindowPtr('get');
    %     if strcmp(f.WaitStatus, 'waiting')
    %         % Reset WaitStatus to 'inactive'
    %         set(f, 'WaitStatus', 'inactive');
    %     end
    % end

    function interpolateROIsByTag(sTag1, sTag2)

        lastRoiTag(sTag1);

        if isempty(sTag2)
            return;
        end

        try
        %
        % set(fiMainWindowPtr('get'), 'Pointer', 'watch');
        % drawnow;

        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

        if size(dicomBuffer('get', [], dSeriesOffset), 3) ~= 1

            atRoiInput = roiTemplate('get', dSeriesOffset);
            atVoiInput = voiTemplate('get', dSeriesOffset);

            dTagOffset1 = find(strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {sTag1} ), 1);
            dTagOffset2 = find(strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {sTag2} ), 1);

            if ~isempty(dTagOffset1)&&~isempty(dTagOffset2)

                if strcmpi(atRoiInput{dTagOffset2}.ObjectType, 'voi-roi')

                    for vv=1:numel(atVoiInput)

                        dVoiTagOffset = find(contains(atVoiInput{vv}.RoisTag, atRoiInput{dTagOffset2}.Tag), 1);

                        if ~isempty(dVoiTagOffset)

                            dNbTags = numel(atVoiInput{vv}.RoisTag);

                            adSliceNb = cell(2, dNbTags);
                            for rr=1:numel(atVoiInput{vv}.RoisTag)

                                dTagOffset = find(strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), atVoiInput{vv}.RoisTag{rr} ), 1);

                                if ~isempty(dTagOffset)

                                    adSliceNb{1, rr} = atRoiInput{dTagOffset}.SliceNb;
                                    adSliceNb{2, rr} = dTagOffset;

                                end
                            end

                            numericValues = cell2mat(adSliceNb);

                            [minValue, minOffset] = min(numericValues(1,:));
                            [~, maxOffset]        = max(numericValues(1,:));

                            if atRoiInput{dTagOffset1}.SliceNb < minValue
                                dTagOffset2 = numericValues(2,minOffset);
                            else
                                dTagOffset2 = numericValues(2,maxOffset);
                            end

                            break;
                        end
                    end
                end

                interpolateBetweenROIs(atRoiInput{dTagOffset1}, atRoiInput{dTagOffset2}, dSeriesOffset, true);

            end
        end

        catch ME
            logErrorToFile(ME);
            progressBar(1, 'Error:interpolateROIsByTag()');
        end

        set(fiMainWindowPtr('get'), 'Pointer', 'default');
        drawnow;
    end

    function sLastTag = lastRoiTag(sTag)

        persistent psLastTag;

        if exist('sTag', 'var')
            psLastTag = sTag;
        end

        sLastTag = psLastTag;
    end
end
