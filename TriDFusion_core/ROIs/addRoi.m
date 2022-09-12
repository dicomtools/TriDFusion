function addRoi(ptrRoi, dOffset, sLesionType)
%function addRoi(ptrRoi, dOffset, sLesionType)
%Add ROI to input template.
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

    iCurrentOffset = get(uiSeriesPtr('get'), 'Value');
    if dOffset > numel(tAddInput)
        return;
    end

    if iCurrentOffset == dOffset
        atDicomInfo = dicomMetaData('get');
        imRoi = dicomBuffer('get');
    else
        atDicomInfo = tAddInput(dOffset).atDicomInfo;

        aInput = inputBuffer('get');
        imRoi  = aInput{dOffset};
    end

    atRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

    addlistener(ptrRoi, 'DeletingROI', @deleteRoiEvents );
    addlistener(ptrRoi, 'ROIMoved'   , @movedRoiEvents  );

    sSOPClassUID    = '';
    sSOPInstanceUID = '';
    sFrameOfReferenceUID = '';

    if size(dicomBuffer('get'), 3) ~= 1 && ...
       switchTo3DMode('get')     == false && ...
       switchToIsoSurface('get') == false && ...
       switchToMIPMode('get')    == false

        switch get(ptrRoi, 'Parent')
            
            case axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))                   
                dSliceNb = sliceNumber('get', 'coronal' );
                sAxe = 'Axes1';
                
            case axes1rPtr('get', [], get(uiSeriesPtr('get'), 'Value'))  
                dSliceNb = sliceNumber('get', 'coronal' );
                sAxe = 'Axes1'; 
                
            case axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
                dSliceNb = sliceNumber('get', 'sagittal');
                sAxe = 'Axes2';
                
            case axes2rPtr('get', [], get(uiSeriesPtr('get'), 'Value'))
                dSliceNb = sliceNumber('get', 'sagittal');
                sAxe = 'Axes2';
                
            otherwise
                dSliceNb = sliceNumber('get', 'axial');
                sAxe = 'Axes3';

                if numel(atDicomInfo) >= dSliceNb
                    sSOPClassUID         = atDicomInfo{dSliceNb}.SOPClassUID;
                    sSOPInstanceUID      = atDicomInfo{dSliceNb}.SOPInstanceUID;
                    sFrameOfReferenceUID = atDicomInfo{dSliceNb}.FrameOfReferenceUID;
                else
                    sSOPClassUID         = atDicomInfo{1}.SOPClassUID;
                    sSOPInstanceUID      = atDicomInfo{1}.SOPInstanceUID;
                    sFrameOfReferenceUID = atDicomInfo{1}.FrameOfReferenceUID;
                end

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
    tRoi.Type                = ptrRoi.Type;
    tRoi.Position            = ptrRoi.Position;
    tRoi.Label               = ptrRoi.Label;
    tRoi.LabelVisible        = ptrRoi.LabelVisible;
    tRoi.Color               = ptrRoi.Color;
    tRoi.LineWidth           = ptrRoi.LineWidth;
    tRoi.Tag                 = ptrRoi.Tag;
    tRoi.ObjectType          = 'roi';
    tRoi.LesionType          = sLesionType;

    switch lower(tRoi.Type)
        case lower('images.roi.line')

        case { lower('images.roi.freehand'), ...
               lower('images.roi.assistedfreehand') }
            tRoi.FaceAlpha      = ptrRoi.FaceAlpha;
            tRoi.Waypoints      = ptrRoi.Waypoints;
            tRoi.FaceSelectable = ptrRoi.FaceSelectable;
            tRoi.Smoothing      = ptrRoi.Smoothing;

            addlistener(ptrRoi, 'WaypointAdded'  , @waypointEvents);
            addlistener(ptrRoi, 'WaypointRemoved', @waypointEvents);

        case lower('images.roi.polygon')
            tRoi.FaceAlpha      = ptrRoi.FaceAlpha;
            tRoi.FaceSelectable = ptrRoi.FaceSelectable;

        case lower('images.roi.circle')
            tRoi.FaceAlpha      = ptrRoi.FaceAlpha;
            tRoi.Radius         = ptrRoi.Radius;
            tRoi.FaceSelectable = ptrRoi.FaceSelectable;
            tRoi.Vertices       = ptrRoi.Vertices;

        case lower('images.roi.ellipse')
            tRoi.FaceAlpha      = ptrRoi.FaceAlpha;
            tRoi.SemiAxes       = ptrRoi.SemiAxes;
            tRoi.RotationAngle  = ptrRoi.RotationAngle;
            tRoi.FaceSelectable = ptrRoi.FaceSelectable;
            tRoi.Vertices       = ptrRoi.Vertices;
            
        case lower('images.roi.rectangle')
            tRoi.FaceAlpha      = ptrRoi.FaceAlpha;
            tRoi.FaceSelectable = ptrRoi.FaceSelectable;
            tRoi.Rotatable      = ptrRoi.Rotatable;
            tRoi.RotationAngle  = ptrRoi.RotationAngle;
            tRoi.Vertices       = ptrRoi.Vertices;
    end

    tRoi.Object = ptrRoi;

    tMaxDistances = computeRoiFarthestPoint(imRoi, atDicomInfo, tRoi, false, false);
    tRoi.MaxDistances = tMaxDistances;

    if isfield( tAddInput(dOffset), 'tRoi' )
        tAddInput(dOffset).tRoi{numel(tAddInput(dOffset).tRoi)+1} = tRoi;
    else
        tAddInput(dOffset).tRoi{1} = tRoi;
    end

    if isempty(atRoiInput)
        atRoiInput{1} = tRoi;
    else
        atRoiInput{numel(atRoiInput)+1} = tRoi;
    end

    inputTemplate('set', tAddInput);

    roiTemplate('set', get(uiSeriesPtr('get'), 'Value'), atRoiInput);

end
