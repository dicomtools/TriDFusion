function extractRadiomicsToXls(sFileName, bEntireVolume, bContourType, dContourOffset)
%function extractRadiomicsToXls(sFileName, bEntireVolume, bContourType, dContourOffset)
%Run PyRadiomics, extract features of all contours and export the result to a .xls file.
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

    if isempty(sFileName)
        return;
    end

    [~, ~, ext] = fileparts(sFileName);   
    if ~strcmpi(ext, '.xls')
        return;
    end

    try

    sRadiomicsScript = validateRadiomicsInstallation();
    
    if ~isempty(sRadiomicsScript) % External PyRadiomics is installed
        
        atMetaData = dicomMetaData('get', [],  get(uiSeriesPtr('get'), 'Value'));
        
        sUnit = getSerieUnitValue(get(uiSeriesPtr('get'), 'Value'));

        if (strcmpi(atMetaData{1}.Modality, 'pt') || ...
            strcmpi(atMetaData{1}.Modality, 'nm'))&& ...
            strcmpi(sUnit, 'SUV' )

            tQuantification = quantificationTemplate('get', [], get(uiSeriesPtr('get'), 'Value'));

            bSUVUnit  = true;
            dSUVScale = tQuantification.tSUV.dScale;
        else
            bSUVUnit  = false;
            dSUVScale = [];
        end

        sRootPath = viewerRootPath('get');

        if ~isempty(sRootPath)

            load(sprintf('%s/imdata/tRadiomicsData.mat', sRootPath), 'tRadiomics');
    
            extractRadiomicsFromContours(sRadiomicsScript, ...
                                         tRadiomics, ...
                                         bSUVUnit  , ...
                                         dSUVScale , ...
                                         bEntireVolume, ...
                                         bContourType  , ...
                                         dContourOffset, ...
                                         sFileName , ...
                                         false);
        end
        
    end

    catch ME
        logErrorToFile(ME);
    end

end