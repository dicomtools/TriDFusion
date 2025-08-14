function deleteContourObject(pVoiRoiTag, dSeriesOffset)
%function deleteContourObject(pVoiRoiTag, dSeriesOffset)
% Delete a contour object from the ROI/VOI templates.
%
% Syntax:
%   deleteContourObject(pVoiRoiTag, dSeriesOffset)
%
% Description:
%   This function removes a contour object identified by the provided tag from the
%   appropriate ROI or VOI template corresponding to the specified series offset.
%   For detailed information about available options, see the TriDFusion documentation
%   (TriDFusion.doc or TriDFusion.pdf).
%
% Inputs:
%   pVoiRoiTag    - Tag associated with the VOI or ROI to be deleted.
%   dSeriesOffset - Series offset index in the templates.
%
% Outputs:
%   None.
%
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2025, Daniel Lafontaine, on behalf of the TriDFusion development team.
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
% along with TriDFusion.  If not, see <http://www.gnu.org/licenses/>
    
    if isempty(pVoiRoiTag)
        return;
    end

    atRoiInput = roiTemplate('get', dSeriesOffset);
    atVoiInput = voiTemplate('get', dSeriesOffset);

    atRoiInputBack = roiTemplate('get', dSeriesOffset);
    atVoiInputBack = voiTemplate('get', dSeriesOffset);

    dUID = generateUniqueNumber(false);

    if ~isempty(pVoiRoiTag)

        % Search for a voi tag, if we don't find one, then the tag is
        % roi

        if isempty(atVoiInput)
            aTagOffset = 0;
        else
            aTagOffset = strcmp( cellfun( @(atVoiInput) atVoiInput.Tag, atVoiInput, 'uni', false ), pVoiRoiTag );
        end

        if aTagOffset(aTagOffset==1) % tag is a voi

            dTagOffset = find(aTagOffset, 1);

            if ~isempty(dTagOffset)

                % Clear roi from roi input template

                % aRoisTagOffset = zeros(1, numel(atVoiInput{dTagOffset}.RoisTag));
                if ~isempty(atRoiInput)

                    % for ro=1:numel(atVoiInput{dTagOffset}.RoisTag)
                    % 
                    %     aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[atVoiInput{dTagOffset}.RoisTag{ro}]} );
                    %     aRoisTagOffset(ro) = find(aTagOffset, 1);
                    % end

                    % Precompute all tags from atRoiInput once
                    allRoiTags = cellfun(@(roi) roi.Tag, atRoiInput, 'UniformOutput', false);
                    
                    % Use vectorized ismember to get the first occurrence index for each tag
                    [~, aRoisTagOffset] = ismember(atVoiInput{dTagOffset}.RoisTag, allRoiTags);

                    if numel(atVoiInput{dTagOffset}.RoisTag)

                        for ro=1:numel(atVoiInput{dTagOffset}.RoisTag)

                            % Clear it constraint

                            [asConstraintTagList, asConstraintTypeList] = roiConstraintList('get', get(uiSeriesPtr('get'), 'Value') );

                            if ~isempty(asConstraintTagList)

                                dConstraintOffset = find(contains(asConstraintTagList, atVoiInput{dTagOffset}.RoisTag(ro)));
                                if ~isempty(dConstraintOffset) % tag exist
                                     roiConstraintList('set', dSeriesOffset,  asConstraintTagList{dConstraintOffset}, asConstraintTypeList{dConstraintOffset});
                                end
                            end

                            % Delete farthest distance objects

                            if roiHasMaxDistances(atRoiInput{aRoisTagOffset(ro)}) == true

                                maxDistances = atRoiInput{aRoisTagOffset(ro)}.MaxDistances; % Cache the MaxDistances field
                                objectsToDelete = [maxDistances.MaxXY.Line, ...
                                                   maxDistances.MaxCY.Line, ...
                                                   maxDistances.MaxXY.Text, ...
                                                   maxDistances.MaxCY.Text];
                                % Delete only valid objects
                                delete(objectsToDelete(isvalid(objectsToDelete)));                                   
                            end

                            % Delete ROI object

                            if isvalid(atRoiInput{aRoisTagOffset(ro)}.Object)

                                delete(atRoiInput{aRoisTagOffset(ro)}.Object)
                            end

                            atRoiInput{aRoisTagOffset(ro)} = [];
                            
                        end

                        atRoiInput(cellfun(@isempty, atRoiInput)) = [];

                        roiTemplate('set', dSeriesOffset, atRoiInput);

                        roiTemplateEvent('add', dSeriesOffset, atRoiInputBack, atRoiInput, dUID);
                    end
                end

                % Clear voi from voi input template

                atVoiInput(dTagOffset) = [];
                atVoiInput(cellfun(@isempty, atVoiInput)) = [];

                voiTemplate('set', dSeriesOffset, atVoiInput);

                voiTemplateEvent('add', dSeriesOffset, atVoiInputBack, atVoiInput, dUID);

                % Refresh contour figure

                setVoiRoiSegPopup();
                
                enableUndoVoiRoiPanel();

                if size(dicomBuffer('get', [], dSeriesOffset), 3) ~= 1

                    if dSeriesOffset == get(uiSeriesPtr('get'), 'Value')

                        plotRotatedRoiOnMip(axesMipPtr('get', [], dSeriesOffset), dicomBuffer('get', [], dSeriesOffset), mipAngle('get'));
                    end
                end
            end

        else % Tag is a ROI

            if isempty(atRoiInput)
                aTagOffset = 0;
            else
                aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), pVoiRoiTag );
            end

            if aTagOffset(aTagOffset==1) % tag is a roi

                dTagOffset = find(aTagOffset, 1);

                if ~isempty(dTagOffset)

                    % Clear it constraint

                    [asConstraintTagList, asConstraintTypeList] = roiConstraintList('get', dSeriesOffset);

                    if ~isempty(asConstraintTagList)

                        dConstraintOffset = find(contains(asConstraintTagList, {pVoiRoiTag}));
                        if ~isempty(dConstraintOffset) % tag exist
                             roiConstraintList('set', dSeriesOffset,  asConstraintTagList{dConstraintOffset}, asConstraintTypeList{dConstraintOffset});
                        end
                    end

                    % Delete farthest distance objects

                    if roiHasMaxDistances(atRoiInput{dTagOffset}) == true
  
                        maxDistances = atRoiInput{dTagOffset}.MaxDistances; % Cache the field to avoid repeated lookups
                        objectsToDelete = [maxDistances.MaxXY.Line, ...
                                           maxDistances.MaxCY.Line, ...
                                           maxDistances.MaxXY.Text, ...
                                           maxDistances.MaxCY.Text];
                        % Delete only valid objects
                        delete(objectsToDelete(isvalid(objectsToDelete)));
                    end
                    
                    % Delete ROI object

                    if isvalid(atRoiInput{dTagOffset}.Object)

                        delete(atRoiInput{dTagOffset}.Object)
                    end

                    atRoiInput(dTagOffset) = [];
                    atRoiInput(cellfun(@isempty, atRoiInput)) = [];

                    roiTemplate('set', dSeriesOffset, atRoiInput);

                    roiTemplateEvent('add', dSeriesOffset, atRoiInputBack, atRoiInput, dUID);

                    % Clear roi from voi input template (if exist)

                    if ~isempty(atVoiInput)

                        for vo=1:numel(atVoiInput)

                            dTagOffset = find(contains(atVoiInput{vo}.RoisTag, pVoiRoiTag));

                            if ~isempty(dTagOffset) % tag exist
                                atVoiInput{vo}.RoisTag{dTagOffset} = [];
                                atVoiInput{vo}.RoisTag(cellfun(@isempty, atVoiInput{vo}.RoisTag)) = [];

                                if isempty(atVoiInput{vo}.RoisTag)
                                    atVoiInput{vo} = [];
                                else
                                    % Rename voi-roi label
                                    atRoiInput = roiTemplate('get', dSeriesOffset);

                                    dNbTags = numel(atVoiInput{vo}.RoisTag);

                                    for dRoiNb=1:dNbTags

                                        aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), atVoiInput{vo}.RoisTag{dRoiNb} );

                                        if ~isempty(aTagOffset)

                                            dTagOffset = find(aTagOffset, 1);

                                            if~isempty(dTagOffset)

                                                sLabel = sprintf('%s (roi %d/%d)', atVoiInput{vo}.Label, dRoiNb, dNbTags);

                                                atRoiInput{dTagOffset}.Label = sLabel;
                                                atRoiInput{dTagOffset}.Object.Label = sLabel;
                                           end
                                        end
                                    end

                                    roiTemplate('set', dSeriesOffset, atRoiInput);
                               end

                            end
                        end

                       atVoiInput(cellfun(@isempty, atVoiInput)) = [];

                       voiTemplate('set', dSeriesOffset, atVoiInput);

                       voiTemplateEvent('add', dSeriesOffset, atVoiInputBack, atVoiInput, dUID);

                    end

                    setVoiRoiSegPopup();

                    enableUndoVoiRoiPanel();

                    if size(dicomBuffer('get', [], dSeriesOffset), 3) ~= 1

                        if dSeriesOffset == get(uiSeriesPtr('get'), 'Value')

                            plotRotatedRoiOnMip(axesMipPtr('get', [], dSeriesOffset), dicomBuffer('get', [], dSeriesOffset), mipAngle('get'));
                        end
                    end

                end
            end
        end
    end
end