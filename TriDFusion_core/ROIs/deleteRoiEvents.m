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

    atRoiInput = roiTemplate('get', dSerieOffset);
    atVoiInput = voiTemplate('get', dSerieOffset);  
            
    % Clear it constraint

    [asConstraintTagList, asConstraintTypeList] = roiConstraintList('get', dSerieOffset);

    if ~isempty(asConstraintTagList)

        dConstraintOffset = find(contains(asConstraintTagList, {sRoiTag}));

        if ~isempty(dConstraintOffset) % tag exist
             roiConstraintList('set', dSerieOffset,  asConstraintTagList{dConstraintOffset}, asConstraintTypeList{dConstraintOffset});
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

            if ~isempty(atRoiInput{dTagOffset}.MaxDistances)
                objectsToDelete = [atRoiInput{dTagOffset}.MaxDistances.MaxXY.Line, ...
                                   atRoiInput{dTagOffset}.MaxDistances.MaxCY.Line, ...
                                   atRoiInput{dTagOffset}.MaxDistances.MaxXY.Text, ...
                                   atRoiInput{dTagOffset}.MaxDistances.MaxCY.Text];
                delete(objectsToDelete(isvalid(objectsToDelete)));
            end                   
            
            % Delete ROI object 
            
            if isvalid(atRoiInput{dTagOffset}.Object)

                delete(atRoiInput{dTagOffset}.Object)
            end

            atRoiInput(dTagOffset) = [];
           
            roiTemplate('set', dSerieOffset, atRoiInput);  

  %          atRoiInput(cellfun(@isempty, atRoiInput)) = [];


            % Clear roi from voi input template (if exist)

            if ~isempty(atVoiInput)                        

                for vo=1:numel(atVoiInput)     

                    dTagOffset = find(contains(atVoiInput{vo}.RoisTag, sRoiTag));

                    if ~isempty(dTagOffset) % tag exist

                        atVoiInput{vo}.RoisTag(dTagOffset) = [];
                     %   atVoiInput{vo}.RoisTag(cellfun(@isempty, atVoiInput{vo}.RoisTag)) = [];     
                        if isempty(atVoiInput{vo}.RoisTag)
                            atVoiInput(vo) = [];
                            break;
                        else
                            
if 0 % Need to improve the operation speed  
                            if ~isempty(atRoiInput)               
                
                                dNbTags = numel(atVoiInput{vo}.RoisTag);
                
                                for dRoiNb=1:dNbTags
                
                                    aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), atVoiInput{vo}.RoisTag{dRoiNb} );
                
                                    if ~isempty(aTagOffset)
                
                                        dTagOffset = find(aTagOffset, 1);
                
                                        if~isempty(dTagOffset)
                
                                            sLabel = sprintf('%s (roi %d/%d)', atVoiInput{vo}.Label, dRoiNb, dNbTags);
                
                                            atRoiInput{dTagOffset}.Label = sLabel;
                                            atRoiInput{dTagOffset}.Object.Label = sLabel;                           
                                            atRoiInput{dTagOffset}.ObjectType  = 'voi-roi';
                                       end
                                    end                 
                                end
                            end
end
                        end
                    end
                end

  %             atVoiInput(cellfun(@isempty, atVoiInput)) = [];
               roiTemplate('set', dSerieOffset, atRoiInput);  
               voiTemplate('set', dSerieOffset, atVoiInput);                                        
            end

            % Refresh contour popup

            setVoiRoiSegPopup();

        end
    end

end
