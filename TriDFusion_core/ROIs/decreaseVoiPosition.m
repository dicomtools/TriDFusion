function decreaseVoiPosition(sRoiTag, dNbPixels)
%function decreaseVoiPosition(sRoiTag, dNbPixels)
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

    atRoi = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
    atVoi = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

    if ~isempty(atRoi)        

        if isempty(atVoi)
            aTagOffset = 0;
        else
            aTagOffset = strcmp( cellfun( @(atVoi) atVoi.Tag, atVoi, 'uni', false ), {sRoiTag} );
        end
        
        if aTagOffset(aTagOffset==1) % tag is a voi

            dNbRoiTag = numel(atVoi{aTagOffset}.RoisTag);

            for tt=1:dNbRoiTag % Scan all tag
                
                aRoiTagOffset = strcmp( cellfun( @(atRoi) atRoi.Tag, atRoi, 'uni', false ), {[atVoi{aTagOffset}.RoisTag{tt}]} );
                dRoiTagOffset = find(aRoiTagOffset, 1);           
           
                if ~isempty(dRoiTagOffset)
            
                    switch atRoi{dRoiTagOffset}.Type
                        
                        case lower('images.roi.line')
                                       
                        case lower('images.roi.rectangle')
                
                        case lower('images.roi.ellipse')
                                       
                        case lower('images.roi.circle')
                            
                                                                
                        otherwise
                    
                        % Calculate the center of the ROI

                        centerX = mean(atRoi{dRoiTagOffset}.Position(:, 1));
                        centerY = mean(atRoi{dRoiTagOffset}.Position(:, 2));
                        
                        % Iterate through each vertex and move it closer to the center

                        for i = 1:size(atRoi{dRoiTagOffset}.Position, 1)
                            x = atRoi{dRoiTagOffset}.Position(i, 1);
                            y = atRoi{dRoiTagOffset}.Position(i, 2);
                            
                            % Calculate the new position for the vertex
                            
                            new_x = centerX + (x - centerX) * (1 - dNbPixels / 100); % Adjust the factor as needed
                            new_y = centerY + (y - centerY) * (1 - dNbPixels / 100); % Adjust the factor as needed
                            
                            atRoi{dRoiTagOffset}.Position(i, 1) = new_x;
                            atRoi{dRoiTagOffset}.Position(i, 2) = new_y;
                        end
    
                        if isvalid(atRoi{dRoiTagOffset}.Object)                                   
                            atRoi{dRoiTagOffset}.Object.Position = atRoi{dRoiTagOffset}.Position;
                        end
                    end
                end
            end
        end

        roiTemplate('set', get(uiSeriesPtr('get'), 'Value'), atRoi);
    end    

end