function hideViewVoiFaceAlhaCallback(hObject, ~)
%function hideViewVoiFaceAlhaCallback(hObject.UserData,~)
%Hide\View VOI ROIs FaceAlpha.
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

    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

    atVoiInput = voiTemplate('get', dSeriesOffset); 
    atRoiInput = roiTemplate('get', dSeriesOffset);                

    if isempty(atVoiInput) 
        return;
    end

    dVoiTagOffset = find(strcmp( cellfun( @(atVoiInput) atVoiInput.Tag, atVoiInput, 'uni', false ), hObject.UserData ) );

    if ~isempty(dVoiTagOffset)

        dNbRois = numel(atVoiInput{dVoiTagOffset}.RoisTag);

        dFaceAlpha = 0;

        for vv=1: dNbRois

            dRoiTagOffset = find(strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), atVoiInput{dVoiTagOffset}.RoisTag{vv} ) );

            if ~isempty(dRoiTagOffset) % Found the Tag 
                
                if vv==1

                    if atRoiInput{dRoiTagOffset}.FaceAlpha == 0
        
                        dFaceAlpha = roiFaceAlphaValue('get');
                    end
                end

                atRoiInput{dRoiTagOffset}.FaceAlpha = dFaceAlpha;

                if isvalid(atRoiInput{dRoiTagOffset}.Object)

                    atRoiInput{dRoiTagOffset}.Object.FaceAlpha = dFaceAlpha;
                end
                         
            end

        end

        roiTemplate('set', dSeriesOffset, atRoiInput);
        
    end     
    
end
