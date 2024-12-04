function setColorbarLabel() 
%function setColorbarLabel() 
%Set 2D Fusion Colorbar Label.
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

    tInput = inputTemplate('get');
    
    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');
    if dSeriesOffset > numel(tInput)
        return;
    end
    
    sLabel = '';

    bSetLabel = false;

    if tInput(dSeriesOffset).bDoseKernel == true

        sLabel = sprintf('Dose');

        bSetLabel = true;
    end
    
    if tInput(dSeriesOffset).bEdgeDetection == true

        if tInput(dSeriesOffset).bDoseKernel == true
            sLabel = sprintf('%s, Edge', sLabel);
        else
            sLabel = sprintf('Edge');
        end

        bSetLabel = true;
    end    
       
    if bSetLabel == true
        
        ptrColorbar = uiColorbarPtr('get');
    
        ptrColorbar.Label.String = sLabel;         
        uiColorbarPtr('set', ptrColorbar);
    end
end