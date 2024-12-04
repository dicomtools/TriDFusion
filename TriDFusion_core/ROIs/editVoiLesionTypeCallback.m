function editVoiLesionTypeCallback(hObject,~)
%function editVoiLesionTypeCallback(hObject,~)
%Set VOI Location.
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

    atVoiInput = voiTemplate('get', dSeriesOffset);                
    atRoiInput = roiTemplate('get', dSeriesOffset);                
   
    if ~isempty(atVoiInput) 

        dVoiTagOffset = find(cellfun(@(c) any(strcmp(c.RoisTag, hObject.UserData.Tag)), atVoiInput), 1);         
    
        if ~isempty(dVoiTagOffset)

            bTagIsUpdated = false;

            [bLesionOffset, ~, asLesionShortName] = getLesionType(hObject.Text);   

            for nn=1:numel(asLesionShortName)

                if contains(atVoiInput{dVoiTagOffset}.Label, asLesionShortName{nn})

                    bTagIsUpdated = true;

                    atVoiInput{dVoiTagOffset}.Label = replace(atVoiInput{dVoiTagOffset}.Label, asLesionShortName{nn}, asLesionShortName{bLesionOffset});
                    break;
                end
            end

             if bTagIsUpdated == false

                atVoiInput{dVoiTagOffset}.Label = sprintf('%s-%s', atVoiInput{dVoiTagOffset}.Label, asLesionShortName{bLesionOffset});    
             end       

            atVoiInput{dVoiTagOffset}.LesionType = hObject.Text; 

            dNbRois = numel(atVoiInput{dVoiTagOffset}.RoisTag);

            for vv=1: dNbRois

                dRoiTagOffset = find(strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), atVoiInput{dVoiTagOffset}.RoisTag{vv} ) );

                if ~isempty(dRoiTagOffset) % Found the Tag 

                    bTagIsUpdated = false;

                    [bLesionOffset, ~, asLesionShortName] = getLesionType(hObject.Text);   

                    for nn=1:numel(asLesionShortName)

                        if contains(atRoiInput{dRoiTagOffset}.Label, asLesionShortName{nn})

                            bTagIsUpdated = true;

                            atRoiInput{dRoiTagOffset}.Label = replace(atRoiInput{dRoiTagOffset}.Label, asLesionShortName{nn}, asLesionShortName{bLesionOffset});

                            if isvalid(atRoiInput{dRoiTagOffset}.Object)

                                atRoiInput{dRoiTagOffset}.Object.Label = atRoiInput{dRoiTagOffset}.Label;
                            end
                            break;
                        end
                    end

                     if bTagIsUpdated == false

                        atRoiInput{dRoiTagOffset}.Label = sprintf('%s-%s', atRoiInput{dRoiTagOffset}.Label, asLesionShortName{bLesionOffset});    

                        if isvalid(atRoiInput{dRoiTagOffset}.Object)
                            
                            atRoiInput{dRoiTagOffset}.Object.Label = atRoiInput{dRoiTagOffset}.Label;
                        end

                     end       

                    atRoiInput{dRoiTagOffset}.LesionType = hObject.Text;                                
                end

            end

            roiTemplate('set', dSeriesOffset, atRoiInput);
            voiTemplate('set', dSeriesOffset, atVoiInput);
            
            setVoiRoiSegPopup(); 

        end         
    end
    
end
