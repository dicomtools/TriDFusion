function writeDICOMCallback(~, ~)
%function writeDICOMCallback(~, ~)
%Export To DICOM Current Serie.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2020, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    atInputTemplate = inputTemplate('get');

    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');
    if dSeriesOffset > numel(atInputTemplate)
        return;
    end

    sWriteDir = outputDir('get');
    if isempty(sWriteDir)

        sCurrentDir  = viewerRootPath('get');

        sMatFile = [sCurrentDir '/' 'exportDicomLastUsedDir.mat'];
        % load last data directory
        if exist(sMatFile, 'file')
                                    % lastDirMat mat file exists, load it
           load('-mat', sMatFile);
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

        sDate = sprintf('%s', datetime('now','Format','MMMM-d-y-hhmmss'));
        sWriteDir = char(sOutDir) + "TriDFusion_DCM_" + char(sDate) + '/';
        if ~(exist(char(sWriteDir), 'dir'))
            mkdir(char(sWriteDir));
        end

        try
            exportDicomLastUsedDir = sOutDir;
            save(sMatFile, 'exportDicomLastUsedDir');
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

    atMetaData = dicomMetaData('get', [], dSeriesOffset);
    if isempty(atMetaData)
        atMetaData = atInputTemplate(dSeriesOffset).atDicomInfo;
    end

    % Set series label

    sSeriesDescription = getViewerSeriesDescriptionDialog(sprintf('%s', atMetaData{1}.SeriesDescription));
    if isempty(sSeriesDescription)
        return;
    end

    for sd=1:numel(atMetaData)
        atMetaData{sd}.SeriesDescription = sSeriesDescription;
    end

    % Set series buffer

    aBuffer = dicomBuffer('get', [], dSeriesOffset);
    if isempty(aBuffer)

        aInput  = inputBuffer('get');
        aBuffer = aInput{dSeriesOffset};

%        if strcmp(imageOrientation('get'), 'coronal')
%            aBuffer = permute(aBuffer, [3 2 1]);
%        elseif strcmp(imageOrientation('get'), 'sagittal')
%            aBuffer = permute(aBuffer, [2 3 1]);
%        else
%            aBuffer = permute(aBuffer, [1 2 3]);
%        end

%        if atInputTemplate(dSeriesOffset).bFlipLeftRight == true
%            aBuffer=aBuffer(:,end:-1:1,:);
%        end

%        if atInputTemplate(dSeriesOffset).bFlipAntPost == true
%            aBuffer=aBuffer(end:-1:1,:,:);
%        end

%        if atInputTemplate(dSeriesOffset).bFlipHeadFeet == true
%            aBuffer=aBuffer(:,:,end:-1:1);
%        end
    end

    % Write DICOM

    bInputIsDicom = false;

    try
        if exist(char(atInputTemplate(dSeriesOffset).asFilesList{1}), 'file') % Input series is dicom
            if isdicom(char(atInputTemplate(dSeriesOffset).asFilesList{1}))
                bInputIsDicom = true;
            end
        end
    catch
    end

    if bInputIsDicom == true % Input series is dicom
        writeDICOM(aBuffer, atMetaData, sWriteDir, dSeriesOffset, true);
    else % Input series is another format
        writeOtherFormatToDICOM(aBuffer, atMetaData, sWriteDir, true);
    end

end
