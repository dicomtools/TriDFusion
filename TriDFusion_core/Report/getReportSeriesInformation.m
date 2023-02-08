function sReport = getReportSeriesInformation()
%function getReportSeriesInformation()
%Generate series information report.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2023, Daniel Lafontaine, on behalf of the TriDFusion development team.
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
    
    atMetaData = dicomMetaData('get', [], get(uiSeriesPtr('get'), 'Value'));
            
    if isempty(atMetaData{1}.SeriesDescription)
        sSeriesDescription = '-';
    else
        sSeriesDescription = atMetaData{1}.SeriesDescription;
    end
    
    % Series Date Time
    
    sSeriesTime = atMetaData{1}.SeriesTime;
    sSeriesDate = atMetaData{1}.SeriesDate;
    
    if isempty(sSeriesTime)
        sSeriesDateTime = '-';
    else
        if numel(sSeriesTime) == 6
            sSeriesTime = sprintf('%s.00', sSeriesTime);
        end

        sSeriesDateTime = datetime([sSeriesDate sSeriesTime],'InputFormat','yyyyMMddHHmmss.SS');
    end
    
    % Acquisition Date Time
    
    sAcquisitionTime = atMetaData{1}.AcquisitionTime;
    
    if isempty(sAcquisitionTime)
        sAcquisitionDateTime = '-';
    else
        if numel(atMetaData) > 1                
            dayAcquisitionDate = inf;
            for jj=1:numel(atMetaData)

                acquisitionTime = atMetaData{jj}.AcquisitionTime;
                acquisitionDate = atMetaData{jj}.AcquisitionDate;

                if numel(acquisitionTime) == 6
                    acquisitionTime = sprintf('%s.00', acquisitionTime);
                end            

                datetimeAcquisitionDate = datetime([acquisitionDate acquisitionTime],'InputFormat','yyyyMMddHHmmss.SS');
                dayCurAcquisitionDate = datenum(datetimeAcquisitionDate);
                if dayCurAcquisitionDate < dayAcquisitionDate % Find min time
                    dayAcquisitionDate = dayCurAcquisitionDate;
                    sAcquisitionDateTime = datetime([acquisitionDate acquisitionTime],'InputFormat','yyyyMMddHHmmss.SS');
                end                    
            end

        else
            acquisitionTime = atMetaData{1}.AcquisitionTime;
            acquisitionDate = atMetaData{1}.AcquisitionDate;

            if numel(acquisitionTime) == 6
                acquisitionTime = sprintf('%s.00', acquisitionTime);
            end            

            sAcquisitionDateTime = datetime([acquisitionDate acquisitionTime],'InputFormat','yyyyMMddHHmmss.SS');
            dayAcquisitionDate = datenum(sAcquisitionDateTime);                
        end
    end        
        
    sReport = sprintf('Series description:\n%s'         , char(sSeriesDescription));      
    sReport = sprintf('%s\n\nSeries date time:\n%s'     , sReport, char(sSeriesDateTime));
    sReport = sprintf('%s\n\nAcquisition date Time:\n%s', sReport, char(sAcquisitionDateTime));        
         
    if isfield(atMetaData{1}, 'RadiopharmaceuticalInformationSequence') 

        if ( ~isempty(atMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideTotalDose) && ...
             ~isempty(atMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartDateTime) ) || ...
           ( ~isempty(atMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideTotalDose) && ...
             ~isempty(atMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartTime) )      
         
             % Radiopharmaceutical Date Time

            if isempty(atMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartDateTime) 
                sInjDateTime = sprintf('%s%s', atMetaData{1}.StudyDate, atMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartTime);
            else
                sInjDateTime = atMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartDateTime;      
            end
            
            if isempty(sInjDateTime)
                sInjDateTime = '-';
            else
                if numel(sInjDateTime) == 14
                    sInjDateTime = sprintf('%s.00', sInjDateTime);
                end

                sInjDateTime = datetime(sInjDateTime,'InputFormat','yyyyMMddHHmmss.SS');
            end
            
            % Radionuclide Total Dose
            
            if isempty(atMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideTotalDose)
                sInjDose = '-';
                sInjDoseMCi = '-';
            else
                sInjDose = str2double(atMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideTotalDose);
                sInjDoseMCi = sInjDose / 3.7E7;
                
                sInjDose = num2str(sInjDose/1000000); % Convert to MBq
                
                sInjDoseMCi = num2str(sInjDoseMCi);
            end
            
            % Radiopharmaceutical 
            
            if isempty(atMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.Radiopharmaceutical)
                sRadiopharmaceutical = '-';
            else
                sRadiopharmaceutical = atMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.Radiopharmaceutical;
                sRadiopharmaceutical = strrep(sRadiopharmaceutical,'^',' ');
                sRadiopharmaceutical = strtrim(sRadiopharmaceutical);
            end   
            
            % Radiopharmaceutical 
            
            if isempty(atMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideCodeSequence.Item_1.CodeMeaning)
                sRadionuclide = '-';
            else
                sRadionuclide = atMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideCodeSequence.Item_1.CodeMeaning;
                sRadionuclide = strrep(sRadionuclide,'^',' ');
                sRadionuclide = strtrim(sRadionuclide);
            end   
            
            % Radionuclide Half Life
            
            if isempty(atMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideHalfLife)
                sHalfLife = '-';
            else
                sHalfLife = atMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideHalfLife;
            end                
             
            
            % Decay Correction
            
            sUnitDisplay = getSerieUnitValue(get(uiSeriesPtr('get'), 'Value'));
            if strcmpi(sUnitDisplay, 'SUV')
        
                if isempty(atMetaData{1}.DecayCorrection)
                    sDecayCorrection = '-';
                    sDecayTime = '';
                else
                    switch lower(atMetaData{1}.DecayCorrection)

                        case 'start'

                        daySeriesDate = datenum(sSeriesDateTime);
                        dateInjDate   = datenum(sInjDateTime);

                        if daySeriesDate > dayAcquisitionDate
                            daySeriesDate = dayAcquisitionDate;
                        end
                        
                        relT = seconds((daySeriesDate - dateInjDate)*(24*60*60)); 
               %         relT = seconds((dayAcquisitionDate - dateInjDate)*(24*60*60)); 
                        relT.Format = 'dd:hh:mm:ss';
                        sDecayTime = char(relT);

                        sDecayCorrection = 'Scan start time';

                        case 'admin'

                        dateInjDate = datenum(sInjDateTime);

                        relT = seconds((dateInjDate - dateInjDate)*(24*60*60)); 
                        relT.Format = 'dd:hh:mm:ss';
                        sDecayTime = char(relT);

                        sDecayCorrection = 'Administration time';

                        case 'none'

                     %   dayAcquisitionDate = datenum(sAcquisitionDateTime);
                        dateInjDate        = datenum(sInjDateTime);

                        relT = seconds((dayAcquisitionDate - dateInjDate)*(24*60*60)); 
                        relT.Format = 'dd:hh:mm:ss';
                        sDecayTime = char(relT);

                        sDecayCorrection = 'No decay correction';

                        otherwise
                            sDecayCorrection = '-';
                            sDecayTime = '';
                    end                    
                end                   
            
                tQuantification = quantificationTemplate('get');
                sTotal = num2str(tQuantification.tSUV.dTot/10000000); % In MBq
                sDmCi  = num2str(tQuantification.tSUV.dmCi);
                
                sReport = sprintf('%s\n\nInjection date time:\n%s'       , sReport, char(sInjDateTime));
                sReport = sprintf('%s\n\nRadiopharmaceutical:\n%s'       , sReport, char(sRadiopharmaceutical));
                sReport = sprintf('%s\n\nRadionuclide:\n%s'              , sReport, char(sRadionuclide));
                sReport = sprintf('%s\n\nHalf life:\n%s sec'             , sReport, char(sHalfLife));
                sReport = sprintf('%s\n\nSUV additional decay-correction:\n%s -- %s', sReport, char(sDecayCorrection), char(sDecayTime));
                sReport = sprintf('%s\n\nAdministrated activity:\n%s MBq -- %s mCi'   , sReport, char(sInjDose), char(sInjDoseMCi));
                sReport = sprintf('%s\n\nTotal calculated activity:\n%s MBq -- %s mCi', sReport, char(sTotal), char(sDmCi));
            
            else
                sReport = sprintf('%s\n\nInjection date time:\n%s'       , sReport, char(sInjDateTime));
                sReport = sprintf('%s\n\nRadiopharmaceutical:\n%s'       , sReport, char(sRadiopharmaceutical));
                sReport = sprintf('%s\n\nRadionuclide:\n%s'              , sReport, char(sRadionuclide));
                sReport = sprintf('%s\n\nHalf life:\n%s sec'             , sReport, char(sHalfLife));
                sReport = sprintf('%s\n\nAdministrated activity:\n%s MBq -- %s mCi'   , sReport, char(sInjDose), char(sInjDoseMCi));
            end
                                           
        end
    end                  
end    
