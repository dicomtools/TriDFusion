function writeDICOM(aBuffer, tMetaData, sWriteDir, iSeriesOffset)            
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

    tWriteTemplate = inputTemplate('get');
    if iSeriesOffset > numel(tWriteTemplate)  
        return;
    end      
    
    try
                
    set(fiMainWindowPtr('get'), 'Pointer', 'watch');
    drawnow;  
  
    sTmpDir = sprintf('%stemp_dicom_%s//', tempdir, datetime('now','Format','MMMM-d-y-hhmmss'));
    if exist(char(sTmpDir), 'dir')
        rmdir(char(sTmpDir), 's');
    end
    mkdir(char(sTmpDir));    
    
    dicomdict('factory');  

    aBufferSize = size(aBuffer);

    if numel(aBufferSize) > 2
        array4d = zeros(aBufferSize(1), aBufferSize(2),1, aBufferSize(3));
        for slice = 1:aBufferSize(3)
            if numel(tMetaData) == aBufferSize(3)
                if isfield(tMetaData{slice}, 'RescaleIntercept') && ...
                   isfield(tMetaData{slice}, 'RescaleSlope')     
                    if tMetaData{slice}.RescaleSlope ~= 0
                        aBuffer(:,:,slice) = (aBuffer(:,:,slice) - tMetaData{slice}.RescaleIntercept) / tMetaData{slice}.RescaleSlope;
                    else
                        if isfield(tMetaData{slice}, 'RealWorldValueMappingSequence') % SUV Spect
                            if tMetaData{slice}.RealWorldValueMappingSequence.Item_1.RealWorldValueSlope ~= 0
                                fSlope = tMetaData{slice}.RealWorldValueMappingSequence.Item_1.RealWorldValueSlope;
                                fIntercept = tMetaData{slice}.RealWorldValueMappingSequence.Item_1.RealWorldValueIntercept;
                                aBuffer(:,:,slice) = (aBuffer(:,:,slice) - fIntercept) / fSlope;
                            end                        
                        end                           
                    end
                end                            
            else
                if isfield(tMetaData{1}, 'RescaleIntercept') && ...
                   isfield(tMetaData{1}, 'RescaleSlope')     
                    if tMetaData{1}.RescaleSlope ~= 0
                        aBuffer(:,:,slice) = (aBuffer(:,:,slice) - tMetaData{1}.RescaleIntercept) / tMetaData{1}.RescaleSlope;
                    else                        
                        if isfield(tMetaData{1}, 'RealWorldValueMappingSequence') % SUV Spect
                            if tMetaData{1}.RealWorldValueMappingSequence.Item_1.RealWorldValueSlope ~= 0
                                fSlope =  tMetaData{1}.RealWorldValueMappingSequence.Item_1.RealWorldValueSlope;
                                fIntercept = tMetaData{1}.RealWorldValueMappingSequence.Item_1.RealWorldValueIntercept;
                                aBuffer(:,:,slice) = (aBuffer(:,:,slice) - fIntercept) / fSlope;
                            end                        
                        end                                                 
                    end
                end                  
            end
           array4d(:,:,1,slice) = aBuffer(:,:,slice);
        end            
    else
        if isfield(tMetaData{1}, 'RescaleIntercept') && ...
           isfield(tMetaData{1}, 'RescaleSlope') 
            if tMetaData{1}.RescaleSlope ~= 0
                aBuffer = (aBuffer - tMetaData{1}.RescaleIntercept) / tMetaData{1}.RescaleSlope;
            else
                if isfield(tMetaData{1}, 'RealWorldValueMappingSequence') % SUV Spect
                    if tMetaData{1}.RealWorldValueMappingSequence.Item_1.RealWorldValueSlope ~= 0
                        fSlope = tMetaData{1}.RealWorldValueMappingSequence.Item_1.RealWorldValueSlope;
                        fIntercept = tMetaData{1}.RealWorldValueMappingSequence.Item_1.RealWorldValueIntercept;
                        aBuffer = (aBuffer - fIntercept) / fSlope;
                    end                        
                end                
            end
        end               
        
        array4d = aBuffer;
    end
    
    if numel(tWriteTemplate(iSeriesOffset).asFilesList)
        for ww=1: numel(tWriteTemplate(iSeriesOffset).asFilesList)

            tWriteMetaData{ww} = ...
                dicominfo(char(tWriteTemplate(iSeriesOffset).asFilesList{ww}));
            progressBar(ww / numel(tWriteTemplate(iSeriesOffset).asFilesList), sprintf('Processing header %d/%d, please wait', ww, numel(tWriteTemplate(iSeriesOffset).asFilesList)));
        end         
    else
        for ww=1: numel(tWriteTemplate(iSeriesOffset).atDicomInfo)
            tWriteMetaData{ww} = tWriteTemplate(iSeriesOffset).atDicomInfo{ww};
        end        
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
        if isfield(tWriteMetaData{1}, 'ImagePositionPatient') && ...
           isfield(tWriteMetaData{2}, 'ImagePositionPatient')

            if tWriteMetaData{2}.ImagePositionPatient(3) - ...
               tWriteMetaData{1}.ImagePositionPatient(3) > 0                    
                 array4d = array4d(:,:,:,end:-1:1);   
                 tWriteMetaData = flip(tWriteMetaData);
            end
        end
    else
        if isfield(tWriteMetaData{1}, 'PatientPosition')
            if strcmpi(tWriteMetaData{1}.PatientPosition, 'FFS')
                 array4d = array4d(:,:,:,end:-1:1);    
                 tWriteMetaData = flip(tWriteMetaData);
            end         
            
            if strcmpi(tWriteMetaData{1}.PatientPosition, 'FFP')
                 array4d = array4d(end:-1:1,:,:,:);    
            end               
        end
    end  

    dSeriesInstanceUID = dicomuid;
    
    dWriteEndLoop = numel(tWriteMetaData);
    for ww=1:dWriteEndLoop
        tWriteMetaData{ww}.InstanceNumber = tMetaData{ww}.InstanceNumber;                              
        tWriteMetaData{ww}.PatientPosition = tMetaData{ww}.PatientPosition;                                                                  

        tWriteMetaData{ww}.PixelSpacing = tMetaData{ww}.PixelSpacing;                              
        tWriteMetaData{ww}.SliceThickness = tMetaData{ww}.SliceThickness;                 
        tWriteMetaData{ww}.ImagePositionPatient = tMetaData{ww}.ImagePositionPatient;               
        tWriteMetaData{ww}.ImageOrientationPatient = tMetaData{ww}.ImageOrientationPatient;        

        tWriteMetaData{ww}.Rows = tMetaData{ww}.Rows;               
        tWriteMetaData{ww}.Columns = tMetaData{ww}.Columns;           
        
        tWriteMetaData{ww}.SeriesDescription = tMetaData{ww}.SeriesDescription; 
        tWriteMetaData{ww}.SourceApplicationEntityTitle = 'TRIDFUSION';
        
        if updateDicomWriteSeriesInstanceUID('get') == true
            tWriteMetaData{ww}.SeriesInstanceUID = dSeriesInstanceUID;
        end

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
        
        % Fix patient dose
        
        if isfield(tWriteMetaData{ww}, 'PatientWeight')
            tWriteMetaData{ww}.PatientWeight = tMetaData{ww}.PatientWeight;
        end  
        
        if isfield(tWriteMetaData{ww}, 'PatientSize')
            tWriteMetaData{ww}.PatientSize = tMetaData{ww}.PatientSize;
        end  
        
        if isfield(tWriteMetaData{ww}, 'SeriesDate')
            tWriteMetaData{ww}.SeriesDate = tMetaData{ww}.SeriesDate;
        end  
        
        if isfield(tWriteMetaData{ww}, 'SeriesTime')
            tWriteMetaData{ww}.SeriesTime = tMetaData{ww}.SeriesTime;
        end    
        
        if isfield(tWriteMetaData{ww}, 'AcquisitionDate')
            tWriteMetaData{ww}.AcquisitionDate = tMetaData{ww}.AcquisitionDate;
        end  
        
        if isfield(tWriteMetaData{ww}, 'AcquisitionTime')
            tWriteMetaData{ww}.AcquisitionTime = tMetaData{ww}.AcquisitionTime;
        end   
        
        if isfield(tWriteMetaData{ww}, 'RadiopharmaceuticalInformationSequence')
            if isfield(tWriteMetaData{ww}.RadiopharmaceuticalInformationSequence, 'Item_1')
                
                if isfield(tWriteMetaData{ww}.RadiopharmaceuticalInformationSequence.Item_1, 'RadionuclideTotalDose')
                    tWriteMetaData{ww}.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideTotalDose = tMetaData{ww}.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideTotalDose;
                end
                
                if isfield(tWriteMetaData{ww}.RadiopharmaceuticalInformationSequence.Item_1, 'RadiopharmaceuticalStartDateTime')
                    tWriteMetaData{ww}.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartDateTime = tMetaData{ww}.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartDateTime;
                end
                
                if isfield(tWriteMetaData{ww}.RadiopharmaceuticalInformationSequence.Item_1, 'RadionuclideHalfLife')
                    tWriteMetaData{ww}.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideHalfLife = tMetaData{ww}.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideHalfLife;
                end                
            end
        end                   
        
        sWriteFile = sprintf('%s.%d', tWriteMetaData{ww}.SeriesInstanceUID, ww);                                             
        sOutFile = sprintf('%s%s',sTmpDir, sWriteFile);

        try      
            tWriteMetaData{ww}.BitsAllocated = 16;
            tWriteMetaData{ww}.BitsStored = 16;
            tWriteMetaData{ww}.HighBit = 15;

            if tWriteTemplate(iSeriesOffset).bMathApplied == true
                
                if strcmpi(tWriteMetaData{ww}.Modality, 'NM')
                    if numel(tWriteMetaData) == 1                    

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

                    tWriteMetaData{ww}.RealWorldValueMappingSequence.Item_1.RealWorldValueLastValueMapped = 65535; 
                    tWriteMetaData{ww}.RealWorldValueMappingSequence.Item_1.RealWorldValueFirstValueMapped = 0;
                    tWriteMetaData{ww}.RealWorldValueMappingSequence.Item_1.RealWorldValueIntercept = 0;  
                    tWriteMetaData{ww}.RealWorldValueMappingSequence.Item_1.RealWorldValueSlope = fSlope; 

                    tWriteMetaData{ww}.RealWorldValueMappingSequence.Item_1.MeasurementUnitsCodeSequence.Item_1.CodeValue = '{counts}';
                    tWriteMetaData{ww}.RealWorldValueMappingSequence.Item_1.MeasurementUnitsCodeSequence.Item_1.CodingSchemeDesignator  = 'UCUM';
                    tWriteMetaData{ww}.RealWorldValueMappingSequence.Item_1.MeasurementUnitsCodeSequence.Item_1.CodeMeaning =  'Counts';                    
                end
            end
                
            if numel(tWriteMetaData) == 1    
                
                dicomwrite(int16(array4d) , ...
                           sOutFile          , ...
                           tWriteMetaData{ww}, ...
                           'CreateMode'      , ...
                           'Copy'            , ...
                           'WritePrivate'    , true ...
                           ); 
            else       
   %             array4d = dicomread(char(tWriteTemplate(iSeriesOffset).asFilesList{ww}));
                dicomwrite(int16(array4d(:,:,:,ww)) , ...
                           sOutFile          , ...
                           tWriteMetaData{ww}, ...
                           'CreateMode'      , ...
                           'Copy'          , ...
                           'WritePrivate'    , true ...
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
