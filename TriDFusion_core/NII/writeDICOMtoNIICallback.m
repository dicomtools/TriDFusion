function writeDICOMtoNIICallback(~, ~)
%function writeDICOMtoNIICallback()
%Import .nii file type to TriDFusion.
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
           
    atInputTemplate = inputTemplate('get');

    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');
    if dSeriesOffset > numel(atInputTemplate)
        return;
    end
    
    sOutDir = outputDir('get');
    if isempty(sOutDir)
                
        sCurrentDir  = viewerRootPath('get');

         sMatFile = [sCurrentDir '/' 'exportNIILastUsedDir.mat'];
         % load last data directory
         if exist(sMatFile, 'file')
                                    % lastDirMat mat file exists, load it
            load('-mat', sMatFile);
            if exist('exportNIILastUsedDir', 'var')
                sCurrentDir = exportNIILastUsedDir;
            end
            if sCurrentDir == 0
                sCurrentDir = pwd;
            end
         end

        sOutDir = uigetdir(sCurrentDir);
        if sOutDir == 0
            return;
        end
        sOutDir = [sOutDir '/'];

        try
            exportNIILastUsedDir = sOutDir;
            save(sMatFile, 'exportNIILastUsedDir');
        catch
            progressBar(1 , sprintf('Warning: Cant save file %s', sMatFile));
        end
    
        sDate = sprintf('%s', datetime('now','Format','MMMM-d-y-hhmmss'));                
        sOutDir = char(sOutDir) + "TriDFusion_NII_" + char(sDate) + '/';              
        if ~(exist(char(sOutDir), 'dir'))
            mkdir(char(sOutDir));
        end
    end
    
    [sFilePath, ~, ~] = fileparts(char(atInputTemplate(dSeriesOffset).asFilesList{1}));

    dicm2nii(sFilePath, sOutDir, 1);

end
