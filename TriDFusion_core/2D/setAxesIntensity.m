function setAxesIntensity(dSeriesOffset)
%function setAxesIntensity(dSeriesOffset)
% set axes min max intensity.
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

    dLevelMin = windowLevel('get', 'min');
    dLevelMax = windowLevel('get', 'max');

    if isnan(dLevelMin)
        dLevelMin = 0;
    end

    if isnan(dLevelMax)
        dLevelMax = dLevelMin+1;
    end

    if dLevelMin == dLevelMax
        dLevelMax = dLevelMax+1;
    end

    % Set axes intensity

    if size(dicomBuffer('get', [], dSeriesOffset), 3) == 1            
        set(axePtr('get', [], dSeriesOffset), 'CLim', [dLevelMin dLevelMax]);
    else
        set(axes1Ptr('get', [], dSeriesOffset), 'CLim', [dLevelMin dLevelMax]);
        set(axes2Ptr('get', [], dSeriesOffset), 'CLim', [dLevelMin dLevelMax]);
        set(axes3Ptr('get', [], dSeriesOffset), 'CLim', [dLevelMin dLevelMax]);
        if link2DMip('get') == true && isVsplash('get') == false
            set(axesMipPtr('get', [], dSeriesOffset), 'CLim', [dLevelMin dLevelMax]);
        end
    end 
end