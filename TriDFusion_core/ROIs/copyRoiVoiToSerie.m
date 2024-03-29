function copyRoiVoiToSerie(dSeriesOffset, dSeriesToOffset, tRoiVoiObject, bMirror)
%function copyRoiVoiToSerie(dSeriesOffset, dSeriesToOffset, tRoiVoiObject, bMirror)
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

%    tRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

    imRoi       = dicomBuffer('get', [], dSeriesToOffset);
    atDicomInfo = dicomMetaData('get', [], dSeriesToOffset);

%    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

    atInput       = inputTemplate('get');
    atRoiInput    = roiTemplate('get', dSeriesToOffset);
    atRefRoiInput = roiTemplate('get', dSeriesOffset);
    
    aBuffer = inputBuffer('get');

%    set(uiSeriesPtr('get'), 'Value', dSeriesToOffset); 
    
    aRefBuffer = dicomBuffer('get', [], dSeriesOffset);
    if isempty(aRefBuffer) 

        aRefBuffer = aBuffer{dSeriesOffset};            
    end
    
    if isempty(imRoi)        

        imRoi = aBuffer{dSeriesToOffset};         
    end
        
    atRefInfo = dicomMetaData('get', [], dSeriesOffset);
    if isempty(atRefInfo)

         atRefInfo = atInput(dSeriesOffset).atDicomInfo;
    end
    
    if isempty(atDicomInfo)
         atDicomInfo = atInput(dSeriesToOffset).atDicomInfo;
    end
    
%    set(uiSeriesPtr('get'), 'Value', dSeriesOffset);
    
    if strcmpi(tRoiVoiObject.ObjectType, 'voi')

       % Voi

        asTag = [];

        endIloop = numel(tRoiVoiObject.RoisTag);
        for kk=1:endIloop

            for ll=1:numel(atRefRoiInput)

                if strcmpi(tRoiVoiObject.RoisTag{kk}, atRefRoiInput{ll}.Tag)

                    if dSeriesOffset == dSeriesToOffset

                        tRoi = atRefRoiInput{ll};
                        tRoi.Tag = num2str(randi([-(2^52/2),(2^52/2)],1));

                        tRoi = addRoiFromTemplate(tRoi, dSeriesOffset);

                        tMaxDistances = computeRoiFarthestPoint(imRoi, atDicomInfo, tRoi, false, false);
                        tRoi.MaxDistances = tMaxDistances;

                    else
                        tRoi     = atRefRoiInput{ll};
                        tRoi.Tag = num2str(randi([-(2^52/2),(2^52/2)],1));
                        tRoi.Object = [];

                        [aNewPosition, aRadius, aSemiAxes] = computeRoiScaledPosition(imRoi, atDicomInfo, aRefBuffer, atRefInfo, tRoi);

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

                        if size(aRefBuffer, 3) ~= 1 
                    
                            switch lower(tRoi.Axe)
                                
                                case 'axes1'                  
                                                    
                                case 'axes2'                  
       
                                otherwise

                                    if numel(atDicomInfo) >= tRoi.SliceNb
                                        sSOPClassUID         = atDicomInfo{tRoi.SliceNb}.SOPClassUID;
                                        sSOPInstanceUID      = atDicomInfo{tRoi.SliceNb}.SOPInstanceUID;
                                        sFrameOfReferenceUID = atDicomInfo{tRoi.SliceNb}.FrameOfReferenceUID;
                                    else
                                        sSOPClassUID         = atDicomInfo{1}.SOPClassUID;
                                        sSOPInstanceUID      = atDicomInfo{1}.SOPInstanceUID;
                                        sFrameOfReferenceUID = atDicomInfo{1}.FrameOfReferenceUID;
                                    end
                    
                            end
                        else
                            sSOPClassUID         = atDicomInfo{1}.SOPClassUID;
                            sSOPInstanceUID      = atDicomInfo{1}.SOPInstanceUID;
                            sFrameOfReferenceUID = atDicomInfo{1}.FrameOfReferenceUID;
                        end

                        tRoi.SOPClassUID         = sSOPClassUID;
                        tRoi.SOPInstanceUID      = sSOPInstanceUID;
                        tRoi.FrameOfReferenceUID = sFrameOfReferenceUID;                        
                    end

                    if ~isempty(tRoi.Position)

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

            createVoiFromRois(dSeriesToOffset, asTag, tRoiVoiObject.Label, tRoiVoiObject.Color, tRoiVoiObject.LesionType);
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

            [aNewPosition, aRadius, aSemiAxes] = computeRoiScaledPosition(imRoi, atDicomInfo, aRefBuffer, atRefInfo, tRoi);

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

            if size(aRefBuffer, 3) ~= 1 
        
                switch lower(tRoi.Axe)
                    
                    case 'axes1'                  
                                        
                    case 'axes2'                  

                    otherwise

                        if numel(atDicomInfo) >= tRoi.SliceNb
                            sSOPClassUID         = atDicomInfo{tRoi.SliceNb}.SOPClassUID;
                            sSOPInstanceUID      = atDicomInfo{tRoi.SliceNb}.SOPInstanceUID;
                            sFrameOfReferenceUID = atDicomInfo{tRoi.SliceNb}.FrameOfReferenceUID;
                        else
                            sSOPClassUID         = atDicomInfo{1}.SOPClassUID;
                            sSOPInstanceUID      = atDicomInfo{1}.SOPInstanceUID;
                            sFrameOfReferenceUID = atDicomInfo{1}.FrameOfReferenceUID;
                        end
        
                end
            else
                sSOPClassUID         = atDicomInfo{1}.SOPClassUID;
                sSOPInstanceUID      = atDicomInfo{1}.SOPInstanceUID;
                sFrameOfReferenceUID = atDicomInfo{1}.FrameOfReferenceUID;
            end

            tRoi.SOPClassUID         = sSOPClassUID;
            tRoi.SOPInstanceUID      = sSOPInstanceUID;
            tRoi.FrameOfReferenceUID = sFrameOfReferenceUID;  
        end

        if ~isempty(tRoi.Position)

            if isempty(atRoiInput)
                atRoiInput{1} = tRoi;
            else
                atRoiInput{numel(atRoiInput)+1} = tRoi;
            end

            roiTemplate('set', dSeriesToOffset, atRoiInput);
        end

    end

    function tRoi = addRoiFromTemplate(tRoi, dSeriesOffset)
        
        switch lower(tRoi.Axe)
            
            case 'axes1'
                axRoi = axes1Ptr('get', [], dSeriesOffset);
            
            case 'axes2'
                axRoi = axes2Ptr('get', [], dSeriesOffset);
            
            case 'axes3'
                axRoi = axes3Ptr('get', [], dSeriesOffset);
            
            case 'axe'
                axRoi = axePtr('get', [], dSeriesOffset);
            
            otherwise
                tRoi = [];
                return;
        end

        switch lower(tRoi.Type)

            case lower('images.roi.line')

                roiPtr = images.roi.Line(axRoi, ...
                                         'Position'           , tRoi.Position, ...
                                         'Color'              , tRoi.Color, ...
                                         'LineWidth'          , tRoi.LineWidth, ...
                                         'Label'              , tRoi.Label, ...
                                         'LabelVisible'       , tRoi.LabelVisible, ...
                                         'Tag'                , tRoi.Tag, ...
                                         'StripeColor'        , tRoi.StripeColor, ...
                                         'InteractionsAllowed', tRoi.InteractionsAllowed, ...                                           
                                         'UserData'           , tRoi.UserData, ...   
                                         'Visible'            , 'off' ...
                                         );

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

                roiPtr = images.roi.Freehand(axRoi, ...
                                             'Position'           , tRoi.Position, ...
                                             'Smoothing'          , tRoi.Smoothing, ...
                                             'Waypoints'          , tRoi.Waypoints, ...
                                             'Color'              , tRoi.Color, ...
                                             'FaceAlpha'          , tRoi.FaceAlpha, ...
                                             'LineWidth'          , tRoi.LineWidth, ...
                                             'Label'              , tRoi.Label, ...
                                             'LabelVisible'       , tRoi.LabelVisible, ...
                                             'FaceSelectable'     , tRoi.FaceSelectable, ...
                                             'Tag'                , tRoi.Tag, ...
                                             'StripeColor'        , tRoi.StripeColor, ...
                                             'InteractionsAllowed', tRoi.InteractionsAllowed, ...                                               
                                             'UserData'           , tRoi.UserData, ...   
                                             'Visible'            , 'off' ...
                                             );
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

                roiPtr = images.roi.AssistedFreehand(axRoi, ...
                                                     'Position'           , tRoi.Position, ...
                                                     'Waypoints'          , tRoi.Waypoints, ...
                                                     'Color'              , tRoi.Color, ...
                                                     'FaceAlpha'          , tRoi.FaceAlpha, ...
                                                     'LineWidth'          , tRoi.LineWidth, ...
                                                     'Label'              , tRoi.Label, ...
                                                     'LabelVisible'       , tRoi.LabelVisible, ...
                                                     'FaceSelectable'     , tRoi.FaceSelectable, ...
                                                     'Tag'                , tRoi.Tag, ... 
                                                     'StripeColor'        , tRoi.StripeColor, ...
                                                     'InteractionsAllowed', tRoi.InteractionsAllowed, ...                                                       
                                                     'UserData'           , tRoi.UserData, ...   
                                                     'Visible'            , 'off' ...
                                                     );
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

                roiPtr = images.roi.Polygon(axRoi, ...
                                            'Position'           , tRoi.Position, ...
                                            'Color'              , tRoi.Color, ...
                                            'FaceAlpha'          , tRoi.FaceAlpha, ...
                                            'LineWidth'          , tRoi.LineWidth, ...
                                            'Label'              , tRoi.Label, ...
                                            'LabelVisible'       , tRoi.LabelVisible, ...
                                            'FaceSelectable'     , tRoi.FaceSelectable, ...
                                            'Tag'                , tRoi.Tag, ...
                                            'StripeColor'        , tRoi.StripeColor, ...
                                            'InteractionsAllowed', tRoi.InteractionsAllowed, ...  
                                            'UserData'           , tRoi.UserData, ...   
                                            'Visible'            , 'off' ...
                                            );

                roiDefaultMenu(roiPtr);

                uimenu(roiPtr.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData', roiPtr, 'Callback', @hideViewFaceAlhaCallback);

                constraintMenu(roiPtr);

                cropMenu(roiPtr);
                
                voiMenu(roiPtr);

                uimenu(roiPtr.UIContextMenu,'Label', 'Display Result' , 'UserData',roiPtr, 'Callback',@figRoiDialogCallback, 'Separator', 'on');

            case lower('images.roi.circle')

                roiPtr = images.roi.Circle(axRoi, ...
                                           'Position'           , tRoi.Position, ...
                                           'Radius'             , tRoi.Radius, ...
                                           'Color'              , tRoi.Color, ...
                                           'FaceAlpha'          , tRoi.FaceAlpha, ...
                                           'LineWidth'          , tRoi.LineWidth, ...
                                           'Label'              , tRoi.Label, ...
                                           'LabelVisible'       , tRoi.LabelVisible, ...
                                           'FaceSelectable'     , tRoi.FaceSelectable, ...
                                           'Tag'                , tRoi.Tag, ...
                                           'StripeColor'        , tRoi.StripeColor, ...
                                           'InteractionsAllowed', tRoi.InteractionsAllowed, ...  
                                           'UserData'           , tRoi.UserData, ...   
                                           'Visible'            , 'off' ...
                                           );

                roiDefaultMenu(roiPtr);

                constraintMenu(roiPtr);

                cropMenu(roiPtr);
                
                voiMenu(roiPtr);

                uimenu(roiPtr.UIContextMenu,'Label', 'Display Result' , 'UserData',roiPtr, 'Callback',@figRoiDialogCallback, 'Separator', 'on');

            case lower('images.roi.ellipse')

                roiPtr = images.roi.Ellipse(axRoi, ...
                                            'Position'           , tRoi.Position, ...
                                            'SemiAxes'           , tRoi.SemiAxes, ...
                                            'RotationAngle'      , tRoi.RotationAngle, ...
                                            'Color'              , tRoi.Color, ...
                                            'FaceAlpha'          , tRoi.FaceAlpha, ...
                                            'LineWidth'          , tRoi.LineWidth, ...
                                            'Label'              , tRoi.Label, ...
                                            'LabelVisible'       , tRoi.LabelVisible, ...
                                            'FaceSelectable'     , tRoi.FaceSelectable, ...
                                            'Tag'                , tRoi.Tag, ...
                                            'StripeColor'        , tRoi.StripeColor, ...
                                            'InteractionsAllowed', tRoi.InteractionsAllowed, ...                                             
                                            'FixedAspectRatio'   , tRoi.FixedAspectRatio, ...
                                            'UserData'           , tRoi.UserData, ...   
                                            'Visible'            , 'off' ...
                                            );

                roiDefaultMenu(roiPtr);

                uimenu(roiPtr.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData', roiPtr, 'Callback', @hideViewFaceAlhaCallback);

                constraintMenu(roiPtr);

                cropMenu(roiPtr);
                
                voiMenu(roiPtr);

                uimenu(roiPtr.UIContextMenu,'Label', 'Display Result' , 'UserData',roiPtr, 'Callback',@figRoiDialogCallback, 'Separator', 'on');

            case lower('images.roi.rectangle')

                roiPtr = images.roi.Rectangle(axRoi, ...
                                              'Position'           , tRoi.Position, ...
                                              'Rotatable'          , tRoi.Rotatable, ...
                                              'RotationAngle'      , tRoi.RotationAngle, ...
                                              'Color'              , tRoi.Color, ...
                                              'FaceAlpha'          , tRoi.FaceAlpha, ...
                                              'LineWidth'          , tRoi.LineWidth, ...
                                              'Label'              , tRoi.Label, ...
                                              'LabelVisible'       , tRoi.LabelVisible, ...
                                              'FaceSelectable'     , tRoi.FaceSelectable, ...
                                              'Tag'                , tRoi.Tag, ...
                                              'StripeColor'        , tRoi.StripeColor, ...
                                              'InteractionsAllowed', tRoi.InteractionsAllowed, ...   
                                              'FixedAspectRatio'   , tRoi.FixedAspectRatio, ...
                                              'UserData'           , tRoi.UserData, ...   
                                              'Visible'            , 'off' ...
                                              );

                roiDefaultMenu(roiPtr);

                uimenu(roiPtr.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData', roiPtr, 'Callback', @hideViewFaceAlhaCallback);

                constraintMenu(roiPtr);

                cropMenu(roiPtr);
                
                voiMenu(roiPtr);

                uimenu(roiPtr.UIContextMenu,'Label', 'Display Result' , 'UserData', roiPtr, 'Callback', @figRoiDialogCallback, 'Separator', 'on');

        end

        addlistener(roiPtr, 'DeletingROI', @deleteRoiEvents);
        addlistener(roiPtr, 'ROIMoved'   , @movedRoiEvents );

        tRoi.Object = roiPtr;
    end

    function flipCoordinates()

        % to do

    end
end
