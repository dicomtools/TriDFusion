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

    iOffset = get(uiSeriesPtr('get'), 'Value');
    if iOffset > numel(inputTemplate('get'))
        return;
    end

     sCurrentDir = pwd;
     if integrateToBrowser('get') == true
         sCurrentDir = [sCurrentDir '/TriDFusion'];
     end

     sMatFile = [sCurrentDir '/' 'lastWriteDicomDir.mat'];
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

    try
        exportDicomLastUsedDir = sOutDir;
        save(sMatFile, 'exportDicomLastUsedDir');
    catch
        progressBar(1 , sprintf('Warning: Cant save file %s', sMatFile));
        h = msgbox(sprintf('Warning: Cant save file %s', sMatFile), 'Warning');
%        if integrateToBrowser('get') == true
%            sLogo = './TriDFusion/logo.png';
%        else
%            sLogo = './logo.png';
%        end

%        javaFrame = get(h, 'JavaFrame');
%        javaFrame.setFigureIcon(javax.swing.ImageIcon(sLogo));
    end

    writeDICOM(sOutDir, iOffset);

end