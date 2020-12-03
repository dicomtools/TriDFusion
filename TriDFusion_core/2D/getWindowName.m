function sWindowName = getWindowName(dWindow, dLevel)
%function sWindowName = getWindowName(dWindow, dLevel)
%Return the intensity Window's name.
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

    if     dWindow == 1200 &&...
           dLevel  == -500
        sWindowName = 'Lung';
    elseif dWindow == 500 &&...   
           dLevel  == 50
        sWindowName = 'Soft';
    elseif dWindow == 500 &&...   
           dLevel  == 200
        sWindowName = 'Bone';           
    elseif dWindow == 240 &&...   
           dLevel  == 40
        sWindowName = 'Liver';
    elseif dWindow == 80 &&...   
           dLevel  == 40
        sWindowName = 'Brain';                
    elseif dWindow == 350 &&...   
           dLevel  == 90
        sWindowName = 'Head and Neck';                
     elseif dWindow == 2000 &&...   
            dLevel  == -600
        sWindowName = 'Enchanced Lung';               
    elseif dWindow == 350 &&...   
           dLevel  == 50
        sWindowName = 'Mediastinum';                
    elseif dWindow == 1000 &&...   
           dLevel  == 350
        sWindowName = 'Temporal Bone';                
    elseif dWindow == 2500 &&...   
           dLevel  == 415
        sWindowName = 'Vertebra';
    elseif dWindow == 350 &&...   
           dLevel  == 50
        sWindowName = 'Scout CT';
    elseif dWindow == 2000 &&...   
           dLevel  == 0
        sWindowName = 'All';
    else
        sWindowName = 'Custom';
    end
end