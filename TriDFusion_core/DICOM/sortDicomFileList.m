function tDataSets = sortDicomFileList(tFileList, iNbFiles)
%function tDataSets = sortDicomFileList(tFileList, iNbFiles)
%Sort the slices of all dicom headers.
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

    iDataSetIDs = unique(tFileList.aHash(1:iNbFiles));
    
    tDataSets = struct('FileNames', cell(1, length(iDataSetIDs)), 'DicomInfos', cell(1, length(iDataSetIDs)), 'DicomBuffers', cell(1, length(iDataSetIDs)));

    for iLoop=1 : length(iDataSetIDs)

        h = find(tFileList.aHash(1:iNbFiles) == iDataSetIDs(iLoop));
        
        iInstanceNumbers      = tFileList.InstanceNumber(h);
        aImagePositionPatient = tFileList.ImagePositionPatient(h,:);

        if(length(unique(iInstanceNumbers)) == length(iInstanceNumbers))
            [~, ind] = sort(iInstanceNumbers);
        else
            [~, ind] = sort(aImagePositionPatient(:,3));
        end

        h = h(ind);
        
        tDataSets(iLoop).FileNames    = cell(length(h),1);
        tDataSets(iLoop).DicomInfos   = cell(length(h),1);
        tDataSets(iLoop).DicomBuffers = cell(length(h),1);

        endJloop = length(h);
        for jLoop=1:endJloop
            
            if mod(jLoop,15)==1 || jLoop == endJloop         
                progressBar(jLoop / endJloop, sprintf('Sorting file list %d/%d', jLoop, endJloop) );
            end

            tDataSets(iLoop).FileNames{jLoop}    = tFileList.FileName{h(jLoop)} ;
            tDataSets(iLoop).DicomInfos{jLoop}   = tFileList.DicomInfo{h(jLoop)} ;
            tDataSets(iLoop).DicomBuffers{jLoop} = readDcm4che3(tFileList.FileName{h(jLoop)}, tFileList.DicomInfo{h(jLoop)});                    

%            tFileList.DicomInfo{h(jLoop)}.din.pixeldata = []; % Clear data
        end
        
        if isfield(tFileList, 'Contours') 
            tDataSets(iLoop).Contours = tFileList.Contours;
        end
                
        progressBar(1, 'Ready');

    end
end