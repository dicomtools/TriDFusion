function importNrrdCallback(~, ~)
%function importNrrdCallback()
%Import .nrrd file type to TriDFusion.
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
        
%      filter = {'*.nii';'*.gz'};

     sCurrentDir  = viewerRootPath('get');

     sMatFile = [sCurrentDir '/' 'importNrrdLastUsedDir.mat'];
     % load last data directory
     if exist(sMatFile, 'file')
                                % lastDirMat mat file exists, load it
        load('-mat', sMatFile);
        if exist('importNrrdLastUsedDir', 'var')
            sCurrentDir = importNrrdLastUsedDir;
        end
        if sCurrentDir == 0
            sCurrentDir = pwd;
        end
     end

     [sFileName, sPath] = uigetfile(sprintf('%s%s', char(sCurrentDir), '*.nrrd'), 'Import .nrrd file');
     if sFileName ~= 0

        try
            importNrrdLastUsedDir = sPath;
            save(sMatFile, 'importNrrdLastUsedDir');
        catch
            progressBar(1 , sprintf('Warning: Cant save file %s', sMatFile));
        end        
        
%        mainDir('set', sPathName);

        if isVsplash('get') == true

            setVsplashCallback();
        end

        if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 3) ~= 1
            
            link2DMip('set', true);

            set(btnLinkMipPtr('get'), 'BackgroundColor', viewerButtonPushedBackgroundColor('get'));
            set(btnLinkMipPtr('get'), 'ForegroundColor', viewerButtonPushedForegroundColor('get')); 
            set(btnLinkMipPtr('get'), 'FontWeight', 'bold');            
        end

        loadNrrdFile(sPath, sFileName, true, []);    

     end

end
