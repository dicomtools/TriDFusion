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

    atRoi = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
    if isempty(atRoi)
        return;
    end

    atVoi = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

    atDicomInfo = dicomMetaData('get');

    imRoi  = dicomBuffer('get');

    endLoop = numel(atRoi);
    for bb=1:numel(atRoi)

        if mod(bb,5)==1 || bb == endLoop
            progressBar(bb/endLoop, sprintf('Processing ROI %d/%d', bb, endLoop));
        end

        if ~isempty(atRoi{bb})
            switch lower(atRoi{bb}.Axe)
                
                case 'axes1'
                axRoi = axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value'));       
                
                case 'axes2'
                axRoi = axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value'));       
                
                case 'axes3'
                axRoi = axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value'));            
                
                case'axe'
                axRoi = axePtr('get', [], get(uiSeriesPtr('get'), 'Value'));
                
                otherwise
                break;
            end
    
            set(fiMainWindowPtr('get'), 'CurrentAxes', axRoi)
    
            switch lower(atRoi{bb}.Type)
    
                case lower('images.roi.line')
    
                    roiPtr = images.roi.Line(axRoi, ...
                                             'Position'           , atRoi{bb}.Position, ...
                                             'Color'              , atRoi{bb}.Color, ...
                                             'LineWidth'          , atRoi{bb}.LineWidth, ...
                                             'Label'              , atRoi{bb}.Label, ...
                                             'LabelVisible'       , atRoi{bb}.LabelVisible, ...
                                             'Tag'                , atRoi{bb}.Tag, ...
                                             'StripeColor'        , atRoi{bb}.StripeColor, ...
                                             'InteractionsAllowed', atRoi{bb}.InteractionsAllowed, ...                                              
                                             'UserData'           , atRoi{bb}.UserData, ...   
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
                                                 'Position'           , atRoi{bb}.Position, ...
                                                 'Smoothing'          , atRoi{bb}.Smoothing, ...
                                                 'Color'              , atRoi{bb}.Color, ...
                                                 'FaceAlpha'          , atRoi{bb}.FaceAlpha, ...
                                                 'LineWidth'          , atRoi{bb}.LineWidth, ...
                                                 'Label'              , atRoi{bb}.Label, ...
                                                 'LabelVisible'       , atRoi{bb}.LabelVisible, ...
                                                 'FaceSelectable'     , atRoi{bb}.FaceSelectable, ...
                                                 'Tag'                , atRoi{bb}.Tag, ...
                                                 'StripeColor'        , atRoi{bb}.StripeColor, ...
                                                 'InteractionsAllowed', atRoi{bb}.InteractionsAllowed, ...                                                      
                                                 'UserData'           , atRoi{bb}.UserData, ...   
                                                 'Visible'            , 'off' ...
                                                 );  
                                             
                    if isempty(atRoi{bb}.Waypoints(atRoi{bb}.Waypoints==1))
                        roiPtr.Waypoints(:) = false;                    
                    end
                                    
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
                                                         'Position'           , atRoi{bb}.Position, ...
                                                         'Waypoints'          , atRoi{bb}.Waypoints, ...
                                                         'Color'              , atRoi{bb}.Color, ...
                                                         'FaceAlpha'          , atRoi{bb}.FaceAlpha, ...
                                                         'LineWidth'          , atRoi{bb}.LineWidth, ...
                                                         'Label'              , atRoi{bb}.Label, ...
                                                         'LabelVisible'       , atRoi{bb}.LabelVisible, ...
                                                         'FaceSelectable'     , atRoi{bb}.FaceSelectable, ...
                                                         'Tag'                , atRoi{bb}.Tag, ...
                                                         'StripeColor'        , atRoi{bb}.StripeColor, ...
                                                         'InteractionsAllowed', atRoi{bb}.InteractionsAllowed, ...                                                          
                                                         'UserData'           , atRoi{bb}.UserData, ...   
                                                         'Visible'            , 'off' ...
                                                         );
                    if atRoi{bb}.Waypoints(atRoi{bb}.Waypoints==1)
                        roiPtr.Waypoints(:) = false;                    
                    end
    
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
                                                'Position'           , atRoi{bb}.Position, ...
                                                'Color'              , atRoi{bb}.Color, ...
                                                'FaceAlpha'          , atRoi{bb}.FaceAlpha, ...
                                                'LineWidth'          , atRoi{bb}.LineWidth, ...
                                                'Label'              , atRoi{bb}.Label, ...
                                                'LabelVisible'       , atRoi{bb}.LabelVisible, ...
                                                'FaceSelectable'     , atRoi{bb}.FaceSelectable, ...
                                                'Tag'                , atRoi{bb}.Tag, ...
                                                'StripeColor'        , atRoi{bb}.StripeColor, ...
                                                'InteractionsAllowed', atRoi{bb}.InteractionsAllowed, ...                                                 
                                                'UserData'           , atRoi{bb}.UserData, ...   
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
                                               'Position'           , atRoi{bb}.Position, ...
                                               'Radius'             , atRoi{bb}.Radius, ...
                                               'Color'              , atRoi{bb}.Color, ...
                                               'FaceAlpha'          , atRoi{bb}.FaceAlpha, ...
                                               'LineWidth'          , atRoi{bb}.LineWidth, ...
                                               'Label'              , atRoi{bb}.Label, ...
                                               'LabelVisible'       , atRoi{bb}.LabelVisible, ...
                                               'FaceSelectable'     , atRoi{bb}.FaceSelectable, ...
                                               'Tag'                , atRoi{bb}.Tag, ...
                                               'StripeColor'        , atRoi{bb}.StripeColor, ...
                                               'InteractionsAllowed', atRoi{bb}.InteractionsAllowed, ...                                                
                                               'UserData'           , atRoi{bb}.UserData, ...   
                                               'Visible'            , 'off' ...
                                               );
    
                    atRoi{bb}.Vertices = roiPtr.Vertices;
                    
                    roiDefaultMenu(roiPtr);
    
                    constraintMenu(roiPtr);
    
                    cropMenu(roiPtr);
                    
                    voiMenu(roiPtr);
    
                    uimenu(roiPtr.UIContextMenu,'Label', 'Display Result' , 'UserData',roiPtr, 'Callback',@figRoiDialogCallback, 'Separator', 'on');
    
                case lower('images.roi.ellipse')
    
                    roiPtr = images.roi.Ellipse(axRoi, ...
                                                'Position'           , atRoi{bb}.Position, ...
                                                'SemiAxes'           , atRoi{bb}.SemiAxes, ...
                                                'RotationAngle'      , atRoi{bb}.RotationAngle, ...
                                                'Color'              , atRoi{bb}.Color, ...
                                                'FaceAlpha'          , atRoi{bb}.FaceAlpha, ...
                                                'LineWidth'          , atRoi{bb}.LineWidth, ...
                                                'Label'              , atRoi{bb}.Label, ...
                                                'LabelVisible'       , atRoi{bb}.LabelVisible, ...
                                                'FaceSelectable'     , atRoi{bb}.FaceSelectable, ...
                                                'Tag'                , atRoi{bb}.Tag, ...
                                                'StripeColor'        , atRoi{bb}.StripeColor, ...
                                                'InteractionsAllowed', atRoi{bb}.InteractionsAllowed, ...
                                                'FixedAspectRatio'   , atRoi{bb}.FixedAspectRatio, ...
                                                'UserData'           , atRoi{bb}.UserData, ...   
                                                'Visible'            , 'off' ...
                                                );
                                     
                    atRoi{bb}.Vertices = roiPtr.Vertices;
    
                    roiDefaultMenu(roiPtr);
    
                    uimenu(roiPtr.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData', roiPtr, 'Callback', @hideViewFaceAlhaCallback);
    
                    constraintMenu(roiPtr);
    
                    cropMenu(roiPtr);
                    
                    voiMenu(roiPtr);
    
                    uimenu(roiPtr.UIContextMenu,'Label', 'Display Result' , 'UserData',roiPtr, 'Callback',@figRoiDialogCallback, 'Separator', 'on');
    
                case lower('images.roi.rectangle')
                    roiPtr = images.roi.Rectangle(axRoi, ...
                                          'Position'           , atRoi{bb}.Position, ...
                                          'Rotatable'          , atRoi{bb}.Rotatable, ...
                                          'RotationAngle'      , atRoi{bb}.RotationAngle, ...
                                          'Color'              , atRoi{bb}.Color, ...
                                          'FaceAlpha'          , atRoi{bb}.FaceAlpha, ...
                                          'LineWidth'          , atRoi{bb}.LineWidth, ...
                                          'Label'              , atRoi{bb}.Label, ...
                                          'LabelVisible'       , atRoi{bb}.LabelVisible, ...
                                          'FaceSelectable'     , atRoi{bb}.FaceSelectable, ...
                                          'Tag'                , atRoi{bb}.Tag, ...
                                          'StripeColor'        , atRoi{bb}.StripeColor, ...
                                          'InteractionsAllowed', atRoi{bb}.InteractionsAllowed, ...                                      
                                          'FixedAspectRatio'   , atRoi{bb}.FixedAspectRatio, ...
                                          'UserData'           , atRoi{bb}.UserData, ...   
                                          'Visible'            , 'off' ...
                                          );
                                      
                    atRoi{bb}.Vertices = roiPtr.Vertices;
                    
                    roiDefaultMenu(roiPtr);
    
                    uimenu(roiPtr.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData', roiPtr, 'Callback', @hideViewFaceAlhaCallback);
    
                    constraintMenu(roiPtr);
    
                    cropMenu(roiPtr);
                    
                    voiMenu(roiPtr);
    
                    uimenu(roiPtr.UIContextMenu,'Label', 'Display Result' , 'UserData',roiPtr, 'Callback',@figRoiDialogCallback, 'Separator', 'on');
    
            end
            
            if strcmpi(atRoi{bb}.ObjectType, 'voi-roi') % Add VOI submenu
                for vo=1:numel(atVoi)     
                    if find(contains(atVoi{vo}.RoisTag, atRoi{bb}.Tag))         
                        voiDefaultMenu(roiPtr, atVoi{vo}.Tag);
                        break;
                    end
                end
            end

            addlistener(roiPtr, 'DeletingROI', @deleteRoiEvents );
            addlistener(roiPtr, 'ROIMoved'   , @movedRoiEvents  );
    
            atRoi{bb}.Object = roiPtr;
    
            tMaxDistances = computeRoiFarthestPoint(imRoi, atDicomInfo, atRoi{bb}, false, false);
            atRoi{bb}.MaxDistances = tMaxDistances;
        end
    end

    roiTemplate('set', get(uiSeriesPtr('get'), 'Value'), atRoi);

    setVoiRoiSegPopup();

    progressBar(1, 'Ready');


end
