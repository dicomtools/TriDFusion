function importNIIMaskCallback(~, ~)
%function importNIIMaskCallback()
%Import .nii mask file type to TriDFusion.
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

     if switchTo3DMode('get')     == true ||  ...
        switchToIsoSurface('get') == true || ...
        switchToMIPMode('get')    == true

         return;
     end     
        
%      filter = {'*.nii'};

     sCurrentDir  = viewerRootPath('get');

     sMatFile = [sCurrentDir '/' 'importNIILastUsedDir.mat'];
     % load last data directory
     if exist(sMatFile, 'file')
                                % lastDirMat mat file exists, load it
        load('-mat', sMatFile);
        if exist('importNIILastUsedDir', 'var')
            sCurrentDir = importNIILastUsedDir;
        end
        if sCurrentDir == 0
            sCurrentDir = pwd;
        end
     end

%      [sFileName, sPath] = uigetfile({'*.gz';'*.nii'}, sprintf('%s', char(sCurrentDir), 'Import .nii file'));
     [sFileName, sPath] = uigetfile(sprintf('%s%s', char(sCurrentDir), '*.gz;*.nii'), 'Import .nii mask file');

     if sFileName ~= 0

        try
            importNIILastUsedDir = sPath;
            save(sMatFile, 'importNIILastUsedDir');
        catch
            progressBar(1 , sprintf('Warning: Cant save file %s', sMatFile));

        end        
        
%        mainDir('set', sPathName);

        loadNIIMaskFile(sPath, sFileName); 

        triangulateImages();

     end

end
