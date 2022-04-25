function cropInsideCallback(hObject,~)
%function cropInsideCallback(hObject,~)
%Crop Inside One Slice.
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

    im = dicomBuffer('get');
    if isempty(im)
        return;
    end

    if switchTo3DMode('get')     == true ||  ...
       switchToIsoSurface('get') == true || ...
       switchToMIPMode('get')    == true

        return;
    end

    try

    set(fiMainWindowPtr('get'), 'Pointer', 'watch');
    drawnow;

    if size(im, 3) == 1
        axe = axePtr('get', [], get(uiSeriesPtr('get'), 'Value'));
        if ~isempty(axe)
            if gca == axe
                
             im = cropInside(hObject.UserData, ...
                            im, ...
                            [], ...
                            'Axe' ...
                            ); 
            end
        end
    else
        if ~isempty(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))) && ...
           ~isempty(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))) && ...
           ~isempty(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')))

            if gca == axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
                
                im = cropInside(hObject.UserData, ...
                                im, ...
                                sliceNumber('get', 'coronal'), ...
                                'Axes1' ...
                                );   
            end

            if gca == axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
                
                 im = cropInside(hObject.UserData, ...
                                im, ...
                                sliceNumber('get', 'sagittal'), ...
                                'Axes2' ...
                                );   
            end

            if gca == axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
                
                 im = cropInside(hObject.UserData, ...
                                im, ...
                                sliceNumber('get', 'axial'), ...
                                'Axes3' ...
                                );  
            end
        end
    end
    
    dicomBuffer('set', im);

    iOffset = get(uiSeriesPtr('get'), 'Value');
    setQuantification(iOffset);

    refreshImages();

    catch
        progressBar(1, 'Error:cropInsideCallback()');
    end

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow;
end
