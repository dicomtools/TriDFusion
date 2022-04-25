function [aWindowedColor, dColorMin, dColorMax, dMin] = scaledRGBColorWindow(sAction, aColor, sColor, sPlane, dMin, dMax, dImageMin)
%function [aWindowedColor, dColorMin, dColorMax, dMin] = scaledRGBColorWindow(sAction, aColor, sColor, sPlane, dMin, dMax, dImageMin)
%Get/Set 2D combined RGB fusion window.
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

    persistent pdAxeMinRed; 
    persistent pdAxeMinGreen; 
    persistent pdAxeMinBlue; 
    
    persistent pdAxeMaxRed; 
    persistent pdAxeMaxGreen; 
    persistent pdAxeMaxBlue; 
    
    persistent pdCoronalMinRed; 
    persistent pdCoronalMinGreen; 
    persistent pdCoronalMinBlue; 
    
    persistent pdCoronalMaxRed; 
    persistent pdCoronalMaxGreen; 
    persistent pdCoronalMaxBlue; 
    
    persistent pdSagittalMinRed; 
    persistent pdSagittalMinGreen; 
    persistent pdSagittalMinBlue; 
    
    persistent pdSagittalMaxRed; 
    persistent pdSagittalMaxGreen; 
    persistent pdSagittalMaxBlue; 
    
    persistent pdAxialMinRed; 
    persistent pdAxialMinGreen; 
    persistent pdAxialMinBlue; 
    
    persistent pdAxialMaxRed; 
    persistent pdAxialMaxGreen; 
    persistent pdAxialMaxBlue; 
    
    persistent pdMipMinRed; 
    persistent pdMipMinGreen; 
    persistent pdMipMinBlue; 
    
    persistent pdMipMaxRed; 
    persistent pdMipMaxGreen; 
    persistent pdMipMaxBlue;         
    
    if strcmpi(sAction, 'reset')
        
        pdImageMin = [];

        pdAxeMinRed        = []; 
        pdAxeMinGreen      = []; 
        pdAxeMinBlue       = []; 

        pdAxeMaxRed        = []; 
        pdAxeMaxGreen      = []; 
        pdAxeMaxBlue       = []; 

        pdCoronalMinRed    = []; 
        pdCoronalMinGreen  = []; 
        pdCoronalMinBlue   = []; 

        pdCoronalMaxRed    = []; 
        pdCoronalMaxGreen  = []; 
        pdCoronalMaxBlue   = []; 

        pdSagittalMinRed   = []; 
        pdSagittalMinGreen = [];  
        pdSagittalMinBlue  = []; 

        pdSagittalMaxRed   = []; 
        pdSagittalMaxGreen = []; 
        pdSagittalMaxBlue  = []; 

        pdAxialMinRed      = []; 
        pdAxialMinGreen    = []; 
        pdAxialMinBlue     = []; 
        
        pdAxialMaxRed      = []; 
        pdAxialMaxGreen    = []; 
        pdAxialMaxBlue     = []; 
        
        pdMipMinRed        = []; 
        pdMipMinGreen      = []; 
        pdMipMinBlue       = []; 
        
        pdMipMaxRed        = []; 
        pdMipMaxGreen      = []; 
        pdMipMaxBlue       = []; 
        
    elseif strcmpi(sAction, 'set')
        
        if exist('dImageMin', 'var')
            pdImageMin = dImageMin;
        end
    
        switch lower(sColor)
            case 'red'
                switch lower(sPlane)
                    case 'axe'
                        pdAxeMinRed      = dMin;                    
                        pdAxeMaxRed      = dMax;                    
                    case 'coronal'
                        pdCoronalMinRed  = dMin;                    
                        pdCoronalMaxRed  = dMax;      
                    case 'sagittal'
                        pdSagittalMinRed = dMin;                    
                        pdSagittalMaxRed = dMax;      
                    case 'axial'
                        pdAxialMinRed    = dMin;                    
                        pdAxialMaxRed    = dMax;      
                    case 'mip'
                        pdMipMinRed      = dMin;                    
                        pdMipMaxRed      = dMax;      
                end

            case 'green'
                switch lower(sPlane)
                    case 'axe'
                        pdAxeMinGreen      = dMin;                    
                        pdAxeMaxGreen      = dMax;                    
                    case 'coronal'
                        pdCoronalMinGreen  = dMin;                    
                        pdCoronalMaxGreen  = dMax;      
                    case 'sagittal'
                        pdSagittalMinGreen = dMin;                    
                        pdSagittalMaxGreen = dMax;      
                    case 'axial'
                        pdAxialMinGreen    = dMin;                    
                        pdAxialMaxGreen    = dMax;      
                    case 'mip'
                        pdMipMinGreen      = dMin;                    
                        pdMipMaxGreen      = dMax; 
                end

            case 'blue'
                switch lower(sPlane)
                    case 'axe'
                        pdAxeMinBlue      = dMin;                    
                        pdAxeMaxBlue      = dMax;                    
                    case 'coronal'
                        pdCoronalMinBlue  = dMin;                    
                        pdCoronalMaxBlue  = dMax;      
                    case 'sagittal'
                        pdSagittalMinBlue = dMin;                    
                        pdSagittalMaxBlue = dMax;      
                    case 'axial'
                        pdAxialMinBlue    = dMin;                    
                        pdAxialMaxBlue    = dMax;      
                    case 'mip'
                        pdMipMinBlue      = dMin;                    
                        pdMipMaxBlue      = dMax; 
                end          
        end  
        
    elseif strcmpi(sAction, 'get')
        
        dMin = pdImageMin; 
        aWindowedColor = [];
        
        switch lower(sColor)
            case 'red'
                switch lower(sPlane)
                    case 'axe'
                        dColorMin = pdAxeMinRed;                    
                        dColorMax = pdAxeMaxRed;                    
                    case 'coronal'
                        dColorMin = pdCoronalMinRed;                    
                        dColorMax = pdCoronalMaxRed;      
                    case 'sagittal'
                        dColorMin = pdSagittalMinRed;                    
                        dColorMax = pdSagittalMaxRed;      
                    case 'axial'
                        dColorMin = pdAxialMinRed;                    
                        dColorMax = pdAxialMaxRed;      
                    case 'mip'
                        dColorMin = pdMipMinRed;                    
                        dColorMax = pdMipMaxRed;      
                end

            case 'green'
                switch lower(sPlane)
                    case 'axe'
                        dColorMin = pdAxeMinGreen;                    
                        dColorMax = pdAxeMaxGreen;                    
                    case 'coronal'
                        dColorMin = pdCoronalMinGreen;                    
                        dColorMax = pdCoronalMaxGreen;      
                    case 'sagittal'
                        dColorMin = pdSagittalMinGreen;                    
                        dColorMax = pdSagittalMaxGreen;      
                    case 'axial'
                        dColorMin = pdAxialMinGreen;                    
                        dColorMax = pdAxialMaxGreen;      
                    case 'mip'
                        dColorMin = pdMipMinGreen;                    
                        dColorMax = pdMipMaxGreen; 
                end

            case 'blue'
                switch lower(sPlane)
                    case 'axe'
                        dColorMin = pdAxeMinBlue;                    
                        dColorMax = pdAxeMaxBlue;                    
                    case 'coronal'
                        dColorMin = pdCoronalMinBlue;                    
                        dColorMax = pdCoronalMaxBlue;      
                    case 'sagittal'
                        dColorMin = pdSagittalMinBlue;                    
                        dColorMax = pdSagittalMaxBlue;      
                    case 'axial'
                        dColorMin = pdAxialMinBlue;                    
                        dColorMax = pdAxialMaxBlue;      
                    case 'mip'
                        dColorMin = pdMipMinBlue;                    
                        dColorMax = pdMipMaxBlue; 
                end          
        end             
    else
        switch lower(sColor)
            
            case 'red'
                switch lower(sPlane)
                    case 'axe'
                        aWindowedColor = aColor;                    
                        aWindowedColor(aWindowedColor<pdAxeMinRed)      = pdImageMin;
                        aWindowedColor(aWindowedColor>pdAxeMaxRed)      = pdImageMin;
                    case 'coronal'
                        aWindowedColor = aColor;                    
                        aWindowedColor(aWindowedColor<pdCoronalMinRed)  = pdImageMin;
                        aWindowedColor(aWindowedColor>pdCoronalMaxRed)  = pdImageMin;
                    case 'sagittal'
                        aWindowedColor = aColor;                    
                        aWindowedColor(aWindowedColor<pdSagittalMinRed) = pdImageMin;
                        aWindowedColor(aWindowedColor>pdSagittalMaxRed) = pdImageMin;
                    case 'axial'
                        aWindowedColor = aColor;                    
                        aWindowedColor(aWindowedColor<pdAxialMinRed)    = pdImageMin;
                        aWindowedColor(aWindowedColor>pdAxialMaxRed)    = pdImageMin;
                    case 'mip'
                        aWindowedColor = aColor;                    
                        aWindowedColor(aWindowedColor<pdMipMinRed)      = pdImageMin;
                        aWindowedColor(aWindowedColor>pdMipMaxRed)      = pdImageMin;
                    otherwise
                        aWindowedColor = [];                          
                end

            case 'green'
                switch lower(sPlane)
                    case 'axe'
                        aWindowedColor = aColor;                    
                        aWindowedColor(aWindowedColor<pdAxeMinGreen)      = pdImageMin;
                        aWindowedColor(aWindowedColor>pdAxeMaxGreen)      = pdImageMin;
                    case 'coronal'
                        aWindowedColor = aColor;                    
                        aWindowedColor(aWindowedColor<pdCoronalMinGreen)  = pdImageMin;
                        aWindowedColor(aWindowedColor>pdCoronalMaxGreen)  = pdImageMin;
                    case 'sagittal'
                        aWindowedColor = aColor;                    
                        aWindowedColor(aWindowedColor<pdSagittalMinGreen) = pdImageMin;
                        aWindowedColor(aWindowedColor>pdSagittalMaxGreen) = pdImageMin;
                    case 'axial'
                        aWindowedColor = aColor;                    
                        aWindowedColor(aWindowedColor<pdAxialMinGreen)    = pdImageMin;
                        aWindowedColor(aWindowedColor>pdAxialMaxGreen)    = pdImageMin;
                    case 'mip'
                        aWindowedColor = aColor;                    
                        aWindowedColor(aWindowedColor<pdMipMinGreen)      = pdImageMin;
                        aWindowedColor(aWindowedColor>pdMipMaxGreen)      = pdImageMin;
                    otherwise
                        aWindowedColor = [];                         
                end

            case 'blue'
                switch lower(sPlane)
                    case 'axe'
                        aWindowedColor = aColor;                    
                        aWindowedColor(aWindowedColor<pdAxeMinBlue)      = pdImageMin;
                        aWindowedColor(aWindowedColor>pdAxeMaxBlue)      = pdImageMin;
                    case 'coronal'
                        aWindowedColor = aColor;                    
                        aWindowedColor(aWindowedColor<pdCoronalMinBlue)  = pdImageMin;
                        aWindowedColor(aWindowedColor>pdCoronalMaxBlue)  = pdImageMin;
                    case 'sagittal'
                        aWindowedColor = aColor;                    
                        aWindowedColor(aWindowedColor<pdSagittalMinBlue) = pdImageMin;
                        aWindowedColor(aWindowedColor>pdSagittalMaxBlue) = pdImageMin;
                    case 'axial'
                        aWindowedColor = aColor;                    
                        aWindowedColor(aWindowedColor<pdAxialMinBlue)    = pdImageMin;
                        aWindowedColor(aWindowedColor>pdAxialMaxBlue)    = pdImageMin;
                    case 'mip'
                        aWindowedColor = aColor;                    
                        aWindowedColor(aWindowedColor<pdMipMinBlue)      = pdImageMin;
                        aWindowedColor(aWindowedColor>pdMipMaxBlue)      = pdImageMin;
                    otherwise
                        aWindowedColor = [];  
                end
        end          
    end  
end