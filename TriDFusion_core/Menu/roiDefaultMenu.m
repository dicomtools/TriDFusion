function roiDefaultMenu(ptrObject)
%function roiDefaultMenu(ptrObject)
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

    if strcmpi(ptrObject.Type, 'uimenu')
        mUIContextMenu = ptrObject;
        ptrRoi = ptrObject.UserData;
    else
        mUIContextMenu = ptrObject.UIContextMenu;
        ptrRoi = ptrObject;
    end

    % Main function to set up the default ROI context menu with improved structure
    addMenuItem(mUIContextMenu, ptrRoi, 'Copy Contour (Ctrl + C)'   , @copyRoiCallback, false);
    addMenuItem(mUIContextMenu, ptrRoi, 'Paste Contour (Ctrl + V)'  , @pasteRoiCallback, false);
    addMenuItem(mUIContextMenu, ptrRoi, 'Paste Mirror'   , @pasteMirroirRoiCallback, false);
    addMenuItem(mUIContextMenu, ptrRoi, 'Edit Label'     , @editLabelCallback, true);
    addMenuItem(mUIContextMenu, ptrRoi, 'Hide/View Label', @hideViewLabelCallback, false);
    addMenuItem(mUIContextMenu, ptrRoi, 'Edit Color'     , @editColorCallback, false);

    % Add predefined label submenu
    addDynamicMenu(mUIContextMenu, ptrRoi, 'Predefined Label', getRoiLabelList(), @predefinedLabelCallback, []);

    % Add lesion type options if available
    [~, asLesionList] = getLesionType('');
    if ~isempty(asLesionList)

        addDynamicMenu(mUIContextMenu, ptrRoi, 'Edit Site', asLesionList, @editRoiLesionTypeCallback, @refreshRoiMenuLocationCallback);
    end
end

function menuItem = addMenuItem(mUIContextMenu, ptrRoi, label, callback, isSeparator)

    if nargin < 4, isSeparator = false; end  % Default for separator is false
        menuItem = uimenu(mUIContextMenu, ...
                          'Label'   , label, ...
                          'UserData', ptrRoi, ...
                          'HitTest' , 'off', ...
                          'Callback', callback);
    if isSeparator
        menuItem.Separator = 'on';
    end
end

function addDynamicMenu(mUIContextMenu, ptrRoi, label, itemList, callback, mainCallback)
 
    parentMenu = uimenu(mUIContextMenu, 'Label', label, 'UserData', ptrRoi);
    
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

