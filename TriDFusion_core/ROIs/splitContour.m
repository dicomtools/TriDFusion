function splitContour(pAxe, pRoiLinePtr)
%function splitContour(pAxe, pRoiLinePtr)
%Split a ROI or VOI in 2 from a line.
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

    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

    atRoiInput = roiTemplate('get', dSeriesOffset);  
    atVoiInput = voiTemplate('get', dSeriesOffset);  

    switch pAxe

        case axePtr('get', [], get(uiSeriesPtr('get'), 'Value'))   
            sAxe = 'Axe';
            dSliceNb = 1;
        case axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) 
            sAxe = 'Axes1';
            dSliceNb = sliceNumber('get', 'coronal' ); 
        case axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) 
            sAxe = 'Axes2';
            dSliceNb = sliceNumber('get', 'sagittal' ); 
        case axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) 
            sAxe = 'Axes3';
            dSliceNb = sliceNumber('get', 'axial' ); 

        otherwise
            return;
    end

    % Get the line's position
    aLinePos = pRoiLinePtr.Position;

    % Initialize the minimum distance and index of the closest ROI
    dMinDistance = inf;
    dClosestRoiIndex = -1;

    for rr=1:numel(atRoiInput)

        if ~strcmpi(atRoiInput{rr}.Type, 'images.roi.freehand') && ...
           ~strcmpi(atRoiInput{rr}.Type, 'images.roi.assistedfreehand')
            continue;
        end
        
        if strcmpi(atRoiInput{rr}.Axe, sAxe) 

            if atRoiInput{rr}.SliceNb == dSliceNb

                aRoiPos = atRoiInput{rr}.Position;
    
                % Calculate the minimum distance from any point in aRoiPos to the line
                aDistances = arrayfun(@(i) minDistancePointToLine(aRoiPos(i, :), aLinePos), 1:size(aRoiPos, 1));
                dMinDistToLine = min(aDistances);
    
                 % Update the closest ROI if this one is closer
                if dMinDistToLine < dMinDistance
                    dMinDistance = dMinDistToLine;
                    dClosestRoiIndex = rr;
                end      
            end
        end
    end

    if dClosestRoiIndex ~= -1

        % 3D VOI

        if strcmpi(atRoiInput{dClosestRoiIndex}.ObjectType, 'voi-roi')

            dVoiOffset = [];
            asRoiTags = [];

            xmin=0.5;
            xmax=1;
            aColor=xmin+rand(1,3)*(xmax-xmin);

            for vo=1:numel(atVoiInput)    

                dTagOffset = find(contains(atVoiInput{vo}.RoisTag, atRoiInput{dClosestRoiIndex}.Tag), 1);

                if ~isempty(dTagOffset) % tag exist
                    dVoiOffset = vo;
                    break;
                end
            end

            if ~isempty(dVoiOffset)

                for vo=1:numel(atVoiInput{dVoiOffset}.RoisTag)

                    atRoiInput = roiTemplate('get', dSeriesOffset);

                    dRoiOffset = find(strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ),  atVoiInput{dVoiOffset}.RoisTag(vo)), 1);
                    if ~isempty(dRoiOffset)

                        aRoiPos = atRoiInput{dRoiOffset}.Position;
                        isOverLine = false;
            
                        % Loop through each segment of the ROI
                        for i = 1:size(aRoiPos, 1)
                            % Get the endpoints of the current ROI segment
                            p1 = aRoiPos(i, :);
                            p2 = aRoiPos(mod(i, size(aRoiPos, 1)) + 1, :);
                        
                            % Check if this segment intersects with the line
                            [bIntersects, ~] = segmentsIntersect(p1, p2, aLinePos(1, :), aLinePos(2, :));
            
                            if bIntersects == true
                                isOverLine = true;
                                break;
                            end
                        end

                        if isOverLine

                            % Initialize arrays to store the vertices of the two new ROIs
                            aRoi1Pos = [];
                            aRoi2Pos = [];
                            
                            % Initialize a list to store the intersection points
                            aIntersectionPoints = [];
                            
                            % Loop through each segment of the ROI
                            for i = 1:size(aRoiPos, 1)
            
                                % Get the endpoints of the current ROI segment
                                p1 = aRoiPos(i, :);
                                p2 = aRoiPos(mod(i, size(aRoiPos, 1)) + 1, :);
                            
                                % Check if this segment intersects with the line
                                [bIntersects, aIntersectionPoint] = segmentsIntersect(p1, p2, aLinePos(1, :), aLinePos(2, :));
                                
                                if bIntersects
                                    % Store the intersection point
                                    aIntersectionPoints = [aIntersectionPoints; aIntersectionPoint];
                                    
                                    % Add the current point p1 to the appropriate ROI
                                    if isPointAboveLine(p1, aLinePos)
                                        aRoi1Pos = [aRoi1Pos; p1];
                                        % Add the intersection point to both ROIs
                                        aRoi1Pos = [aRoi1Pos; aIntersectionPoint];
                                        aRoi2Pos = [aRoi2Pos; aIntersectionPoint];
                                    else
                                        aRoi2Pos = [aRoi2Pos; p1];
                                        % Add the intersection point to both ROIs
                                        aRoi1Pos = [aRoi1Pos; aIntersectionPoint];
                                        aRoi2Pos = [aRoi2Pos; aIntersectionPoint];
                                    end
                                else
                                    % Add the current point p1 to the appropriate ROI
                                    if isPointAboveLine(p1, aLinePos)
                                        aRoi1Pos = [aRoi1Pos; p1];
                                    else
                                        aRoi2Pos = [aRoi2Pos; p1];
                                    end
                                end
                            end
                            
                            % If there are exactly two intersection points, add them to the corresponding ROIs to close the loop
            
                            if size(aIntersectionPoints, 1) == 2
            
                                aRoi1Pos = [aRoi1Pos; aIntersectionPoints(2, :)];
                                aRoi2Pos = [aRoi2Pos; aIntersectionPoints(1, :)];
                            end
                            
                            % Remove duplicate intersection points
                            aRoi1Pos = unique(aRoi1Pos, 'rows', 'stable');
                            aRoi2Pos = unique(aRoi2Pos, 'rows', 'stable');
            
                            % Add ROI 1
            
                            atRoiInput{dRoiOffset}.Position = aRoi1Pos;
            
                            if isvalid(atRoiInput{dRoiOffset}.Object)
                                atRoiInput{dRoiOffset}.Object.Position = aRoi1Pos;
                                atRoiInput{dRoiOffset}.Object.Waypoints(:) = false;
            
                                atRoiInput{dRoiOffset}.Waypoints = atRoiInput{dRoiOffset}.Object.Waypoints;
                            end
            
                            if ~isempty(atRoiInput{dRoiOffset}.MaxDistances)
                
                                if isvalid(atRoiInput{dRoiOffset}.MaxDistances.MaxXY.Line)
                                    delete(atRoiInput{dRoiOffset}.MaxDistances.MaxXY.Line);
                                end
                                
                                if isvalid(atRoiInput{dRoiOffset}.MaxDistances.MaxCY.Line)
                                    delete(atRoiInput{dRoiOffset}.MaxDistances.MaxCY.Line);
                                end
                                
                                if isvalid(atRoiInput{dRoiOffset}.MaxDistances.MaxXY.Text)
                                    delete(atRoiInput{dRoiOffset}.MaxDistances.MaxXY.Text);
                                end
                                
                                if isvalid(atRoiInput{dRoiOffset}.MaxDistances.MaxCY.Text)
                                    delete(atRoiInput{dRoiOffset}.MaxDistances.MaxCY.Text);
                                end
                            end
            
                            tMaxDistances = computeRoiFarthestPoint(dicomBuffer('get', [], dSeriesOffset), dicomMetaData('get', [], dSeriesOffset), atRoiInput{dRoiOffset}, false, false);
            
                            atRoiInput{dRoiOffset}.MaxDistances = tMaxDistances;    
            
                            roiTemplate('set', dSeriesOffset, atRoiInput);

                            % Add ROI 2

                            switch pAxe
                                
                                case axes1Ptr('get', [], dSeriesOffset)     
                    
                                    sliceNumber('set', 'coronal', atRoiInput{dRoiOffset}.SliceNb);
                                                    
                                case axes2Ptr('get', [], dSeriesOffset)
                    
                                    sliceNumber('set', 'sagittal', atRoiInput{dRoiOffset}.SliceNb);
                    
                                 case axes3Ptr('get', [], dSeriesOffset)
                    
                                    sliceNumber('set', 'axial', atRoiInput{dRoiOffset}.SliceNb);
                            end
                            
                            sTag = num2str(randi([-(2^52/2),(2^52/2)],1));

                            roiPtr = images.roi.Freehand(pAxe, ...
                                         'Position'           , aRoi2Pos, ...
                                         'Deletable'          , atRoiInput{dRoiOffset}.Deletable, ...
                                         'Smoothing'          , atRoiInput{dRoiOffset}.Smoothing, ...
                                         'Color'              , aColor, ...
                                         'FaceAlpha'          , roiFaceAlphaValue('get'), ...
                                         'LineWidth'          , atRoiInput{dRoiOffset}.LineWidth, ...
                                         'Label'              , atRoiInput{dRoiOffset}.Label, ...
                                         'LabelVisible'       , atRoiInput{dRoiOffset}.LabelVisible, ...
                                         'FaceSelectable'     , atRoiInput{dRoiOffset}.FaceSelectable, ...
                                         'Tag'                , sTag, ...
                                         'StripeColor'        , atRoiInput{dRoiOffset}.StripeColor, ...
                                         'InteractionsAllowed', atRoiInput{dRoiOffset}.InteractionsAllowed, ...                                                      
                                         'UserData'           , atRoiInput{dRoiOffset}.UserData, ...   
                                         'Visible'            , 'on' ...
                                         );  
                                     
                        
                            roiPtr.Waypoints(:) = false;
                                                       
                            addRoi(roiPtr, dSeriesOffset, atRoiInput{dRoiOffset}.LesionType);
            
                            roiDefaultMenu(roiPtr);
            
                            uimenu(roiPtr.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData',roiPtr, 'Callback', @hideViewFaceAlhaCallback);
                            uimenu(roiPtr.UIContextMenu,'Label', 'Clear Waypoints' , 'UserData',roiPtr, 'Callback', @clearWaypointsCallback);
            
                            constraintMenu(roiPtr);
            
                            cropMenu(roiPtr);
            
                            voiMenu(roiPtr);
            
                            uimenu(roiPtr.UIContextMenu,'Label', 'Display Statistics ' , 'UserData',roiPtr, 'Callback',@figRoiDialogCallback, 'Separator', 'on');

                            asRoiTags{numel(asRoiTags)+1} = sTag;

                        else
                            isOnSameSide = true;

                            % Loop through each point in the ROI position
                            for i = 1:size(aRoiPos, 1)
                                % Check if the current point is on the same side as the first point of aRoi2Pos
                                if isPointAboveLine(aRoiPos(i, :), aLinePos) 
                                    isOnSameSide = false;
                                    break;
                                end
                            end

                            if isOnSameSide == true

                                atRoiInput{dRoiOffset}.Color = aColor;

                                if isvalid(atRoiInput{dRoiOffset}.Object)
                                    atRoiInput{dRoiOffset}.Object.Color = aColor;
                
                                    atRoiInput{dRoiOffset}.Waypoints = atRoiInput{dRoiOffset}.Object.Waypoints;
                                end

                                roiTemplate('set', dSeriesOffset, atRoiInput);

                                asRoiTags{numel(asRoiTags)+1} = atRoiInput{dRoiOffset}.Tag;

%                                 atVoiInput{dVoiOffset}.RoisTag(vo) = [];

                            end

                        end

                    end
                end

                if ~isempty(asRoiTags)

                    bRemoveTagFromVoi = false;

                    for tt=1:numel(asRoiTags)

                        dTagOffset = find(strcmp(atVoiInput{dVoiOffset}.RoisTag, asRoiTags{tt}), 1);
                        if ~isempty(dTagOffset)
                            atVoiInput{dVoiOffset}.RoisTag(dTagOffset) = [];
                            bRemoveTagFromVoi = true;
                        end


                    end
                    
                    if bRemoveTagFromVoi == true
                        atVoiInput{dVoiOffset}.RoisTag(cellfun(@isempty, atVoiInput{dVoiOffset}.RoisTag)) = [];
                        voiTemplate('set', dSeriesOffset, atVoiInput);
                    end

                    createVoiFromRois(dSeriesOffset, asRoiTags, [], aColor, atVoiInput{dVoiOffset}.LesionType);

                end

                switch pAxe
            
                    case axePtr('get', [], get(uiSeriesPtr('get'), 'Value'))   

                    case axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) 
                        sliceNumber('set', 'coronal', dSliceNb); 
                    case axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) 
                        sliceNumber('set', 'sagittal', dSliceNb); 
                    case axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')) 
                        sliceNumber('set', 'axial', dSliceNb); 
            
                    otherwise
                        return;
                end

                setVoiRoiSegPopup();

                plotRotatedRoiOnMip(axesMipPtr('get', [], dSeriesOffset), dicomBuffer('get', [], dSeriesOffset), mipAngle('get'));       

                refreshImages();

            end


        % 2D ROI

        else
           aRoiPos = atRoiInput{dClosestRoiIndex}.Position;
           isOverLine = false;

            % Loop through each segment of the ROI
            for i = 1:size(aRoiPos, 1)
                % Get the endpoints of the current ROI segment
                p1 = aRoiPos(i, :);
                p2 = aRoiPos(mod(i, size(aRoiPos, 1)) + 1, :);
            
                % Check if this segment intersects with the line
                [bIntersects, ~] = segmentsIntersect(p1, p2, aLinePos(1, :), aLinePos(2, :));

                if bIntersects == true
                    isOverLine = true;
                    break;
                end
            end

            if isOverLine == true

                % Initialize arrays to store the vertices of the two new ROIs
                aRoi1Pos = [];
                aRoi2Pos = [];
                
                % Initialize a list to store the intersection points
                aIntersectionPoints = [];
                
                % Loop through each segment of the ROI
                for i = 1:size(aRoiPos, 1)

                    % Get the endpoints of the current ROI segment
                    p1 = aRoiPos(i, :);
                    p2 = aRoiPos(mod(i, size(aRoiPos, 1)) + 1, :);
                
                    % Check if this segment intersects with the line
                    [bIntersects, aIntersectionPoint] = segmentsIntersect(p1, p2, aLinePos(1, :), aLinePos(2, :));
                    
                    if bIntersects
                        % Store the intersection point
                        aIntersectionPoints = [aIntersectionPoints; aIntersectionPoint];
                        
                        % Add the current point p1 to the appropriate ROI
                        if isPointAboveLine(p1, aLinePos)
                            aRoi1Pos = [aRoi1Pos; p1];
                            % Add the intersection point to both ROIs
                            aRoi1Pos = [aRoi1Pos; aIntersectionPoint];
                            aRoi2Pos = [aRoi2Pos; aIntersectionPoint];
                        else
                            aRoi2Pos = [aRoi2Pos; p1];
                            % Add the intersection point to both ROIs
                            aRoi1Pos = [aRoi1Pos; aIntersectionPoint];
                            aRoi2Pos = [aRoi2Pos; aIntersectionPoint];
                        end
                    else
                        % Add the current point p1 to the appropriate ROI
                        if isPointAboveLine(p1, aLinePos)
                            aRoi1Pos = [aRoi1Pos; p1];
                        else
                            aRoi2Pos = [aRoi2Pos; p1];
                        end
                    end
                end
                
                % If there are exactly two intersection points, add them to the corresponding ROIs to close the loop

                if size(aIntersectionPoints, 1) == 2

                    aRoi1Pos = [aRoi1Pos; aIntersectionPoints(2, :)];
                    aRoi2Pos = [aRoi2Pos; aIntersectionPoints(1, :)];
                end
                
                % Remove duplicate intersection points
                aRoi1Pos = unique(aRoi1Pos, 'rows', 'stable');
                aRoi2Pos = unique(aRoi2Pos, 'rows', 'stable');

                % Add ROI 1

                atRoiInput{dClosestRoiIndex}.Position = aRoi1Pos;

                if isvalid(atRoiInput{dClosestRoiIndex}.Object)
                    atRoiInput{dClosestRoiIndex}.Object.Position = aRoi1Pos;
                    atRoiInput{dClosestRoiIndex}.Object.Waypoints(:) = false;

                    atRoiInput{dClosestRoiIndex}.Waypoints = atRoiInput{dClosestRoiIndex}.Object.Waypoints;
                end

                if ~isempty(atRoiInput{dClosestRoiIndex}.MaxDistances)
    
                    if isvalid(atRoiInput{dClosestRoiIndex}.MaxDistances.MaxXY.Line)
                        delete(atRoiInput{dClosestRoiIndex}.MaxDistances.MaxXY.Line);
                    end
                    
                    if isvalid(atRoiInput{dClosestRoiIndex}.MaxDistances.MaxCY.Line)
                        delete(atRoiInput{dClosestRoiIndex}.MaxDistances.MaxCY.Line);
                    end
                    
                    if isvalid(atRoiInput{dClosestRoiIndex}.MaxDistances.MaxXY.Text)
                        delete(atRoiInput{dClosestRoiIndex}.MaxDistances.MaxXY.Text);
                    end
                    
                    if isvalid(atRoiInput{dClosestRoiIndex}.MaxDistances.MaxCY.Text)
                        delete(atRoiInput{dClosestRoiIndex}.MaxDistances.MaxCY.Text);
                    end
                end

                tMaxDistances = computeRoiFarthestPoint(dicomBuffer('get', [], dSeriesOffset), dicomMetaData('get', [], dSeriesOffset), atRoiInput{dClosestRoiIndex}, false, false);

                atRoiInput{dClosestRoiIndex}.MaxDistances = tMaxDistances;    

                roiTemplate('set', dSeriesOffset, atRoiInput);

%                 roiPtr = images.roi.Freehand(pAxe, ...
%                              'Position'           , aRoi1Pos, ...
%                              'Deletable'          , atRoiInput{dClosestRoiIndex}.Deletable, ...
%                              'Smoothing'          , atRoiInput{dClosestRoiIndex}.Smoothing, ...
%                              'Color'              , atRoiInput{dClosestRoiIndex}.Color, ...
%                              'FaceAlpha'          , roiFaceAlphaValue('get'), ...
%                              'LineWidth'          , atRoiInput{dClosestRoiIndex}.LineWidth, ...
%                              'Label'              , atRoiInput{dClosestRoiIndex}.Label, ...
%                              'LabelVisible'       , atRoiInput{dClosestRoiIndex}.LabelVisible, ...
%                              'FaceSelectable'     , atRoiInput{dClosestRoiIndex}.FaceSelectable, ...
%                              'Tag'                , num2str(randi([-(2^52/2),(2^52/2)],1)), ...
%                              'StripeColor'        , atRoiInput{dClosestRoiIndex}.StripeColor, ...
%                              'InteractionsAllowed', atRoiInput{dClosestRoiIndex}.InteractionsAllowed, ...                                                      
%                              'UserData'           , atRoiInput{dClosestRoiIndex}.UserData, ...   
%                              'Visible'            , 'on' ...
%                              );  
%                          
%                 
%                 roiPtr.Waypoints(:) = false;
% 
%                                            
%                 addRoi(roiPtr, dSeriesOffset, atRoiInput{dClosestRoiIndex}.LesionType);
% 
%                 roiDefaultMenu(roiPtr);
% 
%                 uimenu(roiPtr.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData',roiPtr, 'Callback', @hideViewFaceAlhaCallback);
%                 uimenu(roiPtr.UIContextMenu,'Label', 'Clear Waypoints' , 'UserData',roiPtr, 'Callback', @clearWaypointsCallback);
% 
%                 constraintMenu(roiPtr);
% 
%                 cropMenu(roiPtr);
% 
%                 voiMenu(roiPtr);
% 
%                 uimenu(roiPtr.UIContextMenu,'Label', 'Display Statistics ' , 'UserData',roiPtr, 'Callback',@figRoiDialogCallback, 'Separator', 'on');

                % Add ROI 2

                xmin=0.5;
                xmax=1;
                aColor=xmin+rand(1,3)*(xmax-xmin);

                roiPtr = images.roi.Freehand(pAxe, ...
                             'Position'           , aRoi2Pos, ...
                             'Deletable'          , atRoiInput{dClosestRoiIndex}.Deletable, ...
                             'Smoothing'          , atRoiInput{dClosestRoiIndex}.Smoothing, ...
                             'Color'              , aColor, ...
                             'FaceAlpha'          , roiFaceAlphaValue('get'), ...
                             'LineWidth'          , atRoiInput{dClosestRoiIndex}.LineWidth, ...
                             'Label'              , atRoiInput{dClosestRoiIndex}.Label, ...
                             'LabelVisible'       , atRoiInput{dClosestRoiIndex}.LabelVisible, ...
                             'FaceSelectable'     , atRoiInput{dClosestRoiIndex}.FaceSelectable, ...
                             'Tag'                , num2str(randi([-(2^52/2),(2^52/2)],1)), ...
                             'StripeColor'        , atRoiInput{dClosestRoiIndex}.StripeColor, ...
                             'InteractionsAllowed', atRoiInput{dClosestRoiIndex}.InteractionsAllowed, ...                                                      
                             'UserData'           , atRoiInput{dClosestRoiIndex}.UserData, ...   
                             'Visible'            , 'on' ...
                             );  
                         
            
                roiPtr.Waypoints(:) = false;
                                           
                addRoi(roiPtr, dSeriesOffset, atRoiInput{dClosestRoiIndex}.LesionType);

                roiDefaultMenu(roiPtr);

                uimenu(roiPtr.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData',roiPtr, 'Callback', @hideViewFaceAlhaCallback);
                uimenu(roiPtr.UIContextMenu,'Label', 'Clear Waypoints' , 'UserData',roiPtr, 'Callback', @clearWaypointsCallback);

                constraintMenu(roiPtr);

                cropMenu(roiPtr);

                voiMenu(roiPtr);

                uimenu(roiPtr.UIContextMenu,'Label', 'Display Statistics ' , 'UserData',roiPtr, 'Callback',@figRoiDialogCallback, 'Separator', 'on');


%                 % Delete original ROI
% 
%                 sRoiTag = atRoiInput{dClosestRoiIndex}.Tag;
% 
%                 atRoiInput = roiTemplate('get', dSeriesOffset);
% 
%                 % Clear it constraint                
% 
%                 
%                 aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), sRoiTag );            
% 
%                 dTagOffset = find(aTagOffset, 1);
% 
%                 if ~isempty(dTagOffset)
% 
%                     [asConstraintTagList, asConstraintTypeList] = roiConstraintList('get', dSeriesOffset );
%     
%                     if ~isempty(asConstraintTagList)
%     
%                         dConstraintOffset = find(contains(asConstraintTagList, sRoiTag));
%                         if ~isempty(dConstraintOffset) % tag exist
%                              roiConstraintList('set', dSeriesOffset,  asConstraintTagList{dConstraintOffset}, asConstraintTypeList{dConstraintOffset});
%                         end
%                     end
%     
%                     % Delete farthest distance objects
%         
%     
%                     if ~isempty(atRoiInput{dTagOffset}.MaxDistances)
%                         objectsToDelete = [atRoiInput{dTagOffset}.MaxDistances.MaxXY.Line, ...
%                                            atRoiInput{dTagOffset}.MaxDistances.MaxCY.Line, ...
%                                            atRoiInput{dTagOffset}.MaxDistances.MaxXY.Text, ...
%                                            atRoiInput{dTagOffset}.MaxDistances.MaxCY.Text];
%                         delete(objectsToDelete(isvalid(objectsToDelete)));
%                     end                   
%                     
%                     % Delete ROI object 
%                     
%                     if isvalid(atRoiInput{dTagOffset}.Object)
%                         delete(atRoiInput{dTagOffset}.Object)
%                     end
%     
%                     atRoiInput{dTagOffset} = [];               
%     
%                     atRoiInput(cellfun(@isempty, atRoiInput)) = [];
%     
%                     roiTemplate('set', dSeriesOffset, atRoiInput);
%                 end
                refreshImages();

                if size(dicomBuffer('get', [], dSeriesOffset), 3) ~= 1
                    
                    plotRotatedRoiOnMip(axesMipPtr('get', [], dSeriesOffset), dicomBuffer('get', [], dSeriesOffset), mipAngle('get'));       
                end               

            end
        end
    end


    function d = minDistancePointToLine(aPoint, aLinePos)
        % Line endpoints
        x1 = aLinePos(1, 1); y1 = aLinePos(1, 2);
        x2 = aLinePos(2, 1); y2 = aLinePos(2, 2);
        
        % Point coordinates
        px = aPoint(1); py = aPoint(2);
        
        % Line vector
        aLineVec = [x2 - x1, y2 - y1];
        
        % Vector from line start to the point
        startToPointVec = [px - x1, py - y1];
        
        % Projection of startToPointVec onto aLineVec
        dProjLength = dot(startToPointVec, aLineVec) / norm(aLineVec)^2;
        
        if dProjLength < 0
            % Closest to line start
            aClosestPoint = [x1, y1];
        elseif dProjLength > 1
            % Closest to line end
            aClosestPoint = [x2, y2];
        else
            % Closest point is on the line
            aClosestPoint = [x1, y1] + dProjLength * aLineVec;
        end
        
        % Calculate distance from the point to the closest point on the line
        d = norm([px, py] - aClosestPoint);
    end

    % Helper function to check if two line segments intersect and return the intersection point
    function [bIntersects, aIntersectionPoint] = segmentsIntersect(p1, p2, q1, q2)
        % Calculate the direction of the points
        d1 = direction(q1, q2, p1);
        d2 = direction(q1, q2, p2);
        d3 = direction(p1, p2, q1);
        d4 = direction(p1, p2, q2);
    
        bIntersects = false;
        aIntersectionPoint = [];
    
        % Check for general case of intersection
        if ((d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0)) && ((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0))
            bIntersects = true;
        end
    
        % Check for special cases (collinear points)
        if d1 == 0 && onSegment(q1, q2, p1)
            bIntersects = true;
            aIntersectionPoint = p1;
        end
        if d2 == 0 && onSegment(q1, q2, p2)
            bIntersects = true;
            aIntersectionPoint = p2;
        end
        if d3 == 0 && onSegment(p1, p2, q1)
            bIntersects = true;
            aIntersectionPoint = q1;
        end
        if d4 == 0 && onSegment(p1, p2, q2)
            bIntersects = true;
            aIntersectionPoint = q2;
        end
    
        if isempty(aIntersectionPoint) && bIntersects
            % Calculate the intersection point for the general case
            [aIntersectionPoint] = calculateIntersection(p1, p2, q1, q2);
        end
    end
    
    % Helper function to calculate the direction of the triplet (p, q, r)
    function dir = direction(p, q, r)
        dir = (r(2) - p(2)) * (q(1) - p(1)) - (q(2) - p(2)) * (r(1) - p(1));
    end
    
    % Helper function to check if point r is on the segment pq
    function isOn = onSegment(p, q, r)
        isOn = min(p(1), q(1)) <= r(1) && r(1) <= max(p(1), q(1)) && ...
               min(p(2), q(2)) <= r(2) && r(2) <= max(p(2), q(2));
    end
   
    
    % Helper function to determine if a point is above the line
    function isAbove = isPointAboveLine(point, linePos)
        % Line equation: y = mx + b
        % Compute the slope (m) and intercept (b)
        m = (linePos(2, 2) - linePos(1, 2)) / (linePos(2, 1) - linePos(1, 1));
        b = linePos(1, 2) - m * linePos(1, 1);
    
        % Check if the point is above the line
        isAbove = point(2) > m * point(1) + b;
    end
    
    % Function to calculate the intersection point of two line segments
    function aIntersectionPoint = calculateIntersection(p1, p2, q1, q2)
        % Line 1 represented as a1x + b1y = c1
        a1 = p2(2) - p1(2);
        b1 = p1(1) - p2(1);
        c1 = a1 * p1(1) + b1 * p1(2);
    
        % Line 2 represented as a2x + b2y = c2
        a2 = q2(2) - q1(2);
        b2 = q1(1) - q2(1);
        c2 = a2 * q1(1) + b2 * q1(2);
    
        % Calculate the determinant
        determinant = a1 * b2 - a2 * b1;
    
        % If the determinant is zero, the lines are parallel
        if determinant == 0
            aIntersectionPoint = [];
        else
            % Intersection point
            x = (b2 * c1 - b1 * c2) / determinant;
            y = (a1 * c2 - a2 * c1) / determinant;
            aIntersectionPoint = [x, y];
        end
    end
end