function importCerrDoseConstraintCallback(~, ~)
%function importCerrDoseConstraintCallback()
%Import CERR Scan and Dose Constraint to TriDFusion.
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

     sCurrentDir  = viewerRootPath('get');

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

     [sFileName, sPathName] = uigetfile(sprintf('%s%s', char(sCurrentDir), char(filter)), 'Import CERR Dose');
     if sFileName ~= 0

        try
            importCERRLastUsedDir = sPathName;
            save(sMatFile, 'importCERRLastUsedDir');
        catch ME   
            logErrorToFile(ME);
            progressBar(1 , sprintf('Warning: Cant save file %s', sMatFile));
%            h = msgbox(sprintf('Warning: Cant save file %s', sMatFile), 'Warning');
%                if integrateToBrowser('get') == true
%                    sLogo = './TriDFusion/logo.png';
%                else
%                    sLogo = './logo.png';
%                end

%                javaFrame = get(h, 'JavaFrame');
%                javaFrame.setFigureIcon(javax.swing.ImageIcon(sLogo));
        end
        
        mainDir('set', sPathName);
        
        progressBar(0.1, 'Loading CERR PlanC');

        cerrFileName = sprintf('%s%s', sPathName, sFileName);

        %sPathName = 'C:\Temp\DoseConstraintDisplay\';
        %sFileName = '0617-693410_09-09-2000-32821.mat';

        try
            planC = loadPlanC(cerrFileName, viewerTempDirectory('get'));
            planC = updatePlanFields(planC);
            planC = quality_assure_planC(cerrFileName,planC);
            
        catch ME   
            logErrorToFile(ME);
            progressBar(1, 'Error: importCerrDoseConstraintCallback() Cant Load CERR PlanC!');
            return;
        end
        
        structNamC = {'Lung_IPSI','Lung_CNTR','PTV'};

        loadCerrDoseConstraint(planC, structNamC);

     end

end
