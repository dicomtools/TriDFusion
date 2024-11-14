function aColorMap = getColorMap(sAction, lOffset, aAxeColorMap)
%function aColor = getColorMap(sAction, lOffset, aAxeColorMap)
%Return the 2D ColorMap, from an offset.
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
       
    persistent pasColorMap;
    persistent paColorMap;

    if isempty(pasColorMap)
        
        pasColorMap = getColorMapsName();                     
    end

    if isempty(paColorMap)

        paColorMap = getColorMapsValue();             
    end

    if strcmpi(sAction, 'all')

        aColorMap = pasColorMap;

    elseif strcmpi(sAction, 'name')

        aColorMap = '';

        for kk=1:numel(paColorMap)
            
            if invertColor('get')
                aColorCurrentMap = flipud(paColorMap{kk});
            else
                aColorCurrentMap = paColorMap{kk};
            end

            if isequal(aColorCurrentMap, aAxeColorMap)
                aColorMap = pasColorMap{kk};
                break;
            end
        end
    else
        if invertColor('get')
            
            aColorMap = flipud(paColorMap{lOffset});

        else
            aColorMap = paColorMap{lOffset};                     
        end
    end  

end    