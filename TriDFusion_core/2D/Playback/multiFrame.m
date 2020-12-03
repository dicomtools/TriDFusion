function multiFrame(mPlay)
%function recordMultiFrame(mRecord, sPath, sFileName, sExtention)
%Play 2D Frames.
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
        progressBar(1, 'Error: Require a 3D Volume');  
        multiFramePlayback('set', false);                
        mPlay.State = 'off';
        return;
    end   

    while multiFramePlayback('get')                       

        if gca == axes1Ptr('get') || ...
           (isVsplash('get') == true && ...
            strcmpi(vSplahView('get'), 'coronal'))

            iLastSlice = size(dicomBuffer('get'), 1);  
            iCurrentSlice = sliceNumber('get', 'coronal');
%             set(uiSliderCorPtr('get'), 'Value', iSlider);
            if iCurrentSlice < iLastSlice
                iCurrentSlice = iCurrentSlice +1;
            else
                iCurrentSlice = 1;
            end  

            sliceNumber('set', 'coronal', iCurrentSlice);

        elseif gca == axes2Ptr('get') || ...
           (isVsplash('get') == true && ...
            strcmpi(vSplahView('get'), 'sagittal'))
%              set(uiSliderSagPtr('get'), 'Value', iSlider);
            iLastSlice = size(dicomBuffer('get'), 2);    
            iCurrentSlice = sliceNumber('get', 'sagittal'); 

            if iCurrentSlice < iLastSlice
                iCurrentSlice = iCurrentSlice +1;
            else
                iCurrentSlice = 1;
            end   

            sliceNumber('set', 'sagittal', iCurrentSlice);

        else
            iLastSlice = size(dicomBuffer('get'), 3);            
            iCurrentSlice = sliceNumber('get', 'axial');

            if iCurrentSlice >= 1
                iCurrentSlice = iCurrentSlice -1;
            end        

            if iCurrentSlice == 0
                iCurrentSlice = iLastSlice;
            end    

            sliceNumber('set', 'axial', iCurrentSlice);

   %         iSlider = iCurrentSlice/iLastSlice; 

   %         set(uiSliderTraPtr('get'), 'Value', iSlider);

        end

        refreshImages();                        

        pause(multiFrameSpeed('get'));

    end

end
