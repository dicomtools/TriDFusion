function readSTLModel(sPath, sFileName, dimX, dimY, dimZ, voxelX, voxelY, voxelZ, dPixelValue, bFillHoles)
%function readSTLModel(sPath, sFileName, dimX, dimY, dimZ, voxelX, voxelY, voxelZ, dPixelValue, bFillHoles)
%Read .stl Model.
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

    % Deactivate main tool bar 
    set(uiSeriesPtr('get'), 'Enable', 'off');                
    mainToolBarEnable('off');
    
    atInput = inputTemplate('get');

%    if iSeriesOffset > numel(inputTemplate('get'))  
%        return;
%    end 
    
%    try
                
    set(fiMainWindowPtr('get'), 'Pointer', 'watch');
    drawnow; 
    
    releaseRoiWait();

    set(btnTriangulatePtr('get'), 'BackgroundColor', viewerButtonPushedBackgroundColor('get'));
    set(btnTriangulatePtr('get'), 'ForegroundColor', viewerButtonPushedForegroundColor('get'));
    set(btnTriangulatePtr('get'), 'FontWeight', 'bold');

    set(zoomMenu('get'), 'Checked', 'off');
    set(btnZoomPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
    set(btnZoomPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
    set(btnZoomPtr('get'), 'FontWeight', 'normal');
    zoomTool('set', false);
    zoom('off');           

    set(panMenu('get'), 'Checked', 'off');
    set(btnPanPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
    set(btnPanPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));          
    set(btnPanPtr('get'), 'FontWeight', 'normal');
    panTool('set', false);
    pan('off');     

    set(rotate3DMenu('get'), 'Checked', 'off');         
    rotate3DTool('set', false);
    rotate3d off;

    set(dataCursorMenu('get'), 'Checked', 'off');
    dataCursorTool('set', false);              
    datacursormode('off');  
    
    switchTo3DMode    ('set', false);
    switchToIsoSurface('set', false);
    switchToMIPMode   ('set', false);

    set(btnFusionPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
    set(btnFusionPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
    set(btnFusionPtr('get'), 'FontWeight', 'normal');

    set(btn3DPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
    set(btn3DPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
    set(btn3DPtr('get'), 'FontWeight', 'normal');

    set(btnIsoSurfacePtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
    set(btnIsoSurfacePtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
    set(btnIsoSurfacePtr('get'), 'FontWeight', 'normal');

    set(btnMIPPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
    set(btnMIPPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
    set(btnMIPPtr('get'), 'FontWeight', 'normal');
    
    progressBar(0.5, 'Reading stl, please wait.');

    FV = stlread(sprintf('%s%s', sPath, sFileName));            
    
    progressBar(0.999999, 'Converting polygon to voxel, please wait.');

%        aBuffer = polygon2voxel(FV, [dimX dimY dimZ], 'auto');
    aBuffer = polygon2voxel(FV, [dimX dimY dimZ], 'auto');
    if bFillHoles == true
        aBuffer = imfill(aBuffer, 'holes');
    end
    
    aBuffer = aBuffer(:,:,end:-1:1);
    aBuffer = double(aBuffer);
    aBuffer(aBuffer~=0) = dPixelValue;       
    
    if ~isempty(atInput)
        
%        atInput(numel(atInput)+1) = atInput(iSeriesOffset);
%        atInput(numel(atInput)).atDicomInfo = atDcmMetaData;        


        asSeriesDescription = seriesDescription('get');
        asSeriesDescription{numel(asSeriesDescription)+1}=sprintf('STL-%s', sFileName);
        
        atInput(numel(atInput)+1).atDicomInfo = [];        
        
        atInput(numel(atInput)).atDicomInfo{1}.Modality = 'ot';
        atInput(numel(atInput)).atDicomInfo{1}.Units = '';
        atInput(numel(atInput)).atDicomInfo{1}.ReconstructionDiameter = [];
        
        atInput(numel(atInput)).atDicomInfo{1}.PixelSpacing(1)      = voxelX;
        atInput(numel(atInput)).atDicomInfo{1}.PixelSpacing(2)      = voxelY;        
        atInput(numel(atInput)).atDicomInfo{1}.SpacingBetweenSlices = voxelZ;
        atInput(numel(atInput)).atDicomInfo{1}.SliceThickness       = voxelZ;
        
        % Patient information
       
        atInput(numel(atInput)).atDicomInfo{1}.PatientName      = asSeriesDescription{1}; 
        atInput(numel(atInput)).atDicomInfo{1}.PatientID        = asSeriesDescription{1};
        
        atInput(numel(atInput)).atDicomInfo{1}.PatientWeight    = [];
        atInput(numel(atInput)).atDicomInfo{1}.PatientSize      = [];
        atInput(numel(atInput)).atDicomInfo{1}.PatientSex       = '';
        atInput(numel(atInput)).atDicomInfo{1}.PatientAge       = '';
        atInput(numel(atInput)).atDicomInfo{1}.PatientBirthDate = '';   
        
        atInput(numel(atInput)).atDicomInfo{1}.SeriesDescription = asSeriesDescription{1}; 
        
        atInput(numel(atInput)).atDicomInfo{1}.InstanceNumber          = 1; 
        atInput(numel(atInput)).atDicomInfo{1}.PatientPosition         = [];
        atInput(numel(atInput)).atDicomInfo{1}.ImagePositionPatient    = zeros(3,1); 
        atInput(numel(atInput)).atDicomInfo{1}.ImageOrientationPatient = zeros(6,1); 
        
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
   
        atInput(numel(atInput)).atDicomInfo{1}.SeriesTime = '';
        atInput(numel(atInput)).atDicomInfo{1}.SeriesDate = '';

        atInput(numel(atInput)).atDicomInfo{1}.AcquisitionTime = '';
        atInput(numel(atInput)).atDicomInfo{1}.AcquisitionDate = '';   
        
        % Series default
        
        atInput(numel(atInput)).asFilesList    = [];
        atInput(numel(atInput)).asFilesList{1} = sprintf('%s%s',sPath, sFileName);

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
        
        asSeries = get(uiSeriesPtr('get'), 'String');
        asSeries{numel(asSeries)+1} = asSeriesDescription{numel(asSeriesDescription)};   
        
    else
        
        asSeriesDescription{1}=sprintf('STL-%s', sFileName);

        atInput(1).atDicomInfo{1}.Modality = 'ot';
        atInput(1).atDicomInfo{1}.SeriesDescription = asSeriesDescription{1}; 
        atInput(1).atDicomInfo{1}.Units = '';
        atInput(1).atDicomInfo{1}.ReconstructionDiameter = [];
        
        atInput(1).atDicomInfo{1}.PixelSpacing(1)      = voxelX;
        atInput(1).atDicomInfo{1}.PixelSpacing(2)      = voxelY;        
        atInput(1).atDicomInfo{1}.SpacingBetweenSlices = voxelZ;
        atInput(1).atDicomInfo{1}.SliceThickness       = voxelZ;
        
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
        atInput(1).atDicomInfo{1}.ImagePositionPatient    = zeros(3,1); 
        atInput(1).atDicomInfo{1}.ImageOrientationPatient = zeros(6,1); 
        
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
   
        atInput(1).atDicomInfo{1}.SeriesTime = '';
        atInput(1).atDicomInfo{1}.SeriesDate = '';

        atInput(1).atDicomInfo{1}.AcquisitionTime = '';
        atInput(1).atDicomInfo{1}.AcquisitionDate = '';   
        
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
        
        asSeries{1} = asSeriesDescription{1};              
    end   
    
    imageOrientation('set', 'axial');
            
    seriesDescription('set', asSeriesDescription);
            
    inputTemplate('set', atInput);

    aInputBuffer = inputBuffer('get');        
    aInputBuffer{numel(aInputBuffer)+1} = aBuffer;    
    inputBuffer('set', aInputBuffer);
        
    set(uiSeriesPtr('get'), 'String', asSeries);
    set(uiFusedSeriesPtr('get'), 'String', asSeries);
    
    set(uiSeriesPtr('get'), 'Value', numel(atInput));
    dicomMetaData('set', atInput(numel(atInput)).atDicomInfo);
    dicomBuffer('set', aBuffer);
    
    aMip = computeMIP(aBuffer);
    mipBuffer('set', aMip, numel(atInput)) ;
    atInput(numel(atInput)).aMip = aMip;   
    
    setQuantification(numel(atInput));

    tQuant = quantificationTemplate('get');
    atInput(numel(atInput)).tQuant = tQuant;
    inputTemplate('set', atInput);  

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
    
    progressBar(1, sprintf('Import %s completed.', sFileName));
    
%    catch
%        progressBar(1, 'Error:readSTLModel()');                        
%    end

    clear aBuffer;
   
    % Reactivate main tool bar 
    set(uiSeriesPtr('get'), 'Enable', 'on');        
    mainToolBarEnable('on');
    
    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow; 
end
