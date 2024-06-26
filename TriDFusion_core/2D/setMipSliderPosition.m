function setMipSliderPosition(uiMipSlider)
%function setMipSliderPosition(uiMipSlider)
%Set Mipittal slider position.
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
% This version of TriDFusion is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% TriDFusion is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
% without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
% See the GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with TriDFusion.  If not, see <http://www.gnu.org/licenses/>.
    
    uiSegMainPanel    = uiSegMainPanelPtr('get');
    uiKernelMainPanel = uiKernelMainPanelPtr('get');
    uiRoiMainPanel    = uiRoiMainPanelPtr('get');

    if isPanelFullScreen(btnUiMipWindowFullScreenPtr('get')) 

         if viewSegPanel('get') == true

            dXoffset = uiSegMainPanel.Position(3); 
            dYoffset = addOnWidth('get')+30; 
            dXsize   = getMainWindowSize('xsize')-uiSegMainPanel.Position(3);
            dYsize   = 20;

        elseif viewKernelPanel('get') == true
            dXoffset = uiKernelMainPanel.Position(3); 
            dYoffset = addOnWidth('get')+30; 
            dXsize   = getMainWindowSize('xsize')-uiKernelMainPanel.Position(3);
            dYsize   = 20;

        elseif viewRoiPanel('get') == true
            dXoffset = uiRoiMainPanel.Position(3); 
            dYoffset = addOnWidth('get')+30; 
            dXsize   = getMainWindowSize('xsize')-uiRoiMainPanel.Position(3);
            dYsize   = 20;

         else

            dXoffset = 0;
            dYoffset = addOnWidth('get')+30;
            dXsize   = getMainWindowSize('xsize');
            dYsize   = 20;
         end                    
    else
        dXoffset = (getMainWindowSize('xsize')/1.25);
        dYoffset = addOnWidth('get')+30;
        dXsize   = getMainWindowSize('xsize')/5;
        dYsize   = 20;       
    end

    set(uiMipSlider, ...
        'Position', [dXoffset ...
                     dYoffset ...
                     dXsize ...
                     dYsize ...
                     ] ...
       );

end