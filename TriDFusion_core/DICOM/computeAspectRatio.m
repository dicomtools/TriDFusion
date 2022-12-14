function dRatio = computeAspectRatio(sDirection, atDicomInfo)        
%function dRatio = computeAspectRatio(sDirection, atDicomInfo)      
%Compute the aspect ratio from dicom header.
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

    if atDicomInfo{1}.ReconstructionDiameter 
        if strcmp(sDirection, 'y')      
            dRatio = computeSliceSpacing(atDicomInfo) * ...
                       (atDicomInfo{1}.Rows / atDicomInfo{1}.ReconstructionDiameter);  
        else      
            dRatio = computeSliceSpacing(atDicomInfo) * ...
                       (atDicomInfo{1}.Columns / atDicomInfo{1}.ReconstructionDiameter);                       
        end
    else
        dRatio = 1;
    end

end