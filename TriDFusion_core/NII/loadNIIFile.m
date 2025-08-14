function loadNIIFile(sPath, sFileName, bInitDisplay, dFactor)
%function loadNIIFile(sPath, sFileName, bInitDisplay, dFactor)
%Load .nii file to TriDFusion.
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

    % Deactivate main tool bar
    
    atInput = inputTemplate('get');

%    if iSeriesOffset > numel(inputTemplate('get'))  
%        return;
%    end 
    
    try
                
    set(fiMainWindowPtr('get'), 'Pointer', 'watch');
    drawnow; 
    
    if bInitDisplay == true    

        set(uiSeriesPtr('get'), 'Enable', 'off');       

        mainToolBarEnable('off');
        
        releaseRoiWait();
       
        set(btnTriangulatePtr('get'), 'BackgroundColor', viewerButtonPushedBackgroundColor('get'));
        set(btnTriangulatePtr('get'), 'ForegroundColor', viewerButtonPushedForegroundColor('get'));
        % set(btnTriangulatePtr('get'), 'FontWeight', 'bold');
        set(btnTriangulatePtr('get'), 'CData', resizeTopBarIcon('triangulate_white.png'));
   
        set(zoomMenu('get'), 'Checked', 'off');
        set(btnZoomPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
        set(btnZoomPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
        % set(btnZoomPtr('get'), 'FontWeight', 'normal');
        set(btnZoomPtr('get'), 'CData', resizeTopBarIcon('zoom_grey.png'));
        zoomTool('set', false);
        zoomMode(fiMainWindowPtr('get'), get(uiSeriesPtr('get'), 'Value'), 'off');           
    
        set(panMenu('get'), 'Checked', 'off');
        set(btnPanPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
        set(btnPanPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));          
        % set(btnPanPtr('get'), 'FontWeight', 'normal');
        set(btnPanPtr('get'), 'CData', resizeTopBarIcon('pan_grey.png'));
        panTool('set', false);
        panMode(fiMainWindowPtr('get'), get(uiSeriesPtr('get'), 'Value'), 'off');  

        set(rotate3DMenu('get'), 'Checked', 'off');         
        rotate3DTool('set', false);
        rotate3d(fiMainWindowPtr('get'), 'off');
    
        set(dataCursorMenu('get'), 'Checked', 'off');
        dataCursorTool('set', false);              
        datacursormode(fiMainWindowPtr('get'), 'off');  
        
        switchTo3DMode    ('set', false);
        switchToIsoSurface('set', false);
        switchToMIPMode   ('set', false);
    
        set(btnFusionPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
        set(btnFusionPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
        % set(btnFusionPtr('get'), 'FontWeight', 'normal');
        set(btnFusionPtr('get'), 'CData', resizeTopBarIcon('fusion_grey.png'));
    
        set(btn3DPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
        set(btn3DPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
        % set(btn3DPtr('get'), 'FontWeight', 'normal');
        set(btn3DPtr('get'), 'CData', resizeTopBarIcon('3d_volume_grey.png'));
    
        set(btnIsoSurfacePtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
        set(btnIsoSurfacePtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
        % set(btnIsoSurfacePtr('get'), 'FontWeight', 'normal');
        set(btnIsoSurfacePtr('get'), 'CData', resizeTopBarIcon('3d_iso_grey.png'));
    
        set(btnMIPPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
        set(btnMIPPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
        % set(btnMIPPtr('get'), 'FontWeight', 'normal');
        set(btnMIPPtr('get'), 'CData', resizeTopBarIcon('3d_mip_grey.png'));
        
        progressBar(0.5, 'Reading nrrd, please wait.');
    end
    
    progressBar(0.5, 'Reading nii, please wait.');

    nii = nii_tool('load', sprintf('%s%s',sPath, sFileName));

    if isfield(nii.hdr, 'dim')
        rows    = nii.hdr.dim(2);
        columns = nii.hdr.dim(3);
    else
        rows    = 0;
        columns = 0;        
    end

    if isfield(nii.hdr, 'pixdim')

        if nii.hdr.dim(1) == 3
            voxelX = nii.hdr.pixdim(2);
            voxelY = nii.hdr.pixdim(3);
            voxelZ = nii.hdr.pixdim(4);        
        else    
            voxelX = nii.hdr.pixdim(2);
            voxelY = nii.hdr.pixdim(3);
            voxelZ = 1;
        end
     else
        voxelX = 1;
        voxelY = 1;
        voxelZ = 1;          
    end

    aImageOrientationPatient = zeros(6,1);
    
    % Axial
    
    aImageOrientationPatient(1) = 1;
    aImageOrientationPatient(5) = 1;

    aImagePositionPatient = zeros(3,1);

    if isfield(nii.hdr, 'qoffset_x')
        aImagePositionPatient(1) = nii.hdr.qoffset_x;   
    end

    if isfield(nii.hdr, 'qoffset_y')
        aImagePositionPatient(2) = nii.hdr.qoffset_y;   
    end

    if isfield(nii.hdr, 'qoffset_z')
        aImagePositionPatient(3) = nii.hdr.qoffset_z;   
    end

    if numel(size(nii.img)) >2
        aBuffer = imrotate3(nii.img, 90, [0 0 1], 'nearest');
%         aBuffer = aBuffer(end:-1:1,:,:);
    else
        aBuffer = imrotate(nii.img, 90, 'nearest');
%         aBuffer = aBuffer(end:-1:1,:);        
    end

    if ~isempty(dFactor)
        
        aBuffer = aBuffer * dFactor;
    end

    if ~isempty(atInput)
        
%        atInput(numel(atInput)+1) = atInput(iSeriesOffset);
%        atInput(numel(atInput)).atDicomInfo = atDcmMetaData;        


        asSeriesDescription = seriesDescription('get');
        asSeriesDescription{numel(asSeriesDescription)+1}=sprintf('NII-%s', sFileName);
        
        atInput(numel(atInput)+1).atDicomInfo = [];        
        
        atInput(numel(atInput)).atDicomInfo{1}.Modality = 'ot';
        atInput(numel(atInput)).atDicomInfo{1}.Units = '';
        atInput(numel(atInput)).atDicomInfo{1}.ReconstructionDiameter = [];
        
        atInput(numel(atInput)).atDicomInfo{1}.PixelSpacing(1)      = voxelX;
        atInput(numel(atInput)).atDicomInfo{1}.PixelSpacing(2)      = voxelY;        
        atInput(numel(atInput)).atDicomInfo{1}.SpacingBetweenSlices = voxelZ;
        atInput(numel(atInput)).atDicomInfo{1}.SliceThickness       = voxelZ;

        atInput(numel(atInput)).atDicomInfo{1}.Rows    = rows;
        atInput(numel(atInput)).atDicomInfo{1}.Columns = columns;

        % Patient information
       
        atInput(numel(atInput)).atDicomInfo{1}.PatientName      = asSeriesDescription{end}; 
        atInput(numel(atInput)).atDicomInfo{1}.PatientID        = asSeriesDescription{end};
        
        atInput(numel(atInput)).atDicomInfo{1}.PatientWeight    = [];
        atInput(numel(atInput)).atDicomInfo{1}.PatientSize      = [];
        atInput(numel(atInput)).atDicomInfo{1}.PatientSex       = '';
        atInput(numel(atInput)).atDicomInfo{1}.PatientAge       = '';
        atInput(numel(atInput)).atDicomInfo{1}.PatientBirthDate = '';   
        
        atInput(numel(atInput)).atDicomInfo{1}.SeriesDescription = asSeriesDescription{end}; 
        
        atInput(numel(atInput)).atDicomInfo{1}.InstanceNumber          = 1; 
        atInput(numel(atInput)).atDicomInfo{1}.PatientPosition         = [];
        atInput(numel(atInput)).atDicomInfo{1}.ImagePositionPatient    = aImagePositionPatient; 
        atInput(numel(atInput)).atDicomInfo{1}.ImageOrientationPatient = aImageOrientationPatient; 
        atInput(numel(atInput)).atDicomInfo{1}.SliceLocation = 1;  
        
        % Series SOP
       
        atInput(numel(atInput)).atDicomInfo{1}.SOPClassUID = ''; 
        atInput(numel(atInput)).atDicomInfo{1}.MediaStorageSOPClassUID = ''; 
        atInput(numel(atInput)).atDicomInfo{1}.SOPInstanceUID = ''; 
        atInput(numel(atInput)).atDicomInfo{1}.FrameOfReferenceUID = ''; 
        
        % Series UID
        
        atInput(numel(atInput)).atDicomInfo{1}.StudyID           = dicomuid;
        atInput(numel(atInput)).atDicomInfo{1}.SeriesInstanceUID = dicomuid;
        atInput(numel(atInput)).atDicomInfo{1}.StudyInstanceUID  = dicomuid;
        atInput(numel(atInput)).atDicomInfo{1}.AccessionNumber   = '';

        % Date Time

        atInput(numel(atInput)).atDicomInfo{1}.StudyTime = '';
        atInput(numel(atInput)).atDicomInfo{1}.StudyDate = '';

        atInput(numel(atInput)).atDicomInfo{1}.SeriesTime = '';
        atInput(numel(atInput)).atDicomInfo{1}.SeriesDate = '';

        atInput(numel(atInput)).atDicomInfo{1}.AcquisitionTime = '';
        atInput(numel(atInput)).atDicomInfo{1}.AcquisitionDate = '';   

        atInput(numel(atInput)).atDicomInfo{1}.din = [];

        % Dose

        atInput(numel(atInput)).atDicomInfo{1}.DoseUnits = [];
        atInput(numel(atInput)).atDicomInfo{1}.DoseType = [];
        atInput(numel(atInput)).atDicomInfo{1}.Units = [];


        % Series default
        
        atInput(numel(atInput)).asFilesList    = [];
        atInput(numel(atInput)).asFilesList{1} = sprintf('%s%s', sPath, sFileName);
        
        atInput(numel(atInput)).sOrientationView    = 'Axial';
       
        atInput(numel(atInput)).bEdgeDetection      = false;
        atInput(numel(atInput)).bFlipLeftRight      = false;
        atInput(numel(atInput)).bFlipAntPost        = false;
        atInput(numel(atInput)).bFlipHeadFeet       = false;
        atInput(numel(atInput)).bDoseKernel         = false;
        atInput(numel(atInput)).bMathApplied        = false;
        atInput(numel(atInput)).bFusedDoseKernel    = false;
        atInput(numel(atInput)).bFusedEdgeDetection = false;
        
        atInput(numel(atInput)).tMovement = [];
        
        atInput(numel(atInput)).tMovement.bMovementApplied = false;
        atInput(numel(atInput)).tMovement.aGeomtform       = [];
        
        atInput(numel(atInput)).tMovement.atSeq{1}.sAxe         = [];
        atInput(numel(atInput)).tMovement.atSeq{1}.aTranslation = [];
        atInput(numel(atInput)).tMovement.atSeq{1}.dRotation    = [];

        atInput(numel(atInput)).aDicomBuffer = [];
     
        asSeries = get(uiSeriesPtr('get'), 'String');
        asSeries{numel(asSeries)+1} = asSeriesDescription{end};   
        
    else
        
        asSeriesDescription{1}=sprintf('NII-%s', sFileName);

        atInput(1).atDicomInfo{1}.Modality = 'ot';
        atInput(1).atDicomInfo{1}.SeriesDescription = asSeriesDescription{1}; 
        atInput(1).atDicomInfo{1}.Units = '';
        atInput(1).atDicomInfo{1}.ReconstructionDiameter = [];
        
        atInput(1).atDicomInfo{1}.PixelSpacing(1)      = voxelX;
        atInput(1).atDicomInfo{1}.PixelSpacing(2)      = voxelY;        
        atInput(1).atDicomInfo{1}.SpacingBetweenSlices = voxelZ;
        atInput(1).atDicomInfo{1}.SliceThickness       = voxelZ;

        atInput(1).atDicomInfo{1}.Rows    = rows;
        atInput(1).atDicomInfo{1}.Columns = columns;

        % Patient information
       
        atInput(1).atDicomInfo{1}.PatientName      = asSeriesDescription{1}; 
        atInput(1).atDicomInfo{1}.PatientID        = asSeriesDescription{1};
        
        atInput(1).atDicomInfo{1}.PatientWeight    = '';
        atInput(1).atDicomInfo{1}.PatientSize      = '';
        atInput(1).atDicomInfo{1}.PatientSex       = '';
        atInput(1).atDicomInfo{1}.PatientAge       = '';
        atInput(1).atDicomInfo{1}.PatientBirthDate = '';   
        
        atInput(1).atDicomInfo{1}.SeriesDescription = asSeriesDescription{1}; 
        
        atInput(1).atDicomInfo{1}.InstanceNumber          = 1; 
        atInput(1).atDicomInfo{1}.PatientPosition         = [];
        atInput(1).atDicomInfo{1}.ImagePositionPatient    = aImagePositionPatient; 
        atInput(1).atDicomInfo{1}.ImageOrientationPatient = aImageOrientationPatient; 
        atInput(1).atDicomInfo{1}.SliceLocation = 1;  
        
        % Series SOP
       
        atInput(1).atDicomInfo{1}.SOPClassUID = ''; 
        atInput(1).atDicomInfo{1}.MediaStorageSOPClassUID = ''; 
        atInput(1).atDicomInfo{1}.SOPInstanceUID = ''; 
        atInput(1).atDicomInfo{1}.FrameOfReferenceUID = ''; 
        
        % Series UID
        
        atInput(1).atDicomInfo{1}.StudyID           = dicomuid;
        atInput(1).atDicomInfo{1}.SeriesInstanceUID = dicomuid;
        atInput(1).atDicomInfo{1}.StudyInstanceUID  = dicomuid;
        atInput(1).atDicomInfo{1}.AccessionNumber   = '';
       
        % Date Time

        atInput(1).atDicomInfo{1}.StudyTime = '';
        atInput(1).atDicomInfo{1}.StudyDate = ''; 

        atInput(1).atDicomInfo{1}.SeriesTime = '';
        atInput(1).atDicomInfo{1}.SeriesDate = '';

        atInput(1).atDicomInfo{1}.AcquisitionTime = '';
        atInput(1).atDicomInfo{1}.AcquisitionDate = '';   

        % Dose

        atInput(1).atDicomInfo{1}.DoseUnits = [];
        atInput(1).atDicomInfo{1}.DoseType = [];
        atInput(1).atDicomInfo{1}.Units = [];

        atInput(1).atDicomInfo{1}.din = [];
        
        % Series default
        atInput(1).asFilesList    = [];
        atInput(1).asFilesList{1} = sprintf('%s%s', sPath, sFileName);
        
        atInput(1).sOrientationView    = 'Axial';
        
        atInput(1).bEdgeDetection      = false;
        atInput(1).bFlipLeftRight      = false;
        atInput(1).bFlipAntPost        = false;
        atInput(1).bFlipHeadFeet       = false;
        atInput(1).bDoseKernel         = false;
        atInput(1).bMathApplied        = false;
        atInput(1).bFusedDoseKernel    = false;
        atInput(1).bFusedEdgeDetection = false;
        
        atInput(1).tMovement = [];
        
        atInput(1).tMovement.bMovementApplied = false;
        atInput(1).tMovement.aGeomtform       = [];
        
        atInput(1).tMovement.atSeq{1}.sAxe         = [];
        atInput(1).tMovement.atSeq{1}.aTranslation = [];
        atInput(1).tMovement.atSeq{1}.dRotation    = [];  

        atInput(1).aDicomBuffer = [];
   
        asSeries{1} = asSeriesDescription{1};              
    end 

    sOrientation = getImageOrientation(aImageOrientationPatient);

    if      strcmpi(sOrientation, 'Sagittal')

        dCurrentLocation = aImageOrientationPatient(1);
        dNextLocation = dCurrentLocation-voxelZ;

    elseif  strcmpi(sOrientation, 'Coronal')
        
        dCurrentLocation = aImageOrientationPatient(2);
        dNextLocation = dCurrentLocation-voxelZ;
    else    % Axial
        dCurrentLocation = aImageOrientationPatient(3);
        dNextLocation = dCurrentLocation-voxelZ;
    end

    if dCurrentLocation > dNextLocation                    
        if size(aBuffer, 3) ~=1
            aBuffer = aBuffer(:,:,end:-1:1);
        end
    end
           
    seriesDescription('set', asSeriesDescription);
            
    inputTemplate('set', atInput);

    aInputBuffer = inputBuffer('get');        
    aInputBuffer{numel(aInputBuffer)+1} = aBuffer;    
    inputBuffer('set', aInputBuffer);
        
    set(uiSeriesPtr('get'), 'String', asSeries);
    set(uiFusedSeriesPtr('get'), 'String', asSeries);
    
    dicomMetaData('set', atInput(numel(atInput)).atDicomInfo, numel(atInput));
    dicomBuffer('set', aBuffer, numel(atInput));

    if bInitDisplay == true    

        set(uiSeriesPtr('get'), 'Value', numel(atInput));
        
        imageOrientation('set', 'axial');       
    end

    setQuantification(numel(atInput));
    
    tQuant = quantificationTemplate('get');
    atInput(numel(atInput)).tQuant = tQuant;

    if size(aBuffer, 3) ~= 1
    
        aMip = computeMIP(aBuffer);
        mipBuffer('set', aMip, numel(atInput)) ;
        atInput(numel(atInput)).aMip = aMip;   
    end
    
    inputTemplate('set', atInput);  

    if bInitDisplay == true    

        cropValue('set', min(dicomBuffer('get'), [], 'all'));

        clearDisplay();                       

        initDisplay(3); 

        initWindowLevel('set', true);
    
        dicomViewerCore();  
        
        setViewerDefaultColor(1, atInput(numel(atInput)).atDicomInfo);
           
        refreshImages();
        
        % Activate playback
       
        if size(dicomBuffer('get'), 3) ~= 1
            setPlaybackToolbar('on');
        end
        
        setRoiToolbar('on');
        
    end

    progressBar(1, sprintf('Import %s completed.', sFileName));
    
    catch ME
        logErrorToFile(ME);
        progressBar(1, 'Error:loadNIIFile()');                        
    end

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow; 

    clear aBuffer;

    if bInitDisplay == true    

        % Reactivate main tool bar 

        set(uiSeriesPtr('get'), 'Enable', 'on');        
        mainToolBarEnable('on');
       
    end
    
end
