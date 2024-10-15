function fix_mask(sRootDir)
% Define the root directory
% sRootDir = 'E:\TRAINED_MODELS\nnUNetv2\nnUNet_raw_data_base\Task121_Metastatic_Breast_Cancer_PETAC_CTAC\data0\training';  % Replace with the path to your folder

% Get list of all subfolders
subfolders = dir(sRootDir);

% Loop over each subfolder
for i = 1:length(subfolders)
    % Check if it's a folder (and not the '.' or '..' entries)
    if subfolders(i).isdir && ~strcmp(subfolders(i).name, '.') && ~strcmp(subfolders(i).name, '..')
        % Construct the expected filename (_gt.nrrd file)
        sNrrdFileName = fullfile(sRootDir, subfolders(i).name, [subfolders(i).name '_gt.nrrd']);
        
        % Check if the file exists
        if isfile(sNrrdFileName)
            fprintf('Processing: %s\n', sNrrdFileName);
            
            % Load the .nrrd file
            [data, meta] = nrrdread(sNrrdFileName);  % Read the NRRD file
            
            % Replace all non-zero values with 1
            data(data ~= 0) = 1;
            
            % Save the modified data back to the file
            % nrrdwrite(sNrrdFileName, data, meta);
        
            if isfield(meta, 'spacedirections')
        
                acSpaceDirections = split(meta.spacedirections);
        
                acVoxelX = split(acSpaceDirections{1}, ',');
                acVoxelY = split(acSpaceDirections{2}, ',');
        
                voxelX = str2double(cleanString(acVoxelX{1}));
                voxelY = str2double(cleanString(acVoxelY{2}));
        
                if str2double(meta.dimension) == 3
                   acVoxelZ = split(acSpaceDirections{3}, ',');
                   voxelZ = str2double(cleanString(acVoxelZ{3}));        
                else    
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
        
            if str2double(meta.dimension) == 3
                aImagePositionPatient = zeros(3,1);
            else
                aImagePositionPatient = zeros(2,1);
            end
        
            if isfield(meta, 'spaceorigin')
        
                acSpaceOrigin = split(meta.spaceorigin, ',');
        
                aImagePositionPatient(1) = str2double(cleanString(acSpaceOrigin{1}));   
                aImagePositionPatient(2) = str2double(cleanString(acSpaceOrigin{2}));   
        
                if str2double(meta.dimension) == 3
                    aImagePositionPatient(3) = str2double(cleanString(acSpaceOrigin{3}));   
                end
            end

            origin = aImagePositionPatient;
            
            pixelspacing = zeros(3,1);
        
            pixelspacing(1) = voxelX;
            pixelspacing(2) = voxelY;
            pixelspacing(3) = voxelZ;

            nrrdWriter(sNrrdFileName, squeeze(data), pixelspacing, origin, 'raw'); % Write .nrrd images 
          
            fprintf('Modified and saved: %s\n', sNrrdFileName);
        else
            fprintf('File not found: %s\n', sNrrdFileName);
        end
    end
end