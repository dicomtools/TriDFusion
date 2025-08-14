function addPlotEdit(ptrPlotEdit, pAxe, dSeriesOffset, sMultiObject, sMultiTag)
%function addPlotEdit(ptrPlotEdit, pAxe, dSeriesOffset, sMultiObject, sMultiTag)
%Add plot edit to input template.
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

    if ~exist('sMultiTag', 'var')
        
        sMultiTag = [];
    end

    atPlotEditInput = plotEditTemplate('get', dSeriesOffset);

    atInput = inputTemplate('get');

    dCurrentSeriesOffset = get(uiSeriesPtr('get'), 'Value');
    if dSeriesOffset > numel(atInput)
        return;
    end

    if dCurrentSeriesOffset == dSeriesOffset

        atDicomInfo = dicomMetaData('get', [], dSeriesOffset);
        % imRoi = dicomBuffer('get', [], dSeriesOffset);
    else
        atDicomInfo = atInput(dSeriesOffset).atDicomInfo;

        % atInput = inputBuffer('get');
        % imRoi  = atInput{dSeriesOffset};
    end

    switch pAxe

        case axePtr('get', [], dSeriesOffset)     

            dSliceNb = 1;
            sAxe = 'Axe';

        case axes1Ptr('get', [], dSeriesOffset)     

            dSliceNb = sliceNumber('get', 'coronal' );
            sAxe = 'Axes1';
                            
        case axes2Ptr('get', [], dSeriesOffset)

            dSliceNb = sliceNumber('get', 'sagittal');
            sAxe = 'Axes2';

         case axes3Ptr('get', [], dSeriesOffset)

            dSliceNb = sliceNumber('get', 'axial');
            sAxe = 'Axes3';

        otherwise
            
            dSliceNb = mipAngle('get');
            sAxe = 'AxesMip';
    end

    if     isa(ptrPlotEdit, 'matlab.graphics.chart.primitive.Quiver')
        sType = 'Quiver';
    elseif isa(ptrPlotEdit, 'matlab.graphics.primitive.Text')
        sType = 'Text';
    end

    tPlotEdit.Type    = sType;
    tPlotEdit.Axe     = sAxe;
    tPlotEdit.SliceNb = dSliceNb;
    tPlotEdit.Tag     = ptrPlotEdit.Tag;
    tPlotEdit.Color   = ptrPlotEdit.Color;
    tPlotEdit.MultiObject = sMultiObject;
    tPlotEdit.MultiTag    = sMultiTag;
    tPlotEdit.SeriesInstanceUID = atDicomInfo{1}.SeriesInstanceUID;

    if strcmpi(sType, 'Quiver')
        tPlotEdit.XData         = ptrPlotEdit.XData;
        tPlotEdit.YData         = ptrPlotEdit.YData;     
        tPlotEdit.ZData         = ptrPlotEdit.ZData;
        tPlotEdit.UData         = ptrPlotEdit.UData;
        tPlotEdit.VData         = ptrPlotEdit.VData;
        tPlotEdit.WData         = ptrPlotEdit.WData;
        tPlotEdit.LineWidth     = ptrPlotEdit.LineWidth;
        tPlotEdit.MaxHeadSize   = ptrPlotEdit.MaxHeadSize;
        tPlotEdit.PickableParts = ptrPlotEdit.PickableParts;
        tPlotEdit.HitTest       = ptrPlotEdit.HitTest;
        tPlotEdit.LineStyle     = ptrPlotEdit.LineStyle;

    elseif strcmpi(sType, 'Text')

        tPlotEdit.Position      = ptrPlotEdit.Position;
        tPlotEdit.String        = ptrPlotEdit.String;
        tPlotEdit.FontAngle     = ptrPlotEdit.FontAngle;
        tPlotEdit.FontWeight    = ptrPlotEdit.FontWeight;
        tPlotEdit.FontName      = ptrPlotEdit.FontName;
        tPlotEdit.Interpreter   = ptrPlotEdit.Interpreter;
        tPlotEdit.PickableParts = ptrPlotEdit.PickableParts;
        tPlotEdit.HitTest       = ptrPlotEdit.HitTest;
        tPlotEdit.FontSize      = ptrPlotEdit.FontSize;
        tPlotEdit.VerticalAlignment   = ptrPlotEdit.VerticalAlignment;
        tPlotEdit.HorizontalAlignment = ptrPlotEdit.HorizontalAlignment;
    end

    tPlotEdit.Object  = ptrPlotEdit;

    if isempty(atPlotEditInput)

        atPlotEditInput{1} = tPlotEdit;
    else
        atPlotEditInput{numel(atPlotEditInput)+1} = tPlotEdit;
    end

    plotEditTemplate('set', dSeriesOffset, atPlotEditInput);

end
