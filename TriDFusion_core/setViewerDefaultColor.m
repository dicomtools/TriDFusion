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
          switchTo3DMode('get') == true || ...
          switchToMIPMode('get') == true 
            invertColor     ('set', true   );    
            backgroundColor ('set', 'white' );              
            set(fiMainWindowPtr('get'), 'Color', 'white');
        else   

            sModality = atMetaData{1}.Modality;
            if exist('atFuseMetaData', 'var')
                sFuseModality = atFuseMetaData{1}.Modality;
            else
                sFuseModality = 'null';
            end

            if bUpdateColorMap == true    
                if strcmpi(sModality, 'mr')&&strcmpi(sFuseModality, 'mr')
                    colorMapOffset('set', 10); 
                    fusionColorMapOffset('set', 10); 
                elseif strcmpi(sModality, 'pt')&&strcmpi(sFuseModality, 'mr')
                    if isFusion('get')
                        colorMapOffset('set', 19); 
                        fusionColorMapOffset('set', 10);   
                    else
                        colorMapOffset('set', 10); 
                        fusionColorMapOffset('set', 19);                                 
                    end
                elseif strcmpi(sModality, 'nm')&&strcmpi(sFuseModality, 'mr')
                    if isFusion('get')
                        colorMapOffset('set', 19); 
                        fusionColorMapOffset('set', 10);   
                    else
                        colorMapOffset('set', 10); 
                        fusionColorMapOffset('set', 19);                                 
                    end  
                elseif strcmpi(sModality, 'mr')&&strcmpi(sFuseModality, 'nm')    
                    colorMapOffset('set', 10); 
                    fusionColorMapOffset('set', 19);   
                elseif strcmpi(sModality, 'mr')&&strcmpi(sFuseModality, 'ct')    
                    colorMapOffset('set', 10); 
                    fusionColorMapOffset('set', 10);      
                elseif strcmpi(sModality, 'ct')&&strcmpi(sFuseModality, 'mr')    
                    colorMapOffset('set', 10); 
                    fusionColorMapOffset('set', 10);                                
                elseif strcmpi(sModality, 'mr')&&strcmpi(sFuseModality, 'pt')    
                    colorMapOffset('set', 10); 
                    fusionColorMapOffset('set', 19);      
                elseif strcmpi(sModality, 'nm')&&strcmpi(sFuseModality, 'nm')    
                    colorMapOffset('set', 10); 
                    fusionColorMapOffset('set', 10); 
                elseif strcmpi(sModality, 'pt')&&strcmpi(sFuseModality, 'pt')    
                    colorMapOffset('set', 10); 
                    fusionColorMapOffset('set', 10); 
                elseif strcmpi(sModality, 'nm')&&strcmpi(sFuseModality, 'pt')    
                    colorMapOffset('set', 10); 
                    fusionColorMapOffset('set', 10); 
                elseif strcmpi(sModality, 'pt')&&strcmpi(sFuseModality, 'nm')    
                    colorMapOffset('set', 10); 
                    fusionColorMapOffset('set', 10); 
                elseif strcmpi(sModality, 'pt')&&strcmpi(sFuseModality, 'pt')    
                    colorMapOffset('set', 10); 
                    fusionColorMapOffset('set', 10); 
                elseif strcmpi(sModality, 'ct')&&strcmpi(sFuseModality, 'ct')    
                    colorMapOffset('set', 10); 
                    fusionColorMapOffset('set', 10);                                         
                elseif strcmpi(sModality, 'nm')&&strcmpi(sFuseModality, 'ct')    
                    if isFusion('get')
                        colorMapOffset('set', 19); 
                        fusionColorMapOffset('set', 10);   
                    else
                        colorMapOffset('set', 10); 
                        fusionColorMapOffset('set', 19);                                 
                    end
                elseif strcmpi(sModality, 'pt')&&strcmpi(sFuseModality, 'ct')    
                    if isFusion('get')
                        colorMapOffset('set', 19); 
                        fusionColorMapOffset('set', 10);   
                    else
                        colorMapOffset('set', 10); 
                        fusionColorMapOffset('set', 19);                                 
                    end 
                else                                           
                    colorMapOffset('set', 10); 
                    if bUpdateColorMap == true
                        fusionColorMapOffset('set', 19);                               
                    end
                end                          
            end

            if bUpdateColorMap == true    

                if strcmpi(sModality, 'nm') || ...
                   strcmpi(sModality, 'pt') || ...
                   strcmpi(sModality, 'ot') 

                    if isFusion('get') == true && get(uiAlphaSliderPtr('get'), 'Value')
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
                    invertColor     ('set', false   );    
                    backgroundColor ('set', 'black' );   
                    overlayColor    ('set', 'white' );                        

                    set(uiLogo.Children, 'Color', [0.8500 0.8500 0.8500]);  

                end
            end

            if size(dicomBuffer('get'), 3) == 1
                set(uiOneWindowPtr('get'), 'BackgroundColor', backgroundColor('get'));
            else
                set(uiCorWindowPtr('get'), 'BackgroundColor', backgroundColor('get'));
                set(uiSagWindowPtr('get'), 'BackgroundColor', backgroundColor('get'));
                set(uiTraWindowPtr('get'), 'BackgroundColor', backgroundColor('get'));                            
            end

            uiSliderLevel = uiSliderLevelPtr('get');
            if ~isempty(uiSliderLevel)                                
                set(uiSliderLevel , 'BackgroundColor',  backgroundColor('get'));
            end

            uiSliderWindow = uiSliderWindowPtr('get');
            if ~isempty(uiSliderWindow)                               
                set(uiSliderWindow, 'BackgroundColor',  backgroundColor('get'));
            end

            uiFusionSliderLevel = uiFusionSliderLevelPtr('get');
            if ~isempty(uiFusionSliderLevel)                              
                set(uiFusionSliderLevel , 'BackgroundColor',  backgroundColor('get'));
            end

            uiFusionSliderWindow = uiFusionSliderWindowPtr('get');
            if ~isempty(uiFusionSliderWindow) 
                set(uiFusionSliderWindow, 'BackgroundColor',  backgroundColor('get'));                   
            end

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

            set(fiMainWindowPtr('get'), 'Color', 'black');  

            if size(dicomBuffer('get'), 3) == 1
                colormap(axePtr('get') , getColorMap('one', colorMapOffset('get')));
                if isFusion('get') == true                               
                    colormap(axefPtr('get'), getColorMap('one', fusionColorMapOffset('get')));
                end
            else               
                colormap(axes1Ptr('get'), getColorMap('one', colorMapOffset('get')));
                colormap(axes2Ptr('get'), getColorMap('one', colorMapOffset('get')));
                colormap(axes3Ptr('get'), getColorMap('one', colorMapOffset('get'))); 

                if isFusion('get') == true       
                    colormap(axes1fPtr('get'), getColorMap('one', fusionColorMapOffset('get')));
                    colormap(axes2fPtr('get'), getColorMap('one', fusionColorMapOffset('get')));
                    colormap(axes3fPtr('get'), getColorMap('one', fusionColorMapOffset('get')));   
                end
            end                        
        end

    end  

end   