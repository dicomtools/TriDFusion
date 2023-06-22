function atEnergyWindow = getEnergyWindowsName(atMetaData)
%function  asEnergyWindow = getEnergyWindowsName(atMetaData)
%Extract dicom header enrgy windows name.
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

    atEnergyWindow = [];

    if isfield(atMetaData{1}, 'EnergyWindowInformationSequence')

        dNbFields = numel(fieldnames(atMetaData{1}.EnergyWindowInformationSequence));
    
        if dNbFields > 0
    
            atEnergyWindow = cell(dNbFields, 1);
        
            for jj=1:dNbFields
        
                sItem = sprintf('Item_%d', jj);
                sEnergyWindowName = atMetaData{1}.EnergyWindowInformationSequence.(sItem).EnergyWindowName;
        
                dEnergyWindowLowerLimit = atMetaData{1}.EnergyWindowInformationSequence.(sItem).EnergyWindowRangeSequence.Item_1.EnergyWindowLowerLimit;
                dEnergyWindowUpperLimit = atMetaData{1}.EnergyWindowInformationSequence.(sItem).EnergyWindowRangeSequence.Item_1.EnergyWindowUpperLimit;
        
                atEnergyWindow{jj}.sEnergyWindowTag = sprintf('%s (%f,%f)', sEnergyWindowName, dEnergyWindowLowerLimit, dEnergyWindowUpperLimit);
                atEnergyWindow{jj}.sEnergyWindowName = sEnergyWindowName;
                atEnergyWindow{jj}.dLowerLimit = dEnergyWindowLowerLimit;
                atEnergyWindow{jj}.dUpperLimit = dEnergyWindowUpperLimit;
            end
        end
    end
end