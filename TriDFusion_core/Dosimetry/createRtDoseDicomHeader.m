function atRtDoseHeader = createRtDoseDicomHeader(aRtDoseImage, atSeriesHeader, dSeriesOffset)

    atRtDoseHeader{1}.TransferSyntaxUID = '1.2.840.10008.1.2.1';

    atRtDoseHeader{1}.Rows    = atSeriesHeader{1}.Rows;
    atRtDoseHeader{1}.Columns = atSeriesHeader{1}.Columns;

    atRtDoseHeader{1}.ImplementationVersionName    = 'TRIDFUSION';
    atRtDoseHeader{1}.SourceApplicationEntityTitle = 'TRIDFUSION';

    sCreationDate = datestr(now, 'yyyymmdd');
    sCreationTime = datestr(now,'HHMMSS.FFF');

    atRtDoseHeader{1}.InstanceCreationDate = sCreationDate;
    atRtDoseHeader{1}.InstanceCreationTime = sCreationTime;

    atRtDoseHeader{1}.StudyDate       = atSeriesHeader{1}.StudyDate;
    atRtDoseHeader{1}.SeriesDate      = atSeriesHeader{1}.SeriesDate;
    atRtDoseHeader{1}.AcquisitionDate = atSeriesHeader{1}.AcquisitionDate;
    atRtDoseHeader{1}.ContentDate     = sCreationDate;
    atRtDoseHeader{1}.StudyTime       = atSeriesHeader{1}.StudyTime;
    atRtDoseHeader{1}.SeriesTime      = atSeriesHeader{1}.SeriesTime;
    atRtDoseHeader{1}.AcquisitionTime = atSeriesHeader{1}.AcquisitionTime;
    atRtDoseHeader{1}.ContentTime     = sCreationTime;
    
    atRtDoseHeader{1}.AccessionNumber = atSeriesHeader{1}.AccessionNumber;
    atRtDoseHeader{1}.Modality = 'RTDOSE';


    aDoseImageSize = size(aRtDoseImage);

    atRtDoseHeader{1}.Rows    = aDoseImageSize(2);
    atRtDoseHeader{1}.Columns = aDoseImageSize(1);

    atRtDoseHeader{1}.PixelSpacing        = atSeriesHeader{1}.PixelSpacing;
    atRtDoseHeader{1}.BitsAllocated       = 32;
    atRtDoseHeader{1}.BitsStored          = 32;
    atRtDoseHeader{1}.HighBit             = 31;
    atRtDoseHeader{1}.PixelRepresentation = 0;
    atRtDoseHeader{1}.DoseUnits           = 'Gy';
    atRtDoseHeader{1}.DoseType            = 'PHYSICAL';
    atRtDoseHeader{1}.Units               = [];

    atRtDoseHeader{1}.SamplesPerPixel           = 1;
    atRtDoseHeader{1}.PhotometricInterpretation = 'MONOCHROME2';

    atRtDoseHeader{1}.NumberOfFrames = aDoseImageSize(3);  

    atRtDoseHeader{1}.FrameIncrementPointer = zeros(1,2);
    atRtDoseHeader{1}.FrameIncrementPointer(1, 1) = 12292;
    atRtDoseHeader{1}.FrameIncrementPointer(1, 2) = 12;
    
    atRtDoseHeader{1}.DoseSummationType = '';

    adGridFrameOffsetVector = zeros(aDoseImageSize(3),1);

    dOffset = computeSliceSpacing(atSeriesHeader);

    adGridFrameOffsetVector(1,1)=0;
    for aa=2:aDoseImageSize(3)
        adGridFrameOffsetVector(aa,1) = (aa-1)*dOffset;
    end

    atRtDoseHeader{1}.GridFrameOffsetVector = adGridFrameOffsetVector;

%     atRtDoseHeader{1}.DoseGridScaling: 0.0460;

    dTrueMin = min(aRtDoseImage, [],'all');
    dTrueMax = max(aRtDoseImage, [],'all');
    dTrueRange = dTrueMax-dTrueMin;
    dDoseGridScaling = dTrueRange/65535;
    atRtDoseHeader{1}.DoseGridScaling = dDoseGridScaling;

    atRtDoseHeader{1}.TissueHeterogeneityCorrection = 'IMAGE';

    atRtDoseHeader{1}.Manufacturer           = atSeriesHeader{1}.Manufacturer;
    atRtDoseHeader{1}.InstitutionName        = atSeriesHeader{1}.InstitutionName;
    atRtDoseHeader{1}.ReferringPhysicianName = atSeriesHeader{1}.ReferringPhysicianName;
    atRtDoseHeader{1}.StationName            = atSeriesHeader{1}.StationName;
    atRtDoseHeader{1}.StudyDescription       = atSeriesHeader{1}.StudyDescription;
    atRtDoseHeader{1}.SeriesDescription      = sprintf('%s 3DF DOSEMAP',  atSeriesHeader{1}.SeriesDescription);
    atRtDoseHeader{1}.ManufacturerModelName  = atSeriesHeader{1}.ManufacturerModelName;

    atRtDoseHeader{1}.DerivationDescription = 'Converted image data';

    atRtDoseHeader{1}.PatientName           = atSeriesHeader{1}.PatientName;
    atRtDoseHeader{1}.PatientID             = atSeriesHeader{1}.PatientID;
    atRtDoseHeader{1}.PatientBirthDate      = atSeriesHeader{1}.PatientBirthDate;
    atRtDoseHeader{1}.PatientSex            = atSeriesHeader{1}.PatientSex;
    atRtDoseHeader{1}.PatientAge            = atSeriesHeader{1}.PatientAge;
    atRtDoseHeader{1}.PatientWeight         = atSeriesHeader{1}.PatientWeight;
    atRtDoseHeader{1}.PatientSize           = atSeriesHeader{1}.PatientSize;

    atRtDoseHeader{1}.StudyInstanceUID    = atSeriesHeader{1}.StudyInstanceUID;
    atRtDoseHeader{1}.SeriesInstanceUID   = dicomuid;
    atRtDoseHeader{1}.StudyID             = atSeriesHeader{1}.StudyID;

%     if getImagePosition(dSeriesOffset) == false
%         aImagePositionPatient = atSeriesHeader{end}.ImagePositionPatient;
%     else
%         aImagePositionPatient = atSeriesHeader{1}.ImagePositionPatient;
%     end

    atRtDoseHeader{1}.SeriesNumber   = [];
    atRtDoseHeader{1}.InstanceNumber = [];
    atRtDoseHeader{1}.ImagePositionPatient    = atSeriesHeader{end}.ImagePositionPatient;
    atRtDoseHeader{1}.ImageOrientationPatient = atSeriesHeader{1}.ImageOrientationPatient;
    atRtDoseHeader{1}.FrameOfReferenceUID     = atSeriesHeader{1}.FrameOfReferenceUID;

    atRtDoseHeader{1}.MediaStorageSOPClassUID    = '1.2.840.10008.5.1.4.1.1.481.2';
    atRtDoseHeader{1}.MediaStorageSOPInstanceUID = '1.2.752.37.54.2728.173529256568938809430198472177006276718';
    atRtDoseHeader{1}.TransferSyntaxUID          = '1.2.840.10008.1.2.1';
    atRtDoseHeader{1}.ImplementationClassUID     = '1.2.752.37.54.2728.124.87.88.205.83.159';

    atRtDoseHeader{1}.InstanceCreatorUID = '1.2.752.37.54.2728.124.87.88.205.83.159';
    atRtDoseHeader{1}.SOPClassUID        = '1.2.840.10008.5.1.4.1.1.481.2';
    atRtDoseHeader{1}.SOPInstanceUID     = '1.2.752.37.54.2728.173529256568938809430198472177006276718';

end