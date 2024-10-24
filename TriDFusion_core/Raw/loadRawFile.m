function loadRawFile(sPathName, sFileName, dimX, dimY, dimZ, voxelX, voxelY, voxelZ, dImageOffset, sUnit, sMachine)
%function loadRawFile(sPathName, sFileName, dimX, dimY, dimZ, voxelX, voxelY, voxelZ, dImageOffset, sUnit, sMachine)
%Load .raw file to TriDFusion.
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
    set(uiSeriesPtr('get'), 'Enable', 'off');                
    mainToolBarEnable('off');
     
    atInput = inputTemplate('get');    
%    atDcmMetaData = dicomMetaData('get');   

%    iSeriesOffset = get(uiSeriesPtr('get'), 'Value');
%    if iSeriesOffset > numel(inputTemplate('get'))  
%        return;
%    end 
    
    try
        
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
    zoom(fiMainWindowPtr('get'), 'off');           

    set(panMenu('get'), 'Checked', 'off');
    set(btnPanPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
    set(btnPanPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));          
    set(btnPanPtr('get'), 'FontWeight', 'normal');
    panTool('set', false);
    pan(fiMainWindowPtr('get'), 'off');     

    set(rotate3DMenu('get'), 'Checked', 'off');         
    rotate3DTool('set', false);
    rotate3d(fiMainWindowPtr('get'), 'off');

    set(dataCursorMenu('get'), 'Checked', 'off');
    dataCursorTool('set', false);              
    datacursormode(fiMainWindowPtr('get'), 'off');  
                
    outputDir('set', '');
       
    mainDir('set', sPathName);
        
    rawFileName = sprintf('%s%s', sPathName, sFileName);
       
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
    
    progressBar(0.5, 'Scaning .raw file');

    switch lower(sMachine)
        case 'big-endian'
            sMachineFmt = 'ieee-be'; 
            
        case 'little-endian'
            sMachineFmt = 'ieee-le'; 
            
        case 'big-endian 64'
            sMachineFmt = 'ieee-be.l64'; 
            
        case 'little-endian 64'
            sMachineFmt = 'ieee-le.l64'; 
            
        otherwise
            sMachineFmt = 'ieee-be'; 
    end
    
    fid = fopen(rawFileName, 'rb', sMachineFmt);
     
    if fid == -1
      error('Cannot open file: %s', rawFileName);
    end
    
%    aBuffer = fread(fid,[dimX dimY], 'uint16');

    fseek(fid, dImageOffset,'bof');

    switch(lower(sUnit))
        case 'uint8'
            aBuffer = uint8(fread(fid,dimX*dimY*dimZ,'uint8'));
        case 'int8'
            aBuffer = int8(fread(fid,dimX*dimY*dimZ,'int8'));
        case 'uint16'
            aBuffer = uint16(fread(fid,dimX*dimY*dimZ,'uint16'));
        case 'int16'
            aBuffer = int16(fread(fid,dimX*dimY*dimZ,'int16'));
        case 'uint32'
            aBuffer = uint32(fread(fid,dimX*dimY*dimZ,'uint32'));
        case 'int32'
            aBuffer = int32(fread(fid,dimX*dimY*dimZ,'int32'));
        case 'single'
            aBuffer = single(fread(fid,dimX*dimY*dimZ,'single'));
        case 'double'
            aBuffer = double(fread(fid,dimX*dimY*dimZ,'double'));
    end

%    aBuffer = fread(fid,  dimX*dimY*dimZ, sUnit);
    fclose(fid);
    aBuffer = reshape(aBuffer, [dimX dimY dimZ]);

%    fclose(fid);
    
    if ~isempty(atInput)
        
%        atInput(numel(atInput)+1) = atInput(iSeriesOffset);
%        atInput(numel(atInput)).atDicomInfo = atDcmMetaData;        


        asSeriesDescription = seriesDescription('get');
        asSeriesDescription{numel(asSeriesDescription)+1}=sprintf('RAW-%s', sFileName);
        
        atInput(numel(atInput)+1).atDicomInfo = [];        
        
        atInput(numel(atInput)).atDicomInfo{1}.Modality = 'ot';
        atInput(numel(atInput)).atDicomInfo{1}.Units = sUnit;
        atInput(numel(atInput)).atDicomInfo{1}.ReconstructionDiameter = [];
        
        atInput(numel(atInput)).atDicomInfo{1}.PixelSpacing(1)      = voxelX;
        atInput(numel(atInput)).atDicomInfo{1}.PixelSpacing(2)      = voxelY;        
        atInput(numel(atInput)).atDicomInfo{1}.SpacingBetweenSlices = voxelZ;
        atInput(numel(atInput)).atDicomInfo{1}.SliceThickness       = voxelZ;
        
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
        atInput(numel(atInput)).atDicomInfo{1}.ImagePositionPatient    = zeros(3,1); 
        atInput(numel(atInput)).atDicomInfo{1}.ImageOrientationPatient = zeros(6,1); 
        
        % Series SOP
       
        atInput(numel(atInput)).atDicomInfo{1}.SOPClassUID = ''; 
        atInput(numel(atInput)).atDicomInfo{1}.MediaStorageSOPClassUID = ''; 
        atInput(numel(atInput)).atDicomInfo{1}.SOPInstanceUID = ''; 
        atInput(numel(atInput)).atDicomInfo{1}.FrameOfReferenceUID = ''; 
        
        % Series UID
 %        atInput(numel(atInput)).atDicomInfo{1}.AccessionNumber   = '';
       
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

        % Manufacturer

        atInput(numel(atInput)).atDicomInfo{1}.Manufacturer           = '';
        atInput(numel(atInput)).atDicomInfo{1}.InstitutionName        = '';
        atInput(numel(atInput)).atDicomInfo{1}.ReferringPhysicianName = '';
        atInput(numel(atInput)).atDicomInfo{1}.StationName            = '';
        atInput(numel(atInput)).atDicomInfo{1}.StudyDescription       = '';
        atInput(numel(atInput)).atDicomInfo{1}.ManufacturerModelName  = '';

        % Dose

        atInput(numel(atInput)).atDicomInfo{1}.DoseUnits = [];
        atInput(numel(atInput)).atDicomInfo{1}.DoseType = [];
        atInput(numel(atInput)).atDicomInfo{1}.Units = [];

        atInput(numel(atInput)).atDicomInfo{1}.din = [];


        % Series default
        
        atInput(numel(atInput)).asFilesList    = [];
        atInput(numel(atInput)).asFilesList{1} = sprintf('%s%s', sPathName, sFileName);

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
        
        asSeriesDescription{1}=sprintf('RAW-%s', sFileName);

        atInput(1).atDicomInfo{1}.Modality = 'ot';
        atInput(1).atDicomInfo{1}.SeriesDescription = asSeriesDescription{1}; 
        atInput(1).atDicomInfo{1}.Units = sUnit;
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
    %    atInput(1).atDicomInfo{1}.AccessionNumber   = '';
        
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

        % Manufacturer
        
        atInput(1).atDicomInfo{1}.Manufacturer           = '';
        atInput(1).atDicomInfo{1}.InstitutionName        = '';
        atInput(1).atDicomInfo{1}.ReferringPhysicianName = '';
        atInput(1).atDicomInfo{1}.StationName            = '';
        atInput(1).atDicomInfo{1}.StudyDescription       = '';
        atInput(1).atDicomInfo{1}.ManufacturerModelName  = '';
        
        % Dose

        atInput(1).atDicomInfo{1}.DoseUnits = [];
        atInput(1).atDicomInfo{1}.DoseType = [];
        atInput(1).atDicomInfo{1}.Units = [];

        atInput(1).atDicomInfo{1}.din = [];
       
        % Series default
        atInput(1).asFilesList    = [];
        atInput(1).asFilesList{1} = sprintf('%s%s', sPathName, sFileName);       

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
    
    cropValue('set', min(dicomBuffer('get'), [], 'all'));

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
   
    progressBar(1, sprintf('Import %s completed', sFileName));
   
    catch
        progressBar(1, 'Error:loadRawFile()');                        
    end

    clear aBuffer;
  
    % Reactivate main tool bar 
    set(uiSeriesPtr('get'), 'Enable', 'on');        
    mainToolBarEnable('on');
    
    set(fiMainWindowPtr('get'), 'Pointer', 'default');            
    drawnow;
    

%    progressBar(1, 'Ready');

end
