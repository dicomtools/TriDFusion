function writeRoisToNiiMask(sOutDir, bSubDir, aInputBuffer, atInputMeta, aDicomBuffer, atDicomMeta, dSeriesOffset, bIndex)
%function writeRoisToNiiMask(sOutDir, bSubDir, aInputBuffer, atInputMeta, aDicomBuffer, atDicomMeta, dSeriesOffset, bIndex)
%Export ROIs To .nii mask.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2021, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    atInput = inputTemplate('get');
    if dSeriesOffset > numel(atInput)
        return;
    end

    try

    set(fiMainWindowPtr('get'), 'Pointer', 'watch');
    drawnow;

    dicomdict('factory');

    % Set series label

%     sSeriesDescription = getViewerSeriesDescriptionDialog(sprintf('MASK-%s', atDicomMeta{1}.SeriesDescription));
%     if isempty(sSeriesDescription)
%         return;
%     end
%
%     for sd=1:numel(atDicomMeta)
%         atDicomMeta{sd}.SeriesDescription = sSeriesDescription;
%     end

    tRoiInput = roiTemplate('get', dSeriesOffset);
    tVoiInput = voiTemplate('get', dSeriesOffset);

    bUseRoiTemplate = false;
    if numel(aInputBuffer) ~= numel(aDicomBuffer)

        [tRoiInput, tVoiInput] = resampleROIs(aDicomBuffer, atDicomMeta, aInputBuffer, atInputMeta, tRoiInput, false, tVoiInput, dSeriesOffset);

        atDicomMeta  = atInputMeta;
        aDicomBuffer = aInputBuffer;

        bUseRoiTemplate = true;
    end

    aBufferSize = size(aDicomBuffer);

    aMaskBuffer = zeros(aBufferSize);
 %   aMaskBuffer(aMaskBuffer==0) = min(double(aDicomBuffer),[], 'all');

    nbContours = numel(tVoiInput);
    for cc=1:nbContours

        if mod(cc,5)==1 || cc == 1 || cc == nbContours
            progressBar( cc / nbContours - 0.000001, sprintf('Processing contour %d/%d, please wait', cc, nbContours) );
        end

        nbRois = numel(tVoiInput{cc}.RoisTag);

        for rr=1:nbRois

            for tt=1:numel(tRoiInput)

                if strcmpi(tVoiInput{cc}.RoisTag{rr}, tRoiInput{tt}.Tag)

                    dSliceNb = tRoiInput{tt}.SliceNb;

                    if strcmpi(tRoiInput{tt}.Axe, 'Axe')

                        aSlice = aDicomBuffer(:,:);

                        if bUseRoiTemplate == true
                            roiMask = roiTemplateToMask(tRoiInput{tt}, aSlice);
                        else
                            roiMask = createMask(tRoiInput{tt}.Object, aSlice);
                        end

                        if bIndex == true
                            aSlice( roiMask) =cc;
                            aSlice(~roiMask) =0;
                        else
                            aSlice( roiMask) =1;
                            aSlice(~roiMask) =0;
                        end

                        aSliceMask =  aMaskBuffer(:,:);
                        if bIndex == true
                             aMaskBuffer(:,:) = aSlice+aSliceMask;
                       else
                            aMaskBuffer(:,:) = aSlice|aSliceMask;
                       end
                    end

                    if strcmpi(tRoiInput{tt}.Axe, 'Axes1')

                        aSlice =  permute(aDicomBuffer(dSliceNb,:,:), [3 2 1]);

                        if bUseRoiTemplate == true
                            roiMask = roiTemplateToMask(tRoiInput{tt}, aSlice);
                        else
                            roiMask = createMask(tRoiInput{tt}.Object, aSlice);
                        end

                        if bIndex == true
                            aSlice( roiMask) =cc;
                            aSlice(~roiMask) =0;
                        else
                            aSlice( roiMask) =1;
                            aSlice(~roiMask) =0;
                        end

                        aSliceMask =  permute(aMaskBuffer(dSliceNb,:,:), [3 2 1]);
                        if bIndex == true
                            aSlice = aSlice+aSliceMask;
                        else
                            aSlice = aSlice|aSliceMask;
                        end
                        aMaskBuffer(dSliceNb,:,:) = permute(reshape(aSlice, [1 size(aSlice)]), [1 3 2]);
                    end

                    if strcmpi(tRoiInput{tt}.Axe, 'Axes2')

                        aSlice = permute(aDicomBuffer(:,dSliceNb,:), [3 1 2]);

                        if bUseRoiTemplate == true
                            roiMask = roiTemplateToMask(tRoiInput{tt}, aSlice);
                        else
                            roiMask = createMask(tRoiInput{tt}.Object, aSlice);
                        end

                        if bIndex == true
                            aSlice( roiMask) =cc;
                            aSlice(~roiMask) =0;
                        else
                            aSlice( roiMask) =1;
                            aSlice(~roiMask) =0;
                        end

                        aSliceMask =  permute(aMaskBuffer(:,dSliceNb,:), [3 1 2]);
                        if bIndex == true
                            aSlice = aSlice+aSliceMask;
                        else
                            aSlice = aSlice|aSliceMask;
                        end
                        aMaskBuffer(:,dSliceNb,:) = permute(reshape(aSlice, [1 size(aSlice)]), [3 1 2]);
                    end

                    if strcmpi(tRoiInput{tt}.Axe, 'Axes3')

                        aSlice = aDicomBuffer(:,:,dSliceNb);

                        if bUseRoiTemplate == true
                            roiMask = roiTemplateToMask(tRoiInput{tt}, aSlice);
                        else
                            roiMask = createMask(tRoiInput{tt}.Object, aSlice);
                        end

                        if bIndex == true
                            aSlice( roiMask) =cc;
                            aSlice(~roiMask) =0;
                        else
                            aSlice( roiMask) =1;
                            aSlice(~roiMask) =0;
                        end

                        aSliceMask =  aMaskBuffer(:,:,dSliceNb);

                        if bIndex == true
                            aMaskBuffer(:,:,dSliceNb) = aSlice+aSliceMask;
                        else
                            aMaskBuffer(:,:,dSliceNb) = aSlice|aSliceMask;
                        end

                    end
                    break;
                end
            end
        end
    end

%     aMaskBuffer(aMaskBuffer~=0) = aDicomBuffer(aMaskBuffer~=0);
%     aMaskBuffer(aMaskBuffer==0) = min(double(aDicomBuffer),[], 'all');

    if bIndex == false
        aMaskBuffer(aMaskBuffer~=0) = 1;
        aMaskBuffer(aMaskBuffer==0) = 0;
    end

    if bSubDir == true
        sDate = sprintf('%s', datetime('now','Format','MMMM-d-y-hhmmss'));
        sWriteDir = char(sOutDir) + "TriDFusion_Contours-NII-MASK_" + char(sDate) + '/';
        if ~(exist(char(sWriteDir), 'dir'))
            mkdir(char(sWriteDir));
        end
    else
        sWriteDir = char(sOutDir);
    end

    % Create an empty directory

    sDICOMPath = sprintf('%stemp_dicom_%s/', viewerTempDirectory('get'), datetime('now','Format','MMMM-d-y-hhmmss'));
    if exist(char(sDICOMPath), 'dir')
        rmdir(char(sDICOMPath), 's');
    end
    mkdir(char(sDICOMPath));

%     if size(aMaskBuffer, 3) ==1
%         aMaskBuffer = aMaskBuffer(end:-1:1,:);
%     else
%         aMaskBuffer = aMaskBuffer(:,:,end:-1:1);
%         aMaskBuffer = aMaskBuffer(end:-1:1,:,:);
%
% %        aMaskBuffer = aMaskBuffer(:,:,2:end);
%
%     end
%
%     for ww=1:numel(atDicomMeta)
%         atDicomMeta{ww}.RescaleIntercept = 0;
%         atDicomMeta{ww}.RescaleSlope = 1;
%     end
%
%     bInputIsDicom = false;
%
%     try
%         if exist(char(atInput(dSeriesOffset).asFilesList{1}), 'file') % Input series is dicom
%             if isdicom(char(atInput(dSeriesOffset).asFilesList{1}))
%                 bInputIsDicom = true;
%             end
%         end
%     catch
%     end

%     atNiiDicomMeta = cell(1, numel(atDicomMeta));atInput



%     for jj=1:numel(atDicomMeta)
        atNiiDicomMeta{1}.Modality                = atDicomMeta{1}.Modality;
        atNiiDicomMeta{1}.Units                   = 'Counts';
        atNiiDicomMeta{1}.PixelSpacing            = atDicomMeta{1}.PixelSpacing;
        if numel(aBufferSize) > 2
            dSliceSPacing = computeSliceSpacing(atDicomMeta);
            if  dSliceSPacing == 0
                dSliceSPacing = 1;
            end
            atNiiDicomMeta{1}.SpacingBetweenSlices    = dSliceSPacing;
            atNiiDicomMeta{1}.SliceThickness          = dSliceSPacing;
        end
        atNiiDicomMeta{1}.Rows                    = atDicomMeta{1}.Rows;
        atNiiDicomMeta{1}.Columns                 = atDicomMeta{1}.Columns;
%         atNiiDicomMeta{1}.PatientName             = atDicomMeta{1}.PatientName;
%         atNiiDicomMeta{1}.PatientID               = atDicomMeta{1}.PatientID;
%         atNiiDicomMeta{1}.PatientWeight           = atDicomMeta{1}.PatientWeight;
%         atNiiDicomMeta{1}.PatientSize             = atDicomMeta{1}.PatientSize;
%         atNiiDicomMeta{1}.PatientSex              = atDicomMeta{1}.PatientSex;
%         atNiiDicomMeta{1}.PatientAge              = atDicomMeta{1}.PatientAge;
%         atNiiDicomMeta{1}.PatientBirthDate        = atDicomMeta{1}.PatientBirthDate;
        atNiiDicomMeta{1}.SeriesDescription       = sprintf('MASK-%s', atDicomMeta{1}.SeriesDescription);
        if isfield(atNiiDicomMeta, 'PatientPosition')
            atNiiDicomMeta{1}.PatientPosition         = atDicomMeta{1}.PatientPosition;
        end
        % if isDicomImageFlipped(atDicomMeta)
        %     atNiiDicomMeta{1}.ImagePositionPatient = atDicomMeta{end}.ImagePositionPatient;
        % else
        %     atNiiDicomMeta{1}.ImagePositionPatient = atDicomMeta{1}.ImagePositionPatient;
        % end
        atNiiDicomMeta{1}.ImageOrientationPatient = atDicomMeta{1}.ImageOrientationPatient;
%         atNiiDicomMeta{1}.MediaStorageSOPClassUID     = atDicomMeta{1}.MediaStorageSOPClassUID;
%         atNiiDicomMeta{1}.MediaStorageSOPInstanceUID  = atDicomMeta{1}.MediaStorageSOPInstanceUID;
        atNiiDicomMeta{1}.StudyInstanceUID        = atDicomMeta{1}.StudyInstanceUID;
        atNiiDicomMeta{1}.AccessionNumber         = atDicomMeta{1}.AccessionNumber;
        % atNiiDicomMeta{1}.SOPClassUID             = '1.2.840.10008.5.1.4.1.1.20';
        % atNiiDicomMeta{1}.SOPInstanceUID          = '1.2.752.37.54.2572.122881719510441496582642976905549489909';
        atNiiDicomMeta{1}.SOPClassUID             = atDicomMeta{1}.SOPClassUID;
        atNiiDicomMeta{1}.SOPInstanceUID          = atDicomMeta{1}.SOPInstanceUID;
        atNiiDicomMeta{1}.SeriesInstanceUID       = dicomuid;
        atNiiDicomMeta{1}.StudyInstanceUID        = atDicomMeta{1}.StudyInstanceUID;
        atNiiDicomMeta{1}.AccessionNumber         = atDicomMeta{1}.AccessionNumber;
        atNiiDicomMeta{1}.SeriesTime              = char(datetime('now','TimeZone','local','Format','HHmmss'));
        atNiiDicomMeta{1}.SeriesDate              = char(datetime('now','TimeZone','local','Format','yyyyMMddHHmmss'));
%         atNiiDicomMeta{1}.AcquisitionTime        = '';
%         atNiiDicomMeta{1}.AcquisitionDate        = '';
%         atNiiDicomMeta{1}.RescaleIntercept        = 0;
%         atNiiDicomMeta{1}.RescaleSlope            = 1;
%     end

%    if bInputIsDicom == true % Input series is dicom
%        writeDICOM(aMaskBuffer, atDicomMeta, sDICOMPath, dSeriesOffset, false);
%    else % Input series is another format
        writeOtherFormatToDICOM(aMaskBuffer, atNiiDicomMeta, sDICOMPath, false);
%    end

%     [sFilePath, ~, ~] = fileparts(char(atInputTemplate(dSeriesOffset).asFilesList{1}));

    dicm2nii(sDICOMPath, sWriteDir, 1);

    if exist(char(sDICOMPath), 'dir')
        rmdir(char(sDICOMPath), 's');
    end

    progressBar(1, sprintf('Export NII mask to %s completed', char(sWriteDir)));

    catch ME
        logErrorToFile(ME);
        progressBar(1, 'Error:writeRoisToNiiMask()');
    end

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow;

end
