function exportBrownFatContoursToXls(sXlsFileName)
%function exportBrownFatContoursToXls(sXlsFileName)
%Export Brown Fat Contours statistics  to excel.
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

    try
        dSeriesOffset = get(uiSeriesPtr('get'), 'Value');
        atMetaData = dicomMetaData('get', [], dSeriesOffset);

        % Compute sites uptake
        tReport = computeReportLesionInformation(true, false, false, false);

        % Set patient information
        if isfield(atMetaData{1}, 'PatientName')
            if isstruct(atMetaData{1}.PatientName)
                if isfield(atMetaData{1}.PatientName, 'GivenName')
                    sGivenName = atMetaData{1}.PatientName.GivenName;
                else
                    sGivenName = ' ';
                end
                if isfield(atMetaData{1}.PatientName, 'MiddleName')
                    sMiddleName = atMetaData{1}.PatientName.MiddleName;
                else
                    sMiddleName = ' ';
                end
                if isfield(atMetaData{1}.PatientName, 'FamilyName')
                    sFamilyName = atMetaData{1}.PatientName.FamilyName;
                else
                    sFamilyName = ' ';
                end
                sPatientName = sprintf('%s %s %s', sGivenName, sMiddleName, sFamilyName);
                sPatientName = strrep(sPatientName, '^', ' ');
                sPatientName = strtrim(sPatientName);
            else
                sPatientName = atMetaData{1}.PatientName;
                sPatientName = strrep(sPatientName, '^', ' ');
                sPatientName = strtrim(sPatientName);
            end
        else
            sPatientName = ' ';
        end
        % ID, weight, size, sex, age
        if isfield(atMetaData{1}, 'PatientID')
            sPatientID = strtrim(atMetaData{1}.PatientID);
        else
            sPatientID = ' ';
        end
        if isfield(atMetaData{1}, 'PatientWeight')
            sPatientWeight = strtrim(num2str(atMetaData{1}.PatientWeight));
        else
            sPatientWeight = ' ';
        end
        if isfield(atMetaData{1}, 'PatientSize')
            sPatientSize = strtrim(num2str(atMetaData{1}.PatientSize));
        else
            sPatientSize = ' ';
        end
        if isfield(atMetaData{1}, 'PatientSex')
            sPatientSex = strtrim(atMetaData{1}.PatientSex);
        else
            sPatientSex = ' ';
        end
        if isfield(atMetaData{1}, 'PatientAge')
            sPatientAge = strtrim(atMetaData{1}.PatientAge);
        else
            sPatientAge = ' ';
        end
        % Series description, date/time, accession
        if isfield(atMetaData{1}, 'SeriesDescription')
            sSeriesDescription = strtrim(strrep(strrep(atMetaData{1}.SeriesDescription,'_',' '),'^',' '));
        else
            sSeriesDescription = ' ';
        end
        if isfield(atMetaData{1}, 'SeriesDate')
            if isempty(atMetaData{1}.SeriesDate)
                sSeriesDate = ' ';
            else
                dateStr = atMetaData{1}.SeriesDate;
                timeStr = atMetaData{1}.SeriesTime;
                if isempty(timeStr), timeStr = '000000'; end
                dateTime = [dateStr timeStr];
                if contains(dateTime, '.')
                    dateTime = extractBefore(dateTime, '.');
                end
                try
                    sSeriesDate = datetime(dateTime, 'InputFormat', 'yyyyMMddHHmmss');
                catch
                    sSeriesDate = '';
                end
            end
        else
            sSeriesDate = ' ';
        end
        if isfield(atMetaData{1}, 'AccessionNumber')
            sAccession = strtrim(atMetaData{1}.AccessionNumber);
        else
            sAccession = ' ';
        end

        sNumberOfSlices = num2str(size(dicomBuffer('get', [], dSeriesOffset), 3));

        % Column names and initial cells
        asColumnNames = {'Patient Name','Patient ID','Patient Age','Patient Sex','Patient Weight','Patient Size', ...
                         'Series Date','Accession Number','Number Of Slices','Series Description', ...
                         'Cervical Nb VOIs','Cervical Mean','Cervical Max','Cervical Peak','Cervical Volume', ...
                         'Supraclavicular Nb VOIs','Supraclavicular Mean','Supraclavicular Max','Supraclavicular Peak','Supraclavicular Volume', ...
                         'Mediastinal Nb VOIs','Mediastinal Mean','Mediastinal Max','Mediastinal Peak','Mediastinal Volume', ...
                         'Paraspinal Nb VOIs','Paraspinal Mean','Paraspinal Max','Paraspinal Peak','Paraspinal Volume', ...
                         'Axillary Nb VOIs','Axillary Mean','Axillary Max','Axillary Peak','Axillary Volume', ...
                         'Abdominal Nb VOIs','Abdominal Mean','Abdominal Max','Abdominal Peak','Abdominal Volume', ...
                         'Global Nb VOIs','Global Mean','Global Max','Global Peak','Global Volume'};
        acCell = {sPatientName, sPatientID, sPatientAge, sPatientSex, sPatientWeight, sPatientSize, ...
                  sSeriesDate, sAccession, sNumberOfSlices, sSeriesDescription};

        regions = {'Cervical','Supraclavicular','Mediastinal','Paraspinal','Axillary','Abdominal','All'};
        fields  = {'Count','Mean','Max','Peak','Volume'};
        for i = 1:numel(regions)
            region = regions{i};
            if isfield(tReport, region)
                for j = 1:numel(fields)
                    val = tReport.(region).(fields{j});
                    if ~isempty(val)
                        acCell{end+1} = val;
                    else
                        acCell{end+1} = NaN;
                    end
                end
            else
                acCell = [acCell, repmat({NaN}, 1, numel(fields))];
            end
        end

        acTable = cell2table(acCell, 'VariableNames', asColumnNames);

        % -- File locking and write logic --
        lockFile = [sXlsFileName '.lock'];
        while exist(lockFile, 'file')
            pause(0.2);
        end
        fidLock = fopen(lockFile, 'w');
        if fidLock == -1
            error('Could not create lock file %s', lockFile);
        end
        fclose(fidLock);

        % Retry loop with corruption handling
        dMaxWaitTime   = 60;
        dRetryInterval = 1;
        dStartTime     = tic;
        bWritten = false;
        try
            while ~bWritten
                try
                    writetable(acTable, sXlsFileName, 'WriteMode','Append', 'WriteVariableNames',false);
                    bWritten = true;
                catch ME
                    id = ME.identifier;
                    if any(strcmp(id, {'MATLAB:table:write:FileOpen','MATLAB:xlswrite:AddSheetError','MATLAB:xlwrite:WorkbookOpen'}))
                        if toc(dStartTime) > dMaxWaitTime
                            logErrorToFile(ME);
                            error('Timed out waiting for %s to be released.', sXlsFileName);
                        end
                        pause(dRetryInterval);
                    elseif any(strcmp(id, {'MATLAB:xlsread:ExcelCorruptFile','MATLAB:table:read:FileCorrupted','MATLAB:table:write:CorruptOrEncrypted'}))
                        ts      = datestr(now,'yyyymmdd_HHMMSS');
                        backup = sprintf('%s_corrupt_%s.bak', sXlsFileName, ts);
                        movefile(sXlsFileName, backup);
                        writetable(acTable, sXlsFileName, 'WriteMode','Overwrite', 'WriteVariableNames',true);
                        bWritten = true;
                    else
                        rethrow(ME);
                    end
                end
            end
        catch ME_outer
            logErrorToFile(ME_outer);
            rethrow(ME_outer);
        end

        % Release lock
        if exist(lockFile, 'file')
            delete(lockFile);
        end

    catch ME
        logErrorToFile(ME);
    end

end