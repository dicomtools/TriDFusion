function importNpCallback(~, ~)
%function importNpCallback()
%Import .np file type to TriDFusion.
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

     if switchTo3DMode('get')     == true ||  ...
        switchToIsoSurface('get') == true || ...
        switchToMIPMode('get')    == true

         return;
     end     
        

     sCurrentDir  = viewerRootPath('get');

     sMatFile = [sCurrentDir '/' 'importNpLastUsedDir.mat'];
     % load last data directory
     if exist(sMatFile, 'file')
                                % lastDirMat mat file exists, load it
        load('-mat', sMatFile);
        if exist('importNpLastUsedDir', 'var')
            sCurrentDir = importNpLastUsedDir;
        end
        if sCurrentDir == 0
            sCurrentDir = pwd;
        end
     end
     
    filter = {'*.np;*.npz', 'NP and NPZ Files (*.np,*.npz)'; '*.*', 'All Files (*.*)'};
    [sNpFileName, sNpPath] = uigetfile(filter, 'Import .np file', sCurrentDir);

     if sNpFileName ~= 0

        try
            importNpLastUsedDir = sNpPath;
            save(sMatFile, 'importNpLastUsedDir');
        catch ME
            logErrorToFile(ME);
            progressBar(1 , sprintf('Warning: Cant save file %s', sMatFile));
        end      
    
        % Extract the base file name (removing the extension)
        [~, sBaseFileName, ~] = fileparts(sNpFileName);
        
        sPklFileName = sprintf('%s.pkl', sBaseFileName);

        % Construct the full path to the .pkl file
        sPklFilePath = fullfile(sNpPath, sPklFileName);

        if exist(sPklFilePath, 'file')
            sPklPath = sNpPath;
        else

            sMatFile = [sCurrentDir '/' 'importPklLastUsedDir.mat'];
            % load last data directory
            if exist(sMatFile, 'file')
                                        % lastDirMat mat file exists, load it
                load('-mat', sMatFile);
                if exist('importPklLastUsedDir', 'var')
                    sCurrentDir = importPklLastUsedDir;
                end
                if sCurrentDir == 0
                    sCurrentDir = pwd;
                end
            end     

            filter = {'*.pkl', 'Pkl File (*.pkl)'; '*.*', 'All Files (*.*)'};
            [sPklFileName, sPklPath] = uigetfile(filter, 'Import .pkl file', sCurrentDir);
        
            if sPklFileName ~= 0
        
                try
                    importPklLastUsedDir = sPklPath;
                    save(sMatFile, 'importPklLastUsedDir');
                catch ME
                    logErrorToFile(ME);
                    progressBar(1 , sprintf('Warning: Cant save file %s', sMatFile));
                end 
            else
                 sPklPath = [];
                 sPklFileName = [];
            end
        end

        if isVsplash('get') == true

            setVsplashCallback();
        end

        if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 3) ~= 1

            link2DMip('set', true);

            set(btnLinkMipPtr('get'), 'BackgroundColor', viewerButtonPushedBackgroundColor('get'));
            set(btnLinkMipPtr('get'), 'ForegroundColor', viewerButtonPushedForegroundColor('get')); 
            % set(btnLinkMipPtr('get'), 'FontWeight', 'bold');            
            set(btnLinkMipPtr('get'), 'CData', resizeTopBarIcon('link_mip_white.png'));
        end

        loadNpFile(sNpPath, sNpFileName, sPklPath, sPklFileName, true, []);    
     end
end
