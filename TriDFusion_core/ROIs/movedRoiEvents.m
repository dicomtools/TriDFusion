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

    atRoi = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
    
    if isempty(atRoi)
        return;
    end
    
    aTagOffset = strcmp( cellfun( @(atRoi) atRoi.Tag, atRoi, 'uni', false ), {hObject.Tag} );
    dTagOffset = find(aTagOffset, 1);          

    if ~isempty(dTagOffset)
           
        atRoi{dTagOffset}.Position = hObject.Position;

        switch lower(hObject.Type)
            
            case lower('images.roi.circle')
                
                atRoi{dTagOffset}.Radius   = hObject.Radius;
                atRoi{dTagOffset}.Vertices = hObject.Vertices;
                
             case lower('images.roi.ellipse')
                
                if strcmpi(hObject.UserData, 'Sphere')
                    
                    atVoi = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
                                          
                    aSemiAxesRatio = atRoi{dTagOffset}.SemiAxes ./ hObject.SemiAxes;
                    
                    for vv=1:numel(atVoi)
                        
                        pRoisTag = atVoi{vv}.RoisTag;
                        aTagOffset = strcmp( cellfun( @(pRoisTag) pRoisTag, pRoisTag, 'uni', false ), {hObject.Tag} );
                        
                        if find(aTagOffset, 1) % Move all sphere objects
                            
                            sVoiLable = []; 
                            
                            for rr=1:numel(pRoisTag)
                                
                                if strcmp(pRoisTag{rr}, hObject.Tag)
                                    
                                    if aSemiAxesRatio(1) ~= 1 && ...
                                       aSemiAxesRatio(2) ~= 1    
                                    
                                    atRoi{dTagOffset}.SemiAxes      = hObject.SemiAxes;
                                    atRoi{dTagOffset}.RotationAngle = hObject.RotationAngle;
                                    atRoi{dTagOffset}.Vertices      = hObject.Vertices;
                
                                    tMaxDistances = computeRoiFarthestPoint(dicomBuffer('get'), dicomMetaData('get'), atRoi{dTagOffset}, false, false);

                                    sVoiLable = sprintf('Sphere %s mm', num2str(tMaxDistances.MaxXY.Length));
                                    atVoi{vv}.Label = sVoiLable;
                                    
                                    voiTemplate('set', get(uiSeriesPtr('get'), 'Value'), atVoi);
                                    
                                    setVoiRoiSegPopup();
                                    
                                    atRoi{dTagOffset}.Object.Label = sprintf('%s (roi %d/%d)', sVoiLable, rr, numel(pRoisTag));
                                    atRoi{dTagOffset}.Label = sprintf('%s (roi %d/%d)', sVoiLable, rr, numel(pRoisTag));

                                    end
                                    
                                    continue;
                                end
                                
                                aTagOffset = strcmp( cellfun( @(atRoi) atRoi.Tag, atRoi, 'uni', false ), pRoisTag(rr) );
                                dVoiRoiTagOffset = find(aTagOffset, 1);      
                                
                                if ~isempty(dVoiRoiTagOffset)
      
                                    atRoi{dVoiRoiTagOffset}.Object.Center = hObject.Center;
                                    atRoi{dVoiRoiTagOffset}.Position      = hObject.Center;
                                    
%                                    if aSemiAxesRatio(1) ~= 1 && ...
%                                       aSemiAxesRatio(2) ~= 1  
                                   
                                     if ~isempty(sVoiLable)
                                        atRoi{dVoiRoiTagOffset}.Object.Label = sprintf('%s (roi %d/%d)', sVoiLable, rr, numel(pRoisTag));
                                        atRoi{dVoiRoiTagOffset}.Label = sprintf('%s (roi %d/%d)', sVoiLable, rr, numel(pRoisTag));
                                     end

                                    atRoi{dVoiRoiTagOffset}.Object.SemiAxes      = atRoi{dVoiRoiTagOffset}.Object.SemiAxes ./ aSemiAxesRatio;
                                    atRoi{dVoiRoiTagOffset}.Object.RotationAngle = hObject.RotationAngle;

                                    atRoi{dVoiRoiTagOffset}.SemiAxes      = atRoi{dVoiRoiTagOffset}.Object.SemiAxes;
                                    atRoi{dVoiRoiTagOffset}.RotationAngle = atRoi{dVoiRoiTagOffset}.Object.RotationAngle;

                                    tMaxDistances = computeRoiFarthestPoint(dicomBuffer('get'), dicomMetaData('get'), atRoi{dVoiRoiTagOffset}, false, false);
                                    atRoi{dVoiRoiTagOffset}.MaxDistances = tMaxDistances;    
%                                    end
                                    
                                    atRoi{dVoiRoiTagOffset}.Vertices = atRoi{dVoiRoiTagOffset}.Object.Vertices;     
                                    
                                end   
                                                            
                            end
                        end
                        
                        break
                    end                    
                end
                
                atRoi{dTagOffset}.SemiAxes      = hObject.SemiAxes;
                atRoi{dTagOffset}.RotationAngle = hObject.RotationAngle;
                atRoi{dTagOffset}.Vertices      = hObject.Vertices;
                               
             case lower('images.roi.rectangle')
                atRoi{dTagOffset}.Vertices = hObject.Vertices;
                
             case lower('images.roi.line')
                dLength = computeRoiLineLength(hObject);
                
                atRoi{dTagOffset}.Label          = [num2str(dLength) ' mm'];
                atRoi{dTagOffset}.Object.Label   = [num2str(dLength) ' mm'];
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

        if viewFarthestDistances('get') == true
            refreshImages();
        end

    end

end
