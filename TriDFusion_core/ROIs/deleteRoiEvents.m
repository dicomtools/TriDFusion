function deleteRoiEvents(hObject, ~)
%function deleteRoiEvents(hObject,~)
%Delete ROI\VOI Event.
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

    sRoiTag = hObject.Tag;

    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

    atRoiInput = roiTemplate('get', dSeriesOffset);
    atVoiInput = voiTemplate('get', dSeriesOffset);  

    atRoiInputBack = roiTemplate('get', dSeriesOffset);
    atVoiInputBack = voiTemplate('get', dSeriesOffset);

    % Clear it constraint

    [asConstraintTagList, asConstraintTypeList] = roiConstraintList('get', dSeriesOffset);

    if ~isempty(asConstraintTagList)

        dConstraintOffset = find(contains(asConstraintTagList, {sRoiTag}));

        if ~isempty(dConstraintOffset) % tag exist
             roiConstraintList('set', dSeriesOffset,  asConstraintTagList{dConstraintOffset}, asConstraintTypeList{dConstraintOffset});
        end    
    end
    
    if isempty(atRoiInput) 
        aTagOffset = 0;
    else
        aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {sRoiTag} );            
    end
    
    if aTagOffset(aTagOffset==1) % tag is a roi

        dTagOffset = find(aTagOffset, 1);

        if ~isempty(dTagOffset)

            % Delete farthest distance objects

            % Farthest distance are dynamically computed as needed.

            if roiHasMaxDistances(atRoiInput{dTagOffset}) == true

                maxDistances = atRoiInput{dTagOffset}.MaxDistances; % Cache field to avoid repeated lookup

                objectsToDelete = [maxDistances.MaxXY.Line, ...
                                   maxDistances.MaxCY.Line, ...
                                   maxDistances.MaxXY.Text, ...
                                   maxDistances.MaxCY.Text];
                
                delete(objectsToDelete(isvalid(objectsToDelete))); % Perform deletion on the filtered list
              
                atRoiInput{dTagOffset} = rmfield(atRoiInput{dTagOffset}, 'MaxDistances');                                                       
            end

            % Delete ROI object 
            
            if isvalid(atRoiInput{dTagOffset}.Object)

                delete(atRoiInput{dTagOffset}.Object)
            end

            atRoiInput(dTagOffset) = [];
            atRoiInput(cellfun(@isempty, atRoiInput)) = [];
           
            roiTemplate('set', dSeriesOffset, atRoiInput);  
            
            dUID = generateUniqueNumber(false);
            roiTemplateEvent('add', dSeriesOffset, atRoiInputBack, atRoiInput, dUID);

            % dUID = generateUniqueNumber(false);
            % 
            % roiTemplateEvent('add', dSeriesOffset, atRoiInputBack, atRoiInput, dUID);

  %          atRoiInput(cellfun(@isempty, atRoiInput)) = [];


            % Clear roi from voi input template (if exist)

            if ~isempty(atVoiInput)

                removeVoiIdx = false(1, numel(atVoiInput)); % Preallocate logical index for removal
            
                for vo = 1:numel(atVoiInput)
                    
                    roiTags = atVoiInput{vo}.RoisTag;
            
                    dTagOffset = find(contains(roiTags, sRoiTag), 1); % Find first match only
            
                    if ~isempty(dTagOffset)
                        
                        roiTags(dTagOffset) = []; % Remove tag
                        atVoiInput{vo}.RoisTag = roiTags;
            
                        if isempty(roiTags)
                            removeVoiIdx(vo) = true; % Mark for removal
                        end
                    end
                end
            
                % Remove empty VOIs in one step
                atVoiInput(removeVoiIdx) = [];
            
                voiTemplate('set', dSeriesOffset, atVoiInput);
                voiTemplateEvent('add', dSeriesOffset, atVoiInputBack, atVoiInput, dUID);
            end

            % Refresh contour popup

            setVoiRoiSegPopup();

            enableUndoVoiRoiPanel();

        end
    end
    
    if size(dicomBuffer('get', [], dSeriesOffset), 3) ~= 1 && is2DBrush('get') == false

        plotRotatedRoiOnMip(axesMipPtr('get', [], dSeriesOffset), dicomBuffer('get', [], dSeriesOffset), mipAngle('get'));       
    end

    drawnow; % Force refresh
end
