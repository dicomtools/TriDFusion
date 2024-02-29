function oneFrame(sDirection)
%function oneFrame(sDirection)
%Display 2D Next or Previous Frame.
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

    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

    if size(dicomBuffer('get', [], dSeriesOffset), 3) == 1

        progressBar(1, 'Error: Require a 3D Volume!');               
        set(uiSeriesPtr('get'), 'Enable', 'on');
       return;
    end        

    pAxe = gca(fiMainWindowPtr('get'));

    % pAxe = getAxeFromMousePosition(dSeriesOffset);
    % 
    % if isempty(pAxe)
    %     return;
    % end

    windowButton('set', 'down');  

    if (pAxe == axes1Ptr('get', [], dSeriesOffset)  && playback2DMipOnly('get') == false) || ...
       (isVsplash('get') == true && strcmpi(vSplahView('get'), 'coronal'))
        
            dLastSlice = size(dicomBuffer('get', [], dSeriesOffset), 1);  
            dCurrentSlice = sliceNumber('get', 'coronal');
%             set(uiSliderCorPtr('get'), 'Value', iSlider);
            if strcmpi(sDirection, 'Foward')

                if dCurrentSlice < dLastSlice
                    dCurrentSlice = dCurrentSlice +1;
                end

                if dCurrentSlice == dLastSlice
                    dCurrentSlice = 1;
                end  
            else
                if dCurrentSlice > 1
                    dCurrentSlice = dCurrentSlice -1;
                else
                    dCurrentSlice = dLastSlice;
                end                              
            end

            sliceNumber('set', 'coronal', dCurrentSlice);
            
            set(uiSliderCorPtr('get'), 'Value', sliceNumber('get', 'coronal') / size(dicomBuffer('get'), 1));

    elseif (pAxe == axes2Ptr('get', [], dSeriesOffset)  && playback2DMipOnly('get') == false) || ...
           (isVsplash('get') == true && strcmpi(vSplahView('get'), 'sagittal'))
        
    
%              set(uiSliderSagPtr('get'), 'Value', iSlider);
            dLastSlice = size(dicomBuffer('get', [], dSeriesOffset), 2);    
            dCurrentSlice = sliceNumber('get', 'sagittal'); 

            if strcmpi(sDirection, 'Foward')
                if dCurrentSlice < dLastSlice
                    dCurrentSlice = dCurrentSlice +1;
                end

                if dCurrentSlice == dLastSlice
                    dCurrentSlice = 1;
                end  
            else
                if dCurrentSlice > 1
                    dCurrentSlice = dCurrentSlice -1;
                else
                    dCurrentSlice = dLastSlice;
                end                              
            end  

            sliceNumber('set', 'sagittal', dCurrentSlice);
            
            set(uiSliderSagPtr('get'), 'Value', sliceNumber('get', 'sagittal') / size(dicomBuffer('get'), 2));

    elseif (pAxe == axes3Ptr('get', [], dSeriesOffset)  && playback2DMipOnly('get') == false) || ...
           (isVsplash('get') == true && strcmpi(vSplahView('get'), 'axial'))
         
            dLastSlice = size(dicomBuffer('get', [], dSeriesOffset), 3);            
            dCurrentSlice = sliceNumber('get', 'axial');

             if strcmpi(sDirection, 'Foward')

                if dCurrentSlice > 1
                    dCurrentSlice = dCurrentSlice -1;
                else
                    dCurrentSlice = dLastSlice;
                end 
            else
                if dCurrentSlice < dLastSlice
                    dCurrentSlice = dCurrentSlice +1;
                else
                    dCurrentSlice = 1;
                end                              
            end     

            sliceNumber('set', 'axial', dCurrentSlice);

           set(uiSliderTraPtr('get'), 'Value', 1 - (sliceNumber('get', 'axial') / size(dicomBuffer('get'), 3)));                       

    else
        if isVsplash('get') == false
            
            iMipAngleValue = mipAngle('get');

            if strcmpi(sDirection, 'Foward')
                iMipAngleValue = iMipAngleValue+1;
            else
                iMipAngleValue = iMipAngleValue-1;
            end
            
            if iMipAngleValue <=0
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
        end
    end

    refreshImages();        
    
    windowButton('set', 'up');  

end  
