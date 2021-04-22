function clearDisplay()
%function clearDisplay()
%Clear Viewer All Displays.
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
    
    ptrFusionColorbar = uiFusionColorbarPtr('get');
    if ~isempty(ptrFusionColorbar) 
        ptrFusionColorbar.Position = [0 0 0 0];                
        clear ptrFusionColorbar;
        uiFusionColorbarPtr('set' , '');
    end

    uiFusionSliderLevel = uiFusionSliderLevelPtr('get');
    if ~isempty(uiFusionSliderLevel) 
        uiFusionSliderLevel.Position = [0 0 0 0];
        clear uiFusionSliderLevel;               
        uiFusionSliderLevelPtr('set', '');
    end

    uiFusionSliderWindow = uiFusionSliderWindowPtr('get');
    if ~isempty(uiFusionSliderWindow) 
        uiFusionSliderWindow.Position = [0 0 0 0];
        clear uiFusionSliderWindow;               
        uiFusionSliderWindowPtr('set', '');
    end

    uiAlphaSlider = uiAlphaSliderPtr('get');
    if ~isempty(uiAlphaSlider) 
        uiAlphaSlider.Position = [0 0 0 0];
        clear uiAlphaSlider;               
        uiAlphaSliderPtr('set', '');
    end

    uiSliderWindow = uiSliderWindowPtr('get');
    if ~isempty(uiSliderWindow)
        uiSliderWindow.Position = [0 0 0 0];
        clear uiSliderWindow;                
        uiSliderWindowPtr('set', '');                
    end

    uiSliderLevel = uiSliderLevelPtr('get');
    if ~isempty(uiSliderLevel)
        uiSliderLevel.Position = [0 0 0 0];
        clear uiSliderLevel;               
        uiSliderLevelPtr('set', '');                
    end

    ptrColorbar = uiColorbarPtr('get');
    if ~isempty(ptrColorbar)                
        ptrColorbar.Position = [0 0 0 0];                
        clear ptrColorbar;
        uiColorbarPtr('set', '');
    end

    ui3DPanel = ui3DPanelPtr('get');
    if ~isempty(ui3DPanel)     
        delete(ui3DPanel);
        clear ui3DPanel;  
        ui3DPanelPtr('set', '');
    end

    uiMain3DPanel = uiMain3DPanelPtr('get');
    if ~isempty(uiMain3DPanel)     
        delete(uiMain3DPanel);
        clear uiMain3DPanel;   
        uiMain3DPanelPtr('set', '');
    end

    uiSegPanel = uiSegPanelPtr('get');
    if ~isempty(uiSegPanel)
        delete(uiSegPanel);            
        clear uiSegPanel;
        uiSegPanelPtr('set', '');
    end 

    uiSegMainPanel = uiSegMainPanelPtr('get');
    if ~isempty(uiSegMainPanel)
        delete(uiSegMainPanel);            
        clear uiSegMainPanel;
        uiSegMainPanelPtr('set', '');
    end 

    uiKernelPanel = uiKernelPanelPtr('get');
    if ~isempty(uiKernelPanel)
        delete(uiKernelPanel);            
        clear uiKernelPanel;
        uiKernelPanelPtr('set', '');
    end

    uiKernelMainPanel = uiKernelMainPanelPtr('get');
    if ~isempty(uiKernelMainPanel)
        delete(uiKernelMainPanel);            
        clear uiKernelMainPanel;
        uiKernelMainPanelPtr('set', '');
    end  
    
    uiRoiPanel = uiRoiPanelPtr('get');
    if ~isempty(uiRoiPanel)
        delete(uiRoiPanel);            
        clear uiRoiPanel;
        uiRoiPanelPtr('set', '');
    end

    uiRoiMainPanel = uiRoiMainPanelPtr('get');
    if ~isempty(uiRoiMainPanel)
        delete(uiRoiMainPanel);            
        clear uiRoiMainPanel;
        uiRoiMainPanelPtr('set', '');
    end 
    
    uiSliderCor = uiSliderCorPtr('get');
    if ~isempty(uiSliderCor)
        delete(uiSliderCor);
        clear uiSliderCor;   
        uiSliderCorPtr('set', '');
    end

    uiSliderSag = uiSliderSagPtr('get');
    if ~isempty(uiSliderSag)
        delete(uiSliderSag);
        clear uiSliderSag;           
        uiSliderSagPtr('set', '');
    end

    uiSliderTra = uiSliderTraPtr('get');
    if ~isempty(uiSliderTra)
        delete(uiSliderTra);
        clear uiSliderTra;           
        uiSliderTraPtr('set', '');
    end   

    txt = axesText('get', 'axe');
    if ~isempty(txt)
        delete(txt);
        clear txt;
        axesText('set', 'axe', '');
    end      
    
    txt1 = axesText('get', 'axes1');
    if ~isempty(txt1)
        delete(txt1);
        clear txt1;
        axesText('set', 'axes1', '');
    end    
    
    txt2 = axesText('get', 'axes2');
    if ~isempty(txt2)
        delete(txt2);
        clear txt2;
        axesText('set', 'axes2', '');
    end    
    
    txt3 = axesText('get', 'axes3');
    if ~isempty(txt3)
        delete(txt3);
        clear txt3;
        axesText('set', 'axes3', '');
    end    
    
    axef = axefPtr('get');
    if ~isempty(axef)
        delete(axef);
        clear axef;
        axefPtr('set', '');
    end

    axe = axePtr('get');
    if ~isempty(axe)
        axesText('set', 'axe', '');                
        delete(axe);
        clear axe;
        axePtr('set', '');
   end

    uiOneWindow = uiOneWindowPtr('get');
    if ~isempty(uiOneWindow)
       delete(uiOneWindow);
       clear uiOneWindow;
       uiOneWindowPtr('set', '');
    end

    axes1f = axes1fPtr('get');
    if ~isempty(axes1f)
        delete(axes1f);
        clear axes1f;
        axes1fPtr('set', '');
    end

    axes1 = axes1Ptr('get');
    if ~isempty(axes1)
        axesText('set', 'axes1', '');                
        delete(axes1);
        clear axes1;
        axes1Ptr('set', '');
    end

    uiCorWindow = uiCorWindowPtr('get');
    if ~isempty(uiCorWindow)
        delete(uiCorWindow);
        clear uiCorWindow;
        uiCorWindowPtr('set', '');
    end

    axes2f = axes2fPtr('get');
    if ~isempty(axes2f)
        delete(axes2f);
        clear axes2f;
        axes2fPtr('set', '');
    end

    axes2 = axes2Ptr('get');
    if ~isempty(axes2)
        axesText('set', 'axes2', '');                
        delete(axes2);
        clear axes2;
        axes2Ptr('set', '');
    end

    uiSagWindow = uiSagWindowPtr('get');
    if ~isempty(uiSagWindow)
        delete(uiSagWindow); 
        clear uiSagWindow;
        uiSagWindowPtr('set', '');
    end          

    axes3f = axes3fPtr('get');
    if ~isempty(axes3f)
        delete(axes3f);
        clear axes3f;
        axes3fPtr('set', '');
    end

    axes3 = axes3Ptr('get');
    if ~isempty(axes3)
        axesText('set', 'axes3', '');                
        delete(axes3);
        clear axes3;
        axes3Ptr('set', '');
    end       

    uiTraWindow = uiTraWindowPtr('get');
    if ~isempty(uiTraWindow)
        delete(uiTraWindow); 
        clear uiTraWindow;
        uiTraWindowPtr('set', '');
    end          
end                  
