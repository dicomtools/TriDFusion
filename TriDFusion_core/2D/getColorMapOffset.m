function lOffset = getColorMapOffset(sLabel)
%function lOffset = getColorMapOffset(sLabel)
%Get Label 2D Color Map Offset.
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

    switch lower(sLabel) 
        case 'parula'
            lOffset = 1;
        case 'jet'
            lOffset = 2;
        case 'hsv'
            lOffset = 3;
        case 'hot'
            lOffset = 4;
        case 'cool'
            lOffset = 5;
        case 'spring'
            lOffset = 6;                    
        case 'summer'
            lOffset = 7;
        case 'autumn'
            lOffset = 8;
        case 'winter'
            lOffset = 9;
        case 'gray'
            lOffset = 10;
        case 'invert linear'
            lOffset = 11;            
        case 'bone'
            lOffset = 12;                
        case 'copper'
            lOffset = 13;
        case 'pink'
            lOffset = 14;
        case 'lines'
            lOffset = 15;
        case 'colorcube'
            lOffset = 16;
        case 'prism'
            lOffset = 17;  
        case 'flag'                       
            lOffset = 18;
        case 'pet'
            lOffset = 19;
        case 'hot metal'
            lOffset = 20;    
        case 'angio'
            lOffset = 21;            
        case 'yellow'
            lOffset = 22;    
        case 'magenta'
            lOffset = 23;                
        case 'cyan'
            lOffset = 24;                
        case 'red'
            lOffset = 25;          
        case 'green'
            lOffset = 26;    
        case 'blue'
            lOffset = 27;         
             
        otherwise
            lOffset = 0;
    end
    
end