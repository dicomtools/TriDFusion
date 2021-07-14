function rotateFusedImage(bInitCoordinate)
%function  moveFusedImage(bInitCoordinate)
%Manually Move The Fused Image. 
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
    
   persistent paInitClickedPtX;
    
    clickedAxe = gca;
       
    if size(fusionBuffer('get'), 3) == 1 
    else
        imCoronalF  = imCoronalFPtr ('get'); 
        imSagittalF = imSagittalFPtr('get'); 
        imAxialF    = imAxialFPtr   ('get'); 

        iCoronal  = sliceNumber('get', 'coronal' );
        iSagittal = sliceNumber('get', 'sagittal');
        iAxial    = sliceNumber('get', 'axial'   );
        
        if bInitCoordinate == true
            
            clickedPt = get(clickedAxe,'CurrentPoint');
            
            paInitClickedPtX = clickedPt(1,1);                 
                
        else      
            clickedPt = get(clickedAxe,'CurrentPoint');
            
            aClickedPtX = clickedPt(1,1);

            aDiffClickedPtX = aClickedPtX-paInitClickedPtX;            
        
            FF = fusionBuffer('get');
                    
            switch clickedAxe
                case axes1Ptr('get')        
                    imCoronalF.CData = imrotate(permute(FF(iCoronal,:,:), [3 2 1]), aDiffClickedPtX, 'bilinear', 'crop');  
   
                case axes2Ptr('get')   
                    imSagittalF.CData = imrotate(permute(FF(:,iSagittal,:), [3 1 2]), aDiffClickedPtX, 'bilinear', 'crop');  
                    
                case axes3Ptr('get')        
                    imAxialF.CData = imrotate(FF(:,:,iAxial), aDiffClickedPtX, 'bilinear', 'crop');             
                otherwise
                    fusedImageRotationValues('set', false);                       
                    return;
            end
            
            fusedImageRotationValues('set', true, clickedAxe, aDiffClickedPtX);                       
                                    
        end
    end


end