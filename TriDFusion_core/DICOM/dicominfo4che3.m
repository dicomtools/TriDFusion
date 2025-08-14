function info = dicominfo4che3(fileInput)
%function info = dicominfo4che3(fileInput)
%Return a structure of the meta data.
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

USE_DCM4CHEE = true;

if USE_DCM4CHEE == true
    try 
        din = org.dcm4che3.io.DicomInputStream(...
                java.io.BufferedInputStream(java.io.FileInputStream(char(fileInput))));    

        dataset = din.readDataset(-1, -1);                  
        % info.din.pixelData = dataset.getInts(org.dcm4che3.data.Tag.PixelData);
    catch ME   
        logErrorToFile(ME);
        try 
            
        info = dicominfo(char(fileInput)); 
%        info.din.rows       = info.Rows;
%        info.din.cols       = info.Columns;   
        catch ME   
            % logErrorToFile(ME);
            info = []; % The specified file is not in DICOM format.
        end
        
        return;
    end  
else
        try 
            
        info = dicominfo(char(fileInput)); 
 
        catch ME   
            logErrorToFile(ME);
            info = [];
        end
  
        return;    
end
    % Image information
        
    asImageType{1} = char(dataset.getString(org.dcm4che3.data.Tag.ImageType, 0));
    asImageType{2} = char(dataset.getString(org.dcm4che3.data.Tag.ImageType, 1));
    asImageType{3} = char(dataset.getString(org.dcm4che3.data.Tag.ImageType, 2));
    asImageType{4} = char(dataset.getString(org.dcm4che3.data.Tag.ImageType, 3));

    info.ImageType = '';

    if ~isempty(asImageType{1})
        info.ImageType = sprintf('%s', asImageType{1});
    end

    if ~isempty(asImageType{2})
        info.ImageType = sprintf('%s\\%s', info.ImageType, asImageType{2});
    end

    if ~isempty(asImageType{3})
        info.ImageType = sprintf('%s\\%s', info.ImageType, asImageType{3});
    end

    if ~isempty(asImageType{4})
        info.ImageType = sprintf('%s\\%s', info.ImageType, asImageType{4});
    end

    % Patient information

    info.PatientName        = char(dataset.getString(org.dcm4che3.data.Tag.PatientName, 0));
    info.PatientID          = char(dataset.getString(org.dcm4che3.data.Tag.PatientID, 0));
    info.SeriesDescription  = char(dataset.getString(org.dcm4che3.data.Tag.SeriesDescription, 0));
    info.StudyDescription   = char(dataset.getString(org.dcm4che3.data.Tag.StudyDescription, 0));

    info.Modality  = char(dataset.getString(org.dcm4che3.data.Tag.Modality, 0));        

    info.InstanceNumber  = dataset.getInt(org.dcm4che3.data.Tag.InstanceNumber, 0);

    info.PatientPosition         = char(dataset.getString(org.dcm4che3.data.Tag.PatientPosition, 0));      
    info.ImagePositionPatient    = dataset.getDoubles(org.dcm4che3.data.Tag.ImagePositionPatient);
    info.ImageOrientationPatient = dataset.getDoubles(org.dcm4che3.data.Tag.ImageOrientationPatient);
    
    if isempty(info.ImagePositionPatient) 
        datasetDetector = dataset.getNestedDataset(org.dcm4che3.data.Tag.DetectorInformationSequence); % NM
        if ~isempty(datasetDetector)
            info.ImagePositionPatient = datasetDetector.getDoubles(org.dcm4che3.data.Tag.ImagePositionPatient);
            if isempty(info.ImagePositionPatient) 
                info.ImagePositionPatient = zeros(3,1);
            end
        else
            info.ImagePositionPatient = zeros(3,1);
        end
    end
    
    if isempty(info.ImageOrientationPatient) 
        datasetDetector = dataset.getNestedDataset(org.dcm4che3.data.Tag.DetectorInformationSequence); % NM
        if ~isempty(datasetDetector)         
            info.ImageOrientationPatient = datasetDetector.getDoubles(org.dcm4che3.data.Tag.ImageOrientationPatient);      
            if isempty(info.ImageOrientationPatient)         
                info.ImageOrientationPatient = zeros(6,1);
            end
        else
            info.ImageOrientationPatient = zeros(6,1);
        end
    end
    
    info.SeriesDate = char(dataset.getString(org.dcm4che3.data.Tag.SeriesDate, 0));
    info.StudyDate  = char(dataset.getString(org.dcm4che3.data.Tag.StudyDate , 0));

    info.SeriesTime = char(dataset.getString(org.dcm4che3.data.Tag.SeriesTime, 0));
    info.StudyTime  = char(dataset.getString(org.dcm4che3.data.Tag.StudyTime , 0));

    asSeriesType{1} = char(dataset.getString(org.dcm4che3.data.Tag.SeriesType, 0));
    asSeriesType{2} = char(dataset.getString(org.dcm4che3.data.Tag.SeriesType, 1));
    asSeriesType{3} = char(dataset.getString(org.dcm4che3.data.Tag.SeriesType, 2));
    asSeriesType{4} = char(dataset.getString(org.dcm4che3.data.Tag.SeriesType, 3));

    info.SeriesType = '';

    if ~isempty(asSeriesType{1})
        info.SeriesType = sprintf('%s', asSeriesType{1});
    end

    if ~isempty(asSeriesType{2})
        info.SeriesType = sprintf('%s\\%s', info.SeriesType, asSeriesType{2});
    end

    if ~isempty(asSeriesType{3})
        info.SeriesType = sprintf('%s\\%s', info.SeriesType, asSeriesType{3});
    end

    if ~isempty(asSeriesType{4})
        info.SeriesType = sprintf('%s\\%s', info.SeriesType, asSeriesType{4});
    end

    info.ContentTime  = char(dataset.getString(org.dcm4che3.data.Tag.ContentTime , 0));

    info.AcquisitionTime  = char(dataset.getString(org.dcm4che3.data.Tag.AcquisitionTime, 0));
    info.AcquisitionDate  = char(dataset.getString(org.dcm4che3.data.Tag.AcquisitionDate , 0));                     

    info.SeriesInstanceUID = char(dataset.getString(org.dcm4che3.data.Tag.SeriesInstanceUID, 0));
    info.StudyInstanceUID  = char(dataset.getString(org.dcm4che3.data.Tag.StudyInstanceUID, 0));
    
    info.MediaStorageSOPClassUID    = char(dataset.getString(org.dcm4che3.data.Tag.MediaStorageSOPClassUID, 0));
    info.MediaStorageSOPInstanceUID = char(dataset.getString(org.dcm4che3.data.Tag.MediaStorageSOPInstanceUID, 0));
    info.SOPClassUID                = char(dataset.getString(org.dcm4che3.data.Tag.SOPClassUID, 0));
    info.SOPInstanceUID             = char(dataset.getString(org.dcm4che3.data.Tag.SOPInstanceUID, 0));
    info.FrameOfReferenceUID        = char(dataset.getString(org.dcm4che3.data.Tag.FrameOfReferenceUID, 0));    

    info.AccessionNumber = char(dataset.getString(org.dcm4che3.data.Tag.AccessionNumber, 0));
    info.StudyID         = char(dataset.getString(org.dcm4che3.data.Tag.StudyID, 0));

    info.ActualFrameDuration = dataset.getInt(org.dcm4che3.data.Tag.ActualFrameDuration,0);

    info.Rows    = dataset.getInt(org.dcm4che3.data.Tag.Rows, 0);
    info.Columns = dataset.getInt(org.dcm4che3.data.Tag.Columns,0);

    info.RescaleSlope     = dataset.getFloat(org.dcm4che3.data.Tag.RescaleSlope,0);        
    info.RescaleIntercept = dataset.getFloat(org.dcm4che3.data.Tag.RescaleIntercept,0);        

    info.SliceLocation  = dataset.getFloat(org.dcm4che3.data.Tag.SliceLocation, 0);
    info.ReconstructionDiameter = dataset.getFloat(org.dcm4che3.data.Tag.ReconstructionDiameter,0);
    info.SliceThickness         = dataset.getFloat(org.dcm4che3.data.Tag.SliceThickness,0);
    info.SpacingBetweenSlices   = dataset.getFloat(org.dcm4che3.data.Tag.SpacingBetweenSlices,0);
    info.PixelSpacing           = dataset.getDoubles(org.dcm4che3.data.Tag.PixelSpacing);
    if isempty(info.PixelSpacing) 
        info.PixelSpacing = zeros(2,1);
    end
         
    info.PatientWeight    = dataset.getFloat(org.dcm4che3.data.Tag.PatientWeight, 0);
    info.PatientSize      = dataset.getFloat(org.dcm4che3.data.Tag.PatientSize, 0);
    info.PatientSex       = char(dataset.getString(org.dcm4che3.data.Tag.PatientSex, 0));
    info.PatientAge       = char(dataset.getString(org.dcm4che3.data.Tag.PatientAge, 0));
    info.PatientBirthDate = char(dataset.getString(org.dcm4che3.data.Tag.PatientBirthDate, 0));
    
    % Manifacturer & protocol information

    info.Manufacturer           = char(dataset.getString(org.dcm4che3.data.Tag.Manufacturer, 0));
    info.ManufacturerModelName  = char(dataset.getString(org.dcm4che3.data.Tag.ManufacturerModelName, 0));
    info.ProtocolName           = char(dataset.getString(org.dcm4che3.data.Tag.ProtocolName, 0)); 
    info.InstitutionName        = char(dataset.getString(org.dcm4che3.data.Tag.InstitutionName, 0)); 
    info.StationName            = char(dataset.getString(org.dcm4che3.data.Tag.StationName, 0)); 
    info.ReferringPhysicianName = char(dataset.getString(org.dcm4che3.data.Tag.ReferringPhysicianName, 0));
   
    info.NumberOfEnergyWindows = str2double(dataset.getString(org.dcm4che3.data.Tag.NumberOfEnergyWindows,0));
    info.NumberOfDetectors     = str2double(dataset.getString(org.dcm4che3.data.Tag.NumberOfDetectors,0));
    
    % Dose information
    
    datasetDose = dataset.getNestedDataset(org.dcm4che3.data.Tag.RadiopharmaceuticalInformationSequence, 0);
    if ~isempty(datasetDose)
        % RadiopharmaceuticalInformationSequence
        info.RadiopharmaceuticalInformationSequence.Item_1.Radiopharmaceutical              = char(datasetDose.getString(org.dcm4che3.data.Tag.Radiopharmaceutical, 0));
        info.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartTime     = char(datasetDose.getString(org.dcm4che3.data.Tag.RadiopharmaceuticalStartTime, 0));
        info.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStopTime      = char(datasetDose.getString(org.dcm4che3.data.Tag.RadiopharmaceuticalStopTime, 0));
        info.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideTotalDose            = char(datasetDose.getString(org.dcm4che3.data.Tag.RadionuclideTotalDose, 0));
        info.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideHalfLife             = char(datasetDose.getString(org.dcm4che3.data.Tag.RadionuclideHalfLife, 0));
        info.RadiopharmaceuticalInformationSequence.Item_1.RadionuclidePositronFraction     = char(datasetDose.getString(org.dcm4che3.data.Tag.RadionuclidePositronFraction, 0));
        info.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartDateTime = char(datasetDose.getString(org.dcm4che3.data.Tag.RadiopharmaceuticalStartDateTime, 0));
        info.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStopDateTime  = char(datasetDose.getString(org.dcm4che3.data.Tag.RadiopharmaceuticalStopDateTime, 0));
        
        % RadiopharmaceuticalCodeSequence
        
        datasetRadiopharmaceutical = datasetDose.getNestedDataset(org.dcm4che3.data.Tag.RadiopharmaceuticalCodeSequence, 0);        
        if ~isempty(datasetRadiopharmaceutical)
            
            info.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalCodeSequence.Item_1.CodeValue = ...
                char(datasetRadiopharmaceutical.getString(org.dcm4che3.data.Tag.CodeValue, 0));

            info.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalCodeSequence.Item_1.CodingSchemeDesignator = ...
                char(datasetRadiopharmaceutical.getString(org.dcm4che3.data.Tag.CodingSchemeDesignator, 0));

            info.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalCodeSequence.Item_1.CodeMeaning = ...
                char(datasetRadiopharmaceutical.getString(org.dcm4che3.data.Tag.CodeMeaning, 0));
        else
            info.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalCodeSequence.Item_1.CodeValue = '';
            info.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalCodeSequence.Item_1.CodingSchemeDesignator = '';
            info.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalCodeSequence.Item_1.CodeMeaning = '';
        end
    
        % RotationInformationSequence

        datasetRotationInformation = dataset.getNestedDataset(org.dcm4che3.data.Tag.RotationInformationSequence, 0);
        if ~isempty(datasetRotationInformation)
    
            info.RotationInformationSequence.Item_1.RotationDirection        = char(datasetRotationInformation.getString(org.dcm4che3.data.Tag.RotationDirection, 0));
            info.RotationInformationSequence.Item_1.RadialPosition           = datasetRotationInformation.getDoubles(org.dcm4che3.data.Tag.RadialPosition);
            info.RotationInformationSequence.Item_1.NumberOfFramesInRotation = str2double(datasetRotationInformation.getString(org.dcm4che3.data.Tag.NumberOfFramesInRotation));
            info.RotationInformationSequence.Item_1.AngularStep              = double(datasetRotationInformation.getDoubles(org.dcm4che3.data.Tag.AngularStep));                                                                                                                                                                                
            info.RotationInformationSequence.Item_1.StartAngle               = double(datasetRotationInformation.getDoubles(org.dcm4che3.data.Tag.StartAngle));                                                                                                                                                                                
            info.RotationInformationSequence.Item_1.ScanArc                  = double(datasetRotationInformation.getDoubles(org.dcm4che3.data.Tag.ScanArc));
        end

        % Dose information

        % RadionuclideCodeSequence
        
        datasetRadionuclide = datasetDose.getNestedDataset(org.dcm4che3.data.Tag.RadionuclideCodeSequence, 0);
        if ~isempty(datasetRadionuclide)
        
            info.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideCodeSequence.Item_1.CodeValue = ...
                char(datasetRadionuclide.getString(org.dcm4che3.data.Tag.CodeValue, 0));

            info.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideCodeSequence.Item_1.CodingSchemeDesignator ...
                = char(datasetRadionuclide.getString(org.dcm4che3.data.Tag.CodingSchemeDesignator, 0));

            info.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideCodeSequence.Item_1.CodeMeaning ...
                = char(datasetRadionuclide.getString(org.dcm4che3.data.Tag.CodeMeaning, 0));        
        else
            info.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideCodeSequence.Item_1.CodeValue = '';
            info.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideCodeSequence.Item_1.CodingSchemeDesignator = '';
            info.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideCodeSequence.Item_1.CodeMeaning = '';
        end
    end
    
    % Real World Value (SUV SPECT)
    
    realWorldValue = dataset.getNestedDataset(org.dcm4che3.data.Tag.RealWorldValueMappingSequence, 0);
    if ~isempty(realWorldValue)    
         measurementUnits = realWorldValue.getNestedDataset(org.dcm4che3.data.Tag.MeasurementUnitsCodeSequence, 0);
         if ~isempty(measurementUnits)    
            info.RealWorldValueMappingSequence.Item_1.MeasurementUnitsCodeSequence.Item_1.CodeValue              = char(measurementUnits.getString(org.dcm4che3.data.Tag.CodeValue, 0));
            info.RealWorldValueMappingSequence.Item_1.MeasurementUnitsCodeSequence.Item_1.CodingSchemeDesignator = char(measurementUnits.getString(org.dcm4che3.data.Tag.CodingSchemeDesignator, 0));
            info.RealWorldValueMappingSequence.Item_1.MeasurementUnitsCodeSequence.Item_1.CodeMeaning            = char(measurementUnits.getString(org.dcm4che3.data.Tag.CodeMeaning, 0));
         end
         info.RealWorldValueMappingSequence.Item_1.RealWorldValueLastValueMapped  = realWorldValue.getFloat(org.dcm4che3.data.Tag.RealWorldValueLastValueMapped, 0);
         info.RealWorldValueMappingSequence.Item_1.RealWorldValueFirstValueMapped = realWorldValue.getFloat(org.dcm4che3.data.Tag.RealWorldValueFirstValueMapped, 0);
         info.RealWorldValueMappingSequence.Item_1.RealWorldValueIntercept        = realWorldValue.getFloat(org.dcm4che3.data.Tag.RealWorldValueIntercept, 0);
         info.RealWorldValueMappingSequence.Item_1.RealWorldValueSlope            = realWorldValue.getFloat(org.dcm4che3.data.Tag.RealWorldValueSlope, 0);               
    end
    
    info.Units = char(dataset.getString(org.dcm4che3.data.Tag.Units, 0));        
    info.DecayCorrection = char(dataset.getString(org.dcm4che3.data.Tag.DecayCorrection, 0));        

    info.MRAcquisitionType = char(dataset.getString(org.dcm4che3.data.Tag.MRAcquisitionType, 0));
    
    % Image information

    info.BitsAllocated = dataset.getInt(org.dcm4che3.data.Tag.BitsAllocated, 0);
    info.BitsStored    = dataset.getInt(org.dcm4che3.data.Tag.BitsStored, 0);
    info.HighBit       = dataset.getInt(org.dcm4che3.data.Tag.HighBit, 0);

   % if info.HighBit == info.BitsStored -1 % 16 bits
   %     info.din.pixeldata  = uint16(dataset.getInts(org.dcm4che3.data.Tag.PixelData));
   % else
   %     info.din.pixeldata  = dataset.getInts(org.dcm4che3.data.Tag.PixelData);
   % end

    % DetectorInformationSequence

    dInformationSequenceItem = 0;

    detectorInformationSequence = dataset.getNestedDataset(org.dcm4che3.data.Tag.DetectorInformationSequence, 0); % Item_1
    while ~isempty(detectorInformationSequence)

        dInformationSequenceItem = dInformationSequenceItem+1;
        sInformationSequenceItem = sprintf('Item_%d', dInformationSequenceItem);

        info.DetectorInformationSequence.(sInformationSequenceItem).StartAngle            = double(detectorInformationSequence.getDoubles(org.dcm4che3.data.Tag.StartAngle));                                                                                                                                                                                
        info.DetectorInformationSequence.(sInformationSequenceItem).FieldOfViewShape      = char(detectorInformationSequence.getString(org.dcm4che3.data.Tag.FieldOfViewShape, 0));                                                                                                                                                                                
        info.DetectorInformationSequence.(sInformationSequenceItem).FieldOfViewDimensions = double(detectorInformationSequence.getInts(org.dcm4che3.data.Tag.FieldOfViewDimensions));   
        info.DetectorInformationSequence.(sInformationSequenceItem).RadialPosition        = double(detectorInformationSequence.getDoubles(org.dcm4che3.data.Tag.RadialPosition));

        detectorInformationSequence = dataset.getNestedDataset(org.dcm4che3.data.Tag.DetectorInformationSequence, dInformationSequenceItem); % Item_X

        if dInformationSequenceItem > 1000 % Protection
            break;
        end
    end

    % EnergyWindowRangeSequence

    dEnergyWindowInformationSequenceItem = 0;

    energyWindowInformationSequence = dataset.getNestedDataset(org.dcm4che3.data.Tag.EnergyWindowInformationSequence, 0); % Item_1
    while ~isempty(energyWindowInformationSequence)

        dEnergyWindowInformationSequenceItem = dEnergyWindowInformationSequenceItem+1;
        sEnergyWindowInformationSequenceItem = sprintf('Item_%d', dEnergyWindowInformationSequenceItem);

        dEnergyWindowRangeSequence = 0;

        energyWindowRangeSequence = energyWindowInformationSequence.getNestedDataset(org.dcm4che3.data.Tag.EnergyWindowRangeSequence, 0);
        while ~isempty(energyWindowRangeSequence)

            dEnergyWindowRangeSequence = dEnergyWindowRangeSequence+1;
            sEnergyWindowRangeSequence = sprintf('Item_%d', dEnergyWindowRangeSequence);

            info.EnergyWindowInformationSequence.(sEnergyWindowInformationSequenceItem).EnergyWindowRangeSequence.(sEnergyWindowRangeSequence).EnergyWindowLowerLimit = ...
                double(energyWindowRangeSequence.getDoubles(org.dcm4che3.data.Tag.EnergyWindowLowerLimit));

            info.EnergyWindowInformationSequence.(sEnergyWindowInformationSequenceItem).EnergyWindowRangeSequence.(sEnergyWindowRangeSequence).EnergyWindowUpperLimit = ...
                double(energyWindowRangeSequence.getDoubles(org.dcm4che3.data.Tag.EnergyWindowUpperLimit));        

            energyWindowRangeSequence = energyWindowInformationSequence.getNestedDataset(org.dcm4che3.data.Tag.EnergyWindowRangeSequence, dEnergyWindowRangeSequence);

            if dEnergyWindowRangeSequence > 1000 % Protection
                break;
            end
        end

        info.EnergyWindowInformationSequence.(sEnergyWindowInformationSequenceItem).EnergyWindowName = char(energyWindowInformationSequence.getString(org.dcm4che3.data.Tag.EnergyWindowName, 0));

        energyWindowInformationSequence = dataset.getNestedDataset(org.dcm4che3.data.Tag.EnergyWindowInformationSequence, dEnergyWindowInformationSequenceItem); % Item_X

         if dEnergyWindowInformationSequenceItem > 1000 % Protection
            break;
        end          
    end

    % 3DF private tags 
    grp      = hex2dec('0029');
    tag0010  = bitor(bitshift(grp,16), hex2dec('0010'));   % Private Creator
    tag1010  = bitor(bitshift(grp,16), hex2dec('1010'));   % JSON payload (VR=UN)
    tag1011  = bitor(bitshift(grp,16), hex2dec('1011'));   % short text 

    % Private Creator 
    info.Private_0029_0010 = char( dataset.getString(tag0010, '') );

    % JSON payload lives in a VR=UN tag 
    rawBytes = dataset.getBytes(tag1010);
    if isempty(rawBytes)
        info.Private_0029_1010 = '';
    else
        % Java byte[] → MATLAB int8 array
        mb = int8(rawBytes);
        % reinterpret as uint8 0–255
        ub = typecast(mb, 'uint8');
        % turn into a row char vector
        info.Private_0029_1010 = char(ub(:)') ;
    end

    % 3DF Annotation string is short (VR=LO)
    rawBytes1011 = dataset.getBytes(tag1011);
    if isempty(rawBytes1011)
        info.Private_0029_1011 = '';
    else
        mb1 = int8(rawBytes1011);
        ub1 = typecast(mb1,'uint8');
        txt1011 = char(ub1(:)');
        info.Private_0029_1011 = regexprep(txt1011,'[\x00]+$','');
    end
     %    E3 = info.EnergyWindowInformationSequence.Item_3.EnergyWindowRangeSequence.Item_1;

%    info.din.rows       = info.Rows;
%    info.din.cols       = info.Columns;  
    
%        info.din.nbOfFrames = dataset.getInt(org.dcm4che3.data.Tag.NumberOfFrames,0);
%     info.din = [];

    info.NumberOfSlices = dataset.getInt(org.dcm4che3.data.Tag.NumberOfSlices,0);
    info.NumberOfTemporalPositions = dataset.getInt(org.dcm4che3.data.Tag.NumberOfTemporalPositions,0);

    % Dose

    info.DoseUnits                     = char(dataset.getString(org.dcm4che3.data.Tag.DoseUnits, 0));
    info.DoseType                      = char(dataset.getString(org.dcm4che3.data.Tag.DoseType, 0));
    info.DoseSummationType             = char(dataset.getString(org.dcm4che3.data.Tag.DoseSummationType, 0));
    info.GridFrameOffsetVector         = dataset.getDoubles(org.dcm4che3.data.Tag.GridFrameOffsetVector);
    info.DoseGridScaling               = dataset.getDoubles(org.dcm4che3.data.Tag.DoseGridScaling);
    info.TissueHeterogeneityCorrection = char(dataset.getString(org.dcm4che3.data.Tag.TissueHeterogeneityCorrection, 0));

    din.close();

end   