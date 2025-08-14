function [tMaterial, sMatFile] = xlsxToMaterialMat(sFileName)
%function [tMaterial, sMatFile] = xlsxToMaterialMat(sFileName)
%Convert .xlsx Material to .mat Format. 
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

    tMaterial = [];
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

                sTissueName = cleanString(aRaw{jj,1});

                % Density
                
                tMaterial.(sTissueName).density = aRaw{jj,2};              

                % Composition

                tMaterial.(sTissueName).composition = aRaw{jj,3};              
            end
        end

        [~,sMaterialName,~] = fileparts(sFileName);

        sRootPath   = viewerRootPath('get');
        sKernelPath = sprintf('%s/kernel', sRootPath);
         
        sMatFile = sprintf('%s/%s.mat', sKernelPath, sMaterialName);

        if exist(sMatFile, 'file')                                       
            delete(sMatFile);
        end

        save(sMatFile, 'tMaterial');
        
    catch ME   
        logErrorToFile(ME);

        tMaterial = [];
        sMatFile = '';        
    end



end        
