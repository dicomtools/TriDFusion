function resizeFigure(~, ~) 
%function resizeFigure(~, ~)
%Resize Main Figure.
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

   uiSegMainPanel = uiSegMainPanelPtr('get');
   if ~isempty(uiSegMainPanel)
        set(uiSegMainPanel, ...
            'position', [0 ...
                         addOnWidth('get')+30 ...
                         300 ...
                         getMainWindowSize('ysize')-getTopWindowSize('ysize')-addOnWidth('get')-30 ...
                         ] ...
           );

        uiSegPanelSlider = uiSegPanelSliderPtr('get');
        if ~isempty(uiSegPanelSlider)

            aMainSegPanelPosition = get(uiSegMainPanel, 'position');
            set(uiSegPanelSlider, ...
                'position', [280 ...
                             0 ...
                             20 ...
                             aMainSegPanelPosition(4) ...
                             ]...
               );                
        end              
    end            

    uiKernelMainPanel = uiKernelMainPanelPtr('get');
    if ~isempty(uiKernelMainPanel)
        set(uiKernelMainPanel, ...
            'position', [0 ...
                         addOnWidth('get')+30 ...
                         300 ...
                         getMainWindowSize('ysize')-getTopWindowSize('ysize')-addOnWidth('get')-30 ...
                         ] ...
           );

        uiKernelPanelSlider = uiKernelPanelSliderPtr('get');
        if ~isempty(uiKernelPanelSlider)
            aMainKernelPanelPosition = get(uiKernelMainPanel, 'position');
            set(uiKernelPanelSlider, ...
                'position', [280 ...
                             0 ...
                             20 ...
                             aMainKernelPanelPosition(4) ...
                             ]...
               );                
        end 
    end
    
    uiRoiMainPanel = uiRoiMainPanelPtr('get');
    if ~isempty(uiRoiMainPanel)
        set(uiRoiMainPanel, ...
            'position', [0 ...
                         addOnWidth('get')+30 ...
                         300 ...
                         getMainWindowSize('ysize')-getTopWindowSize('ysize')-addOnWidth('get')-30 ...
                         ] ...
           );

        uiRoiPanelSlider = uiRoiPanelSliderPtr('get');
        if ~isempty(uiRoiPanelSlider)
            aMainRoiPanelPosition = get(uiRoiMainPanel, 'position');
            set(uiRoiPanelSlider, ...
                'position', [280 ...
                             0 ...
                             20 ...
                             aMainRoiPanelPosition(4) ...
                             ]...
               );                
        end 
    end
    
    uiCorWindow = uiCorWindowPtr('get');
    if ~isempty(uiCorWindow)
        
        setCorWindowPosition(uiCorWindow);
    end   

    uiSagWindow = uiSagWindowPtr('get');
    if ~isempty(uiSagWindow)

        setSagWindowPosition(uiSagWindow);
    end  

    uiTraWindow = uiTraWindowPtr('get');
    if ~isempty(uiTraWindow)

        setTraWindowPosition(uiTraWindow);
    end  
    
    uiMipWindow = uiMipWindowPtr('get');
    if ~isempty(uiTraWindow)

        setMipWindowPosition(uiMipWindow);
    end  
    
    uiSliderCor = uiSliderCorPtr('get');
    if ~isempty(uiSliderCor)                               

        setCorSliderPosition(uiSliderCor);
    end    

    uiSliderSag = uiSliderSagPtr('get');
    if ~isempty(uiSliderSag)                 

        setSagSliderPosition(uiSliderSag);     
    end

    uiSliderTra = uiSliderTraPtr('get');
    if ~isempty(uiSliderTra)   

        setTraSliderPosition(uiSliderTra);
    end
    
    uiSliderMip = uiSliderMipPtr('get');
    if ~isempty(uiSliderMip)  

        setMipSliderPosition(uiSliderMip);        
    end
        
    uiTopWindow = uiTopWindowPtr('get');
    if ~isempty(uiTopWindow)

        set(uiTopWindow, ...
            'position', [0 ...
                        getMainWindowSize('ysize')-getTopWindowSize('ysize') ...
                        getMainWindowSize('xsize') ...
                        getTopWindowSize('ysize') ...
                        ]...
            );
    end  

    uiOneWindow = uiOneWindowPtr('get');
    if ~isempty(uiOneWindow)

        setOneWindowPosition(uiOneWindow);
    end 

    uiMain3DPanel = uiMain3DPanelPtr('get');
    if ~isempty(uiMain3DPanel)
        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true            
            set(uiMain3DPanel, ...
                'position', [0 ...
                             addOnWidth('get')+30 ...
                             680 ...
                             getMainWindowSize('ysize')-getTopWindowSize('ysize')-addOnWidth('get')-30 ...
                             ]...
               );                
        end

        ui3DPanelSlider = ui3DPanelSliderPtr('get');
        if ~isempty(ui3DPanelSlider)
            if switchTo3DMode('get')     == true || ...
               switchToIsoSurface('get') == true || ...
               switchToMIPMode('get')    == true     
                aMain3DPanelPosition = get(uiMain3DPanel, 'position');
                set(ui3DPanelSlider, ...
                    'position', [660 ...
                                 0 ...
                                 20 ...
                                 aMain3DPanelPosition(4) ...
                                 ]...
                   );                
            end
        end            
    end            
 
    uiProgressWindow = uiProgressWindowPtr('get');
    if ~isempty(uiProgressWindow)
        set(uiProgressWindow, ...
            'position', [0 ...
                         0 ...
                         getMainWindowSize('xsize') ...
                         30 ...
                         ]...
           );
    end 

    ptrColorbar = uiColorbarPtr('get');
    if ~isempty(ptrColorbar)  

        setColorbarPosition(ptrColorbar);
    end

    if isFusion('get') == true

        uiAlphaSlider = uiAlphaSliderPtr('get');
        if ~isempty(uiAlphaSlider) 

            setAlphaSliderPosition(uiAlphaSlider);
        end

        ptrFusionColorbar = uiFusionColorbarPtr('get');
        if ~isempty(ptrFusionColorbar) 

            setFusionColorbarPosition(ptrFusionColorbar);
        end
              
    end

%     btnExitViewer = btnExitViewerPtr('get');
%     if ~isempty(btnExitViewer)
% 
%         if ~isempty(uiTopWindowPtr('get'))
% 
%             aTopWindowBarPosition = get(uiTopWindowPtr('get'), 'Position');
% 
%             set(btnExitViewer, 'Position', [aTopWindowBarPosition(3)-70 6 65 25]);
%         end
%     end

end 
