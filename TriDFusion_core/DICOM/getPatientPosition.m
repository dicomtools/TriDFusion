function sPosition = getPatientPosition(aOrientation)
%function sPosition = getPatientPosition(aOrientation)
%Return plane view orientation as a string.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2021, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    aOrientation = round(aOrientation);    
    if numel(aOrientation) == 6
        if     abs(aOrientation(2)) == 1 && ...
               abs(aOrientation(6)) == 1  % ['0', '1', '0', '0', '0', '-1'] Sagittal plane view
                sPosition = 'To do';
                
        elseif abs(aOrientation(1)) == 1 && ...
               abs(aOrientation(6)) == 1  % ['1', '0', '0', '0', '0', '-1']  Coronal plane view
                sPosition = 'To do';
           
        else                              % ['1', '0', '0', '0', '1', '0'] Axial plane view 
            if aOrientation(5) == -1
                sPosition = 'FFP';
            else
                sPosition = 'To do';
            end

        end
    else
        sPosition = 'Unknow';
    end        
end