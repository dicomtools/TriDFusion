function aColorMapHotIron = getHotIronColorMap()    
%function aColorMapHotIron = getHotIronColorMap()
%Get Hot Iron Colormap.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Note: option settings must fit on one line and can contain one semicolon at most.
%Options can be strings, cell arrays of strings, or numerical arrays.
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

aColorMapHotIron = [
    0     0     0
    2     0     0
    4     0     0
    6     0     0
    8     0     0
    10    0     0
    12    0     0
    14    0     0
    16    0     0
    18    0     0
    20    0     0
    30    0     0
    40    0     0
    50    0     0
    60    0     0
    80    0     0
    100   0     0
    120   0     0
    140   0     0
    160   0     0
    180   0     0
    200   10    0
    220   20    0
    240   30    0
    255   40    0
    255   60    0
    255   80    0
    255   100   0
    255   120   0
    255   140   0
    255   160   0
    255   180   0
    255   200   20
    255   220   40
    255   240   60
    255   255   80
    255   255  100
    255   255  120
    255   255  140
    255   255  160
    255   255  180
    255   255  200
    255   255  220
    255   255  240
    255   255  255
] / 255;

% Number of rows in the original colormap
nOriginal = size(aColorMapHotIron, 1);

% Target number of rows for the interpolated colormap
nTarget = 256;

% Original positions for each row in the original colormap
xOriginal = linspace(1, nTarget, nOriginal);

% Target positions for each row in the final 256x3 colormap
xTarget = 1:nTarget;

% Interpolate each color channel (R, G, B) separately
R = interp1(xOriginal, aColorMapHotIron(:,1), xTarget);
G = interp1(xOriginal, aColorMapHotIron(:,2), xTarget);
B = interp1(xOriginal, aColorMapHotIron(:,3), xTarget);

% Combine the interpolated channels into a 256x3 color map
aColorMapHotIron = [R' G' B'];

end
