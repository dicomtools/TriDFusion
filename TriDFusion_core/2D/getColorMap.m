function aColorMap = getColorMap(sAction, lOffset)
%function aColor = getColorMap(sAction, lOffset)
%Return the 2D ColorMap, from an offset.
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

    intensity = [0 20 40 120 220 1024];
    color = ([0 0 0; 43 0 0; 103 37 20; 199 155 97; 216 213 201; 255 255 255]) ./ 255;
    queryPoints = linspace(min(intensity),max(intensity),256);
    aAngio = interp1(intensity, color, queryPoints);

    pasColorMap = {'parula', 'jet'   , 'hsv'   , 'hot'   , 'cool', ...
                   'spring', 'summer', 'autumn', 'winter', 'gray', ...
                   'invert linear'   ,'bone'  , 'copper' , 'pink', ...
                   'lines' , 'colorcube', 'prism', 'flag', 'pet' , ...
                   'hot metal', 'angio', 'yellow', 'magenta', ...
                   'cyan', 'red', 'green','blue', 'white', 'black'};                     

    paColorMap = {parula(256), jet(256)   , hsv(256)   , hot(256)   , cool(256), ...
                  spring(256), summer(256), autumn(256), winter(256), gray(256), ...
                  flipud(gray(256)), bone(256)  , copper(256), pink(256)  , lines(256) , colorcube(256), ...
                  prism(256) , flag(256), getPetColorMap(), getHotMetalColorMap(), aAngio};                  

    if strcmpi(sAction, 'all')
        aColorMap = pasColorMap;
    else
        aColorMap = paColorMap{lOffset};                     
    end  
end    