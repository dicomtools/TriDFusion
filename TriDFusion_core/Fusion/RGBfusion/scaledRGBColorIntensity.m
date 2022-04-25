function [aScaledColor, dColorIntensity, dMin] = scaledRGBColorIntensity(sAction, aColor, sColor, sPlane, dIntensity, dImageMin)
%function sColor = scaledRGBColorIntensity(sAction, aColor, sColor, sPlane, dIntensity)
%Get/Set 2D combined RGB fusion intensity.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2021, Daniel Lafontaine, on behalf of the TriDFusion development team.
% 
% This file is part of The Triple Dimention Fusion (TriDFusion).
% 
% TriDFusion development has been led by: Daniel Lafontaine
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

    persistent pdImageMin; 

    persistent pdAxeRed; 
    persistent pdAxeGreen; 
    persistent pdAxeBlue; 

    persistent pdCoronalRed; 
    persistent pdCoronalGreen; 
    persistent pdCoronalBlue; 
    
    persistent pdSagittalRed; 
    persistent pdSagittalGreen; 
    persistent pdSagittalBlue; 
    
    persistent pdAxialRed; 
    persistent pdAxialGreen; 
    persistent pdAxialBlue; 
    
    persistent pdMipRed; 
    persistent pdMipGreen; 
    persistent pdMipBlue;         
    
    if strcmpi(sAction, 'reset')
        
        pdImageMin = 0;

        pdAxeRed       = 0; 
        pdAxeGreen     = 0; 
        pdAxeBlue      = 0; 

        pdCoronalRed   = 0; 
        pdCoronalGreen = 0; 
        pdCoronalBlue  = 0; 

        pdSagittalRed   = 0; 
        pdSagittalGreen = 0; 
        pdSagittalBlue  = 0; 

        pdAxialRed      = 0; 
        pdAxialGreen    = 0; 
        pdAxialBlue     = 0; 

        pdMipRed        = 0; 
        pdMipGreen      = 0; 
        pdMipBlue       = 0;  
        
    elseif strcmpi(sAction, 'set')
        
        if exist('dImageMin', 'var')
            pdImageMin = dImageMin;
        end
 
        switch lower(sColor)
            case 'red'
                switch lower(sPlane)
                    case 'axe'
                        pdAxeRed      = dIntensity;                    
                    case 'coronal'
                        pdCoronalRed  = dIntensity;
                    case 'sagittal'
                        pdSagittalRed = dIntensity;
                    case 'axial'
                        pdAxialRed    = dIntensity;
                    case 'mip'
                        pdMipRed      = dIntensity;
                end

            case 'green'
                switch lower(sPlane)
                    case 'axe'
                        pdAxeGreen      = dIntensity;                    
                    case 'coronal'
                        pdCoronalGreen  = dIntensity;
                    case 'sagittal'
                        pdSagittalGreen = dIntensity;
                    case 'axial'
                        pdAxialGreen    = dIntensity;
                    case 'mip'
                        pdMipGreen      = dIntensity;
                end

            case 'blue'
                switch lower(sPlane)
                    case 'axe'
                        pdAxeBlue      = dIntensity;                    
                    case 'coronal'
                        pdCoronalBlue  = dIntensity;
                    case 'sagittal'
                        pdSagittalBlue = dIntensity;
                    case 'axial'
                        pdAxialBlue    = dIntensity;
                    case 'mip'
                        pdMipBlue      = dIntensity;
                end            
        end  
        
    elseif strcmpi(sAction, 'get')
        
        dMin = pdImageMin; 
        aScaledColor = [];
        
        switch lower(sColor)
            case 'red'
                switch lower(sPlane)
                    case 'axe'
                        dColorIntensity = pdAxeRed;                    
                    case 'coronal'
                        dColorIntensity = pdCoronalRed;
                    case 'sagittal'
                        dColorIntensity = pdSagittalRed;
                    case 'axial'
                        dColorIntensity = pdAxialRed;
                    case 'mip'
                        dColorIntensity = pdMipRed;
                end

            case 'green'
                switch lower(sPlane)
                    case 'axe'
                        dColorIntensity = pdAxeGreen;                    
                    case 'coronal'
                        dColorIntensity = pdCoronalGreen;
                    case 'sagittal'
                        dColorIntensity = pdSagittalGreen;
                    case 'axial'
                        dColorIntensity = pdAxialGreen;
                    case 'mip'
                        dColorIntensity = pdMipGreen;
                end

            case 'blue'
                switch lower(sPlane)
                    case 'axe'
                        dColorIntensity = pdAxeBlue;                    
                    case 'coronal'
                        dColorIntensity = pdCoronalBlue;
                    case 'sagittal'
                        dColorIntensity = pdSagittalBlue;
                    case 'axial'
                        dColorIntensity = pdAxialBlue;
                    case 'mip'
                        dColorIntensity = pdMipBlue;
                end            
        end             
    else
        switch lower(sColor)
            case 'red'
                switch lower(sPlane)
                    case 'axe'
                        aScaledColor = aColor*pdAxeRed;                    
                    case 'coronal'
                        aScaledColor = aColor*pdCoronalRed;
                    case 'sagittal'
                        aScaledColor = aColor*pdSagittalRed;
                    case 'axial'
                        aScaledColor = aColor*pdAxialRed;
                    case 'mip'
                        aScaledColor = aColor*pdMipRed;
                    case 'zeros'
                        aScaledColor = aColor;
                        aScaledColor(aScaledColor==0) = pdImageMin;
                    otherwise
                        aScaledColor = [];
                end

            case 'green'
                switch lower(sPlane)
                    case 'axe'
                        aScaledColor = aColor*pdAxeGreen;                    
                    case 'coronal'
                        aScaledColor = aColor*pdCoronalGreen;
                    case 'sagittal'
                        aScaledColor = aColor*pdSagittalGreen;
                    case 'axial'
                        aScaledColor = aColor*pdAxialGreen;
                    case 'mip'
                        aScaledColor = aColor*pdMipGreen;
                    case 'zeros'
                        aScaledColor = aColor;
                        aScaledColor(aScaledColor==0) = pdImageMin;  
                    otherwise
                        aScaledColor = [];                        
                end

            case 'blue'
                switch lower(sPlane)
                    case 'axe'
                        aScaledColor = aColor*pdAxeBlue;                    
                    case 'coronal'
                        aScaledColor = aColor*pdCoronalBlue;
                    case 'sagittal'
                        aScaledColor = aColor*pdSagittalBlue;
                    case 'axial'
                        aScaledColor = aColor*pdAxialBlue;
                    case 'mip'
                        aScaledColor = aColor*pdMipBlue;
                    case 'zeros'
                        aScaledColor = aColor;
                        aScaledColor(aScaledColor==0) = pdImageMin;                        
                    otherwise
                        aScaledColor = [];                        
                end     
                
            otherwise
                aScaledColor = [];
        end          
    end   
end