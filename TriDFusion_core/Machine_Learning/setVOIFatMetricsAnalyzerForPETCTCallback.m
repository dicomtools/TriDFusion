function setVOIFatMetricsAnalyzerForPETCTCallback(hObject, ~)
%function setVOIFatMetricsAnalyzerForPETCTCallback()
%Run AI VOI-Fat Metrics Analyzer for PET-CT, The tool is called from the main menu.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2024, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    [sSegmentatorScript, ~] = validateSegmentatorInstallation();
    
    if ~isempty(sSegmentatorScript) % External Segmentor is installed

        if exist('hObject', 'var')
     
            sCurrentDir  = viewerRootPath('get');
    
            % Define the path to the mat file
            sMatFile = fullfile(sCurrentDir, 'exportCsvLastUsedDir.mat');
            
            % Load last data directory if the mat file exists
            if exist(sMatFile, 'file')
                % Load the mat file if it exists
                load('-mat', sMatFile);
                
                % Check if 'exportCsvLastUsedDir' exists in the loaded file
                if exist('exportCsvLastUsedDir', 'var')
                    sCurrentDir = exportCsvLastUsedDir;
                end
                
                % Ensure sCurrentDir is not invalid (0 is not a valid directory)
                if isequal(sCurrentDir, 0) || ~ischar(sCurrentDir)
                    sCurrentDir = pwd;  % Set it to the current directory if invalid
                end
            end
    
            sCsvDir = uigetdir(sCurrentDir);
            if sCsvDir == 0
                return;
            end
            sCsvDir = [sCsvDir '/'];
    
            try
                exportDicomLastUsedDir = sCsvDir;
                save(sMatFile, 'exportDicomLastUsedDir');
            catch ME
                logErrorToFile(ME);
                progressBar(1 , sprintf('Warning: Cant save file %s', sMatFile));
            end
        else
            sPathToCheck = 'G:\';
            if exist('G:\', 'dir')
                sCsvDir = sPathToCheck;
            else
                sCsvDir = 'c:\Temp\';
            end
        end
    
        setVOIFatMetricsAnalyzerForPETCT(sSegmentatorScript, sCsvDir);  

    end

end