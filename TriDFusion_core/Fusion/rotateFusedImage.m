function rotateFusedImage(bInitCoordinate)
%function  rotateFusedImage(bInitCoordinate)
%Manually rotate The Fused Image. 
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
   
    persistent pInitImAxeFCData;
   
    persistent pInitImSagittalFCData;
    persistent pInitImCoronalFCData;
    persistent pInitImAxialFCData;
 
    persistent pdAxeRotation;
    
    persistent pdCoronalRotation;
    persistent pdSagittalRotation;
    persistent pdAxialRotation;
   
    pAxe = gca(fiMainWindowPtr('get'));
   
    if size(fusionBuffer('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 3) == 1 
        
        imAxeF = imAxeFPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));
        
        if bInitCoordinate == true
            
            clickedPt = get(pAxe, 'CurrentPoint');
            
            paInitClickedPtX = clickedPt(1,1);                                        
                    
            pInitImAxeFCData =  get(imAxeF,'CData');   
            
             [~, ~, dRotation] = fusedImageRotationValues('get', [], axePtr('get', [], get(uiSeriesPtr('get'), 'Value')) );                  
            pdAxeRotation = dRotation;           
        else
            clickedPt = get(pAxe,'CurrentPoint');
            
            aClickedPtX = clickedPt(1,1);

            aDiffClickedPtX = aClickedPtX-paInitClickedPtX;            
        
%            FF = fusionBuffer('get', [], get(uiFusedSeriesPtr('get'), 'Value'));
            
            imAxeF.CData = imrotate(pInitImAxeFCData, aDiffClickedPtX, 'nearest', 'crop');             
            
            fusedImageRotationValues('set', true, pAxe, pdAxeRotation+aDiffClickedPtX);                       
            
        end        
    else
        imCoronalF  = imCoronalFPtr ('get', [], get(uiFusedSeriesPtr('get'), 'Value')); 
        imSagittalF = imSagittalFPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')); 
        imAxialF    = imAxialFPtr   ('get', [], get(uiFusedSeriesPtr('get'), 'Value')); 

%        iCoronal  = sliceNumber('get', 'coronal' );
%        iSagittal = sliceNumber('get', 'sagittal');
%        iAxial    = sliceNumber('get', 'axial'   );
        
        if bInitCoordinate == true
            
            clickedPt = get(pAxe,'CurrentPoint');
            
            paInitClickedPtX = clickedPt(1,1);                 
            
            pInitImCoronalFCData  = get(imCoronalF,'CData');       
            pInitImSagittalFCData = get(imSagittalF,'CData');       
            pInitImAxialFCData    = get(imAxialF,'CData'); 
            
            [~, ~, dRotation] = fusedImageRotationValues('get', [], axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) );                  
            pdCoronalRotation = dRotation;
            
            [~, ~, dRotation] = fusedImageRotationValues('get', [], axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) );                  
            pdSagittalRotation = dRotation;
            
            [~, ~, dRotation] = fusedImageRotationValues('get', [], axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) );                  
            pdAxialRotation = dRotation;
            
        else      
            clickedPt = get(pAxe,'CurrentPoint');
            
            aClickedPtX = clickedPt(1,1);

            aDiffClickedPtX = aClickedPtX-paInitClickedPtX;            
        
%            FF = fusionBuffer('get', [], get(uiFusedSeriesPtr('get'), 'Value'));
                    
            switch pAxe
                
                case axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))        
                    imCoronalF.CData = imrotate(pInitImCoronalFCData, aDiffClickedPtX, 'nearest', 'crop');  
                    fusedImageRotationValues('set', true, pAxe, pdCoronalRotation+aDiffClickedPtX);                       
                    
                case axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))   
                    imSagittalF.CData = imrotate(pInitImSagittalFCData, aDiffClickedPtX, 'nearest', 'crop');  
                    fusedImageRotationValues('set', true, pAxe, pdSagittalRotation+aDiffClickedPtX);                       
                    
                case axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))                      
                    imAxialF.CData = imrotate(pInitImAxialFCData, aDiffClickedPtX, 'nearest', 'crop');             
                    fusedImageRotationValues('set', true, pAxe, pdAxialRotation+aDiffClickedPtX);                       
                    
               otherwise
%                    fusedImageRotationValues('set', false);                       
%                    return;
            end
            
                                    
        end
    end


end