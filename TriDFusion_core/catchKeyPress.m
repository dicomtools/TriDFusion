function catchKeyPress(~,evnt)
%function catchKeyPress(~,evnt)
%Catch\Execute Keyboard Key Press.
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

    persistent pdToggle;

    if isempty(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')))
        
        return;
    end

    if strcmpi(evnt.Key,'x') % Activate the interpolaion

        if isMoveImageActivated('get') == true || ...
           switchTo3DMode('get')       == true || ...
           switchToIsoSurface('get')   == true || ...
           switchToMIPMode('get')      == true

            return;
        end       

        atRoiMenu = roiMenuObject('get');

        if ~isempty(atRoiMenu)

            for ii=1:numel(atRoiMenu.Children)

                toggleTool = atRoiMenu.Children(ii);
                
                clickedCallback = func2str(toggleTool.ClickedCallback);

                if contains(clickedCallback, 'setInterpolateCallback') 

                    if strcmpi(get(toggleTool, 'State'), 'on')
                        
                        set(toggleTool, 'State', 'off');
                    else

                        set(toggleTool, 'State', 'on');
                    end

                    callbackFunction = get(toggleTool, 'ClickedCallback');  

                    callbackFunction();
                    
                end

            end
        end
    end

    if strcmpi(evnt.Key,'b') % Activate the brush

        if isMoveImageActivated('get') == false && ...
           switchTo3DMode('get')       == false && ...
           switchToIsoSurface('get')   == false && ...
           switchToMIPMode('get')      == false

            atRoiMenu = roiMenuObject('get');

            if ~isempty(atRoiMenu)

                for ii=1:numel(atRoiMenu.Children)

                    toggleTool = atRoiMenu.Children(ii);
                    
                    clickedCallback = func2str(toggleTool.ClickedCallback);
                    % if isempty(toggleTool.OnCallback)
                    %     onCallback = '';
                    % else
                    %     onCallback = func2str(toggleTool.OnCallback);
                    % end

                    if contains(clickedCallback, 'set2DBrushCallback') 

                        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

                        callbackFunction = get(toggleTool, 'ClickedCallback');  

                        % set(toggleTool, 'State', 'on');

                        windowButton('set', 'down');

                        pAxe = getAxeFromMousePosition(get(uiSeriesPtr('get'), 'Value'));

                        if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 3) ~= 1
 
                            if pAxe ~= axes1Ptr('get', [], dSeriesOffset) && ... % Coronal
                               pAxe ~= axes2Ptr('get', [], dSeriesOffset) && ... % Sagittal
                               pAxe ~= axes3Ptr('get', [], dSeriesOffset)        % Axial

                                pAxe = axes3Ptr('get', [], dSeriesOffset);
    
                            end
                        end

                        callbackFunction(toggleTool, pAxe);
                        
                        % set(toggleTool, 'State', 'off');

                        windowButton('set', 'up');
                    end
    
                end
            end

        end
    end

    if strcmpi(evnt.Key,'shift') % Activate mouse up and down scroll mode

        if isMoveImageActivated('get') == false && ...
           switchTo3DMode('get')       == false && ...
           switchToIsoSurface('get')   == false && ...
           switchToMIPMode('get')      == false

            if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 3) ~= 1

                set(fiMainWindowPtr('get'), 'Pointer', 'bottom');
    
                setCrossVisibility(false);            
            end
        end
    end

    if strcmpi(evnt.Key,'d')
        
        % dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

        if isMoveImageActivated('get') == true || ...
           switchTo3DMode('get')       == true || ...
           switchToIsoSurface('get')   == true || ...
           switchToMIPMode('get')      == true

            return;
        end       

        atRoiMenu = roiMenuObject('get');

        if ~isempty(atRoiMenu)

            for ii=1:numel(atRoiMenu.Children)

                toggleTool = atRoiMenu.Children(ii);
                
                clickedCallback = func2str(toggleTool.ClickedCallback);

                if contains(clickedCallback, 'drawfreehandCallback') 

                    if strcmpi(get(toggleTool, 'State'), 'on')
                        
                        set(toggleTool, 'State', 'off');
                    else

                        set(toggleTool, 'State', 'on');
                    end

                    callbackFunction = get(toggleTool, 'ClickedCallback');  

                    callbackFunction();
                    
                end

            end
        end
    end

    if strcmpi(evnt.Key,'p')
        
        if isMoveImageActivated('get') == true || ...
           switchTo3DMode('get')       == true || ...
           switchToIsoSurface('get')   == true || ...
           switchToMIPMode('get')      == true

            return;
        end       

        atRoiMenu = roiMenuObject('get');

        if ~isempty(atRoiMenu)

            for ii=1:numel(atRoiMenu.Children)

                toggleTool = atRoiMenu.Children(ii);
                
                clickedCallback = func2str(toggleTool.ClickedCallback);

                if contains(clickedCallback, 'drawpolygonCallback') 

                    if strcmpi(get(toggleTool, 'State'), 'on')
                        
                        set(toggleTool, 'State', 'off');
                    else

                        set(toggleTool, 'State', 'on');
                    end

                    callbackFunction = get(toggleTool, 'ClickedCallback');  

                    callbackFunction();
                end

            end
        end
    end

    if strcmpi(evnt.Key,'v')
        
        % dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

        if isMoveImageActivated('get') == true || ...
           switchTo3DMode('get')       == true || ...
           switchToIsoSurface('get')   == true || ...
           switchToMIPMode('get')      == true

            return;
        end       
        
        atRoiMenu = roiMenuObject('get');

        if ~isempty(atRoiMenu)

            for ii=1:numel(atRoiMenu.Children)

                toggleTool = atRoiMenu.Children(ii);
                
                clickedCallback = func2str(toggleTool.ClickedCallback);

                if contains(clickedCallback, 'drawClickVoiCallback') 

                    callbackFunction = get(toggleTool, 'ClickedCallback');  

                    % windowButton('set', 'down');

                    % pAxe = gca(fiMainWindowPtr('get'));
                    if strcmpi(get(toggleTool, 'State'), 'on')

                        set(toggleTool, 'State', 'off');
                    else

                        set(toggleTool, 'State', 'on');
                    end

                    callbackFunction();
                    
                    % set(toggleTool, 'State', 'off');

                    % windowButton('set', 'up');
                end

            end
        end
    end

    if strcmpi(evnt.Key,'m')
        
        % dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

        if isMoveImageActivated('get') == true || ...
           switchTo3DMode('get')       == true || ...
           switchToIsoSurface('get')   == true || ...
           switchToMIPMode('get')      == true

            return;
        end       
        
        atRoiMenu = roiMenuObject('get');

        if ~isempty(atRoiMenu)

            for ii=1:numel(atRoiMenu.Children)

                toggleTool = atRoiMenu.Children(ii);
                
                clickedCallback = func2str(toggleTool.ClickedCallback);

                if contains(clickedCallback, 'drawlineCallback') 

                    callbackFunction = get(toggleTool, 'ClickedCallback');  

                    if strcmpi(get(toggleTool, 'State'), 'on')

                        set(toggleTool, 'State', 'off');
                    else

                        set(toggleTool, 'State', 'on');
                    end

                    callbackFunction();

                end

            end
        end
    end

    if strcmpi(evnt.Key,'e')
        
        % dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

        if isMoveImageActivated('get') == true || ...
           switchTo3DMode('get')       == true || ...
           switchToIsoSurface('get')   == true || ...
           switchToMIPMode('get')      == true

            return;
        end       
        
        atRoiMenu = roiMenuObject('get');

        if ~isempty(atRoiMenu)

            for ii=1:numel(atRoiMenu.Children)

                toggleTool = atRoiMenu.Children(ii);
                
                clickedCallback = func2str(toggleTool.ClickedCallback);

                if contains(clickedCallback, 'drawsphereCallback') 

                    callbackFunction = get(toggleTool, 'ClickedCallback');  

                    if strcmpi(get(toggleTool, 'State'), 'on')

                        set(toggleTool, 'State', 'off');
                    else

                        set(toggleTool, 'State', 'on');
                    end

                    callbackFunction();

                end

            end
        end
    end

    if strcmpi(evnt.Key,'k')
        
        % dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

        if isMoveImageActivated('get') == true || ...
           switchTo3DMode('get')       == true || ...
           switchToIsoSurface('get')   == true || ...
           switchToMIPMode('get')      == true

            return;
        end       
        
        atRoiMenu = roiMenuObject('get');

        if ~isempty(atRoiMenu)

            for ii=1:numel(atRoiMenu.Children)

                toggleTool = atRoiMenu.Children(ii);
                
                clickedCallback = func2str(toggleTool.ClickedCallback);

                if contains(clickedCallback, 'set2DScissorCallback') 

                    callbackFunction = get(toggleTool, 'ClickedCallback');  

                    if strcmpi(get(toggleTool, 'State'), 'on')

                        set(toggleTool, 'State', 'off');
                    else

                        set(toggleTool, 'State', 'on');
                    end

                    callbackFunction();

                end

            end
        end
    end

    if strcmpi(evnt.Key,'tab')
        
        if isMoveImageActivated('get') == true || ...
           switchTo3DMode('get')       == true || ...
           switchToIsoSurface('get')   == true || ...
           switchToMIPMode('get')      == true

            return;
        end
        
        if ~isempty(voiTemplate('get', get(uiSeriesPtr('get'), 'Value')))

            uiAddVoiRoiPanel = uiAddVoiRoiPanelObject('get');

            if ~isempty(uiAddVoiRoiPanel)
    
                callbackFunction = get(uiAddVoiRoiPanel, 'Callback');  
                
                callbackFunction(uiAddVoiRoiPanel);
            end
        end
    end

    if strcmpi(evnt.Key,'s')
        
        if isMoveImageActivated('get') == true || ...
           switchTo3DMode('get')       == true || ...
           switchToIsoSurface('get')   == true || ...
           switchToMIPMode('get')      == true

            return;
        end

        if ~isempty(roiTemplate('get', get(uiSeriesPtr('get'), 'Value'))) 

            txtContourVisibilityPanel = txtContourVisibilityPanelObject('get');

            if ~isempty(txtContourVisibilityPanel)
    
                buttonDownFcn = get(txtContourVisibilityPanel, 'ButtonDownFcn');  
                
                buttonDownFcn(txtContourVisibilityPanel);
            end
        end
    end

    if strcmpi(evnt.Key,'escape')

        atRoiMenu = roiMenuObject('get');

        if ~isempty(atRoiMenu)

            for ii=1:numel(atRoiMenu.Children)

                set(atRoiMenu.Children(ii), 'State', 'off');
            end
        end

        % windowButton('set', 'up');
        axeClicked('set', true);

        uiresume(fiMainWindowPtr('get'));

        uiCreateVoiRoiPanel = uiCreateVoiRoiPanelObject('get');
        if ~isempty(uiCreateVoiRoiPanel)
            
            if strcmpi(uiCreateVoiRoiPanel.String, 'Cancel')

                callbackFunction = get(uiCreateVoiRoiPanel, 'Callback');  
                callbackFunction(uiCreateVoiRoiPanel);
            end
        end

        if is2DBrush('get') == true

            is2DBrush('set', false);

            pRoiPtr = brush2Dptr('get');

            if ~isempty(pRoiPtr)
                delete(pRoiPtr);
                brush2Dptr('set', []);
            end

            roiSetAxeBorder(false);

            setCrossVisibility(true);

            if ~isempty(atRoiMenu)
    
                for ii=1:numel(atRoiMenu.Children)
    
                    set(atRoiMenu.Children(ii), 'Enable', 'on');
                end
            end 
        end
    end

    if strcmpi(evnt.Key,'add')

        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true 
       
            if multiFrame3DZoom('get') > 1.2
                multiFrame3DZoom('set', multiFrame3DZoom('get')/1.2);
            end

            if multiFrame3DPlayback('get') == false && ...
                multiFrame3DRecord('get')  == false
            
                zoom3D('in', 1.2);
            end         
            
            initGate3DObject('set', true);
        else

            multiFrameZoom('set', 'out', 1);

            pAxe = getAxeFromMousePosition(dSeriesOffset);

            % pAxe = gca(fiMainWindowPtr('get'));

            if multiFrameZoom('get', 'axe') ~= pAxe

                multiFrameZoom('set', 'in', 1);
            end

            dZFactor = multiFrameZoom('get', 'in');
            dZFactor = dZFactor+0.025;
            
            multiFrameZoom('set', 'in', dZFactor);

            switch pAxe

                case axePtr('get', [], dSeriesOffset)

                    axesHandle = axePtr('get', [], dSeriesOffset);

                case axes1Ptr('get', [], dSeriesOffset)

                    axesHandle = axes1Ptr('get', [], dSeriesOffset);

                    % zoom(axes1Ptr('get', [], dSeriesOffset), dZFactor);
                    % multiFrameZoom('set', 'axe', axes1Ptr('get', [], dSeriesOffset));

                case axes2Ptr('get', [], dSeriesOffset)

                    axesHandle = axes2Ptr('get', [], dSeriesOffset);

                    % zoom(axes2Ptr('get', [], dSeriesOffset), dZFactor);
                    % multiFrameZoom('set', 'axe', axes2Ptr('get', [], dSeriesOffset));
                    
                case axes3Ptr('get', [], dSeriesOffset)

                    axesHandle = axes3Ptr('get', [], dSeriesOffset);

                    % zoom(axes3Ptr('get', [], dSeriesOffset), dZFactor);
                    % multiFrameZoom('set', 'axe', axes3Ptr('get', [], dSeriesOffset));
                    
                case axesMipPtr('get', [], dSeriesOffset)

                    axesHandle = axesMipPtr('get', [], dSeriesOffset);

                    % zoom(axesMipPtr('get', [], dSeriesOffset), dZFactor);
                    % multiFrameZoom('set', 'axe', axesMipPtr('get', [], dSeriesOffset));
                    
                otherwise

                    axesHandle = axes3Ptr('get', [], dSeriesOffset);

                    % zoom(axes3Ptr('get', [], dSeriesOffset), dZFactor);
                    % multiFrameZoom('set', 'axe', axes3Ptr('get', [], dSeriesOffset));
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

        end
    end
    
    if strcmpi(evnt.Key,'subtract')
        
        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true 
       
            multiFrame3DZoom('set', multiFrame3DZoom('get')*1.2);

             if multiFrame3DPlayback('get') == false && ...
                multiFrame3DRecord('get')   == false
            
                zoom3D('out', 1.2);
             end

             initGate3DObject('set', true);     
        else

            multiFrameZoom('set', 'in', 1);

            % pAxe = gca(fiMainWindowPtr('get'));
            pAxe = getAxeFromMousePosition(dSeriesOffset);

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

                    % zoom(axes1Ptr('get', [], dSeriesOffset), dZFactor);
                    % multiFrameZoom('set', 'axe', axes1Ptr('get', [], dSeriesOffset));

                case axes2Ptr('get', [], dSeriesOffset)

                    axesHandle = axes2Ptr('get', [], dSeriesOffset);

                    % zoom(axes2Ptr('get', [], dSeriesOffset), dZFactor);
                    % multiFrameZoom('set', 'axe', axes2Ptr('get', [], dSeriesOffset));
                    
                case axes3Ptr('get', [], dSeriesOffset)

                    axesHandle = axes3Ptr('get', [], dSeriesOffset);

                    % zoom(axes3Ptr('get', [], dSeriesOffset), dZFactor);
                    % multiFrameZoom('set', 'axe', axes3Ptr('get', [], dSeriesOffset));
                    
                case axesMipPtr('get', [], dSeriesOffset)

                    axesHandle = axesMipPtr('get', [], dSeriesOffset);

                    % zoom(axesMipPtr('get', [], dSeriesOffset), dZFactor);
                    % multiFrameZoom('set', 'axe', axesMipPtr('get', [], dSeriesOffset));
                    
                otherwise

                    axesHandle = axes3Ptr('get', [], dSeriesOffset);

                    % zoom(axes3Ptr('get', [], dSeriesOffset), dZFactor);
                    % multiFrameZoom('set', 'axe', axes3Ptr('get', [], dSeriesOffset));
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

        end
    end    
    
    if strcmpi(evnt.Key,'uparrow')

        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true 

            flip3Dobject('up');    
        else               
            if size(dicomBuffer('get', [], dSeriesOffset), 3) ~= 1

                % windowButton('set', 'up');  

                pAxe = gca(fiMainWindowPtr('get'));
             
                switch pAxe

                    case axes1Ptr('get', [], dSeriesOffset)

                        dLastSlice = size(dicomBuffer('get', [], dSeriesOffset), 1);  
            
                        dCurrentSlice = sliceNumber('get', 'coronal');
                        
                        if dCurrentSlice < dLastSlice
        
                            dCurrentSlice = dCurrentSlice +1;
                        end
        
                        if dCurrentSlice == dLastSlice
        
                            dCurrentSlice = 1;
                        end  

                        % sliceNumber('set', 'coronal', dCurrentSlice);
                        
                        set(uiSliderCorPtr('get'), 'Value', dCurrentSlice / dLastSlice);
            
                        sliderCorCallback();
                                  
                    case axes2Ptr('get', [], dSeriesOffset)

                        dLastSlice = size(dicomBuffer('get', [], dSeriesOffset), 2);    
            
                        dCurrentSlice = sliceNumber('get', 'sagittal'); 
                        
                        if dCurrentSlice < dLastSlice

                            dCurrentSlice = dCurrentSlice +1;
                        end
        
                        if dCurrentSlice == dLastSlice

                            dCurrentSlice = 1;
                        end 

                        % sliceNumber('set', 'sagittal', iSliceNumber);    

                        set(uiSliderSagPtr('get'), 'Value', dCurrentSlice / dLastSlice);

                        sliderSagCallback();
                    
                    otherwise  

                        dLastSlice = size(dicomBuffer('get', [], dSeriesOffset), 3);  
            
                        dCurrentSlice = sliceNumber('get', 'axial');

                        if dCurrentSlice > 1
                            dCurrentSlice = dCurrentSlice -1;
                        else
                            dCurrentSlice = dLastSlice;
                        end 

                        % sliceNumber('set', 'axial', dCurrentSlice);    

                        set(uiSliderTraPtr('get'), 'Value', 1 - (dCurrentSlice / dLastSlice));       
                        
                        sliderTraCallback();
                end

                % refreshImages();                
                
                % windowButton('set', 'up');  

            end
                               
        end
    end   
    
    if strcmpi(evnt.Key,'downarrow')
      
        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true 

            flip3Dobject('down');   
        else
            if size(dicomBuffer('get', [], dSeriesOffset), 3) ~= 1

                % windowButton('set', 'down'); 

                pAxe = gca(fiMainWindowPtr('get'));

                % pAxe = getAxeFromMousePosition(get(uiSeriesPtr('get'), 'Value'));
           
                switch pAxe

                    case axes1Ptr('get', [], dSeriesOffset)

                        dLastSlice = size(dicomBuffer('get', [], dSeriesOffset), 1);  
            
                        dCurrentSlice = sliceNumber('get', 'coronal');
                    
                        if dCurrentSlice > 1
            
                            dCurrentSlice = dCurrentSlice -1;
                        else
                            dCurrentSlice = dLastSlice;
                        end                                                     
            
                        % sliceNumber('set', 'coronal', dCurrentSlice);
                        
                        set(uiSliderCorPtr('get'), 'Value', dCurrentSlice / dLastSlice);
            
                        sliderCorCallback();
                        
                    case axes2Ptr('get', [], dSeriesOffset)

                        dLastSlice = size(dicomBuffer('get', [], dSeriesOffset), 2);    
            
                        dCurrentSlice = sliceNumber('get', 'sagittal');        
        
                        if dCurrentSlice > 1
        
                            dCurrentSlice = dCurrentSlice -1;
                        else
                            dCurrentSlice = dLastSlice;
                        end                              
                          
                        % sliceNumber('set', 'sagittal', dCurrentSlice);
                        
                        set(uiSliderSagPtr('get'), 'Value', dCurrentSlice / dLastSlice);
            
                        sliderSagCallback();
                        
                    otherwise    

                        dLastSlice = size(dicomBuffer('get', [], dSeriesOffset), 3);  
            
                        dCurrentSlice = sliceNumber('get', 'axial');
            
                        if dCurrentSlice < dLastSlice
        
                            dCurrentSlice = dCurrentSlice +1;
                        else
                            dCurrentSlice = 1;
                        end                              
                
                        % sliceNumber('set', 'axial', dCurrentSlice);
            
                        set(uiSliderTraPtr('get'), 'Value', 1 - (dCurrentSlice / dLastSlice));       
            
                        sliderTraCallback();                     
                end
                
                % refreshImages();
                % 
                % windowButton('set', 'up'); 
            end            
        end
    end     
    
    if strcmpi(evnt.Key,'leftarrow')
        
        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true 

             flip3Dobject('left');                             
        else
            if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 3) ~= 1 && ...
               isVsplash('get') == false    
                
                iMipAngleValue = mipAngle('get');
    

                iMipAngleValue = iMipAngleValue-1;
                
                
                if iMipAngleValue <=0
                    iMipAngleValue = 32;
                end   
                    
                if iMipAngleValue > 32
                    iMipAngleValue = 1;
                end    
    
                % mipAngle('set', iMipAngleValue);                    
    
                if iMipAngleValue == 1
                    dMipSliderValue = 0;
                else
                    dMipSliderValue = iMipAngleValue/32;
                end
    
                set(uiSliderMipPtr('get'), 'Value', dMipSliderValue);
    
                % plotRotatedRoiOnMip(axesMipPtr('get', [], dSeriesOffset), dicomBuffer('get', [], dSeriesOffset), iMipAngleValue);       
                sliderMipCallback();
                    
            end  
        end
    end
    
    if strcmpi(evnt.Key,'rightarrow')

        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true 

              flip3Dobject('right');                             
        else
            if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 3) ~= 1 && isVsplash('get') == false    
                
                iMipAngleValue = mipAngle('get');
        
                iMipAngleValue = iMipAngleValue+1;
   
                if iMipAngleValue <=0
                    iMipAngleValue = 32;
                end   
                    
                if iMipAngleValue > 32
                    iMipAngleValue = 1;
                end    
    
                % mipAngle('set', iMipAngleValue);                    
    
                if iMipAngleValue == 1
                    dMipSliderValue = 0;
                else
                    dMipSliderValue = iMipAngleValue/32;
                end
    
                set(uiSliderMipPtr('get'), 'Value', dMipSliderValue);
    
                % plotRotatedRoiOnMip(axesMipPtr('get', [], dSeriesOffset), dicomBuffer('get', [], dSeriesOffset), iMipAngleValue);       
                sliderMipCallback();               
            end            
        end
    end 

    if strcmpi(evnt.Key,'space')
        
        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true || ...
           isempty(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')))

            return;
        end

        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

        set(fiMainWindowPtr('get'), 'Pointer', 'default');            

        releaseRoiWait();

%        atMetaData = dicomMetaData('get');                
        sUnitDisplay = getSerieUnitValue(get(uiSeriesPtr('get'), 'Value'));                        
        if strcmpi(sUnitDisplay, 'SUV')

            tQuant = quantificationTemplate('get');   

            lMin = suvWindowLevel('get', 'min')/tQuant.tSUV.dScale;  
            lMax = suvWindowLevel('get', 'max')/tQuant.tSUV.dScale;   

%            lMin = min(dicomBuffer('get'), [], 'all');
%            lMax = max(dicomBuffer('get'), [], 'all');
        else
            lMin = min(dicomBuffer('get', [], dSeriesOffset), [], 'all');
            lMax = max(dicomBuffer('get', [], dSeriesOffset), [], 'all');
        end

        setWindowMinMax(lMax, lMin);                    

%    isMoveImageActivated('set', false);
    
        if zoomTool('get')
        
            set(zoomMenu('get'), 'Checked', 'off');
    
            set(btnZoomPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
            set(btnZoomPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
            set(btnZoomPtr('get'), 'FontWeight', 'normal');
            
            zoomTool('set', false);
            zoom(fiMainWindowPtr('get'), 'off');           
        end  

        multiFrameZoom('set', 'in',  1);
        multiFrameZoom('set', 'out', 1);

        if panTool('get')
                  
            set(panMenu('get'), 'Checked', 'off');
    
            set(btnPanPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
            set(btnPanPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
            set(btnPanPtr('get'), 'FontWeight', 'normal');
    
            panTool('set', false);
            pan(fiMainWindowPtr('get'), 'off'); 
    
        end

        set(btnTriangulatePtr('get'), 'BackgroundColor', viewerButtonPushedBackgroundColor('get'));
        set(btnTriangulatePtr('get'), 'ForegroundColor', viewerButtonPushedForegroundColor('get'));
        set(btnTriangulatePtr('get'), 'FontWeight', 'bold');
        
        if isMoveImageActivated('get') == true

            set(fiMainWindowPtr('get'), 'Pointer', 'fleur');           
        end

        if size(dicomBuffer('get', [], dSeriesOffset), 3) == 1   

             resetAxePlotView(axePtr('get', [], dSeriesOffset));          
        else
            resetAxePlotView(axes1Ptr('get', [], dSeriesOffset));
            resetAxePlotView(axes2Ptr('get', [], dSeriesOffset));
            resetAxePlotView(axes3Ptr('get', [], dSeriesOffset));

            if link2DMip('get') == true && isVsplash('get') == false

                resetAxePlotView(axesMipPtr('get', [], dSeriesOffset));
            end            
        end

    end

    if strcmpi(evnt.Key,'c')
        
       if switchTo3DMode('get')     == true || ...
          switchToIsoSurface('get') == true || ...
          switchToMIPMode('get')    == true || ...
          isVsplash('get')          == true        

            return;
        end

        if ismember('shift', get(fiMainWindowPtr('get'),'CurrentModifier'))

            if crossSize('get') > 30

                crossSize('set', 0);
            else    
                crossSize('set', crossSize('get')+10);
            end
            % redrawCross('all');
        else
            if crossActivate('get')
                crossActivate('set', false);
            else
                crossActivate('set', true);                       
            end

        end 

        if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 3) == 1
        %    delete(findobj(axe, 'Type', 'line'))
        else
            alAxes1Line   = axesLine('get', 'axes1');
            alAxes2Line   = axesLine('get', 'axes2');
            alAxes3Line   = axesLine('get', 'axes3');
            alAxesMipLine = axesLine('get', 'axesMip');

            for ii1=1:numel(alAxes1Line)    
                alAxes1Line{ii1}.Visible = crossActivate('get');
            end

            for ii2=1:numel(alAxes2Line)    
                alAxes2Line{ii2}.Visible = crossActivate('get');
            end

            for ii3=1:numel(alAxes3Line)    
                alAxes3Line{ii3}.Visible = crossActivate('get');
            end 
            
            for iiMip=1:numel(alAxesMipLine)    
                alAxesMipLine{iiMip}.Visible = crossActivate('get');
            end             
        %    delete(findobj(axes1, 'Type', 'line'))
        %    delete(findobj(axes2, 'Type', 'line'))
        %    delete(findobj(axes3, 'Type', 'line'))
        end                

        refreshImages();
    end

    if strcmpi(evnt.Key,'d')  

 %       setDataCursorCallback();   
    end

    persistent pdColorOffset;
    persistent pdFusionColorOffset;
    persistent pdInvertColor;
    persistent pdBackgroundColor;
    persistent pdOverlayColor;
    persistent pdAlphaSlider;

    if strcmpi(evnt.Key,'f')
 
        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true
            return;
        end
        
        dNbFusedSeries = 0;
        
        if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 3) == 1
            dNbSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
            for rr=1:dNbSeries
                imAxeF = imAxeFPtr('get', [], rr);
                if ~isempty(imAxeF)               
                    dNbFusedSeries = dNbFusedSeries+1; % Multiple fusion
                end
            end
        else
            dNbSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
            for rr=1:dNbSeries
                    
                imCoronalF  = imCoronalFPtr ('get', [], rr);
                imSagittalF = imSagittalFPtr('get', [], rr);
                imAxialF    = imAxialFPtr   ('get', [], rr);

                if ~isempty(imCoronalF) && ...
                   ~isempty(imSagittalF) && ...
                   ~isempty(imAxialF)
                    dNbFusedSeries = dNbFusedSeries+1;  % Multiple fusion
                end
            end
        end             
        
        if isFusion('get')== true
                                
            if keyPressFusionStatus('get') ~= 0 && ...
               keyPressFusionStatus('get') ~= 1     

                pdColorOffset       = colorMapOffset('get');
                pdFusionColorOffset = fusionColorMapOffset('get');

                pdInvertColor     = invertColor    ('get');
                pdBackgroundColor = backgroundColor('get');
                pdOverlayColor    = overlayColor   ('get');

                pdAlphaSlider = sliderAlphaValue('get');   
                
                keyPressFusionStatus('set', 1);

%                set(uiAlphaSliderPtr('get') , 'Value', 1);
%                sliderAlphaValue('set', 1);   

                if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 3) == 1

                    alpha( imAxePtr('get', [], get(uiSeriesPtr('get'), 'Value')), 0 );
                    if dNbFusedSeries == 1
                        alpha( imAxeFPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 1 );
                    end                    
                else
                    alpha( imCoronalPtr('get', [], get(uiSeriesPtr('get'), 'Value')), 0 );
                    alpha( imSagittalPtr('get', [], get(uiSeriesPtr('get'), 'Value')), 0 );
                    alpha( imAxialPtr('get', [], get(uiSeriesPtr('get'), 'Value')), 0 );

                    if link2DMip('get') == true  && isVsplash('get') == false                                        
                        set( imMipPtr ('get', [], get(uiSeriesPtr('get'), 'Value')), 'Visible', 'on' );
                        alpha( imMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), 0 );
                    end  
                    
                    if dNbFusedSeries == 1

                        alpha( imCoronalFPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 1 );
                        alpha( imSagittalFPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 1 );
                        alpha( imAxialFPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 1 );

                        if link2DMip('get') == true  && isVsplash('get') == false                                        
                           set( imMipFPtr ('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'Visible', 'on' );
                           alpha( imMipFPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 1 );
                        end                        
                    end
                end

                iFuseOffset = get(uiFusedSeriesPtr('get'), 'Value');

                tFuseInput  = inputTemplate('get');
                atFuseMetaData = tFuseInput(iFuseOffset).atDicomInfo;

                % Deactivate colobar

                setColorbarVisible('off');

                ptrFusionColorbar = uiFusionColorbarPtr('get');
                if ~isempty(ptrFusionColorbar) 
        
                    setFusionColorbarPosition(ptrFusionColorbar);
                end


                asSeriesString = seriesDescription('get');

                if ~isempty(asSeriesString) && dNbFusedSeries == 1

                    if numel(asSeriesString) >= get(uiFusedSeriesPtr('get'), 'Value')
                        
                        ptrFusionColorbar = uiFusionColorbarPtr('get');
                        
                        ptrFusionColorbar.Label.String = asSeriesString{get(uiFusedSeriesPtr('get'), 'Value')};         
                        uiFusionColorbarPtr('set', ptrFusionColorbar);
                    end
                end

                setFusionColorbarVisible('on');

                set(uiAlphaSliderPtr('get'), 'Enable', 'off');

                setViewerDefaultColor(true, dicomMetaData('get'), atFuseMetaData);                        

            else
                if keyPressFusionStatus('get') == 1

                    keyPressFusionStatus('set', 0);
                
%                    set(uiAlphaSliderPtr('get') , 'Value', 0);
%                    sliderAlphaValue('set', 0);   

                    if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 3) == 1

                        alpha( imAxePtr('get', [], get(uiSeriesPtr('get'), 'Value')), 1 );
                    else
                        alpha( imCoronalPtr('get', [], get(uiSeriesPtr('get'), 'Value')), 1 );
                        alpha( imSagittalPtr('get', [], get(uiSeriesPtr('get'), 'Value')), 1 );
                        alpha( imAxialPtr('get', [], get(uiSeriesPtr('get'), 'Value')), 1 );

                        if link2DMip('get') == true  && isVsplash('get') == false                                        
                            set( imMipPtr ('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'Visible', 'on' );
                            alpha( imMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), 1 );
                        end 
                                                
                    end

                    % Deactivate fusion colobar

                    asSeriesString = seriesDescription('get');

                    if ~isempty(asSeriesString) && dNbFusedSeries == 1

                        if numel(asSeriesString) >= get(uiSeriesPtr('get'), 'Value')
        
                            ptrColorbar = uiColorbarPtr('get');
        
                            ptrColorbar.Label.String = asSeriesString{get(uiSeriesPtr('get'), 'Value')};         
                            uiColorbarPtr('set', ptrColorbar);
                        end
                    end

                    setColorbarVisible('on');

                    setFusionColorbarVisible('off');
               
                    ptrColorbar = uiColorbarPtr('get');
                    if ~isempty(ptrColorbar) 
            
                        setColorbarPosition(ptrColorbar);
                    end

                    set(uiAlphaSliderPtr('get'), 'Enable', 'off');

                    setViewerDefaultColor(true, dicomMetaData('get', [], get(uiSeriesPtr('get'), 'Value')));                           
                else
                    keyPressFusionStatus('set', 2);

%                    set(uiAlphaSliderPtr('get') , 'Value', pdAlphaSlider);     
%                    sliderAlphaValue('set', pdAlphaSlider);

                    if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 3) == 1
                        alpha( imAxePtr('get', [], get(uiSeriesPtr('get'), 'Value')), 1-pdAlphaSlider );
                    else
                        alpha( imCoronalPtr('get', [], get(uiSeriesPtr('get'), 'Value')), 1-pdAlphaSlider );
                        alpha( imSagittalPtr('get', [], get(uiSeriesPtr('get'), 'Value')), 1-pdAlphaSlider );
                        alpha( imAxialPtr('get', [], get(uiSeriesPtr('get'), 'Value')), 1-pdAlphaSlider );

                        if link2DMip('get') == true && isVsplash('get') == false                       
                            alpha( imMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), 1-pdAlphaSlider );
                        end
                        
                        if dNbFusedSeries == 1

                            alpha( imCoronalFPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), pdAlphaSlider );
                            alpha( imSagittalFPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), pdAlphaSlider );
                            alpha( imAxialFPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), pdAlphaSlider );

                            if link2DMip('get') == true  && isVsplash('get') == false                                        
                                set( imMipFPtr ('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'Visible', 'on' );
                                alpha( imMipFPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), pdAlphaSlider );
                            end                        
                        end                        
                   end   

                    colorMapOffset('set', pdColorOffset);
                    fusionColorMapOffset('set', pdFusionColorOffset);

                    invertColor('set', pdInvertColor);

                    backgroundColor ('set', pdBackgroundColor);
                    overlayColor    ('set', pdOverlayColor);

                    % Reactivate all colobars

                    ptrColorbar = uiColorbarPtr('get');
                    if ~isempty(ptrColorbar) 
            
                        setColorbarPosition(ptrColorbar);
                    end

                    ptrFusionColorbar = uiFusionColorbarPtr('get');
                    if ~isempty(ptrFusionColorbar) 
            
                        setFusionColorbarPosition(ptrFusionColorbar);
                    end

                    setColorbarLabel();                  

                    setColorbarVisible('on');

                    setFusionColorbarLabel();

                    setFusionColorbarVisible('on');

                    set(uiAlphaSliderPtr('get'), 'Enable', 'on');

                    setViewerDefaultColor(false, dicomMetaData('get', [], get(uiSeriesPtr('get'), 'Value')));
                 
                end
            end
            
%            sliderAlphaCallback();

%             setFusionColorbarLabel();

        end
       
        refreshImages();   
  
    end

    if strcmpi(evnt.Key,'i')
        
        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true
            return;
        end

        uiLogo = logoObject('get');

        if(invertColor('get'))               
            
            invertColor('set', false);

            if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 3) == 1
                
                set(uiOneWindowPtr('get'), 'BackgroundColor', 'black');
                
               cmap = flipud(colormap(axePtr('get', [], get(uiSeriesPtr('get'), 'Value'))));
               colormap(axePtr('get', [], get(uiSeriesPtr('get'), 'Value')), cmap);
                
                if isFusion('get') == true 
                
                    dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
                    for rr=1:dNbFusedSeries   
                        axef = axefPtr('get', [], rr);
                        if ~isempty(axef)     
                           cmapf = flipud(colormap(axef));
                           colormap(axef, cmapf);                        
                        end
                    end
                end
                
                if isPlotContours('get') == true 
                   cmapfc = flipud(colormap(axefcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))));
                   colormap(axefcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), cmapfc);
                end
                
            else
                if switchTo3DMode('get')     == true || ...
                   switchToIsoSurface('get') == true || ...
                   switchToMIPMode('get')    == true

                else
                    set(uiCorWindowPtr('get'), 'BackgroundColor', 'black');
                    set(uiSagWindowPtr('get'), 'BackgroundColor', 'black');
                    set(uiTraWindowPtr('get'), 'BackgroundColor', 'black');
                    
                    if link2DMip('get') == true && isVsplash('get') == false
                        set(uiMipWindowPtr('get'), 'BackgroundColor', 'black');
                    end
                    
                    cmap1 = flipud(colormap(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))));
                    cmap2 = flipud(colormap(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))));
                    cmap3 = flipud(colormap(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))));
                
                    colormap(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), cmap1);
                    colormap(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), cmap2);
                    colormap(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), cmap3); 
                
                    if link2DMip('get') == true && isVsplash('get') == false
                        cmapMip = flipud(colormap(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value'))));
                        colormap(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), cmapMip); 
                    end

                    if isFusion('get') == true 
                        
                        dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
                        for rr=1:dNbFusedSeries
                            
                            axes1f = axes1fPtr('get', [], rr);
                            axes2f = axes2fPtr('get', [], rr);
                            axes3f = axes3fPtr('get', [], rr);
                            
                            if ~isempty(axes1f) && ...
                               ~isempty(axes2f) && ...
                               ~isempty(axes3f) 
                       
                                cmap1f = flipud(colormap(axes1f));
                                cmap2f = flipud(colormap(axes2f));
                                cmap3f = flipud(colormap(axes3f));
                                
                                colormap(axes1f, cmap1f);
                                colormap(axes2f, cmap2f);
                                colormap(axes3f, cmap3f);  
                            end
                            
                            if link2DMip('get') == true && isVsplash('get') == false
                                
                                axesMipf = axesMipfPtr('get', [], rr);                                
                                if ~isempty(axesMipf)
                                    cmapMipf = flipud(colormap(axesMipf));
                                    colormap(axesMipf, cmapMipf);  
                                end
                            end
                        end
                    end
                    
                    if isPlotContours('get') == true && isVsplash('get') == false
                        
                        cmap1fc = flipud(colormap(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))));
                        cmap2fc = flipud(colormap(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))));
                        cmap3fc = flipud(colormap(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))));
                    
                        colormap(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), cmap1fc);
                        colormap(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), cmap2fc);
                        colormap(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), cmap3fc);   
                        
                        if link2DMip('get') == true && isVsplash('get') == false
                            cmapMipfc = flipud(colormap(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))));
                            colormap(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), cmapMipfc);                                                       
                        end
                    end
                end
            end
            
            set(uiLogo.Children, 'Color', [0.8500 0.8500 0.8500]); 

            set(fiMainWindowPtr('get'), 'Color', 'black');
       
%             set(uiSliderLevelPtr('get') , 'BackgroundColor',  'black');
%             set(uiSliderWindowPtr('get'), 'BackgroundColor',  'black');

%             set(uiFusionSliderLevelPtr('get') , 'BackgroundColor',  'black');
%             set(uiFusionSliderWindowPtr('get'), 'BackgroundColor',  'black');     

            set(uiAlphaSliderPtr('get')   , 'BackgroundColor',  'black');                   
            set(uiColorbarPtr('get')      , 'Color',  'white');                   
            set(uiFusionColorbarPtr('get'), 'Color',  'white');                   

            backgroundColor('set', 'black');
            if strcmp(getColorMap('one', colorMapOffset('get')), 'white')
                overlayColor ('set', 'black' );
            else    
                overlayColor ('set', 'white' );
            end    
        else   
             
            invertColor('set', true);

            if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 3) == 1 
                
                set(uiOneWindowPtr('get'), 'BackgroundColor', 'white');
                
                cmap = flipud(colormap(axePtr('get', [], get(uiSeriesPtr('get'), 'Value'))));
                colormap(axePtr('get' , [], get(uiSeriesPtr('get'), 'Value')), cmap);
                
                if isFusion('get') == true 
                
                    dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
                    for rr=1:dNbFusedSeries    
                        axef = axefPtr('get', [], rr);
                        if ~isempty(axef)
                            cmapf = flipud(colormap(axef));
                            colormap(axef, cmapf);                                                
                        end
                    end
                end
                
                if isPlotContours('get') == true 
                    cmapfc = flipud(colormap(axefcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))));
                    colormap(axefcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), cmapfc);
                end
                
            else

                set(uiCorWindowPtr('get'), 'BackgroundColor', 'white');
                set(uiSagWindowPtr('get'), 'BackgroundColor', 'white');
                set(uiTraWindowPtr('get'), 'BackgroundColor', 'white');
                
                if link2DMip('get') == true && isVsplash('get') == false
                    set(uiMipWindowPtr('get'), 'BackgroundColor', 'white');
                end         
                
                cmap1 = flipud(colormap(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))));
                cmap2 = flipud(colormap(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))));
                cmap3 = flipud(colormap(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))));
                            
                colormap(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), cmap1);
                colormap(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), cmap2);
                colormap(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), cmap3);        
                
                if link2DMip('get') == true && isVsplash('get') == false             
                   cmapMip = flipud(colormap(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value'))));
                   colormap(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')),cmapMip);        
                end
                
                if isFusion('get') == true 
                    
                    dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
                    for rr=1:dNbFusedSeries

                        axes1f = axes1fPtr('get', [], rr);
                        axes2f = axes2fPtr('get', [], rr);
                        axes3f = axes3fPtr('get', [], rr);

                        if ~isempty(axes1f) && ...
                           ~isempty(axes2f) && ...
                           ~isempty(axes3f) 
                       
                            cmap1f = flipud(colormap(axes1f));
                            cmap2f = flipud(colormap(axes2f));
                            cmap3f = flipud(colormap(axes3f));
                                
                            colormap(axes1f, cmap1f);
                            colormap(axes2f, cmap2f);
                            colormap(axes3f, cmap3f);                               
                        end
                        
                        if link2DMip('get') == true && isVsplash('get') == false
                            
                            axesMipf = axesMipfPtr('get', [], rr);
                            if ~isempty(axesMipf)
                                cmapMipf = flipud(colormap(axesMipf));
                                colormap(axesMipf, cmapMipf);                               
                            end
                        end
                    end
                end
                
                if isPlotContours('get') == true && isVsplash('get') == false
                    
                    cmap1fc = flipud(colormap(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))));
                    cmap2fc = flipud(colormap(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))));
                    cmap3fc = flipud(colormap(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))));
                        
                    colormap(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), cmap1fc);
                    colormap(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), cmap2fc);
                    colormap(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), cmap3fc);    
                    
                    if link2DMip('get') == true && isVsplash('get') == false
                        cmapMipfc = flipud(colormap(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))));
                        colormap(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), cmapMipfc);                               
                    end                    
                end

            end
            
            set(uiLogo.Children, 'Color', [0.1500 0.1500 0.1500]); 

            set(fiMainWindowPtr('get'), 'Color', 'white');
% 
%             set(uiSliderLevelPtr('get') , 'BackgroundColor',  'white');
%             set(uiSliderWindowPtr('get'), 'BackgroundColor',  'white');  
% 
%             set(uiFusionSliderLevelPtr('get') , 'BackgroundColor',  'white');
%             set(uiFusionSliderWindowPtr('get'), 'BackgroundColor',  'white');

            set(uiAlphaSliderPtr('get')   , 'BackgroundColor',  'white'); 
            set(uiColorbarPtr('get')      , 'Color',  'black');                   
            set(uiFusionColorbarPtr('get'), 'Color',  'black');  

            backgroundColor('set', 'white');
            if strcmpi(getColorMap('one', colorMapOffset('get')), 'black')
                overlayColor ('set', 'white' );
            else
                overlayColor ('set', 'black' ); 
            end
        end

        if size(dicomBuffer('get', [],  get(uiSeriesPtr('get'), 'Value')), 3) ~= 1 && ...
           switchTo3DMode('get')     == false && ...
           switchToIsoSurface('get') == false && ...
           switchToMIPMode('get')    == false && ...
           isVsplash('get')          == false

            btnUiTraWindowFullScreen = btnUiTraWindowFullScreenPtr('get');
            btnUiCorWindowFullScreen = btnUiCorWindowFullScreenPtr('get');
            btnUiSagWindowFullScreen = btnUiSagWindowFullScreenPtr('get');
            btnUiMipWindowFullScreen = btnUiMipWindowFullScreenPtr('get');

            if ~isempty(btnUiTraWindowFullScreen)&& ...
               ~isempty(btnUiCorWindowFullScreen)&& ...
               ~isempty(btnUiSagWindowFullScreen)&& ...
               ~isempty(btnUiMipWindowFullScreen)

                bIsTraFullScreen = isPanelFullScreen(btnUiTraWindowFullScreen);
                bIsCorFullScreen = isPanelFullScreen(btnUiCorWindowFullScreen);
                bIsSagFullScreen = isPanelFullScreen(btnUiSagWindowFullScreen);
                bIsMipFullScreen = isPanelFullScreen(btnUiMipWindowFullScreen);

                set(btnUiTraWindowFullScreen, 'CData', getFullScreenIconImage(uiTraWindowPtr('get'), ~bIsTraFullScreen));
                set(btnUiCorWindowFullScreen, 'CData', getFullScreenIconImage(uiCorWindowPtr('get'), ~bIsCorFullScreen));
                set(btnUiSagWindowFullScreen, 'CData', getFullScreenIconImage(uiSagWindowPtr('get'), ~bIsSagFullScreen));
                set(btnUiMipWindowFullScreen, 'CData', getFullScreenIconImage(uiMipWindowPtr('get'), ~bIsMipFullScreen));

                set(btnUiTraWindowFullScreen, 'BackgroundColor', get(uiTraWindowPtr('get'), 'BackgroundColor'));
                set(btnUiCorWindowFullScreen, 'BackgroundColor', get(uiCorWindowPtr('get'), 'BackgroundColor'));
                set(btnUiSagWindowFullScreen, 'BackgroundColor', get(uiSagWindowPtr('get'), 'BackgroundColor'));
                set(btnUiMipWindowFullScreen, 'BackgroundColor', get(uiMipWindowPtr('get'), 'BackgroundColor'));
            end
        end

%                bInitSegPanel = false;                
%                if  viewSegPanel('get')
%                    bInitSegPanel = true;
%                    viewSegPanel('set', false);
%                    objSegPanel = viewSegPanelMenuObject('get');
%                    if ~isempty(objSegPanel)
%                       objSegPanel.Checked = 'off';
%                    end
%                end

%                bInitKernelPanel = false;                
%                if  viewKernelPanel('get')
%                    bInitKernelPanel = true;
%                    viewKernelPanel('set', false);
%                    objKernelPanel = viewKernelPanelMenuObject('get');
%                    if ~isempty(objKernelPanel)
%                       objKernelPanel.Checked = 'off';
%                    end
%                end

%         triangulateCallback();

%         clearDisplay();                        
%         initDisplay(3);     

%         dicomViewerCore();
%          if isVsplash('get') == false        
            refreshImages();   
%          else
%             tAxes1Text = axesText('get', 'axes1');
%             tAxes1Text.Color  = overlayColor('get');  

%             tAxes2Text = axesText('get', 'axes2');
%             tAxes2Text.Color  = overlayColor('get'); 

%             tAxes3Text = axesText('get', 'axes3');
%             tAxes3Text.Color  = overlayColor('get');                     
%          end

%                 if bInitSegPanel == true
%                    setViewSegPanel();
%                 end

%                 if bInitKernelPanel == true
%                    setViewKernelPanel();
%                 end                 
    end

    if strcmpi(evnt.Key,'o')

        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true
            return;
        end

        if overlayActivate('get')
            overlayActivate('set', false);

            if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 3) == 1
                pAxeText = axesText('get', 'axe');
                pAxeText.Visible = 'off';
                
                if isFusion('get') == true
                    pAxefText = axesText('get', 'axef');
                    pAxefText.Visible = 'off';                    
                end
            else
                pAxes1Text   = axesText('get', 'axes1'  );
                pAxes2Text   = axesText('get', 'axes2'  );
                pAxes3Text   = axesText('get', 'axes3'  );
                pAxesMipText = axesText('get', 'axesMip');

                pAxes1Text.Visible   = 'off';
                pAxes2Text.Visible   = 'off';
                pAxes3Text.Visible   = 'off';
                pAxesMipText.Visible = 'off';
               
                if isVsplash('get') == false

                    pAxes1ViewText   = axesText('get', 'axes1View'  );
                    pAxes2ViewText   = axesText('get', 'axes2View'  );
                    pAxes3ViewText   = axesText('get', 'axes3View'  );
                    pAxesMipViewText = axesText('get', 'axesMipView');

                    pAxes1ViewText.Visible   = 'off';
                    pAxes2ViewText.Visible   = 'off';
                    for tt=1:numel(pAxes3ViewText)
                        pAxes3ViewText{tt}.Visible   = 'off';
                    end
                    pAxesMipViewText.Visible = 'off';                    
                end
                
                if isFusion('get') == true
                    pAxes3fText = axesText('get', 'axes3f');
                    pAxes3fText.Visible = 'off';                    
                end
                
            end

            if isVsplash('get') == true

                ptMontageAxes1 = montageText('get', 'axes1');                 
                for aa=1:numel(ptMontageAxes1)
                    ptMontageAxes1{aa}.Visible = 'off';
                end                           

                ptMontageAxes2 = montageText('get', 'axes2');                 
                for aa=1:numel(ptMontageAxes2)
                    ptMontageAxes2{aa}.Visible = 'off';
                end 

                ptMontageAxes3 = montageText('get', 'axes3');                 
                for aa=1:numel(ptMontageAxes3)
                    ptMontageAxes3{aa}.Visible = 'off';
                end                          
            end                    
        else
            overlayActivate('set', true);  

            if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 3) == 1

                pAxeText = axesText('get', 'axe');
                pAxeText.Visible = 'on';
                
                if isFusion('get') == true
                    pAxefText = axesText('get', 'axef');
                    pAxefText.Visible = 'on';                    
                end                                
            else
                pAxes1Text   = axesText('get', 'axes1'  );
                pAxes2Text   = axesText('get', 'axes2'  );
                pAxes3Text   = axesText('get', 'axes3'  );
                pAxesMipText = axesText('get', 'axesMip');

                pAxes1Text.Visible   = 'on';
                pAxes2Text.Visible   = 'on';
                pAxes3Text.Visible   = 'on';
                pAxesMipText.Visible = 'on';
                
                if isVsplash('get') == false
                    pAxes1ViewText   = axesText('get', 'axes1View'  );
                    pAxes2ViewText   = axesText('get', 'axes2View'  );
                    pAxes3ViewText   = axesText('get', 'axes3View'  );
                    pAxesMipViewText = axesText('get', 'axesMipView');

                    pAxes1ViewText.Visible   = 'on';
                    pAxes2ViewText.Visible   = 'on';
                    for tt=1:numel(pAxes3ViewText)
                        pAxes3ViewText{tt}.Visible   = 'on';
                    end
                    pAxesMipViewText.Visible = 'on';                    
                end 
                
                if isFusion('get') == true
                    pAxes3fText = axesText('get', 'axes3f');
                    pAxes3fText.Visible = 'on';                    
                end                
            end

            if isVsplash('get') == true

                ptMontageAxes1 = montageText('get', 'axes1');                 
                for aa=1:numel(ptMontageAxes1)
                    ptMontageAxes1{aa}.Visible = 'on';
                end                           

                ptMontageAxes2 = montageText('get', 'axes2');                 
                for aa=1:numel(ptMontageAxes2)
                    ptMontageAxes2{aa}.Visible = 'on';
                end 

                ptMontageAxes3 = montageText('get', 'axes3');                 
                for aa=1:numel(ptMontageAxes3)
                    ptMontageAxes3{aa}.Visible = 'on';
                end                          
            end

            refreshImages();

        end

    end

    if strcmpi(evnt.Key,'r')   

        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true 
           return;
        end
                
        tInput = inputTemplate('get');
        
        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');
        if dSeriesOffset > numel(tInput)
            return;
        end                      

        if size(dicomBuffer('get', [], dSeriesOffset), 3) == 1            
            return;
        end  

        if tInput(dSeriesOffset).bFlipHeadFeet == true
            tInput(dSeriesOffset).bFlipHeadFeet = false;
        else
            tInput(dSeriesOffset).bFlipHeadFeet = true;
        end

        inputTemplate('set', tInput);  
                
        im = dicomBuffer('get', [], dSeriesOffset);   
        im=im(:,:,end:-1:1);
        dicomBuffer('set', im, dSeriesOffset);     
        
        if isFusion('get')
                             
            dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
            for rr=1:dNbFusedSeries
                                              
                imf = fusionBuffer('get', [], rr);   
                if ~isempty(imf)

                    axes1f = axes1fPtr('get', [], rr);
                    axes2f = axes2fPtr('get', [], rr);
                    axes3f = axes3fPtr('get', [], rr);

                    if ~isempty(axes1f) && ...
                       ~isempty(axes2f) && ...
                       ~isempty(axes3f)                       
                        imf=imf(:,:,end:-1:1);
                    end
                    
                    fusionBuffer('set', imf, rr);  
                end
            end
        end 
        
        refreshImages();
    end

    if strcmpi(evnt.Key,'l') 

        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true 

            return;
        end
        
        tInput = inputTemplate('get');
        
        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');
        if dSeriesOffset > numel(tInput)

            return;
        end                      
        
        if tInput(dSeriesOffset).bFlipLeftRight == true
            tInput(dSeriesOffset).bFlipLeftRight = false;
        else
            tInput(dSeriesOffset).bFlipLeftRight = true;
        end     
        
        inputTemplate('set', tInput);        
        
        im = dicomBuffer('get', [], dSeriesOffset);                   

        if size(dicomBuffer('get', [], dSeriesOffset), 3) == 1     
            if size(dicomBuffer('get', [], dSeriesOffset), 4) ~= 1     
                im=im(:,end:-1:1,:,:);     
            else               
                im=im(:,end:-1:1);     
            end
        else
            im=im(:,end:-1:1,:);     
            if isVsplash('get') == false           
                tAxes1ViewText = axesText('get', 'axes1View'); 
                if strcmpi(tAxes1ViewText.String, 'Right')
                    tAxes1ViewText.String  = 'Left';  
                else
                    tAxes1ViewText.String  = 'Right';  
                end
                
                tAxes3ViewText = axesText('get', 'axes3View'); 
                if strcmpi(tAxes3ViewText{2}.String, 'Right')
                    tAxes3ViewText{2}.String  = 'Left';  
                else
                    tAxes3ViewText{2}.String  = 'Right';  
                end                
            end            
        end
        
        dicomBuffer('set', im, dSeriesOffset);

        if isFusion('get')
                             
            dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
            for rr=1:dNbFusedSeries
                                              
                imf = fusionBuffer('get', [], rr);   
                if ~isempty(imf)
                    if size(imf, 3) == 1    
                        axef = axefPtr('get', [], rr);
                        if ~isempty(axef)
                            imf=imf(:,end:-1:1);
                        end
                    else
                        axes1f = axes1fPtr('get', [], rr);
                        axes2f = axes2fPtr('get', [], rr);
                        axes3f = axes3fPtr('get', [], rr);

                        if ~isempty(axes1f) && ...
                           ~isempty(axes2f) && ...
                           ~isempty(axes3f)                       
                            imf=imf(:,end:-1:1,:);
                        end
                    end
                    
                    fusionBuffer('set', imf, rr);  
                end
            end
        end        

        refreshImages();
    end   

    if strcmpi(evnt.Key,'a')   

        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true 
            return;
        end
        
        tInput = inputTemplate('get');
        
        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');
        if dSeriesOffset > numel(tInput)
            return;
        end                      
        
        if tInput(dSeriesOffset).bFlipAntPost == true
            tInput(dSeriesOffset).bFlipAntPost = false;
        else
            tInput(dSeriesOffset).bFlipAntPost = true;
        end      
        
        inputTemplate('set', tInput);
        
        im = dicomBuffer('get', [], dSeriesOffset);  

        if size(dicomBuffer('get', [], dSeriesOffset), 3) == 1  
            if size(dicomBuffer('get', [], dSeriesOffset), 4) ~= 1     
                im=im(end:-1:1,:,:,:);
            else
                im=im(end:-1:1,:);
            end
        else
            im=im(end:-1:1,:,:);
            if isVsplash('get') == false           
                tAxes2ViewText = axesText('get', 'axes2View'); 
                if strcmpi(tAxes2ViewText.String, 'Anterior')
                    tAxes2ViewText.String  = 'Posterior';  
                else
                    tAxes2ViewText.String  = 'Anterior';  
                end
                
                tAxes3ViewText = axesText('get', 'axes3View'); 
                if strcmpi(tAxes3ViewText{1}.String, 'Anterior')
                    tAxes3ViewText{1}.String  = 'Posterior';  
                else
                    tAxes3ViewText{1}.String  = 'Anterior';  
                end                
            end             
        end
        
        dicomBuffer('set', im, dSeriesOffset);
  
        if isFusion('get')
                             
            dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
            for rr=1:dNbFusedSeries
                                              
                imf = fusionBuffer('get', [], rr);   
                if ~isempty(imf)
                    if size(imf, 3) == 1    
                        axef = axefPtr('get', [], rr);
                        if ~isempty(axef)
                            imf=imf(end:-1:1,:);
                        end
                    else
                        axes1f = axes1fPtr('get', [], rr);
                        axes2f = axes2fPtr('get', [], rr);
                        axes3f = axes3fPtr('get', [], rr);

                        if ~isempty(axes1f) && ...
                           ~isempty(axes2f) && ...
                           ~isempty(axes3f)                       
                            imf=imf(end:-1:1,:,:);
                        end
                    end
                    
                    fusionBuffer('set', imf, rr);  
                end
            end
        end 
        
        refreshImages();
    end  

    if strcmpi(evnt.Key,'z')

        setZoomCallback();
    end

    if strcmpi(evnt.Key,'n')

        setPanCallback();
    end                

    if strcmpi(evnt.Key,'f1')
        [dMax, dMin] = computeWindowLevel(1200, -500);
        setFkeyWindowMinMax(dMax, dMin);
    end

    if strcmpi(evnt.Key,'f2')
        [dMax, dMin] = computeWindowLevel(500, 50);
        setFkeyWindowMinMax(dMax, dMin);
    end

    if strcmpi(evnt.Key,'f3')
        [dMax, dMin] = computeWindowLevel(500, 200);
        setFkeyWindowMinMax(dMax, dMin);
    end

    if strcmpi(evnt.Key,'f4')
        [dMax, dMin] = computeWindowLevel(240, 40);
        setFkeyWindowMinMax(dMax, dMin);
    end

    if strcmpi(evnt.Key,'f5')
        [dMax, dMin] = computeWindowLevel(80, 40);
        setFkeyWindowMinMax(dMax, dMin);
    end

    if strcmpi(evnt.Key,'f6')
        [dMax, dMin] = computeWindowLevel(350, 90);
        setFkeyWindowMinMax(dMax, dMin);
    end

    if strcmpi(evnt.Key,'f7')
        [dMax, dMin] = computeWindowLevel(2000, -600);
        setFkeyWindowMinMax(dMax, dMin);
    end

    if strcmpi(evnt.Key,'f8')
        [dMax, dMin] = computeWindowLevel(350, 50);
        setFkeyWindowMinMax(dMax, dMin);
    end

    if strcmpi(evnt.Key,'f9')

         if  pdToggle == 0

            [dMax, dMin] = computeWindowLevel(2000, 0);
            setFkeyWindowMinMax(dMax, dMin);  
            pdToggle =1;
        elseif pdToggle == 1

            [dMax, dMin] = computeWindowLevel(2500, 415);
            setFkeyWindowMinMax(dMax, dMin);
            pdToggle =2;

        else
            [dMax, dMin] = computeWindowLevel(1000, 350);
            setFkeyWindowMinMax(dMax, dMin);
            pdToggle =0;
        end               
    end                             

end
