function setVsplashCallback(~, ~)
%function setVsplashCallback(~, ~)
%Set 2D vSplash.
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
    
%    try
        
    releaseRoiWait();

    set(btnTriangulatePtr('get'), 'BackgroundColor', viewerButtonPushedBackgroundColor('get'));
    set(btnTriangulatePtr('get'), 'ForegroundColor', viewerButtonPushedForegroundColor('get'));
    set(btnTriangulatePtr('get'), 'FontWeight', 'bold');

    set(zoomMenu('get'), 'Checked', 'off');
    set(btnZoomPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
    set(btnZoomPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
    set(btnZoomPtr('get'), 'FontWeight', 'normal');
    zoomTool('set', false);
    zoom(fiMainWindowPtr('get'), 'off');           

    set(panMenu('get'), 'Checked', 'off');
    set(btnPanPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
    set(btnPanPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));          
    set(btnPanPtr('get'), 'FontWeight', 'normal');
    panTool('set', false);
    pan(fiMainWindowPtr('get'), 'off');     

    set(rotate3DMenu('get'), 'Checked', 'off');         
    rotate3DTool('set', false);
    rotate3d(fiMainWindowPtr('get'), 'off');

    set(dataCursorMenu('get'), 'Checked', 'off');
    dataCursorTool('set', false);              
    datacursormode(fiMainWindowPtr('get'), 'off'); 
    
    iCoronalSize  = size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 1);
    iSagittalSize = size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 2);
    iAxialSize    = size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 3);

    iCoronal  = sliceNumber('get', 'coronal');
    iSagittal = sliceNumber('get', 'sagittal');
    iAxial    = sliceNumber('get', 'axial');

    multiFramePlayback('set', false);
    multiFrameRecord  ('set', false);

    mPlay = playIconMenuObject('get');
    if ~isempty(mPlay)
        mPlay.State = 'off';
%          playIconMenuObject('set', '');
    end

    mRecord = recordIconMenuObject('get');
    if ~isempty(mRecord)
        mRecord.State = 'off';
%          recordIconMenuObject('set', '');
    end

    if isVsplash('get') == false

        releaseRoiWait();

        isVsplash('set', true);

        set(btnVsplashPtr('get'), 'BackgroundColor', viewerButtonPushedBackgroundColor('get'));
        set(btnVsplashPtr('get'), 'ForegroundColor', viewerButtonPushedForegroundColor('get'));
        set(btnVsplashPtr('get'), 'FontWeight', 'bold');
        
        if isPlotContours('get') == true % Deactivate plot contour
            setPlotContoursCallback();            
        end

        clearDisplay();
        initDisplay(3);

        dicomViewerCore();

%        if isFusion('get') == false
%            set(btnFusionPtr ('get')   , 'Enable', 'off');
%            set(btnLinkMipPtr('get')   , 'Enable', 'off');
%            set(uiFusedSeriesPtr('get'), 'Enable', 'off');
%        end


    else
        isVsplash('set', false);

        link2DMip('set', true);

        set(btnLinkMipPtr('get'), 'BackgroundColor', viewerButtonPushedBackgroundColor('get'));
        set(btnLinkMipPtr('get'), 'ForegroundColor', viewerButtonPushedForegroundColor('get')); 
        set(btnLinkMipPtr('get'), 'FontWeight', 'bold');

        set(btnVsplashPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
        set(btnVsplashPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
        set(btnVsplashPtr('get'), 'FontWeight', 'normal');
        
%        isPlotContours('set', false);

        clearDisplay();
        initDisplay(3);

%        link2DMip('set', true);

%        set(btnLinkMipPtr('get'), 'BackgroundColor', viewerButtonPushedBackgroundColor('get'));
%        set(btnLinkMipPtr('get'), 'ForegroundColor', viewerButtonPushedForegroundColor('get')); 
                
        dicomViewerCore();

%        set(btnFusionPtr('get')    , 'Enable', 'on');
%        set(btnLinkMipPtr('get')   , 'Enable', 'on');
%        set(uiFusedSeriesPtr('get'), 'Enable', 'on');
    end

    % Restore color

    set(uiCorWindowPtr('get'), 'BackgroundColor', dBackgroundColor);
    set(uiSagWindowPtr('get'), 'BackgroundColor', dBackgroundColor);
    set(uiTraWindowPtr('get'), 'BackgroundColor', dBackgroundColor);

    if link2DMip('get') == true && isVsplash('get') == false
        set(uiMipWindowPtr('get'), 'BackgroundColor', dBackgroundColor);
    end

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

    colormap(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), getColorMap('one', dColorMapOffset));
    colormap(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), getColorMap('one', dColorMapOffset));
    colormap(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), getColorMap('one', dColorMapOffset));

    if link2DMip('get') == true && isVsplash('get') == false
        colormap(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), getColorMap('one', dColorMapOffset));
    end

    if isFusion('get') == true

        colormap(axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')),  getColorMap('one', dFusionColorMapOffset));
        colormap(axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')),  getColorMap('one', dFusionColorMapOffset));
        colormap(axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')),  getColorMap('one', dFusionColorMapOffset));

        if link2DMip('get') == true && isVsplash('get') == false

            colormap(axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')),  getColorMap('one', dFusionColorMapOffset));
        end
    end

    overlayColor('set', dOverlayColor);

    backgroundColor('set', dBackgroundColor);

    colorMapOffset('set', dColorMapOffset);

    if isFusion('get')

        fusionColorMapOffset('set', dFusionColorMapOffset);
    end

    if isVsplash('get') == false

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

    if link2DMip('get') == true && isVsplash('get') == false

        set(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), 'CLim', [dWindowLevelMin dWindowLevelMax]);
    end  

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

        if link2DMip('get') == true && isVsplash('get') == false

            set(axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'CLim', [dFusionWindowLevelMin dFusionWindowLevelMax]);
        end           
    end

    % restore slider position

    set(uiSliderCorPtr('get'), 'Value', iCoronal / iCoronalSize);
    sliceNumber('set', 'coronal', iCoronal);

    set(uiSliderSagPtr('get'), 'Value', iSagittal / iSagittalSize);
    sliceNumber('set', 'sagittal', iSagittal);

    set(uiSliderTraPtr('get'), 'Value', 1 - (iAxial / iAxialSize));
    sliceNumber('set', 'axial', iAxial);

    refreshImages();
    
%    catch
%        progressBar(1, 'Error:setVsplashCallback()');                        
%    end
    
    % Reactivate main tool bar 
    set(uiSeriesPtr('get'), 'Enable', 'on');                        
    mainToolBarEnable('on');   
    
%    if isVsplash('get') == false
        
%        atMetaData = dicomMetaData('get');

%        if strcmpi(atMetaData{1}.Modality, 'ct')
%            link2DMip('set', false);

%            set(btnLinkMipPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
%            set(btnLinkMipPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));         
%        end         
%    end
    
end
