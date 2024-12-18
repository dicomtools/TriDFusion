function constraintContourFromMenuCallback(hObject, ~)
%function constraintContourFromMenuCallback(hObject, ~)
%Constraint a ROI or VOI, the function is called from a menu.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2022, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    sConstraintType = get(hObject, 'Label');
    sConstraintTag  = get(hObject, 'UserData');

    atVoiInput = voiTemplate('get', dSeriesOffset);

    roiConstraintList('set', dSeriesOffset, sConstraintTag, sConstraintType);
    
    if ~isempty(atVoiInput)
        
        dRoiVoiTagOffset = find(strcmp( cellfun( @(atVoiInput) atVoiInput.Tag, atVoiInput, 'uni', false ), sConstraintTag), 1);
    
        if ~isempty(dRoiVoiTagOffset) % tag is a voi

            [asConstraintTagList, ~] = roiConstraintList('get', dSeriesOffset);

            bIsVoiActive = false;

            if ~isempty(asConstraintTagList)

                dVoiTagOffset = find(strcmp( cellfun( @(asConstraintTagList) asConstraintTagList, asConstraintTagList, 'uni', false ), sConstraintTag), 1);

                if ~isempty(dVoiTagOffset) % tag is active

                    bIsVoiActive = true;
                end        
            end

            for tt=1:numel(atVoiInput{dRoiVoiTagOffset}.RoisTag)

                sConstraintTag = atVoiInput{dRoiVoiTagOffset}.RoisTag{tt};

                roiConstraintList('set', dSeriesOffset, sConstraintTag, sConstraintType, bIsVoiActive);
            end            
        end         
    end
    
end
