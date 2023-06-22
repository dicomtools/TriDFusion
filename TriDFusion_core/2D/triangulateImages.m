function triangulateImages()
%function triangulateImages()
%Set the slices number of the 2D triangulation.
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

    if is2DBrush('get') == true
    
        axeClicked('set', true);
        uiresume(fiMainWindowPtr('get'));

    else
        if size(dicomBuffer('get', [], dSeriesOffset), 3) ~= 1
    
            if showBorder('get') == false && is2DBrush('get') == false
                % To reset next, delete, previous contour end of list
    %            set(uiTraWindowPtr('get'), 'HighlightColor', [0 1 1]);
                set(uiTraWindowPtr('get'), 'BorderWidth', 0);          
            end
    
            im = dicomBuffer('get', [], dSeriesOffset);
    
            iCoronalSize  = size(im,1);
            iSagittalSize = size(im,2);
            iAxialSize    = size(im,3);        
    
            clickedPt = get(gca,'CurrentPoint');
    
            clickedPtX = round(clickedPt(1  ));
            clickedPtY = round(clickedPt(1,2));
    
    
            if clickedPtX > 0 && clickedPtY > 0
    
                switch gca
                    case axes1Ptr('get', [], dSeriesOffset)  
                        if ( (clickedPtX <= iSagittalSize) &&...
                             (clickedPtY <= iAxialSize) )  
                            sliceNumber('set', 'sagittal', clickedPtX);
                            sliceNumber('set', 'axial'   , clickedPtY);
    
                            set(uiSliderSagPtr('get'), 'Value', clickedPtX / iSagittalSize);
                            set(uiSliderTraPtr('get'), 'Value', 1 - (clickedPtY / iAxialSize));
    
                            refreshImages();
                            axeClicked('set', true);
                            uiresume(fiMainWindowPtr('get'));
                        end
    
                    case axes2Ptr('get', [], dSeriesOffset)
                        if ( (clickedPtX <= iCoronalSize) &&...
                             (clickedPtY <= iAxialSize) )  
                            sliceNumber('set', 'coronal', clickedPtX);
                            sliceNumber('set', 'axial'  , clickedPtY);                
    
                            set(uiSliderCorPtr('get'), 'Value', clickedPtX / iCoronalSize);
                            set(uiSliderTraPtr('get'), 'Value', 1 - (clickedPtY / iAxialSize));
    
                            refreshImages();
    
                            axeClicked('set', true);
                            uiresume(fiMainWindowPtr('get'));                                
                        end    
    
                    case axes3Ptr('get', [], dSeriesOffset)
                        if ( (clickedPtX <= iSagittalSize) && ...
                             (clickedPtY <= iCoronalSize) ) 
    
                            sliceNumber('set', 'sagittal', clickedPtX);
                            sliceNumber('set', 'coronal' , clickedPtY);
    
                            set(uiSliderSagPtr('get'), 'Value', clickedPtX / iSagittalSize);
                            set(uiSliderCorPtr('get'), 'Value', clickedPtY / iCoronalSize);
    
                            refreshImages();
    
                            axeClicked('set', true);
                            uiresume(fiMainWindowPtr('get'));
                        end
    
                    case axesMipPtr('get', [], dSeriesOffset)
    
                        if isFusion('get') == true
    
                            dFusionSeriesOffset = get(uiFusedSeriesPtr('get'), 'Value');
    
                            atSeriesMetaData = dicomMetaData('get', [], dSeriesOffset);
                            atFusionMetaData = dicomMetaData('get', [], dFusionSeriesOffset);
    
                            if isempty(atFusionMetaData)
                                atInputTemplate = inputTemplate('get');
                                atFusionMetaData = atInputTemplate(dFusionSeriesOffset).atDicomInfo;
                            end
    
                            if strcmpi(atSeriesMetaData{1}.Modality, 'ct') && ...
                              ~strcmpi(atFusionMetaData{1}.Modality, 'ct') 
                                if round(clickedPtY) < size(fusionBuffer('get', [], dFusionSeriesOffset), 3)
                                    im = fusionBuffer('get', [], dFusionSeriesOffset);
                                end
                            end
                            
                        end
    
                        iMipAngle = mipAngle('get');
                        angle = (iMipAngle - 1) * 11.25; % to rotate 90 counterclockwise
                       
                        iAxial = round(clickedPtY);
    
                        if angle == 0
    
                            iSagittal = round(clickedPtX);
    
                            [~, idx] = max(im(:,iSagittal,iAxial), [], 'all', 'linear');
                            [iCoronal, ~] = ind2sub(size(im(:,iSagittal,iAxial)), idx);
    
                        elseif angle == 90
                             iCoronal = round(clickedPtX);
    
                            [~, idx] = max(im(iCoronal,:,iAxial), [], 'all', 'linear');
                            [~, iSagittal] = ind2sub(size(im(iCoronal,:,iAxial)), idx);  
    
                        elseif angle == 180
    
                            iSagittal = round(iSagittalSize-clickedPtX);
    
                            [~, idx] = max(im(:,iSagittal,iAxial), [], 'all', 'linear');
                            [iCoronal, ~] = ind2sub(size(im(:,iSagittal,iAxial)), idx);      
    
                        elseif angle == 270
    
                            iCoronal = round(iCoronalSize-clickedPtX);
    
                            [~, idx] = max(im(iCoronal,:,iAxial), [], 'all', 'linear');
                            [~, iSagittal] = ind2sub(size(im(iCoronal,:,iAxial)), idx);                           
                        else
                            
                            % Calculate the xy offset on the axial
                            angleRad = deg2rad(angle);
                            cosAngle = cos(angleRad);
                            sinAngle = sin(angleRad);
                            
                            centerX = iSagittalSize / 2;
                            centerY = iCoronalSize / 2;
                            
                            shiftedX = clickedPtX - centerX;
                            shiftedY = shiftedX * tan(angleRad);
                            
                            iSagittal = centerX + round(shiftedX * cosAngle - shiftedY * sinAngle);
                            iCoronal = centerY + round(shiftedX * sinAngle + shiftedY * cosAngle);
                            
                            % Calculate the diagonal mask
                            % Specify image size
                            imageWidth = iCoronalSize; % Width of the image
                            imageHeight = iSagittalSize; % Height of the image
                            
                            % Given XY coordinate and angle
                            x = iSagittal; % X-coordinate the line must pass through
                            y = iCoronal; % Y-coordinate the line must pass through
                            
                            % Calculate the line parameters
                            angleRad = deg2rad(angle - 90);
                            
                            % Calculate the slope and intercept of the line
                            slope = tan(angleRad);
                            intercept = y - slope * x;
                            
                            % Generate points along the line
                            if abs(slope) <= 1
                                % Iterate over x-values
                                xLine = 1:imageWidth;
                                yLine = slope * xLine + intercept;
                            else
                                % Iterate over y-values
                                yLine = 1:imageHeight;
                                xLine = (yLine - intercept) / slope;
                            end
                            
                            % Round the line coordinates to integers
                            xLine = round(xLine);
                            yLine = round(yLine);
                            
                            % Find coordinates within the valid range
                            validIndices = (xLine >= 1 & xLine <= imageWidth) & (yLine >= 1 & yLine <= imageHeight);
                            xLine = xLine(validIndices);
                            yLine = yLine(validIndices);
    
                            % Modify the image using logical indexing
                            imTemp = im(:, :, iAxial);
                            imTemp(~ismember(1:numel(imTemp), sub2ind(size(imTemp), yLine, xLine))) = false;
                            im(:, :, iAxial) = imTemp;
                            clear imTemp;
                      
                            % Find maximum value and its indices
                            [~, idx] = max(im(:,:,iAxial), [], 'all', 'linear');
                            [iCoronal, iSagittal] = ind2sub(size(im(:, :, iAxial)), idx);
                        
                        end
    
    
                        if (iSagittal >= 1) && (iSagittal <= iSagittalSize) && ...
                           (iCoronal >= 1) && (iCoronal <= iCoronalSize) && ...
                           (iAxial >= 1) && (iAxial <= iAxialSize)
    
                            sliceNumber('set', 'sagittal', iSagittal);
                            sliceNumber('set', 'coronal', iCoronal);
    
                            set(uiSliderSagPtr('get'), 'Value', iSagittal / iSagittalSize);
                            set(uiSliderCorPtr('get'), 'Value', iCoronal / iCoronalSize);
    
                            sliceNumber('set', 'axial', iAxial);
                            set(uiSliderTraPtr('get'), 'Value', iAxial / iAxialSize);                       
                        end
                    
                        refreshImages();
                        axeClicked('set', true);
                        uiresume(fiMainWindowPtr('get'));             
    
                end               
            end
            
            clear im;
         
        else
            if showBorder('get') == false 
                % To reset next, delete, previous contour end of list
     %           set(uiOneWindowPtr('get'), 'HighlightColor', [0 1 1]);
                set(uiOneWindowPtr('get'), 'BorderWidth', 0);
            end
        end
    end
end