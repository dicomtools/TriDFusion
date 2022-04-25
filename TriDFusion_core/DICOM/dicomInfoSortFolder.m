function tDataSets = dicomInfoSortFolder(link)
%function tDataSets = dicomInfoSortFolder(link)
%DICOM main function that initialize and return a sorted structure of the
%dataset
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

    initDcm4che3();

    if(isfolder(link))
        sDirName = link; 
    else
        sDirName = fileparts(link);
    end

    % Init a structure for all files

    tFileList.FileName             = cell(1,100000);
    tFileList.InstanceNumber       = zeros(1,100000);
    tFileList.ImagePositionPatient = zeros(100000,3);
    tFileList.aHash                = zeros(1,100000);

    [tFileList, iNbFiles] = getDicomFileList(sDirName, tFileList);

    if(iNbFiles == 0) 
        if isfield(tFileList, 'Contours') 
            tDataSets.Contours = tFileList.Contours;
        else
            tDataSets = [];
        end
        return; 
    end

    tDataSets = sortDicomFileList(tFileList, iNbFiles);
%    tDataSets.DicomBuffers = squeeze(dicomreadVolume(fullfile(link)));

end