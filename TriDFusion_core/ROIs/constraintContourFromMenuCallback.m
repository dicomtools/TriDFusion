function constraintContourFromMenuCallback(hObject, ~)
%function maskContourFromMenuCallback(hObject, ~)
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

    sConstraintType = get(hObject, 'Label');
    sConstraintTag  = get(hObject, 'UserData'); 

    aVoiRoiTag = voiRoiTag('get');

%    tRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
    tVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

    roiConstraintList('set', get(uiSeriesPtr('get'), 'Value'), sConstraintTag, sConstraintType);

    if ~isempty(tVoiInput) && ...
       ~isempty(aVoiRoiTag)

        for aa=1:numel(tVoiInput)
            if strcmp(tVoiInput{aa}.Tag, sConstraintTag) % Tag is a VOI

                [asConstraintTagList, ~] = roiConstraintList('get', get(uiSeriesPtr('get'), 'Value') );

                bIsVoiActive = false;
                for cc=1:numel(asConstraintTagList) % Verify is VOI active
                    if strcmp(asConstraintTagList{cc}, sConstraintTag)
                        bIsVoiActive = true;
                        break;
                    end
                end         

                for tt=1:numel(tVoiInput{aa}.RoisTag)
                    sConstraintTag = tVoiInput{aa}.RoisTag{tt};
                    roiConstraintList('set', get(uiSeriesPtr('get'), 'Value'), sConstraintTag, sConstraintType, bIsVoiActive);
                end
            break;
            end
        end
    end            
end 