function aAlphamap = compute3DLinearAlphaMap(dFraction)
%function aAlphamap = compute3DLinearAlphaMap(dFraction)
%Return a 256 matrix, based on a 0 to 1 fraction.
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

    aAlphamap = zeros(256,1);

    if dFraction > 0 && dFraction <= 1
    
        dNbSteps = round(dFraction*256);
        dOffset = 256-dNbSteps;
        
        aLinAlphaMap1 = linspace(0, 1, dOffset)';
        aLinAlphaMap2 = linspace(1, 0, dNbSteps)';
    
        aAlphamap(1:dOffset) = aLinAlphaMap1;
        aAlphamap(dOffset+1:end) = aLinAlphaMap2;        
    end
    
end