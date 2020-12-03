function dSUVconv = computeSUV(tSUVMetaData)
%function dSUVconv = computeSUV(tSUVMetaData)
%Compute SUV values.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Note: option settings must fit on one line and can contain one semicolon at most.
%Options can be strings, cell arrays of strings, or numerical arrays.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%        Brad Beattie, beattieb@MSKCC.ORG
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

    if isfield(tSUVMetaData, 'dose') 

        if isempty(tSUVMetaData.dose.RadionuclideTotalDose) || ...
           isempty(tSUVMetaData.dose.RadiopharmaceuticalStartDateTime) ...
            return; 
        end

        injDose     = str2double(tSUVMetaData.dose.RadionuclideTotalDose);
        injDateTime = tSUVMetaData.dose.RadiopharmaceuticalStartDateTime;      
        acqTime     = tSUVMetaData.SeriesTime;
        acqDate     = tSUVMetaData.SeriesDate;
        patWeight   = str2double(tSUVMetaData.PatientWeight);
        halfLife    = str2double(tSUVMetaData.dose.RadionuclideHalfLife);

        if numel(injDateTime) == 14
            injDateTime = sprintf('%s.00', injDateTime);
        end

        datetimeInjDate = datetime(injDateTime,'InputFormat','yyyyMMddHHmmss.SS');
        dateInjDate = datenum(datetimeInjDate);

        if numel(acqTime) == 6
            acqTime = sprintf('%s.00', acqTime);
        end

        datetimeAcqDate = datetime([acqDate acqTime],'InputFormat','yyyyMMddHHmmss.SS');
        dayAcqDate = datenum(datetimeAcqDate);

        relT = (dayAcqDate - dateInjDate)*(24*60*60); % Acquisition start time

        % calculate conversion factor

        if strcmpi(tSUVMetaData.Units,'bqml')
            corrInj = injDose / exp(log(2) * relT / halfLife); %in Bq and seconds
            dSUVconv = patWeight / corrInj; %assuming massDensity = 1kg/L
            dSUVconv = dSUVconv * 1e3; %because image values mL -> L
        else
         %   msgbox('ERROR: computeSUV(): Account for activity units!');
            return;
        end
    end

end