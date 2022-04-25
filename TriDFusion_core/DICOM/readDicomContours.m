function tContours = readDicomContours(sFileName)
%function tContours = readDicomContours(sFileName)
%Return a structure of the dicom contours.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2021, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    rtssheader = dicominfo(char(sFileName));    
    tContours  = readRTstructures(rtssheader);

    function tContours = readRTstructures(rtssheader)

        ROIContourSequence = fieldnames(rtssheader.ROIContourSequence);
        tContours = struct('Number', {}, 'ROIName', {}, 'ContourData', {}, 'Color', {},  'Referenced', {});
        
        for i = 1:length(ROIContourSequence) % Loop through contours

            if isfield(rtssheader.ROIContourSequence.(ROIContourSequence{i}), 'ContourSequence')
                tContours(i).Number = i;

                tContours(i).ROIName = rtssheader.StructureSetROISequence.(ROIContourSequence{i}).ROIName;

                ContourSequence = fieldnames(rtssheader.ROIContourSequence.(ROIContourSequence{i}).ContourSequence);

                % Loop through segments (slices)
                aSegments = cell(1,length(ContourSequence));
                for j = 1:length(ContourSequence)
                    if strcmpi(rtssheader.ROIContourSequence.(ROIContourSequence{i}).ContourSequence.(ContourSequence{j}).ContourGeometricType, 'CLOSED_PLANAR')

                        if ~isempty(rtssheader.ROIContourSequence.(ROIContourSequence{i}).ContourSequence.(ContourSequence{j}).ContourData)
                            % Read points
                            aSegments{j} = reshape(rtssheader.ROIContourSequence.(ROIContourSequence{i}).ContourSequence.(ContourSequence{j}).ContourData, ...
                                3, rtssheader.ROIContourSequence.(ROIContourSequence{i}).ContourSequence.(ContourSequence{j}).NumberOfContourPoints)';

                            if isfield(rtssheader.ROIContourSequence.(ROIContourSequence{i}).ContourSequence.(ContourSequence{j}), 'ContourImageSequence')
                                tContours(i).Referenced.SOP(j).SOPClassUID    = rtssheader.ROIContourSequence.(ROIContourSequence{i}).ContourSequence.(ContourSequence{j}).ContourImageSequence.Item_1.ReferencedSOPClassUID;
                                tContours(i).Referenced.SOP(j).SOPInstanceUID = rtssheader.ROIContourSequence.(ROIContourSequence{i}).ContourSequence.(ContourSequence{j}).ContourImageSequence.Item_1.ReferencedSOPInstanceUID;
                            else
                                tContours(i).Referenced.SOP(j).SOPClassUID    = rtssheader.SOPClassUID;
                                tContours(i).Referenced.SOP(j).SOPInstanceUID = rtssheader.SOPInstanceUID;
                            end
                        end
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
   
end