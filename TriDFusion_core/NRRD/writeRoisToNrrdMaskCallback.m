function writeRoisToNrrdMaskCallback(~, ~)
%function writeRoisToNrrdMaskCallback(~, ~)
%Export ROIs To .nrrd Mask, called from main menu.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2023, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    dOffset = get(uiSeriesPtr('get'), 'Value');
    
%     bSubDir = false;
    
%     sOutDir = outputDir('get');
%     if isempty(sOutDir)
        
        bSubDir = true;

        sCurrentDir  = viewerRootPath('get');

        sMatFile = [sCurrentDir '/' 'exportNrrdMaskLastUsedDir.mat'];
        % load last data directory
        if exist(sMatFile, 'file')
                                    % lastDirMat mat file exists, load it
           load('-mat', sMatFile);
           if exist('exportNrrdMaskLastUsedDir', 'var')
               sCurrentDir = exportNrrdMaskLastUsedDir;
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
            exportNrrdMaskLastUsedDir = sOutDir;
            save(sMatFile, 'exportNrrdMaskLastUsedDir');
        catch ME
            logErrorToFile(ME);
            progressBar(1 , sprintf('Warning: Cant save file %s', sMatFile));
    %        h = msgbox(sprintf('Warning: Cant save file %s', sMatFile), 'Warning');
    %        if integrateToBrowser('get') == true
    %            sLogo = './TriDFusion/logo.png';
    %        else
    %            sLogo = './logo.png';
    %        end

    %        javaFrame = get(h, 'JavaFrame');
    %        javaFrame.setFigureIcon(javax.swing.ImageIcon(sLogo));
        end
%     end    
    
    tInput = inputTemplate('get');    
    aInputBuffer = inputBuffer('get');
    
    writeRoisToNrrdMask(sOutDir, bSubDir, sprintf('%s.nrrd',cleanString(tInput(dOffset).atDicomInfo{1}.SeriesDescription)), aInputBuffer{dOffset}, tInput(dOffset).atDicomInfo, dicomBuffer('get',[],dOffset), dicomMetaData('get',[],dOffset), dOffset, 1);

end
