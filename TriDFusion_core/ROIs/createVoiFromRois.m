function createVoiFromRois(adTag)
%function createVoiFromRois(adTag)
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
    atMetaData = dicomMetaData('get');

    iSeriesOffset = get(uiSeriesPtr('get'), 'Value');
    if iSeriesOffset > numel(tInput)  
        return;
    end

    if ~isempty(tInput(iSeriesOffset).tRoi)

        if isfield(tInput(iSeriesOffset), 'tVoi')
            if isempty(tInput(iSeriesOffset).tVoi)
                dVoiOffset = 1;                         
            else
                dVoiOffset = numel(tInput(iSeriesOffset).tVoi)+1; 
            end

        else
            dVoiOffset = 1; 
        end

        tInput(iSeriesOffset).tVoi{dVoiOffset}.Label = sprintf('VOI %d', dVoiOffset);

        dRoiNb = 0;
        for bb=1:numel(adTag)
            for cc=1:numel(tInput(iSeriesOffset).tRoi)
                if isvalid(tInput(iSeriesOffset).tRoi{cc}.Object)
                    if strcmpi(tInput(iSeriesOffset).tRoi{cc}.Tag, adTag{bb})                           

                        tInput(iSeriesOffset).tRoi{cc}.ObjectType  = 'voi-roi';
                        tInput(iSeriesOffset).tVoi{dVoiOffset}.RoisTag{bb} = tInput(iSeriesOffset).tRoi{cc}.Tag; 
                        tInput(iSeriesOffset).tVoi{dVoiOffset}.Tag = num2str(rand);
                        tInput(iSeriesOffset).tVoi{dVoiOffset}.ObjectType = 'voi';
                        tInput(iSeriesOffset).tVoi{dVoiOffset}.Color = tInput(iSeriesOffset).tRoi{cc}.Color;

                        dRoiNb = dRoiNb+1;
                        sLabel =  sprintf('%s (roi %d/%d)', tInput(iSeriesOffset).tVoi{dVoiOffset}.Label, dRoiNb, numel(adTag));

                        tInput(iSeriesOffset).tRoi{cc}.Label = sLabel;
                        tInput(iSeriesOffset).tRoi{cc}.Object.Label = sLabel; 
                    end
                end
            end
        end

        aDisplayBuffer = dicomBuffer('get');

        aInput   = inputBuffer('get');
        if     strcmp(imageOrientation('get'), 'axial')
            aInputBuffer = permute(aInput{iSeriesOffset}, [1 2 3]);
        elseif strcmp(imageOrientation('get'), 'coronal') 
            aInputBuffer = permute(aInput{iSeriesOffset}, [3 2 1]);    
        elseif strcmp(imageOrientation('get'), 'sagittal')
            aInputBuffer = permute(aInput{iSeriesOffset}, [3 1 2]);
        end   
if 0
        if numel(tInput(iSeriesOffset).asFilesList) ~= 1

            if ~isempty(atMetaData{1}.ImagePositionPatient)

                if atMetaData{2}.ImagePositionPatient(3) - ...
                   atMetaData{1}.ImagePositionPatient(3) > 0
                    aInputBuffer = aInputBuffer(:,:,end:-1:1);                   

                end
            end            
        else
            if strcmpi(atMetaData{1}.PatientPosition, 'FFS')
                aInputBuffer = aInputBuffer(:,:,end:-1:1);                   
            end
        end  
end                
        [~, tVoiMask] = computeVoi(aInputBuffer, aDisplayBuffer, atMetaData, tInput(iSeriesOffset).tVoi{dVoiOffset}, tInput(iSeriesOffset).tRoi, 1, 1, 1);
        tInput(iSeriesOffset).tVoi{dVoiOffset}.tMask = tVoiMask;

    end            

    roiTemplate('set', tInput(iSeriesOffset).tRoi);            
    voiTemplate('set', tInput(iSeriesOffset).tVoi);

    inputTemplate('set', tInput);            

end
