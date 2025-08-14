function decreaseVoiPosition(sVoiTag, dDecreaseBySize)
%function decreaseVoiPosition(sVoiTag, dDecreaseBySize)
%Decrease a VOI position by an number of pixels.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2023, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    atMetaData = dicomMetaData('get', [], dSeriesOffset);

    atRoiInput = roiTemplate('get', dSeriesOffset);
    atVoiInput = voiTemplate('get', dSeriesOffset);

    % atRoiInputBack = roiTemplate('get', dSeriesOffset);

    dUID = generateUniqueNumber(false);

    if ~isempty(atRoiInput)        

        if isempty(atVoiInput)
            
            aTagOffset = 0;
        else
            aTagOffset = strcmp( cellfun( @(atVoiInput) atVoiInput.Tag, atVoiInput, 'uni', false ), {sVoiTag} );
        end
        
        if aTagOffset(aTagOffset==1) % tag is a voi

            dNbRoiTag = numel(atVoiInput{aTagOffset}.RoisTag);

            for tt=1:dNbRoiTag % Scan all tag

                 atRoiInputBack = atRoiInput;
               
                aRoiTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[atVoiInput{aTagOffset}.RoisTag{tt}]} );
                dRoiTagOffset = find(aRoiTagOffset, 1);           
           
                if ~isempty(dRoiTagOffset)
            
                    switch atRoiInput{dRoiTagOffset}.Type
                        
                        case lower('images.roi.line')
                                       
                        case lower('images.roi.rectangle')
                
                        case lower('images.roi.ellipse')
                                       
                        case lower('images.roi.circle')
                            
                                                                
                        otherwise
                        switch lower(atRoiInput{dRoiTagOffset}.Axe)
            
                            case 'axe'
    
                                xPixelSize = atMetaData{1}.PixelSpacing(1);
                                yPixelSize = atMetaData{1}.PixelSpacing(2);
    
                            case 'axes1'
    
                                xPixelSize = atMetaData{1}.PixelSpacing(2);
                                yPixelSize = computeSliceSpacing(atMetaData);
    
                            case 'axes2'
    
                                xPixelSize = atMetaData{1}.PixelSpacing(1);
                                yPixelSize = computeSliceSpacing(atMetaData);
           
                            case 'axes3'
    
                                xPixelSize = atMetaData{1}.PixelSpacing(1);
                                yPixelSize = atMetaData{1}.PixelSpacing(2);
    
                            otherwise
                                continue;
                               
                        end
    
                        if xPixelSize == 0
                            xPixelSize = 1;
                        end
    
                        if yPixelSize == 0
                            yPixelSize = 1;
                        end                    
                        % Calculate the center of the ROI

                        centerX = mean(atRoiInput{dRoiTagOffset}.Position(:, 1));
                        centerY = mean(atRoiInput{dRoiTagOffset}.Position(:, 2));
                        
                        % Iterate through each vertex and move it closer to the center

                        for i = 1:size(atRoiInput{dRoiTagOffset}.Position, 1)
                            x = atRoiInput{dRoiTagOffset}.Position(i, 1);
                            y = atRoiInput{dRoiTagOffset}.Position(i, 2);
                            
                            % Calculate the new position for the vertex
                            
%                             new_x = centerX + (x - centerX) * (1 - dDecreaseBySize / 100); % Adjust the factor as needed
%                             new_y = centerY + (y - centerY) * (1 - dDecreaseBySize / 100); % Adjust the factor as needed

                            new_x = x - (dDecreaseBySize/xPixelSize * sign(x - centerX)); 
                            new_y = y - (dDecreaseBySize/yPixelSize * sign(y - centerY)); 

                            atRoiInput{dRoiTagOffset}.Position(i, 1) = new_x;
                            atRoiInput{dRoiTagOffset}.Position(i, 2) = new_y;
                        end
    
                        if isvalid(atRoiInput{dRoiTagOffset}.Object)                                   
                            atRoiInput{dRoiTagOffset}.Object.Position = atRoiInput{dRoiTagOffset}.Position;
                            roiTemplateEvent('add', dSeriesOffset, atRoiInputBack, atRoiInput, dUID);
                        end
                    end
                end
            end
        end

        roiTemplate('set', get(uiSeriesPtr('get'), 'Value'), atRoiInput);
        
        enableUndoVoiRoiPanel();        
    end    

end