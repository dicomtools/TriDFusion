function setFusionColorbarIntensityMaxScaleValue(dYOffset, dRatio, bDefaultUnit, dSeriesOffset)
%function setFusionColorbarIntensityMaxScaleValue(dYOffset, dRatio, bDefaultUnit, dSeriesOffset)
%Set fusion intensity max scale value.
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

    if dYOffset < 0
        dYOffset = 0;
    end

    adLineMinYOffset = get(lineFusionColorbarIntensityMinPtr('get'), 'YData');
    
    if dYOffset > adLineMinYOffset(1)
        dYOffset=adLineMinYOffset(1)-0.0001;
    end

    set(lineFusionColorbarIntensityMaxPtr('get'), 'YData', [dYOffset dYOffset]);
    set(textFusionColorbarIntensityMaxPtr('get'), 'Position', [0.1 dYOffset 0]);

 %   dYOffset = dYOffset-0.01; % Compensate for line width

    sUnitDisplay = getSerieUnitValue(dSeriesOffset);

%     if strcmpi(sUnitDisplay, 'HU')
%         dRatio=100;
%     end

%    if isempty(fusionBuffer('get', [], dSeriesOffset))

if 0
        aInputBuffer = inputBuffer('get');
    
        dMin = min(aInputBuffer{dSeriesOffset}, [], 'all');
        dMax = max(aInputBuffer{dSeriesOffset}, [], 'all');

        clear aInputBuffer;
else
    tQuantification = quantificationTemplate('get', [], dSeriesOffset);

    dMin = tQuantification.tCount.dMin;
    dMax = tQuantification.tCount.dMax;    
end

%    else
%        dMin = min(fusionBuffer('get', [], dSeriesOffset), [], 'all');
%        dMax = max(fusionBuffer('get', [], dSeriesOffset), [], 'all');        
%    end

    % Compute intensity

    dIntensityTotal = (dMax-dMin)*(dRatio/100);

    dPercenctOfMax = 1-dYOffset;

    dLevelMax = (dIntensityTotal*dPercenctOfMax)+dMin;
    
    fusionWindowLevel('set', 'max', dLevelMax);


    % Set axes intensity

%     if size(fusionBuffer('get', [], dSeriesOffset), 3) == 1            
%         set(axefPtr('get', [], dSeriesOffset), 'CLim', [dLevelMin dLevelMax]);
%     else
%         set(axes1fPtr('get', [], dSeriesOffset), 'CLim', [dLevelMin dLevelMax]);
%         set(axes2fPtr('get', [], dSeriesOffset), 'CLim', [dLevelMin dLevelMax]);
%         set(axes3fPtr('get', [], dSeriesOffset), 'CLim', [dLevelMin dLevelMax]);
%         if link2DMip('get') == true && isVsplash('get') == false
%             set(axesMipfPtr('get', [], dSeriesOffset), 'CLim', [dLevelMin dLevelMax]);
%         end
%     end

    % Set colorbar text

    if strcmpi(sUnitDisplay, 'SUV')  
        if bDefaultUnit == true
            tQuant = quantificationTemplate('get', [], dSeriesOffset);

            if isfield(tQuant, 'tSUV')
                dLevelMax = dLevelMax*tQuant.tSUV.dScale;      
            end
        end
    end

    if strcmpi(sUnitDisplay, 'HU')
        if bDefaultUnit == true
        
            [dLevelMax, ~] = computeWindowMinMax(dLevelMax, fusionWindowLevel('get', 'min'));  
        end        
    end

    sLevelMax = sprintf('%.1f', dLevelMax);
    if strcmpi(sLevelMax, '-0.0')
        sLevelMax = 0;
    end

    set(textFusionColorbarIntensityMaxPtr('get'), 'String', sLevelMax);

end