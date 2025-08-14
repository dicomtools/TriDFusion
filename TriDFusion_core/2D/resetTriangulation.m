function resetTriangulation(aOriginalImage, dOriginalCoronal, dOriginalSagittal, dOriginalAxial)
%function resetTriangulation(aOriginalImage, dOriginalCoronal, dOriginalSagittal, dOriginalAxial)
%Set Coronal Slider.
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
    
    aBuffer = dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value'));

    if isempty(aBuffer) || size(aBuffer, 3) == 1
        return;
    end

    aImageSize = size(aBuffer);
    aOriginalImageSize = size(aOriginalImage);

    % Ratio
    dCorRatio = aImageSize(1) / aOriginalImageSize(1);
    dSagRatio = aImageSize(2) / aOriginalImageSize(2);
    dTraRatio = aImageSize(3) / aOriginalImageSize(3);

    % Updated location
    dCoronal  = round(dOriginalCoronal  * dCorRatio);
    dSagittal = round(dOriginalSagittal * dSagRatio);
    dAxial    = round(dOriginalAxial    * dTraRatio);

    if dCoronal  > aImageSize(1)
         dCoronal = round(aImageSize(1)/2);
    end

    if dSagittal  > aImageSize(2)
         dSagittal = round(aImageSize(2)/2);
    end
    
    if dAxial  > aImageSize(3)
         dAxial = round(aImageSize(3)/2);
    end

    sliceNumber('set', 'coronal' , dCoronal);
    sliceNumber('set', 'sagittal', dSagittal);
    sliceNumber('set', 'axial'   , dAxial);

    hCorSlider = uiSliderCorPtr('get');
    hSagSlider = uiSliderSagPtr('get');
    hTraSlider = uiSliderTraPtr('get');
   
    set(hCorSlider, 'Value', dCoronal);
    set(hSagSlider, 'Value', dSagittal);
    set(hTraSlider, 'Value', dAxial);

    refreshImages();

    drawnow;

    clear aBuffer;

end