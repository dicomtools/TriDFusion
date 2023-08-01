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

    sWindow = sprintf('%.0f', dWindow);
    if strcmpi(sWindow, '-0')
        sWindow = '0';
    end

    sLevel  = sprintf('%.0f', dLevel);
    if strcmpi(sLevel, '-0')
        sLevel = '0';
    end

    if     strcmpi(sWindow, '1200') && strcmpi(sLevel, '-500')
        sWindowName = 'Lung';

    elseif strcmpi(sWindow, '500' ) && strcmpi(sLevel, '50'  )
        sWindowName = 'Soft Tissue';

    elseif strcmpi(sWindow, '500' ) && strcmpi(sLevel, '200' )
        sWindowName = 'Bone';           

    elseif strcmpi(sWindow, '240' ) && strcmpi(sLevel, '40'  )
        sWindowName = 'Liver';

    elseif strcmpi(sWindow, '80'  ) && strcmpi(sLevel, '40'  )
        sWindowName = 'Brain';                

    elseif strcmpi(sWindow, '350' ) && strcmpi(sLevel, '90'  )
        sWindowName = 'Head and Neck';                

    elseif strcmpi(sWindow, '2000') && strcmpi(sLevel, '-600')
        sWindowName = 'Enhanced Lung';               

    elseif strcmpi(sWindow, '350' ) && strcmpi(sLevel, '50'  )
        sWindowName = 'Mediastinum';                

    elseif strcmpi(sWindow, '1000') && strcmpi(sLevel, '350' )
        sWindowName = 'Temporal Bone';                

    elseif strcmpi(sWindow, '2500') && strcmpi(sLevel, '415' )
        sWindowName = 'Vertebra';

    elseif strcmpi(sWindow, '2000') && strcmpi(sLevel, '0'   )
        sWindowName = 'All';
    else
        sWindowName = 'Custom';
    end
end