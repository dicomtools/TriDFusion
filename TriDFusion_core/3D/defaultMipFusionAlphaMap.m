function aAlphaMap = defaultMipFusionAlphaMap(im, sType)
%function aAlphaMap = defaultMipFusionAlphaMap(sType)
%Return the default MIP AlphaMap, base on scan type.
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

    if strcmp(sType, 'mr')

       intensity = [0 20 40 120 220 1024];
       alpha = [0 0 0.15 0.3 0.38 0.5];
 %      color = ([0 0 0; 43 0 0; 103 37 20; 199 155 97; 216 213 201; 255 255 255]) ./ 255;
       queryPoints = linspace(min(intensity),max(intensity),256);
       alphamap = interp1(intensity,alpha,queryPoints)';
       aAlphaMap = alphamap;

    elseif strcmp(sType, 'ct')     
        
        dMin = min(im,[],'all');
        dMax = max(im,[],'all');
        
        if dMin < 0 && dMax > 0
            intensity = [dMin,dMin/183,dMax/4.7,dMax];
        else        
            intensity = [-3024,-16.45,641.38,3071];
        end
        
        alpha = [0, 0, 0.72, 0.72];
%        color = ([0 0 0; 186 65 77; 231 208 141; 255 255 255]) ./ 255;
        queryPoints = linspace(min(intensity),max(intensity),256);
        alphamap = interp1(intensity,alpha,queryPoints)';
        aAlphaMap = alphamap;
    elseif strcmpi(sType, 'pt')  
        aAlphaMap = getPTAlphaMapValues();    
    else
        aAlphaMap = zeros(256,1);
    end 

end 