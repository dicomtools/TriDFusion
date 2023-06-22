function setCrossVisibility(bStatus)
%function setCrossVisibility(sVisible)
%View ON/OFF 2D Cross. 
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

    if crossActivate('get') == true

        if size(dicomBuffer('get'), 3) == 1 || ...
           isVsplash('get') == true     

        else
            alAxes1Line = axesLine('get', 'axes1');
            alAxes2Line = axesLine('get', 'axes2');
            alAxes3Line = axesLine('get', 'axes3');

            for ii1=1:numel(alAxes1Line)    
                alAxes1Line{ii1}.Visible = bStatus;
            end

            for ii2=1:numel(alAxes2Line)    
                alAxes2Line{ii2}.Visible = bStatus;
            end

            for ii3=1:numel(alAxes3Line)    
                alAxes3Line{ii3}.Visible = bStatus;
            end 

            refreshImages();

        end                
    end

end