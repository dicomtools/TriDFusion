function tDoseKernel = getDoseKernelTemplate()
%function tDoseKernel = getDoseKernelTemplate()
%Retun the Kernel Templates from the .mat files of Kernel folder.
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

    sRootPath   = viewerRootPath('get');
    sKernelPath = sprintf('%s/kernel/', sRootPath);

    dOffset = 1;
%     atListing = dir([sKernelPath '*.mat']);

    f = java.io.File(char(sKernelPath));
    atListing = f.listFiles();

    for kk=1:numel(atListing)
        if contains(char(atListing(kk)), '.mat')
            sVariable = cell2mat(who('-file', char(atListing(kk))));
            if strcmpi(sVariable, 'tKernel')                 
                tDoseKernel.ModelName{dOffset} = char(atListing(kk).getName());
                dOffset = dOffset+1;
            end
        end
    end

    if exist('tDoseKernel', 'var')
        for ll=1:numel(tDoseKernel.ModelName)
            load([sKernelPath tDoseKernel.ModelName{ll}], 'tKernel');
            tDoseKernel.Kernel{ll} = tKernel;
            tDoseKernel.Tissue{ll} = fieldnames(tKernel);
            for mm=1:numel(tDoseKernel.Tissue{ll})
                tDoseKernel.Isotope{ll}{mm}=fieldnames(tKernel.(tDoseKernel.Tissue{ll}{mm}));
            end

        end 
    else
        tDoseKernel = [];
    end            
end