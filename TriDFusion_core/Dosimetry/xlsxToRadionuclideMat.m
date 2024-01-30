function [tRadionuclide, sMatFile] = xlsxToRadionuclideMat(sFileName)
%function [tRadionuclide, sMatFile] = xlsxToRadionuclideMat(sFileName)
%Convert .xlsx Radionuclide to .mat Format. 
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

    tRadionuclide = [];
    sMatFile = '';

    if ~exist(sFileName, 'file')
        return;
    end

    try
        [~,aSheets,~] = xlsfinfo(sFileName);

        for ii=1:numel(aSheets)

            [~,~,aRaw] = xlsread(sFileName, ii);
            dNbRow = size(aRaw, 1);

            for jj=1: dNbRow

                sRadionuclideName = cleanString(aRaw{jj,1});
                sRadionuclideName = regexprep(sRadionuclideName, '-', '');

                % HalfLife
                
                tRadionuclide.(sRadionuclideName).halfLife = cleanString(aRaw{jj,2});              

                % Emission

                tRadionuclide.(sRadionuclideName).emission.alpha                 = false;
                tRadionuclide.(sRadionuclideName).emission.beta                  = false;
                tRadionuclide.(sRadionuclideName).emission.gamma                 = false;
                tRadionuclide.(sRadionuclideName).emission.monoenergeticElectron = false;
                tRadionuclide.(sRadionuclideName).emission.positron              = false;
                tRadionuclide.(sRadionuclideName).emission.xRay                  = false;

                for kk=3:7
                    switch lower((aRaw{jj,kk}))
    
                        case 'alpha'
                            tRadionuclide.(sRadionuclideName).emission.alpha = true;

                        case 'beta'
                            tRadionuclide.(sRadionuclideName).emission.beta = true;

                        case 'gamma'
                            tRadionuclide.(sRadionuclideName).emission.gamma = true;

                        case 'monoenergetic_electron'
                            tRadionuclide.(sRadionuclideName).emission.monoenergeticElectron = true;

                        case 'positron'
                            tRadionuclide.(sRadionuclideName).emission.positron = true;

                        case 'xray'
                            tRadionuclide.(sRadionuclideName).emission.xRay = true;
                    end

                end
            end
        end

        [~,sRadionuclideName,~] = fileparts(sFileName);

        sRootPath   = viewerRootPath('get');
        sKernelPath = sprintf('%s/kernel', sRootPath);
         
        sMatFile = sprintf('%s/%s.mat', sKernelPath, sRadionuclideName);

        if exist(sMatFile, 'file')                                       
            delete(sMatFile);
        end

        save(sMatFile, 'tRadionuclide');
    catch
        tRadionuclide = [];
        sMatFile = '';        
    end



end        
