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
    
    atRoi = roiTemplate('get'); 

    for bb=1:numel(atRoi)
        if strcmpi(hObject.Tag, atRoi{bb}.Tag)
            
            atRoi{bb}.Position = hObject.Position;
            tInput(iOffset).tRoi{bb}.Position = hObject.Position;

            switch lower(hObject.Type)
                case lower('images.roi.circle')
                    atRoi{bb}.Radius = hObject.Radius;
                    tInput(iOffset).tRoi{bb}.Radius = hObject.Radius;

                 case lower('images.roi.ellipse')
                    atRoi{bb}.SemiAxes      = hObject.SemiAxes;
                    atRoi{bb}.RotationAngle = hObject.RotationAngle;  
                    tInput(iOffset).tRoi{bb}.SemiAxes = hObject.SemiAxes;
                    tInput(iOffset).tRoi{bb}.RotationAngle = hObject.RotationAngle;
                    
                 case lower('images.roi.line')
                    dLength = computeRoiLineLength(hObject);
                    atRoi{bb}.Label = [num2str(dLength) ' mm'];     
                    atRoi{bb}.Object.Label = [num2str(dLength) ' mm']; 
                    tInput(iOffset).tRoi{bb}.Label =  [num2str(dLength) ' mm'];
             end

            roiTemplate('set', atRoi);
            inputTemplate('set', tInput);
            
            setVoiRoiSegPopup();

            break;
        end
    end

end