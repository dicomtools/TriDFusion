function setColorbarIntensityMinScaleValue(dYOffset, dRatio, bDefaultUnit, dSeriesOffset)
%function setColorbarIntensityMinScaleValue(dYOffset, dRatio, bDefaultUnit, dSeriesOffset)
%Set intensity min scale value.
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

    if dYOffset > 1
        dYOffset = 1;
    end

    adLineMaxYOffset = get(lineColorbarIntensityMaxPtr('get'), 'YData');
    
    if dYOffset < adLineMaxYOffset(1)
        dYOffset = adLineMaxYOffset(1)+0.0001;
    end

    set(lineColorbarIntensityMinPtr('get'), 'YData', [dYOffset dYOffset]);
    set(textColorbarIntensityMinPtr('get'), 'Position', [0 dYOffset 0]);

%    dYOffset = dYOffset+0.01; % Compensate for line width

    sUnitDisplay = getSerieUnitValue(dSeriesOffset);

    if strcmpi(sUnitDisplay, 'HU')
        dRatio=100;
    end

if 0    
    aInputBuffer = inputBuffer('get');

    dMin = min(aInputBuffer{dSeriesOffset}, [], 'all');
    dMax = max(aInputBuffer{dSeriesOffset}, [], 'all');

    clear aInputBuffer;
else
    tInput = inputTemplate('get');

    dMin = tInput(dSeriesOffset).tQuant.tCount.dMin;
    dMax = tInput(dSeriesOffset).tQuant.tCount.dMax;     
end

    % Compute intensity

    dIntensityTotal = (dMax-dMin)*(dRatio/100);

    dPercenctOfMin = 1-dYOffset;

    dLevelMin = (dIntensityTotal*dPercenctOfMin)+dMin;
    
    windowLevel('set', 'min', dLevelMin);


%     % Set axes intensity
% 
%     if size(dicomBuffer('get', [], dSeriesOffset), 3) == 1            
%         set(axePtr('get', [], dSeriesOffset), 'CLim', [dLevelMin dLevelMax]);
%     else
%         set(axes1Ptr('get', [], dSeriesOffset), 'CLim', [dLevelMin dLevelMax]);
%         set(axes2Ptr('get', [], dSeriesOffset), 'CLim', [dLevelMin dLevelMax]);
%         set(axes3Ptr('get', [], dSeriesOffset), 'CLim', [dLevelMin dLevelMax]);
%         if link2DMip('get') == true && isVsplash('get') == false
%             set(axesMipPtr('get', [], dSeriesOffset), 'CLim', [dLevelMin dLevelMax]);
%         end
%     end

    % Set colorbar text

    if strcmpi(sUnitDisplay, 'SUV')  

        if bDefaultUnit == true

            tQuant = quantificationTemplate('get', [], dSeriesOffset);
            dLevelMin = dLevelMin*tQuant.tSUV.dScale;      
        end
    end

    if strcmpi(sUnitDisplay, 'HU')

        if bDefaultUnit == true
        
            [~, dLevelMin] = computeWindowMinMax(windowLevel('get', 'max'), dLevelMin);  
        end        
    end

    sLevelMin = sprintf('%.1f', dLevelMin);
    if strcmpi(sLevelMin, '-0.0')
        sLevelMin = 0;
    end

    set(textColorbarIntensityMinPtr('get'), 'String', sLevelMin);

end