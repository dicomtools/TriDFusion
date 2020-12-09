function importCerrDoseConstraintCallback(~, ~)
%function importCerrDoseConstraintCallback()
%Import CERR Scan and Dose to TriDFusion.
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


     filter = {'*.mat'};

     sCurrentDir = pwd;
     if integrateToBrowser('get') == true
         sCurrentDir = [sCurrentDir '/TriDFusion'];
     end

     sMatFile = [sCurrentDir '/' 'importCERRLastUsedDir.mat'];
     % load last data directory
     if exist(sMatFile, 'file')
                                % lastDirMat mat file exists, load it
        load('-mat', sMatFile);
        if exist('importCERRLastUsedDir', 'var')
            sCurrentDir = importCERRLastUsedDir;
        end
        if sCurrentDir == 0
            sCurrentDir = pwd;
        end
     end

     [file, path] = uigetfile(sprintf('%s%s', char(sCurrentDir), char(filter)), 'Import CERR Dose');
     if file ~= 0

        try
            importCERRLastUsedDir = path;
            save(sMatFile, 'importCERRLastUsedDir');
        catch
            progressBar(1 , sprintf('Warning: Cant save file %s', sMatFile));
            h = msgbox(sprintf('Warning: Cant save file %s', sMatFile), 'Warning');
%                if integrateToBrowser('get') == true
%                    sLogo = './TriDFusion/logo.png';
%                else
%                    sLogo = './logo.png';
%                end

%                javaFrame = get(h, 'JavaFrame');
%                javaFrame.setFigureIcon(javax.swing.ImageIcon(sLogo));
        end
        
        loadCerrDoseConstraint(path, file);
        
     end
 
end
