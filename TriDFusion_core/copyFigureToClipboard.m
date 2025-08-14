function copyFigureToClipboard(hFig)
%function copyFigureToClipboard(hFig)
% COPYFIGURETOCLIPBOARD Copies the given figure to the clipboard.
%   copyFigureToClipboard(hFig) captures the content of the specified 
%   figure and copies it to the clipboard using the appropriate method 
%   based on the MATLAB version and UI mode.
%
%   INPUT:
%       hFig - Handle to the figure that needs to be copied.
%
%   FUNCTIONALITY:
%       - If a viewer UI figure is active or MATLAB is R2025a or newer:
%         - The figure is captured as an image.
%         - A temporary hidden figure is created to hold the image.
%         - The image is copied to the clipboard using `copygraphics`.
%       - Otherwise:
%         - `hgexport` is used to directly copy the figure.
%       - Errors are logged using `logErrorToFile` in case of failure.
%
%   NOTE:
%       - Ensures correct copying of complex figure contents.
%       - Uses `copygraphics` for modern MATLAB versions.
%       - Uses `hgexport` for older MATLAB versions.
%
%   Example:
%       copyFigureToClipboard(gcf);
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2022, Daniel Lafontaine, on behalf of the TriDFusion development team.
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
    
    if viewerUIFigure('get') == true || ...
       ~isMATLABReleaseOlderThan('R2025a')

        aRGBImage = frame2im(getframe(hFig));

        aFigPosition = get(hFig, 'Position');

        fCopyFigure = figure('Units'   , 'pixels', ...
                             'Position', aFigPosition, ...
                             'Color'   , 'none',...
                             'Visible' , 'off');

        axeCopyFigure = ...
           axes(fCopyFigure, ...
                 'Units'   , 'pixels', ...
                 'Position', [0 0 aFigPosition(3) aFigPosition(4)], ...
                 'Color'   , 'none',...
                 'Visible' , 'off'...
                 );
        axeCopyFigure.Interactions = [];
        deleteAxesToolbar(axeCopyFigure);
        disableDefaultInteractivity(axeCopyFigure);

        image(axeCopyFigure, aRGBImage);

        disableAxesToolbar(axeCopyFigure);
        axeCopyFigure.Visible = 'off';

        copygraphics(axeCopyFigure);

        delete(axeCopyFigure);
        delete(fCopyFigure);

    else
        inv = get(hFig,'InvertHardCopy');

        set(hFig,'InvertHardCopy','Off');

        hgexport(hFig,'-clipboard');

        set(hFig,'InvertHardCopy',inv);
    end
end
