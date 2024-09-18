function [imRegistered, atRegisteredMetaData, dispField] = deformableRegistration(imToRegister, atImToRegisterMetaData, imReference, atReferenceMetaData, aLogicalMask, sInterpolation, sNumberOfPyramidLevelsMode, dNumberOfPyramidLevels, dGridRegularization, sGridSpacingMode, aGridSpacing, sPixelResolutionMode, aPixelResolution, bReferenceOutputView, bUpdateDescription, dMovingSeriesOffset, dispField)
%function [imRegistered, atRegisteredMetaData, dispField] = deformableRegistration(imToRegister, atImToRegisterMetaData, imReference, atReferenceMetaData, aLogicalMask, sInterpolation, sNumberOfPyramidLevelsMode, dNumberOfPyramidLevels, dGridRegularization, sGridSpacingMode, aGridSpacing, sPixelResolutionMode, aPixelResolution, bReferenceOutputView, bUpdateDescription, dMovingSeriesOffset, dispField)
%Deformable registration of grayscale images or intensity volumes using total variation method.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Note: option settings must fit on one line and can contain one semicolon at most.
%Options can be strings, cell arrays of strings, or numerical arrays.
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

    dSliceThickness = computeSliceSpacing(atImToRegisterMetaData);
    
    if dSliceThickness == 0           
        dSliceThickness = 1;
    end
    
    if atImToRegisterMetaData{1}.PixelSpacing(1) == 0 && ...
       atImToRegisterMetaData{1}.PixelSpacing(2) == 0 

        for jj=1:numel(atImToRegisterMetaData)
            atImToRegisterMetaData{1}.PixelSpacing(1) =1;
            atImToRegisterMetaData{1}.PixelSpacing(2) =1;
        end       
    end

    % 
    % [Mdti,Rdti] = TransformMatrix(atImToRegisterMetaData{1}, dSliceThickness);
    % TF = affine3d((Mdti*Rdti)');
    % RA = imref3d(size(imToRegister), atImToRegisterMetaData{1}.PixelSpacing(2), atImToRegisterMetaData{1}.PixelSpacing(1), dSliceThickness);  % Spatial referencing object for the CT

    if ~isequal(size(imReference), size(imToRegister))      
            
        % Dimension must be the same

        [imResampled, atImToRegisterMetaData] = ...
            resampleImage(imToRegister          , ...
                          atImToRegisterMetaData, ...
                          imReference           , ...
                          atReferenceMetaData   , ...
                          sInterpolation        , ...
                          true                  , ...
                          false);
    else
        imResampled = imToRegister;
    end

    if exist('dispField', 'var')   

        % if bReferenceOutputView == true
        %     [imRegistered, ~] = imwarp(imToRegister, dispField, 'InterpolationMethod', sInterpolation); 
        % else
            [imRegistered, ~] = imwarp(imResampled, dispField, 'Interp', sInterpolation);        
 
    else

        if strcmpi(sNumberOfPyramidLevelsMode, 'automatic')

            dNumberOfPyramidLevels = calculateNumPyramidLevels3D(size(imToRegister));
        end

        if strcmpi(sPixelResolutionMode, 'automatic') || ...
           strcmpi(sGridSpacingMode    , 'automatic')
           
            aPixelSpacing = atImToRegisterMetaData{1}.PixelSpacing;
        end

        if strcmpi(sPixelResolutionMode, 'automatic')
            % Define PixelResolution
            if size(imResampled, 3) == 1 % 2D
                aPixelResolution = [aPixelSpacing(2), aPixelSpacing(1)];
            else
                aPixelResolution = [aPixelSpacing(2), aPixelSpacing(1), dSliceThickness];
            end
        end

        if strcmpi(sGridSpacingMode, 'automatic')
   
            % Convert physical spacing (mm) to number of pixels
            % Use rounding to the nearest integer

            if size(imResampled, 3) == 1 % 2D
                aGridSpacing = [round(aPixelSpacing(1)), round(aPixelSpacing(2))];
            else
                aGridSpacing = [round(aPixelSpacing(1)), round(aPixelSpacing(2)), round(dSliceThickness)];
            end
        end

        % if bReferenceOutputView == true

            [dispField, ~] = ...
                imregdeform(rescale(imResampled), ...                           % Image to register (moving)
                            rescale(imReference) , ...                          % Reference image (fixed)
                            'NumPyramidLevels'   , dNumberOfPyramidLevels, ...  % Number of pyramid levels 
                            'GridRegularization' , dGridRegularization, ...     % Regularization value (tunable)
                            'GridSpacing'        , aGridSpacing, ...            % Spacing between control points in the deformation grid
                            'PixelResolution'    , aPixelResolution, ...        % Physical resolution of the images (e.g., mm per pixel)
                            'DisplayProgress'    , true);                       % Display progress during registration
            
            [imRegistered, ~] = imwarp(imResampled, dispField, 'Interp', sInterpolation);        
           
        % else
        %     [dispField, ~] = ...
        %         imregdeform(rescale(imResampled), ...                           % Image to register (moving)
        %                     rescale(imReference) , ...                          % Reference image (fixed)
        %                     'NumPyramidLevels'   , dNumberOfPyramidLevels, ...  % Number of pyramid levels 
        %                     'GridRegularization' , dGridRegularization, ...     % Regularization value (tunable)
        %                     'GridSpacing'        , aGridSpacing, ...            % Spacing between control points in the deformation grid
        %                     'PixelResolution'    , aPixelResolution, ...        % Physical resolution of the images (e.g., mm per pixel)
        %                     'DisplayProgress'    , true); 
        % 
        %     outputView = imref3d(size(imToRegister));
        %     [imRegistered, ~] = imwarp(imToRegister, dispField, 'OutputView', outputView, 'InterpolationMethod', sInterpolation);
        % 
        % end


        % if bReferenceOutputView == true
        % 
        %     [imRegistered, ~] = imwarp(imToRegister, dispField, 'InterpolationMethod', sInterpolation); 
        % else
        %     outputView = imref3d(size(imToRegister));
        %     [imRegistered, ~] = imwarp(imToRegister, dispField, 'OutputView', outputView, 'InterpolationMethod', sInterpolation);
        % end

    end

    clear imResampled;

    % Update the header

    atRegisteredMetaData = atImToRegisterMetaData;

    if bReferenceOutputView == true || ...
       isequal(size(imReference), size(imRegistered)) 

        dimsRsp = size(imRegistered);
          
        if numel(atRegisteredMetaData) ~= 1
    
            if dimsRsp(3) < numel(atRegisteredMetaData)
    
                atRegisteredMetaData = atRegisteredMetaData(1:numel(atReferenceMetaData)); % Remove some slices
            else
                for cc=1:dimsRsp(3) - numel(atRegisteredMetaData)
                    atRegisteredMetaData{end+1} = atRegisteredMetaData{end}; %Add missing slice
                end            
            end                
        end
    
        for jj=1:numel(atRegisteredMetaData)
    
            atRegisteredMetaData{jj}.ImagePositionPatient    = atReferenceMetaData{jj}.ImagePositionPatient;
            atRegisteredMetaData{jj}.ImageOrientationPatient = atReferenceMetaData{jj}.ImageOrientationPatient;
            atRegisteredMetaData{jj}.PixelSpacing            = atReferenceMetaData{jj}.PixelSpacing;  
            atRegisteredMetaData{jj}.Rows                    = atReferenceMetaData{jj}.Rows;  
            atRegisteredMetaData{jj}.Columns                 = atReferenceMetaData{jj}.Columns;  
            atRegisteredMetaData{jj}.SpacingBetweenSlices    = atReferenceMetaData{jj}.SpacingBetweenSlices;  
            atRegisteredMetaData{jj}.SliceThickness          = atReferenceMetaData{jj}.SliceThickness;      
            atRegisteredMetaData{jj}.SliceLocation           = atReferenceMetaData{jj}.SliceLocation;      
        end  
      
    end

    % Update series description            

    if bUpdateDescription == true

        for jj=1:numel(atRegisteredMetaData)

            atRegisteredMetaData{jj}.SeriesDescription  = sprintf('MOV-COREG %s', atRegisteredMetaData{jj}.SeriesDescription);
        end

        if ~exist('dMovingSeriesOffset', 'var')

            dMovingSeriesOffset = [];
            atInput = inputTemplate('get');
    
    
            for jj=1:numel(atInput)
                if strcmpi(atInput(jj).atDicomInfo{1}.SeriesInstanceUID, atImToRegisterMetaData{1}.SeriesInstanceUID)
                    dMovingSeriesOffset = jj;
                    break;
                end
            end
        end

        if ~isempty(dMovingSeriesOffset)

            asDescription = seriesDescription('get');
            asDescription{dMovingSeriesOffset} = sprintf('MOV-COREG %s', asDescription{dMovingSeriesOffset});
            seriesDescription('set', asDescription);
    
            set(uiSeriesPtr('get'), 'String', asDescription);
            set(uiFusedSeriesPtr('get'), 'String', asDescription);            
        end
    end

    function numPyramidLevels = calculateNumPyramidLevels3D(imageSize)
        % Calculate the number of pyramid levels for registration based on image dimensions.
        % 
        % Parameters:
        % - imageSize: A vector containing the size of the 3D image [height, width, depth]
        %
        % Returns:
        % - numPyramidLevels: Calculated number of pyramid levels
    
        % Find the minimum dimension of the 3D image
        minDimension = min(imageSize);
        
        % Calculate the number of pyramid levels using log2 of the minimum dimension divided by 16
        numPyramidLevels = floor(log2(minDimension / 16));
        
        % Ensure at least 1 pyramid level if the calculated value is too low
        numPyramidLevels = max(numPyramidLevels, 1);
    end

end