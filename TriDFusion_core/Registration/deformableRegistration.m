function [imRegistered, atRegisteredMetaData, dispField] = deformableRegistration(imToRegister, atImToRegisterMetaData, imReference, atReferenceMetaData, aLogicalMask, bUpdateDescription, dispField)
%function [imRegistered, atRegisteredMetaData, dispField] = deformableRegistration(imToRegister, atImToRegisterMetaData, imReference, atReferenceMetaData, aLogicalMask, bUpdateDescription, dispField)
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
    
    if ~isequal(size(imReference), size(imToRegister))      

        % Dimension must be the same

        [imToRegister, atImToRegisterMetaData] = ...
            resampleImage(imToRegister          , ...
                          atImToRegisterMetaData, ...
                          imReference           , ...
                          atReferenceMetaData   , ...
                          'Nearest'             , ...
                          true                  , ...
                          false);
    end
    

    if exist('dispField', 'var')   

        imRegistered = imwarp(imToRegister, dispField, 'Interp', 'Nearest');               
    else
        [dispField,~] = imregdeform(rescale(imToRegister), rescale(imReference),GridRegularization=0.001); % Deformable registration          
       
        imRegistered = imwarp(imToRegister, dispField, 'Interp', 'Nearest');
    end

    dimsRsp = size(imRegistered);

    atRegisteredMetaData = atImToRegisterMetaData;
        
    % Updat the header

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
  
    % Update series description

    if bUpdateDescription == true 

        for jj=1:numel(atRegisteredMetaData)

            atRegisteredMetaData{jj}.SeriesDescription = sprintf('MOV-COREG %s', atRegisteredMetaData{jj}.SeriesDescription);
        end
    end

    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

    if dSeriesOffset <= numel(inputTemplate('get')) && ...
       bUpdateDescription == true 

        asDescription = seriesDescription('get');
        asDescription{dSeriesOffset} = sprintf('MOV-COREG %s', asDescription{dSeriesOffset});
        seriesDescription('set', asDescription);
    end  
         
end