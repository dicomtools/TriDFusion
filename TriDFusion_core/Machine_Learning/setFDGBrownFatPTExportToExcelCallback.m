function setFDGBrownFatPTExportToExcelCallback(~, ~)
%function setFDGBrownFatPTExportToExcelCallback()
%Open FDG Brown Fat PET BQML Segmentation, and save PT result to excel.
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

    atInput = inputTemplate('get');

    dPTSerieOffset = [];
    for tt=1:numel(atInput)

        if strcmpi(atInput(tt).atDicomInfo{1}.Modality, 'pt')

            dPTSerieOffset = tt;
            break;
        end
    end

    if isempty(dPTSerieOffset)

        return;
    end 

    % Create Root directory

    % sRootDirectory = 'C:/Users/lafontad/Documents/My Data/Brown fat/BAT_STATISTICS';
    sRootDirectory = 'P:\Dali\Daniel\BAT_STATISTICS';

    % if exist('G:/Documents', 'dir')
    % 
    %     sRootDirectory = 'G:/Documents/BAT_STATISTICS';
    % else
    %     sUserFolder = getenv('USERPROFILE'); % Gets "C:\Users\Username"
    %     sOneDrivePath = fullfile(sUserFolder, 'OneDrive - Memorial Sloan Kettering Cancer Center', 'Documents');
    % 
    %     if exist(sOneDrivePath, 'dir')
    % 
    %         sRootDirectory = sprintf('%s/BAT_STATISTICS', sOneDrivePath);
    %     else
    %         sRootDirectory = 'C:/Temp/BAT_STATISTICS';
    %     end
    % end

    atVoiInput = voiTemplate('get', dPTSerieOffset);

    if ~isempty(atVoiInput)
    
    set(uiSeriesPtr('get'), 'Value', dPTSerieOffset);

    setSeriesCallback();
    
    % Export PT Statistics To Excel

    exportBrownFatContoursToXls(sprintf('%s/BAT_PT_STATISTICS_All_Patients.xls', sRootDirectory)); 

    end

    catch ME
        logErrorToFile(ME);
    end

    % Exit the compiled executable

    close(fiMainWindowPtr('get'));       
end