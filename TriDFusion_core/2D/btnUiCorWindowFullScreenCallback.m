function btnUiCorWindowFullScreenCallback(~, ~)
%function btnUiCorWindowFullScreenCallback(~, ~)
%Resize Coronal Window to Figure Full Screen.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2023, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    persistent ptLimitCor;
    persistent ptLimitSag;
    persistent ptLogoPosition;

    uiCorWindow = uiCorWindowPtr('get');
    uiSagWindow = uiSagWindowPtr('get');
    uiTraWindow = uiTraWindowPtr('get');
    uiMipWindow = uiMipWindowPtr('get');

    uiCorSlider = uiSliderCorPtr('get');
    uiSagSlider = uiSliderSagPtr('get');
    uiTraSlider = uiSliderTraPtr('get');
    uiMipSlider = uiSliderMipPtr('get');

    if ~isempty(uiCorWindow)

        uiLogo = logoObject('get');

        btnUiCorWindowFullScreen = btnUiCorWindowFullScreenPtr('get');

        if ~isempty(btnUiCorWindowFullScreen)

            bIsFullScreen = isPanelFullScreen(btnUiCorWindowFullScreen);

            btnUiCorWindowFullScreen.CData = getFullScreenIconImage(uiCorWindow,  bIsFullScreen);

            if bIsFullScreen == false

                ptLogoPosition = uiLogo.Position;

                ptLimitCor = axesLimitsFromTemplate(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')));
                ptLimitSag = axesLimitsFromTemplate(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')));

                adjAxeCameraViewAngle(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')));
                adjAxeCameraViewAngle(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')));
               
                if isFusion('get') == true

                    setAxesLimitsFromSource(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')));
                    setAxesLimitsFromSource(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')));
                  
                    uiLogo.Position(2) = uiLogo.Position(2)+15;
                end

                if isPlotContours('get') == true

                    setAxesLimitsFromSource(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')));                    
                    setAxesLimitsFromSource(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')));                    
               end

                % 
                % pdCameraViewAngle = get(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'CameraViewAngle');
                % 
                % set(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'CameraViewAngle', 1);

                set(btnUiCorWindowFullScreen, 'TooltipString'  , 'Exit Full Screen (Ctrl + F)');

                set(uiTraWindow, 'Visible', 'Off');
                set(uiSagWindow, 'Visible', 'Off');
                set(uiMipWindow, 'Visible', 'Off');

                set(uiTraSlider, 'Visible', 'Off');
                set(uiSagSlider, 'Visible', 'Off');
                set(uiMipSlider, 'Visible', 'Off');
            else
                uiLogo.Position = ptLogoPosition;

                axesLimitsFromTemplate(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), ptLimitCor);
                axesLimitsFromTemplate(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), ptLimitSag);

                if isFusion('get') == true

                    setAxesLimitsFromSource(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')));
                    setAxesLimitsFromSource(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')));
               end

                if isPlotContours('get') == true
                    
                    setAxesLimitsFromSource(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')));                    
                    setAxesLimitsFromSource(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')));                    
                end

                % set(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'CameraViewAngle', pdCameraViewAngle);

                set(btnUiCorWindowFullScreen, 'TooltipString'  , 'Full Screen (Ctrl + F)');

                set(uiTraWindow, 'Visible', 'On');
                set(uiSagWindow, 'Visible', 'On');
                set(uiMipWindow, 'Visible', 'On');

                set(uiTraSlider, 'Visible', 'On');
                set(uiSagSlider, 'Visible', 'On');
                set(uiMipSlider, 'Visible', 'On');
            end

            if ~isempty(uiCorWindow)
                setCorWindowPosition(uiCorWindow);
            end

            if ~isempty(uiCorSlider)
                setCorSliderPosition(uiCorSlider);
            end

            ptrColorbar = uiColorbarPtr('get');
            if ~isempty(ptrColorbar)
                setColorbarPosition(ptrColorbar);
            end

            if isFusion('get') == true

                uiAlphaSlider = uiAlphaSliderPtr('get');
                if ~isempty(uiAlphaSlider)
                    setAlphaSliderPosition(uiAlphaSlider);
                end

                ptrFusionColorbar = uiFusionColorbarPtr('get');
                if ~isempty(ptrFusionColorbar)

                    setFusionColorbarPosition(ptrFusionColorbar);
                end
            end

        end
    end
end
