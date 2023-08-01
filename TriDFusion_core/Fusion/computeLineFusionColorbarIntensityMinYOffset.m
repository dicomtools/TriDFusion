function dYOffsetMin = computeLineFusionColorbarIntensityMinYOffset(dSeriesOffset)
%function dYOffsetMin = computeLineFusionColorbarIntensityMinYOffset(dSeriesOffset)
%Compute fusion colorbar max intensity y offset.
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

    dLevelMin = fusionWindowLevel('get', 'min');

if 0    
    aInputBuffer = inputBuffer('get');

    dImageMin = min(aInputBuffer{dSeriesOffset}, [], 'all');
    dImageMax = max(aInputBuffer{dSeriesOffset}, [], 'all');

    clear aInputBuffer;
else
    tQuantification = quantificationTemplate('get', [], dSeriesOffset);

    dImageMin = tQuantification.tCount.dMin;
    dImageMax = tQuantification.tCount.dMax;      
end
    dColorbarScale = fusionColorbarScale('get');

%     sUnitDisplay = getSerieUnitValue(dSeriesOffset);
% 
%     if strcmpi(sUnitDisplay, 'HU')
%         dColorbarScale=100;
%     end

    dIntensityTotal = (dImageMax-dImageMin)*dColorbarScale/100;

    dYOffsetMin = (1-((dLevelMin-dImageMin)/dIntensityTotal));
end