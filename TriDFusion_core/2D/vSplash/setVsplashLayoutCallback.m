function setVsplashLayoutCallback(hObject, ~)         
%function setVsplashCallback(~, ~)   
%Set 2D vSplash Layout.
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

    if isempty(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')))

        return;
    end

    if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 3) == 1

        return;
    end

    if switchTo3DMode('get')     == true || ...
       switchToIsoSurface('get') == true || ...
       switchToMIPMode('get')    == true

        return;
    end

    if hObject == uiEditVsplahXPtr('get')
        vSplashLayout('set', 'x', str2double(get(hObject, 'String')));
    else    
        vSplashLayout('set', 'y', str2double(get(hObject, 'String')));
    end

    if isVsplash('get') == true

        dWindowLevelMax = windowLevel('get', 'max');
        dWindowLevelMin = windowLevel('get', 'min');

        dOverlayColor = overlayColor('get');
    
        dBackgroundColor = backgroundColor('get');
    
        dColorMapOffset = colorMapOffset('get');
    
        if isFusion('get')

            dFusionWindowLevelMax = fusionWindowLevel('get', 'max');
            dFusionWindowLevelMin = fusionWindowLevel('get', 'min');

            dFusionColorMapOffset = fusionColorMapOffset('get');
        end

        % Deactivate main tool bar 
        set(uiSeriesPtr('get'), 'Enable', 'off');                        
        mainToolBarEnable('off');  
    
        multiFramePlayback('set', false);

        mPlay = playIconMenuObject('get');
        if ~isempty(mPlay)
            mPlay.State = 'off';
        end                                        

        clearDisplay();                    
        initDisplay(3);  

        dicomViewerCore(); 

        % restore color
    
        set(uiCorWindowPtr('get'), 'BackgroundColor', dBackgroundColor);
        set(uiSagWindowPtr('get'), 'BackgroundColor', dBackgroundColor);
        set(uiTraWindowPtr('get'), 'BackgroundColor', dBackgroundColor);
                
        ptrColorbar = uiColorbarPtr('get');
        if ~isempty(ptrColorbar)
            set(ptrColorbar, 'Color',  dOverlayColor);
        end
    
        if isFusion('get')
    
            uiAlphaSlider = uiAlphaSliderPtr('get');
            if ~isempty(uiAlphaSlider)
    
                set(uiAlphaSlider, 'BackgroundColor',  dBackgroundColor);
            end
    
            ptrFusionColorbar = uiFusionColorbarPtr('get');
            if ~isempty(ptrFusionColorbar)
    
                set(ptrFusionColorbar   , 'Color', dOverlayColor);
            end        
        end
    
        set(fiMainWindowPtr('get'), 'Color', dBackgroundColor);

        ptrColorbar = uiColorbarPtr('get');
        colormap(ptrColorbar, getColorMap('one', colorMapOffset('get')));

        colormap(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), getColorMap('one', dColorMapOffset));
        colormap(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), getColorMap('one', dColorMapOffset));
        colormap(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), getColorMap('one', dColorMapOffset));          
    
        if isFusion('get') == true

            ptrFusionColorbar = uiFusionColorbarPtr('get');
            colormap(ptrFusionColorbar, getColorMap('one', fusionColorMapOffset('get')));

            colormap(axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')),  getColorMap('one', dFusionColorMapOffset));
            colormap(axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')),  getColorMap('one', dFusionColorMapOffset));
            colormap(axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')),  getColorMap('one', dFusionColorMapOffset));
        end

        overlayColor('set', dOverlayColor);
    
        backgroundColor('set', dBackgroundColor);
    
        colorMapOffset('set', dColorMapOffset);
    
        if isFusion('get')
            fusionColorMapOffset('set', dFusionColorMapOffset);
        end

        % Restore intensity
    
        windowLevel('set', 'max', dWindowLevelMax);
        windowLevel('set', 'min', dWindowLevelMin);
    
        % Compute colorbar line y offset
    
        dYOffsetMax = computeLineColorbarIntensityMaxYOffset(get(uiSeriesPtr('get'), 'Value'));
        dYOffsetMin = computeLineColorbarIntensityMinYOffset(get(uiSeriesPtr('get'), 'Value'));
    
        % Ajust the intensity 
    
        setColorbarIntensityMaxScaleValue(dYOffsetMax, ...
                                          colorbarScale('get'), ...
                                          isColorbarDefaultUnit('get'), ...
                                          get(uiSeriesPtr('get'), 'Value')...
                                          );
    
        setColorbarIntensityMinScaleValue(dYOffsetMin, ...
                                          colorbarScale('get'), ...
                                          isColorbarDefaultUnit('get'), ...
                                          get(uiSeriesPtr('get'), 'Value')...
                                          );
    
        setAxesIntensity(get(uiSeriesPtr('get'), 'Value'));
                
        if isFusion('get')
    
            fusionWindowLevel('set', 'max', dFusionWindowLevelMax);
            fusionWindowLevel('set', 'min', dFusionWindowLevelMin);
        
            % Compute colorbar line y offset
        
            dFusionYOffsetMax = computeLineFusionColorbarIntensityMaxYOffset(get(uiFusedSeriesPtr('get'), 'Value'));
            dFusionYOffsetMin = computeLineFusionColorbarIntensityMinYOffset(get(uiFusedSeriesPtr('get'), 'Value'));
        
            % Ajust the intensity 
        
            setFusionColorbarIntensityMaxScaleValue(dFusionYOffsetMax, ...
                                                    fusionColorbarScale('get'), ...
                                                    isFusionColorbarDefaultUnit('get'),...
                                                    get(uiFusedSeriesPtr('get'), 'Value')...
                                                   );
                                                
            setFusionColorbarIntensityMinScaleValue(dFusionYOffsetMin, ...
                                                    fusionColorbarScale('get'), ...
                                                    isFusionColorbarDefaultUnit('get'),...
                                                    get(uiFusedSeriesPtr('get'), 'Value')...
                                                    );
        
            setFusionAxesIntensity(get(uiFusedSeriesPtr('get'), 'Value'));       
        end

        % Reactivate main tool bar 

        set(uiSeriesPtr('get'), 'Enable', 'on');                        
        
        mainToolBarEnable('on');          
    end

end