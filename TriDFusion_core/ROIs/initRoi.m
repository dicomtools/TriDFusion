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

    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

    atRoi = roiTemplate('get', dSeriesOffset);

    if isempty(atRoi)
        return;
    end
    
    % atVoi = voiTemplate('get', dSeriesOffset);

    % atDicomInfo = dicomMetaData('get', [], dSeriesOffset);
    % 
    % imRoi  = dicomBuffer('get', [], dSeriesOffset);

    endLoop = numel(atRoi);
    for bb=1:numel(atRoi)

        if mod(bb,25)==1 || bb == endLoop

            progressBar(bb/endLoop, sprintf('Processing contour %d/%d', bb, endLoop));
        end

        if ~isempty(atRoi{bb})
            
            switch lower(atRoi{bb}.Axe)
                
                case 'axes1'
                axRoi = axes1Ptr('get', [], dSeriesOffset);       
                
                case 'axes2'
                axRoi = axes2Ptr('get', [], dSeriesOffset);       
                
                case 'axes3'
                axRoi = axes3Ptr('get', [], dSeriesOffset);            
                
                case'axe'
                axRoi = axePtr('get', [], dSeriesOffset);
                
                otherwise
                break;
            end
    
            set(fiMainWindowPtr('get'), 'CurrentAxes', axRoi)
    
            switch lower(atRoi{bb}.Type)
    
                case lower('images.roi.line')
    
                    roiPtr = images.roi.Line(axRoi, ...
                                             'Position'           , atRoi{bb}.Position, ...
                                             'Deletable'          , atRoi{bb}.Deletable, ...
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
    
                    uimenu(roiPtr.UIContextMenu,'Label', 'Display Statistics ' , 'UserData',roiPtr, 'Callback',@figRoiDialogCallback, 'Separator', 'on');
    
                case lower('images.roi.freehand')
                    
                    roiPtr = images.roi.Freehand(axRoi, ...
                                                 'Position'           , atRoi{bb}.Position, ...
                                                 'Deletable'          , atRoi{bb}.Deletable, ...
                                                 'Smoothing'          , atRoi{bb}.Smoothing, ...
                                                 'Color'              , atRoi{bb}.Color, ...
                                                 'FaceAlpha'          , roiFaceAlphaValue('get'), ...
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

                    if ~isempty(roiPtr.Waypoints(:))
                        
                        roiPtr.Waypoints(:) = false;
                    end

                    % roiPtr.Waypoints(:) = atRoi{bb}.Waypoints;                    
                                           
                    % if isempty(find(atRoi{bb}.Waypoints, 1))
                    %     try
                    %         roiPtr.Waypoints(:) = false;                    
                    %     catch
                    %     end
                    % end

                    addRoiMenu(roiPtr);

                    % voiDefaultMenu(roiPtr);
                    % 
                    % roiDefaultMenu(roiPtr);
                    % 
                    % uimenu(roiPtr.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData', roiPtr, 'Callback', @hideViewFaceAlhaCallback);
                    % uimenu(roiPtr.UIContextMenu,'Label', 'Clear Waypoints' , 'UserData', roiPtr, 'Callback', @clearWaypointsCallback);
                    % 
                    % constraintMenu(roiPtr);
                    % 
                    % cropMenu(roiPtr);
                    % 
                    % uimenu(roiPtr.UIContextMenu,'Label', 'Display Statistics ' , 'UserData',roiPtr, 'Callback',@figRoiDialogCallback, 'Separator', 'on');
                    % 
                    addlistener(roiPtr, 'WaypointAdded'  , @waypointEvents);
                    addlistener(roiPtr, 'WaypointRemoved', @waypointEvents);
    
                case lower('images.roi.assistedfreehand')
    
                    roiPtr = images.roi.AssistedFreehand(axRoi, ...
                                                         'Position'           , atRoi{bb}.Position, ...
                                                         'Deletable'          , atRoi{bb}.Deletable, ...
                                                         'Waypoints'          , atRoi{bb}.Waypoints, ...
                                                         'Color'              , atRoi{bb}.Color, ...
                                                         'FaceAlpha'          , roiFaceAlphaValue('get'), ...
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
                    
                    if ~isempty(roiPtr.Waypoints(:))
                        
                        roiPtr.Waypoints(:) = false;                    
                    end

                    addRoiMenu(roiPtr);
                   
                    % voiDefaultMenu(roiPtr);
                    % 
                    % roiDefaultMenu(roiPtr);
                    % 
                    % uimenu(roiPtr.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData', roiPtr, 'Callback', @hideViewFaceAlhaCallback);
                    % uimenu(roiPtr.UIContextMenu,'Label', 'Clear Waypoints' , 'UserData', roiPtr, 'Callback', @clearWaypointsCallback);
                    % 
                    % constraintMenu(roiPtr);
                    % 
                    % cropMenu(roiPtr);  
                    % 
                    % uimenu(roiPtr.UIContextMenu,'Label', 'Display Statistics ' , 'UserData',roiPtr, 'Callback',@figRoiDialogCallback, 'Separator', 'on');
    
                    addlistener(roiPtr, 'WaypointAdded'  , @waypointEvents);
                    addlistener(roiPtr, 'WaypointRemoved', @waypointEvents);
    
                case lower('images.roi.polygon')
    
                    roiPtr = images.roi.Polygon(axRoi, ...
                                                'Position'           , atRoi{bb}.Position, ...
                                                'Deletable'          , atRoi{bb}.Deletable, ...
                                                'Color'              , atRoi{bb}.Color, ...
                                                'FaceAlpha'          , roiFaceAlphaValue('get'), ...
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
                     addRoiMenu(roiPtr);
                   
                    % voiDefaultMenu(roiPtr);
                    % 
                    % roiDefaultMenu(roiPtr);
                    % 
                    % uimenu(roiPtr.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData', roiPtr, 'Callback', @hideViewFaceAlhaCallback);
                    % 
                    % constraintMenu(roiPtr);
                    % 
                    % cropMenu(roiPtr);
                    % 
                    % uimenu(roiPtr.UIContextMenu,'Label', 'Display Statistics ' , 'UserData',roiPtr, 'Callback',@figRoiDialogCallback, 'Separator', 'on');
    
                case lower('images.roi.circle')
    
                    roiPtr = images.roi.Circle(axRoi, ...
                                               'Position'           , atRoi{bb}.Position, ...
                                               'Deletable'          , atRoi{bb}.Deletable, ...
                                               'Radius'             , atRoi{bb}.Radius, ...
                                               'Color'              , atRoi{bb}.Color, ...
                                               'FaceAlpha'          , roiFaceAlphaValue('get'), ...
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

                    addRoiMenu(roiPtr);

                    % voiDefaultMenu(roiPtr);
                    % 
                    % roiDefaultMenu(roiPtr);
                    % 
                    % constraintMenu(roiPtr);
                    % 
                    % cropMenu(roiPtr);
                    % 
                    % uimenu(roiPtr.UIContextMenu,'Label', 'Display Statistics ' , 'UserData',roiPtr, 'Callback',@figRoiDialogCallback, 'Separator', 'on');
    
                case lower('images.roi.ellipse')
    
                    roiPtr = images.roi.Ellipse(axRoi, ...
                                                'Position'           , atRoi{bb}.Position, ...
                                                'Deletable'          , atRoi{bb}.Deletable, ...
                                                'SemiAxes'           , atRoi{bb}.SemiAxes, ...
                                                'RotationAngle'      , atRoi{bb}.RotationAngle, ...
                                                'Color'              , atRoi{bb}.Color, ...
                                                'FaceAlpha'          , roiFaceAlphaValue('get'), ...
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

                    addRoiMenu(roiPtr);
    
                    % voiDefaultMenu(roiPtr);
                    % 
                    % roiDefaultMenu(roiPtr);
                    % 
                    % uimenu(roiPtr.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData', roiPtr, 'Callback', @hideViewFaceAlhaCallback);
                    % 
                    % constraintMenu(roiPtr);
                    % 
                    % cropMenu(roiPtr);
                    % 
                    % uimenu(roiPtr.UIContextMenu,'Label', 'Display Statistics ' , 'UserData',roiPtr, 'Callback',@figRoiDialogCallback, 'Separator', 'on');
    
                case lower('images.roi.rectangle')
                    roiPtr = images.roi.Rectangle(axRoi, ...
                                          'Position'           , atRoi{bb}.Position, ...
                                          'Deletable'          , atRoi{bb}.Deletable, ...
                                          'Rotatable'          , atRoi{bb}.Rotatable, ...
                                          'RotationAngle'      , atRoi{bb}.RotationAngle, ...
                                          'Color'              , atRoi{bb}.Color, ...
                                          'FaceAlpha'          , roiFaceAlphaValue('get'), ...
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
                   
                    addRoiMenu(roiPtr);

                    % voiDefaultMenu(roiPtr);
                    % 
                    % roiDefaultMenu(roiPtr);
                    % 
                    % uimenu(roiPtr.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData', roiPtr, 'Callback', @hideViewFaceAlhaCallback);
                    % 
                    % constraintMenu(roiPtr);
                    % 
                    % cropMenu(roiPtr);
                    % 
                    % uimenu(roiPtr.UIContextMenu,'Label', 'Display Statistics ' , 'UserData',roiPtr, 'Callback',@figRoiDialogCallback, 'Separator', 'on');
    
            end
            

            if strcmpi(atRoi{bb}.ObjectType, 'voi-roi') % Add VOI submenu

                roiPtr.UserData = 'voi-roi';
                
                % aTagOffset = cellfun(@(v) any(strcmp(v.RoisTag,  atRoi{bb}.Tag)), atVoi);
                % if any(aTagOffset)
                %     voiDefaultMenu(roiPtr, atVoi{find(aTagOffset, 1, 'first')}.Tag);
                % end
                % 
                % % Iterate over VOIs and check for matching RoisTag

                % for vo = 1:numel(atVoi)
                %     if any(contains(atVoi{vo}.RoisTag, atRoi{bb}.Tag))
                % 
                %         atRoi{bb}.Object.UserData = 'voi-roi';
                %         % % Call voiDefaultMenu with the matched VOI tag
                %         % voiDefaultMenu(roiPtr, atVoi{vo}.Tag);
                %         % break; % Exit loop after the first match
                %     end
                % end
            end

            addlistener(roiPtr, 'DeletingROI', @deleteRoiEvents);
            addlistener(roiPtr, 'ROIMoved'   , @movedRoiEvents );
    
            atRoi{bb}.Object = roiPtr;
    
            %DL tMaxDistances = computeRoiFarthestPoint(imRoi, atDicomInfo, atRoi{bb}, false, false);
            %DL atRoi{bb}.MaxDistances = tMaxDistances;
        end
    end

    roiTemplate('set', dSeriesOffset, atRoi);

    setVoiRoiSegPopup();

    if size(dicomBuffer('get', [], dSeriesOffset), 3) ~= 1

        plotRotatedRoiOnMip(axesMipPtr('get', [], dSeriesOffset), dicomBuffer('get', [], dSeriesOffset), mipAngle('get'));       
    end

    progressBar(1, 'Ready');

end
