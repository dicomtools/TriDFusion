function adColorMap = getColorMapsValue()
%function adColorMap = getColorMapsValue()
%Return all colormaps value.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2024, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    adColorMap = {parula(256), jet(256)   , hsv(256)   , hot(256)   , cool(256), ...
                  spring(256), summer(256), autumn(256), winter(256), gray(256), ...
                  flipud(gray(256)), bone(256)  , copper(256), pink(256)  , lines(256) , colorcube(256), ...
                  prism(256) , flag(256), getPetColorMap(), getHotMetalColorMap(), ...
                  getAngioColorMap(), getPixelLabelColormap(), getYellowColorMap(), getMagentaColorMap(), ...
                  getCyanColorMap(), getRedColorMap(), getGreenColorMap(), getBlueColorMap()};  
end