function movedRoiEvents(hObject, ~)
%function movedRoiEvents(hObject,~)
%Move ROIs Event.
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

    tInput = inputTemplate('get');
    iOffset = get(uiSeriesPtr('get'), 'Value');
    if iOffset > numel(tInput)
        return;
    end

    atRoi = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
    
    if isempty(atRoi)
        return;
    end
    
    aTagOffset = strcmp( cellfun( @(atRoi) atRoi.Tag, atRoi, 'uni', false ), {hObject.Tag} );
    dTagOffset = find(aTagOffset, 1);          

    if ~isempty(dTagOffset)
           
        atRoi{dTagOffset}.Position = hObject.Position;
        tInput(iOffset).tRoi{dTagOffset}.Position = hObject.Position;

        switch lower(hObject.Type)
            
            case lower('images.roi.circle')
                atRoi{dTagOffset}.Radius = hObject.Radius;
                atRoi{dTagOffset}.Vertices = hObject.Vertices;
                 
                tInput(iOffset).tRoi{dTagOffset}.Radius = hObject.Radius;                
                tInput(iOffset).tRoi{dTagOffset}.Vertices = hObject.Vertices;
                
             case lower('images.roi.ellipse')
                atRoi{dTagOffset}.SemiAxes      = hObject.SemiAxes;
                atRoi{dTagOffset}.RotationAngle = hObject.RotationAngle;
                atRoi{dTagOffset}.Vertices      = hObject.Vertices;
                
                tInput(iOffset).tRoi{dTagOffset}.SemiAxes = hObject.SemiAxes;
                tInput(iOffset).tRoi{dTagOffset}.RotationAngle = hObject.RotationAngle;
                tInput(iOffset).tRoi{dTagOffset}.Vertices = hObject.Vertices;
                
             case lower('images.roi.rectangle')
                atRoi{dTagOffset}.Vertices = hObject.Vertices;
                tInput(iOffset).tRoi{dTagOffset}.Vertices = hObject.Vertices;
                
             case lower('images.roi.line')
                dLength = computeRoiLineLength(hObject);
                
                atRoi{dTagOffset}.Label                = [num2str(dLength) ' mm'];
                atRoi{dTagOffset}.Object.Label         = [num2str(dLength) ' mm'];
                tInput(iOffset).tRoi{dTagOffset}.Label = [num2str(dLength) ' mm'];
        end

        if ~isempty(atRoi{dTagOffset}.MaxDistances)
            
            if isvalid(atRoi{dTagOffset}.MaxDistances.MaxXY.Line)
                delete(atRoi{dTagOffset}.MaxDistances.MaxXY.Line);
            end
            
            if isvalid(atRoi{dTagOffset}.MaxDistances.MaxCY.Line)
                delete(atRoi{dTagOffset}.MaxDistances.MaxCY.Line);
            end
            
            if isvalid(atRoi{dTagOffset}.MaxDistances.MaxXY.Text)
                delete(atRoi{dTagOffset}.MaxDistances.MaxXY.Text);
            end
            
            if isvalid(atRoi{dTagOffset}.MaxDistances.MaxCY.Text)
                delete(atRoi{dTagOffset}.MaxDistances.MaxCY.Text);
            end
        end

        tMaxDistances = computeRoiFarthestPoint(dicomBuffer('get'), dicomMetaData('get'), atRoi{dTagOffset}, false, false);
        atRoi{dTagOffset}.MaxDistances = tMaxDistances;

        roiTemplate('set', get(uiSeriesPtr('get'), 'Value'), atRoi);
        inputTemplate('set', tInput);

        if viewFarthestDistances('get') == true
            refreshImages();
        end

    end

end
