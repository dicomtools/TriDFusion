function addContourToTemplate(dSeriesOffset, sAxe, dSliceNb, sType, aPosition, sLabel, sLabelVisible, aColor, dLineWidth, dFaceAlpha, dFaceSelectable, dSmoothing, sTag, sLesionType)
%function addContourToTemplate(dSeriesOffset, sAxe, dSliceNb, sType, aPosition, sLabel, sLabelVisible, aColor, dLineWidth, dFaceAlpha, dFaceSelectable, dSmoothing, sTag, sLesionType)
%Add contour to input template.
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

    tAddInput = inputTemplate('get');
    aBuffer   = inputBuffer('get');
    
    imRoi = aBuffer{dSeriesOffset};

    atDicomInfo = tAddInput(dSeriesOffset).atDicomInfo;

    atRoiInput = roiTemplate('get', dSeriesOffset);

    if size(imRoi, 3) ~= 1 

        if strcmpi(sAxe, 'Axes3')

            if numel(atDicomInfo) >= dSliceNb
                sSOPClassUID         = atDicomInfo{dSliceNb}.SOPClassUID;
                sSOPInstanceUID      = atDicomInfo{dSliceNb}.SOPInstanceUID;
                sFrameOfReferenceUID = atDicomInfo{dSliceNb}.FrameOfReferenceUID;
            else
                sSOPClassUID         = atDicomInfo{1}.SOPClassUID;
                sSOPInstanceUID      = atDicomInfo{1}.SOPInstanceUID;
                sFrameOfReferenceUID = atDicomInfo{1}.FrameOfReferenceUID;
            end
        else
            progressBar( 1, 'Error: addContourToTemplate() only support Axes3!');  
            return;
        end
    else
        sSOPClassUID         = atDicomInfo{1}.SOPClassUID;
        sSOPInstanceUID      = atDicomInfo{1}.SOPInstanceUID;
        sFrameOfReferenceUID = atDicomInfo{1}.FrameOfReferenceUID;         
        
        dSliceNb = 1;
        sAxe = 'Axe';
    end

    tRoi.Axe                 = sAxe;
    tRoi.SliceNb             = dSliceNb;
    tRoi.SOPClassUID         = sSOPClassUID;
    tRoi.SOPInstanceUID      = sSOPInstanceUID;
    tRoi.FrameOfReferenceUID = sFrameOfReferenceUID;
    tRoi.Type                = sType;
    tRoi.Position            = aPosition;
    tRoi.Label               = sLabel;
    tRoi.LabelVisible        = sLabelVisible;
    tRoi.Color               = aColor;
    tRoi.LineWidth           = dLineWidth;
    tRoi.FaceAlpha           = dFaceAlpha;
    tRoi.FaceSelectable      = dFaceSelectable;
    tRoi.Smoothing           = dSmoothing;
    tRoi.Waypoints           = [];    
    tRoi.Tag                 = sTag;    
    tRoi.ObjectType          = 'roi';
    tRoi.LesionType          = sLesionType;
    tRoi.StripeColor         = 'none';
    tRoi.InteractionsAllowed = 'all';    
    tRoi.Deletable           = 1;
    tRoi.UserData            = [];
    
    % tMaxDistances     = computeRoiFarthestPoint(imRoi, atDicomInfo, tRoi, false, false);
    % tRoi.MaxDistances = tMaxDistances;

    if isempty(atRoiInput)
        atRoiInput{1} = tRoi;
    else
        atRoiInput{numel(atRoiInput)+1} = tRoi;
    end

    roiTemplate('set', dSeriesOffset, atRoiInput);

end
