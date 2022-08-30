function dSUVconv = computeSUV(tMetaData, suvType)
%function dSUVconv = computeSUV(tMetaData)
%Compute SUV values.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Note: option settings must fit on one line and can contain one semicolon at most.
%Options can be strings, cell arrays of strings, or numerical arrays.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%        Brad Beattie, beattieb@MSKCC.ORG
%        C. Ross Schmidtlein, schmidtr@mskcc.org
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

    dSUVconv = 0;

    if isfield(tMetaData, 'RadiopharmaceuticalInformationSequence') 

        if ( ~isempty(tMetaData.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideTotalDose) && ...
             ~isempty(tMetaData.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartDateTime) ) || ...
           ( ~isempty(tMetaData.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideTotalDose) && ...
             ~isempty(tMetaData.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartTime) )      
           
            if isempty(tMetaData.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartDateTime) 
                injDateTime = sprintf('%s%s', tMetaData.StudyDate, tMetaData.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartTime);
            else
                injDateTime = tMetaData.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartDateTime;      
            end
            
            injDose    = str2double(tMetaData.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideTotalDose);
            
            seriesTime = tMetaData.SeriesTime;
            seriesDate = tMetaData.SeriesDate;
            
            acquisitionTime = tMetaData.AcquisitionTime;
            acquisitionDate = tMetaData.AcquisitionDate;
            
            patWeight = tMetaData.PatientWeight;
            if patWeight == 0 || isnan(patWeight)
                patWeight =1;
            end
            halfLife = str2double(tMetaData.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideHalfLife);

            % Radiopharmaceutical Date Time
            
            if numel(injDateTime) == 14
                injDateTime = sprintf('%s.00', injDateTime);
            end

            datetimeInjDate = datetime(injDateTime,'InputFormat','yyyyMMddHHmmss.SS');
            dateInjDate = datenum(datetimeInjDate);
            
            % Series Date Time

            if numel(seriesTime) == 6
                seriesTime = sprintf('%s.00', seriesTime);
            end

            datetimeSeriesDate = datetime([seriesDate seriesTime],'InputFormat','yyyyMMddHHmmss.SS');
            daySeriesDate = datenum(datetimeSeriesDate);

            % Acquisition Date Time
            
            if numel(acquisitionTime) == 6
                acquisitionTime = sprintf('%s.00', acquisitionTime);
            end            

            datetimeAcquisitionDate = datetime([acquisitionDate acquisitionTime],'InputFormat','yyyyMMddHHmmss.SS');
            dayAcquisitionDate = datenum(datetimeAcquisitionDate);
            
            % Decay correction
            
            sDecayCorrection = tMetaData.DecayCorrection;
            if strcmpi(sDecayCorrection, 'START')
                relT = (daySeriesDate - dateInjDate)*(24*60*60); % Acquisition start time
            
            elseif strcmpi(sDecayCorrection, 'ADMIN')
                relT = (dateInjDate - dateInjDate)*(24*60*60); % Radiopharmaceutical administration time
                    
            elseif strcmpi(sDecayCorrection, 'NONE')
                 %   relT = 0; % No decay
                relT = (dayAcquisitionDate - dateInjDate)*(24*60*60); % No decay correction
           
            else
                relT = inf;
            end
            
            % SUV type
           
            if relT ~= inf
            
                corrInj = injDose / 2^(relT / halfLife); %in Bq and seconds (exp(log(2) * relT / halfLife)
                
                if strcmpi(suvType, 'BW') % Body Weight
                    dSUVconv = patWeight/corrInj; % pt weight in grams

                elseif strcmpi(suvType, 'BSA') % body surface area
                    % Patient height
                    % (BSA in m2) = [(weight in kg)^0.425 \* (height in cm)^0.725 \* 0.007184].
                    % SUV-bsa = (PET image Pixels) \* (BSA in m2) \* (10000 cm2/m2) / (injected dose).
                    patHeight = tMetaData.PatientSize;
                    if patHeight == 0 || isnan(patHeight)
                        dSUVconv =0;
                    else

                        bsaMm = patWeight^0.425 * (patHeight*100)^0.725 * 0.007184;
                        dSUVconv = bsaMm/corrInj;
                    end
                        
                elseif strcmpi(suvType, 'LBM') % lean body mass 
                    patGender = tMetaData.PatientSex;
                    patHeight = tMetaData.PatientSize;
                    if patHeight == 0 || isnan(patHeight)
                        dSUVconv =0;

                    else
                        if strcmpi(patGender,'M')
                            %LBM in kg = 1.10 \* (weight in kg) – 120 \* [(weight in kg) / (height in cm)]^2.
                            lbmKg = 1.10 * patWeight - 120 * (patWeight/(patHeight*100))^2;
                            %1.10 * weight - 120 * (weight/height) ^2
                        else
                            %if d=gender == female
                            %LBM in kg = 1.07 \* (weight in kg) – 148 \* [(weight in kg) / (height in cm)]^2.
                            lbmKg = 1.07 * patWeight - 148 * (patWeight/(patHeight*100))^2;
                        end

                        dSUVconv = lbmKg/corrInj;                   
                    end
                        
                elseif strcmpi(suvType, 'LBMJANMA') % lean body mass by Janmahasatian method
                        
                    patHeight = tMetaData.PatientSize;
                    if patHeight == 0 || isnan(patHeight)
                        dSUVconv =0;
                    else
                        bmi = (patHeight*2.20462 / (patHeight*39.3701)^2) * 703;
                        patGender = tMetaData.PatientSex;
                        if strcmpi(patGender,'M')
                            lbmKg = (9270 * patWeight) / (6680 + 216*bmi); % male
                        else
                            lbmKg = (9270 * patWeight) / (8780 + 244*bmi); % female
                        end
                        dSUVconv = lbmKg/corrInj;
                    end
                        
                else
                    dSUVconv = 0;
                end             
                
                % SUV SPECT

                if isfield(tMetaData, 'RealWorldValueMappingSequence')
                    if isfield(tMetaData.RealWorldValueMappingSequence.Item_1, 'MeasurementUnitsCodeSequence')
                        sUnits = tMetaData.RealWorldValueMappingSequence.Item_1.MeasurementUnitsCodeSequence.Item_1.CodeValue;
                        if strcmpi(sUnits, 'Bq/ml')
                            sUnits = 'BQML';
                        else
                            sUnits = tMetaData.Units;
                        end
                    else
                        sUnits = tMetaData.Units;
                    end
                else
                    sUnits = tMetaData.Units;
                end
                
                % Transformation to Bq/L

                if strcmpi(sUnits, 'BQML') || strcmpi(sUnits, 'BQCC')
                    dSUVconv = dSUVconv * 1e3; 

                elseif strcmpi(sUnits, 'KBQCC') || strcmpi(sUnits, 'KBQML')
                    dSUVconv = dSUVconv * 1e6; 

                else
                    dSUVconv = 0;
                end    
            end   
        end
    end
end