function copyRoiVoiToSerie(dSeriesToOffset, tRoiVoiObject, bMirror)
%function copyRoiVoiToSerie(dSeriesToOffset, tRoiVoiObject, bMirror)
%Copy ROI form a serie to another.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2021, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    tRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

    imRoi       = dicomBuffer('get');
    atDicomInfo = dicomMetaData('get');

    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

    atInput    = inputTemplate('get');
    atRoiInput = roiTemplate('get', dSeriesToOffset);
    
    aBuffer = inputBuffer('get');

    set(uiSeriesPtr('get'), 'Value', dSeriesToOffset); 
    
    aRefBuffer = dicomBuffer('get');
    if isempty(aRefBuffer)
        
        if     strcmp(imageOrientation('get'), 'axial')
            aRefBuffer = permute(aBuffer{dSeriesToOffset}, [1 2 3]);
        elseif strcmp(imageOrientation('get'), 'coronal')
            aRefBuffer = permute(aBuffer{dSeriesToOffset}, [3 2 1]);
        elseif strcmp(imageOrientation('get'), 'sagittal')
            aRefBuffer = permute(aBuffer{dSeriesToOffset}, [3 1 2]);
        end        
    end
    
    atRefInfo = dicomMetaData('get');
    if isempty(atRefInfo)
         atRefInfo = atInput(dSeriesToOffset).atDicomInfo;
    end
    
    set(uiSeriesPtr('get'), 'Value', dSeriesOffset);

    
    if strcmpi(tRoiVoiObject.ObjectType, 'voi')

       % Voi

        asTag = [];

        endIloop = numel(tRoiVoiObject.RoisTag);
        for kk=1:endIloop

            for ll=1:numel(tRoiInput)

                if strcmpi(tRoiVoiObject.RoisTag{kk}, tRoiInput{ll}.Tag)

                    if dSeriesOffset == dSeriesToOffset

                        tRoi = tRoiInput{ll};
                        tRoi.Tag = num2str(randi([-(2^52/2),(2^52/2)],1));

                        tRoi = addRoiFromTemplate(tRoi, dSeriesOffset);

                        tMaxDistances = computeRoiFarthestPoint(imRoi, atDicomInfo, tRoi, false, false);
                        tRoi.MaxDistances = tMaxDistances;

                    else
                        tRoi     = tRoiInput{ll};
                        tRoi.Tag = num2str(randi([-(2^52/2),(2^52/2)],1));
                        tRoi.Object = [];

                        [aNewPosition, aRadius, aSemiAxes] = computeRoiScaledPosition(aRefBuffer, atRefInfo, imRoi, atDicomInfo, tRoi);

                        switch lower(tRoi.Type)

                            case lower('images.roi.circle')

                                switch lower(tRoi.Axe)

                                    case 'axes1'

                                        tRoi.Position = [];
                                        progressBar(1, 'Error: Copy of a circle from a coronal plane is not yet supported!');

                                    case 'axes2'

                                        tRoi.Position = [];
                                        progressBar(1, 'Error: Copy of a circle from a sagitttal plane is not yet supported!');

                                    otherwise
                                        tRoi.Position(:,1) = aNewPosition(:, 1);
                                        tRoi.Position(:,2) = aNewPosition(:, 2);
                                        tRoi.SliceNb       = round(aNewPosition(1,3));
                                end

                                tRoi.Radius        = aRadius;

                            case lower('images.roi.ellipse')

                                switch lower(tRoi.Axe)

                                    case 'axes1'

                                        tRoi.Position = [];

                                        progressBar(1, 'Error: Copy of an ellipse from a coronal plane is not yet supported!');


                                    case 'axes2'

                                        tRoi.Position = [];
                                        progressBar(1, 'Error: Copy of an ellipse from a sagittal plane is not yet supported!');

                                    otherwise

                                        tRoi.Position(:,1) = aNewPosition(:, 1);
                                        tRoi.Position(:,2) = aNewPosition(:, 2);
                                        tRoi.SliceNb       = round(aNewPosition(1,3));
                                        tRoi.SemiAxes      = aSemiAxes;
                                end

                            case lower('images.roi.rectangle')

                                tRoi.Position(1) = aNewPosition(1);
                                tRoi.Position(2) = aNewPosition(2);
                                tRoi.Position(3) = aNewPosition(3);
                                tRoi.Position(4) = aNewPosition(4);
                                tRoi.SliceNb     = round(aNewPosition(5));

                            otherwise
                                tRoi.Position(:,1) = aNewPosition(:, 1);
                                tRoi.Position(:,2) = aNewPosition(:, 2);
                                tRoi.SliceNb       = round(aNewPosition(1,3));

                        end

                    end

                    if ~isempty(tRoi.Position)

                        if isfield( atInput(dSeriesToOffset), 'tRoi' )
                            atInput(dSeriesToOffset).tRoi{numel(atInput(dSeriesToOffset).tRoi)+1} = tRoi;
                        else
                            atInput(dSeriesToOffset).tRoi{1} = tRoi;
                        end

                        inputTemplate('set', atInput);

                        if isempty(atRoiInput)
                            atRoiInput{1} = tRoi;
                        else
                            atRoiInput{numel(atRoiInput)+1} = tRoi;
                        end

                        roiTemplate('set', dSeriesToOffset, atRoiInput);

                        asTag{numel(asTag)+1} = tRoi.Tag;

                    end

                    break;

                end
            end
        end

        if ~isempty(asTag)
            sLabel = tRoiVoiObject.Label;
            createVoiFromRois(dSeriesToOffset, asTag, sLabel, 'Unspecified');
        end

    else
        % Roi

        if dSeriesOffset == dSeriesToOffset

            tRoi     = tRoiVoiObject;
            tRoi.Tag = num2str(randi([-(2^52/2),(2^52/2)],1));

            tRoi = addRoiFromTemplate(tRoi, dSeriesOffset);

            tMaxDistances = computeRoiFarthestPoint(imRoi, atDicomInfo, tRoi, false, false);
            tRoi.MaxDistances = tMaxDistances;
        else
            tRoi     = tRoiVoiObject;
            tRoi.Tag = num2str(randi([-(2^52/2),(2^52/2)],1));
            tRoi.Object = [];

            [aNewPosition, aRadius, aSemiAxes] = computeRoiScaledPosition(aRefBuffer, atRefInfo, imRoi, atDicomInfo, tRoi);

            switch lower(tRoi.Type)

                case lower('images.roi.circle')

                    switch lower(tRoi.Axe)

                        case 'axes1'

                            tRoi.Position = [];

                            progressBar(1, 'Error: Copy of a circle from a coronal plane is not yet supported!');
                            msgbox('Error: copyRoiVoiToSerie(): Copy of a circle from a coronal plane is not yet supported!', 'Error');

                        case 'axes2'

                            tRoi.Position = [];

                            progressBar(1, 'Error: Copy of a circle from a sagitttal plane is not yet supported!');
                            msgbox('Error: copyRoiVoiToSerie(): Copy of a circle from a sagitttal plane is not yet supported!', 'Error');

                        otherwise
                            tRoi.Position(:,1) = aNewPosition(:, 1);
                            tRoi.Position(:,2) = aNewPosition(:, 2);
                            tRoi.SliceNb       = round(aNewPosition(1,3));
                            tRoi.Radius        = aRadius;
                    end

                case lower('images.roi.ellipse')

                    switch lower(tRoi.Axe)

                        case 'axes1'

                            tRoi.Position = [];

                            progressBar(1, 'Error: Copy of an ellipse from a coronal plane is not yet supported!');
                            msgbox('Error: copyRoiVoiToSerie(): Copy of an ellipse from a coronal plane is not yet supported!', 'Error');


                        case 'axes2'

                            tRoi.Position = [];

                            progressBar(1, 'Error: Copy of an ellipse from a sagittal plane is not yet supported!');
                            msgbox('Error: copyRoiVoiToSerie(): Copy of an sagittal from a coronal plane is not yet supported!', 'Error');

                        otherwise

                            tRoi.Position(:,1) = aNewPosition(:, 1);
                            tRoi.Position(:,2) = aNewPosition(:, 2);
                            tRoi.SliceNb       = round(aNewPosition(1,3));
                            tRoi.SemiAxes      = aSemiAxes;
                    end

                case lower('images.roi.rectangle')

                    tRoi.Position(1) = aNewPosition(1);
                    tRoi.Position(2) = aNewPosition(2);
                    tRoi.Position(3) = aNewPosition(3);
                    tRoi.Position(4) = aNewPosition(4);
                    tRoi.SliceNb     = round(aNewPosition(5));

                otherwise
                    tRoi.Position(:,1) = aNewPosition(:, 1);
                    tRoi.Position(:,2) = aNewPosition(:, 2);
                    tRoi.SliceNb       = round(aNewPosition(1,3));

            end

        end

        if ~isempty(tRoi.Position)

            if isfield( atInput(dSeriesToOffset), 'tRoi' )
                atInput(dSeriesToOffset).tRoi{numel(atInput(dSeriesToOffset).tRoi)+1} = tRoi;
            else
                atInput(dSeriesToOffset).tRoi{1} = tRoi;
            end

            inputTemplate('set', atInput);

            if isempty(atRoiInput)
                atRoiInput{1} = tRoi;
            else
                atRoiInput{numel(atRoiInput)+1} = tRoi;
            end

            roiTemplate('set', dSeriesToOffset, atRoiInput);
        end

    end

    function tRoi = addRoiFromTemplate(tRoi, dSeriesOffset)

        if     strcmpi(tRoi.Axe, 'axes1')
            axRoi = axes1Ptr('get', [], dSeriesOffset);
        elseif strcmpi(tRoi.Axe, 'axes2')
            axRoi = axes2Ptr('get', [], dSeriesOffset);
        elseif strcmpi(tRoi.Axe, 'axes3')
            axRoi = axes3Ptr('get', [], dSeriesOffset);
        elseif strcmpi(tRoi.Axe, 'axe')
            axRoi = axePtr('get', [], dSeriesOffset);
        else
            tRoi = [];
            return;
        end

        switch lower(tRoi.Type)

            case lower('images.roi.line')

                roiPtr = drawline(axRoi, ...
                                  'Position'    , tRoi.Position, ...
                                  'Color'       , tRoi.Color, ...
                                  'LineWidth'   , tRoi.LineWidth, ...
                                  'Label'       , tRoi.Label, ...
                                  'LabelVisible', tRoi.LabelVisible, ...
                                  'Tag'         , tRoi.Tag);

                uimenu(roiPtr.UIContextMenu, 'Label', 'Copy Contour' , 'UserData', roiPtr, 'Callback', @copyRoiCallback, 'Separator', 'on');
                uimenu(roiPtr.UIContextMenu, 'Label', 'Paste Contour', 'UserData', roiPtr, 'Callback', @pasteRoiCallback);

                uimenu(roiPtr.UIContextMenu,'Label', 'Snap To Circles'   , 'UserData',roiPtr, 'Callback',@snapLinesToCirclesCallback, 'Separator', 'on');
                uimenu(roiPtr.UIContextMenu,'Label', 'Snap To Rectangles', 'UserData',roiPtr, 'Callback',@snapLinesToRectanglesCallback);

                uimenu(roiPtr.UIContextMenu,'Label', 'Edit Label'     , 'UserData',roiPtr, 'Callback',@editLabelCallback, 'Separator', 'on');
                uimenu(roiPtr.UIContextMenu,'Label', 'Hide/View Label', 'UserData',roiPtr, 'Callback',@hideViewLabelCallback);
                uimenu(roiPtr.UIContextMenu,'Label', 'Edit Color'     , 'UserData',roiPtr, 'Callback',@editColorCallback);

                constraintMenu(roiPtr);

                cropMenu(roiPtr);
            
                uimenu(roiPtr.UIContextMenu,'Label', 'Display Result' , 'UserData',roiPtr, 'Callback',@figRoiDialogCallback, 'Separator', 'on');


            case lower('images.roi.freehand')

                roiPtr = drawfreehand(axRoi, ...
                                      'Position'      , tRoi.Position, ...
                                      'Smoothing'     , tRoi.Smoothing, ...
                                      'Waypoints'     , tRoi.Waypoints, ...
                                      'Color'         , tRoi.Color, ...
                                      'FaceAlpha'     , tRoi.FaceAlpha, ...
                                      'LineWidth'     , tRoi.LineWidth, ...
                                      'Label'         , tRoi.Label, ...
                                      'LabelVisible'  , tRoi.LabelVisible, ...
                                      'FaceSelectable', tRoi.FaceSelectable, ...
                                      'Tag'           , tRoi.Tag);
                roiPtr.Waypoints(:) = tRoi.Waypoints(:);

                roiDefaultMenu(roiPtr);

                uimenu(roiPtr.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData', roiPtr, 'Callback', @hideViewFaceAlhaCallback);
                uimenu(roiPtr.UIContextMenu,'Label', 'Clear Waypoints' , 'UserData', roiPtr, 'Callback', @clearWaypointsCallback);

                constraintMenu(roiPtr);

                cropMenu(roiPtr);
                
                voiMenu(roiPtr);

                uimenu(roiPtr.UIContextMenu,'Label', 'Display Result' , 'UserData',roiPtr, 'Callback',@figRoiDialogCallback, 'Separator', 'on');

                addlistener(roiPtr, 'WaypointAdded'  , @waypointEvents);
                addlistener(roiPtr, 'WaypointRemoved', @waypointEvents);

            case lower('images.roi.assistedfreehand')

                roiPtr = drawassisted(axRoi, ...
                                      'Position'      , tRoi.Position, ...
                                      'Waypoints'     , tRoi.Waypoints, ...
                                      'Color'         , tRoi.Color, ...
                                      'FaceAlpha'     , tRoi.FaceAlpha, ...
                                      'LineWidth'     , tRoi.LineWidth, ...
                                      'Label'         , tRoi.Label, ...
                                      'LabelVisible'  , tRoi.LabelVisible, ...
                                      'FaceSelectable', tRoi.FaceSelectable, ...
                                      'Tag'           , tRoi.Tag);
                roiPtr.Waypoints(:) = tRoi.Waypoints(:);

                roiDefaultMenu(roiPtr);

                uimenu(roiPtr.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData', roiPtr, 'Callback', @hideViewFaceAlhaCallback);
                uimenu(roiPtr.UIContextMenu,'Label', 'Clear Waypoints' , 'UserData', roiPtr, 'Callback', @clearWaypointsCallback);

                constraintMenu(roiPtr);

                cropMenu(roiPtr);
                
                voiMenu(roiPtr);

                uimenu(roiPtr.UIContextMenu,'Label', 'Display Result' , 'UserData',roiPtr, 'Callback',@figRoiDialogCallback, 'Separator', 'on');

                addlistener(roiPtr, 'WaypointAdded'  , @waypointEvents);
                addlistener(roiPtr, 'WaypointRemoved', @waypointEvents);

            case lower('images.roi.polygon')

                roiPtr = drawpolygon(axRoi, ...
                                     'Position'      , tRoi.Position, ...
                                     'Color'         , tRoi.Color, ...
                                     'FaceAlpha'     , tRoi.FaceAlpha, ...
                                     'LineWidth'     , tRoi.LineWidth, ...
                                     'Label'         , tRoi.Label, ...
                                     'LabelVisible'  , tRoi.LabelVisible, ...
                                     'FaceSelectable', tRoi.FaceSelectable, ...
                                     'Tag'           , tRoi.Tag);

                roiDefaultMenu(roiPtr);

                uimenu(roiPtr.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData', roiPtr, 'Callback', @hideViewFaceAlhaCallback);

                constraintMenu(roiPtr);

                cropMenu(roiPtr);
                
                voiMenu(roiPtr);

                uimenu(roiPtr.UIContextMenu,'Label', 'Display Result' , 'UserData',roiPtr, 'Callback',@figRoiDialogCallback, 'Separator', 'on');

            case lower('images.roi.circle')

                roiPtr = drawcircle(axRoi, ...
                                    'Position'      , tRoi.Position, ...
                                    'Radius'        , tRoi.Radius, ...
                                    'Color'         , tRoi.Color, ...
                                    'FaceAlpha'     , tRoi.FaceAlpha, ...
                                    'LineWidth'     , tRoi.LineWidth, ...
                                    'Label'         , tRoi.Label, ...
                                    'LabelVisible'  , tRoi.LabelVisible, ...
                                    'FaceSelectable', tRoi.FaceSelectable, ...
                                    'Tag'           , tRoi.Tag);

                roiDefaultMenu(roiPtr);

                constraintMenu(roiPtr);

                cropMenu(roiPtr);
                
                voiMenu(roiPtr);

                uimenu(roiPtr.UIContextMenu,'Label', 'Display Result' , 'UserData',roiPtr, 'Callback',@figRoiDialogCallback, 'Separator', 'on');

            case lower('images.roi.ellipse')

                roiPtr = drawellipse(axRoi, ...
                                     'Position'      , tRoi.Position, ...
                                     'SemiAxes'      , tRoi.SemiAxes, ...
                                     'RotationAngle' , tRoi.RotationAngle, ...
                                     'Color'         , tRoi.Color, ...
                                     'FaceAlpha'     , tRoi.FaceAlpha, ...
                                     'LineWidth'     , tRoi.LineWidth, ...
                                     'Label'         , tRoi.Label, ...
                                     'LabelVisible'  , tRoi.LabelVisible, ...
                                     'FaceSelectable', tRoi.FaceSelectable, ...
                                     'Tag'           , tRoi.Tag);

                roiDefaultMenu(roiPtr);

                uimenu(roiPtr.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData', roiPtr, 'Callback', @hideViewFaceAlhaCallback);

                constraintMenu(roiPtr);

                cropMenu(roiPtr);
                
                voiMenu(roiPtr);

                uimenu(roiPtr.UIContextMenu,'Label', 'Display Result' , 'UserData',roiPtr, 'Callback',@figRoiDialogCallback, 'Separator', 'on');

            case lower('images.roi.rectangle')

                roiPtr = drawrectangle(axRoi, ...
                                      'Position'      , tRoi.Position, ...
                                      'Rotatable'     , tRoi.Rotatable, ...
                                      'RotationAngle' , tRoi.RotationAngle, ...
                                      'Color'         , tRoi.Color, ...
                                      'FaceAlpha'     , tRoi.FaceAlpha, ...
                                      'LineWidth'     , tRoi.LineWidth, ...
                                      'Label'         , tRoi.Label, ...
                                      'LabelVisible'  , tRoi.LabelVisible, ...
                                      'FaceSelectable', tRoi.FaceSelectable, ...
                                      'Tag'           , tRoi.Tag);

                roiDefaultMenu(roiPtr);

                uimenu(roiPtr.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData', roiPtr, 'Callback', @hideViewFaceAlhaCallback);

                constraintMenu(roiPtr);

                cropMenu(roiPtr);
                
                voiMenu(roiPtr);

                uimenu(roiPtr.UIContextMenu,'Label', 'Display Result' , 'UserData',roiPtr, 'Callback',@figRoiDialogCallback, 'Separator', 'on');

        end

        addlistener(roiPtr, 'DeletingROI', @deleteRoiEvents );
        addlistener(roiPtr, 'ROIMoved'   , @movedRoiEvents  );

        tRoi.Object = roiPtr;
    end

    function flipCoordinates()

        % to do

    end
end
