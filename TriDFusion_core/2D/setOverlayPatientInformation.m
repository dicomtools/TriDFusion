function setOverlayPatientInformation(dSeriesOffset)  
%function setOverlayPatientInformation(dSeriesOffset)  
%set overlay patient information.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Note: option settings must fit on one line and can contain one semicolon at most.
%Options can be strings, cell arrays of strings, or numerical arrays.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2024, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    atMetaData = dicomMetaData('get', [], dSeriesOffset);
                
    if isfield(atMetaData{1}, 'PatientName')
        sPatientName = atMetaData{1}.PatientName;
        sPatientName = strrep(sPatientName,'^',' ');
        sPatientName = strtrim(sPatientName);
    else
        sPatientName = '';
    end
    
    if isfield(atMetaData{1}, 'PatientID')
        sPatientID = atMetaData{1}.PatientID;
        sPatientID = strtrim(sPatientID);
    else
        sPatientID = '';
    end
    
    if isfield(atMetaData{1}, 'SeriesDescription')
        sSeriesDescription = atMetaData{1}.SeriesDescription;
        sSeriesDescription = strrep(sSeriesDescription,'_',' ');
        sSeriesDescription = strrep(sSeriesDescription,'^',' ');
        sSeriesDescription = strtrim(sSeriesDescription);
    else
        sSeriesDescription = '';
    end
    
    if isfield(atMetaData{1}, 'RadiopharmaceuticalInformationSequence')
        sRadiopharmaceutical = atMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.Radiopharmaceutical;
    else
        sRadiopharmaceutical = '';
    end
    
    if isfield(atMetaData{1}, 'SeriesDate')
    
        if isempty(atMetaData{1}.SeriesDate)
            sSeriesDate = '';
        else
            sSeriesDate = atMetaData{1}.SeriesDate;
            if isempty(atMetaData{1}.SeriesTime)
                sSeriesTime = '000000';
            else
                sSeriesTime = atMetaData{1}.SeriesTime;
            end
            sSeriesDate = sprintf('%s%s', sSeriesDate, sSeriesTime);
        end
    
        if ~isempty(sSeriesDate)
            if contains(sSeriesDate,'.')
                sSeriesDate = extractBefore(sSeriesDate,'.');
            end
            sSeriesDate = datetime(sSeriesDate,'InputFormat','yyyyMMddHHmmss');
        end
    else
        sSeriesDate = '';
    end

    overlayPatientInformation('set', sPatientName, ...
                                     sPatientID, ...
                                     sSeriesDescription, ...
                                     sRadiopharmaceutical, ...
                                     sSeriesDate);
                                        
end