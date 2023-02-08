function sReport = getReportPatientInformation()
%function getReportPatientInformation()
%Generate patient information report.
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
    
    % Patient Name
   
    if isempty(atMetaData{1}.PatientName)
        sPatientName = '-';
    else
        sPatientName = atMetaData{1}.PatientName;
        sPatientName = strrep(sPatientName,'^',' ');
        sPatientName = strtrim(sPatientName);            
    end
    
    % Patient ID

    if isempty(atMetaData{1}.PatientID)
        sPatientID = '-';
    else
        sPatientID = atMetaData{1}.PatientID;
        sPatientID = strtrim(sPatientID);
    end
    
    % Patient Sex
    
    if isempty(atMetaData{1}.PatientSex)
        sPatientSex = '-';
    else
        sPatientSex = atMetaData{1}.PatientSex;
        if strcmpi(sPatientSex, 'M')
            sPatientSex = 'Male';
        elseif strcmpi(sPatientSex, 'F')
             sPatientSex = 'Female';
       elseif strcmpi(sPatientSex, 'O')
              sPatientSex = 'Other';
       end
            
    end       
    
    % Patient Age
   
    if isempty(atMetaData{1}.PatientAge)
        sPatientAge = '-';
    else
        sPatientAge = atMetaData{1}.PatientAge;
    end
    
    % Patient Birth Date
    
    if isempty(atMetaData{1}.PatientBirthDate)
        sPatientBirthDate = '-';
    else
        if numel(atMetaData{1}.PatientBirthDate) == 8
            sPatientBirthDate = char(datetime(atMetaData{1}.PatientBirthDate,'InputFormat','yyyyMMdd'));
        else
            sPatientBirthDate = atMetaData{1}.PatientBirthDate;
        end
    end
    
    sReport = sprintf(' Patient name:\n %s'     , char(sPatientName));      
    sReport = sprintf('%s\n\n Patient ID:\n %s' , sReport, char(sPatientID));
    sReport = sprintf('%s\n\n Gender:\n %s'     , sReport, char(sPatientSex));
    sReport = sprintf('%s\n\n Age:\n %s'        , sReport, char(sPatientAge));
    sReport = sprintf('%s\n\n Birth date:\n %s' , sReport, char(sPatientBirthDate));
    
    % Patient Birth Weight
    
    if isempty(atMetaData{1}.PatientWeight)
        sReport = sprintf('%s\n\n Weight:\n -', sReport);
    else
        sPatientWeight = atMetaData{1}.PatientWeight; % In float 
        sPatientWeightLbs = num2str(sPatientWeight * 2.20462262185);
        
        sPatientWeight = num2str(sPatientWeight); % In string
        
        sReport = sprintf('%s\n\n Weight:\n %s Kg -- %s lbs', sReport, char(sPatientWeight), sPatientWeightLbs);
    end
    
    % Patient Birth Size
   
    if isempty(atMetaData{1}.PatientSize)
        sReport = sprintf('%s\n\n Height:\n -' , sReport);
    else
        sPatientSize = atMetaData{1}.PatientSize; % In float 
        sPatientSizeFeet =  num2str(atMetaData{1}.PatientSize * 3.28084);
        
        sPatientSize = num2str(sPatientSize); % In string
        
        sReport = sprintf('%s\n\n Height:\n %s m -- %s foot' , sReport, char(sPatientSize), char(sPatientSizeFeet));
    end       
      
end