function [imRegistered, atRegisteredMetaData, Rmoving, Rfixed, geomtform] = registerImage(imToRegister, atImToRegisterMetaData, imReference, atReferenceMetaData, aLogicalMask, sType, sModality, tOptimizer, tMetric, bRefOutputView, bUpdateDescription, registratedGeomtform)
%function [imRegistered, atRegisteredMetaData, Rmoving, Rfixed, geomtform] = registerImage(imToRegister, atImToRegisterMetaData, dImToRegisterOffset,imReference, atReferenceMetaData, dReferenceOffset, sType, sModality, tOptimizer, tMetric,  bRefOutputView, bUpdateDescription, registratedGeomtform)
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
    
    
    if bRefOutputView == false 

        if ~isequal(size(imReference), size(imToRegister))      
            
            [imReference, atReferenceMetaData] = ...
                resampleImage(imReference, atReferenceMetaData, imToRegister, atImToRegisterMetaData, 'Nearest', true, false);
        end
    end
    
    fixedSliceThickness = computeSliceSpacing(atReferenceMetaData);
    
    if fixedSliceThickness == 0           
        fixedSliceThickness = 1;
    end
    
    if atReferenceMetaData{1}.PixelSpacing(1) == 0 && ...
       atReferenceMetaData{1}.PixelSpacing(2) == 0 
        for jj=1:numel(atReferenceMetaData)
            atReferenceMetaData{1}.PixelSpacing(1) =1;
            atReferenceMetaData{1}.PixelSpacing(2) =1;
        end       
    end
        
    if size(imReference, 3) == 1
       Rfixed  = imref2d(size(imReference),atReferenceMetaData{1}.PixelSpacing(2),atReferenceMetaData{1}.PixelSpacing(1));  
    else
       Rfixed  = imref3d(size(imReference),atReferenceMetaData{1}.PixelSpacing(2),atReferenceMetaData{1}.PixelSpacing(1), fixedSliceThickness);  
    end

    movingSliceThickness = computeSliceSpacing(atImToRegisterMetaData);        
    
    if movingSliceThickness == 0           
        movingSliceThickness = 1;
    end
    
    if atImToRegisterMetaData{1}.PixelSpacing(1) == 0 && ...
       atImToRegisterMetaData{1}.PixelSpacing(2) == 0 
        for jj=1:numel(atImToRegisterMetaData)
            atImToRegisterMetaData{1}.PixelSpacing(1) =1;
            atImToRegisterMetaData{1}.PixelSpacing(2) =1;
        end       
    end      
        
    if size(imToRegister, 3) == 1
       Rmoving = imref2d(size(imToRegister), atImToRegisterMetaData{1}.PixelSpacing(2), atImToRegisterMetaData{1}.PixelSpacing(1));                 
    else         
       Rmoving = imref3d(size(imToRegister), atImToRegisterMetaData{1}.PixelSpacing(2), atImToRegisterMetaData{1}.PixelSpacing(1), movingSliceThickness);
    end
       
    bMonomodal = false;
    if strcmpi(sModality, 'Automatic') % Must be the same modality, same camera & same intensity,
        if  strcmpi(atReferenceMetaData{1}.Modality, atImToRegisterMetaData{1}.Modality) && ... % Same modality
            strcmpi(atReferenceMetaData{1}.ManufacturerModelName, atImToRegisterMetaData{1}.ManufacturerModelName) && ... % Same camera
            strcmpi(atReferenceMetaData{1}.ProtocolName, atImToRegisterMetaData{1}.ProtocolName) % Same protocol 
                bMonomodal = true;
        end        
    else
        if strcmpi(sModality, 'Monomodal') 
            bMonomodal = true;
        end        
    end
      
    if bMonomodal == true
      
        [optimizer, metric] = imregconfig('monomodal');
        
        optimizer.GradientMagnitudeTolerance = tOptimizer.GradientMagnitudeTolerance;
        optimizer.MinimumStepLength = tOptimizer.MinimumStepLength;
        optimizer.MaximumStepLength = tOptimizer.MaximumStepLength;
        optimizer.RelaxationFactor  = tOptimizer.RelaxationFactor;
    else
    
        [optimizer, metric] = imregconfig('multimodal');

        metric.NumberOfSpatialSamples = tMetric.NumberOfSpatialSamples;
        metric.NumberOfHistogramBins  = tMetric.NumberOfHistogramBins;
        metric.UseAllPixels           = tMetric.UseAllPixels;

        optimizer.InitialRadius = tOptimizer.InitialRadius;
        optimizer.Epsilon       = tOptimizer.Epsilon;
        optimizer.GrowthFactor  = tOptimizer.GrowthFactor;
    end
    
    optimizer.MaximumIterations = tOptimizer.MaximumIterations;
    
    dMovingMin = double(min(imToRegister,[],'all'));
   
    if bRefOutputView == true
        Routput = Rfixed;
    else
        Routput = Rmoving;
    end
       
    
    if exist('registratedGeomtform', 'var')        
                       
            imRegistered = imwarp(imToRegister, Rmoving, registratedGeomtform, 'bicubic', 'OutputView', Routput, 'FillValues', dMovingMin);  
            geomtform = registratedGeomtform;
    else

        if ~isempty(aLogicalMask(aLogicalMask)) % Use a logical mask 

            imToRegisterMasked = imToRegister;  

            if ~isequal(size(imToRegisterMasked), size(aLogicalMask))
                [aLogicalMask, ~] = ...
                    resampleImage(double(aLogicalMask), atReferenceMetaData, imToRegister, atImToRegisterMetaData, 'Nearest', true, false);                
                aLogicalMask = logical(imbinarize(aLogicalMask));
            end

            imToRegisterMasked(aLogicalMask==0) = min(imToRegister, [], 'all'); 

            imReferenceMasked = imReference;          
            imReferenceMasked(aLogicalMask==0) = min(imReference, [], 'all');  

            geomtform = imregtform(imToRegisterMasked, Rmoving, imReferenceMasked, Rfixed, sType, optimizer, metric);

            clear imToRegisterMasked;
        else    
            geomtform = imregtform(imToRegister, Rmoving, imReference, Rfixed, sType, optimizer, metric);
        end
        
        imRegistered = imwarp(imToRegister, Rmoving, geomtform, 'OutputView', Routput, 'FillValues', dMovingMin); 
    end
               
    if bRefOutputView == true 
        
%        newSliceThickness = fixedSliceThickness;        
     
        dimsRef = size(imReference);        
%        dimsDcm = size(imToRegister);
        
        %Add missing slice
     
        if dimsRef(3) < numel(atImToRegisterMetaData) && ...
           numel(atImToRegisterMetaData) ~= 1   
            atImToRegisterMetaData = atImToRegisterMetaData(1:dimsRef(3));

        elseif dimsRef(3) > numel(atImToRegisterMetaData) && ...
               numel(atImToRegisterMetaData) ~= 1   

            for cc=1:dimsRef(3)- numel(atImToRegisterMetaData)
                atImToRegisterMetaData{end+1} = atImToRegisterMetaData{end};
            end
        end

        for jj=1:numel(atImToRegisterMetaData)
            
            if numel(atReferenceMetaData) == numel(atImToRegisterMetaData)
                atImToRegisterMetaData{jj}.PatientPosition = atReferenceMetaData{jj}.PatientPosition;  
                atImToRegisterMetaData{jj}.InstanceNumber  = atReferenceMetaData{jj}.InstanceNumber;               
                atImToRegisterMetaData{jj}.NumberOfSlices  = atReferenceMetaData{jj}.NumberOfSlices;

                atImToRegisterMetaData{jj}.PixelSpacing(1) = atReferenceMetaData{jj}.PixelSpacing(1);
                atImToRegisterMetaData{jj}.PixelSpacing(2) = atReferenceMetaData{jj}.PixelSpacing(2);
                
                if atImToRegisterMetaData{jj}.SliceThickness ~= 0
                    atImToRegisterMetaData{jj}.SliceThickness  = atReferenceMetaData{jj}.SliceThickness;
                end
                
                if atReferenceMetaData{jj}.SpacingBetweenSlices == 0
                    atImToRegisterMetaData{jj}.SpacingBetweenSlices = fixedSliceThickness;        
                else
                    atImToRegisterMetaData{jj}.SpacingBetweenSlices = atReferenceMetaData{jj}.SpacingBetweenSlices;        
                end

            else
                atImToRegisterMetaData{jj}.PatientPosition = atReferenceMetaData{1}.PatientPosition;  
                atImToRegisterMetaData{jj}.InstanceNumber  = jj;               
                atImToRegisterMetaData{jj}.NumberOfSlices  = numel(atReferenceMetaData);    

                atImToRegisterMetaData{jj}.PixelSpacing(1) = atReferenceMetaData{1}.PixelSpacing(1);
                atImToRegisterMetaData{jj}.PixelSpacing(2) = atReferenceMetaData{1}.PixelSpacing(2);
                
                if atImToRegisterMetaData{jj}.SliceThickness ~= 0
                    atImToRegisterMetaData{jj}.SliceThickness  = atReferenceMetaData{1}.SliceThickness;
                end
                
                if atReferenceMetaData{1}.SpacingBetweenSlices == 0
                    atImToRegisterMetaData{jj}.SpacingBetweenSlices = fixedSliceThickness;        
                else
                    atImToRegisterMetaData{jj}.SpacingBetweenSlices = atReferenceMetaData{1}.SpacingBetweenSlices;        
                end                
            end
            
            
            atImToRegisterMetaData{jj}.Rows    = dimsRef(1);
            atImToRegisterMetaData{jj}.Columns = dimsRef(2);
            
        end
        
        if (numel(atImToRegisterMetaData) == numel(atReferenceMetaData)) 
            for cc=1:numel(atImToRegisterMetaData)
                atImToRegisterMetaData{cc}.ImagePositionPatient = atReferenceMetaData{cc}.ImagePositionPatient;
                atImToRegisterMetaData{cc}.SliceLocation = atReferenceMetaData{cc}.SliceLocation;
            end
        else

            for cc=1:numel(atImToRegisterMetaData)-1
                if atImToRegisterMetaData{1}.ImagePositionPatient(3) < atImToRegisterMetaData{2}.ImagePositionPatient(3)
                    atImToRegisterMetaData{cc+1}.ImagePositionPatient(3) = atImToRegisterMetaData{cc}.ImagePositionPatient(3) + fixedSliceThickness;               
                    atImToRegisterMetaData{cc+1}.SliceLocation = atImToRegisterMetaData{cc}.SliceLocation + fixedSliceThickness; 
                else
                    atImToRegisterMetaData{cc+1}.ImagePositionPatient(3) = atImToRegisterMetaData{cc}.ImagePositionPatient(3) - fixedSliceThickness;               
                    atImToRegisterMetaData{cc+1}.SliceLocation = atImToRegisterMetaData{cc}.SliceLocation - fixedSliceThickness;             
                end
            end 
        end
    end
    
    atRegisteredMetaData = atImToRegisterMetaData;    
    
    if bUpdateDescription == true

        for jj=1:numel(atRegisteredMetaData)
            atRegisteredMetaData{jj}.SeriesDescription  = sprintf('MOV-COREG %s', atRegisteredMetaData{jj}.SeriesDescription);
        end

        dMovingSeriesOffset = [];
        atInput = inputTemplate('get');
        for jj=1:numel(atInput)
            if strcmpi(atInput(jj).atDicomInfo{1}.SeriesInstanceUID, atImToRegisterMetaData{1}.SeriesInstanceUID)
                dMovingSeriesOffset = jj;
                break;
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
         
end