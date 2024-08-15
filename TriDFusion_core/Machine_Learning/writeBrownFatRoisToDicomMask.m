function writeBrownFatRoisToDicomMask(sNetwork)
%function writeBrownFatRoisToDicomMask(sNetwork)
%Export Brown Fat ROIs To DICOM mask.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2021, Daniel Lafontaine, on behalf of the TriDFusion development team.
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
% along with TriDFusion.cIf not, see <http://www.gnu.org/licenses/>.

    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');
    
    if isempty(voiTemplate('get', dSeriesOffset))
        return;
    end

    bSubDir = false;
    
    sOutDir = outputDir('get');
    if isempty(sOutDir)
        
        bSubDir = true;

        sCurrentDir  = viewerRootPath('get');

        sMatFile = [sCurrentDir '/' 'exportDicomMaskLastUsedDir.mat'];
        % load last data directory
        if exist(sMatFile, 'file')
                                    % lastDirMat mat file exists, load it
           load('-mat', sMatFile);
           if exist('exportDicomMaskLastUsedDir', 'var')
               sCurrentDir = exportDicomMaskLastUsedDir;
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
            exportDicomMaskLastUsedDir = sOutDir;
            save(sMatFile, 'exportDicomMaskLastUsedDir');
        catch
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
    end    
    
    tInput = inputTemplate('get');    
    aInputBuffer = inputBuffer('get');

    atMetaData = dicomMetaData('get', [], dSeriesOffset);

    if machineLearningFDGBrownFatSUVScaled('get') == true

        if machineLearningFDGBrownFatSUVNormalization('get') == true

            if machineLearningFDGBrownFatCELoss('get') == true

                sOvewriteSeriesDescription = sprintf('MASK-%s - CE Loss - NORM %s', atMetaData{1}.SeriesDescription, sNetwork);
            else
                sOvewriteSeriesDescription = sprintf('MASK-%s - NORM %s', atMetaData{1}.SeriesDescription, sNetwork);
            end
        else
            if machineLearningFDGBrownFatCELoss('get') == true

                sOvewriteSeriesDescription = sprintf('MASK-%s - CE Loss - SUV %s', atMetaData{1}.SeriesDescription, sNetwork);
            else
                sOvewriteSeriesDescription = sprintf('MASK-%s - SUV %s', atMetaData{1}.SeriesDescription, sNetwork);
            end
        end
    else
        if machineLearningFDGBrownFatCELoss('get') == true

             sOvewriteSeriesDescription = sprintf('MASK-%s - CE Loss - BQML %s', atMetaData{1}.SeriesDescription, sNetwork);
       else
            sOvewriteSeriesDescription = sprintf('MASK-%s - BQML %s', atMetaData{1}.SeriesDescription, sNetwork);
        end
    end

    if contains(sOvewriteSeriesDescription, 'RT-')
        sOvewriteSeriesDescription = strrep(sOvewriteSeriesDescription, 'RT-', '');
    end

    writeRoisToDicomMask(sOutDir, bSubDir, aInputBuffer{dSeriesOffset}, tInput(dSeriesOffset).atDicomInfo, dicomBuffer('get', [], dSeriesOffset), dicomMetaData('get', [], dSeriesOffset), dSeriesOffset, true, sOvewriteSeriesDescription);
end
