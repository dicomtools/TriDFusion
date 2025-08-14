function setLogoColor(axesHandle, aColor)
%function setLogoColor(axesHandle, aColor)
% Set logo text color
%
% Usage:
%   setLogoColor(uiLogo, aColor)
%
% Input:
%   axesHandle - Handle to the axes whose toolbar should be disabled
%   aColor - RGB color
%
% Description:
%   Updates the color of the text object within the specified axes.
%
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2025, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    if nargin < 1 || ~isvalid(axesHandle)
        return;
    end
    
    for i = 1:length(axesHandle.Children)
        
        if isa(axesHandle.Children(i), 'matlab.graphics.primitive.Text')

            % Set the color of the text object to the desired RGB value
            axesHandle.Children(i).Color = aColor;
            break; % Exit the loop once the text object is found and updated
        end
    end  

end