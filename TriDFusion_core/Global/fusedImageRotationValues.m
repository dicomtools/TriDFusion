function [bApplyRotation, aAxe, dRotation, pInitFCData] = fusedImageRotationValues(sAction, bApplyRotationValue, aAxeValue, dRotationValue)
%function  [bApplyRotation, aAxe, dRotation] = fusedImageRotationValues(sAction, bApplyRotationValue, aAxeValue, dRotationValue)
%Get/Set Fused Image Rotation Values. 
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
   
    persistent pdAxeRotation;
    persistent pdCoronalRotation;
    persistent pdSagittalRotation;
    persistent pdAxialRotation;

    persistent pbApplyAxeRotation;
    persistent pbApplyCoronalRotation;
    persistent pbApplySagittalRotation;
    persistent pbApplyAxialRotation;   
                 
    if strcmpi(sAction, 'set')
                
        if exist('aAxeValue', 'var')
            
            switch(aAxeValue)
                
                % 2D image
            
                case axePtr('get', [], get(uiSeriesPtr('get'), 'Value')) 
                    
                    paAxe = aAxeValue;
                    if exist('dRotationValue', 'var')
                        pdAxeRotation = dRotationValue;
                    end
                    
                    if exist('bApplyRotationValue', 'var')
                        pbApplyAxeRotation = bApplyRotationValue;
                    end
                    
                % 3D images Coronal
               
                case axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) 
                    
                    paCoronal = aAxeValue;
                    if exist('dRotationValue', 'var')
                        pdCoronalRotation = dRotationValue;
                    end                    
                    
                    if exist('bApplyRotationValue', 'var')
                        pbApplyCoronalRotation = bApplyRotationValue;
                    end
                    
                % 3D images Sagittal
                    
                case axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) 
                    
                    paSagittal = aAxeValue;
                    if exist('dRotationValue', 'var')
                        pdSagittalRotation = dRotationValue;
                    end
                    
                    if exist('bApplyRotationValue', 'var')
                        pbApplySagittalRotation = bApplyRotationValue;
                    end
                    
                % 3D images Axial
                    
                case axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
                    
                    paAxial = aAxeValue;
                    if exist('dRotationValue', 'var')
                        pdAxialRotation = dRotationValue;
                    end                    
                    
                    if exist('bApplyRotationValue', 'var')
                        pbApplyAxialRotation = bApplyRotationValue;
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

        pdAxeRotation      = 0;
        pdCoronalRotation  = 0;
        pdSagittalRotation = 0;
        pdAxialRotation    = 0;   
        
        % Init yes\no apply rotation
       
        pbApplyAxeRotation      = false;
        pbApplyCoronalRotation  = false;
        pbApplySagittalRotation = false;
        pbApplyAxialRotation    = false;             
        
    else
        switch(aAxeValue)
            
            % Get 2D image values
            
            case axePtr('get', [], get(uiSeriesPtr('get'), 'Value'))
                aAxe           = paAxe;
                dRotation      = pdAxeRotation;
                bApplyRotation = pbApplyAxeRotation;
                
            % Get 3D images Coronal values

            case axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
                aAxe           = paCoronal;
                dRotation      = pdCoronalRotation;                
                bApplyRotation = pbApplyCoronalRotation;
                
            % Get 3D images Sagittal values

            case axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
                aAxe           = paSagittal;
                dRotation      = pdSagittalRotation;                  
                bApplyRotation = pbApplySagittalRotation;
                
            % Get 3D images Axial values

            case axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
                aAxe           = paAxial;
                dRotation      = pdAxialRotation;  
                bApplyRotation = pbApplyAxialRotation;
                 
            otherwise
                return;                                                    
        end        
        
    end
            
end
