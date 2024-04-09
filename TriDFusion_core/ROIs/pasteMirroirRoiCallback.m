function pasteMirroirRoiCallback(~, ~)
%function pasteMirroirRoiCallback(~, ~)
%Paste mirroir ROI Default Right Click menu.
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
    
    pAxe = getAxeFromMousePosition(get(uiSeriesPtr('get'), 'Value'));

    if isempty(pAxe)
        return;
    end

    if ptrRoi.Parent ~= pAxe
        return;
    end

    [imgHeight, imgWidth, ~] =  size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')));

    sTag = num2str(randi([-(2^52/2),(2^52/2)],1));
    
            
    switch lower(ptrRoi.Type)

        case lower('images.roi.line')

            % Obtain the current positions of the line's start and end points
            aLinePosition = ptrRoi.Position; % This returns a 2x2 matrix: [x1, y1; x2, y2]
            
            % Extract the individual coordinates
            x1 = aLinePosition(1,1);
            y1 = aLinePosition(1,2);
            x2 = aLinePosition(2,1);
            y2 = aLinePosition(2,2);
            
            % Calculate the new x-coordinates by mirroring across the image's vertical axis
            newX1 = imgWidth - x1;
            newX2 = imgWidth - x2;
            
            % Set the new positions for the line
            aLinePosition = [newX1, y1; newX2, y2];
            
            pRoi = images.roi.Line(ptrRoi.Parent, ...
                                   'Position'           , aLinePosition, ...
                                   'Color'              , ptrRoi.Color, ...
                                   'LineWidth'          , ptrRoi.LineWidth, ...
                                   'Label'              , ptrRoi.Label, ...
                                   'LabelVisible'       , 'on', ...
                                   'Tag'                , sTag, ...
                                   'StripeColor'        , ptrRoi.StripeColor, ...                                                                             
                                   'InteractionsAllowed', ptrRoi.InteractionsAllowed, ...                                      
                                   'UserData'           , ptrRoi.UserData, ...
                                   'Visible'            , 'on' ...
                                   );

            uimenu(pRoi.UIContextMenu, 'Label', 'Copy Contour' , 'UserData', pRoi, 'Callback', @copyRoiCallback, 'Separator', 'on');
            uimenu(pRoi.UIContextMenu, 'Label', 'Paste Contour', 'UserData', pRoi, 'Callback', @pasteRoiCallback);

            uimenu(pRoi.UIContextMenu,'Label', 'Snap To Circles'   , 'UserData',pRoi, 'Callback',@snapLinesToCirclesCallback, 'Separator', 'on');
            uimenu(pRoi.UIContextMenu,'Label', 'Snap To Rectangles', 'UserData',pRoi, 'Callback',@snapLinesToRectanglesCallback);

            uimenu(pRoi.UIContextMenu,'Label', 'Edit Label'     , 'UserData',pRoi, 'Callback',@editLabelCallback, 'Separator', 'on');
            uimenu(pRoi.UIContextMenu,'Label', 'Hide/View Label', 'UserData',pRoi, 'Callback',@hideViewLabelCallback);
            uimenu(pRoi.UIContextMenu,'Label', 'Edit Color'     , 'UserData',pRoi, 'Callback',@editColorCallback);

            constraintMenu(pRoi);

            cropMenu(pRoi);

            uimenu(pRoi.UIContextMenu,'Label', 'Display Result' , 'UserData',pRoi, 'Callback',@figRoiDialogCallback, 'Separator', 'on');

            addRoi(pRoi, get(uiSeriesPtr('get'), 'Value'), 'Unspecified');


        case lower('images.roi.freehand')
            
%             xOffset = ptrRoi.Position(1,1)-clickedPtX;
%             yOffset = ptrRoi.Position(1,2)-clickedPtY;
%             
%             aFreehandPosition = zeros(numel(ptrRoi.Position(:,1)),2);
%             aFreehandPosition(:,1) = ptrRoi.Position(:,1) - xOffset;
%             aFreehandPosition(:,2) = ptrRoi.Position(:,2) - yOffset;
            
            aFreehandPosition = ptrRoi.Position;
                                                        
            % Perform flipping operations
            % Horizontal flip
            aFreehandPosition(:,1) = imgWidth - aFreehandPosition(:,1);

            pRoi = images.roi.Freehand(ptrRoi.Parent, ...
                                       'Position'           , aFreehandPosition, ...
                                       'Smoothing'          , ptrRoi.Smoothing, ...
                                       'Color'              , ptrRoi.Color, ...
                                       'LineWidth'          , ptrRoi.LineWidth, ...
                                       'Label'              , roiLabelName(), ...
                                       'LabelVisible'       , ptrRoi.LabelVisible, ...
                                       'FaceSelectable'     , ptrRoi.FaceSelectable, ...
                                       'FaceAlpha'          , ptrRoi.FaceAlpha, ...
                                       'Tag'                , sTag, ...
                                       'StripeColor'        , ptrRoi.StripeColor, ...                                                                              
                                       'InteractionsAllowed', ptrRoi.InteractionsAllowed, ...                                          
                                       'UserData'           , ptrRoi.UserData, ...
                                       'Visible'            , 'on' ...
                                       );
                                   
            pRoi.Waypoints(:) = ptrRoi.Waypoints(:);

            roiDefaultMenu(pRoi);

            uimenu(pRoi.UIContextMenu, 'Label', 'Hide/View Face Alpha', 'UserData', pRoi, 'Callback', @hideViewFaceAlhaCallback);
            uimenu(pRoi.UIContextMenu, 'Label', 'Clear Waypoints', 'UserData', pRoi, 'Callback', @clearWaypointsCallback);

            constraintMenu(pRoi);

            cropMenu(pRoi);
            
            voiMenu(pRoi);

            uimenu(pRoi.UIContextMenu, 'Label', 'Display Result' , 'UserData', pRoi, 'Callback', @figRoiDialogCallback, 'Separator', 'on');
            
            addRoi(pRoi, get(uiSeriesPtr('get'), 'Value'), 'Unspecified');


        case lower('images.roi.polygon')
            
%             xOffset = ptrRoi.Position(1,1)-clickedPtX;
%             yOffset = ptrRoi.Position(1,2)-clickedPtY;
%             
%             aPolygonPosition = zeros(numel(ptrRoi.Position(:,1)),2);
%             aPolygonPosition(:,1) = ptrRoi.Position(:,1) - xOffset;
%             aPolygonPosition(:,2) = ptrRoi.Position(:,2) - yOffset;

            aPolygonPosition = ptrRoi.Position;

            % Perform flipping operations
            % Horizontal flip
            aPolygonPosition(:,1) = imgWidth - aPolygonPosition(:,1);

            pRoi = images.roi.Polygon(ptrRoi.Parent, ...
                                      'Position'           , aPolygonPosition, ...
                                      'Color'              , ptrRoi.Color, ...
                                      'FaceAlpha'          , ptrRoi.FaceAlpha, ...
                                      'LineWidth'          , ptrRoi.LineWidth, ...
                                      'Label'              , roiLabelName(), ...
                                      'LabelVisible'       , ptrRoi.LabelVisible, ...
                                      'FaceSelectable'     , ptrRoi.FaceSelectable, ...
                                      'FaceAlpha'          , ptrRoi.FaceAlpha, ...
                                      'Tag'                , sTag, ...
                                      'StripeColor'        , ptrRoi.StripeColor, ...                                                                             
                                      'InteractionsAllowed', ptrRoi.InteractionsAllowed, ...                                         
                                      'UserData'           , ptrRoi.UserData, ...
                                      'Visible'            , 'on' ...
                                      );
                                  
            roiDefaultMenu(pRoi);

            uimenu(pRoi.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData', pRoi, 'Callback', @hideViewFaceAlhaCallback);

            constraintMenu(pRoi);

            cropMenu(pRoi);
            
            voiMenu(pRoi);

            uimenu(pRoi.UIContextMenu, 'Label', 'Display Result' , 'UserData', pRoi, 'Callback', @figRoiDialogCallback, 'Separator', 'on');

            addRoi(pRoi, get(uiSeriesPtr('get'), 'Value'), 'Unspecified');
            

        case lower('images.roi.circle')

            aCirclePosition = ptrRoi.Position;

            % Perform flipping operations
            % Horizontal flip
            aCirclePosition(:,1) = imgWidth - aCirclePosition(:,1);

            pRoi = images.roi.Circle(ptrRoi.Parent, ...
                                     'Position'           , aCirclePosition, ...
                                     'Radius'             , ptrRoi.Radius, ...
                                     'Color'              , ptrRoi.Color, ...
                                     'FaceAlpha'          , ptrRoi.FaceAlpha, ...
                                     'LineWidth'          , ptrRoi.LineWidth, ...
                                     'Label'              , roiLabelName(), ...
                                     'LabelVisible'       , ptrRoi.LabelVisible, ...
                                     'FaceSelectable'     , ptrRoi.FaceSelectable, ...
                                     'FaceAlpha'          , ptrRoi.FaceAlpha, ...
                                     'Tag'                , sTag, ...
                                     'StripeColor'        , ptrRoi.StripeColor, ...                                                                             
                                     'InteractionsAllowed', ptrRoi.InteractionsAllowed, ...                                           
                                     'UserData'           , ptrRoi.UserData, ...
                                     'Visible'            , 'on' ...
                                     );

            roiDefaultMenu(pRoi);

            constraintMenu(pRoi);

            cropMenu(pRoi);
            
            voiMenu(pRoi);

            uimenu(pRoi.UIContextMenu, 'Label', 'Display Result' , 'UserData', pRoi, 'Callback', @figRoiDialogCallback, 'Separator', 'on');
            
            addRoi(pRoi, get(uiSeriesPtr('get'), 'Value'), 'Unspecified');

            
        case lower('images.roi.ellipse')

            aEclipsePosition = ptrRoi.Position;

            % Perform flipping operations
            % Horizontal flip
             aEclipsePosition(:,1) = imgWidth - aEclipsePosition(:,1);


            pRoi = images.roi.Ellipse(ptrRoi.Parent, ...
                                      'Position'           , aEclipsePosition, ...
                                      'SemiAxes'           , ptrRoi.SemiAxes, ...
                                      'RotationAngle'      , ptrRoi.RotationAngle, ...
                                      'Color'              , ptrRoi.Color, ...
                                      'FaceAlpha'          , ptrRoi.FaceAlpha, ...
                                      'LineWidth'          , ptrRoi.LineWidth, ...
                                      'Label'              , roiLabelName(), ...
                                      'LabelVisible'       , ptrRoi.LabelVisible, ...
                                      'FaceSelectable'     , ptrRoi.FaceSelectable, ...
                                      'FaceAlpha'          , ptrRoi.FaceAlpha, ...
                                      'Tag'                , sTag, ...
                                      'StripeColor'        , ptrRoi.StripeColor, ...
                                      'InteractionsAllowed', ptrRoi.InteractionsAllowed, ...                                      
                                      'FixedAspectRatio'   , ptrRoi.FixedAspectRatio, ...
                                      'UserData'           , ptrRoi.UserData, ...
                                      'Visible'            , 'on' ...
                                      );

            roiDefaultMenu(pRoi);

            uimenu(pRoi.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData', pRoi, 'Callback', @hideViewFaceAlhaCallback);

            constraintMenu(pRoi);

            cropMenu(pRoi);
            
            voiMenu(pRoi);

            uimenu(pRoi.UIContextMenu, 'Label', 'Display Result' , 'UserData', pRoi, 'Callback', @figRoiDialogCallback, 'Separator', 'on');
            
            addRoi(pRoi, get(uiSeriesPtr('get'), 'Value'), 'Unspecified');
            
            if strcmpi(pRoi.UserData, 'Sphere')

                atRoi = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
                atVoi = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
                
                aRoiTagOffset = strcmp( cellfun( @(atRoi) atRoi.Tag, atRoi, 'uni', false ), {ptrRoi.Tag} );
                dFirstRoiOffset = find(aRoiTagOffset, 1); 
                
                if ~isempty(dFirstRoiOffset)
                    
                    for vv=1:numel(atVoi)

                        pRoisTag   = atVoi{vv}.RoisTag;
                        aTagOffset = strcmp( cellfun( @(pRoisTag) pRoisTag, pRoisTag, 'uni', false ), {ptrRoi.Tag} );

                        if find(aTagOffset, 1) % Found sphere

                            asTag{1} = sTag;
                            
                            switch lower(atRoi{dFirstRoiOffset}.Axe)

                                case 'axe'
                                    sPlane = 'axe';
                                    dLastSlice = 1;

                                case 'axes1'
                                    sPlane = 'coronal';
                                    dLastSlice = size(dicomBuffer('get'), 1);

                                case 'axes2'
                                    dLastSlice = size(dicomBuffer('get'), 2);
                                    sPlane = 'sagittal';

                                case 'axes3'
                                    sPlane = 'axial';
                                    dLastSlice = size(dicomBuffer('get'), 3);
                            end
                            
                            dInitalRoiOffset = sliceNumber('get', sPlane);
                            
                            for rr=1:numel(pRoisTag)

                                if strcmp(pRoisTag{rr}, ptrRoi.Tag)
                                    continue;
                                end

                                aTagOffset = strcmp( cellfun( @(atRoi) atRoi.Tag, atRoi, 'uni', false ), pRoisTag(rr) );
                                dVoiRoiTagOffset = find(aTagOffset, 1);      

                                if ~isempty(dVoiRoiTagOffset)

                                    dSliceOffset =   atRoi{dFirstRoiOffset}.SliceNb - atRoi{dVoiRoiTagOffset}.SliceNb;
                                    
                                    dSliceNumber = dInitalRoiOffset-dSliceOffset;
                                    
                                    if dSliceNumber > dLastSlice || ...
                                       dSliceNumber < 1 
                                        continue;
                                    end
                                    
                                    sliceNumber('set', sPlane, dSliceNumber);                

                                    sTag = num2str(randi([-(2^52/2),(2^52/2)],1));

                                    a = images.roi.Ellipse(pAxe, ...
                                                           'Center'             , pRoi.Center, ...
                                                           'SemiAxes'           , atRoi{dVoiRoiTagOffset}.SemiAxes, ...
                                                           'RotationAngle'      , atRoi{dVoiRoiTagOffset}.RotationAngle, ...
                                                           'Deletable'          , 0, ...
                                                           'FixedAspectRatio'   , atRoi{dVoiRoiTagOffset}.FixedAspectRatio, ...
                                                           'InteractionsAllowed', atRoi{dVoiRoiTagOffset}.InteractionsAllowed, ...
                                                           'StripeColor'        , atRoi{dVoiRoiTagOffset}.StripeColor, ...
                                                           'Color'              , atRoi{dVoiRoiTagOffset}.Color, ...
                                                           'LineWidth'          , atRoi{dVoiRoiTagOffset}.LineWidth, ...
                                                           'Label'              , roiLabelName(), ...
                                                           'LabelVisible'       , 'off', ...
                                                           'Tag'                , sTag, ...
                                                           'FaceSelectable'     , atRoi{dVoiRoiTagOffset}.FaceSelectable, ...
                                                           'FaceAlpha'          , atRoi{dVoiRoiTagOffset}.FaceAlpha, ...
                                                           'UserData'           , atRoi{dVoiRoiTagOffset}.UserData, ...
                                                           'Visible'            , 'off' ...
                                                           );

                                    addRoi(a, get(uiSeriesPtr('get'), 'Value'), 'Unspecified');

                                    asTag{numel(asTag)+1} = sTag;    

                                end   

                            end
                        end
                        
                        createVoiFromRois(get(uiSeriesPtr('get'), 'Value'), asTag, sprintf('Sphere %s mm', num2str(atRoi{dFirstRoiOffset}.MaxDistances.MaxXY.Length)), ptrRoi.Color, 'Unspecified');

                        setVoiRoiSegPopup();

                        sliceNumber('set', sPlane, dInitalRoiOffset);
                        
                        break;
                    end   
                end
            end
                

        case lower('images.roi.rectangle')
                        
            aRectanglePosition = ptrRoi.Position;

            x = aRectanglePosition(1);
            y = aRectanglePosition(2);
            w = aRectanglePosition(3);
            h = aRectanglePosition(4);
            
            % Calculate the new X position for horizontal flip
            newX = imgWidth - x - w;
            
            % Update the rectangle's position
            aRectanglePosition = [newX, y, w, h];

            pRoi = images.roi.Rectangle(ptrRoi.Parent, ...
                                        'Position'           ,aRectanglePosition, ...
                                        'Rotatable'          , ptrRoi.Rotatable, ...
                                        'RotationAngle'      , ptrRoi.RotationAngle, ...
                                        'Color'              , ptrRoi.Color, ...
                                        'FaceAlpha'          , ptrRoi.FaceAlpha, ...
                                        'LineWidth'          , ptrRoi.LineWidth, ...
                                        'Label'              , roiLabelName(), ...
                                        'LabelVisible'       , ptrRoi.LabelVisible, ...
                                        'FaceSelectable'     , ptrRoi.FaceSelectable, ...
                                        'FaceAlpha'          , ptrRoi.FaceAlpha, ...
                                        'Tag'                , sTag, ...
                                        'StripeColor'        , ptrRoi.StripeColor, ...                                                                             
                                        'InteractionsAllowed', ptrRoi.InteractionsAllowed, ...                                           
                                        'FixedAspectRatio'   , ptrRoi.FixedAspectRatio, ...
                                        'UserData'           , ptrRoi.UserData, ...
                                        'Visible'            , 'on' ...
                                        );

            roiDefaultMenu(pRoi);

            uimenu(pRoi.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData', pRoi, 'Callback', @hideViewFaceAlhaCallback);

            constraintMenu(pRoi);

            cropMenu(pRoi);
            
            voiMenu(pRoi);

            uimenu(pRoi.UIContextMenu, 'Label', 'Display Result' , 'UserData', pRoi, 'Callback', @figRoiDialogCallback, 'Separator', 'on');
            
            addRoi(pRoi, get(uiSeriesPtr('get'), 'Value'), 'Unspecified');

        otherwise
            return;
    end
    

%    setVoiRoiSegPopup();


end
