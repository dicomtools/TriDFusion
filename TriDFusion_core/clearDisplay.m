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

    % arrayfun(@cla,findall(fiMainWindowPtr('get'),'type','axes'))
  
    ptrFusionColorbar = uiFusionColorbarPtr('get');
    if ~isempty(ptrFusionColorbar) 
        if isvalid(ptrFusionColorbar)
            delete(ptrFusionColorbar);
        end
%        ptrFusionColorbar.Position = [0 0 0 0];                
        clear ptrFusionColorbar;
        uiFusionColorbarPtr('set' , []);
    end

%     uiFusionSliderLevel = uiFusionSliderLevelPtr('get');
%     if ~isempty(uiFusionSliderLevel) 
%         if isvalid(uiFusionSliderLevel)
%             delete(uiFusionSliderLevel);
%         end        
% %        uiFusionSliderLevel.Position = [0 0 0 0];
%         clear uiFusionSliderLevel;               
%         uiFusionSliderLevelPtr('set', []);
%     end
% 
%     uiFusionSliderWindow = uiFusionSliderWindowPtr('get');
%     if ~isempty(uiFusionSliderWindow) 
%         if isvalid(uiFusionSliderWindow)
%             delete(uiFusionSliderWindow);
%         end            
% %        uiFusionSliderWindow.Position = [0 0 0 0];
%         clear uiFusionSliderWindow;               
%         uiFusionSliderWindowPtr('set', []);
%     end

    uiAlphaSlider = uiAlphaSliderPtr('get');
    if ~isempty(uiAlphaSlider) 
        if isvalid(uiAlphaSlider)
            delete(uiAlphaSlider);
        end          
%        uiAlphaSlider.Position = [0 0 0 0];
        clear uiAlphaSlider;               
        uiAlphaSliderPtr('set', []);
    end

%     uiSliderWindow = uiSliderWindowPtr('get');
%     if ~isempty(uiSliderWindow)
%         uiSliderWindow.Position = [0 0 0 0];
%         clear uiSliderWindow;                
%         uiSliderWindowPtr('set', []);                
%     end
% 
%     uiSliderLevel = uiSliderLevelPtr('get');
%     if ~isempty(uiSliderLevel)
%         uiSliderLevel.Position = [0 0 0 0];
%         clear uiSliderLevel;               
%         uiSliderLevelPtr('set', []);                
%     end

    ptrColorbar = uiColorbarPtr('get');
    if ~isempty(ptrColorbar)  
        if isvalid(ptrColorbar)
            delete(ptrColorbar);
        end        
        % ptrColorbar.Position = [0 0 0 0];                
        clear ptrColorbar;
        uiColorbarPtr('set', []);
    end

    % New intensity line on colorbar 

    lineColorbarIntensityMax = lineColorbarIntensityMaxPtr('get');
    if ~isempty(lineColorbarIntensityMax)                
        clear lineColorbarIntensityMax;
        lineColorbarIntensityMaxPtr('set', []);
    end

    lineColorbarIntensityMin = lineColorbarIntensityMinPtr('get');
    if ~isempty(lineColorbarIntensityMin)                
        clear lineColorbarIntensityMin;
        lineColorbarIntensityMinPtr('set', []);
    end

    textColorbarIntensityMax = textColorbarIntensityMaxPtr('get');
    if ~isempty(textColorbarIntensityMax)                
        clear textColorbarIntensityMax;
        textColorbarIntensityMaxPtr('set', []);
    end

    textColorbarIntensityMin = textColorbarIntensityMinPtr('get');
    if ~isempty(textColorbarIntensityMin)                
        clear textColorbarIntensityMin;
        textColorbarIntensityMinPtr('set', []);
    end

    axeColorbar = axeColorbarPtr('get');
    if ~isempty(axeColorbar)                
        clear axeColorbar;
        axeColorbarPtr('set', []);
    end

    % New intensity line fusion on colorbar 

    lineFusionColorbarIntensityMax = lineFusionColorbarIntensityMaxPtr('get');
    if ~isempty(lineFusionColorbarIntensityMax)                
        clear lineFusionColorbarIntensityMax;
        lineFusionColorbarIntensityMaxPtr('set', []);
    end

    lineFusionColorbarIntensityMin = lineFusionColorbarIntensityMinPtr('get');
    if ~isempty(lineFusionColorbarIntensityMin)                
        clear lineFusionColorbarIntensityMin;
        lineFusionColorbarIntensityMinPtr('set', []);
    end

    textFusionColorbarIntensityMax = textFusionColorbarIntensityMaxPtr('get');
    if ~isempty(textFusionColorbarIntensityMax)                
        clear textFusionColorbarIntensityMax;
        textFusionColorbarIntensityMaxPtr('set', []);
    end

    textFusionColorbarIntensityMin = textFusionColorbarIntensityMinPtr('get');
    if ~isempty(textFusionColorbarIntensityMin)                
        clear textFusionColorbarIntensityMin;
        textFusionColorbarIntensityMinPtr('set', []);
    end

    axeFusionColorbar = axeFusionColorbarPtr('get');
    if ~isempty(axeFusionColorbar)                
        clear axeFusionColorbar;
        axeFusionColorbarPtr('set', []);
    end

    btnUiCorWindowFullScreen = btnUiCorWindowFullScreenPtr('get');
    if ~isempty(btnUiCorWindowFullScreen)                
        clear btnUiCorWindowFullScreen;
        btnUiCorWindowFullScreenPtr('set', []);
    end

    btnUiSagWindowFullScreen = btnUiSagWindowFullScreenPtr('get');
    if ~isempty(btnUiSagWindowFullScreen)                
        clear btnUiSagWindowFullScreen;
        btnUiSagWindowFullScreenPtr('set', []);
    end

    btnUiTraWindowFullScreen = btnUiTraWindowFullScreenPtr('get');
    if ~isempty(btnUiTraWindowFullScreen)                
        clear btnUiTraWindowFullScreen;
        btnUiTraWindowFullScreenPtr('set', []);
    end

    btnUiMipWindowFullScreen = btnUiMipWindowFullScreenPtr('get');
    if ~isempty(btnUiMipWindowFullScreen)                
        clear btnUiMipWindowFullScreen;
        btnUiMipWindowFullScreenPtr('set', []);
    end

    chkUiCorWindowSelected = chkUiCorWindowSelectedPtr('get');
    if ~isempty(chkUiCorWindowSelected)                
        clear chkUiCorWindowSelected;
        chkUiCorWindowSelectedPtr('set', []);
    end

    chkUiSagWindowSelected = chkUiSagWindowSelectedPtr('get');
    if ~isempty(chkUiSagWindowSelected)                
        clear chkUiSagWindowSelected;
        chkUiSagWindowSelectedPtr('set', []);
    end

    chkUiTraWindowSelected = chkUiTraWindowSelectedPtr('get');
    if ~isempty(chkUiTraWindowSelected)                
        clear chkUiTraWindowSelected;
        chkUiTraWindowSelectedPtr('set', []);
    end

    chkUiMipWindowSelected = chkUiMipWindowSelectedPtr('get');
    if ~isempty(chkUiMipWindowSelected)                
        clear chkUiMipWindowSelected;
        chkUiMipWindowSelectedPtr('set', []);
    end

    ui3DPanel = ui3DPanelPtr('get');
    if ~isempty(ui3DPanel)     
        delete(ui3DPanel);
        clear ui3DPanel;  
        ui3DPanelPtr('set', []);
    end

    uiMain3DPanel = uiMain3DPanelPtr('get');
    if ~isempty(uiMain3DPanel)     
        delete(uiMain3DPanel);
        clear uiMain3DPanel;   
        uiMain3DPanelPtr('set', []);
    end

    uiSegPanel = uiSegPanelPtr('get');
    if ~isempty(uiSegPanel)
        delete(uiSegPanel);            
        clear uiSegPanel;
        uiSegPanelPtr('set', []);
    end 

    uiSegMainPanel = uiSegMainPanelPtr('get');
    if ~isempty(uiSegMainPanel)
        delete(uiSegMainPanel);            
        clear uiSegMainPanel;
        uiSegMainPanelPtr('set', []);
    end 

    uiKernelPanel = uiKernelPanelPtr('get');
    if ~isempty(uiKernelPanel)
        delete(uiKernelPanel);            
        clear uiKernelPanel;
        uiKernelPanelPtr('set', []);
    end

    uiKernelMainPanel = uiKernelMainPanelPtr('get');
    if ~isempty(uiKernelMainPanel)
        delete(uiKernelMainPanel);            
        clear uiKernelMainPanel;
        uiKernelMainPanelPtr('set', []);
    end  
    
    uiRoiPanel = uiRoiPanelPtr('get');
    if ~isempty(uiRoiPanel)
        delete(uiRoiPanel);            
        clear uiRoiPanel;
        uiRoiPanelPtr('set', []);
    end

    uiRoiMainPanel = uiRoiMainPanelPtr('get');
    if ~isempty(uiRoiMainPanel)
        delete(uiRoiMainPanel);            
        clear uiRoiMainPanel;
        uiRoiMainPanelPtr('set', []);
    end 
    
    uiSliderCor = uiSliderCorPtr('get');
    if ~isempty(uiSliderCor)
        delete(uiSliderCor);
        clear uiSliderCor;   
        uiSliderCorPtr('set', []);
    end

    uiSliderSag = uiSliderSagPtr('get');
    if ~isempty(uiSliderSag)
        delete(uiSliderSag);
        clear uiSliderSag;           
        uiSliderSagPtr('set', []);
    end

    uiSliderTra = uiSliderTraPtr('get');
    if ~isempty(uiSliderTra)
        delete(uiSliderTra);
        clear uiSliderTra;           
        uiSliderTraPtr('set', []);
    end   
    
    uiSliderMip = uiSliderMipPtr('get');
    if ~isempty(uiSliderMip)
        delete(uiSliderMip);
        clear uiSliderMip;           
        uiSliderMipPtr('set', []);
    end   
    
    axesText('reset', 'axe');
    axesText('reset', 'axes1');
    axesText('reset', 'axes2');
    axesText('reset', 'axes3');
    axesText('reset', 'axeMip');
    
    axesText('reset', 'axef');
    axesText('reset', 'axes1f');
    axesText('reset', 'axes2f');
    axesText('reset', 'axes3f');
    axesText('reset', 'axeMipf');
    
    axesText('reset', 'axeView');
    axesText('reset', 'axes1View');
    axesText('reset', 'axes2View');
    axesText('reset', 'axes3View');
    axesText('reset', 'axeMipView');
         
    imAxePtr  ('reset');    
    imAxeFcPtr('reset');  
    imAxeFPtr ('reset');  
  
    axefPtr ('reset');
    axefcPtr('reset');
 %   axerPtr ('reset');
    axePtr  ('reset');
    
    uiOneWindow = uiOneWindowPtr('get');
    if ~isempty(uiOneWindow)
       delete(uiOneWindow);
       clear uiOneWindow;
       uiOneWindowPtr('set', []);
    end
    
    imCoronalPtr  ('reset');                
    imCoronalFcPtr('reset');                
    imCoronalFPtr ('reset');                
        
    axes1fPtr ('reset');
    axes1fcPtr('reset');
%    axes1rPtr ('reset');
    axes1Ptr  ('reset');
        
    uiCorWindow = uiCorWindowPtr('get');
    if ~isempty(uiCorWindow)
        delete(uiCorWindow);
        clear uiCorWindow;
        uiCorWindowPtr('set', []);
    end
    
    imSagittalPtr  ('reset');                
    imSagittalFcPtr('reset');                
    imSagittalFPtr ('reset');                
        
    axes2fPtr ('reset');
    axes2fcPtr('reset');
%    axes2rPtr ('reset');  
    axes2Ptr  ('reset');  
    
    uiSagWindow = uiSagWindowPtr('get');
    if ~isempty(uiSagWindow)
        delete(uiSagWindow); 
        clear uiSagWindow;
        uiSagWindowPtr('set', []);
    end              
    
    imAxialPtr  ('reset'); 
    imAxialFcPtr('reset'); 
    imAxialFPtr ('reset'); 
        
    axes3fPtr ('reset');
    axes3fcPtr('reset');
%    axes3rPtr ('reset');            
    axes3Ptr  ('reset');            
    
    axesColorbarPtr('reset');        
    axesFusionColorbarPtr('reset');    

    uiTraWindow = uiTraWindowPtr('get');
    if ~isempty(uiTraWindow)
        delete(uiTraWindow); 
        clear uiTraWindow;
        uiTraWindowPtr('set', []);
    end

    ptrPlot = plotMipPtr('get');
    if ~isempty(ptrPlot)
        for pp=1:numel(ptrPlot)
            delete(ptrPlot{pp});
        end
        plotMipPtr('set', []);    
    end

    imMipPtr  ('reset');    
    imMipFcPtr('reset');    
    imMipFPtr ('reset');    
   
    axesMipfPtr ('reset');
    axesMipfcPtr('reset');
    axesMipPtr  ('reset'); 
    
    uiMipWindow = uiMipWindowPtr('get');
    if ~isempty(uiMipWindow)
        delete(uiMipWindow); 
        clear uiMipWindow;
        uiMipWindowPtr('set', []);
    end    

end                  
