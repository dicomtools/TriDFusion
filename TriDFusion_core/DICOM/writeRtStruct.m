function writeRtStruct(sOutDir, bSubDir, aInputBuffer, atInputMeta, aDicomBuffer, atDicomMeta, dSeriesOffset, bShowSeriesDescriptionDialog, sOvewriteSeriesDescription)
%function writeRtStruct(sOutDir, bSubDir, aInputBuffer, atInputMeta, aDicomBuffer, atDicomMeta, dSeriesOffset, bShowSeriesDescriptionDialog, sOvewriteSeriesDescription)
%Export ROIs To DICOM RT-Structure.
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

    USE_VERTICES = false;

%    PIXEL_EDGE_RATIO = 3;

    atInput = inputTemplate('get');
    if dSeriesOffset > numel(atInput)
        return;
    end
    
    dicomdict('factory');    
    
    if ~isempty(atInput(dSeriesOffset).asFilesList)
        
        sInputFile = atInput(dSeriesOffset).asFilesList{1};
        if ~isempty(sInputFile)
            tMetaData = dicominfo(string(sInputFile));
        else
            tMetaData = atInput(dSeriesOffset).atDicomInfo{1};
        end
    else % CERR
        tMetaData = atInput(dSeriesOffset).atDicomInfo{1};
    end
        
    % Set series label
    
    if exist('sOvewriteSeriesDescription', 'var')
        sSeriesDescription = sOvewriteSeriesDescription;
    else

        if isfield(tMetaData, 'SeriesDescription')
            sSeriesDescription = tMetaData.SeriesDescription;
        else
            sSeriesDescription = '';
        end
        
        sSeriesDescription = sprintf('RT-%s', sSeriesDescription);
    
    
        if bShowSeriesDescriptionDialog == true
    
            sSeriesDescription = getViewerSeriesDescriptionDialog(sSeriesDescription);
            if isempty(sSeriesDescription)
                return;
            end
        end
    end

    % Resample contours (if needed)
    
    atRoiInput = roiTemplate('get', dSeriesOffset);
    atVoiInput = voiTemplate('get', dSeriesOffset);

    if isempty(atRoiInput)
        return;
    end

    if isempty(atVoiInput)
        return;
    end

%    for pp=1:numel(atVoiInput) % Patch, don't export total-mask
%        if strcmpi(atVoiInput{pp}.Label, 'TOTAL-MASK')
%            atVoiInput{pp} = [];
%            atVoiInput(cellfun(@isempty, atVoiInput)) = [];       
%        end
%    end
    
%    bUseRoiTemplate = false;
    try
        
    set(fiMainWindowPtr('get'), 'Pointer', 'watch');
    drawnow;
    
    if modifiedImagesContourMatrix('get') == false
        if numel(aInputBuffer) ~= numel(aDicomBuffer)  
            
            atRoiInput = resampleROIs(aDicomBuffer, atDicomMeta, aInputBuffer, atInputMeta, atRoiInput, false); 
            
            atDicomMeta  = atInputMeta;          
            aDicomBuffer = aInputBuffer;
            
%            bUseRoiTemplate = true;
        end        
    end
    
    bFlip = getImagePosition(dSeriesOffset);

    if bFlip == true
        dZsize = size(aDicomBuffer, 3);
    end
    
    % Set metadata information
    
    sRootPath = viewerRootPath('get');
    info = dicominfo(sprintf('%s/imdata/rtstruct.dcm', sRootPath));
        
    info.Filename = [];
    info.FileModDate = datetime;
    info.ManufacturerModelName = 'TRIDFUSION';
    
    if isfield(tMetaData, 'StudyDate')
        info.StudyDate = tMetaData.StudyDate;
    else
        info.StudyDate = '';
    end
    
    if isfield(tMetaData, 'StudyTime')
        info.StudyTime = tMetaData.StudyTime;
    else
        info.StudyTime = '';
    end
    
    if isfield(tMetaData, 'PatientName')
        info.PatientName = tMetaData.PatientName;
    else
        info.PatientName = '';
    end
    
    if isfield(tMetaData, 'PatientID')
        info.PatientID = tMetaData.PatientID;
    else
        info.PatientID = '';
    end

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
        
    info.SeriesDescription = sSeriesDescription;
    if isfield(tMetaData, 'StudyDescription')
        info.StudyDescription = tMetaData.StudyDescription;
    else
        info.StudyDescription = '';
    end
    
    if isfield(tMetaData, 'StudyID')
        info.StudyID = tMetaData.StudyID;
    else
        info.StudyID = '';
    end
    
    if isfield(tMetaData, 'AccessionNumber')
        info.AccessionNumber = tMetaData.AccessionNumber;
    else
        info.AccessionNumber = '';
    end
    
    info.SeriesNumber = 1;
    info.StructureSetLabel = 'TRIDFUSION';

    info.StructureSetDate = datestr(now, 'yyyymmdd');
    info.StructureSetTime = datestr(now,'HHMMSS.FFF');

    info.ReferencedFrameOfReferenceSequence = [];
    info.StructureSetROISequence = [];
    info.ROIContourSequence = [];
    info.RTROIObservationsSequence = [];

    % set ReferencedFrameOfReferenceSequence %

    if isfield(tMetaData, 'FrameOfReferenceUID')
        sFrameOfReferenceUID = tMetaData.FrameOfReferenceUID;
    else
       sFrameOfReferenceUID = '';
    end 
    
    info.ReferencedFrameOfReferenceSequence.Item_1.FrameOfReferenceUID = sFrameOfReferenceUID;
    info.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.ReferencedSOPClassUID = '1.2.840.10008.3.1.2.3.1';
    info.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.ReferencedSOPInstanceUID = tMetaData.StudyInstanceUID;
    info.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.SeriesInstanceUID = tMetaData.SeriesInstanceUID;

    nbFrames = numel(atDicomMeta); % Simplified DICOM using 1 file have the same SOPClassUID & SOPInstanceUID
    for ii=1:nbFrames
        sVOIitemName = sprintf('Item_%d', ii);
        info.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.ContourImageSequence.(sVOIitemName).ReferencedSOPClassUID = atDicomMeta{ii}.SOPClassUID;
        info.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.ContourImageSequence.(sVOIitemName).ReferencedSOPInstanceUID = atDicomMeta{ii}.SOPInstanceUID;
    end

    % set StructureSetROISequence *

    nbContours = numel(atVoiInput);
    for cc=1:nbContours
        sVOIitemName = sprintf('Item_%d', cc);
        info.StructureSetROISequence.(sVOIitemName).ROINumber = cc;
        info.StructureSetROISequence.(sVOIitemName).ReferencedFrameOfReferenceUID = sFrameOfReferenceUID;
        info.StructureSetROISequence.(sVOIitemName).ROIName = atVoiInput{cc}.Label;
        info.StructureSetROISequence.(sVOIitemName).ROIDescription = '';
        info.StructureSetROISequence.(sVOIitemName).ROIGenerationAlgorithm = 'MANUAL';
    end

    % set ROIContourSequence *

    for cc=1:nbContours
        
        sVOIitemName = sprintf('Item_%d', cc);
            
        info.ROIContourSequence.(sVOIitemName).ROIDisplayColor = atVoiInput{cc}.Color * 255;
        info.ROIContourSequence.(sVOIitemName).ReferencedROINumber = cc;

        if mod(cc,5)==1 || cc == 1 || cc == nbContours
            progressBar( cc / nbContours - 0.000001, sprintf('Processing voi %d/%d, please wait.', cc, nbContours) );
        end

        nbRois = numel(atVoiInput{cc}.RoisTag);
        for rr=1:nbRois

            sROIitemName = sprintf('Item_%d', rr);

            for tt=1:numel(atRoiInput)

                if strcmpi(atVoiInput{cc}.RoisTag{rr}, atRoiInput{tt}.Tag)

                    if strcmpi(atRoiInput{tt}.Axe, 'Axes3') % Only axial plane is supported

                         if strcmpi(atRoiInput{tt}.Type, 'images.roi.rectangle') || ...
                            strcmpi(atRoiInput{tt}.Type, 'images.roi.circle')    || ...
                            strcmpi(atRoiInput{tt}.Type, 'images.roi.ellipse')


%                             if bUseRoiTemplate == true
%                                 bw = roiTemplateToMask(atRoiInput{tt}, aDicomBuffer(:,:,atRoiInput{tt}.SliceNb));      
%                             else
%                                 bw = createMask(atRoiInput{tt}.Object);         
%                             end
        
%                             aBw  = imresize(bw , PIXEL_EDGE_RATIO, 'nearest'); % do not go directly through pixel centers
    
%                             aBoundaries = bwboundaries(aBw);
%                             if ~isempty(aBoundaries)
%                                aBoundaries = aBoundaries{:};
%                                aBoundaries = aBoundaries/PIXEL_EDGE_RATIO;
                            if USE_VERTICES == true
                     
                                xy = atRoiInput{tt}.Vertices-1;
                            else
                                if strcmpi(atRoiInput{tt}.Type, 'images.roi.rectangle')
                                    
                                    dRotation = atRoiInput{tt}.RotationAngle;  % Rotation angle in degrees

                                    % Step 1: Apply rotation (if any)

                                    if dRotation ~= 0

                                        aImageSize = size(aInputBuffer);
                                    
                                        switch lower(sAxe)
                                    
                                            case 'axe' % 2D
                                    
                                                xSize = aImageSize(1);
                                                ySize = aImageSize(2);
                                    
                                            case 'axes1' % Coronal
                                    
                                                xSize = aImageSize(2);
                                                ySize = aImageSize(3);
                                    
                                            case 'axes2' % Sagittal
                                    
                                                xSize = aImageSize(1);
                                                ySize = aImageSize(3);
                                    
                                            case 'axes3' % Axial
                                    
                                                xSize = aImageSize(1);
                                                ySize = aImageSize(2);
                                    
                                            otherwise
                                                return;
                                        end
                                    
                                        theta = deg2rad(dRotation); % Rotation in degrees
                                        
                                        % Rotation matrices 
                                        R = [cos(theta), -sin(theta);
                                             sin(theta),  cos(theta)];
                                        
                                        aCoords = atRoiInput{tt}.Position(:, 1:2); % Extract X, Y coordinates
                                        
                                        aCenter = [xSize/2, ySize/2];     
                                
                                        aTranslatedCoords = aCoords - aCenter; % Translate points to align image center with origin
                                        
                                        aRotatedCoords = (R * aTranslatedCoords')'; % Apply the rotation matrix
                                        
                                        atRoiInput{tt}.Position(:, 1:2) = aRotatedCoords + aCenter; % Translate points back to original position                                       
                                    end

                                    aCorner1 = [atRoiInput{tt}.Position(1), atRoiInput{tt}.Position(2)];  
                                    dWidth   = atRoiInput{tt}.Position(3);
                                    dHeight  = atRoiInput{tt}.Position(4);

                                    % Generate the coordinates of the four corners

                                    aCorner2 = [aCorner1(1), aCorner1(2) + dHeight];           % [x1, y2]
                                    aCorner3 = [aCorner1(1) + dWidth, aCorner1(2) + dHeight];  % [x2, y2]
                                    aCorner4 = [aCorner1(1) + dWidth, aCorner1(2)];            % [x2, y1]
                                    
                                    % Combine all corners into one variable
                                    xy = [aCorner1; aCorner2; aCorner3; aCorner4];
                                                                     
                                elseif strcmpi(atRoiInput{tt}.Type, 'images.roi.circle')

                                    aCenter = atRoiInput{tt}.Position;        % [x, y]
                                    dRadius = atRoiInput{tt}.Radius;          % Radius of the circle
                                                                        
                                    theta = linspace(0, 2*pi, 360); % 360 points around the circle
                                    xCircle = dRadius * cos(theta) + aCenter(1); % X-coordinates of the circle
                                    yCircle = dRadius * sin(theta) + aCenter(2); % Y-coordinates of the circle
                                    
                                    xy = [xCircle; yCircle]';

                                elseif strcmpi(atRoiInput{tt}.Type, 'images.roi.ellipse')  

                                    aCenter  = atRoiInput{tt}.Position;      % [x, y]
                                    semiAxes = atRoiInput{tt}.SemiAxes;      % [a, b]
                                    rotation = atRoiInput{tt}.RotationAngle; % Angle in degrees
                                                                        
                                    theta = linspace(0, 2*pi, 360); % 360 points around the ellipse
                                    x = semiAxes(1) * cos(theta);   % Semi-major axis scaling
                                    y = semiAxes(2) * sin(theta);   % Semi-minor axis scaling
                                    
                                    dRotationRad = deg2rad(-rotation); % Convert degrees to radians
                                    R = [cos(dRotationRad), -sin(dRotationRad); sin(dRotationRad), cos(dRotationRad)];
                                    aRotatedPoints = R * [x; y];      % Rotate points
                                    
                                    % Translate to the center position
                                    xEllipse = aRotatedPoints(1, :) + aCenter(1); % X-coordinates of the ellipse
                                    yEllipse = aRotatedPoints(2, :) + aCenter(2); % Y-coordinates of the ellipse  

                                    xy = [xEllipse; yEllipse]';

                                end
                            end

                            aBoundaries = zeros(size(xy, 1),2);

                            aBoundaries(:,1)=xy(:,2);
                            aBoundaries(:,2)=xy(:,1);

                            dNBoundaries = size(aBoundaries,1);

                            a3DOffset = zeros(size(xy, 1),3);
                
                            a3DOffset(:,1)=xy(:,1)-1;
                            a3DOffset(:,2)=xy(:,2)-1;

                            if numel(atDicomMeta) ~= 1

                                a3DOffset(:,3) = atRoiInput{tt}.SliceNb-1;
                            else
                                a3DOffset(:,3) = atRoiInput{tt}.SliceNb;
                            end
%                            a3DOffset(:,3)=atDicomMeta{atRoiInput{tt}.SliceNb}.SliceLocation;

                            if bFlip == true

                                a3DOffset(:,3) = dZsize-a3DOffset(:,3);
                            end
                                
                            sliceThikness = computeSliceSpacing(atDicomMeta);       
                            [xfm,~] = TransformMatrix(atDicomMeta{1}, sliceThikness);
%                            out = pctransform(pointCloud(a3DOffset), affine3d(xfm'));

%                            aX = out.Location(:,1);
%                            aY = out.Location(:,2);
                            
                            [outX, outY, outZ] = transformPointsForward(affine3d(xfm'), a3DOffset(:,1), a3DOffset(:,2), a3DOffset(:,3)); 
                            
                            aX = outX(:);
                            aY = outY(:);
                            
%                            aZ = out.Location(:,3);
                            aZ = zeros(dNBoundaries, 1);

                            if numel(atDicomMeta) == 1
%                                aZ(:) = a3DOffset(:,3);                                
                                aZ = outZ(:);                                
                            else
%                                 if atDicomMeta{atRoiInput{tt}.SliceNb}.SliceLocation == 0
%                                     aZ(:) = outZ(:);
%                                 else
%                         %            aZ(:) = atDicomMeta{atRoiInput{tt}.SliceNb}.SliceLocation;
                                    aZ(:) = atDicomMeta{atRoiInput{tt}.SliceNb}.ImagePositionPatient(3);
%                                end
                            end
                            

 %                           aZ = zeros(dNBoundaries, 1);
 %                           aZ(:) = atDicomMeta{atRoiInput{tt}.SliceNb}.SliceLocation;
 
                            aXYZ = zeros(dNBoundaries*3, 1);

                            dXOffset=1;
                            for xx=1:3:numel(aXYZ)
                                aXYZ(xx)=aX(dXOffset);
                                dXOffset = dXOffset+1;
                            end

                            dYOffset=1;
                            for yy=2:3:numel(aXYZ)
                                aXYZ(yy) = aY(dYOffset);
                                dYOffset = dYOffset+1;
                            end
                            
                            dZOffset=1;
                            for zz=3:3:numel(aXYZ)
                                aXYZ(zz) = aZ(dZOffset);
                                dZOffset = dZOffset+1;                               
                            end
                            
                            if numel(aXYZ)*64/8 > 65534
                                dNBoundaries = 1;
                                aXYZ = zeros(dNBoundaries*3, 1);
                            end
                            
                            info.ROIContourSequence.(sVOIitemName).ContourSequence.(sROIitemName).ContourImageSequence.Item_1.ReferencedSOPClassUID    = atRoiInput{tt}.SOPClassUID;
                            info.ROIContourSequence.(sVOIitemName).ContourSequence.(sROIitemName).ContourImageSequence.Item_1.ReferencedSOPInstanceUID = atRoiInput{tt}.SOPInstanceUID;
                            info.ROIContourSequence.(sVOIitemName).ContourSequence.(sROIitemName).ContourGeometricType = 'CLOSED_PLANAR';
    
                            info.ROIContourSequence.(sVOIitemName).ContourSequence.(sROIitemName).NumberOfContourPoints = dNBoundaries; % To revisit
                            info.ROIContourSequence.(sVOIitemName).ContourSequence.(sROIitemName).ContourData = aXYZ; % TO DO [NumberOfContourPoints * xyz]                                   
%                             end
                         else
                            aBoundaries = zeros(size(atRoiInput{tt}.Position, 1),2);

                            aBoundaries(:,1) = atRoiInput{tt}.Position(:,2);
                            aBoundaries(:,2) = atRoiInput{tt}.Position(:,1);

                            dNBoundaries = size(aBoundaries,1);

                            a3DOffset = zeros(size(atRoiInput{tt}.Position, 1),3);
                
                            a3DOffset(:,1)=atRoiInput{tt}.Position(:,1)-1;
                            a3DOffset(:,2)=atRoiInput{tt}.Position(:,2)-1;
                            if numel(atDicomMeta) ~= 1
                                a3DOffset(:,3)=atRoiInput{tt}.SliceNb-1;
                            else
                                a3DOffset(:,3)=atRoiInput{tt}.SliceNb;
                            end
%                            a3DOffset(:,3)=atDicomMeta{atRoiInput{tt}.SliceNb}.SliceLocation;

                            if bFlip == true
                                a3DOffset(:,3) = dZsize-a3DOffset(:,3);
                            end
                                
                            sliceThikness = computeSliceSpacing(atDicomMeta);       
                            [xfm,~] = TransformMatrix(atDicomMeta{1}, sliceThikness);
%                            out = pctransform(pointCloud(a3DOffset), affine3d(xfm'));

%                            aX = out.Location(:,1);
%                            aY = out.Location(:,2);
                            
                            [outX, outY, outZ] = transformPointsForward(affine3d(xfm'), a3DOffset(:,1), a3DOffset(:,2), a3DOffset(:,3)); 
                            
                            aX = outX(:);
                            aY = outY(:);
                            
%                            aZ = out.Location(:,3);
                            aZ = zeros(dNBoundaries, 1);
                            if numel(atDicomMeta) == 1
%                                aZ(:) = a3DOffset(:,3);                                
                                aZ = outZ(:);                                
                            else
%                                 if atDicomMeta{atRoiInput{tt}.SliceNb}.SliceLocation == 0
%                                     aZ(:) = outZ(:);
%                                 else
%                         %            aZ(:) = atDicomMeta{atRoiInput{tt}.SliceNb}.SliceLocation;
                                    aZ(:) = atDicomMeta{atRoiInput{tt}.SliceNb}.ImagePositionPatient(3);
%                                end
                            end
                            

 %                           aZ = zeros(dNBoundaries, 1);
 %                           aZ(:) = atDicomMeta{atRoiInput{tt}.SliceNb}.SliceLocation;
 
                            aXYZ = zeros(dNBoundaries*3, 1);

                            dXOffset=1;
                            for xx=1:3:numel(aXYZ)
                                aXYZ(xx)=aX(dXOffset);
                                dXOffset = dXOffset+1;
                            end

                            dYOffset=1;
                            for yy=2:3:numel(aXYZ)
                                aXYZ(yy) = aY(dYOffset);
                                dYOffset = dYOffset+1;
                            end
                            
                            dZOffset=1;
                            for zz=3:3:numel(aXYZ)
                                aXYZ(zz)=aZ(dZOffset);
                                dZOffset = dZOffset+1;                               
                            end
                            
                            if numel(aXYZ)*64/8 > 65534
                                dNBoundaries = 1;
                                aXYZ = zeros(dNBoundaries*3, 1);
                            end
                            
                            info.ROIContourSequence.(sVOIitemName).ContourSequence.(sROIitemName).ContourImageSequence.Item_1.ReferencedSOPClassUID    = atRoiInput{tt}.SOPClassUID;
                            info.ROIContourSequence.(sVOIitemName).ContourSequence.(sROIitemName).ContourImageSequence.Item_1.ReferencedSOPInstanceUID = atRoiInput{tt}.SOPInstanceUID;
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
        info.RTROIObservationsSequence.(sVOIitemName).ObservationNumber    = cc;
        info.RTROIObservationsSequence.(sVOIitemName).ReferencedROINumber  = cc;
        info.RTROIObservationsSequence.(sVOIitemName).ROIObservationLabel  = atVoiInput{cc}.Label;
        info.RTROIObservationsSequence.(sVOIitemName).RTROIInterpretedType = 'ORGAN';

        info.RTROIObservationsSequence.(sVOIitemName).ROIInterpreter.FamilyName = '';
        info.RTROIObservationsSequence.(sVOIitemName).ROIInterpreter.GivenName  = '';
        info.RTROIObservationsSequence.(sVOIitemName).ROIInterpreter.MiddleName = '';
        info.RTROIObservationsSequence.(sVOIitemName).ROIInterpreter.NamePrefix = '';
        info.RTROIObservationsSequence.(sVOIitemName).ROIInterpreter.NameSuffix = '';
    end
    
    if bSubDir == true
        sDate = sprintf('%s', datetime('now','Format','MMMM-d-y-hhmmss'));
        sWriteDir = char(sOutDir) + "TriDFusion_RT_" + char(sDate) + '/';
        if ~(exist(char(sWriteDir), 'dir'))
            mkdir(char(sWriteDir));
        end
    else
        sWriteDir = char(sOutDir);       
    end
    
    sOutFile = sprintf('%s%s.dcm', sWriteDir, info.SeriesInstanceUID);
    dicomwrite([], sOutFile, info, 'CreateMode', 'copy');

    progressBar( 1, sprintf('Export %s completed %s', sOutFile) );

    catch
        progressBar(1, sprintf('Error:writeRtStruct(), %s', sOutDir) );
    end

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow;
    
end

