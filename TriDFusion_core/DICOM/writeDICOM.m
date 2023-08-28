function writeDICOM(aBuffer, atMetaData, sWriteDir, dSeriesOffset, bRescale)            
%function writeDICOM(aBuffer, atMetaData, sWriteDir, dSeriesOffset, bRescale)
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

    atInputTemplate = inputTemplate('get');
    if dSeriesOffset > numel(atInputTemplate)  
        return;
    end      
    
    try
                
    set(fiMainWindowPtr('get'), 'Pointer', 'watch');
    drawnow;  
  
    sTmpDir = sprintf('%stemp_dicom_%s//', viewerTempDirectory('get'), datetime('now','Format','MMMM-d-y-hhmmss-MS'));
    if exist(char(sTmpDir), 'dir')
        rmdir(char(sTmpDir), 's');
    end
    mkdir(char(sTmpDir));    
    
    dicomdict('factory');  

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
                end
            end

           array4d(:,:,1,slice) = aBuffer(:,:,slice);
           
        end            
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
        end
        array4d = aBuffer;
    end
    
    if numel(atInputTemplate(dSeriesOffset).asFilesList)
 %       for ww=1: numel(atInputTemplate(dSeriesOffset).asFilesList)
        dReadEndLoop = numel(atInputTemplate(dSeriesOffset).asFilesList);
        for ww=1: dReadEndLoop

            atWriteMetaData{ww} = ...
                dicominfo(char(atInputTemplate(dSeriesOffset).asFilesList{ww}));
            
            if mod(ww,5)==1 || ww == dReadEndLoop       
                progressBar(ww / numel(atInputTemplate(dSeriesOffset).asFilesList), ...
                    sprintf('Processing header %d/%d, please wait', ww, numel(atInputTemplate(dSeriesOffset).asFilesList)));
            end
        end         
    else
        for ww=1: numel(atInputTemplate(dSeriesOffset).atDicomInfo)
            atWriteMetaData{ww} = atInputTemplate(dSeriesOffset).atDicomInfo{ww};
        end        
    end

    if numel(atMetaData) < numel(atWriteMetaData) && ...
       numel(atMetaData) ~= 1   
        atWriteMetaData = atWriteMetaData(1:numel(atMetaData));

    elseif numel(atMetaData) > numel(atWriteMetaData) && ...
           numel(atMetaData) ~= 1   

        for cc=1:numel(atMetaData) - numel(atWriteMetaData)
            atWriteMetaData{end+1} = atWriteMetaData{end}; %Add missing slice
        end
    end    

    if numel(atWriteMetaData) ~= 1
        if isfield(atWriteMetaData{1}, 'ImagePositionPatient') && ...
           isfield(atWriteMetaData{2}, 'ImagePositionPatient')

            if atWriteMetaData{2}.ImagePositionPatient(3) - ...
               atWriteMetaData{1}.ImagePositionPatient(3) > 0                    
                 array4d = array4d(:,:,:,end:-1:1);   
                 atWriteMetaData = flip(atWriteMetaData);
            end
        end
    else
        if isfield(atWriteMetaData{1}, 'PatientPosition')
            if strcmpi(atWriteMetaData{1}.PatientPosition, 'FFS')
                 array4d = array4d(:,:,:,end:-1:1);    
                 atWriteMetaData = flip(atWriteMetaData);
            end         
            
            if strcmpi(atWriteMetaData{1}.PatientPosition, 'FFP')
                 array4d = array4d(end:-1:1,:,:,:);    
            end               
        end
    end  

    dSeriesInstanceUID = dicomuid;
    
%    dWriteEndLoop = numel(atWriteMetaData);
    if numel(atWriteMetaData) > 1
        if size(aBuffer, 3) == 1
            dWriteEndLoop = 1;
        else
            dWriteEndLoop = aBufferSize(3);
        end
    else
        dWriteEndLoop = 1;
    end
    
    for ww=1:dWriteEndLoop
        
        atWriteMetaData{ww}.InstanceNumber  = atMetaData{ww}.InstanceNumber;                              
        atWriteMetaData{ww}.PatientPosition = atMetaData{ww}.PatientPosition;                                                                  

        atWriteMetaData{ww}.PixelSpacing    = atMetaData{ww}.PixelSpacing;    

        if isfield(atWriteMetaData{ww}, 'SliceThickness')
            atWriteMetaData{ww}.SliceThickness = atMetaData{ww}.SliceThickness;                 
        end

        if isfield(atWriteMetaData{ww}, 'SpacingBetweenSlices')
            atWriteMetaData{ww}.SpacingBetweenSlices = atMetaData{ww}.SpacingBetweenSlices;     
        end

        if isfield(atWriteMetaData{ww}, 'ImagePositionPatient')
            atWriteMetaData{ww}.ImagePositionPatient = atMetaData{ww}.ImagePositionPatient;     
        end

        if isfield(atWriteMetaData{ww}, 'ImageOrientationPatient')
            atWriteMetaData{ww}.ImageOrientationPatient = atMetaData{ww}.ImageOrientationPatient;     
        end

%        atWriteMetaData{ww}.SliceThickness          = atMetaData{ww}.SliceThickness;                 
%        atWriteMetaData{ww}.SpacingBetweenSlices    = atMetaData{ww}.SpacingBetweenSlices;     
%         atWriteMetaData{ww}.ImagePositionPatient    = atMetaData{ww}.ImagePositionPatient;               
%         atWriteMetaData{ww}.ImageOrientationPatient = atMetaData{ww}.ImageOrientationPatient;        
                
        atWriteMetaData{ww}.Rows    = atMetaData{ww}.Rows;               
        atWriteMetaData{ww}.Columns = atMetaData{ww}.Columns;           
        
        atWriteMetaData{ww}.SeriesDescription = atMetaData{ww}.SeriesDescription; 
        atWriteMetaData{ww}.SourceApplicationEntityTitle = 'TRIDFUSION';
        
        if updateDicomWriteSeriesInstanceUID('get') == true
            atWriteMetaData{ww}.SeriesInstanceUID = dSeriesInstanceUID;
        end
        
        if isfield(atWriteMetaData{ww}, 'Modality')
            atWriteMetaData{ww}.Modality = atMetaData{ww}.Modality;  
        else
            if isfield(atMetaData{ww}, 'Modality')
                if ~isempty(atMetaData{ww}.Modality)
                    atWriteMetaData{ww}.Modality = ...
                        atMetaData{ww}.Modality;
                end
            end            
        end
        
        if isfield(atWriteMetaData{ww}, 'SOPClassUID')
            atWriteMetaData{ww}.SOPClassUID = atMetaData{ww}.SOPClassUID; 
        else
            if isfield(atMetaData{ww}, 'SOPClassUID')
                if ~isempty(atMetaData{ww}.SOPClassUID)
                    atWriteMetaData{ww}.SOPClassUID = ...
                        atMetaData{ww}.SOPClassUID;
                end
            end             
        end  
        
        if isfield(atWriteMetaData{ww}, 'MediaStorageSOPClassUID')
            atWriteMetaData{ww}.SOPClassUID = atMetaData{ww}.MediaStorageSOPClassUID;         
        else
            if isfield(atMetaData{ww}, 'MediaStorageSOPClassUID')
                if ~isempty(atMetaData{ww}.MediaStorageSOPClassUID)
                    atWriteMetaData{ww}.MediaStorageSOPClassUID = ...
                        atMetaData{ww}.MediaStorageSOPClassUID;
                end
            end               
        end          

        if numel(aBufferSize) > 2 % 3D images
        
            if isfield(atWriteMetaData{ww}, 'SliceLocation')
                atWriteMetaData{ww}.SliceLocation = atMetaData{ww}.SliceLocation;     
            else
                if isfield(atMetaData{ww}, 'SliceLocation')
                    if ~isempty(atMetaData{ww}.SliceLocation)
                        atWriteMetaData{ww}.SliceLocation = ...
                            atMetaData{ww}.SliceLocation;
                    end
                end             
            end
    
            if isfield(atWriteMetaData{ww}, 'SpacingBetweenSlices')
                atWriteMetaData{ww}.SpacingBetweenSlices = ...
                    atMetaData{ww}.SpacingBetweenSlices;
            else
                if isfield(atMetaData{ww}, 'SpacingBetweenSlices')
                    if ~isempty(atMetaData{ww}.SpacingBetweenSlices)
                        if atMetaData{ww}.SpacingBetweenSlices ~= 0
                           atWriteMetaData{ww}.SpacingBetweenSlices = ...
                               atMetaData{ww}.SpacingBetweenSlices;
                        end
                    end
                end             
            end
    
            if isfield(atWriteMetaData{ww}, 'NumberOfSlices')
                atWriteMetaData{ww}.NumberOfSlices = atMetaData{ww}.NumberOfSlices;
            else
                if isfield(atMetaData{ww}, 'NumberOfSlices')
                    if ~isempty(atMetaData{ww}.NumberOfSlices)
                        atWriteMetaData{ww}.NumberOfSlices = ...
                            atMetaData{ww}.NumberOfSlices;
                    end
                end             
            end
    
            if isfield(atWriteMetaData{ww}, 'InstanceNumber')
                atWriteMetaData{ww}.InstanceNumber = atMetaData{ww}.InstanceNumber;
            else
                if isfield(atMetaData{ww}, 'InstanceNumber')
                    if ~isempty(atMetaData{ww}.InstanceNumber)
                        atWriteMetaData{ww}.InstanceNumber = ...
                            atMetaData{ww}.InstanceNumber;
                    end
                end              
            end
    
            if isfield(atWriteMetaData{ww}, 'RescaleIntercept')
                atWriteMetaData{ww}.RescaleIntercept = atMetaData{ww}.RescaleIntercept;
            else
                if isfield(atMetaData{ww}, 'RescaleIntercept')
                    if ~isempty(atMetaData{ww}.RescaleIntercept)
                        atWriteMetaData{ww}.RescaleIntercept = ...
                            atMetaData{ww}.RescaleIntercept;
                    end
                end               
            end
            
            if isfield(atWriteMetaData{ww}, 'RescaleSlope')
                atWriteMetaData{ww}.RescaleSlope = atMetaData{ww}.RescaleSlope;
            else
                if isfield(atMetaData{ww}, 'RescaleSlope')
                    if ~isempty(atMetaData{ww}.RescaleSlope)
                        atWriteMetaData{ww}.RescaleSlope = ...
                            atMetaData{ww}.RescaleSlope;
                    end
                end             
            end        
            
            if isfield(atWriteMetaData{ww}, 'Units')
                atWriteMetaData{ww}.Units = atMetaData{ww}.Units;
            else
                if isfield(atMetaData{ww}, 'Units')
                    if ~isempty(atMetaData{ww}.Units)
                        atWriteMetaData{ww}.Units = atMetaData{ww}.Units;
                    end
                end              
            end  
            
            % Fix patient dose
            
            if isfield(atWriteMetaData{ww}, 'PatientWeight')
                atWriteMetaData{ww}.PatientWeight = atMetaData{ww}.PatientWeight;
            else
                if isfield(atMetaData{ww}, 'PatientWeight')
                    if ~isempty(atMetaData{ww}.PatientWeight)
                        atWriteMetaData{ww}.PatientWeight = ...
                            atMetaData{ww}.PatientWeight;
                    end
                end
            end  
            
            if isfield(atWriteMetaData{ww}, 'PatientSize')
                atWriteMetaData{ww}.PatientSize = atMetaData{ww}.PatientSize;
            else
                if isfield(atMetaData{ww}, 'PatientSize')
                    if ~isempty(atMetaData{ww}.PatientSize)
                        atWriteMetaData{ww}.PatientSize = ...
                            atMetaData{ww}.PatientSize;
                    end
                end            
            end  
            
            if isfield(atWriteMetaData{ww}, 'SeriesDate')
                atWriteMetaData{ww}.SeriesDate = atMetaData{ww}.SeriesDate;
            else
                if isfield(atMetaData{ww}, 'SeriesDate')
                    if ~isempty(atMetaData{ww}.SeriesDate)
                        atWriteMetaData{ww}.SeriesDate = ...
                            atMetaData{ww}.SeriesDate;
                    end
                end             
            end  
            
            if isfield(atWriteMetaData{ww}, 'SeriesTime')
                atWriteMetaData{ww}.SeriesTime = atMetaData{ww}.SeriesTime;
            else
                if isfield(atMetaData{ww}, 'SeriesTime')
                    if ~isempty(atMetaData{ww}.SeriesTime)
                        atWriteMetaData{ww}.SeriesTime = ...
                            atMetaData{ww}.SeriesTime;
                    end
                end             
            end    
            
            if isfield(atWriteMetaData{ww}, 'AcquisitionDate')
                atWriteMetaData{ww}.AcquisitionDate = atMetaData{ww}.AcquisitionDate;
            else
                if isfield(atMetaData{ww}, 'AcquisitionDate')
                    if ~isempty(atMetaData{ww}.AcquisitionDate)
                        atWriteMetaData{ww}.AcquisitionDate = ...
                            atMetaData{ww}.AcquisitionDate;
                    end
                end             
            end  
            
            if isfield(atWriteMetaData{ww}, 'AcquisitionTime')
                atWriteMetaData{ww}.AcquisitionTime = ...
                    atMetaData{ww}.AcquisitionTime;
            else
                if isfield(atMetaData{ww}, 'AcquisitionTime')
                    if ~isempty(atMetaData{ww}.AcquisitionTime)
                        atWriteMetaData{ww}.AcquisitionTime = ...
                            atMetaData{ww}.AcquisitionTime;
                    end
                end              
            end       
            
            if isfield(atWriteMetaData{ww}, 'RadiopharmaceuticalInformationSequence')
                if isfield(atWriteMetaData{ww}.RadiopharmaceuticalInformationSequence, 'Item_1')
                    
                    if isfield(atWriteMetaData{ww}.RadiopharmaceuticalInformationSequence.Item_1, 'RadionuclideTotalDose')
                        atWriteMetaData{ww}.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideTotalDose = ...
                            atMetaData{ww}.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideTotalDose;
                    else
                        if isfield(atMetaData{ww}.RadiopharmaceuticalInformationSequence.Item_1, 'RadionuclideTotalDose')
                            if ~isempty(atMetaData{ww}.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideTotalDose)
                                atWriteMetaData{ww}.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideTotalDose = ...
                                    atMetaData{ww}.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideTotalDose;
                            end
                        end                      
                    end
                    
                    if isfield(atWriteMetaData{ww}.RadiopharmaceuticalInformationSequence.Item_1, 'RadiopharmaceuticalStartDateTime')
                        atWriteMetaData{ww}.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartDateTime = ...
                            atMetaData{ww}.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartDateTime;
                    else
                        if isfield(atMetaData{ww}.RadiopharmaceuticalInformationSequence.Item_1, 'RadiopharmaceuticalStartDateTime')
                            if ~isempty(atMetaData{ww}.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartDateTime)
                                atWriteMetaData{ww}.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartDateTime = ...
                                    atMetaData{ww}.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartDateTime;
                            end
                        end    
                    end
                    
                    if isfield(atWriteMetaData{ww}.RadiopharmaceuticalInformationSequence.Item_1, 'RadionuclideHalfLife')
                        atWriteMetaData{ww}.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideHalfLife = ...
                            atMetaData{ww}.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideHalfLife;
                    else
                        if isfield(atMetaData{ww}.RadiopharmaceuticalInformationSequence.Item_1, 'RadionuclideHalfLife')
                            if ~isempty(atMetaData{ww}.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideHalfLife)
                                atWriteMetaData{ww}.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideHalfLife = ...
                                    atMetaData{ww}.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideHalfLife;
                            end
                        end                     
                    end                
                end
            end                   
        end

        sWriteFile = sprintf('%s.%d', atWriteMetaData{ww}.SeriesInstanceUID, ww);                                             
        sOutFile = sprintf('%s%s',sTmpDir, sWriteFile);

        try   
            
            atWriteMetaData{ww}.BitsAllocated = 16;
            atWriteMetaData{ww}.BitsStored    = 16;
            atWriteMetaData{ww}.HighBit       = 15;

            if 0
%            if atInputTemplate(dSeriesOffset).bMathApplied == true
                
                if strcmpi(atWriteMetaData{ww}.Modality, 'NM')
                    if numel(atWriteMetaData) == 1                    

                        dTrueMin = min(array4d, [],'all');
                        dTrueMax = max(array4d, [],'all');
                        dTrueRange = dTrueMax-dTrueMin;
                        fSlope = dTrueRange/65535;

                        array4d = array4d.*inv(fSlope);
                    else
                        dTrueMin = min(array4d(:,:,:,ww), [],'all');
                        dTrueMax = max(array4d(:,:,:,ww), [],'all');
                        dTrueRange = dTrueMax-dTrueMin;
                        fSlope = dTrueRange/65535;

                        array4d(:,:,:,ww) = array4d(:,:,:,ww).*inv(fSlope);
                    end    

                    atWriteMetaData{ww}.RealWorldValueMappingSequence.Item_1.RealWorldValueLastValueMapped = 65535; 
                    atWriteMetaData{ww}.RealWorldValueMappingSequence.Item_1.RealWorldValueFirstValueMapped = 0;
                    atWriteMetaData{ww}.RealWorldValueMappingSequence.Item_1.RealWorldValueIntercept = 0;  
                    atWriteMetaData{ww}.RealWorldValueMappingSequence.Item_1.RealWorldValueSlope = fSlope; 

                    atWriteMetaData{ww}.RealWorldValueMappingSequence.Item_1.MeasurementUnitsCodeSequence.Item_1.CodeValue = '{counts}';
                    atWriteMetaData{ww}.RealWorldValueMappingSequence.Item_1.MeasurementUnitsCodeSequence.Item_1.CodingSchemeDesignator  = 'UCUM';
                    atWriteMetaData{ww}.RealWorldValueMappingSequence.Item_1.MeasurementUnitsCodeSequence.Item_1.CodeMeaning =  'Counts';                    
                end
            end

            if numel(atWriteMetaData) == 1    
                
                dicomwrite(uint16(array4d)    , ...
                           sOutFile           , ...
                           atWriteMetaData{ww}, ...
                           'CreateMode'       , ...
                           'Copy'             , ...
                           'WritePrivate'     , true ...
                           ); 
            else       
   %             array4d = dicomread(char(atInputTemplate(dSeriesOffset).asFilesList{ww}));
                dicomwrite(uint32(array4d(:,:,:,ww)) , ...
                           sOutFile           , ...
                           atWriteMetaData{ww}, ...
                           'CreateMode'       , ...
                           'Copy'             , ...
                           'WritePrivate'     , true ...
                           );                            
            end
        catch
            set(fiMainWindowPtr('get'), 'Pointer', 'default');
            drawnow;             
            
            progressBar(1, sprintf('Error: Write dicom %s fail!', char(sWriteDir)) );
            return;
        end
        
        if mod(ww,5)==1 || ww == dWriteEndLoop         
            progressBar(ww / dWriteEndLoop, sprintf('Writing dicom %d/%d, please wait', ww, dWriteEndLoop));
        end
    end                   
  
    f = java.io.File(char(sTmpDir)); % Copy from temp folder to output dir
    dinfo = f.listFiles();                   
    for K = 1 : 1 : numel(dinfo)
        if ~(dinfo(K).isDirectory)
            copyfile([char(sTmpDir) char(dinfo(K).getName())], char(sWriteDir) );
        end
    end 
    rmdir(char(sTmpDir), 's');    
    
    progressBar(1, sprintf('Export %d files completed %s', ww, char(sWriteDir)));
    
    catch
        progressBar(1, sprintf('Error:writeDICOM(), %s', char(sWriteDir)) );                
    end
    
    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow; 
    

end        
