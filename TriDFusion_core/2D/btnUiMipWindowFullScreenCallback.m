function btnUiMipWindowFullScreenCallback(~, ~)
%function btnUiMipWindowFullScreenCallback(~, ~)
%Resize Miponal Window to Figure Full Screen.
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

    if ~isempty(uiMipWindow)

        btnUiMipWindowFullScreen = btnUiMipWindowFullScreenPtr('get');

        if ~isempty(btnUiMipWindowFullScreen)

            bIsFullScreen = isPanelFullScreen(btnUiMipWindowFullScreen);

            btnUiMipWindowFullScreen.CData = getFullScreenIconImage(uiMipWindow, bIsFullScreen);

            if bIsFullScreen == false

                ptLimit = axesLimitsFromTemplate(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')));

                adjAxeCameraViewAngle(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')));
                
                if isFusion('get') == true

                    setAxesLimitsFromSource(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')));
                end

                if isPlotContours('get') == true

                    setAxesLimitsFromSource(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')));                    
                end

                set(btnUiMipWindowFullScreen, 'TooltipString'  , 'Exit Full Screen (Ctrl + F)');

                set(uiTraWindow, 'Visible', 'Off');
                set(uiCorWindow, 'Visible', 'Off');
                set(uiSagWindow, 'Visible', 'Off');

                set(uiTraSlider, 'Visible', 'Off');
                set(uiCorSlider, 'Visible', 'Off');
                set(uiSagSlider, 'Visible', 'Off');
            else
                axesLimitsFromTemplate(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), ptLimit);

                if isFusion('get') == true

                    setAxesLimitsFromSource(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')));
                end

                if isPlotContours('get') == true
                    
                    setAxesLimitsFromSource(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')));
                end

                set(btnUiMipWindowFullScreen, 'TooltipString'  , 'Full Screen (Ctrl + F)');

                set(uiTraWindow, 'Visible', 'On');
                set(uiCorWindow, 'Visible', 'On');
                set(uiSagWindow, 'Visible', 'On');

                set(uiTraSlider, 'Visible', 'On');
                set(uiCorSlider, 'Visible', 'On');
                set(uiSagSlider, 'Visible', 'On');
            end

            if ~isempty(uiMipWindow)
                setMipWindowPosition(uiMipWindow);
            end

            if ~isempty(uiMipSlider)
                setMipSliderPosition(uiMipSlider);
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
