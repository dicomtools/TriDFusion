function [aRotatedDicomBuffer, aRotatedFusionBuffer, bRotationApplied] = applyManualRotation(aDicomBuffer, aFusionBuffer, bRotateFusion)
%function  [aRotatedDicomBuffer, aRotatedFusionBuffer, bRotationApplied] = applyManualRotation(aDicomBuffer, aFusionBuffer, bRotateFusion)
%Apply manual rotation to both, dicom and fusion buffer. 
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

    tInput = inputTemplate('get');
    
    dSeriesOffset      = get(uiSeriesPtr('get'), 'Value');
    dFusedSeriesOffset = get(uiFusedSeriesPtr('get'), 'Value');
    
    aRotatedDicomBuffer  = aDicomBuffer;
    aRotatedFusionBuffer = aFusionBuffer;

    atRefMetaData = dicomMetaData('get', [], dSeriesOffset);
    atDcmMetaData = dicomMetaData('get', [], dFusedSeriesOffset);
    if isempty(atDcmMetaData)
        atDcmMetaData = atInput(dFusionOffset).atDicomInfo;
    end

    bRotationApplied = false;
    
    if size(aRotatedDicomBuffer, 3) == 1 % 2D image
        [bApplyRotation, aAxe, dRotation] = fusedImageRotationValues('get', false, axePtr('get', [],  dSeriesOffset) );                  
        if bApplyRotation == true
            if ~isempty(aAxe)                    
                
                progressBar(0.999, 'Processing Axe Image Rotation, please wait');
                
                if bRotateFusion == true

                    atRoiInput = roiTemplate('get', dFusedSeriesOffset);
                    
                    if ~isempty(atRoiInput)
    
                        atRoiInput = rotateRoisFromAngle(atRoiInput, aRotatedDicomBuffer, atDcmMetaData, dRotation, 'axe', true);
                        roiTemplate('set', dFusedSeriesOffset, atRoiInput);      
                    end                    
                else
                    atRoiInput = roiTemplate('get', dSeriesOffset);
                    
                    if ~isempty(atRoiInput)
    
                        atRoiInput = rotateRoisFromAngle(atRoiInput, aRotatedDicomBuffer, atRefMetaData, dRotation, 'axe', true);
                        roiTemplate('set', dSeriesOffset, atRoiInput);      
                    end
                end

                aRotatedDicomBuffer  = rotateImageFromAngle(aRotatedDicomBuffer , aAxe, dRotation);
                if bRotateFusion == true
                    aRotatedFusionBuffer = rotateImageFromAngle(aRotatedFusionBuffer, aAxe, dRotation);
                end
                
                bRotationApplied = true;
                
                tInput(dFusedSeriesOffset).tMovement.bMovementApplied = true;
                if isempty(tInput(dFusedSeriesOffset).tMovement.atSeq{1}.sAxe)
                    tInput(dFusedSeriesOffset).tMovement.atSeq{1}.sAxe = 'Axe';
                    tInput(dFusedSeriesOffset).tMovement.atSeq{1}.dRotation = dRotation;                       
                else
                    dNewMovementOffset = numel(tInput(dFusedSeriesOffset).tMovement.atSeq)+1;
                    tInput(dFusedSeriesOffset).tMovement.atSeq{dNewMovementOffset}.sAxe = 'Axe';
                    tInput(dFusedSeriesOffset).tMovement.atSeq{dNewMovementOffset}.dRotation = dRotation;              
                end
                
            end
        end                
    else

        [bApplyRotation, aAxe, dRotation] = fusedImageRotationValues('get', false, axes1Ptr('get', [], dSeriesOffset) );                  
        if bApplyRotation == true % 3D images Coronal
            if ~isempty(aAxe)  

                progressBar(1/3, 'Processing Coronal Image Rotation, please wait');
                
                if bRotateFusion == true

                    atRoiInput = roiTemplate('get', dFusedSeriesOffset);
                    
                    if ~isempty(atRoiInput)
    
                        atRoiInput = rotateRoisFromAngle(atRoiInput, aRotatedDicomBuffer, atDcmMetaData, dRotation, 'axes1', true);
                        roiTemplate('set', dFusedSeriesOffset, atRoiInput);      
                    end                    
                else
                    atRoiInput = roiTemplate('get', dSeriesOffset);
                    
                    if ~isempty(atRoiInput)
    
                        atRoiInput = rotateRoisFromAngle(atRoiInput, aRotatedDicomBuffer, atRefMetaData, dRotation, 'axes1', true);
                        roiTemplate('set', dSeriesOffset, atRoiInput);      
                    end
                end

                aRotatedDicomBuffer  = rotateImageFromAngle(aRotatedDicomBuffer , aAxe, dRotation);
                if bRotateFusion == true
                    aRotatedFusionBuffer = rotateImageFromAngle(aRotatedFusionBuffer, aAxe, dRotation);
                end
                
                bRotationApplied = true;
                
                tInput(dFusedSeriesOffset).tMovement.bMovementApplied = true;
                if isempty(tInput(dFusedSeriesOffset).tMovement.atSeq{1}.sAxe)
                    tInput(dFusedSeriesOffset).tMovement.atSeq{1}.sAxe = 'Axes1';
                    tInput(dFusedSeriesOffset).tMovement.atSeq{1}.dRotation = dRotation;                       
                else
                    dNewMovementOffset = numel(tInput(dFusedSeriesOffset).tMovement.atSeq)+1;
                    tInput(dFusedSeriesOffset).tMovement.atSeq{dNewMovementOffset}.sAxe = 'Axes1';
                    tInput(dFusedSeriesOffset).tMovement.atSeq{dNewMovementOffset}.dRotation = dRotation;              
                end                
            end
        end

        [bApplyRotation, aAxe, dRotation] = fusedImageRotationValues('get', false, axes2Ptr('get', [], dSeriesOffset) );    

        if bApplyRotation == true % 3D images Sagittal

            if ~isempty(aAxe)       

                progressBar(2/3, 'Processing Sagittal Image Rotation, please wait');
 
                if bRotateFusion == true

                    atRoiInput = roiTemplate('get', dFusedSeriesOffset);
                    
                    if ~isempty(atRoiInput)
    
                        atRoiInput = rotateRoisFromAngle(atRoiInput, aRotatedDicomBuffer, atDcmMetaData, dRotation, 'axes2', true);
                        roiTemplate('set', dFusedSeriesOffset, atRoiInput);      
                    end                    
                else
                    atRoiInput = roiTemplate('get', dSeriesOffset);
                    
                    if ~isempty(atRoiInput)
    
                        atRoiInput = rotateRoisFromAngle(atRoiInput, aRotatedDicomBuffer, atRefMetaData, dRotation, 'axes2', true);
                        roiTemplate('set', dSeriesOffset, atRoiInput);      
                    end
                end

                aRotatedDicomBuffer  = rotateImageFromAngle(aRotatedDicomBuffer , aAxe, dRotation);
                if bRotateFusion == true
                    aRotatedFusionBuffer = rotateImageFromAngle(aRotatedFusionBuffer, aAxe, dRotation);
                end
                
                bRotationApplied = true;
                
                tInput(dFusedSeriesOffset).tMovement.bMovementApplied = true;                
                if isempty(tInput(dFusedSeriesOffset).tMovement.atSeq{1}.sAxe)
                    tInput(dFusedSeriesOffset).tMovement.atSeq{1}.sAxe = 'Axes2';
                    tInput(dFusedSeriesOffset).tMovement.atSeq{1}.dRotation = dRotation;                       
                else
                    dNewMovementOffset = numel(tInput(dFusedSeriesOffset).tMovement.atSeq)+1;
                    tInput(dFusedSeriesOffset).tMovement.atSeq{dNewMovementOffset}.sAxe = 'Axes2';
                    tInput(dFusedSeriesOffset).tMovement.atSeq{dNewMovementOffset}.dRotation = dRotation;              
                end                 
            end
        end

        [bApplyRotation, aAxe, dRotation] = fusedImageRotationValues('get', false, axes3Ptr('get', [], dSeriesOffset) );                  

        if bApplyRotation == true % 3D images Axial

            if ~isempty(aAxe)
                progressBar(0.999, 'Processing Axial Image Rotation, please wait');

                if bRotateFusion == true

                    atRoiInput = roiTemplate('get', dFusedSeriesOffset);
                    
                    if ~isempty(atRoiInput)
    
                        atRoiInput = rotateRoisFromAngle(atRoiInput, aRotatedDicomBuffer, atDcmMetaData, dRotation, 'axes3', true);
                        roiTemplate('set', dFusedSeriesOffset, atRoiInput);      
                    end                    
                else
                    atRoiInput = roiTemplate('get', dSeriesOffset);
                    
                    if ~isempty(atRoiInput)
    
                        atRoiInput = rotateRoisFromAngle(atRoiInput, aRotatedDicomBuffer, atRefMetaData, dRotation, 'axes3', true);
                        roiTemplate('set', dSeriesOffset, atRoiInput);      
                    end
                end

                aRotatedDicomBuffer  = rotateImageFromAngle(aRotatedDicomBuffer , aAxe, dRotation);
                if bRotateFusion == true

                    aRotatedFusionBuffer = rotateImageFromAngle(aRotatedFusionBuffer, aAxe, dRotation);
                end
                
                bRotationApplied = true;
                
                tInput(dFusedSeriesOffset).tMovement.bMovementApplied = true;
                if isempty(tInput(dFusedSeriesOffset).tMovement.atSeq{1}.sAxe)
                    tInput(dFusedSeriesOffset).tMovement.atSeq{1}.sAxe = 'Axes3';
                    tInput(dFusedSeriesOffset).tMovement.atSeq{1}.dRotation = dRotation;                       
                else
                    dNewMovementOffset = numel(tInput(dFusedSeriesOffset).tMovement.atSeq)+1;
                    tInput(dFusedSeriesOffset).tMovement.atSeq{dNewMovementOffset}.sAxe = 'Axes3';
                    tInput(dFusedSeriesOffset).tMovement.atSeq{dNewMovementOffset}.dRotation = dRotation;              
                end                 
            end
         end
    end
    
    inputTemplate('set', tInput);

    progressBar(1, 'Ready');

end