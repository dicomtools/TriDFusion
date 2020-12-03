function clickDown(~, ~)
%function  clickDown(~, ~)
%Mouse Click Down Action.
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

    windowButton('set', 'down');  
    set(fiMainWindowPtr('get'), 'UserData', 'down');

    if switchTo3DMode('get')     == false && ...
       switchToIsoSurface('get') == false && ...
       switchToMIPMode('get')    == false             
%                axeClicked('set', true);
%                uiresume(gcf);
    end

    if strcmp(get(fiMainWindowPtr('get'), 'selectiontype'),'alt')

        if switchTo3DMode('get')     == false && ...
           switchToIsoSurface('get') == false && ...
           switchToMIPMode('get')    == false     

            windowButton('set', 'down');             
            adjWL(get(0, 'PointerLocation'));
        end

    else

        if size(dicomBuffer('get'), 3) ~= 1

            if switchTo3DMode('get')     == false && ...
               switchToIsoSurface('get') == false && ...
               switchToMIPMode('get')    == false

                windowButton('set', 'down');

                triangulateImages();
            else

            end
        else
            if switchTo3DMode('get')     == false && ...
               switchToIsoSurface('get') == false && ...
               switchToMIPMode('get')    == false

                windowButton('set', 'down');

                clickedPt = get(gca, 'CurrentPoint');

                clickedPtX = round(clickedPt(1  ));
                clickedPtY = round(clickedPt(1,2));

                if clickedPtX > 0 && ...
                   clickedPtY > 0 && ...
                   gca == axePtr('get')
                    axeClicked('set', true);
                    uiresume(fiMainWindowPtr('get'));                      
                end

                refreshImages();

            end
        end
    end        
end 

