function sUnit = getSerieUnitValue(dOffset)
%function sUnit = getSerieUnitValue(dOffset)
%Get DICOM image unit type.
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

    if isempty(dOffset)
        sUnit = '';
        return;
    end
    
    tInput = inputTemplate('get');                

    switch lower(tInput(dOffset).atDicomInfo{1}.Modality)
        case {'pt', 'nm'}

            if strcmpi(tInput(dOffset).atDicomInfo{1}.Units, 'BQML') && ...
               tInput(dOffset).bDoseKernel == false && ...    
               isfield(tInput(dOffset).tQuant, 'tSUV') 
           
                sUnit = 'SUV';
            elseif strcmpi(tInput(dOffset).atDicomInfo{1}.Units, 'BQML') && ...
               tInput(dOffset).bDoseKernel == true && ...                   
               isfield(tInput(dOffset).tQuant, 'tSUV')   
                sUnit = 'Dose';
            else
                if isfield(tInput(dOffset).atDicomInfo{1}, 'RealWorldValueMappingSequence') % SUV SPECT
                    if isfield(tInput(dOffset).atDicomInfo{1}.RealWorldValueMappingSequence.Item_1, 'MeasurementUnitsCodeSequence')
                        if strcmpi(tInput(dOffset).atDicomInfo{1}.RealWorldValueMappingSequence.Item_1.MeasurementUnitsCodeSequence.Item_1.CodeValue, 'Bq/ml')
                            sUnit = 'SUV';
                        elseif strcmpi(tInput(dOffset).atDicomInfo{1}.RealWorldValueMappingSequence.Item_1.MeasurementUnitsCodeSequence.Item_1.CodeValue, 'Bq/ml') && ...
                            tInput(dOffset).bDoseKernel == true && ...                   
                            isfield(tInput(dOffset).tQuant, 'tSUV')   
                             sUnit = 'Dose';                            
                        else
                            if isempty(tInput(dOffset).atDicomInfo{1}.RealWorldValueMappingSequence.Item_1.MeasurementUnitsCodeSequence.Item_1.CodeValue)
                                sUnit = 'Counts';                            
                            else
                                sUnit = tInput(dOffset).atDicomInfo{1}.RealWorldValueMappingSequence.Item_1.MeasurementUnitsCodeSequence.Item_1.CodeValue;           
                            end                             
                        end
                        
                    else
                        if isempty(tInput(dOffset).atDicomInfo{1}.Units)
                            sUnit = 'Counts';                            
                        else
                            sUnit = tInput(dOffset).atDicomInfo{1}.Units;           
                        end                        
                    end
                else
                    if isempty(tInput(dOffset).atDicomInfo{1}.Units)
                        sUnit = 'Counts';                            
                    else
                        sUnit = tInput(dOffset).atDicomInfo{1}.Units;           
                    end
                end
            end

        case {'ct'}
                sUnit = 'HU';   

        otherwise
            if isempty(tInput(dOffset).atDicomInfo{1}.Units)
                sUnit = 'Counts';                            
            else                    
                sUnit = tInput(dOffset).atDicomInfo{1}.Units;
            end
    end
end