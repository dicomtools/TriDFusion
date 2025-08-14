function logWorkflowProgress(tLogField, sLogProgressFile, bStatus, sMesage)    
%function logWorkflowProgress(tMatching, sLogProgressFile, bStatus, sMesage)
%Logs the processing progress of a batch operation.
%  DESCRIPTION:
%  This function logs the processing status of individual study entries 
%  during the batch processing of TriDFusion. It writes a timestamped log 
%  entry to a specified log file, including the patient's details and the 
%  processing status (Processed, Skipped, or Error).
%
%  PARAMETERS:
%  - tLogField (struct): A structure containing details of the studies, 
%    including patient name, patient ID, accession number, study 
%    instance UID, and the series instance UIDs for the PET (PT) and CT 
%    scans.
%  - 'sLogProgressFile' (string): The path to the log file where progress 
%    will be recorded.
%  - 'bStatus' (integer): The status of the processing. It can take one of
%    the following values:
%      - 1: Success
%      - 2: Error
%      - Any other value: UNKNOWN
%  - 'sMesage' (string) : Message to log.
%
%  FUNCTIONALITY:
%  - Verifies that the 'tMatching' structure contains all required fields 
%    (PatientName, PatientID, Accession, StudyInstanceUID, SeriesInstanceUID1,
%    SeriesInstanceUID2).
%  - Tries to open the log file for appending. If the file cannot be opened, 
%    it retries up to a defined timeout period.
%  - If the file is successfully opened, a log entry with a timestamp, status, 
%    and patient study information is written to the file in CSV format.
%
%  RETURN VALUE:
%  This function does not return any value. It appends progress information to 
%  the specified log file.
%
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

    if isempty(sLogProgressFile)
        return;
    end

    if ~isstruct(tLogField)
        return;
    end

    % Define the required fields
    requiredFields = { 'PatientName', 'PatientID', 'Accession', ...
                       'StudyInstanceUID', 'SeriesInstanceUID1', 'SeriesInstanceUID2' };
                   
    % Check that tLogField contains all required fields
    for tt = 1:length(requiredFields)
        if ~isfield(tLogField, requiredFields{tt})
            return;
        end
    end

    % Retry parameters
    maxRetryTime = 5;    % Maximum total retry time in seconds
    retryDelay   = 0.1;  % Delay between retries in seconds
    startTime    = tic;
    fid          = -1;
    
    % Attempt to open the file until successful or until the timeout is reached
    while fid == -1 && toc(startTime) < maxRetryTime
        fid = fopen(sLogProgressFile, 'a');
        if fid == -1
            pause(retryDelay);
        end
    end

    if fid ~= -1
    
        % Create a timestamp for the log entry
        sTimestamp = string(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss'));

        if bStatus == 1
            sStatus = 'SUCCESS';
        elseif bStatus == 2
            sStatus = 'ERROR';
        else
            sStatus = 'UNKNOWN';  % Optional: handle unexpected values
        end

    
        % Construct the log line in CSV format. Fields are enclosed in quotes
        % to handle any commas within the data.
        logLine = sprintf('%s, %s, %s, %s, %s, %s, %s, %s, %s\n', ...
            sTimestamp, ...
            sStatus, ...
            tLogField.PatientName, ...
            tLogField.PatientID, ...
            tLogField.Accession, ...
            tLogField.StudyInstanceUID, ...
            tLogField.SeriesInstanceUID1, ...
            tLogField.SeriesInstanceUID2, ...
            sMesage);

        % Write the log line to the file
        fprintf(fid, '%s', logLine);

        % Close the file after writing
        fclose(fid);
    end
end