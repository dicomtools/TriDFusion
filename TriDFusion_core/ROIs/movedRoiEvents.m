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

    tMovedInput = inputTemplate('get');        
    iOffset = get(uiSeriesPtr('get'), 'Value');
    if iOffset > numel(tMovedInput)  
        return;
    end

    for bb=1:numel(tMovedInput(iOffset).tRoi)
        if strcmpi(hObject.Tag, tMovedInput(iOffset).tRoi{bb}.Tag)
            tMovedInput(iOffset).tRoi{bb}.Position = hObject.Position;

            switch lower(hObject.Type)
                case lower('images.roi.circle')
                    tMovedInput(iOffset).tRoi{bb}.Radius = hObject.Radius;

                 case lower('images.roi.ellipse')
                    tMovedInput(iOffset).tRoi{bb}.SemiAxes      = hObject.SemiAxes;
                    tMovedInput(iOffset).tRoi{bb}.RotationAngle = hObject.RotationAngle;                                       
                 case lower('images.roi.line')
                    dLength = computeRoiLineLength(hObject);
                    tMovedInput(iOffset).tRoi{bb}.Label = [num2str(dLength) ' mm'];     
                    tMovedInput(iOffset).tRoi{bb}.Object.Label = [num2str(dLength) ' mm']; 
             end

            inputTemplate('set', tMovedInput);
            roiTemplate('set', tMovedInput(iOffset).tRoi);

            break;
        end
    end

end