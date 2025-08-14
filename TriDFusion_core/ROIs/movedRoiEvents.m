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

    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

    atRoiInput     = roiTemplate('get', dSeriesOffset);
    atRoiInputBack = roiTemplate('get', dSeriesOffset);
    
    if isempty(atRoiInput)
        return;
    end
       
    dTagOffset = find(strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {hObject.Tag} ), 1);

    if ~isempty(dTagOffset)
           
        atRoiInput{dTagOffset}.Position = hObject.Position;

        switch lower(hObject.Type)
            
            case lower('images.roi.circle')
                
                atRoiInput{dTagOffset}.Radius   = hObject.Radius;
                atRoiInput{dTagOffset}.Vertices = hObject.Vertices;
                
             case lower('images.roi.ellipse')
                
                if strcmpi(atRoiInput{dTagOffset}.UserData, 'Sphere')
                    
                    atVoi = voiTemplate('get', dSeriesOffset);
                                          
                    aSemiAxesRatio = atRoiInput{dTagOffset}.SemiAxes ./ hObject.SemiAxes;
                    
                    for vv=1:numel(atVoi)
                        
                        pRoisTag = atVoi{vv}.RoisTag;
                        aTagOffset = strcmp( cellfun( @(pRoisTag) pRoisTag, pRoisTag, 'uni', false ), {hObject.Tag} );
                        
                        if find(aTagOffset, 1) % Move all sphere objects
                            
                            sVoiLable = []; 
                            
                            for rr=1:numel(pRoisTag)
                                
                                if strcmp(pRoisTag{rr}, hObject.Tag)
                                    
                                    if aSemiAxesRatio(1) ~= 1 && ...
                                       aSemiAxesRatio(2) ~= 1    
                                    
                                    atRoiInput{dTagOffset}.SemiAxes      = hObject.SemiAxes;
                                    atRoiInput{dTagOffset}.RotationAngle = hObject.RotationAngle;
                                    atRoiInput{dTagOffset}.Vertices      = hObject.Vertices;

                                    if roiHasMaxDistances(atRoiInput{dTagOffset}) == true

                                        maxDistances = atRoiInput{dTagOffset}.MaxDistances; % Cache field to reduce repeated lookup
                                        objectsToDelete = [maxDistances.MaxXY.Line, ...
                                                           maxDistances.MaxCY.Line, ...
                                                           maxDistances.MaxXY.Text, ...
                                                           maxDistances.MaxCY.Text];
                            
                                        % Delete only valid objects
                                        delete(objectsToDelete(isvalid(objectsToDelete)));                                      
                                    end

                                    tMaxDistances = computeRoiFarthestPoint(dicomBuffer('get', [], dSeriesOffset), dicomMetaData('get', [], dSeriesOffset), atRoiInput{dTagOffset}, false, false);

                                    sVoiLable = sprintf('Sphere %s mm', num2str(tMaxDistances.MaxXY.Length));
                                    atVoi{vv}.Label = sVoiLable;
                                    
                                    voiTemplate('set', dSeriesOffset, atVoi);
                                    
                                    setVoiRoiSegPopup();
                                    
                                    atRoiInput{dTagOffset}.Object.Label = sprintf('%s (roi %d/%d)', sVoiLable, rr, numel(pRoisTag));
                                    atRoiInput{dTagOffset}.Label = sprintf('%s (roi %d/%d)', sVoiLable, rr, numel(pRoisTag));

                                    atRoiInput{dTagOffset}.MaxDistances = tMaxDistances;    

                                    end
                                    
                                    continue;
                                end
                                
                                aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), pRoisTag(rr) );
                                dVoiRoiTagOffset = find(aTagOffset, 1);      
                                
                                if ~isempty(dVoiRoiTagOffset)
      
                                    atRoiInput{dVoiRoiTagOffset}.Object.Center = hObject.Center;
                                    atRoiInput{dVoiRoiTagOffset}.Position      = hObject.Center;
                                    
%                                    if aSemiAxesRatio(1) ~= 1 && ...
%                                       aSemiAxesRatio(2) ~= 1  
                                   
                                    if ~isempty(sVoiLable)

                                        atRoiInput{dVoiRoiTagOffset}.Object.Label = sprintf('%s (roi %d/%d)', sVoiLable, rr, numel(pRoisTag));
                                        atRoiInput{dVoiRoiTagOffset}.Label = sprintf('%s (roi %d/%d)', sVoiLable, rr, numel(pRoisTag));
                                    end

                                    atRoiInput{dVoiRoiTagOffset}.Object.SemiAxes      = atRoiInput{dVoiRoiTagOffset}.Object.SemiAxes ./ aSemiAxesRatio;
                                    atRoiInput{dVoiRoiTagOffset}.Object.RotationAngle = hObject.RotationAngle;

                                    atRoiInput{dVoiRoiTagOffset}.SemiAxes      = atRoiInput{dVoiRoiTagOffset}.Object.SemiAxes;
                                    atRoiInput{dVoiRoiTagOffset}.RotationAngle = atRoiInput{dVoiRoiTagOffset}.Object.RotationAngle;
 
%                                    end
                                    
                                    atRoiInput{dVoiRoiTagOffset}.Vertices = atRoiInput{dVoiRoiTagOffset}.Object.Vertices;     

                                    if roiHasMaxDistances(atRoiInput{dVoiRoiTagOffset}) == true

                                        tMaxDistances = computeRoiFarthestPoint(dicomBuffer('get', [], dSeriesOffset), dicomMetaData('get', [], dSeriesOffset), atRoiInput{dVoiRoiTagOffset}, false, false);
                                        atRoiInput{dVoiRoiTagOffset}.MaxDistances = tMaxDistances;                                       
                                    end
                                end                                 
                            end
                            
                            break;
                            
                        end                        
                    end                    
                end
                
                atRoiInput{dTagOffset}.SemiAxes      = hObject.SemiAxes;
                atRoiInput{dTagOffset}.RotationAngle = hObject.RotationAngle;
                atRoiInput{dTagOffset}.Vertices      = hObject.Vertices;
                               
             case lower('images.roi.rectangle')

                atRoiInput{dTagOffset}.Vertices = hObject.Vertices;
                
             case lower('images.roi.line')

                dLength = computeRoiLineLength(hObject);
                
                atRoiInput{dTagOffset}.Label        = [num2str(dLength) ' mm'];
                atRoiInput{dTagOffset}.Object.Label = [num2str(dLength) ' mm'];
        end

        if roiHasMaxDistances(atRoiInput{dTagOffset}) == true
           
            maxDistances = atRoiInput{dTagOffset}.MaxDistances; % Cache field to reduce repeated lookup
            objectsToDelete = [maxDistances.MaxXY.Line, ...
                               maxDistances.MaxCY.Line, ...
                               maxDistances.MaxXY.Text, ...
                               maxDistances.MaxCY.Text];

            % Delete only valid objects
            delete(objectsToDelete(isvalid(objectsToDelete)));

            tMaxDistances = computeRoiFarthestPoint(dicomBuffer('get', [], dSeriesOffset), dicomMetaData('get', [], dSeriesOffset), atRoiInput{dTagOffset}, false, false);
            atRoiInput{dTagOffset}.MaxDistances = tMaxDistances;
        end

        roiTemplate('set', dSeriesOffset, atRoiInput);
        
        dUID = generateUniqueNumber(false);

        roiTemplateEvent('add', dSeriesOffset, atRoiInputBack, atRoiInput, dUID);

        if viewFarthestDistances('get') == true

            refreshImages();
        end

        if size(dicomBuffer('get', [], dSeriesOffset), 3) ~= 1

            plotRotatedRoiOnMip(axesMipPtr('get', [], dSeriesOffset), dicomBuffer('get', [], dSeriesOffset), mipAngle('get'));       
        end

    end

end
