function [imRegistered, atRegisteredMetaData, Rregistered, Rmoving, Rfixed] = registerImage(imMoving, atMovingMetaData, imFixed, atFixedMetaData, sType, tOptimizer, tMetric, bUpdateDescription)
%function [imRegistered, atRegisteredMetaData, Rregistered, Rmoving, Rfixed] = registerImage(imMoving, atMovingMetaData, imFixed, atFixedMetaData, sType, tOptimizer, tMetric, bUpdateDescription)
%Register any modalities.
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

    % sType:
    % 'translation'	(x,y) translation.
    % 'rigid'	Rigid transformation consisting of translation and rotation.
    % 'similarity'	Nonreflective similarity transformation consisting of translation, rotation, and scale.
    % 'affine' Affine transformation consisting of translation, rotation, scale, and shear.        

    fixedSliceThickness = computeSliceSpacing(atFixedMetaData);
    if size(imFixed, 3) == 1
       Rfixed  = imref2d(size(imFixed),atFixedMetaData{1}.PixelSpacing(2),atFixedMetaData{1}.PixelSpacing(1));  
    else
       Rfixed  = imref3d(size(imFixed),atFixedMetaData{1}.PixelSpacing(2),atFixedMetaData{1}.PixelSpacing(1), fixedSliceThickness);  
    end

    movingSliceThickness = computeSliceSpacing(atMovingMetaData);        
    if size(imMoving, 3) == 1
       Rmoving = imref2d(size(imMoving),atMovingMetaData{1}.PixelSpacing(2),atMovingMetaData{1}.PixelSpacing(1));                 
    else         
       Rmoving = imref3d(size(imMoving),atMovingMetaData{1}.PixelSpacing(2),atMovingMetaData{1}.PixelSpacing(1),movingSliceThickness);
    end

    [optimizer, metric] = imregconfig('multimodal');

    metric.NumberOfSpatialSamples = tMetric.NumberOfSpatialSamples;
    metric.NumberOfHistogramBins = tMetric.NumberOfHistogramBins;
    metric.UseAllPixels = tMetric.UseAllPixels;

    optimizer.InitialRadius = tOptimizer.InitialRadius;
    optimizer.Epsilon = tOptimizer.Epsilon;
    optimizer.GrowthFactor = tOptimizer.GrowthFactor;
    optimizer.MaximumIterations = tOptimizer.MaximumIterations;

    if double(min(imMoving,[],'all')) == 0
        [imRegistered, Rregistered] = imregister(imMoving, Rmoving, imFixed, Rfixed, sType, optimizer, metric);  
    else    
        [~, Rregistered] = imregister(imMoving, Rmoving, imFixed, Rfixed, sType, optimizer, metric);  
    
        geomtform = imregtform(imMoving, Rmoving, imFixed, Rregistered, sType, optimizer, metric);
        imRegistered = imwarp(imMoving, Rmoving, geomtform, 'bicubic', 'OutputView', Rregistered, 'FillValues', double(min(imMoving,[],'all')) );
    end

    dimsReg = size(imRegistered);

    atRegisteredMetaData = atMovingMetaData;

    if atFixedMetaData{1}.SpacingBetweenSlices
        fSpacing = atFixedMetaData{1}.SpacingBetweenSlices;
    else
        fSpacing = fixedSliceThickness;
    end

    if size(imRegistered, 3) ~= 1
        if dimsReg(3) < numel(atRegisteredMetaData) && ...
           numel(atRegisteredMetaData) ~= 1   
            atRegisteredMetaData = atRegisteredMetaData(1:dimsReg(3));

        elseif dimsReg(3) > numel(atRegisteredMetaData) && ...
               numel(atRegisteredMetaData) ~= 1   

            for cc=1:dimsReg(3)- numel(atRegisteredMetaData)
                atRegisteredMetaData{end+1} = atRegisteredMetaData{end}; %Add missing slice
            end
        end
    end

    if numel(atRegisteredMetaData) == numel(atFixedMetaData)

        for jj=1:numel(atRegisteredMetaData)
            atRegisteredMetaData{jj}.PixelSpacing(1) = atFixedMetaData{jj}.PixelSpacing(1);
            atRegisteredMetaData{jj}.PixelSpacing(2) = atFixedMetaData{jj}.PixelSpacing(2);
            atRegisteredMetaData{jj}.SliceThickness  = atFixedMetaData{jj}.SliceThickness;
            if atFixedMetaData{jj}.SpacingBetweenSlices
                atRegisteredMetaData{jj}.SpacingBetweenSlices  = atFixedMetaData{jj}.SpacingBetweenSlices;
            else
                atRegisteredMetaData{jj}.SpacingBetweenSlices = atRegisteredMetaData{jj}.SliceThickness;
            end

            if bUpdateDescription == true 
                atRegisteredMetaData{jj}.SeriesDescription  = sprintf('MOV-COREG %s', atRegisteredMetaData{jj}.SeriesDescription);
            end
        end

        for cc=1:numel(atRegisteredMetaData)
            atRegisteredMetaData{cc}.InstanceNumber  = atFixedMetaData{cc}.InstanceNumber;               
            atRegisteredMetaData{cc}.PatientPosition = atFixedMetaData{cc}.PatientPosition;               
            atRegisteredMetaData{cc}.ImagePositionPatient    = atFixedMetaData{cc}.ImagePositionPatient;               
            atRegisteredMetaData{cc}.ImageOrientationPatient = atFixedMetaData{cc}.ImageOrientationPatient;                              
            atRegisteredMetaData{cc}.SliceLocation  = atFixedMetaData{cc}.SliceLocation;               
            atRegisteredMetaData{cc}.NumberOfSlices = atFixedMetaData{cc}.NumberOfSlices;               
        end              
    else
        for jj=1:numel(atRegisteredMetaData)
            atRegisteredMetaData{jj}.PatientPosition = atFixedMetaData{1}.PatientPosition;               
            atRegisteredMetaData{jj}.PixelSpacing(1) = atFixedMetaData{1}.PixelSpacing(1);
            atRegisteredMetaData{jj}.PixelSpacing(2) = atFixedMetaData{1}.PixelSpacing(2);
            atRegisteredMetaData{jj}.SliceThickness  = atFixedMetaData{1}.SliceThickness;
            if atFixedMetaData{1}.SpacingBetweenSlices
                atRegisteredMetaData{jj}.SpacingBetweenSlices  = atFixedMetaData{1}.SpacingBetweenSlices;
            else
                atRegisteredMetaData{jj}.SpacingBetweenSlices = atRegisteredMetaData{jj}.SliceThickness;
            end

            atRegisteredMetaData{jj}.InstanceNumber  = jj;               
            atRegisteredMetaData{jj}.NumberOfSlices  = numel(atRegisteredMetaData); 
            if bUpdateDescription == true 
                atRegisteredMetaData{jj}.SeriesDescription  = sprintf('MOV-COREG %s', atRegisteredMetaData{jj}.SeriesDescription);
            end
        end 

        for cc=1:numel(atRegisteredMetaData)
            atRegisteredMetaData{cc}.PatientPosition = atFixedMetaData{1}.PatientPosition;               
            atRegisteredMetaData{cc}.ImagePositionPatient    = atFixedMetaData{1}.ImagePositionPatient;               
            atRegisteredMetaData{cc}.ImageOrientationPatient = atFixedMetaData{1}.ImageOrientationPatient;                            
        end    

        newSliceThickness = fSpacing;
        for cc=1:numel(atRegisteredMetaData)-1
            atRegisteredMetaData{cc+1}.ImagePositionPatient(3) = atRegisteredMetaData{cc}.ImagePositionPatient(3) + newSliceThickness;               
            atRegisteredMetaData{cc+1}.SliceLocation = atRegisteredMetaData{cc}.SliceLocation + newSliceThickness;               
        end 
    end

    iOffset = get(uiSeriesPtr('get'), 'Value');
    if iOffset <= numel(inputTemplate('get')) && bUpdateDescription == true 
        asDescription = seriesDescription('get');
        asDescription{iOffset} = sprintf('MOV-COREG %s', asDescription{iOffset});
        seriesDescription('set', asDescription);
    end  
end