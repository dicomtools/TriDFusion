function wheelScroll(~, evnt)        
%function  wheelScroll(~, evnt)
%Mouse Scroll Action.
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

    windowButton('set', 'scrool');  

    if size(dicomBuffer('get'), 3) ~= 1 && ...
       switchTo3DMode('get')      == false && ...
       switchToIsoSurface('get')  == false && ...
       switchToMIPMode('get')     == false

        mGate = gateIconMenuObject('get');
        if strcmpi(get(mGate, 'State'), 'on')
            if evnt.VerticalScrollCount > 0                       
                oneGate('Backward');                                              
            else
                oneGate('Foward');                                              
            end

        else

            % Get the current point
            current_point = get(gcf, 'CurrentPoint');
            mouseX = current_point(1, 1);
            mouseY = current_point(1, 2);
            
            posCor = getpixelposition(uiCorWindowPtr('get', get(uiSeriesPtr('get'), 'Value')));
            posSag = getpixelposition(uiSagWindowPtr('get', get(uiSeriesPtr('get'), 'Value')));
            posTra = getpixelposition(uiTraWindowPtr('get', get(uiSeriesPtr('get'), 'Value')));


            if mouseX > posCor(1) && mouseX < (posCor(1)+posCor(3)) && ... % Coronal
               mouseY > posCor(2) && mouseY < (posCor(2)+posCor(4))     
                gca = axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value'));

            elseif  mouseX > posSag(1) && mouseX < (posSag(1)+posSag(3)) && ... % Sagittal
                    mouseY > posSag(2) && mouseY < (posSag(2)+posSag(4))     
                gca = axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value'));

            elseif  mouseX > posTra(1) && mouseX < (posTra(1)+posTra(3)) && ... % Axial
                    mouseY > posTra(2) && mouseY < (posTra(2)+posTra(4))    
                gca = axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value'));

            else
                gca = axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')); % MIP
            end


            switch gca
                case axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
                    if evnt.VerticalScrollCount > 0
                        if sliceNumber('get', 'coronal') > 1
                            sliceNumber('set', 'coronal', ...
                            sliceNumber('get', 'coronal')-1);
                        end
                    else
                        if sliceNumber('get', 'coronal') < size(dicomBuffer('get'), 1)
                            sliceNumber('set', 'coronal', ...
                            sliceNumber('get', 'coronal')+1);
                        end
                    end

                    set(uiSliderCorPtr('get'), 'Value', sliceNumber('get', 'coronal') / size(dicomBuffer('get'), 1));

                case axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
                    if evnt.VerticalScrollCount > 0
                         if sliceNumber('get', 'sagittal') > 1
                             sliceNumber('set', 'sagittal', ...
                             sliceNumber('get', 'sagittal')-1);
                         end
                    else
                         if sliceNumber('get', 'sagittal') < size(dicomBuffer('get'), 2)
                             sliceNumber('set', 'sagittal', ...
                             sliceNumber('get', 'sagittal')+1);
                         end
                    end

                    set(uiSliderSagPtr('get'), 'Value', sliceNumber('get', 'sagittal') / size(dicomBuffer('get'), 2));

                case axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))

                    if evnt.VerticalScrollCount > 0

                        if sliceNumber('get', 'axial') < size(dicomBuffer('get'), 3)
                             sliceNumber('set', 'axial', ...
                             sliceNumber('get', 'axial')+1);
                        end
                    else
                        if sliceNumber('get', 'axial') > 1
                             sliceNumber('set', 'axial', ...
                             sliceNumber('get', 'axial')-1);
                         end
                    end

                    set(uiSliderTraPtr('get'), 'Value', 1 - (sliceNumber('get', 'axial') / size(dicomBuffer('get'), 3)));
                    
                case axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value'))
                                        
                    iMipAngleValue = mipAngle('get');
                    
                    if evnt.VerticalScrollCount > 0
                        iMipAngleValue = iMipAngleValue-1;
                    else
                        iMipAngleValue = iMipAngleValue+1;
                    end

                    if iMipAngleValue <= 0
                        iMipAngleValue = 32;
                    end
                    
                    if iMipAngleValue > 32
                        iMipAngleValue = 1;
                    end    
                    
                    mipAngle('set', iMipAngleValue);                    
                    
                    if iMipAngleValue == 1
                        dMipSliderValue = 0;
                    else
                        dMipSliderValue = mipAngle('get')/32;
                    end
                    
                    set(uiSliderMipPtr('get'), 'Value', dMipSliderValue);
                    
                otherwise

            end
        end
        
        refreshImages();       
        
    else
        updateObjet3DPosition();              
    end

    windowButton('set', 'up');  

end

