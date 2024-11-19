function setViewerDefaultColor(bUpdateColorMap, atMetaData, atFuseMetaData)
%function setViewerDefaultColor(bUpdateColorMap, atMetaData, atFuseMetaData)
%Set Viewer 2D and 3D Default Colormap and Background.
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

    tViewerTemplate = inputTemplate('get');
    uiLogo = logoObject('get');

    iOffset = get(uiSeriesPtr('get'), 'Value');
    if iOffset > numel(tViewerTemplate) || ...
       isempty(dicomBuffer('get'))
        return;
    else
         if switchToIsoSurface('get') == true || ...
            switchTo3DMode('get')     == true || ...
            switchToMIPMode('get')    == true

             if switchToIsoSurface('get') == true  && ...
                switchTo3DMode('get')     == false && ...
                switchToMIPMode('get')    == false

                invertColor     ('set', true   );
                backgroundColor ('set', 'white' );
                set(fiMainWindowPtr('get'), 'Color', 'white');

                set(uiOneWindowPtr('get'), 'BackgroundColor', backgroundColor('get'));

                background3DOffset('set', 7);
            end
        else

            dNbFusedAxes    = 0;
            dNMipFusedAxes  = 0;

            if isFusion('get') == true
                if size(dicomBuffer('get'), 3) == 1
                    dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
                    for rr=1:dNbFusedSeries
                        imAxeF = imAxeFPtr('get', [], rr);
                        if ~isempty(imAxeF)
                            dNbFusedAxes = dNbFusedAxes+1;
                        end
                    end
                else

                    dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
                    for rr=1:dNbFusedSeries

                        imCoronalF  = imCoronalFPtr ('get', [], rr);
                        imSagittalF = imSagittalFPtr('get', [], rr);
                        imAxialF    = imAxialFPtr   ('get', [], rr);

                        if ~isempty(imCoronalF) && ...
                           ~isempty(imSagittalF) && ...
                           ~isempty(imAxialF)

                            dNbFusedAxes = dNbFusedAxes+1;
                        end

                        if link2DMip('get') == true && isVsplash('get') == false

                            imMipF = imMipFPtr('get', [], rr);
                            if ~isempty(imMipF)
                                dNMipFusedAxes = dNMipFusedAxes+1;
                            end
                        end
                    end
                end
            end

            if dNbFusedAxes < 2


               sModality = atMetaData{1}.Modality;
               if strcmpi(sModality, 'RTDOSE') 
                   sModality = 'pt';
               end

               if exist('atFuseMetaData', 'var')
                    sFuseModality = atFuseMetaData{1}.Modality;
                    if strcmpi(sFuseModality, 'RTDOSE') 
                       sFuseModality = 'pt';
                    end                    
                else
                    sFuseModality = 'null';
                end

                if bUpdateColorMap == true
                    if strcmpi(sModality, 'mr')&&strcmpi(sFuseModality, 'mr')
                        colorMapOffset('set', 9);
                        fusionColorMapOffset('set', 9);
                    elseif strcmpi(sModality, 'pt')&&strcmpi(sFuseModality, 'mr')
                        if isFusion('get')
                            colorMapOffset('set', 19);
                            fusionColorMapOffset('set', 9);
                        else
                            colorMapOffset('set', 9);
                            fusionColorMapOffset('set', 19);
                        end
                    elseif strcmpi(sModality, 'nm')&&strcmpi(sFuseModality, 'mr')
                        if isFusion('get')
                            colorMapOffset('set', 19);
                            fusionColorMapOffset('set', 9);
                        else
                            colorMapOffset('set', 9);
                            fusionColorMapOffset('set', 19);
                        end
                    elseif strcmpi(sModality, 'mr')&&strcmpi(sFuseModality, 'nm')
                        colorMapOffset('set', 9);
                        fusionColorMapOffset('set', 19);
                    elseif strcmpi(sModality, 'mr')&&strcmpi(sFuseModality, 'ct')
                        colorMapOffset('set', 9);
                        fusionColorMapOffset('set', 19);
                    elseif strcmpi(sModality, 'ct')&&strcmpi(sFuseModality, 'mr')
                        colorMapOffset('set', 9);
                        fusionColorMapOffset('set', 9);
                    elseif strcmpi(sModality, 'mr')&&strcmpi(sFuseModality, 'pt')
                        colorMapOffset('set', 9);
                        fusionColorMapOffset('set', 19);
                    elseif strcmpi(sModality, 'nm')&&strcmpi(sFuseModality, 'nm')
                        colorMapOffset('set', 9);
                        fusionColorMapOffset('set', 19);
                    elseif strcmpi(sModality, 'pt')&&strcmpi(sFuseModality, 'pt')
                        colorMapOffset('set', 9);
                        fusionColorMapOffset('set', 19);
                    elseif strcmpi(sModality, 'nm')&&strcmpi(sFuseModality, 'pt')
                        colorMapOffset('set', 9);
                        fusionColorMapOffset('set', 19);
                    elseif strcmpi(sModality, 'pt')&&strcmpi(sFuseModality, 'nm')
                        colorMapOffset('set', 9);
                        fusionColorMapOffset('set', 19);
%                     elseif strcmpi(sModality, 'pt')&&strcmpi(sFuseModality, 'pt')
%                         colorMapOffset('set', 9);
%                         fusionColorMapOffset('set', 19);
                    elseif strcmpi(sModality, 'ct')&&strcmpi(sFuseModality, 'ct')
                        colorMapOffset('set', 9);
                        fusionColorMapOffset('set', 19);
                    elseif strcmpi(sModality, 'nm')&&strcmpi(sFuseModality, 'ct')
                        if isFusion('get')
                            colorMapOffset('set', 19);
                            fusionColorMapOffset('set', 9);
                        else
                            colorMapOffset('set', 9);
                            fusionColorMapOffset('set', 19);
                        end
                    elseif strcmpi(sModality, 'ct')&&strcmpi(sFuseModality, 'nm')

                        if isFusion('get') && keyPressFusionStatus('get') == 1
                            colorMapOffset('set', 19);
                            fusionColorMapOffset('set', 9);
                        else
                            colorMapOffset('set', 9);
                            fusionColorMapOffset('set', 19);
                        end
                    elseif strcmpi(sModality, 'pt')&&strcmpi(sFuseModality, 'ct')
                        if isFusion('get')
                            colorMapOffset('set', 19);
                            fusionColorMapOffset('set', 9);
                        else
                            colorMapOffset('set', 9);
                            fusionColorMapOffset('set', 19);
                        end
                    elseif strcmpi(sModality, 'ct')&&strcmpi(sFuseModality, 'pt')

                        if isFusion('get') && keyPressFusionStatus('get') == 1
                            colorMapOffset('set', 19);
                            fusionColorMapOffset('set', 9);
                        else
                            colorMapOffset('set', 9);
                            fusionColorMapOffset('set', 19);
                        end
                    else
                        colorMapOffset('set', 9);
                        if bUpdateColorMap == true
                            fusionColorMapOffset('set', 19);
                        end
                    end
                end

                if bUpdateColorMap == true

                    if strcmpi(sModality, 'nm') || ...
                       strcmpi(sModality, 'pt') || ...
                       strcmpi(sModality, 'ot') 
 

                        if isFusion('get') == true && keyPressFusionStatus('get')
                            if strcmpi(sFuseModality, 'mr') || ...
                               strcmpi(sFuseModality, 'ct')
                                invertColor('set', false);

                                backgroundColor ('set', 'black' );
                                overlayColor    ('set', 'white' );

                                if ~isempty(uiLogo)
                                    set(uiLogo.Children, 'Color', [0.8500 0.8500 0.8500]);
                                end
                            else

                                invertColor('set', true);

                                backgroundColor ('set', 'white' );
                                overlayColor    ('set', 'black' );

                                if ~isempty(uiLogo)
                                    set(uiLogo.Children, 'Color', [0.1500 0.1500 0.1500]);
                                end
                            end

                        else
                            % colorMapOffset('set', 11);

                            invertColor('set', true);

                            backgroundColor ('set', 'white' );
                            overlayColor    ('set', 'black' );

                            if ~isempty(uiLogo)
                                set(uiLogo.Children, 'Color', [0.1500 0.1500 0.1500]);
                            end

                        end
                    else
                        if strcmpi(sFuseModality, 'nm') || ...
                           strcmpi(sFuseModality, 'pt')
                            if isFusion('get') == true && keyPressFusionStatus('get') == 1
                                invertColor     ('set', true   );
                                backgroundColor ('set', 'white' );
                                overlayColor    ('set', 'black' );

                                set(uiLogo.Children, 'Color', [0.1500 0.1500 0.1500]);
                            else
                                invertColor     ('set', false   );
                                backgroundColor ('set', 'black' );
                                overlayColor    ('set', 'white' );

                                set(uiLogo.Children, 'Color', [0.8500 0.8500 0.8500]);
                           end
                        else

                            invertColor     ('set', false   );
                            backgroundColor ('set', 'black' );
                            overlayColor    ('set', 'white' );

                            set(uiLogo.Children, 'Color', [0.8500 0.8500 0.8500]);
                        end

                    end
                end

                if size(dicomBuffer('get'), 3) == 1
                    set(uiOneWindowPtr('get'), 'BackgroundColor', backgroundColor('get'));
                else
                    set(uiCorWindowPtr('get'), 'BackgroundColor', backgroundColor('get'));
                    set(uiSagWindowPtr('get'), 'BackgroundColor', backgroundColor('get'));
                    set(uiTraWindowPtr('get'), 'BackgroundColor', backgroundColor('get'));

                    if link2DMip('get') == true && isVsplash('get') == false
                        set(uiMipWindowPtr('get'), 'BackgroundColor', backgroundColor('get'));
                    end
                end

%                 uiSliderLevel = uiSliderLevelPtr('get');
%                 if ~isempty(uiSliderLevel)
%                     set(uiSliderLevel , 'BackgroundColor',  backgroundColor('get'));
%                 end

%                 uiSliderWindow = uiSliderWindowPtr('get');
%                 if ~isempty(uiSliderWindow)
%                     set(uiSliderWindow, 'BackgroundColor',  backgroundColor('get'));
%                 end

%                 uiFusionSliderLevel = uiFusionSliderLevelPtr('get');
%                 if ~isempty(uiFusionSliderLevel)
%                     set(uiFusionSliderLevel , 'BackgroundColor',  backgroundColor('get'));
%                 end

%                 uiFusionSliderWindow = uiFusionSliderWindowPtr('get');
%                 if ~isempty(uiFusionSliderWindow)
%                     set(uiFusionSliderWindow, 'BackgroundColor',  backgroundColor('get'));
%                 end

                uiAlphaSlider = uiAlphaSliderPtr('get');
                if ~isempty(uiAlphaSlider)
                    set(uiAlphaSlider, 'BackgroundColor',  backgroundColor('get'));
                end

                ptrColorbar = uiColorbarPtr('get');
                if ~isempty(ptrColorbar)
                    set(ptrColorbar, 'Color',  overlayColor('get'));
                end

                ptrFusionColorbar = uiFusionColorbarPtr('get');
                if ~isempty(ptrFusionColorbar)
                    set(ptrFusionColorbar   , 'Color',  overlayColor('get'));
                end

                set(fiMainWindowPtr('get'), 'Color', backgroundColor('get'));
            end

            if size(dicomBuffer('get'), 3) == 1

                colormap(axePtr('get', [], get(uiSeriesPtr('get'), 'Value')) , getColorMap('one', colorMapOffset('get')));

                colormap(uiColorbarPtr('get'), getColorMap('one', colorMapOffset('get')));

                if isFusion('get') == true

                    if dNbFusedAxes < 2

                        colormap(uiFusionColorbarPtr('get'), getColorMap('one', fusionColorMapOffset('get')));

                        colormap(axefPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), getColorMap('one', fusionColorMapOffset('get')));
                    end
                end
            else
                colormap(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), getColorMap('one', colorMapOffset('get')));
                colormap(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), getColorMap('one', colorMapOffset('get')));
                colormap(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), getColorMap('one', colorMapOffset('get')));

                if link2DMip('get') == true && isVsplash('get') == false

                    colormap(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), getColorMap('one', colorMapOffset('get')));
                end

                colormap(uiColorbarPtr('get'), flipud(colormap(getColorMap('one', colorMapOffset('get')))) );

                if isFusion('get') == true

                    if dNbFusedAxes < 2
                        
                        colormap(uiFusionColorbarPtr('get'), getColorMap('one', fusionColorMapOffset('get')));

                        colormap(axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), getColorMap('one', fusionColorMapOffset('get')));
                        colormap(axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), getColorMap('one', fusionColorMapOffset('get')));
                        colormap(axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), getColorMap('one', fusionColorMapOffset('get')));
                    end

                    if link2DMip('get') == true && isVsplash('get') == false

                        if dNMipFusedAxes < 2
                            
                            colormap(axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), getColorMap('one', fusionColorMapOffset('get')));
                        end
                    end
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

            end
        end

    end

end
