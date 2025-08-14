function writePlotEditCallback(hObject, ~)
%function writePlotEditCallback(hObject, ~)
%Export plot edit to a DICOM dicom, the tool is called from main menu.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2025, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    try

    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');
    
    bSubDir = false;
    
    sOutDir = outputDir('get');
    if isempty(sOutDir)
        
        bSubDir = true;

        sCurrentDir  = viewerRootPath('get');

        sMatFile = [sCurrentDir '/' 'lastWriteDicomDir.mat'];
        % load last data directory
        if exist(sMatFile, 'file')
                                    % lastDirMat mat file exists, load it
           load('-mat', sMatFile, 'exportDicomLastUsedDir');
           if exist('exportDicomLastUsedDir', 'var')
               sCurrentDir = exportDicomLastUsedDir;
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
            exportDicomLastUsedDir = sOutDir;
            save(sMatFile, 'exportDicomLastUsedDir');
        catch ME   
            logErrorToFile(ME);
            progressBar(1 , sprintf('Warning: Cant save file %s', sMatFile));
        end        
    end
    
    tInput = inputTemplate('get');    
    aInputBuffer = inputBuffer('get');

    if exist('hObject', 'var')

        bShowSeriesDescriptionDialog = true;
    else
        bShowSeriesDescriptionDialog = false;
    end

    writePlotEdit(sOutDir, bSubDir, aInputBuffer{dSeriesOffset}, tInput(dSeriesOffset).atDicomInfo, dicomBuffer('get', [], dSeriesOffset), dicomMetaData('get', [], dSeriesOffset), dSeriesOffset, bShowSeriesDescriptionDialog);

    clear aInputBuffer;
    clear tInput;

    catch ME
        logErrorToFile(ME);
        progressBar(1, 'Error: writePlotEditCallback()' );    
    end
end
