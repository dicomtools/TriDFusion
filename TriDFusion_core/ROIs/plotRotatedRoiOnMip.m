function plotRotatedRoiOnMip(axesPtr, im, iMipAngle)
%function plotRotatedRoiOnMip(axesPtr, im, iMipAngle)
%Processes and plots various types of regions of interest (ROIs) on maximum intensity projection (MIP) images by dynamically handling ROI shapes, extracting relevant image slices, rotating coordinates based on the viewing angle, and rendering the ROIs on the display axes with specific visual attributes.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2024, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    if size(im, 3) == 1
        return;
    end

    atRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

    ptrPlot = plotMipPtr('get');
    if ~isempty(ptrPlot)
        for pp=1:numel(ptrPlot)
            delete(ptrPlot{pp});
        end
    end

    if isempty(atRoiInput)
        return;
    end

    ptrPlot = cell(numel(atRoiInput), 1);

    for rr=1:numel(atRoiInput)

        currentRoi = atRoiInput{rr};

        switch lower(currentRoi.Type)
                        
            case {'images.roi.rectangle', ...
                  'images.roi.circle'}
    
                switch lower(currentRoi.Axe)    
                    
                    case 'axe'
                        aSlice = im(:,:); 
                        
                    case 'axes1'
                        aSlice = permute(im(currentRoi.SliceNb,:,:), [3 2 1]);
                        
                    case 'axes2'
                        aSlice = permute(im(:,currentRoi.SliceNb,:), [3 1 2]);
                        
                    case 'axes3'
                        aSlice  = im(:,:,currentRoi.SliceNb);  
                        
                    otherwise   
                        continue;
                end
    
                 xy = currentRoi.Vertices;
                 aLogicalMask = poly2mask(xy(:, 1), xy(:, 2), size(aSlice,1), size(aSlice,2));
    
                roiCoords = bwboundaries(aLogicalMask);                                    
                roiCoords = roiCoords{1};
    
            case lower('images.roi.ellipse')
                          
                roiCoords = currentRoi.Vertices;
                                                                      
            otherwise
    
                roiCoords = currentRoi.Position;
        end 

        % Calculate the rotation angle for this MIP slice based on iMipAngle
        rotationAngle = 360 - ((iMipAngle - 1) * 11.25);  % Angle in degrees, matching the MIP
        
        % Convert the rotation angle to radians
        theta = deg2rad(rotationAngle);
                
        switch lower(currentRoi.Axe)

            case 'axes1'
                continue;

            case 'axes2'
                continue;

            case 'axes3'

                % Define the center of rotation (typically the center of the image, adjust if necessary)
                center = [size(im, 2), size(im, 1)] / 2;  % [cols, rows] - adjust to the center of your image

                % Create the 2D rotation matrix (assuming rotation around the Z-axis)
                Rz = [cos(theta), -sin(theta);
                      sin(theta),  cos(theta)];
                
                % Adjust the ROI coordinates by rotating them around the center
                shiftedCoords = roiCoords - center;            % Shift ROI coordinates to the center
                rotatedCoords = (Rz * shiftedCoords')';        % Apply the rotation matrix
                finalCoords = rotatedCoords + center;          % Shift back to the original position
                
                % Extract the X and Y coordinates for plotting
                rotatedX = finalCoords(:, 1);  % X coordinates after rotation
                rotatedY = finalCoords(:, 2);  % Y coordinates after rotation
    
                rotatedY(:) = currentRoi.SliceNb;
        end
        
        % Plot the rotated ROI on the MIP 
        hold(axesPtr, 'on');  % Retain the current MIP image
        
        if contourVisibilityRoiPanelValue('get') == true
            sVisible = 'on';
        else
            sVisible = 'off';
        end

        ptrPlot{rr} = patch(axesPtr, ...
                            'XData', rotatedX, ...
                            'YData', rotatedY, ...
                            'EdgeColor', atRoiInput{rr}.Color, ...
                            'FaceColor', atRoiInput{rr}.Color, ...
                            'LineWidth', atRoiInput{rr}.LineWidth, ...
                            'EdgeAlpha', roiFaceAlphaValue('get'), ...
                            'FaceAlpha', roiFaceAlphaValue('get'), ...
                            'Visible'  , sVisible ...
                           );

        hold(axesPtr, 'off');  % Release the hold on the axes
    end

    ptrPlot = ptrPlot(~cellfun(@isempty, ptrPlot));

    plotMipPtr('set', ptrPlot);

end
