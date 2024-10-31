function btnUiSagWindowFullScreenCallback(~, ~)
%function btnUiSagWindowFullScreenCallback(~, ~)
%Resize Sagonal Window to Figure Full Screen.
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

    persistent ptLimit;

    uiCorWindow = uiCorWindowPtr('get');
    uiSagWindow = uiSagWindowPtr('get');
    uiTraWindow = uiTraWindowPtr('get');
    uiMipWindow = uiMipWindowPtr('get');

    uiCorSlider = uiSliderCorPtr('get');
    uiSagSlider = uiSliderSagPtr('get');
    uiTraSlider = uiSliderTraPtr('get');
    uiMipSlider = uiSliderMipPtr('get');

    if ~isempty(uiSagWindow)

        btnUiSagWindowFullScreen = btnUiSagWindowFullScreenPtr('get');

        if ~isempty(btnUiSagWindowFullScreen)

            bIsFullScreen = isPanelFullScreen(btnUiSagWindowFullScreen);

            btnUiSagWindowFullScreen.CData = getFullScreenIconImage(uiSagWindow, bIsFullScreen);

            if bIsFullScreen == false

                ptLimit = axesLimitsFromTemplate(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')));

                adjAxeCameraViewAngle(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')));
                
                if isFusion('get') == true

                    setAxesLimitsFromSource(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')));
                end

                if isPlotContours('get') == true

                    setAxesLimitsFromSource(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')));                    
                end

                set(btnUiSagWindowFullScreen, 'TooltipString'  , 'Exit Full Screen');

                set(uiTraWindow, 'Visible', 'Off');
                set(uiCorWindow, 'Visible', 'Off');
                set(uiMipWindow, 'Visible', 'Off');

                set(uiTraSlider, 'Visible', 'Off');
                set(uiCorSlider, 'Visible', 'Off');
                set(uiMipSlider, 'Visible', 'Off');
            else
                axesLimitsFromTemplate(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), ptLimit);

                if isFusion('get') == true

                    setAxesLimitsFromSource(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')));
                end

                if isPlotContours('get') == true
                    
                    setAxesLimitsFromSource(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')));                    
                end

                set(btnUiSagWindowFullScreen, 'TooltipString'  , 'Full Screen');

                set(uiTraWindow, 'Visible', 'On');
                set(uiCorWindow, 'Visible', 'On');
                set(uiMipWindow, 'Visible', 'On');

                set(uiTraSlider, 'Visible', 'On');
                set(uiCorSlider, 'Visible', 'On');
                set(uiMipSlider, 'Visible', 'On');
            end

            if ~isempty(uiSagWindow)
                setSagWindowPosition(uiSagWindow);
            end

            if ~isempty(uiSagSlider)
                setSagSliderPosition(uiSagSlider);
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
