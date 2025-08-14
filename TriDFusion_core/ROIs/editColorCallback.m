function editColorCallback(hObject,~)
%function editColorCallback(hObject,~)
%Edit ROI Color.
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

    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

    aColor = uisetcolor([hObject.UserData.Color],'Select a color');
    if isequal(aColor,0)
        return;
    end

    atRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

    if isempty(atRoiInput)
        return;
    else
        aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {hObject.UserData.Tag} );
        dTagOffset = find(aTagOffset, 1);
    end

    if ~isempty(dTagOffset)

        hObject.UserData.Color = aColor;

        atRoiInput{dTagOffset}.Color = aColor;

        if isvalid(atRoiInput{dTagOffset}.Object)

            atRoiInput{dTagOffset}.Object.Color = aColor;
        end

        roiTemplate('set', dSeriesOffset, atRoiInput);
    end

    if size(dicomBuffer('get', [], dSeriesOffset), 3) ~= 1

        plotRotatedRoiOnMip(axesMipPtr('get', [], dSeriesOffset), dicomBuffer('get', [], dSeriesOffset), mipAngle('get'));
    end

end
