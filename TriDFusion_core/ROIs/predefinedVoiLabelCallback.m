function predefinedVoiLabelCallback(hObject,~)
%function predefinedVoiLabelCallback(hObject,~)
%Set VOIs Predefined Label.
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

    sLabel = hObject.Text;

    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

    atVoiInput = voiTemplate('get', dSeriesOffset);                
    atRoiInput = roiTemplate('get', dSeriesOffset);                
   
    if ~isempty(atVoiInput) 

        dVoiTagOffset = find(cellfun(@(c) any(strcmp(c.RoisTag, hObject.UserData.Tag)), atVoiInput), 1);
    
        if ~isempty(dVoiTagOffset)

            atVoiInput{dVoiTagOffset}.Label = sLabel;

            dNbRois = numel(atVoiInput{dVoiTagOffset}.RoisTag);

            for vv=1: dNbRois

                dRoiTagOffset = find(strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), atVoiInput{dVoiTagOffset}.RoisTag{vv} ) );

                if ~isempty(dRoiTagOffset) % Found the Tag 

                    atRoiInput{dRoiTagOffset}.Label = sprintf('%s (roi %d/%d)',sLabel, vv, dNbRois);

                    if isvalid(atRoiInput{dRoiTagOffset}.Object)

                        atRoiInput{dRoiTagOffset}.Object.Label = atRoiInput{dRoiTagOffset}.Label;
                    end
                             
                end

            end

            roiTemplate('set', dSeriesOffset, atRoiInput);
            voiTemplate('set', dSeriesOffset, atVoiInput);
            
            setVoiRoiSegPopup(); 

        end         
    end
        
end