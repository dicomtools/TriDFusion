function initRoi()
%function initRoi()
%Init ROIs Main Function.
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

    tInitInput = inputTemplate('get');
    iOffset = get(uiSeriesPtr('get'), 'Value');
    if iOffset > numel(tInitInput)
        return;
    end

    atRoi = roiTemplate('get');    
    if isempty(atRoi)
        return;
    end
                  
    endLoop = numel(atRoi);
    for bb=1:numel(atRoi)
        
        if mod(bb,5)==1 || bb == endLoop         
            progressBar(bb/numel(tInitInput(iOffset).tRoi), sprintf('Processing ROI %d/%d', bb, endLoop));
        end
        
        if     strcmpi(atRoi{bb}.Axe, 'axes1')
            axRoi = axes1Ptr('get');
        elseif strcmpi(atRoi{bb}.Axe, 'axes2')
            axRoi = axes2Ptr('get');
        elseif strcmpi(atRoi{bb}.Axe, 'axes3')
            axRoi = axes3Ptr('get');
        elseif strcmpi(atRoi{bb}.Axe, 'axe')
            axRoi = axePtr('get');
        else
            break;
        end

        set(fiMainWindowPtr('get'), 'CurrentAxes', axRoi)

        switch lower(tInitInput(iOffset).tRoi{bb}.Type)

            case lower('images.roi.line')

                roiPtr = drawline(axRoi, ...
                                  'Position'    , atRoi{bb}.Position, ...
                                  'Color'       , atRoi{bb}.Color, ...
                                  'LineWidth'   , atRoi{bb}.LineWidth, ...
                                  'Label'       , atRoi{bb}.Label, ...
                                  'LabelVisible', atRoi{bb}.LabelVisible, ...
                                  'Tag'         , atRoi{bb}.Tag);

                uimenu(roiPtr.UIContextMenu, 'Label', 'Copy Object' , 'UserData', roiPtr, 'Callback', @copyRoiCallback, 'Separator', 'on');
                uimenu(roiPtr.UIContextMenu, 'Label', 'Paste Object', 'UserData', roiPtr, 'Callback', @pasteRoiCallback);

                uimenu(roiPtr.UIContextMenu,'Label', 'Snap To Circles'   , 'UserData',roiPtr, 'Callback',@snapLinesToCirclesCallback, 'Separator', 'on');
                uimenu(roiPtr.UIContextMenu,'Label', 'Snap To Rectangles', 'UserData',roiPtr, 'Callback',@snapLinesToRectanglesCallback);

                uimenu(roiPtr.UIContextMenu,'Label', 'Edit Label'     , 'UserData',roiPtr, 'Callback',@editLabelCallback, 'Separator', 'on');
                uimenu(roiPtr.UIContextMenu,'Label', 'Hide/View Label', 'UserData',roiPtr, 'Callback',@hideViewLabelCallback);
                uimenu(roiPtr.UIContextMenu,'Label', 'Edit Color'     , 'UserData',roiPtr, 'Callback',@editColorCallback);

                cropMenu(roiPtr);

                uimenu(roiPtr.UIContextMenu,'Label', 'Display Result' , 'UserData',roiPtr, 'Callback',@figRoiDialogCallback, 'Separator', 'on');


            case lower('images.roi.freehand')

                roiPtr = drawfreehand(axRoi, ...
                                      'Position'      , atRoi{bb}.Position, ...
                                      'Waypoints'     , atRoi{bb}.Waypoints, ...
                                      'Color'         , atRoi{bb}.Color, ...
                                      'FaceAlpha'     , atRoi{bb}.FaceAlpha, ...
                                      'LineWidth'     , atRoi{bb}.LineWidth, ...
                                      'Label'         , atRoi{bb}.Label, ...
                                      'LabelVisible'  , atRoi{bb}.LabelVisible, ...
                                      'FaceSelectable', atRoi{bb}.FaceSelectable, ...
                                      'Tag'           , atRoi{bb}.Tag);
                roiPtr.Waypoints(:) = atRoi{bb}.Waypoints(:);

                roiDefaultMenu(roiPtr);

                uimenu(roiPtr.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData', roiPtr, 'Callback', @hideViewFaceAlhaCallback);
                uimenu(roiPtr.UIContextMenu,'Label', 'Clear Waypoints' , 'UserData', roiPtr, 'Callback', @clearWaypointsCallback);

                cropMenu(roiPtr);

                uimenu(roiPtr.UIContextMenu,'Label', 'Display Result' , 'UserData',roiPtr, 'Callback',@figRoiDialogCallback, 'Separator', 'on');

                addlistener(roiPtr, 'WaypointAdded'  , @waypointEvents);
                addlistener(roiPtr, 'WaypointRemoved', @waypointEvents);

            case lower('images.roi.assistedfreehand')

                roiPtr = drawassisted(axRoi, ...
                                      'Position'      , atRoi{bb}.Position, ...
                                      'Waypoints'     , atRoi{bb}.Waypoints, ...
                                      'Color'         , atRoi{bb}.Color, ...
                                      'FaceAlpha'     , atRoi{bb}.FaceAlpha, ...
                                      'LineWidth'     , atRoi{bb}.LineWidth, ...
                                      'Label'         , atRoi{bb}.Label, ...
                                      'LabelVisible'  , atRoi{bb}.LabelVisible, ...
                                      'FaceSelectable', atRoi{bb}.FaceSelectable, ...
                                      'Tag'           , atRoi{bb}.Tag);
                roiPtr.Waypoints(:) = atRoi{bb}.Waypoints(:);

                roiDefaultMenu(roiPtr);

                uimenu(roiPtr.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData', roiPtr, 'Callback', @hideViewFaceAlhaCallback);
                uimenu(roiPtr.UIContextMenu,'Label', 'Clear Waypoints' , 'UserData', roiPtr, 'Callback', @clearWaypointsCallback);

                cropMenu(roiPtr);

                uimenu(roiPtr.UIContextMenu,'Label', 'Display Result' , 'UserData',roiPtr, 'Callback',@figRoiDialogCallback, 'Separator', 'on');

                addlistener(roiPtr, 'WaypointAdded'  , @waypointEvents);
                addlistener(roiPtr, 'WaypointRemoved', @waypointEvents);

            case lower('images.roi.polygon')

                roiPtr = drawpolygon(axRoi, ...
                                     'Position'      , atRoi{bb}.Position, ...
                                     'Color'         , atRoi{bb}.Color, ...
                                     'FaceAlpha'     , atRoi{bb}.FaceAlpha, ...
                                     'LineWidth'     , atRoi{bb}.LineWidth, ...
                                     'Label'         , atRoi{bb}.Label, ...
                                     'LabelVisible'  , atRoi{bb}.LabelVisible, ...
                                     'FaceSelectable', atRoi{bb}.FaceSelectable, ...
                                     'Tag'           , atRoi{bb}.Tag);

                roiDefaultMenu(roiPtr);

                uimenu(roiPtr.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData', roiPtr, 'Callback', @hideViewFaceAlhaCallback);

                cropMenu(roiPtr);

                uimenu(roiPtr.UIContextMenu,'Label', 'Display Result' , 'UserData',roiPtr, 'Callback',@figRoiDialogCallback, 'Separator', 'on');

            case lower('images.roi.circle')

                roiPtr = drawcircle(axRoi, ...
                                    'Position'      , atRoi{bb}.Position, ...
                                    'Radius'        , atRoi{bb}.Radius, ...
                                    'Color'         , atRoi{bb}.Color, ...
                                    'FaceAlpha'     , atRoi{bb}.FaceAlpha, ...
                                    'LineWidth'     , atRoi{bb}.LineWidth, ...
                                    'Label'         , atRoi{bb}.Label, ...
                                    'LabelVisible'  , atRoi{bb}.LabelVisible, ...
                                    'FaceSelectable', atRoi{bb}.FaceSelectable, ...
                                    'Tag'           , atRoi{bb}.Tag);

                roiDefaultMenu(roiPtr);

                cropMenu(roiPtr);

                uimenu(roiPtr.UIContextMenu,'Label', 'Display Result' , 'UserData',roiPtr, 'Callback',@figRoiDialogCallback, 'Separator', 'on');

            case lower('images.roi.ellipse')

                roiPtr = drawellipse(axRoi, ...
                                     'Position'      , atRoi{bb}.Position, ...
                                     'SemiAxes'      , atRoi{bb}.SemiAxes, ...
                                     'RotationAngle' , atRoi{bb}.RotationAngle, ...
                                     'Color'         , atRoi{bb}.Color, ...
                                     'FaceAlpha'     , atRoi{bb}.FaceAlpha, ...
                                     'LineWidth'     , atRoi{bb}.LineWidth, ...
                                     'Label'         , atRoi{bb}.Label, ...
                                     'LabelVisible'  , atRoi{bb}.LabelVisible, ...
                                     'FaceSelectable', atRoi{bb}.FaceSelectable, ...
                                     'Tag'           , atRoi{bb}.Tag);

                roiDefaultMenu(roiPtr);

                uimenu(roiPtr.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData', roiPtr, 'Callback', @hideViewFaceAlhaCallback);

                cropMenu(roiPtr);

                uimenu(roiPtr.UIContextMenu,'Label', 'Display Result' , 'UserData',roiPtr, 'Callback',@figRoiDialogCallback, 'Separator', 'on');

            case lower('images.roi.rectangle')
                roiPtr = drawrectangle(axRoi, ...
                                      'Position'      , atRoi{bb}.Position, ...
                                      'Color'         , atRoi{bb}.Color, ...
                                      'FaceAlpha'     , atRoi{bb}.FaceAlpha, ...
                                      'LineWidth'     , atRoi{bb}.LineWidth, ...
                                      'Label'         , atRoi{bb}.Label, ...
                                      'LabelVisible'  , atRoi{bb}.LabelVisible, ...
                                      'FaceSelectable', atRoi{bb}.FaceSelectable, ...
                                      'Tag'           , atRoi{bb}.Tag);

                roiDefaultMenu(roiPtr);

                uimenu(roiPtr.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData', roiPtr, 'Callback', @hideViewFaceAlhaCallback);

                cropMenu(roiPtr);

                uimenu(roiPtr.UIContextMenu,'Label', 'Display Result' , 'UserData',roiPtr, 'Callback',@figRoiDialogCallback, 'Separator', 'on');

        end

        addlistener(roiPtr, 'DeletingROI', @deleteRoiEvents );
        addlistener(roiPtr, 'ROIMoved'   , @movedRoiEvents  );

        atRoi{bb}.Object = roiPtr;
    end

    roiTemplate('set', atRoi);

    progressBar(1, 'Ready');


end
