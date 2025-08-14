function logErrorToFile(ME)
%function logErrorToFile(ME)
%This function captures error details from a catch block and logs them to a file, including the error message, identifier, stack trace, possible causes, and memory usage for debugging purposes.
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

    if enableErrorLogging('get') == true
        
        % Get the root path for log storage
    
        sRootPath = viewerRootPath('get');
    
        % Define log file path
    
        logFilePath = sprintf('%s/3df_error_log.txt', sRootPath);
        
        % Open the log file in append mode
        
         % Retry parameters
        maxRetryTime = 5;    % Maximum total retry time in seconds
        retryDelay   = 0.1;  % Delay between retries in seconds
        startTime    = tic;
        fid          = -1;
        
        % Attempt to open the file until successful or until the timeout is reached
        while fid == -1 && toc(startTime) < maxRetryTime
            
            fid = fopen(logFilePath, 'a'); 

            if fid == -1
                pause(retryDelay);
            end
        end

        if fid ~= -1  % Ensure the file opened successfully
            try
                % Write timestamp
                fprintf(fid, 'Error occurred at %s\n', datetime('now','Format','MMMM-d-y-hhmmss'));
                fprintf(fid, 'Message: %s\n', ME.message);
                fprintf(fid, 'Identifier: %s\n', ME.identifier);
    
                % Log detailed report from getReport(ME)
                msgText = getReport(ME, 'extended', 'hyperlinks', 'off');
                fprintf(fid, 'Full Report:\n%s\n', msgText);
    
                % Loop through stack trace for detailed debugging info
                fprintf(fid, 'Stack Trace:\n');
                for k = 1:length(ME.stack)
                    fprintf(fid, '  In %s (line %d)\n', ME.stack(k).file, ME.stack(k).line);
                end
    
                % Log cause and potential resolution hints
                if ~isempty(ME.cause)
                    fprintf(fid, 'Possible Cause: %s\n', strjoin(ME.cause, ', '));
                end
    
                % Log memory usage (converted to MB)
                memInfo = memory;
                fprintf(fid, 'Memory Usage (MB):\n');
                fprintf(fid, '  MaxPossibleArrayBytes: %.2f MB\n', memInfo.MaxPossibleArrayBytes / 1e6);
                fprintf(fid, '  MemAvailableAllArrays: %.2f MB\n', memInfo.MemAvailableAllArrays / 1e6);
                fprintf(fid, '  MemUsedMATLAB: %.2f MB\n', memInfo.MemUsedMATLAB / 1e6);
    
                fprintf(fid, '----------------------------\n'); % Separator for readability
                
            catch logError
                fprintf('Logging failed: %s\n', logError.message);
            end
            fclose(fid); % Close the file safely
        else
            warning('Failed to open log file: %s', logFilePath);
        end
    end
end
