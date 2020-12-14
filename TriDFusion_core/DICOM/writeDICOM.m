function writeDICOM(sOutDir, iSeriesOffset)            
%function writeDICOM(sOutDir, iSeriesOffset)
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

    sDate = sprintf('%s', datetime('now','Format','MMMM-d-y-hhmmss'));                
    sWriteDir = char(sOutDir) + "TriDFusion_" + char(sDate) + '/';              
    if ~(exist(char(sWriteDir), 'dir'))
        mkdir(char(sWriteDir));
    end

    tWriteTemplate = inputTemplate('get');
    if iSeriesOffset > numel(tWriteTemplate)  
        return;
    end  

    dicomdict('factory');  

    aBuffer = dicomBuffer('get');
    if isempty(aBuffer)
        aInput  = inputBuffer('get');      
        aBuffer = aInput{iSeriesOffset};
    end
    aBufferSize = size(aBuffer);

    tMetaData = dicomMetaData('get');
    if isempty(tMetaData)
        tMetaData = tWriteTemplate(iSeriesOffset).atDicomInfo;
    end

    if numel(aBufferSize) > 2
        array4d = zeros(aBufferSize(1), aBufferSize(2),1, aBufferSize(3));
        for slice = 1:aBufferSize(3)
            if isfield(tMetaData{slice}, 'RescaleIntercept') && ...
               isfield(tMetaData{slice}, 'RescaleSlope')     
                if tMetaData{slice}.RescaleSlope ~= 0
                    aBuffer(:,:,slice) = (aBuffer(:,:,slice) / tMetaData{slice}.RescaleSlope) - tMetaData{slice}.RescaleIntercept;
                end
            end                            
           array4d(:,:,1,slice) = aBuffer(:,:,slice);
        end            
    else
        if isfield(tMetaData{1}, 'RescaleIntercept') && ...
           isfield(tMetaData{1}, 'RescaleSlope') 
            if tMetaData{1}.RescaleSlope ~= 0
                aBuffer = (aBuffer / tMetaData{1}.RescaleSlope) - tMetaData{1}.RescaleIntercept;
            end
        end
        array4d = aBuffer;
    end

    for ww=1: numel(tWriteTemplate(iSeriesOffset).asFilesList)

        tWriteMetaData{ww} = ...
            dicominfo(char(tWriteTemplate(iSeriesOffset).asFilesList{ww}), 'UseVRHeuristic', false);
        progressBar(ww / numel(tWriteTemplate(iSeriesOffset).asFilesList), sprintf('Processing header %d/%d, please wait', ww, numel(tWriteTemplate(iSeriesOffset).asFilesList)));

    end 

    if numel(tMetaData) < numel(tWriteMetaData) && ...
       numel(tMetaData) ~= 1   
        tWriteMetaData = tWriteMetaData(1:numel(tMetaData));

    elseif numel(tMetaData) > numel(tWriteMetaData) && ...
           numel(tMetaData) ~= 1   

        for cc=1:numel(tMetaData) - numel(tWriteMetaData)
            tWriteMetaData{end+1} = tWriteMetaData{end}; %Add missing slice
        end
    end    

    if numel(tWriteMetaData) ~= 1
        if tWriteMetaData{2}.ImagePositionPatient(3) - ...
           tWriteMetaData{1}.ImagePositionPatient(3) > 0                    
             array4d = array4d(:,:,:,end:-1:1);   
             tWriteMetaData = flip(tWriteMetaData);
        end
    else
        if strcmpi(tWriteMetaData{1}.PatientPosition, 'FFS')
             array4d = array4d(:,:,:,end:-1:1);    
             tWriteMetaData = flip(tWriteMetaData);
        end                       
    end  

    dSeriesInstanceUID = dicomuid;
    for ww=1: numel(tWriteMetaData)
        tWriteMetaData{ww}.InstanceNumber = tMetaData{ww}.InstanceNumber;                              
        tWriteMetaData{ww}.PatientPosition = tMetaData{ww}.PatientPosition;                                                                  

        tWriteMetaData{ww}.PixelSpacing = tMetaData{ww}.PixelSpacing;                              
        tWriteMetaData{ww}.SliceThickness = tMetaData{ww}.SliceThickness;                 
        tWriteMetaData{ww}.ImagePositionPatient = tMetaData{ww}.ImagePositionPatient;               
        tWriteMetaData{ww}.ImageOrientationPatient = tMetaData{ww}.ImageOrientationPatient;        

        tWriteMetaData{ww}.SeriesDescription = tMetaData{ww}.SeriesDescription; 
        tWriteMetaData{ww}.SourceApplicationEntityTitle = 'TRIDFUSION';
        tWriteMetaData{ww}.SeriesInstanceUID = dSeriesInstanceUID;

        if isfield(tWriteMetaData{ww}, 'SliceLocation')
            tWriteMetaData{ww}.SliceLocation = tMetaData{ww}.SliceLocation;               
        end

        if isfield(tWriteMetaData{ww}, 'SpacingBetweenSlices')
            tWriteMetaData{ww}.SpacingBetweenSlices = tMetaData{ww}.SpacingBetweenSlices;
        end

        if isfield(tWriteMetaData{ww}, 'NumberOfSlices')
            tWriteMetaData{ww}.NumberOfSlices = tMetaData{ww}.NumberOfSlices;
        end

        if isfield(tWriteMetaData{ww}, 'InstanceNumber')
            tWriteMetaData{ww}.InstanceNumber = tMetaData{ww}.InstanceNumber;
        end

        if isfield(tWriteMetaData{ww}, 'RescaleIntercept')
            tWriteMetaData{ww}.RescaleIntercept = tMetaData{ww}.RescaleIntercept;
        end
        
        if isfield(tWriteMetaData{ww}, 'RescaleSlope')
            tWriteMetaData{ww}.RescaleSlope = tMetaData{ww}.RescaleSlope;
        end        
        
        if isfield(tWriteMetaData{ww}, 'Units')
            tWriteMetaData{ww}.Units = tMetaData{ww}.Units;
        end  
        
        sWriteFile = sprintf('%s.%d', tWriteMetaData{ww}.SeriesInstanceUID, ww);                                             
        sOutFile = sprintf('%s%s',sWriteDir, sWriteFile);

        try        
            if numel(tWriteTemplate(iSeriesOffset).asFilesList) == 1    
                dicomwrite(int16(array4d(:,:,:,:))  , ...
                           sOutFile          , ...
                           tWriteMetaData{ww}, ...
                           'CreateMode'      , ...
                           'copy'            , ...
                           'WritePrivate'    , true ...
                           ); 
            else           
                dicomwrite(int16(array4d(:,:,:,ww)) , ...
                           sOutFile          , ...
                           tWriteMetaData{ww}, ...
                           'CreateMode'      , ...
                           'copy'            , ...
                           'WritePrivate'    , true ...
                           );                            
            end
        catch
            progressBar(1, 'Error: Write dicom fail!');
            return;
        end

        progressBar(ww / numel(tWriteTemplate(iSeriesOffset).asFilesList), sprintf('Writing dicom %d/%d, please wait', ww, numel(tWriteMetaData)));

    end                   

    progressBar(1, sprintf('Export %d files completed %s', ww, char(sWriteDir)));

end        
