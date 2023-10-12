function setTraWindowPosition(uiTraWindow)
%function setTraWindowPosition(uiTraWindow)
%Set Axial Window position.
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
    
    if isVsplash('get') == true && ...
       ~strcmpi(vSplahView('get'), 'all')                 
        if viewSegPanel('get')

            dXoffset = uiSegMainPanel.Position(3);
            dYoffset = addOnWidth('get')+30+15;
            dXsize   = getMainWindowSize('xsize')-(uiSegMainPanel.Position(3)/2);
            dYsize   = getMainWindowSize('ysize')-getTopWindowSize('ysize')-addOnWidth('get')-30-15;
  
        elseif viewKernelPanel('get') 

            dXoffset = uiKernelMainPanel.Position(3);
            dYoffset = addOnWidth('get')+30+15;
            dXsize   = getMainWindowSize('xsize')-(uiKernelMainPanel.Position(3)/2);
            dYsize   = getMainWindowSize('ysize')-getTopWindowSize('ysize')-addOnWidth('get')-30-15;
    
        elseif viewRoiPanel('get') 

            dXoffset = uiRoiMainPanel.Position(3);
            dYoffset = addOnWidth('get')+30+15;
            dXsize   = getMainWindowSize('xsize')-(uiRoiMainPanel.Position(3)/2);
            dYsize   = getMainWindowSize('ysize')-getTopWindowSize('ysize')-addOnWidth('get')-30-15;
                 
        else
            dXoffset = 0;
            dYoffset = addOnWidth('get')+30+15;
            dXsize   = getMainWindowSize('xsize');
            dYsize   = getMainWindowSize('ysize')-getTopWindowSize('ysize')-addOnWidth('get')-30-15;
                                      
        end  
     
    else
        if isVsplash('get') == true  

            dXoffset = getMainWindowSize('xsize')/2;
            dYoffset = addOnWidth('get')+30+15;
            dXsize   = getMainWindowSize('xsize')/2;
            dYsize   = getMainWindowSize('ysize')-getTopWindowSize('ysize')-addOnWidth('get')-30-15;
                
        else
            if isPanelFullScreen(btnUiTraWindowFullScreenPtr('get')) 

                 if viewSegPanel('get') == true
        
                    dXoffset = uiSegMainPanel.Position(3); 
                    dYoffset = addOnWidth('get')+30+15; 
                    dXsize   = getMainWindowSize('xsize')-uiSegMainPanel.Position(3);
                    dYsize   = getMainWindowSize('ysize')-getTopWindowSize('ysize')-addOnWidth('get')-30-15;                
        
                elseif viewKernelPanel('get') == true
                    dXoffset = uiKernelMainPanel.Position(3); 
                    dYoffset = addOnWidth('get')+30+15; 
                    dXsize   = getMainWindowSize('xsize')-uiKernelMainPanel.Position(3);
                    dYsize   = getMainWindowSize('ysize')-getTopWindowSize('ysize')-addOnWidth('get')-30-15;                
        
                elseif viewRoiPanel('get') == true
                    dXoffset = uiRoiMainPanel.Position(3); 
                    dYoffset = addOnWidth('get')+30+15; 
                    dXsize   = getMainWindowSize('xsize')-uiRoiMainPanel.Position(3);
                    dYsize   = getMainWindowSize('ysize')-getTopWindowSize('ysize')-addOnWidth('get')-30-15;                
        
                 else
                    dXoffset = 0; 
                    dYoffset = addOnWidth('get')+30+15; 
                    dXsize   = getMainWindowSize('xsize');
                    dYsize   = getMainWindowSize('ysize')-getTopWindowSize('ysize')-addOnWidth('get')-30-15;                
                end  
            else

                dXoffset = getMainWindowSize('xsize')/2.5;
                dYoffset = addOnWidth('get')+30+15;
                dXsize   = getMainWindowSize('xsize')/2.5;
                dYsize   = getMainWindowSize('ysize')-getTopWindowSize('ysize')-addOnWidth('get')-30-15;             
            end
         end
    end

    set(uiTraWindow, ...
        'Position', [dXoffset ...
                     dYoffset ...
                     dXsize ...
                     dYsize ...
                     ] ...
       );

    txt3 = axesText('get', 'axes3');
    if ~isempty(txt3)
        if isvalid(txt3.Parent)
            set(txt3.Parent, ...
                'Position', [25 ...
                             dYsize-getTopWindowSize('ysize') ...
                             100 ...
                             200 ...
                             ]...
                );                                               
        end
    end

    btnUiTraWindowFullScreen = btnUiTraWindowFullScreenPtr('get');
    if ~isempty(btnUiTraWindowFullScreen)

        if isFusion('get') == true

            set(btnUiTraWindowFullScreen, ...
                'Position', [dXsize-73 ...
                             25 ...
                             20 ...
                             20 ... 
                             ] ...
               );
        else
            set(btnUiTraWindowFullScreen, ...
                'Position', [dXsize-73 ...
                             5 ...
                             20 ...
                             20 ...
                             ] ...
               );
        end
    end
   
end