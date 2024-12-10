function brushRoi2D(he, hf, xSize, ySize, dVoiOffset, sLesionType, dSerieOffset)
%function  brushRoi2D(he, hf, xSize, ySize, dVoiOffset, sLesionType, dSerieOffset)
%Edit an ROI position from another ROI position.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2023, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    try

    bMATLABReleaseOlderThan2023b = true;
    if isMATLABReleaseOlderThan('R2023b')
        
        bMATLABReleaseOlderThan2023b = true;
    end

    xSize = xSize+1;
    ySize = ySize+1;

    hfMask = poly2mask(hf.Position(:,1), hf.Position(:,2), xSize, ySize);
    hfPos = round(hf.Position);
    hfMask(sub2ind([xSize, ySize], hfPos(:, 2), hfPos(:, 1))) = true;

    heMask = poly2mask(he.Vertices(:, 1), he.Vertices(:, 2), xSize, ySize);
    hePos = round(he.Position);
    heMask(sub2ind([xSize, ySize], hePos(:, 2), hePos(:, 1))) = true;

    center = he.Center;

    if hf.inROI(center(1), center(2))
        newMask = hfMask | heMask;
    else
        newMask = hfMask & ~heMask;
    end

    if any(hfMask(:) ~= newMask(:))

        if pixelEdge('get') == true

           if bMATLABReleaseOlderThan2023b == true 

                newMask = imresize(newMask, 3, 'nearest');
                [B,~,n,~] = bwboundaries(newMask, 4, 'noholes');
           else
                [B,~,n,~] = bwboundaries(newMask, 4, 'noholes','TraceStyle', 'pixeledge');
           end
        else
            [B,~,n,~] = bwboundaries(newMask, 4, 'noholes');  
        end

        clear hfMask;
        clear heMask;
        clear newMask;

        bDeleteRoi = false;
        if n == 1
            if size(B{1}, 1) < 3
                bDeleteRoi = true;
            end
        end

        if isempty(B) || bDeleteRoi == true

            deleteRoiEvents(hf);

        else
            if ~isempty(dVoiOffset)

                if get(uiDeleteVoiRoiPanelObject('get'), 'Value') ~= dVoiOffset

                    set(uiDeleteVoiRoiPanelObject('get'), 'Value', dVoiOffset);

                    if ~isempty(sLesionType)

                        set(uiLesionTypeVoiRoiPanelObject('get'), 'Value', getLesionType(sLesionType));
                    end
                end
            end

            if n > 1

                dBoundaryOffset = getLargestboundary(B);

                B2 = B;
                B2(dBoundaryOffset) = [];

                dSecondBoundaryOffset = getLargestboundary(B2);

                if pixelEdge('get')
                    
                    if bMATLABReleaseOlderThan2023b == true

                        B2{dSecondBoundaryOffset} = (B2{dSecondBoundaryOffset} + 1) / 3;
                        % B2{dSecondBoundaryOffset} = reducepoly(B2{dSecondBoundaryOffset});
                    end
                else
                    B2{dSecondBoundaryOffset} = smoothRoi(B2{dSecondBoundaryOffset}, [xSize, ySize]);
                end

                 if size(B2{dSecondBoundaryOffset}, 1) > 10

                      addFreehandRoi(he.Parent, [B2{dSecondBoundaryOffset}(:, 2), B2{dSecondBoundaryOffset}(:, 1)], dVoiOffset, hf.Color, sLesionType, dSerieOffset);
                 end
            else
                dBoundaryOffset = 1;
            end

            if pixelEdge('get') == true
                
                if bMATLABReleaseOlderThan2023b == true

                    B{dBoundaryOffset} = (B{dBoundaryOffset} + 1) / 3;
                    % B{dBoundaryOffset} = reducepoly(B{dBoundaryOffset});
                else
                    % boundaryMatrix = B{dBoundaryOffset};
                    % boundaryMatrix(:, 1) = boundaryMatrix(:, 1) - 0.1;
                    % B{dBoundaryOffset} = boundaryMatrix;    
                end
            else
                B{dBoundaryOffset} = smoothRoi(B{dBoundaryOffset}, [xSize, ySize]);
            end

            hf.Position = [B{dBoundaryOffset}(:, 2), B{dBoundaryOffset}(:, 1)];

        end
    end
    catch
    end

    function largestBoundary = getLargestboundary(cBoundaries)

        % Find the index of the largest boundary

        [~, largestBoundary] = max(cellfun(@(x) size(x, 1), cBoundaries));

        % % Initialize variables to keep track of the largest boundary and its size
        % largestBoundary = 1;
        % largestSize = 0;
        %
        % % Determine the number of boundaries outside the loop for efficiency
        % numBoundaries = length(cBoundaries);

        % % Loop through each boundary in 'B'
        % for k = 1:numBoundaries
        %     % Get the current boundary
        %     boundary = cBoundaries{k};
        %
        %     % Calculate the size of the current boundary
        %     boundarySize = size(boundary, 1);
        %
        %     % Check if the current boundary is larger than the previous largest
        %     if boundarySize > largestSize
        %
        %         largestSize = boundarySize;
        %         largestBoundary = k;
        %     end
        % end
    end

    function addFreehandRoi(pAxe, aPosition, dVoiOffset, aColor, sLesionType, dSerieOffset)

        % pAxe = gca(fiMainWindowPtr('get'));

        % pAxe = getAxeFromMousePosition(get(uiSeriesPtr('get'), 'Value'));
        %
        % if isempty(pAxe)
        %     return;
        % end

        sRoiTag = num2str(randi([-(2^52/2),(2^52/2)],1));

        pRoi = images.roi.Freehand(pAxe, 'Color', aColor,'Position', aPosition, 'lineWidth', 1, 'Label', roiLabelName(), 'LabelVisible', 'off', 'Tag', sRoiTag, 'FaceSelectable', 1, 'FaceAlpha', roiFaceAlphaValue('get'));

        if ~isempty(pRoi.Waypoints(:))

            pRoi.Waypoints(:) = false;
        end
        
        % Add ROI right click menu

        addRoi(pRoi, dSerieOffset, sLesionType);
        
        addRoiMenu(pRoi);

        % addlistener(pRoi, 'WaypointAdded'  , @waypointEvents);
        % addlistener(pRoi, 'WaypointRemoved', @waypointEvents);  

        pRoi.InteractionsAllowed = 'none';

        % 
        % voiDefaultMenu(pRoi);
        % 
        % roiDefaultMenu(pRoi);
        % 
        % uimenu(pRoi.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData', pRoi, 'Callback', @hideViewFaceAlhaCallback);
        % uimenu(pRoi.UIContextMenu,'Label', 'Clear Waypoints'     , 'UserData', pRoi, 'Callback', @clearWaypointsCallback);
        % 
        % constraintMenu(pRoi);
        % 
        % cropMenu(pRoi);
        % 
        % uimenu(pRoi.UIContextMenu,'Label', 'Display Statistics ' , 'UserData', pRoi, 'Callback',@figRoiDialogCallback, 'Separator', 'on');

        if ~isempty(dVoiOffset)

            atVoiInput = voiTemplate('get', dSerieOffset);

            atVoiInput{dVoiOffset}.RoisTag{end+1} = sRoiTag;

            atRoiInput = roiTemplate('get', dSerieOffset);

            % if ~isempty(atRoiInput)
            % 
            %     dTagOffset = find(strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), sRoiTag ), 1);
            % 
            %     if ~isempty(dTagOffset)

                    % voiDefaultMenu(atRoiInput{dTagOffset}.Object, atVoiInput{dVoiOffset}.Tag);

                    dNbTags = numel(atVoiInput{dVoiOffset}.RoisTag);

                    allTags = cellfun(@(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false);

                    for dRoiNb = 1:dNbTags % Loop over the number of tags

                        % Find matching tag offset outside the loop
                        dTagOffset = find(strcmp(allTags, atVoiInput{dVoiOffset}.RoisTag{dRoiNb}), 1);

                        if ~isempty(dTagOffset) % If valid offset found, update the label

                            sLabel = sprintf('%s (roi %d/%d)', atVoiInput{dVoiOffset}.Label, dRoiNb, dNbTags);

                            % Update fields in the structure
                            atRoiInput{dTagOffset}.Label = sLabel;
                            atRoiInput{dTagOffset}.Object.Label = sLabel;
                            atRoiInput{dTagOffset}.ObjectType  = 'voi-roi';
                            atRoiInput{dTagOffset}.Object.UserData = 'voi-roi';
                        end
                    end

            %     end
            % 
            % end

            roiTemplate('set', dSerieOffset, atRoiInput);
            voiTemplate('set', dSerieOffset, atVoiInput);
        end
    end
end
