function addRoi(ptrRoi, iOffset)
%function addRoi(ptrRoi, iOffset)
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
%    iOffset = get(uiSeriesPtr('get'), 'Value');
    if iOffset > numel(tAddInput)  
        return;
    end
    
    atRoiInput = roiTemplate('get');

    addlistener(ptrRoi, 'DeletingROI', @deleteRoiEvents );
    addlistener(ptrRoi, 'ROIMoved'   , @movedRoiEvents  );

    if size(dicomBuffer('get'), 3) ~= 1 && ...
       switchTo3DMode('get')     == false && ...
       switchToIsoSurface('get') == false && ...
       switchToMIPMode('get')    == false

        switch get(ptrRoi, 'Parent')
            case axes1Ptr('get')   
                dSliceNb = sliceNumber('get', 'coronal' );
                sAxe = 'Axes1';
            case axes2Ptr('get')                   
                dSliceNb = sliceNumber('get', 'sagittal');
                sAxe = 'Axes2';
            otherwise                 
                dSliceNb = sliceNumber('get', 'axial'   );
                sAxe = 'Axes3';
        end
     else
        dSliceNb = 1;
        sAxe = 'Axe';
    end

    tRoi.Axe          = sAxe;
    tRoi.SliceNb      = dSliceNb;
    tRoi.Type         = ptrRoi.Type;
    tRoi.Position     = ptrRoi.Position;
    tRoi.Label        = ptrRoi.Label;
    tRoi.LabelVisible = ptrRoi.LabelVisible;
    tRoi.Color        = ptrRoi.Color;
    tRoi.LineWidth    = ptrRoi.LineWidth;
    tRoi.Tag          = ptrRoi.Tag; 
    tRoi.ObjectType   = 'roi'; 

    switch lower(tRoi.Type)
        case lower('images.roi.line')

        case { lower('images.roi.freehand'), ...
               lower('images.roi.assistedfreehand') }
            tRoi.FaceAlpha = ptrRoi.FaceAlpha;
            tRoi.Waypoints = ptrRoi.Waypoints;
            tRoi.FaceSelectable = ptrRoi.FaceSelectable; 
            
            addlistener(ptrRoi, 'WaypointAdded'  , @waypointEvents);
            addlistener(ptrRoi, 'WaypointRemoved', @waypointEvents);

        case lower('images.roi.polygon')
            tRoi.FaceAlpha = ptrRoi.FaceAlpha;
            tRoi.FaceSelectable = ptrRoi.FaceSelectable; 

        case lower('images.roi.circle')
            tRoi.FaceAlpha = ptrRoi.FaceAlpha;
            tRoi.Radius    = ptrRoi.Radius;    
            tRoi.FaceSelectable = ptrRoi.FaceSelectable; 

        case lower('images.roi.ellipse')
            tRoi.FaceAlpha      = ptrRoi.FaceAlpha;
            tRoi.SemiAxes       = ptrRoi.SemiAxes;
            tRoi.RotationAngle  = ptrRoi.RotationAngle;
            tRoi.FaceSelectable = ptrRoi.FaceSelectable; 

        case lower('images.roi.rectangle')
            tRoi.FaceAlpha = ptrRoi.FaceAlpha;
            tRoi.FaceSelectable = ptrRoi.FaceSelectable; 

    end

    if isfield( tAddInput(iOffset), 'tRoi' )            
        tAddInput(iOffset).tRoi{numel(tAddInput(iOffset).tRoi)+1} = tRoi;
    else
        tAddInput(iOffset).tRoi{1} = tRoi;
    end
    
    tRoi.Object = ptrRoi;              
  
    if isempty(atRoiInput)
        atRoiInput{1} = tRoi;
    else
        atRoiInput{numel(atRoiInput)+1} = tRoi;
    end
    
    inputTemplate('set', tAddInput);
        
    roiTemplate('set', atRoiInput);

    setVoiRoiSegPopup();

end  