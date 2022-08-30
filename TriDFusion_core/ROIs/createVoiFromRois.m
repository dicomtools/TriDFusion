function createVoiFromRois(iSeriesOffset, adTag, sVoiName, sLesionType)
%function createVoiFromRois(iSeriesOffset, adTag, sVoiName, sLesionType)
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

    tInput = inputTemplate('get');

    if iSeriesOffset > numel(tInput)
        return;
    end

    atRoi = roiTemplate('get', iSeriesOffset);
    if isempty(atRoi)
        return;
    end

    if isfield(tInput(iSeriesOffset), 'tVoi')
        if isempty(tInput(iSeriesOffset).tVoi)
            dVoiOffset = 1;
        else
            dVoiOffset = numel(tInput(iSeriesOffset).tVoi)+1;
        end

    else
        dVoiOffset = 1;
    end

    if ~isempty(sVoiName)
        tInput(iSeriesOffset).tVoi{dVoiOffset}.Label = sVoiName;
    else
        tInput(iSeriesOffset).tVoi{dVoiOffset}.Label = sprintf('VOI %d', dVoiOffset);
    end

    dRoiNb = 0;
    dNbTags = numel(adTag);
    
    sVoiTag = [];

    for bb=1:dNbTags
        for cc=1:numel(atRoi) % Set VOI tag, type and color
%            if isvalid(atRoi{cc}.Object)
                if strcmp(atRoi{cc}.Tag, adTag{bb})
                    sVoiTag = num2str(randi([-(2^52/2),(2^52/2)],1));
                    tInput(iSeriesOffset).tVoi{dVoiOffset}.Tag        = sVoiTag;
                    tInput(iSeriesOffset).tVoi{dVoiOffset}.ObjectType = 'voi';
                    tInput(iSeriesOffset).tVoi{dVoiOffset}.Color      = atRoi{cc}.Color;
                    tInput(iSeriesOffset).tVoi{dVoiOffset}.LesionType = sLesionType;

                    tInput(iSeriesOffset).tVoi{dVoiOffset}.RoisTag = num2cell(zeros(1,numel(adTag)));
                    break;
                end
%           end
        end
    end

    for bb=1:dNbTags

        if dNbTags > 100
            if mod(bb, 10)==1 || bb == dNbTags
                progressBar( bb/dNbTags, sprintf('Computing ROI %d/%d, please wait', bb, dNbTags) );
            end
        end

        for cc=1:numel(atRoi)
%            if isvalid(atRoi{cc}.Object)
                if strcmp(atRoi{cc}.Tag, adTag{bb})

                    atRoi{cc}.ObjectType  = 'voi-roi';
                    tInput(iSeriesOffset).tRoi{cc}.ObjectType = atRoi{cc}.ObjectType;
                    tInput(iSeriesOffset).tVoi{dVoiOffset}.RoisTag{bb} = atRoi{cc}.Tag;

                    dRoiNb = dRoiNb+1;
                    sLabel = sprintf('%s (roi %d/%d)', tInput(iSeriesOffset).tVoi{dVoiOffset}.Label, dRoiNb, dNbTags);

                    atRoi{cc}.Label = sLabel;
                    atRoi{cc}.Object.Label = sLabel;
                    voiDefaultMenu(atRoi{cc}.Object, sVoiTag);
                    break;
                end
%            end
        end
    end

    roiTemplate('set', iSeriesOffset, atRoi);
    voiTemplate('set', iSeriesOffset, tInput(iSeriesOffset).tVoi);

    inputTemplate('set', tInput);

    if dNbTags > 100
        progressBar( 1, 'Ready' );
    end

end
