function aBuffer = loadNpFile(sNpPath, sNpFileName, sPklPath, sPklFileName, bInitDisplay, dFactor)
%function aBuffer = loadNpFile(sNpPath, sNpFileName, sPklPath, sPklFileName, bInitDisplay, dFactor)
%Load .np and .npz file to TriDFusion.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Note: option settings must fit on one line and can contain one semicolon at most.
%Options can be strings, cell arrays of strings, or numerical arrays.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2023, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    % Construct full filename
    sFullFilename = fullfile(sNpPath, sNpFileName);
    [~, ~, ext] = fileparts(sFullFilename);

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
        
        progressBar(0.5, sprintf('Reading %s, please wait.', ext));
    end
    
    if strcmpi(ext, '.npz')  

        % Handle npz files by unzipping them to a temporary folder and reading a contained npy file.
        sNpzTmpDir = sprintf('%stemp_npz_%s/', viewerTempDirectory('get'), datetime('now','Format','MMMM-d-y-hhmmss'));
        mkdir(sNpzTmpDir);
        unzip(sFullFilename, sNpzTmpDir);

        % Assuming the npz archive contains one array, find the first .npy file.
        asNpyFiles = dir(fullfile(sNpzTmpDir, '*.npy'));
        if isempty(asNpyFiles)
            progressBar(1, 'Error: No .npy files found in the npz archive!');
            errordlg('No .npy files found in the npz archive!', 'npz Archive Validation');            
        end

        % Initialize file names as empty strings
        sNpyDataFile = '';
        
        % Loop through all files in asNpyFiles
        for i = 1:numel(asNpyFiles)
            currentName = lower(asNpyFiles(i).name); % Convert to lower case for case-insensitive comparison
            if contains(currentName, 'data')
                sNpyDataFile = fullfile(sNpzTmpDir, asNpyFiles(i).name);
            end
        end

        aNPYBuffer = readNPY(sNpyDataFile);
        % [shape, dataType, fortranOrder, littleEndian, totalHeaderLength, header] = readNPYheader(sNpyDataFile);

        rmdir(sNpzTmpDir, 's');  % Clean up temporary directory

    elseif strcmpi(ext, '.npy') || strcmpi(ext, '.np') % Read the file directly
        aNPYBuffer = readNPY(sFullFilename);
        % [shape, dataType, fortranOrder, littleEndian, totalHeaderLength, header] = readNPYheader(sFullFilename);
    else
        progressBar(1, 'Error: Unsupported file extension. Use .pn, .npy or .npz!');
        errordlg('Unsupported file extension. Use .pn, .npy or .npz!', 'File Extension Validation');                    
    end

    imgShape = size(aNPYBuffer);  % For example: [2, 191, 512, 512]
    nd = numel(imgShape);
    
    if nd == 2

        aBuffer = aNPYBuffer;  

        if ~isempty(dFactor)

            aBuffer = aBuffer * dFactor;
        end

        tHeader = extractHeaderFromPkl(sPklPath, sPklFileName);
            
        if isempty(tHeader)

            tHeader.PixelSpacing = [1, 1];
            tHeader.SliceThickness  = 1; 

            tHeader.ImagePositionPatient = zeros(2,1);  

            tHeader.SliceLocation = 1;
        end
        
        tHeader.Rows    = size(aBuffer, 1);
        tHeader.Columns = size(aBuffer, 2);

        tHeader.ImageOrientationPatient = zeros(6,1);
                
        tHeader.ImageOrientationPatient(1) = 1;
        tHeader.ImageOrientationPatient(6) = 1;

        addImageToInputTemplate(aBuffer, tHeader, sNpPath, sNpFileName);
        
        clear aBuffer;

    elseif nd == 3

        aBuffer = squeeze(aNPYBuffer(:, :, :)); % Extract channel i.                      
    
        if ~isempty(dFactor)
            aBuffer = aBuffer * dFactor;
        end

        tHeader = extractHeaderFromPkl(sPklPath, sPklFileName);
        
        if isempty(tHeader)

            tHeader.PixelSpacing = [1, 1];
            tHeader.SliceThickness  = 1;

            tHeader.ImagePositionPatient = zeros(3,1);

            tHeader.SliceLocation = 1;
        else
            aBuffer = reorientVolume(tHeader, aBuffer);                           
        end
        
        aBuffer = aBuffer(:,:,end:-1:1);
     
        % Axial 

        tHeader.Rows    = size(aBuffer, 1);
        tHeader.Columns = size(aBuffer, 2);  

        tHeader.ImageOrientationPatient = zeros(6,1);
                        
        tHeader.ImageOrientationPatient(1) = 1;
        tHeader.ImageOrientationPatient(5) = 1;
              
        addImageToInputTemplate(aBuffer, tHeader, sNpPath, sNpFileName);

        clear aBuffer;
        
    elseif nd == 4

        for i = 1:imgShape(1)

            aBuffer = squeeze(aNPYBuffer(i, :, :, :));

            if ~isempty(dFactor)
                aBuffer = aBuffer * dFactor;
            end

            tHeader = extractHeaderFromPkl(sPklPath, sPklFileName);

            if isempty(tHeader)

                tHeader.PixelSpacing = [1, 1];
                tHeader.SliceThickness  = 1;

                tHeader.ImagePositionPatient = zeros(3,1);
    
                tHeader.SliceLocation = 1;
            else
                aBuffer = reorientVolume(tHeader, aBuffer);                
            end
          
            aBuffer = aBuffer(:,:,end:-1:1);    

            % Axial

            tHeader.Rows    = size(aBuffer, 2);
            tHeader.Columns = size(aBuffer, 1);

            tHeader.ImageOrientationPatient = zeros(6,1);
                        
            tHeader.ImageOrientationPatient(1) = 1;
            tHeader.ImageOrientationPatient(5) = 1;
        
            addImageToInputTemplate(aBuffer, tHeader, sNpPath, sNpFileName);
            
            clear aBuffer;
        end
        
    else
        progressBar(1, 'Error: Unsupported image dimensions!');
        errordlg('Unsupported image dimensions!', 'Image Dimensions Validation');                  
    end
   
    if bInitDisplay == true    

        atInput = inputTemplate('get');

        set(uiSeriesPtr('get'), 'Value', numel(atInput));

        imageOrientation('set', 'axial');       

        cropValue('set', min(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), [], 'all'));

        clearDisplay();  

        initDisplay(3); 
   
        initWindowLevel('set', true);
    
        dicomViewerCore();  
        
        setViewerDefaultColor(1, atInput(numel(atInput)).atDicomInfo);
           
        refreshImages();
        
        % Activate playback
       
        if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 3) ~= 1

            setPlaybackToolbar('on');
        end
        
        setRoiToolbar('on');
        
    end

    progressBar(1, sprintf('Import %s completed.', sNpFileName));

    catch ME
        logErrorToFile(ME);
        progressBar(1, 'Error:loadNpFile()');                        
    end

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow; 

    clear aNPYBuffer;

    if bInitDisplay == true    

        % Reactivate main tool bar 
        set(uiSeriesPtr('get'), 'Enable', 'on');        
        mainToolBarEnable('on');       
    end

    function addImageToInputTemplate(aBuffer, tHeader, sNpFilePath, sNpFileName)

        atInput = inputTemplate('get');

        rows    = tHeader.Rows;
        columns = tHeader.Columns;

        voxelX = tHeader.PixelSpacing(1);
        voxelY = tHeader.PixelSpacing(2);
        voxelZ = tHeader.SliceThickness;

        aImagePositionPatient = tHeader.ImagePositionPatient; 
        aImageOrientationPatient = tHeader.ImageOrientationPatient; 

        dSliceLocation = tHeader.SliceLocation;

        if ~isempty(atInput)
            
            asSeriesDescription = seriesDescription('get');
            asSeriesDescription{numel(asSeriesDescription)+1}=sprintf('Np-%s', sNpFileName);
            
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
            atInput(numel(atInput)).atDicomInfo{1}.SliceLocation = dSliceLocation;  
            
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
            atInput(numel(atInput)).asFilesList{1} = sprintf('%s%s', sNpFilePath, sNpFileName);
            
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
            
            asSeriesDescription{1}=sprintf('Np-%s', sNpFileName);
    
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
            atInput(1).atDicomInfo{1}.SliceLocation = dSliceLocation;  
            
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
            atInput(1).asFilesList{1} = sprintf('%s%s', sNpFilePath, sNpFileName);
            
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
                    
        seriesDescription('set', asSeriesDescription);
                
        inputTemplate('set', atInput);
    
        aInputBuffer = inputBuffer('get');        
        aInputBuffer{numel(aInputBuffer)+1} = aBuffer;    
        inputBuffer('set', aInputBuffer);
            
        set(uiSeriesPtr('get'), 'String', asSeries);
        set(uiFusedSeriesPtr('get'), 'String', asSeries);
        
        dicomMetaData('set', atInput(numel(atInput)).atDicomInfo, numel(atInput));
        dicomBuffer('set', aBuffer, numel(atInput));
        
        setQuantification(numel(atInput));
        
        tQuant = quantificationTemplate('get');
        atInput(numel(atInput)).tQuant = tQuant;
    
        if size(aBuffer, 3) ~= 1
        
            aMip = computeMIP(aBuffer);
            mipBuffer('set', aMip, numel(atInput)) ;
            atInput(numel(atInput)).aMip = aMip;   
        end
        
        inputTemplate('set', atInput); 
    end

    function tHeader = extractHeaderFromPkl(sPklPath, sPklFileName)
        
        try 

        tHeader = [];
        
        if isempty(sPklPath)||isempty(sPklFileName)
            return;
        end

        % Open and read the pkl file

        fid=py.open(fullfile(sPklPath, sPklFileName),'rb');
        pkldata = py.pickle.load(fid);

        tPkldata = struct(pkldata);

        spacing   = double(tPkldata.spacing);
        origin    = double(tPkldata.sitk_stuff{'origin'});
        direction = double(tPkldata.sitk_stuff{'direction'});

        if  numel(spacing) == 3

            tHeader.PixelSpacing = [spacing(3), spacing(2)];
            tHeader.SliceThickness = spacing(1);
            
        else
            tHeader.PixelSpacing = [spacing(2), spacing(1)];
        end

        % ImagePositionPatient is set from the origin values.
        tHeader.ImagePositionPatient   = origin;

        if numel(origin) == 3
            tHeader.SliceLocation = origin(3);
        else
            tHeader.SliceLocation = 1;            
        end

        dirMatrix = reshape(direction, [3, 3]);

        % ImageOrientationPatient is set from the direction values.
        tHeader.ImageOrientationPatient = [dirMatrix(1,:) dirMatrix(2,:)];

        tHeader.Matrix = reshape(direction, [3, 3]);

        % --- Image Dimensions ---
        % [Rows, Columns, NumberOfSlices] (if applicable)
        tHeader.Rows    = double(tPkldata.shape_after_cropping_and_before_resampling{1});
        tHeader.Columns = double(tPkldata.shape_after_cropping_and_before_resampling{2});
        % If there is a third dimension, interpret it as the number of frames/slices.
        if numel(tPkldata.shape_after_cropping_and_before_resampling) >= 3
            tHeader.NumberOfFrames  = double(tPkldata.shape_after_cropping_and_before_resampling{3});
        end

        tHeader.SITKMetadata   = tPkldata.sitk_stuff;   % All stored SITK metadata
        tHeader.ClassLocations = tPkldata.class_locations;

        catch ME
            tHeader = [];
            logErrorToFile(ME);  
            progressBar( 1 , 'Error: extractHeaderFromPkl()' );            
        end
    end

    function aBuffer = reorientVolume(tHeader, aBuffer)
        % reorientVolume transforms a 3D image volume into a canonical orientation.
        %
        %   Inputs:
        %     tHeader - a structure with the following fields:
        %                 Matrix:               3x3 direction matrix.
        %                 ImagePositionPatient: 1x3 vector (origin).
        %                 PixelSpacing:         1x2 vector.
        %                 SliceThickness:       scalar.
        %     aBuffer - the 3D image volume.
        %
        %   Output:
        %     aBufferReoriented - the reoriented 3D image volume.
          
        % [Mtf,~] = TransformMatrix(tHeader, tHeader.SliceThickness, true);
        % 
        % TF = affine3d(Mtf');
        % 
        % % Apply the transformation to the 3D image volume.
        % aBuffer = imwarp(aBuffer, TF, 'interp', 'nearest');                    

        aBufferSize = size(aBuffer);
        
        if numel(aBufferSize) == 3
    
            if aBufferSize(1) == aBufferSize(3)
                % If either header.Rows or header.Columns is found in the size of aBuffer
                aBuffer = permute(aBuffer, [1 3 2]);
            elseif aBufferSize(2) == aBufferSize(3)
                % If neither header.Rows nor header.Columns is found
                aBuffer = permute(aBuffer, [2 3 1]);
            end
        end

   end

end
