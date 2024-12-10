function marginMenu(ptrObject)
%function marginMenu(ptrObject)
%Add Margin Menu To ROIs Right Click.
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

    if strcmpi(ptrObject.Type, 'uimenu')
        mUIContextMenu = ptrObject;
        ptrRoi = ptrObject.UserData;
    else
        mUIContextMenu = ptrObject.UIContextMenu;
        ptrRoi = ptrObject;
    end
    
    mMargin = uimenu(mUIContextMenu,'Label', 'Margin', 'Separator', 'on');
    
    uimenu(mMargin, ...
        'Label'    , 'Margin Adjustments', ...
        'UserData' , ptrRoi, ...
        'Visible'  , 'on', ...
        'HitTest'  , 'on', ...
        'Callback' , @editContourMarginCallback);

    uimenu(mMargin, ...
        'Label'   , 'Create Margin Contour', ...
        'UserData', ptrRoi, ...
        'Visible' , 'on', ...
        'HitTest' , 'off', ...
        'Callback', @createRoiMarginContoursCallback);

    function createRoiMarginContoursCallback(hObject, ~)

        atRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

        dRoiTagOffset = find(strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {hObject.UserData.Tag} ), 1);

        if ~isempty(dRoiTagOffset) % Found the tag

            createRoiMarginContour(contourMarginDistanceValue('get'), contourMarginJointType('get'), atRoiInput(dRoiTagOffset));
        end
    end
end    