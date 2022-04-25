function snapLinesToCirclesCallback(hObject,~)
%function snapLinesToCirclesCallback(hObject,~)
%Snap a ROI Line in The Middle Of 2 ROI Circle.
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

    dObjectOffset = '';

    atRoi = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
    for bb=1:numel(atRoi)
        if strcmpi(hObject.UserData.Tag, atRoi{bb}.Tag)
            dObjectOffset = bb;
            break;
        end
    end

    if isempty(dObjectOffset)
        return;
    end

    bFindFirst = false;
    for bb=1:numel(atRoi)
        if strcmpi(atRoi{bb}.Type, 'images.roi.circle') && ...
           strcmpi(atRoi{bb}.Axe, atRoi{dObjectOffset}.Axe) && ...
           atRoi{bb}.SliceNb == atRoi{dObjectOffset}.SliceNb

            if bFindFirst == true
                hObject.UserData.Position(2,1) = atRoi{bb}.Object.Center(1);
                hObject.UserData.Position(2,2) = atRoi{bb}.Object.Center(2);

                atRoi{dObjectOffset}.Position(2,1) = atRoi{bb}.Object.Center(1);
                atRoi{dObjectOffset}.Position(2,2) = atRoi{bb}.Object.Center(2);

                dLength = computeRoiLineLength(hObject.UserData);
                hObject.UserData.Label = [num2str(dLength) ' mm'];
                atRoi{dObjectOffset}.Label = [num2str(dLength) ' mm'];
                atRoi{dObjectOffset}.Object.Label = [num2str(dLength) ' mm'];

                roiTemplate('set', get(uiSeriesPtr('get'), 'Value'), atRoi);
                break;
            end

            if bFindFirst == false
                hObject.UserData.Position(1,1) = atRoi{bb}.Object.Center(1);
                hObject.UserData.Position(1,2) = atRoi{bb}.Object.Center(2);

                atRoi{dObjectOffset}.Position(1,1) = atRoi{bb}.Object.Center(1);
                atRoi{dObjectOffset}.Position(1,2) = atRoi{bb}.Object.Center(2);
                bFindFirst = true;
            end
        end
    end
end
