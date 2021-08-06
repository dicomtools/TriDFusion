function moveFusedImage(bInitCoordinate, bRestoreXYData)
%function  moveFusedImage(bInitCoordinate, bRestoreXYData)
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
    
    clickedAxe = gca;
          
    if size(fusionBuffer('get'), 3) == 1 
        
        imAxeF = imAxeFPtr('get');
        
        if bInitCoordinate == true
            
            clickedPt = get(clickedAxe, 'CurrentPoint');
            
            paInitClickedPtX = clickedPt(1,1);
            paInitClickedPtY = clickedPt(1,2);
                    
            pInitImAxeFXData =  get(imAxeF,'XData');       
            pInitImAxeFYData =  get(imAxeF,'YData');                        

        else
            clickedPt = get(clickedAxe,'CurrentPoint');
            
            aClickedPtX = clickedPt(1,1);
            aClickedPtY = clickedPt(1,2);  

            aDiffClickedPtX = aClickedPtX-paInitClickedPtX;
            aDiffClickedPtY = aClickedPtY-paInitClickedPtY;      

            imAxeF.XData = [pInitImAxeFXData(1)+aDiffClickedPtX pInitImAxeFXData(2)+aDiffClickedPtX];
            imAxeF.YData = [pInitImAxeFYData(1)+aDiffClickedPtY pInitImAxeFYData(2)+aDiffClickedPtY];

            fusedImageMovementValues('set', true, clickedAxe, [-aDiffClickedPtX -aDiffClickedPtY]);            
        end
    else
        imCoronalF  = imCoronalFPtr ('get'); 
        imSagittalF = imSagittalFPtr('get'); 
        imAxialF    = imAxialFPtr   ('get'); 
        
        if bRestoreXYData == true
            set(imCoronalF,'XData', pInitImCoronalFXData);       
            set(imCoronalF,'YData', pInitImCoronalFYData);  

            set(imSagittalF,'XData', pInitImSagittalFXData);       
            set(imSagittalF,'YData', pInitImSagittalFYData);  

            set(imAxialF,'XData', pInitImAxialFXData);       
            set(imAxialF,'YData', pInitImAxialFYData);     
            
            return;
        end
          
        if bInitCoordinate == true
            
            clickedPt = get(clickedAxe,'CurrentPoint');
            
            paInitClickedPtX = clickedPt(1,1);
            paInitClickedPtY = clickedPt(1,2);
                    
            pInitImCoronalFXData =  get(imCoronalF,'XData');       
            pInitImCoronalFYData =  get(imCoronalF,'YData');  

            pInitImSagittalFXData =  get(imSagittalF,'XData');       
            pInitImSagittalFYData =  get(imSagittalF,'YData');  

            pInitImAxialFXData =  get(imAxialF,'XData');       
            pInitImAxialFYData =  get(imAxialF,'YData');                        

        else        
            clickedPt = get(clickedAxe,'CurrentPoint');
            
            aClickedPtX = clickedPt(1,1);
            aClickedPtY = clickedPt(1,2);  

            aDiffClickedPtX = aClickedPtX-paInitClickedPtX;
            aDiffClickedPtY = aClickedPtY-paInitClickedPtY;
            
            switch clickedAxe
                case axes1Ptr('get')
                    imCoronalF.XData = [pInitImCoronalFXData(1)+aDiffClickedPtX pInitImCoronalFXData(2)+aDiffClickedPtX];
                    imCoronalF.YData = [pInitImCoronalFYData(1)+aDiffClickedPtY pInitImCoronalFYData(2)+aDiffClickedPtY];

                %    imSagittalF.XData = [pInitImSagittalFXData(1)+aDiffClickedPtY pInitImSagittalFXData(2)+aDiffClickedPtY];
                    imSagittalF.YData = [pInitImSagittalFYData(1)+aDiffClickedPtY pInitImSagittalFYData(2)+aDiffClickedPtY];        

                    imAxialF.XData = [pInitImAxialFXData(1)+aDiffClickedPtX pInitImAxialFXData(2)+aDiffClickedPtX];
                %    imAxialF.YData = [pInitImAxialFYData(1)+aDiffClickedPtY pInitImAxialFYData(2)+aDiffClickedPtY];
                
                    fusedImageMovementValues('set', true, clickedAxe, [-aDiffClickedPtX -aDiffClickedPtY]);                       
                    
                case axes2Ptr('get')
                 %   imCoronalF.XData = [pInitImCoronalFXData(1)+aDiffClickedPtX pInitImCoronalFXData(2)+aDiffClickedPtX];
                    imCoronalF.YData = [pInitImCoronalFYData(1)+aDiffClickedPtY pInitImCoronalFYData(2)+aDiffClickedPtY];

                    imSagittalF.XData = [pInitImSagittalFXData(1)+aDiffClickedPtX pInitImSagittalFXData(2)+aDiffClickedPtX];
                    imSagittalF.YData = [pInitImSagittalFYData(1)+aDiffClickedPtY pInitImSagittalFYData(2)+aDiffClickedPtY];        

                %    imAxialF.XData = [pInitImAxialFXData(1)+aDiffClickedPtX pInitImAxialFXData(2)+aDiffClickedPtX];
                    imAxialF.YData = [pInitImAxialFYData(1)+aDiffClickedPtX pInitImAxialFYData(2)+aDiffClickedPtX];
                    
                    fusedImageMovementValues('set', true, clickedAxe, [-aDiffClickedPtX -aDiffClickedPtY]);                       
                    
                case axes3Ptr('get')
                    
                    imCoronalF.XData = [pInitImCoronalFXData(1)+aDiffClickedPtX pInitImCoronalFXData(2)+aDiffClickedPtX];
                %    imCoronalF.YData = [pInitImCoronalFYData(1)+aDiffClickedPtY pInitImCoronalFYData(2)+aDiffClickedPtY];

                    imSagittalF.XData = [pInitImSagittalFXData(1)+aDiffClickedPtY pInitImSagittalFXData(2)+aDiffClickedPtY];
                %    imSagittalF.YData = [pInitImSagittalFYData(1)+aDiffClickedPtY pInitImSagittalFYData(2)+aDiffClickedPtY];        

                    imAxialF.XData = [pInitImAxialFXData(1)+aDiffClickedPtX pInitImAxialFXData(2)+aDiffClickedPtX];
                    imAxialF.YData = [pInitImAxialFYData(1)+aDiffClickedPtY pInitImAxialFYData(2)+aDiffClickedPtY];
                    
                    fusedImageMovementValues('set', true, clickedAxe, [-aDiffClickedPtX -aDiffClickedPtY]);                       

                otherwise
                    fusedImageMovementValues('set', false);                       
                    return;                                                    
            end 
                        
        end        
    end  
    
end