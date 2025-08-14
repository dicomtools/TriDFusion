function computeMIPCallback(~, ~)
%function computeMIPCallback(hObject,~)
%Compute 2D MIP from current dicom image.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2023, Daniel Lafontaine, on behalf of the TriDFusion development team.
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


    im = dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value'));

    if isempty(im)
        return;
    end

    if size(im,3) == 1
         return;
    end

    try

    set(fiMainWindowPtr('get'), 'Pointer', 'watch');
    drawnow;

    mipBuffer('set', computeMIP(gather(im)), get(uiSeriesPtr('get'), 'Value'));

    clear im;

    if isFusion('get') == true

        imf = fusionBuffer('get', [], get(uiFusedSeriesPtr('get'), 'Value'));
        mipFusionBuffer('set', computeMIP(gather(imf)), get(uiFusedSeriesPtr('get'), 'Value'));

        clear imf;
    end

    if isVsplash('get') == false &&  ...
       switchToMIPMode('get') == false && ...
       switchToIsoSurface('get') == false && ...
       switchTo3DMode('get')    == false

        sliderMipCallback();
    end


    catch ME
        logErrorToFile(ME);
        progressBar(1, 'Error:compute2DMIPCallback()');
    end

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow;

    clear im;
end
