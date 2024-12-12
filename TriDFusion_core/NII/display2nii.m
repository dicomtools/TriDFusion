function display2nii(aBuffer, atMetaData, sNiiFolder, dOutFormat)
%function display2nii(aBuffer, atMetaData, sNiiFolder, dOutFormat)
%Save an image to nii.
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
    
    % if 0
    % 
    % atDcmDicomMeta{1}.Modality                = atMetaData{1}.Modality;
    % atDcmDicomMeta{1}.Units                   = atMetaData{1}.Units;
    % atDcmDicomMeta{1}.PixelSpacing            = atMetaData{1}.PixelSpacing;
    % 
    % if numel(aBuffer) > 2
    % 
    %     dSliceSPacing = computeSliceSpacing(atMetaData);
    %     if  dSliceSPacing == 0
    %         dSliceSPacing = 1;
    %     end
    % 
    %     atDcmDicomMeta{1}.SpacingBetweenSlices = dSliceSPacing;
    %     atDcmDicomMeta{1}.SliceThickness       = dSliceSPacing;
    % end
    % 
    % % Axial
    % aImageOrientationPatient = zeros(6,1);
    % 
    % aImageOrientationPatient(1) = 1;
    % aImageOrientationPatient(5) = 1;
    % 
    % atDcmDicomMeta{1}.Rows                    = atMetaData{1}.Rows;
    % atDcmDicomMeta{1}.Columns                 = atMetaData{1}.Columns;
    % atDcmDicomMeta{1}.PatientName             = atMetaData{1}.PatientName;
    % atDcmDicomMeta{1}.PatientID               = atMetaData{1}.PatientID;
    % atDcmDicomMeta{1}.PatientWeight           = atMetaData{1}.PatientWeight;
    % atDcmDicomMeta{1}.PatientSize             = atMetaData{1}.PatientSize;
    % atDcmDicomMeta{1}.PatientSex              = atMetaData{1}.PatientSex;
    % atDcmDicomMeta{1}.PatientAge              = atMetaData{1}.PatientAge;
    % atDcmDicomMeta{1}.PatientBirthDate        = atMetaData{1}.PatientBirthDate;
    % atDcmDicomMeta{1}.SeriesDescription       = cleanString(atMetaData{1}.SeriesDescription);
    % atDcmDicomMeta{1}.PatientPosition         = atMetaData{1}.PatientPosition;
    % atDcmDicomMeta{1}.ImagePositionPatient    = atMetaData{end}.ImagePositionPatient;
    % %     atDcmDicomMeta{1}.ImageOrientationPatient = atMetaData{1}.ImageOrientationPatient;
    % atDcmDicomMeta{1}.ImageOrientationPatient = aImageOrientationPatient;
    % %     atDcmDicomMeta{1}.MediaStorageSOPClassUID     = atMetaData{1}.MediaStorageSOPClassUID;
    % %     atDcmDicomMeta{1}.MediaStorageSOPInstanceUID  = atMetaData{1}.MediaStorageSOPInstanceUID;      
    % atDcmDicomMeta{1}.SOPClassUID             = atMetaData{1}.SOPClassUID;
    % atDcmDicomMeta{1}.SOPInstanceUID          = atMetaData{1}.SOPInstanceUID;
    % atDcmDicomMeta{1}.SeriesInstanceUID       = dicomuid;
    % atDcmDicomMeta{1}.StudyInstanceUID        = atMetaData{1}.StudyInstanceUID;
    % atDcmDicomMeta{1}.AccessionNumber         = atMetaData{1}.AccessionNumber;
    % atDcmDicomMeta{1}.SeriesTime              = char(datetime('now','TimeZone','local','Format','HHmmss'));
    % atDcmDicomMeta{1}.SeriesDate              = char(datetime('now','TimeZone','local','Format','yyyyMMddHHmmss'));
    % atDcmDicomMeta{1}.AcquisitionTime         = atMetaData{1}.AcquisitionTime;
    % atDcmDicomMeta{1}.AcquisitionDate         = atMetaData{1}.AcquisitionDate;
    % 
    % atDcmDicomMeta{1}.RescaleIntercept = 0;
    % atDcmDicomMeta{1}.RescaleSlope = 1;
    % 
    % else
        atDcmDicomMeta = atMetaData;

        sTime = char(datetime('now','TimeZone','local','Format','HHmmss'));
        sDate = char(datetime('now','TimeZone','local','Format','yyyyMMddHHmmss'));    

        for jj=1:numel(atMetaData)
            atDcmDicomMeta{jj}.SeriesTime = sTime;
            atDcmDicomMeta{jj}.SeriesDate = sDate;        
        end
    % end

    sTmpDir = sprintf('%stemp_dicom_%s//', viewerTempDirectory('get'), datetime('now','Format','MMMM-d-y-hhmmss-MS'));

    if exist(char(sTmpDir), 'dir')

        rmdir(char(sTmpDir), 's');
    end

    mkdir(char(sTmpDir));

    if size(aBuffer, 3) ~=1

        aBuffer = aBuffer(:,:,end:-1:1);
    end

    writeOtherFormatToDICOM(aBuffer, atDcmDicomMeta, sTmpDir, true);   
    
    dicm2nii(sTmpDir, sNiiFolder, dOutFormat);
    
    rmdir(char(sTmpDir), 's');
end