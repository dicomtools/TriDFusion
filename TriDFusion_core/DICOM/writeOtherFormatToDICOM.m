function writeOtherFormatToDICOM(aBuffer, atMetaData, sWriteDir, bRescale)            
%function writeOtherFormatToDICOM(aBuffer, atMetaData, sWriteDir, bRescale) 
%Write a DICOM Series.
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

    try
                
    set(fiMainWindowPtr('get'), 'Pointer', 'watch');
    drawnow;  
  
    % sTmpDir = sprintf('%stemp_dicom_%s//', ...
    %     viewerTempDirectory('get'), ...
    %     datetime('now','Format','MMMM-d-y-hhmmss-MS'));
    sTmpDir = sprintf('%s//', tempname(viewerTempDirectory('get')));
  
    % --- Remove old folder if it exists ---
    if exist(sTmpDir, 'dir')
        rmdir(sTmpDir, 's');
    
        % Wait until it's really gone
        maxRetries = 20;
        delaySec   = 0.25;
        for attempt = 1:maxRetries
            if ~exist(sTmpDir, 'dir')
                break;
            end
            pause(delaySec);
        end
    
        if exist(sTmpDir, 'dir')
            progressBar(1, sprintf('Error: Failed to remove directory %s', sTmpDir));
        end
    end
    
    % Create new folder
    mkdir(sTmpDir);
    
    % Wait until it's really created
    maxRetries = 20;
    delaySec   = 0.25;
    for attempt = 1:maxRetries
        if exist(sTmpDir, 'dir')
            break;
        end
        pause(delaySec);
    end
    
    if ~exist(sTmpDir, 'dir')
        progressBar(1, sprintf('Error: Failed to create directory %s', sTmpDir));
    end

    aBufferSize = size(aBuffer);

    if numel(aBufferSize) > 2
        array4d = zeros(aBufferSize(1), aBufferSize(2),1, aBufferSize(3));
        for slice = 1:aBufferSize(3)
            if bRescale == true
                if numel(atMetaData) ~= 1
                    if isfield(atMetaData{slice}, 'RescaleIntercept') && ...
                       isfield(atMetaData{slice}, 'RescaleSlope')     
                        if atMetaData{slice}.RescaleSlope ~= 0
                            aBuffer(:,:,slice) = (aBuffer(:,:,slice) - atMetaData{slice}.RescaleIntercept) / atMetaData{slice}.RescaleSlope;
                        else
                            if isfield(atMetaData{slice}, 'RealWorldValueMappingSequence') % SUV Spect
                                if atMetaData{slice}.RealWorldValueMappingSequence.Item_1.RealWorldValueSlope ~= 0
                                    fSlope = atMetaData{slice}.RealWorldValueMappingSequence.Item_1.RealWorldValueSlope;
                                    fIntercept = atMetaData{slice}.RealWorldValueMappingSequence.Item_1.RealWorldValueIntercept;
                                    aBuffer(:,:,slice) = (aBuffer(:,:,slice) - fIntercept) / fSlope;
                                end                        
                            end                           
                        end
                    end 

                    if strcmpi(atMetaData{1}.Modality, 'RTDOSE')
                        if atMetaData{1}.DoseGridScaling ~= 0
                            aBuffer(:,:,slice) = aBuffer(:,:,slice) / atMetaData{1}.DoseGridScaling;
                        end
                    end                     
                else
                    if isfield(atMetaData{1}, 'RescaleIntercept') && ...
                       isfield(atMetaData{1}, 'RescaleSlope')     
                        if atMetaData{1}.RescaleSlope ~= 0
                            aBuffer(:,:,slice) = (aBuffer(:,:,slice) - atMetaData{1}.RescaleIntercept) / atMetaData{1}.RescaleSlope;
                        else                        
                            if isfield(atMetaData{1}, 'RealWorldValueMappingSequence') % SUV Spect
                                if atMetaData{1}.RealWorldValueMappingSequence.Item_1.RealWorldValueSlope ~= 0
                                    fSlope =  atMetaData{1}.RealWorldValueMappingSequence.Item_1.RealWorldValueSlope;
                                    fIntercept = atMetaData{1}.RealWorldValueMappingSequence.Item_1.RealWorldValueIntercept;
                                    aBuffer(:,:,slice) = (aBuffer(:,:,slice) - fIntercept) / fSlope;
                                end                        
                            end                                                 
                        end
                    end  

                    if strcmpi(atMetaData{1}.Modality, 'RTDOSE')
                        if atMetaData{1}.DoseGridScaling ~= 0
                            aBuffer(:,:,slice) = aBuffer(:,:,slice) / atMetaData{1}.DoseGridScaling;
                        end
                    end                     
                end
            end
            
            array4d(:,:,1,slice) = aBuffer(:,:,slice);

        end            

        array4d = array4d(:,:,:,end:-1:1);   
      
    else
        if bRescale == true

            if isfield(atMetaData{1}, 'RescaleIntercept') && ...
               isfield(atMetaData{1}, 'RescaleSlope') 
                if atMetaData{1}.RescaleSlope ~= 0
                    aBuffer = (aBuffer - atMetaData{1}.RescaleIntercept) / atMetaData{1}.RescaleSlope;
                else
                    if isfield(atMetaData{1}, 'RealWorldValueMappingSequence') % SUV Spect
                        if atMetaData{1}.RealWorldValueMappingSequence.Item_1.RealWorldValueSlope ~= 0
                            fSlope = atMetaData{1}.RealWorldValueMappingSequence.Item_1.RealWorldValueSlope;
                            fIntercept = atMetaData{1}.RealWorldValueMappingSequence.Item_1.RealWorldValueIntercept;
                            aBuffer = (aBuffer - fIntercept) / fSlope;
                        end                        
                    end                
                end
            end   

            if strcmpi(atMetaData{1}.Modality, 'RTDOSE')
                if atMetaData{1}.DoseGridScaling ~= 0
                    aBuffer = aBuffer / atMetaData{1}.DoseGridScaling;
                end
            end          
        end

        array4d = aBuffer;

    end

    if numel(atMetaData) > 1
        dWriteEndLoop = aBufferSize(3);
    else
        dWriteEndLoop = 1;
    end

    dSeriesInstanceUID = dicomuid;
    dSOPInstanceUID = dicomuid;

    atWriteMetaData = cell(1, dWriteEndLoop);

    for ww=1:dWriteEndLoop

        if mod(ww,10)==1 || ww == dWriteEndLoop       
            progressBar(ww / dWriteEndLoop, ...
                sprintf('Processing header %d/%d, please wait', ww, dWriteEndLoop));
        end

        sWriteFile = sprintf('%s.%d', atMetaData{ww}.SeriesInstanceUID, ww);                                             
        sOutFile   = sprintf('%s%s' , sTmpDir, sWriteFile);

        atWriteMetaData{ww} = atMetaData{ww};
        atWriteMetaData{ww}.SourceApplicationEntityTitle = 'TRIDFUSION';
        
        % Series MediaStorageSOPClassUID             

        if isfield(atWriteMetaData{ww}, 'MediaStorageSOPClassUID')

            if isempty(atWriteMetaData{ww}.MediaStorageSOPClassUID)

                if isfield(atWriteMetaData{ww}, 'Modality')

                    switch lower(atWriteMetaData{ww}.Modality)
                        case 'ct'
                            atWriteMetaData{ww}.MediaStorageSOPClassUID = '1.2.840.10008.5.1.4.1.1.2'; % CT
                        case 'mr'
                            atWriteMetaData{ww}.MediaStorageSOPClassUID = '1.2.840.10008.5.1.4.1.1.4'; % MR
                        case 'pt'
                            atWriteMetaData{ww}.MediaStorageSOPClassUID = '1.2.840.10008.5.1.4.1.1.128'; % PT
                        case 'nm'
                            atWriteMetaData{ww}.MediaStorageSOPClassUID = '1.2.840.10008.5.1.4.1.1.20'; % NM
                        case 'rtdose'    
                            atWriteMetaData{ww}.MediaStorageSOPClassUID = '1.2.840.10008.5.1.4.1.1.481.2'; % RTDOSE
                        otherwise
                            atWriteMetaData{ww}.MediaStorageSOPClassUID = '1.2.840.10008.5.1.4.1.1.7'; % Secondary Capture
                          
                    end        
                else
                    atWriteMetaData{ww}.MediaStorageSOPClassUID = '1.2.840.10008.5.1.4.1.1.7'; % Secondary Capture
                end
            end
        else
            if isfield(atWriteMetaData{ww}, 'Modality')
                
                switch lower(atWriteMetaData{ww}.Modality)
                    case 'ct'
                        atWriteMetaData{ww}.MediaStorageSOPClassUID = '1.2.840.10008.5.1.4.1.1.2'; % CT
                    case 'mr'
                        atWriteMetaData{ww}.MediaStorageSOPClassUID = '1.2.840.10008.5.1.4.1.1.4'; % MR
                    case 'pt'
                        atWriteMetaData{ww}.MediaStorageSOPClassUID = '1.2.840.10008.5.1.4.1.1.128'; % PT
                    case 'nm'
                        atWriteMetaData{ww}.MediaStorageSOPClassUID = '1.2.840.10008.5.1.4.1.1.20'; % NM
                    case 'rtdose'
                        atWriteMetaData{ww}.MediaStorageSOPClassUID = '1.2.840.10008.5.1.4.1.1.481.2'; % RTDOSE
                    otherwise
                        atWriteMetaData{ww}.MediaStorageSOPClassUID = '1.2.840.10008.5.1.4.1.1.7'; % Secondary Capture
                      
                end        
            else
                atWriteMetaData{ww}.MediaStorageSOPClassUID = '1.2.840.10008.5.1.4.1.1.7'; % Secondary Capture
            end
        end

        % MediaStorageSOPInstanceUID

        if isfield(atWriteMetaData{ww}, 'MediaStorageSOPInstanceUID')

            if isempty(atWriteMetaData{ww}.MediaStorageSOPInstanceUID)

                atWriteMetaData{ww}.MediaStorageSOPInstanceUID = dSOPInstanceUID;
            end
        else
            atWriteMetaData{ww}.MediaStorageSOPInstanceUID = dSOPInstanceUID;
        end


%        atWriteMetaData{ww}.MediaStorageSOPClassUID    = '1.2.840.10008.5.1.4.1.1.7.3';
%        atWriteMetaData{ww}.MediaStorageSOPInstanceUID = '1.3.6.1.4.1.9590.100.1.2.193378027812447806612603416531187163249';


%        atWriteMetaData{ww}.TransferSyntaxUID          = '1.2.840.10008.1.2';
%        atWriteMetaData{ww}.ImplementationClassUID     = '1.3.6.1.4.1.9590.100.1.3.100.9.4';
%        atWriteMetaData{ww}.ImplementationVersionName  = 'MATLAB IPT 9.4';
       
        % SOPClassUID
         
        if isfield(atWriteMetaData{ww}, 'SOPClassUID')

            if isempty(atWriteMetaData{ww}.SOPClassUID)
    
                atWriteMetaData{ww}.SOPClassUID  = atWriteMetaData{ww}.MediaStorageSOPClassUID;
            end
        else
            atWriteMetaData{ww}.SOPClassUID  = atWriteMetaData{ww}.MediaStorageSOPClassUID;
        end

        % SOPInstanceUID

        if isfield(atWriteMetaData{ww}, 'SOPInstanceUID')

            if isempty(atWriteMetaData{ww}.SOPInstanceUID)
    
                atWriteMetaData{ww}.SOPInstanceUID  = atWriteMetaData{ww}.MediaStorageSOPInstanceUID;
            end
        else
            atWriteMetaData{ww}.SOPInstanceUID  = atWriteMetaData{ww}.MediaStorageSOPInstanceUID;
        end

        % if isempty(atWriteMetaData{ww}.SOPInstanceUID)       
        % 
        %     atWriteMetaData{ww}.SOPInstanceUID  = dicomuid;
        % end
        
%         if isempty(atWriteMetaData{ww}.MediaStorageSOPClassUID) 
% 
%             atWriteMetaData{ww}.MediaStorageSOPClassUID = '1.2.840.10008.5.1.4.1.1.128';
%         end
% 
%         if isempty(atWriteMetaData{ww}.MediaStorageSOPInstanceUID) 
% 
%             atWriteMetaData{ww}.MediaStorageSOPInstanceUID = '1.2.840.113619.2.290.430754041.1667595622.405863';
%         end
 

        atWriteMetaData{ww}.SeriesInstanceUID = dSeriesInstanceUID;

        atWriteMetaData{ww}.BitsAllocated = 16;
        atWriteMetaData{ww}.BitsStored    = 16;
        atWriteMetaData{ww}.HighBit       = 15;

        % Date Time
   
        if isscalar(atMetaData)
            dicomwrite(uint16(array4d)    , ...
                       sOutFile           , ...
                       atWriteMetaData{ww}, ...
                       'CreateMode'       , ...
                       'Copy'           , ...
                       'WritePrivate'     , false ...
                      ); 
        else
            dicomwrite(uint16(array4d(:,:,:,ww)), ...
                       sOutFile           , ...
                       atWriteMetaData{ww}, ...
                       'CreateMode'       , ...
                       'Copy'           , ...
                       'WritePrivate'     , false ...
                      );             
        end

    end
    
    % f = java.io.File(char(sTmpDir)); % Copy from temp folder to output dir
    % dinfo = f.listFiles();                   
    % for K = 1 : 1 : numel(dinfo)
    % 
    %     if ~(dinfo(K).isDirectory)
    % 
    %         sSrcFile  = fullfile(char(sTmpDir), char(dinfo(K).getName()));
    %         sDstFile  = fullfile(char(sWriteDir), char(dinfo(K).getName()));
    % 
    %         if ~strcmpi(sSrcFile, sDstFile) % File doesn't exist
    % 
    %             copyfile(sSrcFile, sWriteDir);
    %         end
    % 
    %     end
    % end 
    % rmdir(char(sTmpDir), 's');    

    f = java.io.File(char(sTmpDir));  % Java File handle for temp folder
    dinfo = f.listFiles();            % Java array of java.io.File objects
    
    for K = 1:numel(dinfo)
    
        if ~dinfo(K).isDirectory()    % <-- must call as a method
            name     = char(dinfo(K).getName());
            sSrcFile = fullfile(char(sTmpDir), name);
            sDstFile = fullfile(char(sWriteDir), name);
    
            if ~strcmpi(sSrcFile, sDstFile)
    
                % --- retry copy ---
                maxRetries = 5;
                delaySec   = 1;
                success    = false;
    
                for attempt = 1:maxRetries
                    try
                        copyfile(sSrcFile, sWriteDir);
                        if exist(sDstFile,'file')
                            success = true;
                            break;
                        end
                    catch ME2
                        logErrorToFile(ME2);
                        progressBar(1, sprintf('Error: Copy attempt %d failed: %s\n', attempt, ME2.message));
                    end
                    pause(delaySec);
                end
    
                if ~success
                    progressBar(1, sprintf('Error: Failed to copy %s after %d attempts.', sSrcFile, maxRetries));
                end
            end
        end
    end
    
    % --- retry rmdir ---
    maxRetries = 5;
    delaySec   = 1;
    for attempt = 1:maxRetries
        try
            rmdir(char(sTmpDir), 's');
            if ~exist(sTmpDir,'dir')
                break;
            end
        catch ME3
            logErrorToFile(ME3);
            progressBar(0, sprintf('Error: mkdir attempt %d failed: %s\n', attempt, ME3.message));
            pause(delaySec);
        end
    end

    progressBar(1, sprintf('Export %d files completed %s', ww, char(sWriteDir)));
    
    catch ME   
        logErrorToFile(ME);
        progressBar(1, sprintf('Error:writeOtherFormatToDICOM(), %s', char(sWriteDir)) );                
    end
    
    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow;     
end