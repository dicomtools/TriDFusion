function roiDefaultMenu(ptrRoi)
%function roiDefaultMenu(ptrRoi)
%Add ROI Default Right Click menu.
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
  
    % Main function to set up the default ROI context menu with improved structure
    addMenuItem(ptrRoi, 'Copy Contour'   , @copyRoiCallback, true);
    addMenuItem(ptrRoi, 'Paste Contour'  , @pasteRoiCallback);
    addMenuItem(ptrRoi, 'Paste Mirror'   , @pasteMirroirRoiCallback);
    addMenuItem(ptrRoi, 'Edit Label'     , @editLabelCallback, true);
    addMenuItem(ptrRoi, 'Hide/View Label', @hideViewLabelCallback);
    addMenuItem(ptrRoi, 'Edit Color'     , @editColorCallback);

    % Add predefined label submenu
    addDynamicMenu(ptrRoi, 'Predefined Label', getRoiLabelList(), @predefinedLabelCallback);

    % Add lesion type options if available
    [~, asLesionList] = getLesionType('');
    if ~isempty(asLesionList)

        addDynamicMenu(ptrRoi, 'Edit Location', asLesionList, @editRoiLesionTypeCallback, @refreshRoiMenuLocationCallback);
    end
end

function menuItem = addMenuItem(ptrRoi, label, callback, isSeparator)

    if nargin < 4, isSeparator = false; end  % Default for separator is false
        menuItem = uimenu(ptrRoi.UIContextMenu, 'Label', label, 'UserData', ptrRoi, 'Callback', callback);
    if isSeparator
        menuItem.Separator = 'on';
    end
end

function addDynamicMenu(ptrRoi, label, itemList, callback, mainCallback)
 
    parentMenu = uimenu(ptrRoi.UIContextMenu, 'Label', label, 'UserData', ptrRoi);
    
    if nargin > 4 && ~isempty(mainCallback)  % Add main callback if provided
        
        parentMenu.MenuSelectedFcn = mainCallback;
    end
    
    numItems = numel(itemList); % Get the number of items

    for i = 1:numItems
        uimenu(parentMenu, ...
            'Text'           , itemList{i}, ...
            'UserData'       , ptrRoi, ...
            'MenuSelectedFcn', callback);
    end
    
end

function refreshRoiMenuLocationCallback(hObject, ~)

    atRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

    dTagOffset = find(strcmp( cellfun(@(x) x.Tag, atRoiInput, 'uni', false), hObject.UserData.Tag));

    if ~isempty(dTagOffset)  % If the tag corresponds to an ROI

        currentLesionType = atRoiInput{dTagOffset}.LesionType;
        
        numChildren = numel(hObject.Children); 
    
        % Iterate through each child 

        for childIdx = 1:numChildren
            
            child = hObject.Children(childIdx); % Access the child
            set(child, 'Checked', strcmpi(child.Text, currentLesionType));
        end
    end
end

