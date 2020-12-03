function triangulateImages()
%function triangulateImages()
%Set the slices number of the 2D triangulation.
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

    if size(dicomBuffer('get'), 3) ~= 1

        im = dicomBuffer('get');

        iCoronalSize  = size(im,1);
        iSagittalSize = size(im,2);
        iAxialSize    = size(im,3);        

        clickedPt = get(gca,'CurrentPoint');

        clickedPtX = round(clickedPt(1  ));
        clickedPtY = round(clickedPt(1,2));

        if clickedPtX > 0 && clickedPtY > 0

            switch gca
                case axes1Ptr('get')  
                    if ( (clickedPtX <= iSagittalSize) &&...
                         (clickedPtY <= iAxialSize) )  
                        sliceNumber('set', 'sagittal', clickedPtX);
                        sliceNumber('set', 'axial'   , clickedPtY);

                        set(uiSliderSagPtr('get'), 'Value', clickedPtX / iSagittalSize);
                        set(uiSliderTraPtr('get'), 'Value', 1 - (clickedPtY / iAxialSize));

                        refreshImages();
                        axeClicked('set', true);
                        uiresume(fiMainWindowPtr('get'));
                    end

                case axes2Ptr('get')
                    if ( (clickedPtX <= iCoronalSize) &&...
                         (clickedPtY <= iAxialSize) )  
                        sliceNumber('set', 'coronal', clickedPtX);
                        sliceNumber('set', 'axial'  , clickedPtY);                

                        set(uiSliderCorPtr('get'), 'Value', clickedPtX / iCoronalSize);
                        set(uiSliderTraPtr('get'), 'Value', 1 - (clickedPtY / iAxialSize));

                        refreshImages();

                        axeClicked('set', true);
                        uiresume(fiMainWindowPtr('get'));                                
                    end    

                case axes3Ptr('get')
                    if ( (clickedPtX <= iSagittalSize) && ...
                         (clickedPtY <= iCoronalSize) ) 

                        sliceNumber('set', 'sagittal', clickedPtX);
                        sliceNumber('set', 'coronal' , clickedPtY);

                        set(uiSliderSagPtr('get'), 'Value', clickedPtX / iSagittalSize);
                        set(uiSliderCorPtr('get'), 'Value', clickedPtY / iCoronalSize);

                        refreshImages();

                        axeClicked('set', true);
                        uiresume(fiMainWindowPtr('get'));
                    end
                otherwise

            end

        end
    end
end