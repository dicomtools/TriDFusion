function refreshImageRotation()
%function refreshImageRotation()
%Refresh manual images rotation.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2022, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

   if isMoveImageActivated('get') == true && ...
       isFusion('get') == true && ...
       isVsplash('get') == false

        aFusionImage = fusionBuffer('get', [], get(uiFusedSeriesPtr('get'), 'Value'));

        if size(aFusionImage, 3) == 1 % 2D image
            [bApplyRotation, aAxe, dRotation] = fusedImageRotationValues('get', [], axePtr('get', [], get(uiSeriesPtr('get'), 'Value')) );                  
            if bApplyRotation == true
                if ~isempty(aAxe)                    
                    imAxeF = imAxeFPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));
                    imAxeF.CData = imrotate(imAxeF.CData, dRotation, 'nearest', 'crop');  
                end
            end                
        else      
            [bApplyRotation, aAxe, dRotation] = fusedImageRotationValues('get', [], axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) );                  
            if bApplyRotation == true % 3D images Coronal
                if ~isempty(aAxe)                    
                    imCoronalF = imCoronalFPtr ('get', [], get(uiFusedSeriesPtr('get'), 'Value')); 
                    imCoronalF.CData = imrotate(imCoronalF.CData, dRotation, 'nearest', 'crop');  
                end
            end

            [bApplyRotation, aAxe, dRotation] = fusedImageRotationValues('get', [], axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) );                  
            if bApplyRotation == true % 3D images Sagittal                    
                if ~isempty(aAxe)                    
                    imSagittalF = imSagittalFPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')); 
                    imSagittalF.CData = imrotate(imSagittalF.CData, dRotation, 'nearest', 'crop');               
                end
            end

            [bApplyRotation, aAxe, dRotation] = fusedImageRotationValues('get', [], axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) );                  
             if bApplyRotation == true % 3D images Axial
                if ~isempty(aAxe)
                    imAxialF = imAxialFPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')); 
                    imAxialF.CData = imrotate(imAxialF.CData, dRotation, 'nearest', 'crop');  
                end
             end
        end 
   end
end