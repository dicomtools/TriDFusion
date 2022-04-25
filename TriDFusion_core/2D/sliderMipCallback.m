function sliderMipCallback(~, ~)
%function sliderMipCallback(~, ~)
%Set MIP Slider.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2021, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    if get(uiSliderMipPtr('get'), 'Value') >= 0 && ...
       get(uiSliderMipPtr('get'), 'Value') <= 1 && ...       
       strcmpi(windowButton('get'), 'up')         
        
        if get(uiSliderMipPtr('get'), 'Value') == 1 
            iMipAngle = 32;
        elseif get(uiSliderMipPtr('get'), 'Value') == 0
            iMipAngle = 1;
        else
            iMipAngle = round(get(uiSliderMipPtr('get'), 'Value') * 32);
            if iMipAngle == 0
                iMipAngle = 1;
            end
        end        
     
        mipAngle('set', iMipAngle);
        
        imComputedMip = mipBuffer('get', [], get(uiSeriesPtr('get'), 'Value'));
        imMip = imMipPtr ('get', [], get(uiSeriesPtr('get'), 'Value'));        
        imMip.CData = permute(imComputedMip(iMipAngle,:,:), [3 2 1]);
        
        dNbFusedSeries = numel(get(uiFusedSeriesPtr('get'), 'String'));
        for rr=1:dNbFusedSeries

           imMf = mipFusionBuffer('get', [], rr);                  

           if ~isempty(imMf)
                imMipF = imMipFPtr('get', [], rr);        
                if ~isempty(imMipF)

                    imMipF.CData = permute(imMf(iMipAngle,:,:), [3 2 1]); 
                end

           end
        end
        
        if overlayActivate('get') == true 
            
            sAxeMipText = sprintf('\n%d/32', iMipAngle);                  
 
            tAxesMipText = axesText('get', 'axesMip');                                      
            tAxesMipText.String = sAxeMipText;
            tAxesMipText.Color  = overlayColor('get');             

            if      iMipAngle < 5
                sMipAngleView = 'Left';
            elseif iMipAngle > 4 && iMipAngle < 13  
                sMipAngleView = 'Posterior';
            elseif iMipAngle > 12 && iMipAngle < 21  
                sMipAngleView = 'Right';
            elseif iMipAngle > 20 && iMipAngle < 29  
                sMipAngleView = 'Anterior';
            else
                sMipAngleView = 'Left';
            end 
            
            tAxesMipViewText = axesText('get', 'axesMipView');                                      
            tAxesMipViewText.String = sMipAngleView;
            tAxesMipViewText.Color  = overlayColor('get');              
        end        
                
    end
end