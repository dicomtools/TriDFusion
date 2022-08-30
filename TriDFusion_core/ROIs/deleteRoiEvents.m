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

    dSerieOffset = get(uiSeriesPtr('get'), 'Value');

    atInput = inputTemplate('get');

    atRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
    atVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));  
            
    % Clear it constraint

    [asConstraintTagList, asConstraintTypeList] = roiConstraintList('get', dSerieOffset);

    if ~isempty(asConstraintTagList)
        dConstraintOffset = find(contains(asConstraintTagList, {sRoiTag}));
        if ~isempty(dConstraintOffset) % tag exist
             roiConstraintList('set', dSerieOffset,  asConstraintTagList{dConstraintOffset}, asConstraintTypeList{dConstraintOffset});
        end    
    end
    
    aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {sRoiTag} );            

    if aTagOffset(aTagOffset==1) % tag is a roi

        if ~isempty(atRoiInput) 

            dTagOffset = find(aTagOffset, 1);

            if ~isempty(dTagOffset)

                % Delete ROI object 

                if isvalid(atRoiInput{dTagOffset}.Object)
                    delete(atRoiInput{dTagOffset}.Object)
                end

                % Delete farthest distance object

                if ~isempty(atRoiInput{dTagOffset}.MaxDistances)
                    if isvalid(atRoiInput{dTagOffset}.MaxDistances.MaxXY.Line)
                        delete(atRoiInput{dTagOffset}.MaxDistances.MaxXY.Line);
                    end

                    if isvalid(atRoiInput{dTagOffset}.MaxDistances.MaxCY.Line)
                        delete(atRoiInput{dTagOffset}.MaxDistances.MaxCY.Line);
                    end

                    if isvalid(atRoiInput{dTagOffset}.MaxDistances.MaxXY.Text)
                        delete(atRoiInput{dTagOffset}.MaxDistances.MaxXY.Text);
                    end

                    if isvalid(atRoiInput{dTagOffset}.MaxDistances.MaxCY.Text)
                        delete(atRoiInput{dTagOffset}.MaxDistances.MaxCY.Text);
                    end
                end                        

                atRoiInput{dTagOffset} = [];

                atRoiInput(cellfun(@isempty, atRoiInput)) = [];

                roiTemplate('set', dSerieOffset, atRoiInput);  

                % Clear roi from input template tRoi

                if isfield(atInput(dSerieOffset), 'tRoi')

                    atInputRoi = atInput(dSerieOffset).tRoi;
                    aTagOffset = strcmp( cellfun( @(atInputRoi) atInputRoi.Tag, atInputRoi, 'uni', false ), {sRoiTag} );

                    dTagOffset = find(aTagOffset, 1);  

                    if ~isempty(dTagOffset)
                        atInput(dSerieOffset).tRoi{dTagOffset} = [];

                        atInput(dSerieOffset).tRoi(cellfun(@isempty, atInput(dSerieOffset).tRoi)) = [];

                        inputTemplate('set', atInput);  
                    end
                end

                % Clear roi from voi input template (if exist)

                if ~isempty(atVoiInput)                        

                    for vo=1:numel(atVoiInput)     

                        dTagOffset = find(contains(atVoiInput{vo}.RoisTag,{sRoiTag}));

                        if ~isempty(dTagOffset) % tag exist
                            atVoiInput{vo}.RoisTag{dTagOffset} = [];
                            atVoiInput{vo}.RoisTag(cellfun(@isempty, atVoiInput{vo}.RoisTag)) = [];     

                            if isempty(atVoiInput{vo}.RoisTag)
                                atVoiInput{vo} = [];
                           end

                        end
                    end

                   atVoiInput(cellfun(@isempty, atVoiInput)) = [];

                   voiTemplate('set', dSerieOffset, atVoiInput);                                        
                end

                % Clear roi from input tVoi template (if exist)

                if isfield(atInput(dSerieOffset), 'tVoi')

                    for vo=1:numel(atInput(dSerieOffset).tVoi)     

                        dTagOffset = find(contains(atInput(dSerieOffset).tVoi{vo}.RoisTag,{sRoiTag}));

                        if ~isempty(dTagOffset) % tag exist
                            atInput(dSerieOffset).tVoi{vo}.RoisTag{dTagOffset} = [];
                            atInput(dSerieOffset).tVoi{vo}.RoisTag(cellfun(@isempty, atInput(dSerieOffset).tVoi{vo}.RoisTag)) = [];     

                            if isempty(atInput(dSerieOffset).tVoi{vo}.RoisTag)
                                atInput(dSerieOffset).tVoi{vo} = [];
                           end

                        end
                    end

                   atInput(dSerieOffset).tVoi(cellfun(@isempty, atInput(dSerieOffset).tVoi)) = [];

                   inputTemplate('set', atInput);                
                end

                % Refresh contour popup

                setVoiRoiSegPopup();

            end
        end
    end

end
