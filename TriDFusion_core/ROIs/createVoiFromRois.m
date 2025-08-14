function createVoiFromRois(dSeriesOffset, asTag, sVoiName, sColor, sLesionType)
%function createVoiFromRois(dSeriesOffset, asTag, sVoiName, sColor, sLesionType)
%Create VOI From Array Of ROIs tag.
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

    atRoi = roiTemplate('get', dSeriesOffset);
    if isempty(atRoi)
        return;
    end
    
    atVoi = voiTemplate('get', dSeriesOffset);
    dVoiOffset = numel(atVoi)+1;

    [bLesionOffset, ~, asLesionShortName] = getLesionType(sLesionType);

    if ~isempty(sVoiName)
        
        if contains(sVoiName, asLesionShortName{bLesionOffset})
            atVoi{dVoiOffset}.Label = sVoiName;
        else
            atVoi{dVoiOffset}.Label = sprintf('%s-%s', sVoiName, asLesionShortName{bLesionOffset});
        end
    else
        atVoi{dVoiOffset}.Label = sprintf('VOI %d-%s', dVoiOffset, asLesionShortName{bLesionOffset});
    end

    dRoiNb = 0;
    dNbTags = numel(asTag);
     
    sVoiTag = num2str(generateUniqueNumber(false));
    atVoi{dVoiOffset}.Tag        = sVoiTag;
    atVoi{dVoiOffset}.ObjectType = 'voi';
    atVoi{dVoiOffset}.Color      = sColor;
    atVoi{dVoiOffset}.LesionType = sLesionType;
    atVoi{dVoiOffset}.RoisTag    = cell(1, dNbTags);

    for bb=1:dNbTags

        dRoiTagOffset = find(strcmp( cellfun( @(atRoi) atRoi.Tag, atRoi, 'uni', false ), asTag(bb) ), 1);
        
        if ~isempty(dRoiTagOffset)

            atRoi{dRoiTagOffset}.ObjectType  = 'voi-roi';
            atVoi{dVoiOffset}.RoisTag{bb} = atRoi{dRoiTagOffset}.Tag;

            dRoiNb = dRoiNb+1;
            sLabel = sprintf('%s (roi %d/%d)', atVoi{dVoiOffset}.Label, dRoiNb, dNbTags);

            atRoi{dRoiTagOffset}.Label = sLabel;

            if isfield(atRoi{dRoiTagOffset}, 'Object')
                
                if ~isstruct(atRoi{dRoiTagOffset}.Object)
    
                    atRoi{dRoiTagOffset}.Object.Label = sLabel;
                    atRoi{dRoiTagOffset}.Object.UserData = 'voi-roi';
                end
            end

            % voiDefaultMenu(atRoi{dRoiTagOffset}.Object, sVoiTag);
        end
    end

    roiTemplate('set', dSeriesOffset, atRoi);
    voiTemplate('set', dSeriesOffset, atVoi);

end
