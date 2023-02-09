function tQuant = quantificationTemplate(sAction, tValue,  dSeriesOffset)
%function  tQuant = quantificationTemplate(sAction, tValue, dSeriesOffset)
%Get\Set Quantification Template.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Note: option settings must fit on one line and can contain one semicolon at most.
%Options can be strings, cell arrays of strings, or numerical arrays.
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

    persistent ptQuant; 

    uiSeries = uiSeriesPtr('get');
    
    if ~isempty(uiSeries)
        if exist('dSeriesOffset', 'var')
            iOffset = dSeriesOffset;
        else
            iOffset = get(uiSeries, 'Value');
        end
    else
        iOffset = 1;
    end

    if strcmpi('set', sAction)
        ptQuant{iOffset} = tValue; 
     elseif strcmpi('reset', sAction)    
        for aa=1:numel(ptQuant)
            ptQuant{aa} = '';
        end       
    else
        tQuant = ptQuant{iOffset};  
    end

end 