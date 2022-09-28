function predefinedLabelCallback(hObject,~)
%function predefinedLabelCallback(hObject,~)
%Set ROIs Predefined Label.
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

    hObject.UserData.Label = hObject.Text;

    sLabel = hObject.Text;

    atRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));                
    
    if isempty(atRoiInput) 
        aTagOffset = 0;
    else
        aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {hObject.UserData.Tag} );            
    end

    if aTagOffset(aTagOffset==1) % tag is a roi

        dTagOffset = find(aTagOffset, 1);

        if ~isempty(dTagOffset)

            hObject.UserData.Label = sLabel;

            atRoiInput{dTagOffset}.Color = sLabel;
            if isvalid(atRoiInput{dTagOffset}.Object)
                atRoiInput{dTagOffset}.Object.Label = sLabel;
            end

            roiTemplate('set', get(uiSeriesPtr('get'), 'Value'), atRoiInput);
        end                      

%            setVoiRoiSegPopup(); Not need for ROI
    end 
    
end
