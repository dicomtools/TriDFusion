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

    function roiSetAxeBorder(bStatus)

        if bStatus == true

            if exist('axe', 'var')
                if gca == axe
                    set(uiOneWindowPtr('get'), 'HighlightColor', [0 1 1]);
                    set(uiOneWindowPtr('get'), 'BorderWidth'   , 1);
                end
            end

            if ~isempty(axes1Ptr('get')) && ...
               ~isempty(axes2Ptr('get')) && ...
               ~isempty(axes3Ptr('get'))

                if gca == axes1Ptr('get')
                    set(uiCorWindowPtr('get'), 'HighlightColor', [0 1 1]);
                    set(uiCorWindowPtr('get'), 'BorderWidth'   , 1);
                end

                if gca == axes2Ptr('get')
                    set(uiSagWindowPtr('get'), 'HighlightColor', [0 1 1]);
                    set(uiSagWindowPtr('get'), 'BorderWidth'   , 1);
                end

                if gca == axes3Ptr('get')
                    set(uiTraWindowPtr('get'), 'HighlightColor', [0 1 1]);
                    set(uiTraWindowPtr('get'), 'BorderWidth'   , 1);
                end 
            end
        else

            if exist('axe', 'var')
                set(uiOneWindowPtr('get'), 'BorderWidth', showBorder('get'));
            end

            if ~isempty(axes1Ptr('get')) && ...
               ~isempty(axes2Ptr('get')) && ...
               ~isempty(axes3Ptr('get'))

                set(uiCorWindowPtr('get'), 'BorderWidth', showBorder('get'));
                set(uiSagWindowPtr('get'), 'BorderWidth', showBorder('get'));
                set(uiTraWindowPtr('get'), 'BorderWidth', showBorder('get'));
            end
        end

    end            

    function releaseRoiAxeWait(tMenu)
        axeClicked('set', true);
        uiresume(fiMainWindowPtr('get'));

        set(t,  'State', 'off');
        set(t2, 'State', 'off');
        set(t3, 'State', 'off');
  %      set(t4, 'State', 'off');
        set(t5, 'State', 'off');
        set(t6, 'State', 'off');
      %  set(t7, 'State', 'off'); 
        set(t8, 'State', 'off'); 

        set(tMenu, 'State', 'on');                

    end

    function drawlineCallback(~,~)

%               releaseRoiAxeWait(t8);
        robotReleaseKey();                 

        if isVsplash('get') == true
            set(t8, 'State', 'off');
            return;                    
        end

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

                roiSetAxeBorder(true); 

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

                    addRoi(a, get(uiSeriesPtr('get'), 'Value'));     
                    
                    uimenu(a.UIContextMenu, 'Label', 'Copy Object' , 'UserData', a, 'Callback', @copyRoiCallback, 'Separator', 'on');
                    uimenu(a.UIContextMenu, 'Label', 'Paste Object', 'UserData', a, 'Callback', @pasteRoiCallback);
                    
                    uimenu(a.UIContextMenu,'Label', 'Snap To Circles'   , 'UserData',a, 'Callback',@snapLinesToCirclesCallback, 'Separator', 'on'); 
                    uimenu(a.UIContextMenu,'Label', 'Snap To Rectangles', 'UserData',a, 'Callback',@snapLinesToRectanglesCallback); 

                    uimenu(a.UIContextMenu,'Label', 'Edit Label' , 'UserData',a, 'Callback',@editLabelCallback, 'Separator', 'on');         

                    uimenu(a.UIContextMenu,'Label', 'Hide/View Label', 'UserData',a, 'Callback',@hideViewLabelCallback); 
                    uimenu(a.UIContextMenu,'Label', 'Edit Color'     , 'UserData',a, 'Callback',@editColorCallback); 

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

        if switchTo3DMode('get')     == false && ...
           switchToIsoSurface('get') == false && ...
           switchToMIPMode('get')    == false              
            setCrossVisibility(true);
        end

    end       

    function drawfreehandCallback(~,~)

%               releaseRoiAxeWait(t);
        robotReleaseKey();  

        if isVsplash('get') == true
            set(t, 'State', 'off');
            return;                    
        end

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

                roiSetAxeBorder(true);                              

   %              while strcmpi(get(t, 'State'), 'on')

                    a = drawfreehand(gca, 'Color', 'cyan', 'LineWidth', 1, 'Label', roiLabelName(), 'LabelVisible', 'off', 'Tag', num2str(randi([-(2^52/2),(2^52/2)],1)), 'FaceSelectable', 1, 'FaceAlpha', 0);  
  %                  a.Waypoints(:) = false;

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

                    addRoi(a, get(uiSeriesPtr('get'), 'Value'));                  

                    roiDefaultMenu(a);

                    uimenu(a.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData',a, 'Callback', @hideViewFaceAlhaCallback); 
                    uimenu(a.UIContextMenu,'Label', 'Clear Waypoints' , 'UserData',a, 'Callback', @clearWaypointsCallback); 

                    cropMenu(a);

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

        if switchTo3DMode('get')     == false && ...
           switchToIsoSurface('get') == false && ...
           switchToMIPMode('get')    == false
            setCrossVisibility(true);
        end


    end            

    function drawcircleCallback(~,~)

%               releaseRoiAxeWait(t2);
        robotReleaseKey();  

        if isVsplash('get') == true
            set(t2, 'State', 'off');
            return;                    
        end

        if strcmpi(get(t2, 'State'), 'off')    
%                    robotReleaseKey();

            set(t2, 'State', 'off');
            roiSetAxeBorder(false);                    

            windowButton('set', 'up');
            mouseFcn('set');
            mainToolBarEnable('on');   
            setCrossVisibility(1);

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

                roiSetAxeBorder(true);         

          %      while strcmpi(get(t2, 'State'), 'on')

                    a = drawcircle(gca, 'Color', 'cyan', 'lineWidth', 1, 'Label', roiLabelName(), 'LabelVisible', 'off', 'Tag', num2str(randi([-(2^52/2),(2^52/2)],1)), 'FaceSelectable', 1, 'FaceAlpha', 0);  
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

                    addRoi(a, get(uiSeriesPtr('get'), 'Value'));                  

                    roiDefaultMenu(a);
                    
                    uimenu(a.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData',a, 'Callback', @hideViewFaceAlhaCallback); 

                    cropMenu(a);

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

        if switchTo3DMode('get')     == false && ...
           switchToIsoSurface('get') == false && ...
           switchToMIPMode('get')    == false              
            setCrossVisibility(true);
        end
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

%             releaseRoiAxeWait(t5);
        robotReleaseKey();  

        if isVsplash('get') == true
            set(t5, 'State', 'off');
            return;                    
        end       

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

                roiSetAxeBorder(true);  

         %       while strcmpi(get(t5, 'State'), 'on')

                    a = drawellipse(gca, 'Color', 'cyan', 'lineWidth', 1, 'Label', roiLabelName(), 'LabelVisible', 'off', 'Tag', num2str(randi([-(2^52/2),(2^52/2)],1)), 'FaceSelectable', 1, 'FaceAlpha', 0); 
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

                    addRoi(a, get(uiSeriesPtr('get'), 'Value'));                  

                    roiDefaultMenu(a);
                    
                    uimenu(a.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData',a, 'Callback', @hideViewFaceAlhaCallback); 

                    cropMenu(a);

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

        if switchTo3DMode('get')     == false && ...
           switchToIsoSurface('get') == false && ...
           switchToMIPMode('get')    == false              
            setCrossVisibility(true);
        end
    end

    function drawrectangleCallback(~,~) 

%             releaseRoiAxeWait(t3);
        robotReleaseKey();  

        if isVsplash('get') == true
            set(t3, 'State', 'off');
            return;                    
        end

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

                roiSetAxeBorder(true);

            %    while strcmpi(get(t3, 'State'), 'on')

                    a = drawrectangle(gca, 'Color', 'cyan', 'lineWidth', 1, 'Label', roiLabelName(), 'LabelVisible', 'off', 'Tag', num2str(randi([-(2^52/2),(2^52/2)],1)), 'FaceSelectable', 1, 'FaceAlpha', 0); 
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

                    addRoi(a, get(uiSeriesPtr('get'), 'Value'));                  

                    roiDefaultMenu(a);
                    
                    uimenu(a.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData',a, 'Callback', @hideViewFaceAlhaCallback); 

                    cropMenu(a);

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

        if switchTo3DMode('get')     == false && ...
           switchToIsoSurface('get') == false && ...
           switchToMIPMode('get')    == false              
            setCrossVisibility(true);
        end
    end

    function drawpolygonCallback(~,~)                   

        robotReleaseKey();  

        if isVsplash('get') == true
            set(t6, 'State', 'off');
            return;                    
        end

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

                roiSetAxeBorder(true);

            %    while strcmpi(get(t6, 'State'), 'on')

                    a = drawpolygon(gca, 'Color', 'cyan', 'lineWidth', 1, 'Label', roiLabelName(), 'LabelVisible', 'off', 'Tag', num2str(randi([-(2^52/2),(2^52/2)],1)), 'FaceSelectable', 1, 'FaceAlpha', 0);  
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

                    addRoi(a, get(uiSeriesPtr('get'), 'Value'));       
                    
                    uimenu(a.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData',a, 'Callback', @hideViewFaceAlhaCallback); 

                    roiDefaultMenu(a);

                    cropMenu(a);

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

        if switchTo3DMode('get')     == false && ...
           switchToIsoSurface('get') == false && ...
           switchToMIPMode('get')    == false              
            setCrossVisibility(true);
        end

    end    

    function setContinuousCallback(~, ~)
        
        axeClicked('set', true);
        uiresume(fiMainWindowPtr('get'));

        set(t,  'State', 'off');
        set(t2, 'State', 'off');
        set(t3, 'State', 'off');
  %      set(t4, 'State', 'off');
        set(t5, 'State', 'off');
        set(t6, 'State', 'off');
      %  set(t7, 'State', 'off'); 
        set(t8, 'State', 'off'); 
        
    end

end
