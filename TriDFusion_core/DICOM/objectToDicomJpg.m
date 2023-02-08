function objectToDicomJpg(sOutDir, pObject, sSeriesDescription, dSeriesOffset)
%function objectToDicomJpg(sOutDir, pObject, sSeriesDescription, dSeriesOffset)
%Export axe to dicom screen capture file.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2023, Daniel Lafontaine, on behalf of the TriDFusion development team.
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
% along with TriDFusion.cIf not, see <http://www.gnu.org/licenses/>.

    % Get object cdata
    
    try
        tObjectFrame = getframe(pObject);
    catch
        progressBar(1, 'Error: objectToDicomJpg() invalid object');
        return;
    end

    % Create an empty dicom directory    
    
    sDcmTmpDir = sprintf('%stemp_dcm_%s/', viewerTempDirectory('get'), datetime('now','Format','MMMM-d-y-hhmmss'));
    if exist(char(sDcmTmpDir), 'dir')
        rmdir(char(sDcmTmpDir), 's');
    end
    mkdir(char(sDcmTmpDir)); 

    sDicomDummyFile = sprintf('%sdummy.dcm', sDcmTmpDir);
    % Write a dummy dicom file
    
    dicomwrite(tObjectFrame.cdata, sDicomDummyFile);

    % Read dummy dicom file
    atMetaData{1} = dicominfo(sDicomDummyFile);
    aDicomImage = dicomread(sDicomDummyFile);

    % Delete dummy directory

    if exist(char(sDcmTmpDir), 'dir')
        rmdir(char(sDcmTmpDir), 's');
    end

    % Acquire associte dicom meta data

    atAssociateMetaData = dicomMetaData('get', [], dSeriesOffset);

    atMetaData{1}.PatientName = atAssociateMetaData{1}.PatientName;
    atMetaData{1}.PatientID   = atAssociateMetaData{1}.PatientID;
    atMetaData{1}.PatientBirthDate = atAssociateMetaData{1}.PatientBirthDate;
    atMetaData{1}.PatientSex = atAssociateMetaData{1}.PatientSex;

    atMetaData{1}.SeriesDescription = sSeriesDescription;

    atMetaData{1}.Modality = atAssociateMetaData{1}.Modality;

    atMetaData{1}.SeriesDate = atAssociateMetaData{1}.SeriesDate;
    atMetaData{1}.StudyDate  = atAssociateMetaData{1}.StudyDate;
    atMetaData{1}.SeriesTime = atAssociateMetaData{1}.SeriesTime;
    atMetaData{1}.StudyTime  = atAssociateMetaData{1}.StudyTime;

    atMetaData{1}.StudyDescription = atAssociateMetaData{1}.StudyDescription;
    atMetaData{1}.StudyInstanceUID = atAssociateMetaData{1}.StudyInstanceUID;

    atMetaData{1}.AccessionNumber = atAssociateMetaData{1}.AccessionNumber;
    
    % Export dicom
    
    atMetaData{1}.SeriesInstanceUID = dicomuid;

    sOutFile = sprintf('%s%s.dcm', sOutDir, atMetaData{1}.SeriesInstanceUID);

    atMetaData{1}.Filename = sOutFile;

    dicomwrite(aDicomImage    , ...
               sOutFile           , ...
               atMetaData{1}, ...
               'CreateMode'       , ...
               'Copy'             , ...
               'WritePrivate'     , true ...
               ); 

    progressBar( 1, sprintf('Export %s completed %s', sOutFile) );
    
end