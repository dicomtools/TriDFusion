function tContours = readDicomContours(sFileName)
      
    rtssheader = dicominfo(char(sFileName));    
    tContours  = readRTstructures(rtssheader);

    function tContours = readRTstructures(rtssheader)

        ROIContourSequence = fieldnames(rtssheader.ROIContourSequence);
        tContours = struct('Number', {}, 'ROIName', {}, 'ContourData', {}, 'Color', {},  'Referenced', {});
        
        for i = 1:length(ROIContourSequence) % Loop through contours

            tContours(i).Number = i;

            tContours(i).ROIName = rtssheader.StructureSetROISequence.(ROIContourSequence{i}).ROIName;

            ContourSequence = fieldnames(rtssheader.ROIContourSequence.(ROIContourSequence{i}).ContourSequence);

            % Loop through segments (slices)
            aSegments = cell(1,length(ContourSequence));
            for j = 1:length(ContourSequence)
                if strcmpi(rtssheader.ROIContourSequence.(ROIContourSequence{i}).ContourSequence.(ContourSequence{j}).ContourGeometricType, 'CLOSED_PLANAR')
                    % Read points
                    aSegments{j} = reshape(rtssheader.ROIContourSequence.(ROIContourSequence{i}).ContourSequence.(ContourSequence{j}).ContourData, ...
                        3, rtssheader.ROIContourSequence.(ROIContourSequence{i}).ContourSequence.(ContourSequence{j}).NumberOfContourPoints)';
                    
                    tContours(i).Referenced.SOP(j).SOPClassUID    = rtssheader.ROIContourSequence.(ROIContourSequence{i}).ContourSequence.(ContourSequence{j}).ContourImageSequence.Item_1.ReferencedSOPClassUID;
                    tContours(i).Referenced.SOP(j).SOPInstanceUID = rtssheader.ROIContourSequence.(ROIContourSequence{i}).ContourSequence.(ContourSequence{j}).ContourImageSequence.Item_1.ReferencedSOPInstanceUID;
                else
                    progressBar(1, 'Error: RT structure Geometric Type not supported');                
                end

            end

            tContours(i).GeometricType = rtssheader.ROIContourSequence.(ROIContourSequence{i}).ContourSequence.(ContourSequence{j}).ContourGeometricType;
            tContours(i).ContourData   = aSegments;    
            tContours(i).Color = rtssheader.ROIContourSequence.(ROIContourSequence{i}).ROIDisplayColor;    
     
            tContours(i).Referenced.StudyInstanceUID  = rtssheader.StudyInstanceUID;
            tContours(i).Referenced.SeriesInstanceUID = rtssheader.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.SeriesInstanceUID;

        end
        
    end
   
end