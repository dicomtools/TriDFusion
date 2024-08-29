function maskToVoi(aMask, sLabel, sLesionType, aColor, sPlane, dSeriesOffset, bPixelEdge, sOptions)
%function maskToVoi(aMask, sLabel, sLesionType, aColor, sPlane, dSeriesOffset, bPixelEdge, sOptions)
%Create a VOI from a 3D mask.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Note: option settings must fit on one line and can contain one semicolon at most.
%Options can be strings, cell arrays of strings, or numerical arrays.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2020, Daniel Lafontaine, on behalf of the TriDFusion development team.
% 
% This file is part of The Triple Dimention Fusion (TriDFusion).
% 
% TriDFusion development has been led by: Daniel Lafontaine
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

    aMaskSize = size(aMask);
    aImageSize = size(dicomBuffer('get', [], dSeriesOffset));

    if numel(aMaskSize) ~= 3 % Must be 3D array
        return;
    end
    
    try
        
    set(fiMainWindowPtr('get'), 'Pointer', 'watch');            
    drawnow;   
    
    if strcmpi(sPlane, 'coronal')
        axRoi = axes1Ptr('get', [], dSeriesOffset);
        dMaskSize  = aMaskSize(1);
        dImageSize = aImageSize(1);
    elseif strcmpi(sPlane, 'sagittal')
        axRoi = axes2Ptr('get', [], dSeriesOffset);
        dMaskSize  = aMaskSize(2);
        dImageSize = aImageSize(2);
    else
        axRoi = axes3Ptr('get', [], dSeriesOffset);
        dMaskSize  = aMaskSize(3);
        dImageSize = aImageSize(3);
    end
     
    asTag = [];
        
    for mm=1: dMaskSize
        
        if mm > dImageSize
            break;
        end

        if strcmpi(sPlane, 'coronal')
            aSlice = aMask(mm,:,:);
        elseif strcmpi(sPlane, 'sagittal')
            aSlice = aMask(:,mm,:);
        else
            aSlice = aMask(:,:,mm);
        end       
        
        if any(aSlice, 'all') 
                               
            if bPixelEdge == true
                aSlice = imresize(aSlice,3, 'nearest'); % do not go directly through pixel centers
            end
            
            if exist('sOptions', 'var')
                 [maskSlice,~,~,~] = bwboundaries(aSlice, 4, sOptions); 
            else
                [maskSlice,~,~,~] = bwboundaries(aSlice, 4, 'noholes'); 
            end

% % Initialize arrays to store boundary types
% innerBoundaries = false(length(maskSlice), 1);
% 
%     % Loop through each boundary
%     for i = 1:length(maskSlice)
%         % Get the coordinates of the current boundary
%         boundary_i = maskSlice{i};
%         
%         % Check if this boundary is contained within any other boundary
%         for j = 1:length(maskSlice)
%             if i ~= j
%                 % Get the coordinates of the other boundary
%                 boundary_j = maskSlice{j};
%                 
%                 % Check if boundary_i is within boundary_j
%                 if inpolygon(boundary_i(:,2), boundary_i(:,1), boundary_j(:,2), boundary_j(:,1))
%                     innerBoundaries(i) = true;
%                     
%                     % Mark the outer boundary (boundary_j) as having an inner boundary
%                     hasInnerBoundary(j) = true;
%                 end
%             end
%         end
%     end
% 
% % Filter out inner boundaries
% outerBoundariesWithInner = maskSlice(hasInnerBoundary);
% 
% Initialize arrays to store outer and inner boundaries
% Initialize arrays to store outer boundaries and their associated inner boundaries


            if ~isempty(maskSlice)

                if strcmpi(sPlane, 'coronal')
                    sliceNumber('set', 'coronal', mm);
                elseif strcmpi(sPlane, 'sagittal')
                    sliceNumber('set', 'sagittal', mm);
                else
                    sliceNumber('set', 'axial', mm);
                end    

                progressBar(mm/dMaskSize, sprintf('Processing mask slice %d/%d', mm, dMaskSize ) );      

                for jj=1:numel(maskSlice)
                    
                    sTag = num2str(randi([-(2^52/2),(2^52/2)],1));

                    curentMask = maskSlice(jj);

                    if bPixelEdge == true                    
                        curentMask{1} = (curentMask{1} +1)/3; 
                    end
                    
                    aPosition = flip(curentMask{1}, 2);

                    if bPixelEdge == false
                        
                        aPosition = smoothRoi(aPosition, aMaskSize);
                    end

                    pRoi = images.roi.Freehand(axRoi, ...
                                               'Smoothing'     , 1, ...
                                               'Position'      , aPosition, ...
                                               'Color'         , aColor, ...
                                               'LineWidth'     , 1, ...
                                               'Label', ''     , ...
                                               'LabelVisible'  , 'off', ...
                                               'Tag'           , sTag, ...
                                               'Visible'       , 'off', ...
                                               'FaceSelectable', 0, ...
                                               'FaceAlpha'     , roiFaceAlphaValue('get'));  

                    if bPixelEdge == true
                        reduce(pRoi);
                    end   

                    pRoi.Waypoints(:) = false;

                    addRoi(pRoi, dSeriesOffset, sLesionType);                  

                    roiDefaultMenu(pRoi);

                    uimenu(pRoi.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData', pRoi, 'Callback', @hideViewFaceAlhaCallback); 
                    uimenu(pRoi.UIContextMenu,'Label', 'Clear Waypoints' , 'UserData', pRoi, 'Callback', @clearWaypointsCallback); 
                    
                    constraintMenu(pRoi);

                    cropMenu(pRoi);

                    voiMenu(pRoi);
                
                    uimenu(pRoi.UIContextMenu,'Label', 'Display Result' , 'UserData',pRoi, 'Callback',@figRoiDialogCallback, 'Separator', 'on'); 

               %     set(fiMainWindowPtr('get'), 'WindowScrollWheelFcn' , @wheelScroll);

                    asTag{numel(asTag)+1} = sTag;
                end
            end
            
        end
    end
    
    if ~isempty(asTag)
        createVoiFromRois(dSeriesOffset, asTag, sLabel, aColor, sLesionType);
        setVoiRoiSegPopup();
    end
    
    progressBar(1, 'Ready' );      
   
    catch
        progressBar(1, 'Error:maskToVoi()');          
    end  

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow;           
 
end