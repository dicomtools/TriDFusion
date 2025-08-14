function hideAllAxesToolbars(fig)
%function  hideAllAxesToolbars(fig)
%   hideAllAxesToolbars(fig) sets the Toolbar.Visible property to 'off'
%   for all axes contained within the figure 'fig'.
%
%   Input:
%       fig - Handle to the figure containing the axes.
%
%   Example:
%       fig = figure;
%       ax1 = axes('Parent', fig);
%       ax2 = axes('Parent', fig, 'Position', [0.5, 0.5, 0.4, 0.4]);
%       hideAllAxesToolbars(fig);
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

    if nargin < 1 || ~isvalid(fig)
        return;
    end

    % Find all axes objects within the figure

    axesHandles = findall(fig, 'Type', 'axes');

    % Loop through each axes handle and set the toolbar visibility to 'off'

    for k = 1:numel(axesHandles)

        if isprop(axesHandles(k), 'Toolbar') && ~isempty(axesHandles(k).Toolbar)

            axesHandles(k).Toolbar.Visible = 'off';

            drawnow;
            drawnow;
        end
    end
end