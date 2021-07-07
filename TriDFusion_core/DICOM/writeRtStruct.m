function writeRtStruct(sOutDir, dOffset)
%function writeRtStruct(sOutDir, tMetaData)
%Export ROIs To DICOM RT-Structure.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%        C. Ross Schmidtlein, schmidtr@mskcc.org
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

    PIXEL_EDGE_RATIO = 3;

    tInput = inputTemplate('get');        
    if dOffset > numel(tInput)
        return;
    end
    
    try
                
    set(fiMainWindowPtr('get'), 'Pointer', 'watch');
    drawnow;  
    
    aInputBuffer = inputBuffer('get');
    aBuffer = aInputBuffer{dOffset};

    atDicomInfo = tInput(dOffset).atDicomInfo;
    
    tRoiInput = roiTemplate('get');
    tVoiInput = voiTemplate('get');   
    
    if ~isempty(tInput(dOffset).asFilesList)
        sInputFile = tInput(dOffset).asFilesList{1};
        tMetaData = dicominfo(string(sInputFile));
    else % CERR
        tMetaData = tInput(dOffset).atDicomInfo{1};
    end
    
    sRootPath  = viewerRootPath('get');    
    info = dicominfo(sprintf('%s/imdata/rtstruct.dcm', sRootPath));
    
    info.Filename = [];
    info.FileModDate = datetime;   
    info.ManufacturerModelName = 'TriDFusion1.0';
    
    info.StudyDate = tMetaData.StudyDate;
    info.StudyTime = tMetaData.StudyTime;
    
    info.PatientName = tMetaData.PatientName;
    info.PatientID = tMetaData.PatientID;
    
    if isfield(tMetaData, 'PatientBirthDate')
        info.PatientBirthDate = tMetaData.PatientBirthDate;
    else
        info.PatientBirthDate = '';       
    end
    
    if isfield(tMetaData, 'PatientSex')
        info.PatientSex = tMetaData.PatientSex;
    else
        info.PatientSex = '';
    end
    
    if isfield(tMetaData, 'ReferringPhysicianName')    
        info.ReferringPhysicianName = tMetaData.ReferringPhysicianName;
    else
        info.ReferringPhysicianName = '';       
    end
    
    info.StudyInstanceUID  = tMetaData.StudyInstanceUID;
    info.SeriesInstanceUID = dicomuid;
    
    info.SeriesDescription = sprintf('RT-%s', tMetaData.SeriesDescription);   
    info.StudyDescription  = tMetaData.StudyDescription;

    if isfield(tMetaData, 'StudyID')    
        info.StudyID = tMetaData.StudyID;
    else
        info.StudyID = '';
    end
    
    info.SeriesNumber = 1;
    info.StructureSetLabel = 'TriDFusion1.0';
        
    info.StructureSetDate = datestr(now, 'yyyymmdd'); 
    info.StructureSetTime = datestr(now,'HHMMSS.FFF');
    
    info.ReferencedFrameOfReferenceSequence = [];
    info.StructureSetROISequence = [];
    info.ROIContourSequence = [];
    info.RTROIObservationsSequence = [];
    
    % set ReferencedFrameOfReferenceSequence %
    
    info.ReferencedFrameOfReferenceSequence.Item_1.FrameOfReferenceUID = tMetaData.FrameOfReferenceUID;
    info.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.ReferencedSOPClassUID = '1.2.840.10008.3.1.2.3.1';   
    info.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.ReferencedSOPInstanceUID = tMetaData.StudyInstanceUID;    
    info.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.SeriesInstanceUID = tMetaData.SeriesInstanceUID;    
    
    nbFrames = numel(atDicomInfo); % Simplified DICOM using 1 file have the same SOPClassUID & SOPInstanceUID
    for ii=1:nbFrames                
        sVOIitemName = sprintf('Item_%d', ii);
        info.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.ContourImageSequence.(sVOIitemName).ReferencedSOPClassUID = atDicomInfo{ii}.SOPClassUID;   
        info.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.ContourImageSequence.(sVOIitemName).ReferencedSOPInstanceUID = atDicomInfo{ii}.SOPInstanceUID;   
    end
    
    % set StructureSetROISequence *
    
    nbContours = numel(tVoiInput);
    for cc=1:nbContours
        sVOIitemName = sprintf('Item_%d', cc);
        info.StructureSetROISequence.(sVOIitemName).ROINumber = cc;
        info.StructureSetROISequence.(sVOIitemName).ReferencedFrameOfReferenceUID = tMetaData.FrameOfReferenceUID;
        info.StructureSetROISequence.(sVOIitemName).ROIName = tVoiInput{cc}.Label;
        info.StructureSetROISequence.(sVOIitemName).ROIDescription = '';
        info.StructureSetROISequence.(sVOIitemName).ROIGenerationAlgorithm = 'MANUAL';
    end

    % set ROIContourSequence *

    for cc=1:nbContours
        sVOIitemName = sprintf('Item_%d', cc);
        info.ROIContourSequence.(sVOIitemName).ROIDisplayColor = tVoiInput{cc}.Color * 255;
        info.ROIContourSequence.(sVOIitemName).ReferencedROINumber = cc;
        
        if mod(cc,5)==1 || cc == 1 || cc == nbContours       
            progressBar( cc / nbContours, sprintf('Processing contour %d/%d, please wait', cc, nbContours) );
        end
            
        nbRois = numel(tVoiInput{cc}.RoisTag);
        for rr=1:nbRois
                    
            sROIitemName = sprintf('Item_%d', rr);
            for tt=1:numel(tRoiInput)
                if strcmpi(tVoiInput{cc}.RoisTag{rr}, tRoiInput{tt}.Tag) 
                    
                    if strcmpi(tRoiInput{tt}.Axe, 'Axes3') % Only axial plane is supported
              
                        bw = createMask(tRoiInput{tt}.Object);

                        aBw  = imresize(bw , PIXEL_EDGE_RATIO, 'nearest'); % do not go directly through pixel centers

                        aBoundaries = bwboundaries(aBw);
                        if ~isempty(aBoundaries)
                            aBoundaries = aBoundaries{:};
                            aBoundaries = aBoundaries/PIXEL_EDGE_RATIO;                                                            

                            dNBoundaries = size(aBoundaries,1);

                            aX = (aBoundaries(:,2)-(size(aBuffer,1)/2)) * tMetaData.PixelSpacing(1); 
                            aY = (aBoundaries(:,1)-(size(aBuffer,2)/2)) * tMetaData.PixelSpacing(2); 
                            aZ = zeros(dNBoundaries, 1);
                            aZ(:) = atDicomInfo{tRoiInput{tt}.SliceNb}.SliceLocation; 

                            dXOffset=1;
                            dYOffset=1;
                            dZOffset=1;
                            aXYZ = zeros(dNBoundaries*3, 1);
                            for xx=1:3:size(aXYZ,1)
                                aXYZ(xx)=aX(dXOffset);
                                dXOffset = dXOffset+1;                       
                            end

                            for yy=2:3:size(aXYZ,1)
                                aXYZ(yy)=aY(dYOffset);
                                dYOffset = dYOffset+1;                       
                            end

                            for zz=3:3:size(aXYZ,1)
                                aXYZ(zz)=aZ(dZOffset);
                                dZOffset = dZOffset+1;                       
                            end

                            info.ROIContourSequence.(sVOIitemName).ContourSequence.(sROIitemName).ContourImageSequence.Item_1.ReferencedSOPClassUID = tRoiInput{tt}.SOPClassUID;
                            info.ROIContourSequence.(sVOIitemName).ContourSequence.(sROIitemName).ContourImageSequence.Item_1.ReferencedSOPInstanceUID = tRoiInput{tt}.SOPInstanceUID;
                            info.ROIContourSequence.(sVOIitemName).ContourSequence.(sROIitemName).ContourGeometricType = 'CLOSED_PLANAR';   

                            info.ROIContourSequence.(sVOIitemName).ContourSequence.(sROIitemName).NumberOfContourPoints = dNBoundaries; % To revisit
                            info.ROIContourSequence.(sVOIitemName).ContourSequence.(sROIitemName).ContourData = aXYZ; % TO DO [NumberOfContourPoints * xyz]
                        end
                    end
                    break;
                end
            end
        end
    end

    % RTROIObservationsSequence %
    
    for cc=1:nbContours
        sVOIitemName = sprintf('Item_%d', cc);
        info.RTROIObservationsSequence.(sVOIitemName).ObservationNumber = cc;
        info.RTROIObservationsSequence.(sVOIitemName).ReferencedROINumber = cc;
        info.RTROIObservationsSequence.(sVOIitemName).ROIObservationLabel = tVoiInput{cc}.Label;
        info.RTROIObservationsSequence.(sVOIitemName).RTROIInterpretedType = 'ORGAN';

        info.RTROIObservationsSequence.(sVOIitemName).ROIInterpreter.FamilyName = '';
        info.RTROIObservationsSequence.(sVOIitemName).ROIInterpreter.GivenName = '';
        info.RTROIObservationsSequence.(sVOIitemName).ROIInterpreter.MiddleName = '';
        info.RTROIObservationsSequence.(sVOIitemName).ROIInterpreter.NamePrefix = '';
        info.RTROIObservationsSequence.(sVOIitemName).ROIInterpreter.NameSuffix = '';        
 
    end
    
    sDate = sprintf('%s', datetime('now','Format','MMMM-d-y-hhmmss'));                
    sWriteDir = char(sOutDir) + "TriDFusion_RT_" + char(sDate) + '/';              
    if ~(exist(char(sWriteDir), 'dir'))
        mkdir(char(sWriteDir));
    end
    
    sOutFile = sprintf('%s%s.dcm', sWriteDir, info.SeriesInstanceUID);
    dicomwrite([], sOutFile, info, 'CreateMode', 'copy');
    
    progressBar( 1, sprintf('Export %s completed %s', sOutFile) );
    
    catch
        progressBar(1, 'Error:writeRtStruct()');                
    end
    
    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow;  
 
end
