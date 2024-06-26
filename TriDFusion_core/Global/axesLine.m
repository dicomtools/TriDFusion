function aLine = axesLine(sAction, sAxes, aValue)
%function aLine = axesLine(sAction, sAxes, aValue)
%Get/Set 2D axes Line value.
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

    persistent paLineAxes1; 
    persistent paLineAxes2; 
    persistent paLineAxes3; 
    persistent paLineAxesMip; 

    if strcmpi('set', sAction)
        if     strcmpi('axes1', sAxes)
            paLineAxes1 = aValue;            
        elseif strcmpi('axes2', sAxes)
            paLineAxes2 = aValue;    
        elseif strcmpi('axes3', sAxes)
            paLineAxes3 = aValue;    
        elseif strcmpi('axesMip', sAxes)
            paLineAxesMip = aValue;   
        else
        end
    else
         if strcmpi('axes1', sAxes)
            aLine = paLineAxes1;            
        elseif strcmpi('axes2', sAxes)
            aLine = paLineAxes2;            
        elseif strcmpi('axes3', sAxes)
            aLine = paLineAxes3;      
        elseif strcmpi('axesMip', sAxes)
            aLine = paLineAxesMip;      
        else
        end                  
    end            
end  