function editRoiLesionTypeCallback(hObject,~)
%function editRoiLesionTypeCallback(hObject,~)
%Set ROI Location.
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

    atRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));                
    
    if ~isempty(atRoiInput) 

        dRoiTagOffset = find(strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), hObject.UserData.Tag ) );
    
        if ~isempty(dRoiTagOffset)

            bTagIsUpdated = false;

            [bLesionOffset, ~, asLesionShortName] = getLesionType(hObject.Text);   

            for nn=1:numel(asLesionShortName)

                if contains(atRoiInput{dRoiTagOffset}.Label, asLesionShortName{nn})

                    bTagIsUpdated = true;

                    atRoiInput{dRoiTagOffset}.Label = replace(atRoiInput{dRoiTagOffset}.Label, asLesionShortName{nn}, asLesionShortName{bLesionOffset});
                    break;
                end
            end

             if bTagIsUpdated == false

                atRoiInput{dRoiTagOffset}.Label = sprintf('%s-%s', atRoiInput{dRoiTagOffset}.Label, asLesionShortName{bLesionOffset});    
             end       

            atRoiInput{dRoiTagOffset}.LesionType = hObject.Text; 

            roiTemplate('set', get(uiSeriesPtr('get'), 'Value'), atRoiInput);
        end         
    end

%            setVoiRoiSegPopup(); Not need for ROI
    
end
