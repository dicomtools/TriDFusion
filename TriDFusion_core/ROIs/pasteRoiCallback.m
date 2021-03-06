function pasteRoiCallback(~, ~)
%function pasteRoiCallback(~, ~)
%Paste ROI Default Right Click menu.
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

    windowButton('set', 'up'); % Patch for Linux

    ptrRoi = copyRoiPtr('get');

    if isempty(ptrRoi)
        return;
    end

    if ~isvalid(ptrRoi)
        return;
    end

    if ptrRoi.Parent ~= gca
        return;
    end

    sTag = num2str(randi([-(2^52/2),(2^52/2)],1));

    switch lower(ptrRoi.Type)

        case lower('images.roi.line')

            pRoi = drawline(ptrRoi.Parent, ...
                            'Position'    , ptrRoi.Position, ...
                            'Color'       , ptrRoi.Color, ...
                            'LineWidth'   , ptrRoi.LineWidth, ...
                            'Label'       , ptrRoi.Label, ...
                            'LabelVisible', 'on', ...
                            'Tag'         , sTag ...
                            );

            uimenu(pRoi.UIContextMenu, 'Label', 'Copy Object' , 'UserData', pRoi, 'Callback', @copyRoiCallback, 'Separator', 'on');
            uimenu(pRoi.UIContextMenu, 'Label', 'Paste Object', 'UserData', pRoi, 'Callback', @pasteRoiCallback);

            uimenu(pRoi.UIContextMenu,'Label', 'Snap To Circles'   , 'UserData',pRoi, 'Callback',@snapLinesToCirclesCallback, 'Separator', 'on');
            uimenu(pRoi.UIContextMenu,'Label', 'Snap To Rectangles', 'UserData',pRoi, 'Callback',@snapLinesToRectanglesCallback);

            uimenu(pRoi.UIContextMenu,'Label', 'Edit Label'     , 'UserData',pRoi, 'Callback',@editLabelCallback, 'Separator', 'on');
            uimenu(pRoi.UIContextMenu,'Label', 'Hide/View Label', 'UserData',pRoi, 'Callback',@hideViewLabelCallback);
            uimenu(pRoi.UIContextMenu,'Label', 'Edit Color'     , 'UserData',pRoi, 'Callback',@editColorCallback);

            cropMenu(pRoi);

            uimenu(pRoi.UIContextMenu,'Label', 'Display Result' , 'UserData',pRoi, 'Callback',@figRoiDialogCallback, 'Separator', 'on');


        case lower('images.roi.freehand')

            pRoi = drawfreehand(ptrRoi.Parent, ...
                                'Position'      , ptrRoi.Position, ...
                                'Color'         , ptrRoi.Color, ...
                                'LineWidth'     , ptrRoi.LineWidth, ...
                                'Label'         , roiLabelName(), ...
                                'LabelVisible'  , ptrRoi.LabelVisible, ...
                                'FaceSelectable', ptrRoi.FaceSelectable, ...
                                'FaceAlpha'     , ptrRoi.FaceAlpha, ...
                                'Tag'           , sTag, ...
                                'Visible'       , 'on' ...
                                );
            pRoi.Waypoints(:) = ptrRoi.Waypoints(:);

            roiDefaultMenu(pRoi);

            uimenu(pRoi.UIContextMenu, 'Label', 'Hide/View Face Alpha', 'UserData', pRoi, 'Callback', @hideViewFaceAlhaCallback);
            uimenu(pRoi.UIContextMenu, 'Label', 'Clear Waypoints', 'UserData', pRoi, 'Callback', @clearWaypointsCallback);

            cropMenu(pRoi);

            uimenu(pRoi.UIContextMenu, 'Label', 'Display Result' , 'UserData', pRoi, 'Callback', @figRoiDialogCallback, 'Separator', 'on');


        case lower('images.roi.polygon')

            pRoi = drawpolygon(ptrRoi.Parent, ...
                               'Position'      , ptrRoi.Position, ...
                               'Color'         , ptrRoi.Color, ...
                               'FaceAlpha'     , ptrRoi.FaceAlpha, ...
                               'LineWidth'     , ptrRoi.LineWidth, ...
                               'Label'         , roiLabelName(), ...
                               'LabelVisible'  , ptrRoi.LabelVisible, ...
                               'FaceSelectable', ptrRoi.FaceSelectable, ...
                               'FaceAlpha'     , ptrRoi.FaceAlpha, ...
                               'Tag'           , sTag, ...
                               'Visible'       , 'on' ...
                               );

            roiDefaultMenu(pRoi);

            uimenu(pRoi.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData', pRoi, 'Callback', @hideViewFaceAlhaCallback);

            cropMenu(pRoi);

            uimenu(pRoi.UIContextMenu, 'Label', 'Display Result' , 'UserData', pRoi, 'Callback', @figRoiDialogCallback, 'Separator', 'on');


        case lower('images.roi.circle')

            pRoi = drawcircle(ptrRoi.Parent, ...
                              'Position'      , ptrRoi.Position, ...
                              'Radius'        , ptrRoi.Radius, ...
                              'Color'         , ptrRoi.Color, ...
                              'FaceAlpha'     , ptrRoi.FaceAlpha, ...
                              'LineWidth'     , ptrRoi.LineWidth, ...
                              'Label'         , roiLabelName(), ...
                              'LabelVisible'  , ptrRoi.LabelVisible, ...
                              'FaceSelectable', ptrRoi.FaceSelectable, ...
                              'FaceAlpha'     , ptrRoi.FaceAlpha, ...
                              'Tag'           , sTag ...
                              );

            roiDefaultMenu(pRoi);

            cropMenu(pRoi);

            uimenu(pRoi.UIContextMenu, 'Label', 'Display Result' , 'UserData', pRoi, 'Callback', @figRoiDialogCallback, 'Separator', 'on');


        case lower('images.roi.ellipse')

            pRoi = drawellipse(ptrRoi.Parent, ...
                               'Position'      , ptrRoi.Position, ...
                               'SemiAxes'      , ptrRoi.SemiAxes, ...
                               'RotationAngle' , ptrRoi.RotationAngle, ...
                               'Color'         , ptrRoi.Color, ...
                               'FaceAlpha'     , ptrRoi.FaceAlpha, ...
                               'LineWidth'     , ptrRoi.LineWidth, ...
                               'Label'         , roiLabelName(), ...
                               'LabelVisible'  , ptrRoi.LabelVisible, ...
                               'FaceSelectable', ptrRoi.FaceSelectable, ...
                               'FaceAlpha'     , ptrRoi.FaceAlpha, ...
                               'Tag'           , sTag ...
                               );

            roiDefaultMenu(pRoi);

            uimenu(pRoi.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData', pRoi, 'Callback', @hideViewFaceAlhaCallback);

            cropMenu(pRoi);

            uimenu(pRoi.UIContextMenu, 'Label', 'Display Result' , 'UserData', pRoi, 'Callback', @figRoiDialogCallback, 'Separator', 'on');


        case lower('images.roi.rectangle')

            pRoi = drawrectangle(ptrRoi.Parent, ...
                                'Position'      , ptrRoi.Position, ...
                                'Color'         , ptrRoi.Color, ...
                                'FaceAlpha'     , ptrRoi.FaceAlpha, ...
                                'LineWidth'     , ptrRoi.LineWidth, ...
                                'Label'         , roiLabelName(), ...
                                'LabelVisible'  , ptrRoi.LabelVisible, ...
                                'FaceSelectable', ptrRoi.FaceSelectable, ...
                                'FaceAlpha'     , ptrRoi.FaceAlpha, ...
                                'Tag'           , sTag ...
                                );

            roiDefaultMenu(pRoi);

            uimenu(pRoi.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData', pRoi, 'Callback', @hideViewFaceAlhaCallback);

            cropMenu(pRoi);

            uimenu(pRoi.UIContextMenu, 'Label', 'Display Result' , 'UserData', pRoi, 'Callback', @figRoiDialogCallback, 'Separator', 'on');

        otherwise
            return;
    end

    addRoi(pRoi, get(uiSeriesPtr('get'), 'Value'));                  
    
    setVoiRoiSegPopup();


end
