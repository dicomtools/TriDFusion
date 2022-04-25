function [bApplyMovement, aAxe, aPosition] = fusedImageMovementValues(sAction, bApplyMovementValue, aAxeValue, aPositionValue)
%function  [bApplyMovement, aAxe, aPosition] = fusedImageMovementValues(sAction, bApplyMovementValue, aAxeValue, aPositionValue)
%Get/Set Fused Image Position Values. 
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

    persistent paAxe;   
    persistent paCoronal;
    persistent paSagittal;
    persistent paAxial;
   
    persistent paAxePosition;
    persistent paCoronalPosition;
    persistent paSagittalPosition;
    persistent paAxialPosition;    
    
    persistent pbApplyAxeMovement;
    persistent pbApplyCoronalMovement;
    persistent pbApplySagittalMovement;
    persistent pbApplyAxialMovement;  
    
    if strcmpi(sAction, 'set')
                
        if exist('aAxeValue', 'var')
            
            switch(aAxeValue)
                
                % 2D image
            
                case axePtr('get', [], get(uiSeriesPtr('get'), 'Value')) 
                    
                    paAxe = aAxeValue;
                    if exist('aPositionValue', 'var')
                        paAxePosition = aPositionValue;
                    end
                    
                    if exist('bApplyMovementValue', 'var')
                        pbApplyAxeMovement = bApplyMovementValue;
                    end
                    
                % 3D images Coronal
               
                case axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) 
                    
                    paCoronal = aAxeValue;
                    if exist('aPositionValue', 'var')
                        paCoronalPosition = aPositionValue;
                    end                    
                    
                    if exist('bApplyMovementValue', 'var')
                        pbApplyCoronalMovement = bApplyMovementValue;
                    end
                    
                % 3D images Sagittal
                    
                case axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) 
                    
                    paSagittal = aAxeValue;
                    if exist('aPositionValue', 'var')
                        paSagittalPosition = aPositionValue;
                    end
                    
                    if exist('bApplyMovementValue', 'var')
                        pbApplySagittalMovement = bApplyMovementValue;
                    end
                    
                % 3D images Axial
                    
                case axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
                    
                    paAxial = aAxeValue;
                    if exist('aPositionValue', 'var')
                        paAxialPosition = aPositionValue;
                    end                    
                    
                    if exist('bApplyMovementValue', 'var')
                        pbApplyAxialMovement = bApplyMovementValue;
                    end
                    
                otherwise
                    return;                                                    
            end
        end
        
    elseif strcmpi(sAction, 'init')
        
        % Init Axes
        
        paAxe      = [];   
        paCoronal  = [];
        paSagittal = [];
        paAxial    = [];
        
        % Init rotation value

        paAxePosition      = [0 0];
        paCoronalPosition  = [0 0];
        paSagittalPosition = [0 0];
        paAxialPosition    = [0 0];   
        
        % Init yes\no apply rotation
       
        pbApplyAxeMovement      = false;
        pbApplyCoronalMovement  = false;
        pbApplySagittalMovement = false;
        pbApplyAxialMovement    = false;             
        
    else
        switch(aAxeValue)
            
            % Get 2D image values
            
            case axePtr('get', [], get(uiSeriesPtr('get'), 'Value'))
                aAxe           = paAxe;
                aPosition      = paAxePosition;
                bApplyMovement = pbApplyAxeMovement;
                
            % Get 3D images Coronal values

            case axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
                aAxe           = paCoronal;
                aPosition      = paCoronalPosition;                
                bApplyMovement = pbApplyCoronalMovement;
                
            % Get 3D images Sagittal values

            case axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
                aAxe           = paSagittal;
                aPosition      = paSagittalPosition;                  
                bApplyMovement = pbApplySagittalMovement;
                
            % Get 3D images Axial values

            case axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
                aAxe           = paAxial;
                aPosition      = paAxialPosition;  
                bApplyMovement = pbApplyAxialMovement;
                 
            otherwise
                return;                                                    
        end        
        
    end
    
end
