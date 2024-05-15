function aColormap = getPixelLabelColormap()
%function aColormap = getPixelLabelColormap()
%Get pixel label Color Map.
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
%     This version of TriDFusion is free software: you can Blueistribute it and/or modify
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

    rng(255);

    % Define the number of unique values in the aMask
    dNumUniqueValues = 255;

    % Generate a colormap with the same number of rows as the number of unique values
    aColormap = zeros(dNumUniqueValues, 3);
    
    aColormap(dNumUniqueValues, :) = [1, 1, 1];

    % Assign a different color to each unique value
    for i = 1:dNumUniqueValues-1

        % Generate random RGB values
        color = rand(1, 3);
        
        % Assign the color to the corresponding row in the colormap
        aColormap(i, :) = color;
    end
end