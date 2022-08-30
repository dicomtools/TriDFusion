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

    try 
        din = org.dcm4che.io.DicomInputStream(...
                java.io.BufferedInputStream(java.io.FileInputStream(char(fileInput))));    
            
        dataset = din.readDataset(-1, -1);                  
    catch 
        try 
        info = dicominfo(char(fileInput)); 
        catch
            info = [];
        end
        return;
    end  


    % Patient information

    info.PatientName        = char(dataset.getString(org.dcm4che.data.Tag.PatientName, 0));
    info.PatientID          = char(dataset.getString(org.dcm4che.data.Tag.PatientID, 0));
    info.SeriesDescription  = char(dataset.getString(org.dcm4che.data.Tag.SeriesDescription, 0));

    info.Modality  = char(dataset.getStrings(org.dcm4che.data.Tag.Modality));        

    info.InstanceNumber  = dataset.getInt(org.dcm4che.data.Tag.InstanceNumber, 0);

    info.PatientPosition         = char(dataset.getStrings(org.dcm4che.data.Tag.PatientPosition));      
    info.ImagePositionPatient    = dataset.getDoubles(org.dcm4che.data.Tag.ImagePositionPatient);
    info.ImageOrientationPatient = dataset.getDoubles(org.dcm4che.data.Tag.ImageOrientationPatient);
    
    if isempty(info.ImagePositionPatient) 
        datasetDetector = dataset.getNestedDataset(org.dcm4che.data.Tag.DetectorInformationSequence); % NM
        if ~isempty(datasetDetector)
            info.ImagePositionPatient = datasetDetector.getDoubles(org.dcm4che.data.Tag.ImagePositionPatient);
            if isempty(info.ImagePositionPatient) 
                info.ImagePositionPatient = zeros(3,1);
            end
        else
            info.ImagePositionPatient = zeros(3,1);
        end
    end
    
    if isempty(info.ImageOrientationPatient) 
        datasetDetector = dataset.getNestedDataset(org.dcm4che.data.Tag.DetectorInformationSequence); % NM
        if ~isempty(datasetDetector)         
            info.ImageOrientationPatient = datasetDetector.getDoubles(org.dcm4che.data.Tag.ImageOrientationPatient);      
            if isempty(info.ImageOrientationPatient)         
                info.ImageOrientationPatient = zeros(6,1);
            end
        else
            info.ImageOrientationPatient = zeros(6,1);
        end
    end
    
    info.SeriesDate = char(dataset.getString(org.dcm4che.data.Tag.SeriesDate, 0));
    info.StudyDate  = char(dataset.getString(org.dcm4che.data.Tag.StudyDate , 0));

    info.SeriesTime = char(dataset.getString(org.dcm4che.data.Tag.SeriesTime, 0));
    info.StudyTime  = char(dataset.getString(org.dcm4che.data.Tag.StudyTime , 0));

    info.SeriesType{1} = char(dataset.getString(org.dcm4che.data.Tag.SeriesType, 0));
    info.SeriesType{2} = char(dataset.getString(org.dcm4che.data.Tag.SeriesType, 1));

    info.AcquisitionTime  = char(dataset.getString(org.dcm4che.data.Tag.AcquisitionTime, 0));
    info.AcquisitionDate  = char(dataset.getString(org.dcm4che.data.Tag.AcquisitionDate , 0));                     

    info.SeriesInstanceUID = char(dataset.getString(org.dcm4che.data.Tag.SeriesInstanceUID, 0));
    info.StudyInstanceUID  = char(dataset.getString(org.dcm4che.data.Tag.StudyInstanceUID, 0));
    
    info.SOPClassUID             = char(dataset.getString(org.dcm4che.data.Tag.SOPClassUID, 0));
    info.MediaStorageSOPClassUID = char(dataset.getString(org.dcm4che.data.Tag.MediaStorageSOPClassUID, 0));
    info.SOPInstanceUID          = char(dataset.getString(org.dcm4che.data.Tag.SOPInstanceUID, 0));
    info.FrameOfReferenceUID     = char(dataset.getString(org.dcm4che.data.Tag.FrameOfReferenceUID, 0));    
    
    info.AccessionNumber   = char(dataset.getString(org.dcm4che.data.Tag.AccessionNumber, 0));

    info.ActualFrameDuration = dataset.getInt(org.dcm4che.data.Tag.ActualFrameDuration,0);

    info.Rows    = dataset.getInt(org.dcm4che.data.Tag.Rows, 0);
    info.Columns = dataset.getInt(org.dcm4che.data.Tag.Columns,0);

    info.RescaleSlope     = dataset.getFloat(org.dcm4che.data.Tag.RescaleSlope,0);        
    info.RescaleIntercept = dataset.getFloat(org.dcm4che.data.Tag.RescaleIntercept,0);        

    info.SliceLocation  = dataset.getFloat(org.dcm4che.data.Tag.SliceLocation, 0);
    info.ReconstructionDiameter = dataset.getFloat(org.dcm4che.data.Tag.ReconstructionDiameter,0);
    info.SliceThickness         = dataset.getFloat(org.dcm4che.data.Tag.SliceThickness,0);
    info.SpacingBetweenSlices   = dataset.getFloat(org.dcm4che.data.Tag.SpacingBetweenSlices,0);
    info.PixelSpacing           = dataset.getDoubles(org.dcm4che.data.Tag.PixelSpacing);
    if isempty(info.PixelSpacing) 
        info.PixelSpacing = zeros(2,1);
    end
         
    info.PatientWeight    = dataset.getFloat(org.dcm4che.data.Tag.PatientWeight, 0);
    info.PatientSize      = dataset.getFloat(org.dcm4che.data.Tag.PatientSize, 0);
    info.PatientSex       = char(dataset.getString(org.dcm4che.data.Tag.PatientSex, 0));
    info.PatientAge       = char(dataset.getString(org.dcm4che.data.Tag.PatientAge, 0));
    info.PatientBirthDate = char(dataset.getString(org.dcm4che.data.Tag.PatientBirthDate, 0));
    
    % Manifacturer & protocol information

    info.ManufacturerModelName = char(dataset.getString(org.dcm4che.data.Tag.ManufacturerModelName, 0));
    info.ProtocolName          = char(dataset.getString(org.dcm4che.data.Tag.ProtocolName, 0)); 
    
    % Dose information
    
    datasetDose = dataset.getNestedDataset(org.dcm4che.data.Tag.RadiopharmaceuticalInformationSequence, 0);
    if ~isempty(datasetDose)
        % RadiopharmaceuticalInformationSequence
        info.RadiopharmaceuticalInformationSequence.Item_1.Radiopharmaceutical              = char(datasetDose.getString(org.dcm4che.data.Tag.Radiopharmaceutical, 0));
        info.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartTime     = char(datasetDose.getString(org.dcm4che.data.Tag.RadiopharmaceuticalStartTime, 0));
        info.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStopTime      = char(datasetDose.getString(org.dcm4che.data.Tag.RadiopharmaceuticalStopTime, 0));
        info.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideTotalDose            = char(datasetDose.getString(org.dcm4che.data.Tag.RadionuclideTotalDose, 0));
        info.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideHalfLife             = char(datasetDose.getString(org.dcm4che.data.Tag.RadionuclideHalfLife, 0));
        info.RadiopharmaceuticalInformationSequence.Item_1.RadionuclidePositronFraction     = char(datasetDose.getString(org.dcm4che.data.Tag.RadionuclidePositronFraction, 0));
        info.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartDateTime = char(datasetDose.getString(org.dcm4che.data.Tag.RadiopharmaceuticalStartDateTime, 0));
        info.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStopDateTime  = char(datasetDose.getString(org.dcm4che.data.Tag.RadiopharmaceuticalStopDateTime, 0));
        
        % RadiopharmaceuticalCodeSequence
        
        datasetRadiopharmaceutical = datasetDose.getNestedDataset(org.dcm4che.data.Tag.RadiopharmaceuticalCodeSequence, 0);        
        if ~isempty(datasetRadiopharmaceutical)
            
            info.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalCodeSequence.Item_1.CodeValue = ...
                char(datasetRadiopharmaceutical.getString(org.dcm4che.data.Tag.CodeValue, 0));

            info.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalCodeSequence.Item_1.CodingSchemeDesignator = ...
                char(datasetRadiopharmaceutical.getString(org.dcm4che.data.Tag.CodingSchemeDesignator, 0));

            info.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalCodeSequence.Item_1.CodeMeaning = ...
                char(datasetRadiopharmaceutical.getString(org.dcm4che.data.Tag.CodeMeaning, 0));
        else
            info.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalCodeSequence.Item_1.CodeValue = '';
            info.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalCodeSequence.Item_1.CodingSchemeDesignator = '';
            info.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalCodeSequence.Item_1.CodeMeaning = '';
        end
        
        % RadionuclideCodeSequence
        
        datasetRadionuclide = datasetDose.getNestedDataset(org.dcm4che.data.Tag.RadionuclideCodeSequence, 0);
        if ~isempty(datasetRadionuclide)
        
            info.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideCodeSequence.Item_1.CodeValue = ...
                char(datasetRadionuclide.getString(org.dcm4che.data.Tag.CodeValue, 0));

            info.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideCodeSequence.Item_1.CodingSchemeDesignator ...
                = char(datasetRadionuclide.getString(org.dcm4che.data.Tag.CodingSchemeDesignator, 0));

            info.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideCodeSequence.Item_1.CodeMeaning ...
                = char(datasetRadionuclide.getString(org.dcm4che.data.Tag.CodeMeaning, 0));        
        else
            info.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideCodeSequence.Item_1.CodeValue = '';
            info.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideCodeSequence.Item_1.CodingSchemeDesignator = '';
            info.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideCodeSequence.Item_1.CodeMeaning = '';
        end
    end
    
    % Real World Value (SUV SPECT)
    
    realWorldValue = dataset.getNestedDataset(org.dcm4che.data.Tag.RealWorldValueMappingSequence, 0);
    if ~isempty(realWorldValue)    
         measurementUnits = realWorldValue.getNestedDataset(org.dcm4che.data.Tag.MeasurementUnitsCodeSequence, 0);
         if ~isempty(measurementUnits)    
            info.RealWorldValueMappingSequence.Item_1.MeasurementUnitsCodeSequence.Item_1.CodeValue              = char(measurementUnits.getString(org.dcm4che.data.Tag.CodeValue, 0));
            info.RealWorldValueMappingSequence.Item_1.MeasurementUnitsCodeSequence.Item_1.CodingSchemeDesignator = char(measurementUnits.getString(org.dcm4che.data.Tag.CodingSchemeDesignator, 0));
            info.RealWorldValueMappingSequence.Item_1.MeasurementUnitsCodeSequence.Item_1.CodeMeaning            = char(measurementUnits.getString(org.dcm4che.data.Tag.CodeMeaning, 0));
         end
         info.RealWorldValueMappingSequence.Item_1.RealWorldValueLastValueMapped  = realWorldValue.getFloat(org.dcm4che.data.Tag.RealWorldValueLastValueMapped, 0);
         info.RealWorldValueMappingSequence.Item_1.RealWorldValueFirstValueMapped = realWorldValue.getFloat(org.dcm4che.data.Tag.RealWorldValueFirstValueMapped, 0);
         info.RealWorldValueMappingSequence.Item_1.RealWorldValueIntercept        = realWorldValue.getFloat(org.dcm4che.data.Tag.RealWorldValueIntercept, 0);
         info.RealWorldValueMappingSequence.Item_1.RealWorldValueSlope            = realWorldValue.getFloat(org.dcm4che.data.Tag.RealWorldValueSlope, 0);               
    end
    
    info.Units = char(dataset.getString(org.dcm4che.data.Tag.Units, 0));        
    info.DecayCorrection = char(dataset.getString(org.dcm4che.data.Tag.DecayCorrection, 0));        

    info.MRAcquisitionType = char(dataset.getString(org.dcm4che.data.Tag.MRAcquisitionType, 0));
    
    % Image information

    info.BitsAllocated = dataset.getInt(org.dcm4che.data.Tag.BitsAllocated, 0);
    info.BitsStored    = dataset.getInt(org.dcm4che.data.Tag.BitsStored, 0);
    info.HighBit       = dataset.getInt(org.dcm4che.data.Tag.HighBit, 0);

%    if info.HighBit == info.BitsStored -1 % 16 bits
%        info.din.pixeldata  = uint16(dataset.getInts(org.dcm4che.data.Tag.PixelData));
%    else
        info.din.pixeldata  = dataset.getInts(org.dcm4che.data.Tag.PixelData);
%    end

    info.din.rows       = dataset.getInt(org.dcm4che.data.Tag.Rows, 0);
    info.din.cols       = dataset.getInt(org.dcm4che.data.Tag.Columns,0);                                                           
%        info.din.nbOfFrames = dataset.getInt(org.dcm4che.data.Tag.NumberOfFrames,0);
    info.NumberOfSlices = dataset.getInt(org.dcm4che.data.Tag.NumberOfSlices,0);
    info.NumberOfTemporalPositions = dataset.getInt(org.dcm4che.data.Tag.NumberOfTemporalPositions,0);

    din.close();

end   