function [tKernel, sMatFile] = xlsxToMat(sFileName)
%function [tKernel, sMatFile] = xlsxToMat(sFileName)
%Convert .xlsx Kernel to .mat Format. 
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

    tKernel = [];
    sMatFile = '';

    if ~exist(sFileName, 'file')
        return;
    end

    try
        [~,aSheets,~] = xlsfinfo(sFileName);

        for ii=1:numel(aSheets)
            sHeteroName = cleanString(aSheets{ii});
          %  tDoseKernel = struct(sHeteroName,{});

            [~,~,aRaw] = xlsread(sFileName, ii);
            aNbIsotope = size(aRaw);
            dNbIsotopes = aNbIsotope(2)/2;

            dIsotopeOffset = 1;
            dFieldOffset = 1;
            for jj=1: dNbIsotopes

                sIsotopeName = cleanString(aRaw{1,dIsotopeOffset});
                dIsotopeOffset = dIsotopeOffset+2;

                sFieldName1 = cleanString(aRaw{2,dFieldOffset});
                aFieldData1 = aRaw(3:end,dFieldOffset);
                aFieldData1 = cell2mat(aFieldData1);
                aFieldData1(find(isnan(aFieldData1)))=[];  % Remove NAN
                dFieldOffset = dFieldOffset+1;

                sFieldName2 = cleanString(aRaw{2,dFieldOffset});
                aFieldData2 = aRaw(3:end,dFieldOffset);
                aFieldData2 = cell2mat(aFieldData2);
                aFieldData2(find(isnan(aFieldData2)))=[]; % Remove NAN
                dFieldOffset = dFieldOffset+1;

                tKernel.(sHeteroName).(sIsotopeName) = struct(sFieldName1, aFieldData1, sFieldName2, aFieldData2);              

            end

        end

        [~,sKernelName,~] = fileparts(sFileName);

        sRootPath   = viewerRootPath('get');
        sKernelPath = sprintf('%s/kernel', sRootPath);
         
        sMatFile = sprintf('%s%s.mat', sKernelPath, sKernelName);

        if exist(sMatFile, 'file')                                       
            delete(sMatFile);
        end

        save(sMatFile, 'tKernel');
    catch
        tKernel = [];
        sMatFile = '';        
    end



end        
