function exportContourReportToPdf(figContourReport, axeContourReport, sFileName)
%function exportContourReportToPdf(figContourReport, axeContourReport, sFileName)
% EXPORTCONTOURREPORTTOPDF Exports the contour report figure to a PDF file.
%   exportContourReportToPdf(figContourReport, axeContourReport, sFileName)
%   captures the contents of the specified figure and exports it as a 
%   high-quality PDF. The function adapts the export method based on 
%   the MATLAB release and whether a viewer UI figure is being used.
%
%   INPUTS:
%       figContourReport  - Handle to the contour report figure.
%       axeContourReport  - Handle to the contour report axes.
%       sFileName         - String specifying the output PDF file name.
%
%   FUNCTIONALITY:
%       - If a viewer UI figure is in use or MATLAB is R2025a or newer:
%         - A new temporary figure is created (if needed).
%         - The contour report is captured as an image.
%         - The image is embedded in an axes and exported.
%       - Otherwise, the standard print method is used for export.
%
%   NOTE:
%       - Uses 'exportgraphics' if MATLAB version is R2025a or newer.
%       - Uses 'print' method for older releases.
%       - Adjusts figure and paper properties for proper scaling.
%
%   Example:
%       exportContourReportToPdf(gcf, gca, 'contour_report.pdf');
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

    if viewerUIFigure('get') == true || ...
       ~isMATLABReleaseOlderThan('R2025a')

        fPdfReport = figure('Units'   , 'pixels', ...
                            'Position', figContourReport.Position, ...
                            'Color'   , 'none',...
                            'Visible' , 'off');

        aRGBImage = frame2im(getframe(figContourReport));

        axePdfReport = ...
           axes(fPdfReport, ...
                 'Units'   , 'pixels', ...
                 'Position', [0 0 figContourReport.Position(3), figContourReport.Position(4)], ...
                 'Color'   , 'none',...
                 'Visible' , 'off'...
                 );
        axePdfReport.Interactions = [];
        deleteAxesToolbar(axePdfReport);
        disableDefaultInteractivity(axePdfReport);

        image(axePdfReport, aRGBImage);

        disableAxesToolbar(axePdfReport);
        axePdfReport.Visible = 'off';

        exportgraphics(axePdfReport, sFileName);

        delete(axePdfReport);

        delete(fPdfReport);
        
    else

        set(axeContourReport,'LooseInset', get(axeContourReport,'TightInset'));
        unit = get(figContourReport,'Units');
        set(figContourReport,'Units','inches');
        pos = get(figContourReport,'Position');

        set(figContourReport, ...
            'PaperPositionMode', 'auto',...
            'PaperUnits'       , ...
            'inches',...
            'PaperPosition'    , [0,0,pos(3),pos(4)],...
            'PaperSize'        , [pos(3), pos(4)]);

        print(figContourReport, sFileName, '-image', '-dpdf', '-r0');

        set(figContourReport,'Units', unit);
    end
end