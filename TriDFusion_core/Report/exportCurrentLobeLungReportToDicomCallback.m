function exportCurrentLobeLungReportToDicomCallback(~, ~)
%function exportCurrentLobeLungReportToDicomCallback()
%Export 3D Lobe Lung Report to a DICOM print.
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

    try

    fig3DLobeLungReport = fig3DLobeLungReportPtr('get');

    sWriteDir = outputDir('get');
    if isempty(sWriteDir)
        
        sCurrentDir  = viewerRootPath('get');

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

        sDate = sprintf('%s', datetime('now','Format','MMMM-d-y-hhmmss'));                
        sWriteDir = char(sOutDir) + "TriDFusion_DCM_" + char(sDate) + '/';              
        if ~(exist(char(sWriteDir), 'dir'))
            mkdir(char(sWriteDir));
        end
        
        try
            exportDicomLastUsedDir = sOutDir;
            save(sMatFile, 'exportDicomLastUsedDir');
        catch ME
            logErrorToFile(ME);
            progressBar(1 , sprintf('Warning: Cant save file %s', sMatFile));
        end   

    end   

    set(fig3DLobeLungReport, 'Pointer', 'watch');
    drawnow;

    objectToDicomJpg(sWriteDir, fig3DLobeLungReport, '3DF Lung Lobe Ratio', get(uiSeriesPtr('get'), 'Value'))

    catch ME
        logErrorToFile(ME);
        progressBar( 1 , 'Error: exportCurrentLobeLungReportToDicomCallback() cant export report' );
    end

    set(fig3DLobeLungReport, 'Pointer', 'default');
    drawnow;        
end