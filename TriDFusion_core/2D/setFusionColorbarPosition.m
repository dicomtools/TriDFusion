function setFusionColorbarPosition(ptrFusionColorbar)
%function setFusionColorbarPosition(ptrFusionColorbar)
%Set fusion colorbar position.
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

    uiSegMainPanel    = uiSegMainPanelPtr('get');
    uiKernelMainPanel = uiKernelMainPanelPtr('get');
    uiRoiMainPanel    = uiRoiMainPanelPtr('get');

    aAxePosition = ptrFusionColorbar.Parent.Parent.Position;
    if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 3) == 1

        dXoffset = aAxePosition(3)-48;
        dYoffset = 30;
        dXsize   = 45;
        dYsize   = ((aAxePosition(4))/2)-53; 

    else
        if isVsplash('get') == true && ...
          ~strcmpi(vSplahView('get'), 'all')

            if viewSegPanel('get') 

                if keyPressFusionStatus('get') == 1
                    dXoffset = aAxePosition(3)-(uiSegMainPanel.Position(3)/2)-48;
                    dYoffset = 7+24;
                    dXsize   = 45;
                    dYsize   = aAxePosition(4)-11-24;                   
                else
                    dXoffset = aAxePosition(3)-(uiSegMainPanel.Position(3)/2)-48;
                    dYoffset = 30;
                    dXsize   = 45;
                    dYsize   = ((aAxePosition(4))/2)-44; 
                end
            elseif viewKernelPanel('get') == true 

                if keyPressFusionStatus('get') == 1
                    dXoffset = aAxePosition(3)-(uiKernelMainPanel.Position(3)/2)-48;
                    dYoffset = 7+24;
                    dXsize   = 45;
                    dYsize   = aAxePosition(4)-11-24;                      
                else
                    dXoffset = aAxePosition(3)-(uiKernelMainPanel.Position(3)/2)-48;
                    dYoffset = 30;
                    dXsize   = 45;
                    dYsize   = ((aAxePosition(4))/2)-44; 
                end
            elseif viewRoiPanel('get') == true 

                if keyPressFusionStatus('get') == 1
                    dXoffset = aAxePosition(3)-(uiRoiMainPanel.Position(3)/2)-48;
                    dYoffset = 7+24;
                    dXsize   = 45;
                    dYsize   = aAxePosition(4)-11-24;                   
                else
                    dXoffset = aAxePosition(3)-(uiRoiMainPanel.Position(3)/2)-48;
                    dYoffset = 30;
                    dXsize   = 45;
                    dYsize   = ((aAxePosition(4))/2)-44;
                end 
            else
                if keyPressFusionStatus('get') == 1
                    dXoffset = aAxePosition(3)-48;
                    dYoffset = 7+24;
                    dXsize   = 45;
                    dYsize   = aAxePosition(4)-11-24;                    
                else
                    dXoffset = aAxePosition(3)-48;
                    dYoffset = 30;
                    dXsize   = 45;
                    dYsize   = ((aAxePosition(4))/2)-44;
                end
            end
        else
            if keyPressFusionStatus('get') == 1

                dXoffset = aAxePosition(3)-48;
                dYoffset = 7+24;
                dXsize   = 45;
                dYsize   = aAxePosition(4)-11-24;            
            else
                dXoffset = aAxePosition(3)-48;
                dYoffset = 30;
                dXsize   = 45;
                dYsize   = ((aAxePosition(4))/2)-44;
            end
        end
    end

    set(ptrFusionColorbar.Parent, ...
        'Position', [dXoffset, ...            
                     dYoffset, ...
                     dXsize, ...
                     dYsize] ...   
       );
    
    axeFusionColorbar = axeFusionColorbarPtr('get');
    if ~isempty(axeFusionColorbar)
        
        set(axeFusionColorbar, ...
            'Position', [dXoffset, ...            
                         dYoffset, ...
                         dXsize, ...
                         dYsize] ...   
           );

    end    

    % drawnow;
end