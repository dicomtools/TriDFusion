function sliderAlphaCallback(~, ~)
%function sliderAlphaCallback(~, ~)
%Set Fusion Alpha Slider.
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

    if size(dicomBuffer('get'), 3) == 1
        
        alpha( imAxeFPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), get(uiAlphaSliderPtr('get'), 'Value') );
        alpha( imAxePtr('get', [], get(uiSeriesPtr('get'), 'Value')) , 1-get(uiAlphaSliderPtr('get'), 'Value') );
    else
        
        alpha( imCoronalFPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), get(uiAlphaSliderPtr('get'), 'Value') );
        alpha( imSagittalFPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), get(uiAlphaSliderPtr('get'), 'Value') );
        alpha( imAxialFPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), get(uiAlphaSliderPtr('get'), 'Value') );
        
        if link2DMip('get') == true && isVsplash('get') == false  
            
            axesMipf = imMipFPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));
            if ~isempty(axesMipf)
                alpha( axesMipf, get(uiAlphaSliderPtr('get'), 'Value') );                                
            end
        end 
        
        alpha( imCoronalPtr('get', [], get(uiSeriesPtr('get'), 'Value'))  , 1-get(uiAlphaSliderPtr('get'), 'Value') );
        alpha( imSagittalPtr('get', [], get(uiSeriesPtr('get'), 'Value'))  , 1-get(uiAlphaSliderPtr('get'), 'Value') );
        alpha( imAxialPtr('get', [], get(uiSeriesPtr('get'), 'Value'))  , 1-get(uiAlphaSliderPtr('get'), 'Value') );
        
        if link2DMip('get') == true && isVsplash('get') == false  
            alpha( imMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), 1-get(uiAlphaSliderPtr('get'), 'Value') );                                
        end 
        
%         if isPlotContours('get') == true && isVsplash('get') == false 
            
%             alpha( imCoronalFcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))  , 1-get(uiAlphaSliderPtr('get'), 'Value') );
%             alpha( imSagittalFcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))  , 1-get(uiAlphaSliderPtr('get'), 'Value') );
%             alpha( imAxialFcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))  , 1-get(uiAlphaSliderPtr('get'), 'Value') );
%             
%             if link2DMip('get') == true && isVsplash('get') == false  
%                 axesMipfc = imMipFcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));
%                 if ~isempty(axesMipfc)
%                     alpha( axesMipfc, 1-get(uiAlphaSliderPtr('get'), 'Value') );                                
%                 end
%             end 
%         end
        
    end            

    sliderAlphaValue('set', get(uiAlphaSliderPtr('get'), 'Value') );
    
    setFusionColorbarLabel();

    if viewerUIFigure('get') == true
        drawnow;
    end

end