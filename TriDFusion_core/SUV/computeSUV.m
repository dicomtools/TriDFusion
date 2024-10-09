function dSUVconv = computeSUV(atMetaData, suvType)
%function dSUVconv = computeSUV(atMetaData, suvType)
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
% 2023-03-31 : Brad Beattie : added suvType == 'FDG'
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

    if isfield(atMetaData{1}, 'RadiopharmaceuticalInformationSequence') 

        if ( ~isempty(atMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideTotalDose) && ...
             ~isempty(atMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartDateTime) ) || ...
           ( ~isempty(atMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideTotalDose) && ...
             ~isempty(atMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartTime) )      
           
            if isempty(atMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartDateTime) 
                injDateTime = sprintf('%s%s', atMetaData{1}.StudyDate, atMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartTime);
            else
                injDateTime = atMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartDateTime;      
            end
            
            injDose    = str2double(atMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideTotalDose);
            

            % Acquisition Date Time
            
            if numel(atMetaData) > 1                
                dayAcquisitionDate = inf;
                for jj=1:numel(atMetaData)
                    
                    acquisitionTime = atMetaData{jj}.AcquisitionTime;
                    acquisitionDate = atMetaData{jj}.AcquisitionDate;

                    if numel(acquisitionTime) == 6
                        acquisitionTime = sprintf('%s.00', acquisitionTime);
                    end            

%                     datetimeAcquisitionDate = datetime([acquisitionDate acquisitionTime],'InputFormat','yyyyMMddHHmmss.SS');
%                     dayCurAcquisitionDate = datenum(datetimeAcquisitionDate);
                    try
                        fullAcquisitionDate = [acquisitionDate acquisitionTime(1:6)];  % Ignoring milliseconds for speed
                        dayCurAcquisitionDate = datenum(fullAcquisitionDate, 'yyyymmddHHMMSS');
                    catch
                        datetimeAcquisitionDate = datetime([acquisitionDate acquisitionTime],'InputFormat','yyyyMMddHHmmss.SS');
                        dayCurAcquisitionDate = datenum(datetimeAcquisitionDate);                        
                    end

                    if dayCurAcquisitionDate < dayAcquisitionDate % Find min time
                        dayAcquisitionDate = dayCurAcquisitionDate;
                    end                    
                end
            
            else
                acquisitionTime = atMetaData{1}.AcquisitionTime;
                acquisitionDate = atMetaData{1}.AcquisitionDate;
                
                if numel(acquisitionTime) == 6
                    acquisitionTime = sprintf('%s.00', acquisitionTime);
                end            

                datetimeAcquisitionDate = datetime([acquisitionDate acquisitionTime],'InputFormat','yyyyMMddHHmmss.SS');
                dayAcquisitionDate = datenum(datetimeAcquisitionDate);                
            end
            
            patWeight = atMetaData{1}.PatientWeight;
            if patWeight == 0 || isnan(patWeight)
                patWeight =1;
            end
            halfLife = str2double(atMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideHalfLife);

            % Radiopharmaceutical Date Time
            
            if numel(injDateTime) == 14
                injDateTime = sprintf('%s.00', injDateTime);
            end
            
            try
                datetimeInjDate = datetime(injDateTime,'InputFormat','yyyyMMddHHmmss.SS');
                dateInjDate = datenum(datetimeInjDate);
            catch
                dateInjDate = [];
            end
            
            % Series Date Time
            
            seriesTime = atMetaData{1}.SeriesTime;
            seriesDate = atMetaData{1}.SeriesDate;
            
            if numel(seriesTime) == 6
                seriesTime = sprintf('%s.00', seriesTime);
            end

            datetimeSeriesDate = datetime([seriesDate seriesTime],'InputFormat','yyyyMMddHHmmss.SS');
            daySeriesDate = datenum(datetimeSeriesDate);

            % Acquisition Date Time
            
%            if numel(acquisitionTime) == 6
%                acquisitionTime = sprintf('%s.00', acquisitionTime);
%            end            

%            datetimeAcquisitionDate = datetime([acquisitionDate acquisitionTime],'InputFormat','yyyyMMddHHmmss.SS');
%            dayAcquisitionDate = datenum(datetimeAcquisitionDate);
            
            % Decay correction
            
            sDecayCorrection = atMetaData{1}.DecayCorrection;


            if strcmpi(sDecayCorrection, 'START')

                if daySeriesDate > dayAcquisitionDate
                    daySeriesDate = dayAcquisitionDate;
                end
                relT = (daySeriesDate - dateInjDate)*(24*60*60); % Acquisition start time
    %            relT = (dayAcquisitionDate - dateInjDate)*(24*60*60); % Acquisition start time min values
           
            elseif strcmpi(sDecayCorrection, 'ADMIN')
%                 relT = (dateInjDate - dateInjDate)*(24*60*60); % Radiopharmaceutical administration time
                  relT = (dayAcquisitionDate - dateInjDate)*(24*60*60); % Radiopharmaceutical administration time
                
            elseif strcmpi(sDecayCorrection, 'NONE')
                 %   relT = 0; % No decay
               %relT = (daySeriesDate - dateInjDate)*(24*60*60); % Acquisition start time
%                relT = (dayAcquisitionDate - dateInjDate)*(24*60*60); % No decay correction
                relT = 0;
           
            else
                relT = inf;
            end
            
            % SUV type
           
            if relT ~= inf
            
                corrInj = injDose / 2^(relT / halfLife); %in Bq and seconds (exp(log(2) * relT / halfLife)
                
                if strcmpi(suvType, 'BW') % Body Weight
                    dSUVconv = patWeight/corrInj; % pt weight in grams

                elseif strcmpi(suvType, 'FDG') % Brads FDG specific SUV

                    patHeight = atMetaData{1}.PatientSize;
                    if patHeight == 0 || isnan(patHeight)
                        dSUVconv =0;
                    else
						x = patHeight / 100; y = patWeight;
                        BHN = 100*exp(2.03*x^3-9.07*x^2+13.94*x+0.00539*y-2.04);
                        dSUVconv = BHN/corrInj;
                    end

                elseif strcmpi(suvType, 'BSA') % body surface area
                    % Patient height
                    % (BSA in m2) = [(weight in kg)^0.425 \* (height in cm)^0.725 \* 0.007184].
                    % SUV-bsa = (PET image Pixels) \* (BSA in m2) \* (10000 cm2/m2) / (injected dose).
                    patHeight = atMetaData{1}.PatientSize;
                    if patHeight == 0 || isnan(patHeight)
                        dSUVconv =0;
                    else

                        bsaMm = patWeight^0.425 * (patHeight*100)^0.725 * 0.007184;
                        dSUVconv = bsaMm/corrInj;
                    end
                        
                elseif strcmpi(suvType, 'LBM') % lean body mass 
                    patGender = atMetaData{1}.PatientSex;
                    patHeight = atMetaData{1}.PatientSize;
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
                        
                    patHeight = atMetaData{1}.PatientSize;
                    if patHeight == 0 || isnan(patHeight)
                        dSUVconv =0;
                    else
                        bmi = (patHeight*2.20462 / (patHeight*39.3701)^2) * 703;
                        patGender = atMetaData{1}.PatientSex;
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

                if isfield(atMetaData{1}, 'RealWorldValueMappingSequence')
                    if isfield(atMetaData{1}.RealWorldValueMappingSequence.Item_1, 'MeasurementUnitsCodeSequence')
                        sUnits = atMetaData{1}.RealWorldValueMappingSequence.Item_1.MeasurementUnitsCodeSequence.Item_1.CodeValue;
                        if strcmpi(sUnits, 'Bq/ml')
                            sUnits = 'BQML';
                        else
                            sUnits = atMetaData{1}.Units;
                        end
                    else
                        sUnits = atMetaData{1}.Units;
                    end
                else
                    sUnits = atMetaData{1}.Units;
                end
                
                % Transformation to Bq/L

                if strcmpi(sUnits, 'CNTS')

                    if isfield(atMetaData{1}, 'petActivityConcentrationScaleFactor')

                        activityScaleFactor = atMetaData{1}.petActivityConcentrationScaleFactor;

                        if activityScaleFactor ~=0
                            dSUVconv = dSUVconv *activityScaleFactor* 1000; 
                        end
                    end

                elseif strcmpi(sUnits, 'BQML') || strcmpi(sUnits, 'BQCC')
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