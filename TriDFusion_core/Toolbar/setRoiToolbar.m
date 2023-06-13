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

    tbRoi = roiMenuObject('get');

    if isempty(tbRoi)

        sRootPath  = viewerRootPath('get');
        sIconsPath = sprintf('%s/icons/', sRootPath);

    %    f = figure('ToolBar','none');
        tbRoi = uitoolbar(fiMainWindowPtr('get'));

%        jToolbar = tbRoi.JavaContainer.getComponentPeer;
%        jToolbar.setBackground();

        roiMenuObject('set', tbRoi);

        mViewRoi = viewRoiObject('get');

        if strcmp(sVisible, 'off')
            mViewRoi.Checked = 'off';
            tbRoi.Visible = 'off';
            roiToolbar('set', false);
       else
            mViewRoi.Checked = 'on';
            tbRoi.Visible = 'on';
            roiToolbar('set', true);
        end

        [img,~] = imread(sprintf('%s//line.png', sIconsPath));
        img = double(img)/255;

        t8 = uitoggletool(tbRoi,'CData',img,'TooltipString','Draw Line');
        t8.ClickedCallback = @drawlineCallback;

        [img,~] = imread(sprintf('%s//freehand.png', sIconsPath));
        img = double(img)/255;
    %    icon = ind2rgb(img,map);

        t = uitoggletool(tbRoi,'CData',img,'TooltipString','Draw Freehand');
        t.ClickedCallback = @drawfreehandCallback;

%            img = zeros(16,16,3);
        [img,~] = imread(sprintf('%s//assisted.png', sIconsPath));
        img = double(img)/255;

  %      t7 = uitoggletool(tbRoi,'CData',img,'TooltipString','Draw Assisted');
  %      t7.ClickedCallback = @drawassistedCallback;

       [img,~] = imread(sprintf('%s//polygon.png', sIconsPath));
       img = double(img)/255;

        t6 = uitoggletool(tbRoi,'CData',img,'TooltipString','Draw Polygon');
        t6.ClickedCallback = @drawpolygonCallback;

        [img,~] = imread(sprintf('%s//circle.png', sIconsPath));
        img = double(img)/255;

        t2 = uitoggletool(tbRoi,'CData',img,'TooltipString','Draw Circle');
        t2.ClickedCallback = @drawcircleCallback;

        [img,~] = imread(sprintf('%s//elipse.png', sIconsPath));
        img = double(img)/255;

        t5 = uitoggletool(tbRoi,'CData',img,'TooltipString','Draw Elipse');
        t5.ClickedCallback = @drawellipseCallback;

        [img,~] = imread(sprintf('%s//rectangle.png', sIconsPath));
        img = double(img)/255;

        t3 = uitoggletool(tbRoi,'CData',img,'TooltipString','Draw Rectangle');
        t3.ClickedCallback = @drawrectangleCallback;
        
        [img,~] = imread(sprintf('%s//sphere.png', sIconsPath));
        img = double(img)/255;

        t11 = uitoggletool(tbRoi,'CData',img,'TooltipString','Draw Sphere');
        t11.ClickedCallback = @drawsphereCallback;
        
        [img,~] = imread(sprintf('%s//farthest.png', sIconsPath));
        img = double(img)/255;

        tFarthest = uitoggletool(tbRoi,'CData',img,'TooltipString','View Farthest Distances', 'Separator', 'on');
        tFarthest.ClickedCallback = @viewFarthestDistancesCallback;

        [img,~] = imread(sprintf('%s//continuous.png', sIconsPath));
        img = double(img)/255;

        tContinuous = uitoggletool(tbRoi,'CData',img,'TooltipString','Continuous', 'Separator', 'on');
        tContinuous.ClickedCallback = @setContinuousCallback;

        [img,~] = imread(sprintf('%s//result.png', sIconsPath));
        img = double(img)/255;

        t10 = uitoggletool(tbRoi,'CData',img,'TooltipString','Result', 'Tag', 'toolbar');
        t10.ClickedCallback = @figRoiDialogCallback;


%         [img,~] = imread(sprintf('%s//cuboid.png', sIconsPath));
%         img = double(img)/255;

%         t4 = uitoggletool(tbRoi,'CData',img,'TooltipString','Draw Cuboid', 'Separator', 'on');
%         t4.ClickedCallback = @drawcuboidCallback;
    else
        mViewRoi = viewRoiObject('get');

        if strcmp(sVisible, 'off')
            mViewRoi.Checked = 'off';
            tbRoi.Visible = 'off';
            roiToolbar('set', false);
        else
            mViewRoi.Checked = 'on';
            tbRoi.Visible = 'on';
            roiToolbar('set', true);
       end
    end

    function releaseRoiAxeWait(tMenu)

        axeClicked('set', true);
        uiresume(fiMainWindowPtr('get'));

        set(t  , 'State', 'off');
        set(t2 , 'State', 'off');
        set(t3 , 'State', 'off');
  %      set(t4, 'State', 'off');
        set(t5 , 'State', 'off');
        set(t6 , 'State', 'off');
      %  set(t7, 'State', 'off');
        set(t8 , 'State', 'off');
        set(t11, 'State', 'off');

        set(tMenu, 'State', 'on');

    end

    function drawlineCallback(~,~)
        
        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true || ...
           isVsplash('get')          == true
            set(t8, 'State', 'off');
            return;
        end
        
%               releaseRoiAxeWait(t8);
        robotReleaseKey();

        if strcmpi(get(t8, 'State'), 'off')

 %           robotReleaseKey();

            set(t8, 'State', 'off');
            roiSetAxeBorder(false);

            windowButton('set', 'up');
            mouseFcn('set');
            mainToolBarEnable('on');
            setCrossVisibility(true);

            return;
        end

        releaseRoiAxeWait(t8);

%         robotReleaseKey();

        setCrossVisibility(false);

        triangulateCallback();

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
            if ~isvalid(t8)
                return;
            end
            if strcmpi(get(t8, 'State'), 'off')
                return;
            end
     %       if w == 0
            if  strcmpi(windowButton('get'), 'down')

                robotClick();

                mainToolBarEnable('off');
                mouseFcn('reset');

                roiSetAxeBorder(true, gca);

         %       while strcmpi(get(t8, 'State'), 'on')

                    a = drawline(gca, 'Color', 'cyan', 'lineWidth', 1, 'Tag', num2str(randi([-(2^52/2),(2^52/2)],1)), 'LabelVisible', 'on');
                    a.LabelVisible = 'on';
                    if ~isvalid(t8)
                        return;
                    end
                    if strcmpi(get(t8, 'State'), 'off')
                        roiSetAxeBorder(false);

                   %     windowButton('set', 'up');
                   %     mouseFcn('set');
                   %     mainToolBarEnable('on');
                   %     setCrossVisibility(1);

                        return;
                    end

                    dLength = computeRoiLineLength(a);
                    a.Label = [num2str(dLength) ' mm'];

                    addRoi(a, get(uiSeriesPtr('get'), 'Value'), 'Unspecified');

%                    setVoiRoiSegPopup();

                    uimenu(a.UIContextMenu, 'Label', 'Copy Contour' , 'UserData', a, 'Callback', @copyRoiCallback, 'Separator', 'on');
                    uimenu(a.UIContextMenu, 'Label', 'Paste Contour', 'UserData', a, 'Callback', @pasteRoiCallback);

                    uimenu(a.UIContextMenu,'Label', 'Snap To Circles'   , 'UserData',a, 'Callback',@snapLinesToCirclesCallback, 'Separator', 'on');
                    uimenu(a.UIContextMenu,'Label', 'Snap To Rectangles', 'UserData',a, 'Callback',@snapLinesToRectanglesCallback);

                    uimenu(a.UIContextMenu,'Label', 'Edit Label' , 'UserData',a, 'Callback',@editLabelCallback, 'Separator', 'on');

                    uimenu(a.UIContextMenu,'Label', 'Hide/View Label', 'UserData',a, 'Callback',@hideViewLabelCallback);
                    uimenu(a.UIContextMenu,'Label', 'Edit Color'     , 'UserData',a, 'Callback',@editColorCallback);

                    constraintMenu(a);

                    cropMenu(a);
 
                    uimenu(a.UIContextMenu,'Label', 'Display Result' , 'UserData',a, 'Callback',@figRoiDialogCallback, 'Separator', 'on');

%                    set(fiMainWindowPtr('get'), 'WindowScrollWheelFcn' , @wheelScroll);
                    refreshImages();

                    if strcmpi(get(tContinuous, 'State'), 'off')
                        doWhileContinuous = false;
                    end

         %       end

                roiSetAxeBorder(false);

                windowButton('set', 'up');
                mouseFcn('set');
                mainToolBarEnable('on');
            end
        end

        set(t8, 'State', 'off');

        setCrossVisibility(true);

    end
%test hf=[];
%test he=[];
    function drawfreehandCallback(~,~)
        
        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true || ...
           isVsplash('get')          == true
            set(t, 'State', 'off');
            return;
        end
        
%               releaseRoiAxeWait(t);
        robotReleaseKey();

        if strcmpi(get(t, 'State'), 'off')
%                   robotReleaseKey();

            set(t, 'State', 'off');
            roiSetAxeBorder(false);

            windowButton('set', 'up');
            mouseFcn('set');
            mainToolBarEnable('on');
            setCrossVisibility(true);

            return;
        end

        releaseRoiAxeWait(t);

%               robotReleaseKey();

        setCrossVisibility(false);

        triangulateCallback();

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
                end
            end
            
            if ~isvalid(t)
                return;
            end
            
            if strcmpi(get(t, 'State'), 'off')
                return;
            end

%import java.awt.event.*;
%mouse = Robot;
%mouse.mouseRelease(InputEvent.BUTTON3_MASK);
% mouse.mousePress(InputEvent.BUTTON3_MASK);

     %       if w == 0
            if  strcmpi(windowButton('get'), 'down')

                robotClick();

                mainToolBarEnable('off');
                mouseFcn('reset');

                roiSetAxeBorder(true, gca);

   %              while strcmpi(get(t, 'State'), 'on')

                a = drawfreehand(gca, ...
                                'Smoothing'     , 1, ...
                                'Color'         , 'cyan', ...
                                'LineWidth'     , 1, ...
                                'Label'         , roiLabelName(), ...
                                'LabelVisible'  , 'off', ...
                                'Tag'           , num2str(randi([-(2^52/2),(2^52/2)],1)), ...
                                'FaceSelectable', 1, ...
                                'FaceAlpha'     , 0 ...
                                );
                            
  %                  a.Waypoints(:) = false;
%test hf=a;
                    if ~isvalid(t)
                        return;
                    end

                    if strcmpi(get(t, 'State'), 'off')

                        roiSetAxeBorder(false);

                 %       windowButton('set', 'up');
                 %       mouseFcn('set');
                 %       mainToolBarEnable('on');
                 %       setCrossVisibility(1);

                        return;
                    end

                    addRoi(a, get(uiSeriesPtr('get'), 'Value'), 'Unspecified');

%                    setVoiRoiSegPopup();

                    roiDefaultMenu(a);

                    uimenu(a.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData',a, 'Callback', @hideViewFaceAlhaCallback);
                    uimenu(a.UIContextMenu,'Label', 'Clear Waypoints' , 'UserData',a, 'Callback', @clearWaypointsCallback);

                    constraintMenu(a);

                    cropMenu(a);
                    
                    voiMenu(a);

                    uimenu(a.UIContextMenu,'Label', 'Display Result' , 'UserData',a, 'Callback',@figRoiDialogCallback, 'Separator', 'on');

%                    set(fiMainWindowPtr('get'), 'WindowScrollWheelFcn' , @wheelScroll);
                    refreshImages();

                    if strcmpi(get(tContinuous, 'State'), 'off')
                        doWhileContinuous = false;
                    end

             %   end

                roiSetAxeBorder(false);

                windowButton('set', 'up');
                mouseFcn('set');
                mainToolBarEnable('on');
            end
        end

        set(t, 'State', 'off');

        setCrossVisibility(true);

    end

    function drawcircleCallback(~,~)
        
        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true || ...
           isVsplash('get')          == true
            set(t2, 'State', 'off');
            return;
        end
        
%               releaseRoiAxeWait(t2);
        robotReleaseKey();

        if strcmpi(get(t2, 'State'), 'off')
%                    robotReleaseKey();

            set(t2, 'State', 'off');
            roiSetAxeBorder(false);

            windowButton('set', 'up');
            mouseFcn('set');
            mainToolBarEnable('on');
            setCrossVisibility(true);

            return;
        end

        releaseRoiAxeWait(t2);

%               robotReleaseKey();

        setCrossVisibility(false);

        triangulateCallback();

        doWhileContinuous = true;
        while doWhileContinuous == true

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
            
            if ~isvalid(t2)
                return;
            end
            
            if strcmpi(get(t2, 'State'), 'off')
                return;
            end

    %        if w == 0
            if  strcmpi(windowButton('get'), 'down')

                robotClick();

                mainToolBarEnable('off');
                mouseFcn('reset');

                roiSetAxeBorder(true, gca);

          %      while strcmpi(get(t2, 'State'), 'on')
          
                a = drawcircle(gca, ...
                               'Color'         , 'cyan', ...
                               'lineWidth'     , 1, ...
                               'Label'         , roiLabelName(), ...
                               'LabelVisible'  , 'off', ...
                               'Tag'           , num2str(randi([-(2^52/2),(2^52/2)],1)), ...
                               'FaceSelectable', 1, ...
                               'FaceAlpha'     , 0 ...
                               );

                if ~isvalid(t2)
                    return;
                end
                if strcmpi(get(t2, 'State'), 'off')
                    roiSetAxeBorder(false);

%                            windowButton('set', 'up');
%                            mouseFcn('set');
%                            mainToolBarEnable('on');
%                            setCrossVisibility(1);

                    return;
                end

%test he=a;
%test addlistener(he,'MovingROI', @(varargin)editorROIMoving(he, hf));
%test addlistener(he,'ROIMoved', @(varargin)editFreehand(hf, he));

                addRoi(a, get(uiSeriesPtr('get'), 'Value'), 'Unspecified');

%                    setVoiRoiSegPopup();

                roiDefaultMenu(a);

                uimenu(a.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData',a, 'Callback', @hideViewFaceAlhaCallback);

                constraintMenu(a);

                cropMenu(a);

                voiMenu(a);

                uimenu(a.UIContextMenu,'Label', 'Display Result' , 'UserData',a, 'Callback',@figRoiDialogCallback, 'Separator', 'on');

%                    set(fiMainWindowPtr('get'), 'WindowScrollWheelFcn' , @wheelScroll);
                refreshImages();

                if strcmpi(get(tContinuous, 'State'), 'off')
                    doWhileContinuous = false;
                end
            %    end

                roiSetAxeBorder(false);

                windowButton('set', 'up');
                mouseFcn('set');
                mainToolBarEnable('on');
            end
        end

        set(t2, 'State', 'off');

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

%                    a = drawcuboid(gca, 'Color', 'cyan', 'lineWidth', 1);
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
            set(t5, 'State', 'off');
            return;
        end
        
%             releaseRoiAxeWait(t5);
        robotReleaseKey();

        if strcmpi(get(t5, 'State'), 'off')
%                    robotReleaseKey();

            set(t5, 'State', 'off');
            roiSetAxeBorder(false);

            windowButton('set', 'up');
            mouseFcn('set');
            mainToolBarEnable('on');
            setCrossVisibility(true);

            return;
        end

        releaseRoiAxeWait(t5);

%              robotReleaseKey();

        setCrossVisibility(false);

        triangulateCallback();

        doWhileContinuous = true;
        while doWhileContinuous == true

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
            
            if ~isvalid(t5)
                return;
            end
            
            if strcmpi(get(t5, 'State'), 'off')
                return;
            end

%                w = waitforbuttonpress;

%                if w == 0
            if  strcmpi(windowButton('get'), 'down')

                robotClick();

                mainToolBarEnable('off');
                mouseFcn('reset');

                roiSetAxeBorder(true, gca);

         %       while strcmpi(get(t5, 'State'), 'on')

                    a = drawellipse(gca, ...
                                    'Color'         , 'cyan', ...
                                    'lineWidth'     , 1, ...
                                    'Label'         , roiLabelName(), ...
                                    'LabelVisible'  , 'off', ...
                                    'Tag'           , num2str(randi([-(2^52/2),(2^52/2)],1)), ...
                                    'FaceSelectable', 1, ...
                                    'FaceAlpha'     , 0 ...
                                    );
                                
                    if ~isvalid(t5)
                        return;
                    end
                    if strcmpi(get(t5, 'State'), 'off')
                        roiSetAxeBorder(false);

%                            windowButton('set', 'up');
%                            mouseFcn('set');
%                            mainToolBarEnable('on');
%                            setCrossVisibility(1);

                        return;
                    end

                    addRoi(a, get(uiSeriesPtr('get'), 'Value'), 'Unspecified');

%                    setVoiRoiSegPopup();

                    roiDefaultMenu(a);

                    uimenu(a.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData',a, 'Callback', @hideViewFaceAlhaCallback);

                    constraintMenu(a);

                    cropMenu(a);
                    
                    voiMenu(a);

                    uimenu(a.UIContextMenu,'Label', 'Display Result' , 'UserData',a, 'Callback',@figRoiDialogCallback, 'Separator', 'on');

%                    set(fiMainWindowPtr('get'), 'WindowScrollWheelFcn' , @wheelScroll  );
                    refreshImages();

                    if strcmpi(get(tContinuous, 'State'), 'off')
                        doWhileContinuous = false;
                    end
            %    end

                roiSetAxeBorder(false);

                windowButton('set', 'up');
                mouseFcn('set');
                mainToolBarEnable('on');
            end
        end
        
        set(t5, 'State', 'off');

        setCrossVisibility(true);
    end

    function drawrectangleCallback(~,~)
        
        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true || ...
           isVsplash('get')          == true
            set(t3, 'State', 'off');
            return;
        end
        
%             releaseRoiAxeWait(t3);
        robotReleaseKey();

        if strcmpi(get(t3, 'State'), 'off')
%                    robotReleaseKey();

            set(t3, 'State', 'off');
            roiSetAxeBorder(false);

            windowButton('set', 'up');
            mouseFcn('set');
            mainToolBarEnable('on');
            setCrossVisibility(true);

            return;
        end

        releaseRoiAxeWait(t3);

%          robotReleaseKey();

        setCrossVisibility(false);

        triangulateCallback();

        doWhileContinuous = true;
        while doWhileContinuous == true
            
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
            
            if ~isvalid(t3)
                return;
            end
            
            if strcmpi(get(t3, 'State'), 'off')
                return;
            end

    %        w = waitforbuttonpress;

    %        if w == 0
            if  strcmpi(windowButton('get'), 'down')

                robotClick();

                mainToolBarEnable('off');
                mouseFcn('reset');

                roiSetAxeBorder(true, gca);

            %    while strcmpi(get(t3, 'State'), 'on')

                a = drawrectangle(gca, ...
                                  'Rotatable'     , false, ...
                                  'Color'         , 'cyan', ...
                                  'lineWidth'     , 1, ...
                                  'Label'         , roiLabelName(), ...
                                  'LabelVisible'  , 'off', ...
                                  'Tag'           , num2str(randi([-(2^52/2),(2^52/2)],1)), ...
                                  'FaceSelectable', 1, ...
                                  'FaceAlpha'     , 0 ...
                                  );
                if ~isvalid(t3)
                    return;
                end

                if strcmpi(get(t3, 'State'), 'off')
                    roiSetAxeBorder(false);

%                            windowButton('set', 'up');
%                            mouseFcn('set');
%                            mainToolBarEnable('on');
%                            setCrossVisibility(1);

                    return;
                end

                addRoi(a, get(uiSeriesPtr('get'), 'Value'), 'Unspecified');

%                    setVoiRoiSegPopup();

                roiDefaultMenu(a);

                uimenu(a.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData',a, 'Callback', @hideViewFaceAlhaCallback);

                constraintMenu(a);

                cropMenu(a);

                voiMenu(a);

                uimenu(a.UIContextMenu,'Label', 'Display Result' , 'UserData',a, 'Callback',@figRoiDialogCallback, 'Separator', 'on');

%                    set(fiMainWindowPtr('get'), 'WindowScrollWheelFcn' , @wheelScroll);
                refreshImages();

                if strcmpi(get(tContinuous, 'State'), 'off')
                    doWhileContinuous = false;
                end
          %      end

                roiSetAxeBorder(false);

                windowButton('set', 'up');
                mouseFcn('set');
                mainToolBarEnable('on');
            end
        end

        set(t3, 'State', 'off');

        setCrossVisibility(true);
    end


    function drawpolygonCallback(~,~)
        
        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true || ...
           isVsplash('get')          == true       
            set(t6, 'State', 'off');
            return;
        end
        
        robotReleaseKey();

        if strcmpi(get(t6, 'State'), 'off')
  %          robotReleaseKey();

            set(t6, 'State', 'off');
            roiSetAxeBorder(false);

            windowButton('set', 'up');
            mouseFcn('set');
            mainToolBarEnable('on');
            setCrossVisibility(1);

            return;
        end

        releaseRoiAxeWait(t6);

%             robotReleaseKey();

        setCrossVisibility(false);

        triangulateCallback();

        doWhileContinuous = true;
        while doWhileContinuous == true

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
            
            if ~isvalid(t6)
                return;
            end
            
            if strcmpi(get(t6, 'State'), 'off')
                return;
            end

%               w = waitforbuttonpress;

%            if w == 0
            if  strcmpi(windowButton('get'), 'down')

                robotClick();

                mainToolBarEnable('off');
                mouseFcn('reset');

                roiSetAxeBorder(true, gca);

            %    while strcmpi(get(t6, 'State'), 'on')

                a = drawpolygon(gca, ...
                                'Color'         , 'cyan', ...
                                'lineWidth'     , 1, ...
                                'Label'         , roiLabelName(), ...
                                'LabelVisible'  , 'off', ...
                                'Tag'           , num2str(randi([-(2^52/2),(2^52/2)],1)), ...
                                'FaceSelectable', 1, ...
                                'FaceAlpha'     , 0 ...
                                );

                if ~isvalid(t6)
                    return;
                end
                if strcmpi(get(t6, 'State'), 'off')
                    roiSetAxeBorder(false);

%                            windowButton('set', 'up');
%                            mouseFcn('set');
%                            mainToolBarEnable('on');
%                            setCrossVisibility(1);

                    return;
                end

                addRoi(a, get(uiSeriesPtr('get'), 'Value'), 'Unspecified');

%                    setVoiRoiSegPopup();

                uimenu(a.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData',a, 'Callback', @hideViewFaceAlhaCallback);

                roiDefaultMenu(a);

                constraintMenu(a);

                cropMenu(a);

                voiMenu(a);

                uimenu(a.UIContextMenu,'Label', 'Display Result' , 'UserData',a, 'Callback',@figRoiDialogCallback, 'Separator', 'on');

%                    set(fiMainWindowPtr('get'), 'WindowScrollWheelFcn' , @wheelScroll);
                refreshImages();

                if strcmpi(get(tContinuous, 'State'), 'off')
                    doWhileContinuous = false;
                end
             %   end

                roiSetAxeBorder(false);

                windowButton('set', 'up');
                mouseFcn('set');
                mainToolBarEnable('on');
            end
        end

        set(t6, 'State', 'off');

        setCrossVisibility(true);

    end

    function drawsphereCallback(~, ~)
        
        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true || ...
           isVsplash('get')          == true       
            set(t11, 'State', 'off');
            return;
        end
        
        robotReleaseKey();

        if strcmpi(get(t11, 'State'), 'off')
  %          robotReleaseKey();

            set(t11, 'State', 'off');
            roiSetAxeBorder(false);

            windowButton('set', 'up');
            mouseFcn('set');
            mainToolBarEnable('on');
            setCrossVisibility(true);

            return;
        end

        releaseRoiAxeWait(t11);

%             robotReleaseKey();

        setCrossVisibility(false);

        triangulateCallback();

        axeClicked('set', false);
        
        uiwait(fiMainWindowPtr('get'));

        if ~isvalid(t11)
            return;
        end

        if strcmpi(get(t11, 'State'), 'off')
            return;
        end

%               w = waitforbuttonpress;

%            if w == 0
        if  strcmpi(windowButton('get'), 'down')

    %        robotClick();

            mainToolBarEnable('off');
            mouseFcn('reset');

            roiSetAxeBorder(true, gca);

        %    while strcmpi(get(t11, 'State'), 'on')
        
            clickedPt = get(gca,'CurrentPoint');
            clickedPtX = clickedPt(1,1);
            clickedPtY = clickedPt(1,2);
            
            atMetaData = dicomMetaData('get');
            dSliceThickness = computeSliceSpacing(atMetaData);
            
            switch(gca)
                
                case axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) % Coronal                    
                    xPixel = atMetaData{1}.PixelSpacing(1);
                    yPixel = dSliceThickness;                                       
                    
                case axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) % Sagittal
                    xPixel = atMetaData{1}.PixelSpacing(2);
                    yPixel = dSliceThickness;
                    
                otherwise % Axial
                    xPixel = atMetaData{1}.PixelSpacing(1);
                    yPixel = atMetaData{1}.PixelSpacing(2);
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
            
            sTag = num2str(randi([-(2^52/2),(2^52/2)],1));
            
            a = images.roi.Ellipse(gca, ...
                                   'Center'          , [clickedPtX clickedPtY], ...
                                   'SemiAxes'        , [dSemiAxesX dSemiAxesY], ...
                                   'RotationAngle'   , 0, ...
                                   'Deletable'       , 0, ...
                                   'FixedAspectRatio', 1, ...
                                   'StripeColor'     , 'k', ...
                                   'Color'           , 'cyan', ...
                                   'lineWidth'       , 1, ...
                                   'Label'           , roiLabelName(), ...
                                   'LabelVisible'    , 'off', ...
                                   'Tag'             , sTag, ...
                                   'FaceSelectable'  , 1, ...
                                   'FaceAlpha'       , 0, ...
                                   'UserData'        , 'Sphere', ...
                                   'Visible'         , 'on' ...
                                   );
                               
             asTag{1} = sTag;
                        
            if ~isvalid(t11)
                return;
            end
            
            if strcmpi(get(t11, 'State'), 'off')
                
                roiSetAxeBorder(false);

%                            windowButton('set', 'up');
%                            mouseFcn('set');
%                            mainToolBarEnable('on');
%                            setCrossVisibility(1);

                return;
            end

            addRoi(a, get(uiSeriesPtr('get'), 'Value'), 'Unspecified');

%                    setVoiRoiSegPopup();

            uimenu(a.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData',a, 'Callback', @hideViewFaceAlhaCallback);

            roiDefaultMenu(a);

            constraintMenu(a);

            cropMenu(a);

            voiMenu(a);

            uimenu(a.UIContextMenu,'Label', 'Display Result' , 'UserData',a, 'Callback',@figRoiDialogCallback, 'Separator', 'on');

%                    set(fiMainWindowPtr('get'), 'WindowScrollWheelFcn' , @wheelScroll);
            refreshImages();
         %   end

            roiSetAxeBorder(false);

            windowButton('set', 'up');
            mouseFcn('set');
            mainToolBarEnable('on');
            
            dRadius = dSphereDiameter/xPixel/2; % In pixel
            
            aDicomBuffer = dicomBuffer('get');

            switch gca

                % Coronal axe 

                case axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))    

                    sPlane = 'coronal';
                     
                    dSliceNb = sliceNumber('get', 'coronal' );

                    xPixelOffset = clickedPtX;
                    yPixelOffset = dSliceNb;
                    zPixelOffset = clickedPtY;   
                    
                    dPixelRatio = xPixel/yPixel;
                    
                    dBufferSize = size(aDicomBuffer, 1);                    
                    

                % Sagittal axe

                case axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
                    
                    sPlane = 'sagittal';

                    dSliceNb = sliceNumber('get', 'sagittal');

                    xPixelOffset = dSliceNb;
                    yPixelOffset = clickedPtX;
                    zPixelOffset = clickedPtY;
                    
                    dPixelRatio = xPixel/yPixel;
                    
                    dBufferSize = size(aDicomBuffer, 2);

                 % Axial axe

                otherwise
                    sPlane = 'axial';

                    dSliceNb = sliceNumber('get', 'axial');

                    xPixelOffset = clickedPtX;
                    yPixelOffset = clickedPtY;
                    zPixelOffset = dSliceNb;   
                    
                    dPixelRatio = xPixel/yPixel;
                    
                    dBufferSize = size(aDicomBuffer, 3);
                    
            end                  
            
            
            aSphereMask = getSphereMask(aDicomBuffer, xPixelOffset, yPixelOffset, zPixelOffset, dRadius);
            
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
            
                if aSlice(aSlice==1)   

                    isRoiValid = false;

                    boundaries = bwboundaries(aSlice, 'noholes', 8);
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
                    
                    sTag = num2str(randi([-(2^52/2),(2^52/2)],1));
                    
                    a = images.roi.Ellipse(gca, ...
                                           'Center'             , [clickedPtX clickedPtY], ...
                                           'SemiAxes'           , [dSemiAxesX dSemiAxesY], ...
                                           'RotationAngle'      , 0, ...
                                           'Deletable'          , 0, ...
                                           'FixedAspectRatio'   , 1, ...
                                           'InteractionsAllowed', 'none', ...
                                           'StripeColor'        , 'k', ...
                                           'Color'              , 'cyan', ...
                                           'lineWidth'          , 1, ...
                                           'Label'              , roiLabelName(), ...
                                           'LabelVisible'       , 'off', ...
                                           'Tag'                , sTag, ...
                                           'FaceSelectable'     , 1, ...
                                           'FaceAlpha'          , 0, ...
                                           'Visible'            , 'off' ...
                                           );

                    addRoi(a, get(uiSeriesPtr('get'), 'Value'), 'Unspecified');
                    
                    asTag{numel(asTag)+1} = sTag;
                end
            end
            
            createVoiFromRois(get(uiSeriesPtr('get'), 'Value'), asTag, sprintf('Sphere %d mm', dSphereDiameter), [0 1 1], 'Unspecified');
            
            setVoiRoiSegPopup();

            sliceNumber('set', sPlane, dSliceNb);
        end
        
        set(t11, 'State', 'off');

        setCrossVisibility(true);
    
    end

    function viewFarthestDistancesCallback(hObject, ~)

        if strcmpi(get(hObject, 'State'), 'on')
            viewFarthestDistances('set', true);
        else
            viewFarthestDistances('set', false);
        end

        if viewFarthestDistances('get') == false

            atRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

            if ~isempty(atRoiInput) && isVsplash('get') == false
            
                numRoiInputs = numel(atRoiInput);
                
                for bb = 1:numRoiInputs

                    currentRoi = atRoiInput{bb};
                    
                    if isvalid(currentRoi.Object)

                        currentDistances = currentRoi.MaxDistances;
        
                         if ~isempty(currentDistances) 
                            currentDistances.MaxXY.Line.Visible = 'off';
                            currentDistances.MaxCY.Line.Visible = 'off';
                            currentDistances.MaxXY.Text.Visible = 'off';
                            currentDistances.MaxCY.Text.Visible = 'off';                        
                        end
       
                    end
                end
            end            
        end

        if ~isempty(dicomBuffer('get'))
            refreshImages();
        end
    end

    function setContinuousCallback(~, ~)

        axeClicked('set', true);
        uiresume(fiMainWindowPtr('get'));

        set(t  , 'State', 'off');
        set(t2 , 'State', 'off');
        set(t3 , 'State', 'off');
  %      set(t4, 'State', 'off');
        set(t5 , 'State', 'off');
        set(t6 , 'State', 'off');
      %  set(t7, 'State', 'off');
        set(t8 , 'State', 'off');
        set(t11, 'State', 'off');

    end

end
