function loadNIIMaskFile(sPath, sFileName)
%function loadNIIMaskFile(sPath, sFileName)
%Load .nii mask file to TriDFusion.
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

    try

    set(fiMainWindowPtr('get'), 'Pointer', 'watch');            
    drawnow;
    
    releaseRoiWait();

    progressBar(0.5, 'Reading nii, please wait.');

    nii = nii_tool('load', sprintf('%s%s',sPath, sFileName));

    if isfield(nii.hdr, 'pixdim')

        if nii.hdr.dim(1) == 3
%             voxelX = nii.hdr.pixdim(2);
%             voxelY = nii.hdr.pixdim(3);
            voxelZ = nii.hdr.pixdim(4);        
        else    
%             voxelX = nii.hdr.pixdim(2);
%             voxelY = nii.hdr.pixdim(3);
            voxelZ = 1;
        end
     else
%         voxelX = 1;
%         voxelY = 1;
        voxelZ = 1;          
    end

    aImageOrientationPatient = zeros(6,1);
    
    % Axial
    
    aImageOrientationPatient(1) = 1;
    aImageOrientationPatient(5) = 1;
    
    if numel(size(nii.img)) >2
        aMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');
%         aMask = aMask(end:-1:1,:,:);
    else
        aMask = imrotate(nii.img, 90, 'nearest');
%         aMask = aMask(end:-1:1,:);        
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
        if size(aMask, 3) ~=1
            aMask = aMask(:,:,end:-1:1);
        end
    end

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
    
            maskToVoi(aVoiMask, sprintf('MASK %d', jj), 'Unspecified', aColor, 'axial',  get(uiSeriesPtr('get'), 'Value'), true);
        end
    
        progressBar(1, sprintf('Import %s completed.', sFileName));
    end

    catch ME
        logErrorToFile(ME);
        progressBar(1, 'Error:loadNIIMaskFile()');                        
    end

    clear aMask;

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow; 

end
