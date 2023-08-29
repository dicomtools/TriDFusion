function writeSeriestoNIICallback(~, ~)
%function writeSeriestoNIICallback()
%Export series to .nii file type.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Note: option settings must fit on one line and can contain one semicolon at most.
%Options can be strings, cell arrays of strings, or numerical arrays.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2020, Daniel Lafontaine, on behalf of the TriDFusion development team.
%
% This file is part of The Triple Dimention Fusion (TriDFusion).
%
% TriDFusion development has been led by: Daniel Lafontaine
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
           
    try
        
    set(fiMainWindowPtr('get'), 'Pointer', 'watch');
    drawnow;

    atInputTemplate = inputTemplate('get');

    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');
    if dSeriesOffset > numel(atInputTemplate)
        set(fiMainWindowPtr('get'), 'Pointer', 'default');
        drawnow;
        return;
    end
    
%     sOutDir = outputDir('get');
%     if isempty(sOutDir)
                
         sCurrentDir  = viewerRootPath('get');

         sMatFile = [sCurrentDir '/' 'exportNIILastUsedDir.mat'];
         % load last data directory
         if exist(sMatFile, 'file')
                                    % lastDirMat mat file exists, load it
            load('-mat', sMatFile);
            if exist('exportNIILastUsedDir', 'var')
                sCurrentDir = exportNIILastUsedDir;
            end
            if sCurrentDir == 0
                sCurrentDir = pwd;
            end
         end

        sOutDir = uigetdir(sCurrentDir);
        if sOutDir == 0
            set(fiMainWindowPtr('get'), 'Pointer', 'default');
            drawnow;
            return;
        end
        sOutDir = [sOutDir '/'];

        try
            exportNIILastUsedDir = sOutDir;
            save(sMatFile, 'exportNIILastUsedDir');
        catch
            progressBar(1 , sprintf('Warning: Cant save file %s', sMatFile));
        end
    
        sDate = sprintf('%s', datetime('now','Format','MMMM-d-y-hhmmss'));                
        sOutDir = char(sOutDir) + "TriDFusion_NII_" + char(sDate) + '/';              
        if ~(exist(char(sOutDir), 'dir'))
            mkdir(char(sOutDir));
        end
%     end
    
    atMetaData  = dicomMetaData('get', [], dSeriesOffset);

    aBuffer = dicomBuffer('get', [], dSeriesOffset);

    atDcmDicomMeta{1}.Modality                = atMetaData{1}.Modality;
    atDcmDicomMeta{1}.Units                   = atMetaData{1}.Units;
    atDcmDicomMeta{1}.PixelSpacing            = atMetaData{1}.PixelSpacing;

    if numel(aBuffer) > 2
        dSliceSPacing = computeSliceSpacing(atMetaData);
        if  dSliceSPacing == 0
            dSliceSPacing = 1;
        end
        atDcmDicomMeta{1}.SpacingBetweenSlices = dSliceSPacing;
        atDcmDicomMeta{1}.SliceThickness       = dSliceSPacing;
    end

    aImageOrientationPatient = zeros(6,1);
    
    % Axial
    
    aImageOrientationPatient(1) = 1;
    aImageOrientationPatient(5) = 1;

    aImagePositionPatient = zeros(3,1);

    atDcmDicomMeta{1}.Rows                    = atMetaData{1}.Rows;
    atDcmDicomMeta{1}.Columns                 = atMetaData{1}.Columns;
    atDcmDicomMeta{1}.PatientName             = atMetaData{1}.PatientName;
    atDcmDicomMeta{1}.PatientID               = atMetaData{1}.PatientID;
    atDcmDicomMeta{1}.PatientWeight           = atMetaData{1}.PatientWeight;
    atDcmDicomMeta{1}.PatientSize             = atMetaData{1}.PatientSize;
    atDcmDicomMeta{1}.PatientSex              = atMetaData{1}.PatientSex;
    atDcmDicomMeta{1}.PatientAge              = atMetaData{1}.PatientAge;
    atDcmDicomMeta{1}.PatientBirthDate        = atMetaData{1}.PatientBirthDate;
    atDcmDicomMeta{1}.SeriesDescription       = cleanString(atMetaData{1}.SeriesDescription);
    atDcmDicomMeta{1}.PatientPosition         = atMetaData{1}.PatientPosition;
    atDcmDicomMeta{1}.ImagePositionPatient    = atMetaData{1}.ImagePositionPatient;
%     atDcmDicomMeta{1}.ImageOrientationPatient = atMetaData{1}.ImageOrientationPatient;
    atDcmDicomMeta{1}.ImageOrientationPatient = aImageOrientationPatient;
    atDcmDicomMeta{1}.SOPClassUID             = atMetaData{1}.SOPClassUID;
    atDcmDicomMeta{1}.SOPInstanceUID          = atMetaData{1}.SOPInstanceUID;
    atDcmDicomMeta{1}.SeriesInstanceUID       = dicomuid;
    atDcmDicomMeta{1}.StudyInstanceUID        = atMetaData{1}.StudyInstanceUID;
    atDcmDicomMeta{1}.AccessionNumber         = atMetaData{1}.AccessionNumber;
    atDcmDicomMeta{1}.SeriesTime              = char(datetime('now','TimeZone','local','Format','HHmmss'));
    atDcmDicomMeta{1}.SeriesDate              = char(datetime('now','TimeZone','local','Format','yyyyMMd'));
    atDcmDicomMeta{1}.AcquisitionTime         = atMetaData{1}.AcquisitionTime;
    atDcmDicomMeta{1}.AcquisitionDate         = atMetaData{1}.AcquisitionDate;    

%     if ~isempty(atMetaData{1}.RescaleIntercept)
%         atDcmDicomMeta{1}.RescaleIntercept = atMetaData{1}.RescaleIntercept;
%     end
% 
%     if ~isempty(atMetaData{1}.RescaleSlope)
%         atDcmDicomMeta{1}.RescaleSlope = atMetaData{1}.RescaleSlope;
%     end

    sTmpDir = sprintf('%stemp_dicom_%s//', viewerTempDirectory('get'), datetime('now','Format','MMMM-d-y-hhmmss-MS'));
    if exist(char(sTmpDir), 'dir')
        rmdir(char(sTmpDir), 's');
    end
    mkdir(char(sTmpDir));  

    if size(aBuffer, 3) ==1
        aBuffer = aBuffer(end:-1:1,:);
    else
        aBuffer = aBuffer(:,:,end:-1:1);
        aBuffer = aBuffer(end:-1:1,:,:);
    end
    
    writeOtherFormatToDICOM(aBuffer, atDcmDicomMeta, sTmpDir, dSeriesOffset, false);

    clear aBuffer;

    dicm2nii(sTmpDir, sOutDir, 1);
  

    rmdir(char(sTmpDir), 's');    

    progressBar(1, sprintf('Export to %s completed', char(sOutDir)));

    catch
        progressBar(1, 'Error:writeDICOMtoNIICallback()');
    end

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow;

end
