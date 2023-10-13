function setViewSegPanel(~, ~)
%function setViewSegPanel(~, ~)   
%Set 2D Segmentation Panel.
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

    hObject = viewSegPanelMenuObject('get');            

    if switchTo3DMode('get')     == false && ...
       switchToIsoSurface('get') == false && ...
       switchToMIPMode('get')    == false        

        releaseRoiWait();

        if strcmp(hObject.Checked, 'on')

            viewSegPanel('set', false);

            hObject.Checked = 'off';

            uiSegMainPanel = uiSegMainPanelPtr('get');
            if ~isempty(uiSegMainPanel)

                uiSegMainPanel.Visible = 'off';                       


                uiOneWindow = uiOneWindowPtr('get');
                if ~isempty(uiOneWindow)
                    set(uiOneWindow, ...
                        'position', [0,...
                                     addOnWidth('get')+30 ...
                                     getMainWindowSize('xsize') ...
                                     getMainWindowSize('ysize')-getTopWindowSize('ysize')-addOnWidth('get')-30 ...
                                     ]...
                        );                                                     
                end

                uiCorWindow = uiCorWindowPtr('get');
                if ~isempty(uiCorWindow)

                    setCorWindowPosition(uiCorWindow);
                end    

                uiSliderCor = uiSliderCorPtr('get');
                if ~isempty(uiSliderCor)    

                    setCorSliderPosition(uiSliderCor);
                end     

                uiSagWindow = uiSagWindowPtr('get');
                if ~isempty(uiSagWindow)

                    setSagWindowPosition(uiSagWindow);
                end   

                uiSliderSag = uiSliderSagPtr('get');
                if ~isempty(uiSliderSag)    

                    setSagSliderPosition(uiSliderSag);     
                end

                uiTraWindow = uiTraWindowPtr('get');
                if ~isempty(uiTraWindow)

                    setTraWindowPosition(uiTraWindow);
                end  

                uiSliderTra = uiSliderTraPtr('get');
                if ~isempty(uiSliderTra) 

                    setTraSliderPosition(uiSliderTra);
                end
                
                uiMipWindow = uiMipWindowPtr('get');
                if ~isempty(uiTraWindow)

                    setMipWindowPosition(uiMipWindow);
                end 

                uiSliderMip = uiSliderMipPtr('get');
                if ~isempty(uiSliderMip)  

                    setMipSliderPosition(uiSliderMip);        
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
            end 
        else
            uiKernelMainPanel = uiKernelMainPanelPtr('get');
            if ~isempty(uiKernelMainPanel)
                uiKernelMainPanel.Visible = 'off'; 
            end

            objKernelPanel = viewKernelPanelMenuObject('get');
            if ~isempty(objKernelPanel)
                objKernelPanel.Checked = 'off';
            end  
            
            uiRoiMainPanel = uiRoiMainPanelPtr('get');
             if ~isempty(uiRoiMainPanel)
                uiRoiMainPanel.Visible = 'off'; 
            end

            objRoiPanel = viewRoiPanelMenuObject('get');
            if ~isempty(objRoiPanel)
                objRoiPanel.Checked = 'off';
            end  
            
            viewRoiPanel   ('set', false);            
            viewKernelPanel('set', false);           
            viewSegPanel   ('set', true);

            hObject.Checked = 'on';

            uiSegMainPanel = uiSegMainPanelPtr('get');
            if ~isempty(uiSegMainPanel)
                uiSegMainPanel.Visible = 'on'; 

                uiOneWindow = uiOneWindowPtr('get');
                if ~isempty(uiOneWindow)
                    set(uiOneWindow, ...
                        'position', [uiSegMainPanel.Position(3)...
                                     addOnWidth('get')+30 ...
                                     getMainWindowSize('xsize')-uiSegMainPanel.Position(3) ...
                                     getMainWindowSize('ysize')-getTopWindowSize('ysize')-addOnWidth('get')-30 ...
                                     ]...
                        );                                                     
                end

                uiCorWindow = uiCorWindowPtr('get');
                if ~isempty(uiCorWindow)

                    setCorWindowPosition(uiCorWindow);
                end   

                uiSliderCor = uiSliderCorPtr('get');
                if ~isempty(uiSliderCor)      

                    setCorSliderPosition(uiSliderCor);
                end    

                uiSagWindow = uiSagWindowPtr('get');
                if ~isempty(uiSagWindow)

                    setSagWindowPosition(uiSagWindow);
                end  

                uiSliderSag = uiSliderSagPtr('get');
                if ~isempty(uiSliderSag)  

                    setSagSliderPosition(uiSliderSag);     
                end

                uiTraWindow = uiTraWindowPtr('get');
                if ~isempty(uiTraWindow)

                    setTraWindowPosition(uiTraWindow);
                end  

                uiSliderTra = uiSliderTraPtr('get');
                if ~isempty(uiSliderTra) 

                    setTraSliderPosition(uiSliderTra);  
                end  
                
                uiMipWindow = uiMipWindowPtr('get');
                if ~isempty(uiTraWindow)

                    setMipWindowPosition(uiMipWindow);
                end 

                uiSliderMip = uiSliderMipPtr('get');
                if ~isempty(uiSliderMip) 

                    setMipSliderPosition(uiSliderMip);        
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
            end                    
        end                
    end
end
