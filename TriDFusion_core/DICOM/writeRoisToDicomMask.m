function writeRoisToDicomMask(sOutDir, bSubDir, aInputBuffer, atInputMeta, aDicomBuffer, atDicomMeta, dSeriesOffset, bIndex, sSeriesDescription)
%function writeRoisToDicomMask(sOutDir, bSubDir, aInputBuffer, atInputMeta, aDicomBuffer, atDicomMeta, dSeriesOffset, bIndex,sSeriesDescription)
%Export ROIs To DICOM mask.
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

    atRoiInput = roiTemplate('get', dSeriesOffset);
    atVoiInput = voiTemplate('get', dSeriesOffset);

    bUseRoiTemplate = false;

    if ~isequal(size(aInputBuffer), size(aDicomBuffer))

        % atRoiInput = resampleROIs(aDicomBuffer, atDicomMeta, aInputBuffer, atInputMeta, atRoiInput, false);
        [atRoiInput, atVoiInput] = resampleROIs(aDicomBuffer, atDicomMeta, aInputBuffer, atInputMeta, atRoiInput, false, atVoiInput, dSeriesOffset);

        atDicomMeta  = atInputMeta;
        aDicomBuffer = aInputBuffer;

        bUseRoiTemplate = true;
    end

    aBufferSize = size(aDicomBuffer);

    aMaskBuffer = zeros(aBufferSize);
 %   aMaskBuffer(aMaskBuffer==0) = min(double(aDicomBuffer),[], 'all');

    nbContours = numel(atVoiInput);
    for cc=1:nbContours

        if mod(cc,5)==1 || cc == 1 || cc == nbContours
            progressBar( cc / nbContours - 0.000001, sprintf('Processing contour %d/%d, please wait', cc, nbContours) );
        end

        nbRois = numel(atVoiInput{cc}.RoisTag);
        for rr=1:nbRois

            for tt=1:numel(atRoiInput)
                if strcmpi(atVoiInput{cc}.RoisTag{rr}, atRoiInput{tt}.Tag)

                    dSliceNb = atRoiInput{tt}.SliceNb;

                    if strcmpi(atRoiInput{tt}.Axe, 'Axe')

                        aSlice = aDicomBuffer(:,:);

                        if bUseRoiTemplate == true
                            roiMask = roiTemplateToMask(atRoiInput{tt}, aSlice);
                        else
                            roiMask = createMask(atRoiInput{tt}.Object, aSlice);
                        end

                        if bIndex == true
                            aSlice( roiMask) =cc;
                            aSlice(~roiMask) =0;
                        else
                            aSlice( roiMask) =1;
                            aSlice(~roiMask) =0;
                        end

                        aSliceMask = aMaskBuffer(:,:);
                        if bIndex == true
                            aMaskBuffer(:,:) = aSlice+aSliceMask;
                        else
                            aMaskBuffer(:,:) = aSlice|aSliceMask;
                        end
                    end

                    if strcmpi(atRoiInput{tt}.Axe, 'Axes1')

                        aSlice =  permute(aDicomBuffer(dSliceNb,:,:), [3 2 1]);

                        if bUseRoiTemplate == true
                            roiMask = roiTemplateToMask(atRoiInput{tt}, aSlice);
                        else
                            roiMask = createMask(atRoiInput{tt}.Object, aSlice);
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

                    if strcmpi(atRoiInput{tt}.Axe, 'Axes2')

                        aSlice = permute(aDicomBuffer(:,dSliceNb,:), [3 1 2]);

                        if bUseRoiTemplate == true
                            roiMask = roiTemplateToMask(atRoiInput{tt}, aSlice);
                        else
                            roiMask = createMask(atRoiInput{tt}.Object, aSlice);
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

                    if strcmpi(atRoiInput{tt}.Axe, 'Axes3')

                        aSlice = aDicomBuffer(:,:,dSliceNb);

                        if bUseRoiTemplate == true
                            roiMask = roiTemplateToMask(atRoiInput{tt}, aSlice);
                        else
                            roiMask = createMask(atRoiInput{tt}.Object, aSlice);
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
        sWriteDir = char(sOutDir) + "TriDFusion_Contours-DICOM-MASK_" + char(sDate) + '/';
        if ~(exist(char(sWriteDir), 'dir'))
            mkdir(char(sWriteDir));
        end
    else
        sWriteDir = char(sOutDir);
    end

%     for ww=1:numel(atDicomMeta)
%         atDicomMeta{ww}.RescaleIntercept = 0;
%         atDicomMeta{ww}.RescaleSlope = 1;
%     end
%
%     bInputIsDicom = false;
%
%      try
%         if exist(char(atInput(dSeriesOffset).asFilesList{1}), 'file') % Input series is dicom
%             if isdicom(char(atInput(dSeriesOffset).asFilesList{1}))
%                 bInputIsDicom = true;
%             end
%         end
%     catch
%     end
%
%     if bInputIsDicom == true % Input series is dicom
%         writeDICOM(aMaskBuffer, atDicomMeta, sWriteDir, dSeriesOffset, false);
%     else % Input series is another format
%         writeOtherFormatToDICOM(aMaskBuffer, atDicomMeta, sWriteDir, dSeriesOffset, false);
%     end


%     for jj=1:numel(atDicomMeta)
        atDcmDicomMeta{1}.Modality                = atDicomMeta{1}.Modality;
        atDcmDicomMeta{1}.Units                   = 'Counts';
        atDcmDicomMeta{1}.PixelSpacing            = atDicomMeta{1}.PixelSpacing;

        if numel(aBufferSize) > 2
            dSliceSPacing = computeSliceSpacing(atDicomMeta);
            if  dSliceSPacing == 0
                dSliceSPacing = 1;
            end
            atDcmDicomMeta{1}.SpacingBetweenSlices = dSliceSPacing;
            atDcmDicomMeta{1}.SliceThickness       = dSliceSPacing;
        end


        atDcmDicomMeta{1}.Rows                    = atDicomMeta{1}.Rows;
        atDcmDicomMeta{1}.Columns                 = atDicomMeta{1}.Columns;
        atDcmDicomMeta{1}.PatientName             = atDicomMeta{1}.PatientName;
        atDcmDicomMeta{1}.PatientID               = atDicomMeta{1}.PatientID;
%         atDcmDicomMeta{1}.PatientWeight           = atDicomMeta{1}.PatientWeight;
%         atDcmDicomMeta{1}.PatientSize             = atDicomMeta{1}.PatientSize;
%         atDcmDicomMeta{1}.PatientSex              = atDicomMeta{1}.PatientSex;
%         atDcmDicomMeta{1}.PatientAge              = atDicomMeta{1}.PatientAge;
%         atDcmDicomMeta{1}.PatientBirthDate        = atDicomMeta{1}.PatientBirthDate;
        atDcmDicomMeta{1}.SeriesDescription       = sprintf('MASK-%s', atDicomMeta{1}.SeriesDescription);
        atDcmDicomMeta{1}.PatientPosition         = atDicomMeta{1}.PatientPosition;
        atDcmDicomMeta{1}.ImagePositionPatient    = atDicomMeta{1}.ImagePositionPatient;
        atDcmDicomMeta{1}.ImageOrientationPatient = atDicomMeta{1}.ImageOrientationPatient;
        % atDcmDicomMeta{1}.SOPClassUID             = '1.2.840.10008.5.1.4.1.1.20';
        % atDcmDicomMeta{1}.SOPInstanceUID          = '1.2.752.37.54.2572.122881719510441496582642976905549489909';
%         atDcmDicomMeta{1}.MediaStorageSOPClassUID     = atDicomMeta{1}.MediaStorageSOPClassUID;
%         atDcmDicomMeta{1}.MediaStorageSOPInstanceUID  = atDicomMeta{1}.MediaStorageSOPInstanceUID;
        atDcmDicomMeta{1}.SOPClassUID             = atDicomMeta{1}.SOPClassUID;
        atDcmDicomMeta{1}.SOPInstanceUID          = atDicomMeta{1}.SOPInstanceUID;
        atDcmDicomMeta{1}.SeriesInstanceUID       = dicomuid;
        atDcmDicomMeta{1}.StudyInstanceUID        = atDicomMeta{1}.StudyInstanceUID;
        atDcmDicomMeta{1}.AccessionNumber         = atDicomMeta{1}.AccessionNumber;
        atDcmDicomMeta{1}.SeriesTime              = char(datetime('now','TimeZone','local','Format','HHmmss'));
        atDcmDicomMeta{1}.SeriesDate              = char(datetime('now','TimeZone','local','Format','yyyyMMdd'));
        atDcmDicomMeta{1}.StudyTime               = atDicomMeta{1}.StudyTime;
        atDcmDicomMeta{1}.StudyDate               = atDicomMeta{1}.StudyDate;
        atDcmDicomMeta{1}.StudyInstanceUID        = atDicomMeta{1}.StudyInstanceUID;
        atDcmDicomMeta{1}.LargestImagePixelValue  = max(aMaskBuffer, [], 'all');
%         atDcmDicomMeta{1}.AcquisitionTime        = '';
%         atDcmDicomMeta{1}.AcquisitionDate        = '';
%         atDcmDicomMeta{1}.RescaleIntercept        = 0;
%         atDcmDicomMeta{1}.RescaleSlope            = 1;
%     end

%     if bInputIsDicom == true % Input series is dicom
%
%         for ww=1:numel(atDicomMeta)
%             atDicomMeta{ww}.RescaleIntercept = 0;
%             atDicomMeta{ww}.RescaleSlope = 1;
%         end
%
%         writeDICOM(aMaskBuffer, atDicomMeta, sWriteDir, dSeriesOffset, false);
%     else % Input series is another format
% atDcmDicomMeta{1}.FrameIncrementPointer  = 'FrameTime';


     if numel(atDicomMeta) > 1
 	     atDcmDicomMeta{1}.InstanceNumber = 1;
         for jj=2:numel(atDicomMeta)
             atDcmDicomMeta{jj} = atDcmDicomMeta{1};
 	         atDcmDicomMeta{jj}.InstanceNumber = jj;
             atDcmDicomMeta{jj}.ImagePositionPatient = atDicomMeta{jj}.ImagePositionPatient;
         end

        aMaskBuffer = aMaskBuffer(:,:,end:-1:1);
     end

    if exist('sSeriesDescription', 'var')
        for jj=1:numel(atDicomMeta)
            atDcmDicomMeta{jj}.SeriesDescription = sSeriesDescription;
        end
    else
        atContours = inputContours('get');
        if ~isempty(atContours)
             for cc=1:numel(atContours)
                if strcmp(atDcmDicomMeta{1}.StudyInstanceUID, atContours{cc}(1).Referenced.StudyInstanceUID)
                    for hh=1:numel(atDcmDicomMeta)
                        atDcmDicomMeta{hh}.SeriesDescription  = sprintf('MASK-%s', atContours{cc}(1).SeriesDescription);
                        if contains(atDcmDicomMeta{hh}.SeriesDescription, 'RT-')
                            atDcmDicomMeta{hh}.SeriesDescription = strrep(atDcmDicomMeta{hh}.SeriesDescription, 'RT-', '');
                        end
                    end
                    break;
                end
             end
        end
    end

    writeOtherFormatToDICOM(aMaskBuffer, atDcmDicomMeta, sWriteDir, false);
%     end

    catch ME   
        logErrorToFile(ME);
        progressBar(1, 'Error:writeRoisToDicomMask()');
    end

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow;

end
