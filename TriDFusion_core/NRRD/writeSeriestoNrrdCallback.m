function writeSeriestoNrrdCallback(~, ~)
%function writeSeriestoNrrdCallback()
%Export series to .nrrd file type.
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

    atInputTemplate = inputTemplate('get');

    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');
    if dSeriesOffset > numel(atInputTemplate)
        set(fiMainWindowPtr('get'), 'Pointer', 'default');
        drawnow;        
        return;
    end
    
%     sOutDir = outputDir('get');
%     
%     if isempty(sOutDir)
                
        sCurrentDir  = viewerRootPath('get');

         sMatFile = [sCurrentDir '/' 'exportNrrdLastUsedDir.mat'];
         % load last data directory
         if exist(sMatFile, 'file')
                                    % lastDirMat mat file exists, load it
            load('-mat', sMatFile);
            if exist('exportNrrdLastUsedDir', 'var')
                sCurrentDir = exportNrrdLastUsedDir;
            end
            if sCurrentDir == 0
                sCurrentDir = pwd;
            end
         end

        sOutDir = uigetdir(sCurrentDir);
        if sOutDir == 0
            set(fiMainWindowPtr('get'), 'Pointer', 'default');
            drawnow;
            return;
        end
        sOutDir = [sOutDir '/'];

        try
            exportNrrdLastUsedDir = sOutDir;
            save(sMatFile, 'exportNrrdLastUsedDir');
        catch
            progressBar(1 , sprintf('Warning: Cant save file %s', sMatFile));
        end
    
        sDate = sprintf('%s', datetime('now','Format','MMMM-d-y-hhmmss'));                
        sOutDir = char(sOutDir) + "TriDFusion_NRRD_" + char(sDate) + '/';              
        if ~(exist(char(sOutDir), 'dir'))
            mkdir(char(sOutDir));
        end
%     end
    
%     [sFilePath, ~, ~] = fileparts(char(atInputTemplate(dSeriesOffset).asFilesList{1}));
% 
%     dicm2nii(sFilePath, sOutDir, 1);

    % Write .nrrd files 

    atMetaData  = dicomMetaData('get', [], dSeriesOffset);
        
    origin = atMetaData{1}.ImagePositionPatient;
    
    pixelspacing = zeros(3,1);

    pixelspacing(1) = atMetaData{1}.PixelSpacing(1);
    pixelspacing(2) = atMetaData{1}.PixelSpacing(2);
    pixelspacing(3) = computeSliceSpacing(atMetaData);

    sNrrdImagesName = sprintf('%s%s.nrrd', sOutDir, cleanString(atMetaData{1}.SeriesDescription));

    aBuffer = dicomBuffer('get', [], dSeriesOffset);

%     if size(aBuffer, 3) ~=1
% 
%         aBuffer = aBuffer(:,:,end:-1:1);
%     end

    nrrdWriter(sNrrdImagesName, squeeze(aBuffer), pixelspacing, origin, 'raw'); % Write .nrrd images 
    
    clear aBuffer;

    progressBar(1, sprintf('Export %s completed', sNrrdImagesName));

    catch
        progressBar(1, 'Error:writeDICOMtoNrrdCallback()');
    end

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow;    
end
