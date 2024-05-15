function setMachineLearningFDGBrownFatDataPreProcessingPETCallback(hObject, ~)
%function setMachineLearningFDGBrownFatDataPreProcessingPETCallback(hObject)
%AI PET Data Pre-processing, The tool is called from the main menu.
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

    sTask98FolderPath = getenv('nnUnet_Task98_BAT_PETAC');

    if isempty(sTask98FolderPath)

       progressBar( 1, 'Error: nnUnet_Task98_BAT_PETAC environment variable not detected!');
       if exist('hObject', 'var')   
            errordlg(sprintf('nnUnet_Task98_BAT_PETAC environment variable detected!\n Please define an environment variable nnUnet_Task98_BAT_PETAC'), 'nnUnet_Task98_BAT_PETAC Validation');  
        end
        return;
    end

    sPreProcessingFile = sprintf('%s/nrrd.py', sTask98FolderPath);

    if ~exist(sPreProcessingFile, 'file')

        progressBar( 1, 'Error: Machine learning data pre-processind intallation not detected!');
        if exist('hObject', 'var')   
            errordlg(sprintf('Machine learning data pre-processing installation not detected! Please contact Daniel Lafontaine at lafontad@mskcc.org for the installation details.'), 'Machine learning installation validation');   
        end
        return;
    end
                    
    sCommandLine = sprintf('cmd.exe /c start /wait python.exe %s', sPreProcessingFile);    
                
    [bStatus, sCmdout] = system(sCommandLine);

    if bStatus 
        progressBar( 1, 'Error: An error occur during machine learning data pre-processing!');
        errordlg(sprintf('An error occur during machine learning data pre-processing: %s', sCmdout), 'Pre-processing Error'); 
    else
          progressBar( 1, sprintf('Machine learning data pre-processing of folder %s completed.', sTask98FolderPath));      
    end

    sCommandLine = sprintf('cmd.exe /c start /wait nnUNetv2_plan_and_preprocess -d 098');    

    [bStatus, sCmdout] = system(sCommandLine);
    if bStatus 
        progressBar( 1, 'Error: An error occur during machine learning nnUNetv2_plan_and_preprocess!');
        errordlg(sprintf('An error occur during machine learning nnUNetv2_plan_and_preprocess: %s', sCmdout), 'Pre-processing Error'); 
    else
          progressBar( 1, sprintf('Machine learning nnUNetv2_plan_and_preprocess completed.'));      
    end
% 
%     sCommandLine = sprintf('cmd.exe /c start /wait nnUNetv2_train 098 3d_fullres 2');    
%     [bStatus, sCmdout] = system(sCommandLine);
%     if bStatus 
%         progressBar( 1, 'Error: An error occur during machine learning nnUNetv2_train!');
%         errordlg(sprintf('An error occur during machine learning nnUNetv2_train: %s', sCmdout), 'Pre-processing Error'); 
%     else
%           progressBar( 1, sprintf('Machine learning nnUNetv2_train completed.'));      
%     end
end