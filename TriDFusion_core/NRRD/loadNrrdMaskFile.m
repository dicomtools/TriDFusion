function loadNrrdMaskFile(sPath, sFileName, acLesionMap)
%function loadNrddMaskFile(sPath, sFileName, acLesionMap)
% Reads the specified .nrrd
% mask file located in the directory sPath and processes it for use within the
% TriDFusion system. The function utilizes acLesionMap to translate lesion type
% names (e.g., 'Cervical', 'Abdominal', etc.) into their corresponding numeric
% codes as defined in the mask data.
%
% Input Arguments:
%   sPath       - A string or character vector representing the directory path
%                 to the .nrrd file.
%   sFileName   - A string or character vector containing the name of the .nrrd
%                 file to be loaded.
%   acLesionMap - A containers.Map object (or cell array) that maps lesion type
%                 names to their numeric codes. This mapping is used to correctly
%                 interpret and process the mask data.
%
%   Example:
%       % Define lesion mapping using a containers.Map:
%       lesionMap = containers.Map(...
%           {'background', 'Cervical', 'Supraclavicular', 'Mediastinal', ...
%           'Paraspinal', 'Axillary', 'Abdominal'}, ...
%           [0, 1, 2, 3, 4, 5, 6]);
%
%       % Specify the path and file name:
%       filePath = 'C:\data\masks\';
%       fileName = 'mask.nrrd';
%
%       % Load the mask file into TriDFusion:
%       loadNrddMaskFile(filePath, fileName, lesionMap);
%
%   Note:
%       This function requires the NRRD file format to be supported by the 
%       underlying nrrd file reading utilities (e.g., nrrdread).
%
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
    
    releaseRoiWait();

    progressBar(0.5, 'Reading ndrr, please wait.');

    [aMask, ~] = nrrdread( sprintf('%s%s',sPath, sFileName));

    if size(aMask, 3) ~=1

        aMask = aMask(:,:,end:-1:1);
    end

%     aMask = imrotate3(double(aMask), 90, [0 0 1], 'nearest');
%     aMask = aMask(end:-1:1,:,:);

    dVoiMax = max(aMask, [], 'all');

    bContinue = true;

    if dVoiMax > 100
        answer = questdlg(sprintf('%d masks has been detected, are you sure you want to continue?', dVoiMax), ...
	        'Masks Validation', ...
	        'Yes','No','No');
        % Handle response
        switch answer
            case 'Yes'
                bContinue = true;
            case 'No'
                bContinue = false;
        end        
    end
   
    if bContinue == true

        for jj=1:dVoiMax
    
            progressBar(jj\dVoiMax-0.009, sprintf('Importing mask %d/%d, please wait.',jj, dVoiMax));
    
            % xmin=0.5;
            % xmax=1;
            % aColor=xmin+rand(1,3)*(xmax-xmin);
            aColor = generateUniqueColor(false);
    
            aVoiMask = aMask;
            aVoiMask(aVoiMask~=jj) = 0;
            
            if ~isempty(acLesionMap)

                sLesionType = acLesionMap(jj);
            else
                sLesionType = 'Unspecified';
            end
            
            maskToVoi(aVoiMask, sprintf('MASK %d', jj), sLesionType, aColor, 'axial',  get(uiSeriesPtr('get'), 'Value'), true);
        end
    
        progressBar(1, sprintf('Import %s completed.', sFileName));
    end

    catch ME
        logErrorToFile(ME);
        progressBar(1, 'Error:loadNdrrMaskFile()');                        
    end

    clear aMask;

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow; 

end
