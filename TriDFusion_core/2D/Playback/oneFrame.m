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

    % pAxe = gca(fiMainWindowPtr('get'));

    % pAxe = getAxeFromMousePosition(dSeriesOffset);
    % 
    % if isempty(pAxe)
    %     return;
    % end

    % windowButton('set', 'down');  
        chkUiCorWindowSelected = chkUiCorWindowSelectedPtr('get');
        chkUiSagWindowSelected = chkUiSagWindowSelectedPtr('get');
        chkUiTraWindowSelected = chkUiTraWindowSelectedPtr('get');

    
    if get(chkUiCorWindowSelected, 'Value') == true || ...
       (isVsplash('get') == true && strcmpi(vSplahView('get'), 'coronal'))
    
        dLastSlice = size(dicomBuffer('get', [], dSeriesOffset), 1);  

        dCurrentSlice = sliceNumber('get', 'coronal');

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

        % sliceNumber('set', 'coronal', dCurrentSlice);
        
        set(uiSliderCorPtr('get'), 'Value', dCurrentSlice);

        sliderCorCallback();

    elseif get(chkUiSagWindowSelected, 'Value') == true || ...
           (isVsplash('get') == true && strcmpi(vSplahView('get'), 'sagittal'))
            
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

        % sliceNumber('set', 'sagittal', dCurrentSlice);
        
        set(uiSliderSagPtr('get'), 'Value', dCurrentSlice);

        sliderSagCallback();

    elseif get(chkUiTraWindowSelected, 'Value') == true || ...
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

        % sliceNumber('set', 'axial', dCurrentSlice);

        set(uiSliderTraPtr('get'), 'Value',  dLastSlice - dCurrentSlice +1);       

        sliderTraCallback();

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

            set(uiSliderMipPtr('get'), 'Value', iMipAngleValue);

            % plotRotatedRoiOnMip(axesMipPtr('get', [], dSeriesOffset), dicomBuffer('get', [], dSeriesOffset), iMipAngleValue);       
            sliderMipCallback();

        end
    end

    % refreshImages();        
    
    windowButton('set', 'up');  

end  
