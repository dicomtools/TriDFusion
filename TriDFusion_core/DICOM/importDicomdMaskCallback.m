function importDicomdMaskCallback(~, ~)
%function importDicomdMaskCallback()
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
   
     dSeriesOffset = get(uiSeriesPtr('get'), 'Value');
   
%      filter = {'*.nii'};

     sCurrentDir  = viewerRootPath('get');

     sMatFile = [sCurrentDir '/' 'importDicomLastUsedDir.mat'];
     % load last data directory
     if exist(sMatFile, 'file')
                                % lastDirMat mat file exists, load it
        load('-mat', sMatFile);
        if exist('importDicomLastUsedDir', 'var')
            sCurrentDir = importDicomLastUsedDir;
        end
        if sCurrentDir == 0
            sCurrentDir = pwd;
        end
     end

%      [sFileName, sPath] = uigetfile({'*.gz';'*.nii'}, sprintf('%s', char(sCurrentDir), 'Import .nii file'));
     [sFileName, sPath] = uigetfile(sprintf('%s%s', char(sCurrentDir), '*.*'), 'Import .dcm mask file');

     if sFileName ~= 0

        if contourVisibilityRoiPanelValue('get') == false

            contourVisibilityRoiPanelValue('set', true);
            set(chkContourVisibilityPanelObject('get'), 'Value', true);

            refreshImages();  

            if size(dicomBuffer('get', [], dSeriesOffset), 3) ~= 1

                plotRotatedRoiOnMip(axesMipPtr('get', [], dSeriesOffset), dicomBuffer('get', [], dSeriesOffset), mipAngle('get'));       
            end
        end

        try
            importDicomLastUsedDir = sPath;
            save(sMatFile, 'importDicomLastUsedDir');
            
        catch ME   
            logErrorToFile(ME);
            progressBar(1 , sprintf('Warning: Cant save file %s', sMatFile));
        end        
        
%        mainDir('set', sPathName);

        loadDcmMaskFile(sPath, sFileName); 

%        triangulateImages();
        refreshImages();

     end

end
