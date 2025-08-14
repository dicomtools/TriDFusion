function setWindowMinMax(dMax, dMin, bRefreshImages)
%function setWindowMinMax(dMax, dMin, bRefreshImages)
%Set 2D Window Min Max Value.
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

    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

    if dMax == dMin

        dMax = dMin+1;
    end
        
    windowLevel('set', 'max', dMax);
    windowLevel('set', 'min' ,dMin);

    getInitWindowMinMax('set', dMax, dMin);

%     set(uiSliderWindowPtr('get'), 'value', 0.5);
%     set(uiSliderLevelPtr('get') , 'value', 0.5);

    if switchTo3DMode('get')     == false && ...
       switchToIsoSurface('get') == false && ...
       switchToMIPMode('get')    == false     

        dYOffsetMax = computeLineColorbarIntensityMaxYOffset(dSeriesOffset);
        dYOffsetMin = computeLineColorbarIntensityMinYOffset(dSeriesOffset);

        % Ajust the intensity

        set(lineColorbarIntensityMaxPtr('get'), 'YData', [0.1 0.1]);
        set(lineColorbarIntensityMinPtr('get'), 'YData', [0.9 0.9]);
        
        setColorbarIntensityMinScaleValue(dYOffsetMin, ...
                                          colorbarScale('get'), ...
                                          isColorbarDefaultUnit('get'), ...
                                          dSeriesOffset...
                                          );

        setColorbarIntensityMaxScaleValue(dYOffsetMax, ...
                                          colorbarScale('get'), ...
                                          isColorbarDefaultUnit('get'), ...
                                          dSeriesOffset...
                                          );



        setAxesIntensity(dSeriesOffset);

        
        if exist('bRefreshImages', 'var')

            if bRefreshImages == true

                refreshImages();
            end
        end
    end
end 