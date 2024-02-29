function moveFusedImage(bInitCoordinate)
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
 
    persistent pInitImAxeFXData;       
    persistent pInitImAxeFYData;      
    
    persistent pInitImCoronalFXData;       
    persistent pInitImCoronalFYData;  
    persistent pInitImSagittalFXData;       
    persistent pInitImSagittalFYData;      
    persistent pInitImAxialFXData;       
    persistent pInitImAxialFYData;          
    
    persistent paInitClickedPtX;
    persistent paInitClickedPtY;    
    
    pAxe = gca(fiMainWindowPtr('get'));
      
    if size(fusionBuffer('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 3) == 1 
                
        imAxeF = imAxeFPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));
        
        if bInitCoordinate == true
            
            clickedPt = get(pAxe, 'CurrentPoint');
            
            paInitClickedPtX = clickedPt(1,1);
            paInitClickedPtY = clickedPt(1,2);
                    
            pInitImAxeFXData =  get(imAxeF,'XData');       
            pInitImAxeFYData =  get(imAxeF,'YData');                           

        else
            clickedPt = get(pAxe,'CurrentPoint');
            
            aClickedPtX = clickedPt(1,1);
            aClickedPtY = clickedPt(1,2);  

            aDiffClickedPtX = aClickedPtX-paInitClickedPtX;
            aDiffClickedPtY = aClickedPtY-paInitClickedPtY;      

            imAxeF.XData = [pInitImAxeFXData(1)+aDiffClickedPtX pInitImAxeFXData(2)+aDiffClickedPtX];
            imAxeF.YData = [pInitImAxeFYData(1)+aDiffClickedPtY pInitImAxeFYData(2)+aDiffClickedPtY];

            fusedImageMovementValues('set', true, axePtr('get', [], get(uiSeriesPtr('get'), 'Value')), [imAxeF.XData(1) imAxeF.YData(1)]);                       
        end
    else
        imCoronalF  = imCoronalFPtr ('get', [], get(uiFusedSeriesPtr('get'), 'Value')); 
        imSagittalF = imSagittalFPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')); 
        imAxialF    = imAxialFPtr   ('get', [], get(uiFusedSeriesPtr('get'), 'Value'));         
          
        if bInitCoordinate == true
            
            clickedPt = get(pAxe,'CurrentPoint');
            
            paInitClickedPtX = clickedPt(1,1);
            paInitClickedPtY = clickedPt(1,2);
                    
            pInitImCoronalFXData  =  get(imCoronalF,'XData');       
            pInitImCoronalFYData  =  get(imCoronalF,'YData');  

            pInitImSagittalFXData =  get(imSagittalF,'XData');       
            pInitImSagittalFYData =  get(imSagittalF,'YData');  

            pInitImAxialFXData    =  get(imAxialF,'XData');       
            pInitImAxialFYData    =  get(imAxialF,'YData');                                                
            
        else        
            clickedPt = get(pAxe,'CurrentPoint');
            
            aClickedPtX = clickedPt(1,1);
            aClickedPtY = clickedPt(1,2);  

            aDiffClickedPtX = aClickedPtX-paInitClickedPtX;
            aDiffClickedPtY = aClickedPtY-paInitClickedPtY;
            
            switch pAxe
                
                case axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
                    imCoronalF.XData = [pInitImCoronalFXData(1)+aDiffClickedPtX pInitImCoronalFXData(2)+aDiffClickedPtX];
                    imCoronalF.YData = [pInitImCoronalFYData(1)+aDiffClickedPtY pInitImCoronalFYData(2)+aDiffClickedPtY];

                %    imSagittalF.XData = [pInitImSagittalFXData(1)+aDiffClickedPtY pInitImSagittalFXData(2)+aDiffClickedPtY];
                    imSagittalF.YData = [pInitImSagittalFYData(1)+aDiffClickedPtY pInitImSagittalFYData(2)+aDiffClickedPtY];        

                    imAxialF.XData = [pInitImAxialFXData(1)+aDiffClickedPtX pInitImAxialFXData(2)+aDiffClickedPtX];
                %    imAxialF.YData = [pInitImAxialFYData(1)+aDiffClickedPtY pInitImAxialFYData(2)+aDiffClickedPtY];
                
%                    fusedImageMovementValues('set', true, axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [(pdCoronalMovementX+aDiffClickedPtX) (pdCoronalMovementY+aDiffClickedPtY)]);                       
%                    fusedImageMovementValues('set', true, axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [imCoronalF.XData(1)  imCoronalF.YData(1)]);                       
%                    fusedImageMovementValues('set', true, axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [imSagittalF.XData(1) imSagittalF.YData(1)]);                       
%                    fusedImageMovementValues('set', true, axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [imAxialF.XData(1)    imAxialF.YData(1)]);                                       
                                        
                case axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
                 %   imCoronalF.XData = [pInitImCoronalFXData(1)+aDiffClickedPtX pInitImCoronalFXData(2)+aDiffClickedPtX];
                    imCoronalF.YData = [pInitImCoronalFYData(1)+aDiffClickedPtY pInitImCoronalFYData(2)+aDiffClickedPtY];

                    imSagittalF.XData = [pInitImSagittalFXData(1)+aDiffClickedPtX pInitImSagittalFXData(2)+aDiffClickedPtX];
                    imSagittalF.YData = [pInitImSagittalFYData(1)+aDiffClickedPtY pInitImSagittalFYData(2)+aDiffClickedPtY];        

                %    imAxialF.XData = [pInitImAxialFXData(1)+aDiffClickedPtX pInitImAxialFXData(2)+aDiffClickedPtX];
                    imAxialF.YData = [pInitImAxialFYData(1)+aDiffClickedPtX pInitImAxialFYData(2)+aDiffClickedPtX];
                    
%                    fusedImageMovementValues('set', true, pAxe, [(pdSagittalMovementX+aDiffClickedPtX) (pdSagittalMovementY+aDiffClickedPtY)]);                       
%                    fusedImageMovementValues('set', true, pAxe, [imSagittalF.XData(1) imSagittalF.YData(1)]);                       
%                    fusedImageMovementValues('set', true, axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [imCoronalF.XData(1)  imCoronalF.YData(1)]);                       
%                    fusedImageMovementValues('set', true, axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [imSagittalF.XData(1) imSagittalF.YData(1)]);                       
%                    fusedImageMovementValues('set', true, axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [imAxialF.XData(1)    imAxialF.YData(1)]);                       
                    
                case axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
                    
                    imCoronalF.XData = [pInitImCoronalFXData(1)+aDiffClickedPtX pInitImCoronalFXData(2)+aDiffClickedPtX];
                %    imCoronalF.YData = [pInitImCoronalFYData(1)+aDiffClickedPtY pInitImCoronalFYData(2)+aDiffClickedPtY];

                    imSagittalF.XData = [pInitImSagittalFXData(1)+aDiffClickedPtY pInitImSagittalFXData(2)+aDiffClickedPtY];
                %    imSagittalF.YData = [pInitImSagittalFYData(1)+aDiffClickedPtY pInitImSagittalFYData(2)+aDiffClickedPtY];        

                    imAxialF.XData = [pInitImAxialFXData(1)+aDiffClickedPtX pInitImAxialFXData(2)+aDiffClickedPtX];
                    imAxialF.YData = [pInitImAxialFYData(1)+aDiffClickedPtY pInitImAxialFYData(2)+aDiffClickedPtY];
                    
%                    fusedImageMovementValues('set', true, pAxe, [(pdAxialMovementX+aDiffClickedPtX) (pdAxialMovementY+aDiffClickedPtY)]);                       
%                    fusedImageMovementValues('set', true, pAxe, [imAxialF.XData(1) imAxialF.YData(1)]);                       
   
                otherwise
%                    fusedImageMovementValues('set', false);                       
                    return;                                                    
            end 
            
%            fusedImageMovementValues('set', true, axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [imCoronalF.XData  imCoronalF.YData ]);                       
%            fusedImageMovementValues('set', true, axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [imSagittalF.XData imSagittalF.YData]);                       
%            fusedImageMovementValues('set', true, axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [imAxialF.XData    imAxialF.YData   ]);                        
        end        
    end  
    
end