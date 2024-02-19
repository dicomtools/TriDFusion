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
            dSeriesOffset = get(uiSeriesPtr('get'), 'Value');
            aImageSize = size(dicomBuffer('get', [], dSeriesOffset));

            gca = getAxeFromMousePosition(dSeriesOffset);

            switch gca

                case axes1Ptr('get', [], dSeriesOffset)

                    if evnt.VerticalScrollCount > 0

                        if sliceNumber('get', 'coronal') > 1

                            sliceNumber('set', 'coronal', ...
                            sliceNumber('get', 'coronal')-1);
                        end
                    else
                        if sliceNumber('get', 'coronal') < aImageSize(1)

                            sliceNumber('set', 'coronal', ...
                            sliceNumber('get', 'coronal')+1);
                        end
                    end

                    set(uiSliderCorPtr('get'), 'Value', sliceNumber('get', 'coronal') / aImageSize(1));

                case axes2Ptr('get', [], dSeriesOffset)

                    if evnt.VerticalScrollCount > 0

                         if sliceNumber('get', 'sagittal') > 1

                             sliceNumber('set', 'sagittal', ...
                             sliceNumber('get', 'sagittal')-1);
                         end
                    else
                         if sliceNumber('get', 'sagittal') < aImageSize(2)
                             
                             sliceNumber('set', 'sagittal', ...
                             sliceNumber('get', 'sagittal')+1);
                         end
                    end

                    set(uiSliderSagPtr('get'), 'Value', sliceNumber('get', 'sagittal') / aImageSize(2));

                case axes3Ptr('get', [], dSeriesOffset)

                    if evnt.VerticalScrollCount > 0

                        if sliceNumber('get', 'axial') < aImageSize(3)
                             sliceNumber('set', 'axial', ...
                             sliceNumber('get', 'axial')+1);
                        end
                    else
                        if sliceNumber('get', 'axial') > 1
                             sliceNumber('set', 'axial', ...
                             sliceNumber('get', 'axial')-1);
                         end
                    end

                    set(uiSliderTraPtr('get'), 'Value', 1 - (sliceNumber('get', 'axial') / aImageSize(3)));
                    
                case axesMipPtr('get', [], dSeriesOffset)
                                        
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

    elseif size(dicomBuffer('get'), 3) == 1 && size(dicomBuffer('get'), 4) ~=1 % Screen capture

        if evnt.VerticalScrollCount > 0 
            screenCaptureFrame('Previous');
        else
            screenCaptureFrame('Next');
        end

    else      

        updateObjet3DPosition();              
    end

    windowButton('set', 'up');  

end

