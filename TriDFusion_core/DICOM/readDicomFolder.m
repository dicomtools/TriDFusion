function [asFilesList, atDicomInfo, aDicomBuffer] = readDicomFolder(asMainDirectory)
%function [asFilesList, atDicomInfo, aDicomBuffer] = readDicomFolder(asMainDirectory)
%Read a dicom folder, including the sub folder.
%See TriDFuison.doc (or pdf) for more information about options.
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

    asFilesList  = cell(1,100000);
    atDicomInfo  = cell(1,100000);
    aDicomBuffer = cell(1,100000);

    dNbEntry = 1;

    for dDirLoop=1: numel(asMainDirectory)
     %   datasets = folderInfo4che3(asMainDir{ii}, true);

        tDatasets = dicomInfoSortFolder(asMainDirectory{dDirLoop});                

        if isempty(tDatasets) 
            continue;
        end
        
        if isfield(tDatasets, 'DicomBuffers')

            if ~isAllBuffersSameSize(tDatasets.DicomBuffers)
                atGroupedDatasets= splitDatasets(tDatasets);
            else
                atGroupedDatasets = tDatasets;
            end
        else
            atGroupedDatasets = tDatasets;
        end

        for jj=1:numel(atGroupedDatasets)

            tDatasets = atGroupedDatasets(jj);
    
            if isfield(tDatasets, 'Contours')
                inputContours('add', tDatasets.Contours{:});
            end
    
            if isfield(tDatasets, 'FileNames'   ) && ...
               isfield(tDatasets, 'DicomInfos'  ) && ...       
               isfield(tDatasets, 'DicomBuffers')                              
    
                atFrameInfo = dicomInfoComputeFrames(tDatasets.DicomInfos);
                
                if isfield(tDatasets.DicomInfos{1}, 'SeriesType')
                    
                    asSeriesType = lower(tDatasets.DicomInfos{1}.SeriesType);
                else
                    asSeriesType = '';
                end
                
                bGated = false;
                if find(contains(asSeriesType, 'gated'))
                    bGated = true;
                end
                
                bDynamic = false;
                if find(contains(asSeriesType, 'dynamic'))
                    bDynamic = true;
                end
    
       %         sFileList = datasets.FileNames;
                if bGated   == true || ...
                   bDynamic == true || ...
                   ~isempty(atFrameInfo)
    
                    if bGated   == true || ...
                       bDynamic == true 
    
                        dNbFrames   = numel(tDatasets.DicomInfos) / tDatasets.DicomInfos{1}.NumberOfSlices;
                        dNbOfSlices = tDatasets.DicomInfos{1}.NumberOfSlices;
    
                        dNumericTimeFirst = str2double(tDatasets.DicomInfos{1}.AcquisitionTime);
                        dNumericTimeLast = str2double(tDatasets.DicomInfos{end}.AcquisitionTime);
    
                        if dNumericTimeLast < dNumericTimeFirst
                            tDatasets.FileNames    = flipud(tDatasets.FileNames);
                            tDatasets.DicomInfos   = flipud(tDatasets.DicomInfos);
                            tDatasets.DicomBuffers = flipud(tDatasets.DicomBuffers);
    %                         dInitialEntry = dNbEntry;
                        end
                        
                        for dFramesLoop=1:dNbFrames
    % 
    %                         if dNumericTimeLast < dNumericTimeFirst
    %                             dFrameOffset = dInitialEntry + (dNbFrames-dFramesLoop-1);
    %                             dFrom = 1+(dFrameOffset * dNbOfSlices);
    %                             dTo   = dFrom+dNbOfSlices-1;  
    %                         else
                                dFrameOffset = dFramesLoop-1;
                                dFrom = 1+ (dFrameOffset * dNbOfSlices);
                                dTo   = dNbOfSlices * dFramesLoop;  
    %                         end
    % 
    %                         dFrameOffset = dNbEntry-1;
    %                         dFrom = 1+ (dFrameOffset * dNbOfSlices);
    %                         dTo   = dNbOfSlices * dNbEntry;  
    
                            asFilesList{dNbEntry}  = tDatasets.FileNames(dFrom:dTo);
                            atDicomInfo{dNbEntry}  = tDatasets.DicomInfos(dFrom:dTo);
                            aDicomBuffer{dNbEntry} = tDatasets.DicomBuffers(dFrom:dTo);
    
                            for dSeriesLoop = 1: numel(atDicomInfo{dNbEntry})
                                if bGated == true
                                    atDicomInfo{dNbEntry}{dSeriesLoop}.SeriesDescription = ...
                                        sprintf('%s (Gate %d)', atDicomInfo{dNbEntry}{dSeriesLoop}.SeriesDescription, dFramesLoop);
                                else
                                    atDicomInfo{dNbEntry}{dSeriesLoop}.SeriesDescription = ...
                                        sprintf('%s (Dynamic %d)', atDicomInfo{dNbEntry}{dSeriesLoop}.SeriesDescription, dFramesLoop);                                    
                                end
                                atDicomInfo{dNbEntry}{dSeriesLoop}.din.frame = dFramesLoop;
                            end
    
                            dNbEntry = dNbEntry+1;
                           
                        end
    
                    else
    
                        for dFramesLoop=1:numel(atFrameInfo)
    
                            if dFramesLoop == 1
                                
                                dFrameOffset = dFramesLoop-1;
                                dNbOfSlices  = atFrameInfo{dFramesLoop}.NbSlices;
                                
                                dFrom = 1+ (dFrameOffset * dNbOfSlices);
                                dTo   = dNbOfSlices * dFramesLoop;                                
                            else
                                dNbOfSlices  = atFrameInfo{dFramesLoop}.NbSlices;
    
                                dFrom = 1+dLastTo;
                                dTo   = dNbOfSlices + dLastTo;                                    
                            end
    
                            asFilesList {dNbEntry} = tDatasets.FileNames(dFrom:dTo);
                            atDicomInfo {dNbEntry} = tDatasets.DicomInfos(dFrom:dTo);
                            aDicomBuffer{dNbEntry} = tDatasets.DicomBuffers(dFrom:dTo);

                            for dSeriesLoop = 1: numel(atDicomInfo{dNbEntry})
                                atDicomInfo{dNbEntry}{dSeriesLoop}.SeriesDescription = ...
                                    sprintf('%s (Frame %d)', atDicomInfo{dNbEntry}{dSeriesLoop}.SeriesDescription, dFramesLoop);
                                atDicomInfo{dNbEntry}{dSeriesLoop}.din.frame = dFramesLoop;
                            end
    
                            dNbEntry = dNbEntry+1;
                            dLastTo  = dTo;
                        end
    
                    end
                else
                    if isscalar(tDatasets)
                        
                        asImageType = lower(tDatasets.DicomInfos{1}.ImageType);  
                        
                        bStatic = false;
                        if find(contains(asImageType, 'static')) 
                            bStatic = true;
                        end
    
                        bWholeBody = false;
                        if find(contains(asImageType, 'whole body')) 
                            bWholeBody = true;
                        end
                        
                        bScreenCapture = false;
                        if strcmpi(tDatasets.DicomInfos{1}.SOPClassUID, '1.2.840.10008.5.1.4.1.1.7') || ...
                           strcmpi(tDatasets.DicomInfos{1}.SOPClassUID, '1.2.840.10008.5.1.4.1.1.7.4')     
                    
                            bScreenCapture = true;
                        end
                   %     if find(contains(asImageType, 'secondary')) 
                   %         bScreenCapture = true;
                   %     end
                            
                        if bStatic    == true || ...
                           bWholeBody == true 
    
                            sSeriesDescription = tDatasets.DicomInfos{1}.SeriesDescription;
                           
                            if numel(tDatasets.DicomBuffers) > 1
    
                                dNbOfImages = numel(tDatasets.DicomBuffers);
    
                                for ll=1:dNbOfImages
                                   
                                    aTemp{1} = tDatasets.DicomBuffers{ll}(:,:);
                             
                                    aDicomBuffer{dNbEntry} = aTemp;
                                
                                    if bStatic == true
                                        tDatasets.DicomInfos{ll}.SeriesDescription = sprintf('%s (Static %d)', sSeriesDescription, ll);
                                    elseif bWholeBody == true
                                        tDatasets.DicomInfos{ll}.SeriesDescription = sprintf('%s (Whole Body %d)', sSeriesDescription, ll);
                                    end
                                    
                                    asFilesList{dNbEntry}  = tDatasets.FileNames(ll);
                                    atDicomInfo{dNbEntry}  = tDatasets.DicomInfos(ll);
                                    
                                    dNbEntry = dNbEntry+1;             
                                end                                
                            else
    
                                if size(tDatasets.DicomBuffers{1}, 3) == 1
                                    dNbOfImages = size(tDatasets.DicomBuffers{1}, 4);
                                else
                                    dNbOfImages = size(tDatasets.DicomBuffers{1}, 3);
                                end                          
                                
                                for ll=1:dNbOfImages
                                                                    
                                    if size(tDatasets.DicomBuffers{1}, 3) == 1
                                        aTemp{1} = tDatasets.DicomBuffers{1}(:,:,1,ll);
                                    else
                                        aTemp{1} = tDatasets.DicomBuffers{1}(:,:,ll);
                                    end
                                    
                                    aDicomBuffer{dNbEntry} = aTemp;
    
                                    if bStatic == true 
                                        tDatasets.DicomInfos{1}.SeriesDescription = sprintf('%s (Static %d)', sSeriesDescription, ll);
                                    elseif bWholeBody == true 
                                        tDatasets.DicomInfos{1}.SeriesDescription = sprintf('%s (Whole Body %d)', sSeriesDescription, ll);
                                    end
                                    
                                    asFilesList{dNbEntry}  = tDatasets.FileNames;
                                    atDicomInfo{dNbEntry}  = tDatasets.DicomInfos;
                                    
                                    dNbEntry = dNbEntry+1;                                      
                                end
                            end
                        elseif bScreenCapture == true
    
                            sSeriesDescription = tDatasets.DicomInfos{1}.SeriesDescription;
    
                            dNbSc = numel(tDatasets.DicomBuffers);
                            for sc=1:dNbSc
    
                                if dNbSc > 1
                                    tDatasets.DicomInfos{1}.SeriesDescription = sprintf('%s (Frame %d)', sSeriesDescription,sc);
                                end
    
                                asFilesList{dNbEntry}  = tDatasets.FileNames;
                                atDicomInfo{dNbEntry}  = tDatasets.DicomInfos;
                                aDicomBuffer{dNbEntry}{1} = reshape(tDatasets.DicomBuffers{sc}, [size(tDatasets.DicomBuffers{sc}, 1), size(tDatasets.DicomBuffers{sc}, 2), 1, 3]);
    
                                dNbEntry = dNbEntry+1;  
                            end
    
                        else
                            asFilesList{dNbEntry}  = tDatasets.FileNames;
                            atDicomInfo{dNbEntry}  = tDatasets.DicomInfos;
                            aDicomBuffer{dNbEntry} = tDatasets.DicomBuffers;
    
                            dNbEntry = dNbEntry+1;                                
                        end
                    else                    
                        asFilesList{dNbEntry}  = tDatasets.FileNames;
                        atDicomInfo{dNbEntry}  = tDatasets.DicomInfos;
                        aDicomBuffer{dNbEntry} = tDatasets.DicomBuffers;
    
                        dNbEntry = dNbEntry+1;
                    end
                end
            end
        end

        % Clean up empty entry

        asFilesList  = asFilesList(~cellfun(@isempty, asFilesList));
        atDicomInfo  = atDicomInfo(~cellfun(@isempty, atDicomInfo));
        aDicomBuffer = aDicomBuffer(~cellfun(@isempty, aDicomBuffer));

    end


    function bAllSameSize = isAllBuffersSameSize(aBuffers)

        % Access the DicomBuffers
        % buffers = tDatasets.DicomBuffers;
        
        dNumBuffers = numel(aBuffers);  % Get the number of buffers
        
        bAllSameSize = true;
        
        if dNumBuffers > 0

            aRefSize = size(aBuffers{1});
                       
            for i = 2:dNumBuffers % Loop through the buffers and compare sizes

                aCurrentSize = size(aBuffers{i});
                
                % Compare current buffer size with the reference size

                if ~isequal(aRefSize, aCurrentSize)

                    bAllSameSize = false;
                    % disp(['Buffer ' num2str(i) ' has a different size: ', mat2str(aCurrentSize)]);
                end
            end
            
        end

    end

    function atGroupedDatasets= splitDatasets(tDatasets)

        aBuffers     = tDatasets.DicomBuffers;
        asFileNames  = tDatasets.FileNames;
        atDicomInfos = tDatasets.DicomInfos;
        
        dNumBuffers = numel(aBuffers);
        atGroupedDatasets = struct('FileNames', {}, 'DicomInfos', {}, 'DicomBuffers', {});
        
        if dNumBuffers > 0

            aRefSize = size(aBuffers{1});
            
            % Temporary storage for grouping

            tCurrentGroup = struct('FileNames', {{}}, 'DicomInfos', {{}}, 'DicomBuffers', {{}});
            tCurrentGroup.FileNames    = asFileNames(1);
            tCurrentGroup.DicomInfos   = atDicomInfos(1);
            tCurrentGroup.DicomBuffers = aBuffers(1);
                     
            dGroupCounter = 1; % Initialize a counter for grouped datasets
                  
            for i = 2:dNumBuffers % Loop through the buffers starting from the second one

                aCurrentSize = size(aBuffers{i});
                
                if isequal(aRefSize, aCurrentSize)  % If sizes are the same, add the buffer to the current group
                   
                    tCurrentGroup.FileNames    = [tCurrentGroup.FileNames; asFileNames(i)];
                    tCurrentGroup.DicomInfos   = [tCurrentGroup.DicomInfos; atDicomInfos(i)];
                    tCurrentGroup.DicomBuffers = [tCurrentGroup.DicomBuffers; aBuffers{i}];

                else  % If sizes are different, save the current group and start a new one
                   
                    atGroupedDatasets(dGroupCounter) = tCurrentGroup;
                    dGroupCounter = dGroupCounter + 1;
                    
                    % Start a new group

                    tCurrentGroup = struct('FileNames', {{}}, 'DicomInfos', {{}}, 'DicomBuffers', {{}});
                    tCurrentGroup.FileNames    = asFileNames(i);
                    tCurrentGroup.DicomInfos   = atDicomInfos(i);
                    tCurrentGroup.DicomBuffers = aBuffers(i);
                    
                    % Update the reference size

                    aRefSize = aCurrentSize;
                end
            end
            
            % Save the last group

            atGroupedDatasets(dGroupCounter) = tCurrentGroup;
        end
    end

end