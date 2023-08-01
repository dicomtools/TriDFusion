function setFkeyWindowMinMax(lMax, lMin)
%function setFkeyWindowMinMax(lMax, lMin)
%Set F1-F9 Window Min Max Value.
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

    atMetaData = dicomMetaData('get');

    if strcmpi(atMetaData{1}.Modality, 'ct')

        windowLevel('set', 'max', lMax);
        windowLevel('set', 'min' ,lMin);

        getInitWindowMinMax('set', lMax, lMin);

        % Compute colorbar line y offset
    
        dYOffsetMax = computeLineColorbarIntensityMaxYOffset(get(uiSeriesPtr('get'), 'Value'));
        dYOffsetMin = computeLineColorbarIntensityMinYOffset(get(uiSeriesPtr('get'), 'Value'));

        % Ajust the intensity 

        set(lineColorbarIntensityMaxPtr('get'), 'YData', [0.1 0.1]);
        set(lineColorbarIntensityMinPtr('get'), 'YData', [0.9 0.9]);

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

        refreshImages();

%         set(uiSliderWindowPtr('get'), 'value', 0.5);
%         set(uiSliderLevelPtr('get') , 'value', 0.5);

%         if switchTo3DMode('get')     == false && ...
%            switchToIsoSurface('get') == false && ...
%            switchToMIPMode('get')    == false
% 
%             if size(dicomBuffer('get'), 3) == 1            
%                 set(axePtr('get', [], get(uiSeriesPtr('get'), 'Value')), 'CLim', [lMin lMax]);
%             else
%                 set(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))  , 'CLim', [lMin lMax]);
%                 set(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))  , 'CLim', [lMin lMax]);
%                 set(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))  , 'CLim', [lMin lMax]);
%                 
%                 if link2DMip('get') == true && isVsplash('get') == false
%                     set(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), 'CLim', [lMin lMax]);                   
%                 end
%             end
% 
%             refreshImages();
%         end
    end

    if isFusion('get') == true

        tFuseInput = inputTemplate('get');

        iFuseOffset = get(uiFusedSeriesPtr('get'), 'Value');                
        if iFuseOffset > numel(tFuseInput)                             
            return;
        else
            atFuseMetaData = tFuseInput(iFuseOffset).atDicomInfo;                   
            if strcmpi(atFuseMetaData{1}.Modality, 'ct')

                fusionWindowLevel('set', 'max', lMax);
                fusionWindowLevel('set', 'min' ,lMin);

                % Compute colorbar line y offset
        
                dYOffsetMax = computeLineFusionColorbarIntensityMaxYOffset(get(uiFusedSeriesPtr('get'), 'Value'));
                dYOffsetMin = computeLineFusionColorbarIntensityMinYOffset(get(uiFusedSeriesPtr('get'), 'Value'));

                % Ajust the intensity 

                set(lineFusionColorbarIntensityMaxPtr('get'), 'YData', [0.1 0.1]);
                set(lineFusionColorbarIntensityMinPtr('get'), 'YData', [0.9 0.9]);

                setFusionColorbarIntensityMaxScaleValue(dYOffsetMax, ...
                                                        fusionColorbarScale('get'), ...
                                                        isFusionColorbarDefaultUnit('get'),...
                                                        get(uiFusedSeriesPtr('get'), 'Value')...
                                                       );
                                                    
                setFusionColorbarIntensityMinScaleValue(dYOffsetMin, ...
                                                        fusionColorbarScale('get'), ...
                                                        isFusionColorbarDefaultUnit('get'),...
                                                        get(uiFusedSeriesPtr('get'), 'Value')...
                                                        );

                setFusionAxesIntensity(get(uiFusedSeriesPtr('get'), 'Value'));

                refreshImages();

%                 set(uiFusionSliderWindowPtr('get'), 'value', 0.5);
%                 set(uiFusionSliderLevelPtr('get') , 'value', 0.5);
% 
%                 if switchTo3DMode('get')     == false && ...
%                    switchToIsoSurface('get') == false && ...
%                    switchToMIPMode('get')    == false
% 
%                     if size(dicomBuffer('get'), 3) == 1            
%                         set(axefPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'CLim', [lMin lMax]);
%                     else
%                         set(axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))  , 'CLim', [lMin lMax]);
%                         set(axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))  , 'CLim', [lMin lMax]);
%                         set(axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))  , 'CLim', [lMin lMax]);
%                         if link2DMip('get') == true                      
%                             set(axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'CLim', [lMin lMax]);
%                         end
%                     end
% 
%                     refreshImages();
%                 end                        
            end
        end
    end 
end  