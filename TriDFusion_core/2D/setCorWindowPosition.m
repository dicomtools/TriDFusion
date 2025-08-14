function setCorWindowPosition(uiCorWindow)
%function setCorWindowPosition(uiCorWindow)
%Set Coronal Window position.
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

    if viewSegPanel('get')
        if isVsplash('get') == true && ...
           ~strcmpi(vSplahView('get'), 'all')

            dXoffset = uiSegMainPanel.Position(3);
            dYoffset = addOnWidth('get')+30+15;
            dXsize   = getMainWindowSize('xsize')-(uiSegMainPanel.Position(3)/2);
            dYsize   = getMainWindowSize('ysize')-viewerToolbarHeight('get')-viewerTopBarHeight('get')-addOnWidth('get')-30-15;                  
        else
            if isVsplash('get') == true    

                dXoffset = uiSegMainPanel.Position(3);
                dYoffset = addOnWidth('get')+30+15;
                dXsize   = (getMainWindowSize('xsize')/4)-(uiSegMainPanel.Position(3)/2);
                dYsize   = getMainWindowSize('ysize')-viewerToolbarHeight('get')-viewerTopBarHeight('get')-addOnWidth('get')-30-15;             
            else
                if isPanelFullScreen(btnUiCorWindowFullScreenPtr('get')) 
                    dXoffset = uiSegMainPanel.Position(3);
                    dYoffset = addOnWidth('get')+30+15;
                    dXsize   = getMainWindowSize('xsize')-uiSegMainPanel.Position(3);
                    dYsize   = getMainWindowSize('ysize')-viewerToolbarHeight('get')-viewerTopBarHeight('get')-addOnWidth('get')-30-15;                     
                else
                    dXoffset = uiSegMainPanel.Position(3);
                    dYoffset = addOnWidth('get')+30+15;
                    dXsize   = (getMainWindowSize('xsize')/5)-(uiSegMainPanel.Position(3)/2);
                    dYsize   = getMainWindowSize('ysize')-viewerToolbarHeight('get')-viewerTopBarHeight('get')-addOnWidth('get')-30-15;                               
                end
            end
        end
    elseif viewKernelPanel('get')
        if isVsplash('get') == true && ...
           ~strcmpi(vSplahView('get'), 'all')

            dXoffset = uiKernelMainPanel.Position(3);
            dYoffset = addOnWidth('get')+30+15;
            dXsize   = getMainWindowSize('xsize')-(uiKernelMainPanel.Position(3)/2);
            dYsize   = getMainWindowSize('ysize')-viewerToolbarHeight('get')-viewerTopBarHeight('get')-addOnWidth('get')-30-15;                    
        else
            if isVsplash('get') == true    

                dXoffset = uiKernelMainPanel.Position(3);
                dYoffset = addOnWidth('get')+30+15;
                dXsize   = (getMainWindowSize('xsize')/4)-(uiKernelMainPanel.Position(3)/2);
                dYsize   = getMainWindowSize('ysize')-viewerToolbarHeight('get')-viewerTopBarHeight('get')-addOnWidth('get')-30-15; 
                     
            else
                if isPanelFullScreen(btnUiCorWindowFullScreenPtr('get')) 
                    dXoffset = uiKernelMainPanel.Position(3);
                    dYoffset = addOnWidth('get')+30+15;
                    dXsize   = getMainWindowSize('xsize')-uiKernelMainPanel.Position(3);
                    dYsize   = getMainWindowSize('ysize')-viewerToolbarHeight('get')-viewerTopBarHeight('get')-addOnWidth('get')-30-15;                        
                else
                    dXoffset = uiKernelMainPanel.Position(3);
                    dYoffset = addOnWidth('get')+30+15;
                    dXsize   = (getMainWindowSize('xsize')/5)-(uiKernelMainPanel.Position(3)/2);
                    dYsize   = getMainWindowSize('ysize')-viewerToolbarHeight('get')-viewerTopBarHeight('get')-addOnWidth('get')-30-15;                  
                end
            end
        end
    elseif viewRoiPanel('get')
        if isVsplash('get') == true && ...
           ~strcmpi(vSplahView('get'), 'all')

            dXoffset = uiRoiMainPanel.Position(3);
            dYoffset = addOnWidth('get')+30+15;
            dXsize   = getMainWindowSize('xsize')-(uiRoiMainPanel.Position(3)/2);
            dYsize   = getMainWindowSize('ysize')-viewerToolbarHeight('get')-viewerTopBarHeight('get')-addOnWidth('get')-30-15;                     
        else
            if isVsplash('get') == true

                dXoffset = uiRoiMainPanel.Position(3);
                dYoffset = addOnWidth('get')+30+15;
                dXsize   = (getMainWindowSize('xsize')/4)-(uiRoiMainPanel.Position(3)/2);
                dYsize   = getMainWindowSize('ysize')-viewerToolbarHeight('get')-viewerTopBarHeight('get')-addOnWidth('get')-30-15;                  
            else
                if isPanelFullScreen(btnUiCorWindowFullScreenPtr('get')) 
                    dXoffset = uiRoiMainPanel.Position(3);
                    dYoffset = addOnWidth('get')+30+15;
                    dXsize   = getMainWindowSize('xsize')-uiRoiMainPanel.Position(3);
                    dYsize   = getMainWindowSize('ysize')-viewerToolbarHeight('get')-viewerTopBarHeight('get')-addOnWidth('get')-30-15;                      
                else 
                    dXoffset = uiRoiMainPanel.Position(3);
                    dYoffset = addOnWidth('get')+30+15;
                    dXsize   = (getMainWindowSize('xsize')/5)-(uiRoiMainPanel.Position(3)/2);
                    dYsize   = getMainWindowSize('ysize')-viewerToolbarHeight('get')-viewerTopBarHeight('get')-addOnWidth('get')-30-15;   
                end
            end
        end            
    else
        if isVsplash('get') == true && ...
           ~strcmpi(vSplahView('get'), 'all')    

            dXoffset = 0;
            dYoffset = addOnWidth('get')+30+15;
            dXsize   = getMainWindowSize('xsize');
            dYsize   = getMainWindowSize('ysize')-viewerToolbarHeight('get')-viewerTopBarHeight('get')-addOnWidth('get')-30-15;                    
        else
            if isVsplash('get') == true

                dXoffset = 0;
                dYoffset = addOnWidth('get')+30+15;
                dXsize   = getMainWindowSize('xsize')/4;
                dYsize   = getMainWindowSize('ysize')-viewerToolbarHeight('get')-viewerTopBarHeight('get')-addOnWidth('get')-30-15;                       
            else  
                if isPanelFullScreen(btnUiCorWindowFullScreenPtr('get')) 
                    dXoffset = 0;
                    dYoffset = addOnWidth('get')+30+15;
                    dXsize   = getMainWindowSize('xsize');
                    dYsize   = getMainWindowSize('ysize')-viewerToolbarHeight('get')-viewerTopBarHeight('get')-addOnWidth('get')-30-15;                     
                else
                    dXoffset = 0;
                    dYoffset = addOnWidth('get')+30+15;
                    dXsize   = getMainWindowSize('xsize')/5;
                    dYsize   = getMainWindowSize('ysize')-viewerToolbarHeight('get')-viewerTopBarHeight('get')-addOnWidth('get')-30-15;              
                end
            end
        end
    end

    set(uiCorWindow, ...
        'position', [dXoffset ...
                     dYoffset ...
                     dXsize ...
                     dYsize ...
                     ]...
       );

    txt1 = axesText('get', 'axes1');
    if ~isempty(txt1)

        if isvalid(txt1.Parent)

            if isVsplash('get') == true

                if strcmpi(vSplahView('get'), 'all')
                    
                    dExtraYOffset = 0;   
                else                
                    dExtraYOffset = -20; 
                end
            else
                dExtraYOffset = 0;                                
            end

            set(txt1.Parent, ...
                'Position', [5 ...
                             dYsize-15-20+dExtraYOffset ...
                             70 ...
                             30 ...
                             ]...
                );         
        end
    end

    btnUiCorWindowFullScreen = btnUiCorWindowFullScreenPtr('get');

    if ~isempty(btnUiCorWindowFullScreen)

        if isFusion('get') == true && ...
           isPanelFullScreen(btnUiCorWindowFullScreenPtr('get'))  
            set(btnUiCorWindowFullScreen, ...
                'Position', [dXsize-20 ...
                             34 ...
                             20 ...
                             20] ...
               );            
        else
            set(btnUiCorWindowFullScreen, ...
                'Position', [dXsize-20 ...
                             10 ...
                             20 ...
                             20] ...
               );
        end
    end 

    chkUiCorWindowSelected = chkUiCorWindowSelectedPtr('get');

    if ~isempty(chkUiCorWindowSelected) && ...
       ~isempty(btnUiCorWindowFullScreen)     

        if isFusion('get') == true && ...
           isPanelFullScreen(btnUiCorWindowFullScreenPtr('get'))  
            set(chkUiCorWindowSelected, ...
                'Position', [dXsize-40 ...
                             34 ...
                             20 ...
                             20] ...
               );            
        else
            set(chkUiCorWindowSelected, ...
                'Position', [dXsize-40 ...
                             10 ...
                             20 ...
                             20] ...
               );
        end
    end

end