function sUnit = getSerieUnitValue(dSeriesOffset)
%function sUnit = getSerieUnitValue(dSeriesOffset)
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

    if isempty(dSeriesOffset)
        sUnit = '';
        return;
    end
    
    tInput = inputTemplate('get');                

    switch lower(tInput(dSeriesOffset).atDicomInfo{1}.Modality)
        
        case {'pt', 'nm'}

            if strcmpi(tInput(dSeriesOffset).atDicomInfo{1}.Units, 'BQML') && ...
               tInput(dSeriesOffset).bDoseKernel == false && ...    
               isfield(tInput(dSeriesOffset).tQuant, 'tSUV') 

%                 if computeSUV(tInput(dSeriesOffset).atDicomInfo, viewerSUVtype('get')) ~= 0
           
                    sUnit = 'SUV';
%                 else
%                     sUnit = 'BQML';
%                 end

            elseif tInput(dSeriesOffset).bDoseKernel == true
               
                if isfield(tInput(dSeriesOffset).atDicomInfo{1}, 'DoseUnits')
    
                    if ~isempty(tInput(dSeriesOffset).atDicomInfo{1}.DoseUnits)
                        
                        sUnit = char(tInput(dSeriesOffset).atDicomInfo{1}.DoseUnits);
                    else
                        sUnit = 'dose';
                    end
                else
                    sUnit = 'dose';
                end   

            else
                if isfield(tInput(dSeriesOffset).atDicomInfo{1}, 'RealWorldValueMappingSequence') % SUV SPECT
                    if isfield(tInput(dSeriesOffset).atDicomInfo{1}.RealWorldValueMappingSequence.Item_1, 'MeasurementUnitsCodeSequence')
                        if strcmpi(tInput(dSeriesOffset).atDicomInfo{1}.RealWorldValueMappingSequence.Item_1.MeasurementUnitsCodeSequence.Item_1.CodeValue, 'Bq/ml')
                            
%                             if computeSUV(dicomMetaData('get', [], dSeriesOffset), viewerSUVtype('get')) ~= 0
                            if isfield(tInput(dSeriesOffset).tQuant, 'tSUV') 

                                sUnit = 'SUV';
                            else
                                sUnit = 'BQML';
                            end

                        elseif strcmpi(tInput(dSeriesOffset).atDicomInfo{1}.RealWorldValueMappingSequence.Item_1.MeasurementUnitsCodeSequence.Item_1.CodeValue, 'Bq/ml') && ...
                            tInput(dSeriesOffset).bDoseKernel == true && ...                   
                            isfield(tInput(dSeriesOffset).tQuant, 'tSUV')   
                             sUnit = 'Dose';                            
                        else
                            if isempty(tInput(dSeriesOffset).atDicomInfo{1}.RealWorldValueMappingSequence.Item_1.MeasurementUnitsCodeSequence.Item_1.CodeValue)
                                sUnit = 'Counts';                            
                            else
                                sUnit = tInput(dSeriesOffset).atDicomInfo{1}.RealWorldValueMappingSequence.Item_1.MeasurementUnitsCodeSequence.Item_1.CodeValue;           
                            end                             
                        end
                        
                    else
                        if isempty(tInput(dSeriesOffset).atDicomInfo{1}.Units)
                            sUnit = 'Counts';                            
                        else
                            sUnit = tInput(dSeriesOffset).atDicomInfo{1}.Units;           
                        end                        
                    end
                else
                    if isempty(tInput(dSeriesOffset).atDicomInfo{1}.Units)
                        sUnit = 'Counts';                            
                    else
                        sUnit = tInput(dSeriesOffset).atDicomInfo{1}.Units;           
                    end
                end
            end

        case {'ct'}
                sUnit = 'HU';   

        otherwise
            if isfield(tInput(dSeriesOffset).atDicomInfo{1}, 'Units')

                if isempty(tInput(dSeriesOffset).atDicomInfo{1}.Units)
                    sUnit = 'Counts';                            
                else                    
                    sUnit = tInput(dSeriesOffset).atDicomInfo{1}.Units;
                end
            else
                sUnit = 'Counts';                            
            end
    end
end