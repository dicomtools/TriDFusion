function atVoi = voiTemplateBackup(sAction, iOffset, tValue)
%function atVoi = voiTemplateBackup(sAction, iOffset, tValue)
%Get\Set VOI Template backup state.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Note: option settings must fit on one line and can contain one semicolon at most.
%Options can be strings, cell arrays of strings, or numerical arrays.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2025, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    persistent patVoi;           

    if strcmpi('set', sAction)
        patVoi{iOffset} = tValue; 
    elseif strcmpi('reset', sAction)    
        if exist('iOffset', 'var') % Clear one series
            patVoi{iOffset} = [];
        else    
            for aa=1:numel(patVoi)
                patVoi{aa} = [];
            end
        end
    else
        if numel(patVoi) < iOffset
            atVoi = '';
        else
            atVoi = patVoi{iOffset};
        end      
    end  
    
end  