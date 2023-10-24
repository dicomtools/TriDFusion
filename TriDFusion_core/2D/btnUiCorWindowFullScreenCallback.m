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

    uiCorWindow = uiCorWindowPtr('get');
    uiSagWindow = uiSagWindowPtr('get');
    uiTraWindow = uiTraWindowPtr('get');
    uiMipWindow = uiMipWindowPtr('get');

    uiCorSlider = uiSliderCorPtr('get');
    uiSagSlider = uiSliderSagPtr('get');
    uiTraSlider = uiSliderTraPtr('get');
    uiMipSlider = uiSliderMipPtr('get');

    if ~isempty(uiCorWindow)

        btnUiCorWindowFullScreen = btnUiCorWindowFullScreenPtr('get');

        if ~isempty(btnUiCorWindowFullScreen)

            bIsFullScreen = isPanelFullScreen(btnUiCorWindowFullScreen);

            btnUiCorWindowFullScreen.CData = getFullScreenIconImage(uiCorWindow,  bIsFullScreen);

            if bIsFullScreen == false

                set(btnUiCorWindowFullScreen, 'TooltipString'  , 'Exit Full Screen');

                set(uiTraWindow, 'Visible', 'Off');
                set(uiSagWindow, 'Visible', 'Off');
                set(uiMipWindow, 'Visible', 'Off');

                set(uiTraSlider, 'Visible', 'Off');
                set(uiSagSlider, 'Visible', 'Off');
                set(uiMipSlider, 'Visible', 'Off');
            else
                set(btnUiCorWindowFullScreen, 'TooltipString'  , 'Full Screen');

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
