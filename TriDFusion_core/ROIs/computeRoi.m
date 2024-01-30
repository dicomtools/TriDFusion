function [tRoiComputed, mask] = computeRoi(imInput, atInputMetaData, imRoi, atRoiMetaData, ptrRoi, dSUVScale, bSUVUnit, bModifiedMatrix, bSegmented, bDoseKernel, bMovementApplied)  
%function tRoiComputed = computeRoi(imInput, atInputMetaData, imRoi, atRoiMetaData, ptrRoi, dSUVScale, bSUVUnit, bModifiedMatrix, bSegmented, bDoseKernel, bMovementApplied)  
%Compute ROI values from ROI object.
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

%    bUseRoiTemplate = false;

     xScale = 1;
     yScale = 1;  
     zScale = 1;
            
    if bModifiedMatrix  == false && ... 
       bMovementApplied == false        % Can't use input buffer if movement have been applied
               
        if numel(imInput) ~= numel(imRoi)
            pTemp{1} = ptrRoi;
            [ptrRoiTemp, transM] = resampleROIs(imRoi, atRoiMetaData, imInput, atInputMetaData, pTemp, false);
            ptrRoi = ptrRoiTemp{1};
            
            if ~strcmpi(ptrRoi.Axe, 'axe')
                xScale = transM(2,2);
                yScale = transM(1,1);  
                zScale = transM(3,3);             
            end
        end
        
        imRoi  = imInput;

        atRoiMetaData = atInputMetaData;    
    end
    
    tRoiComputed.MaxDistances = ptrRoi.MaxDistances;
   
    if ptrRoi.SliceNb <= numel(atRoiMetaData)
        tSliceMeta = atRoiMetaData{ptrRoi.SliceNb};
    else
        tSliceMeta = atRoiMetaData{1};
    end
    
    switch lower(ptrRoi.Axe)    
        
        case 'axe'
            imCData = imRoi(:,:); 
            
        case 'axes1'
            imCData = permute(imRoi(ptrRoi.SliceNb,:,:), [3 2 1]);
            
        case 'axes2'
            imCData = permute(imRoi(:,ptrRoi.SliceNb,:), [3 1 2]);
            
        case 'axes3'
            imCData  = imRoi(:,:,ptrRoi.SliceNb);  
            
        otherwise   
            tRoiComputed = []; 
            mask = [];
            return;
     end
    
     if strcmpi(ptrRoi.Type, 'images.roi.line')
        mask = createMask(ptrRoi.Object, imCData);         
     else
        mask = roiTemplateToMask(ptrRoi, imCData);      
     end

    imCData = double(imCData(mask));
    
    if bSegmented  == true && ...      
       bModifiedMatrix == true % Can't use original buffer   
   
        imCData = imCData(imCData>cropValue('get'));                            
    end
    
%    if numel(imCData) == 0
%        % smaler than 1 pixel
%    end
        
    tRoiComputed.cells = numel(imCData);
    
    if isfield(tSliceMeta, 'RealWorldValueMappingSequence') % SUV SPECT
        if isfield(tSliceMeta.RealWorldValueMappingSequence.Item_1, 'MeasurementUnitsCodeSequence')
            if strcmpi(tSliceMeta.RealWorldValueMappingSequence.Item_1.MeasurementUnitsCodeSequence.Item_1.CodeValue, 'Bq/ml')
                sUnits = 'BQML';
            else
                sUnits = tSliceMeta.RealWorldValueMappingSequence.Item_1.MeasurementUnitsCodeSequence.Item_1.CodeValue;
            end
        else
            sUnits = tSliceMeta.Units;            
        end
    else
        sUnits = tSliceMeta.Units;
    end
    
    if isempty(tSliceMeta.PixelSpacing)
        xPixel = 1;
        yPixel = 1;
        zPixel = 1;
    else
        xPixel = tSliceMeta.PixelSpacing(1)/10;
        yPixel = tSliceMeta.PixelSpacing(2)/10;
        if size(imRoi, 3) == 1 
            zPixel = 1;
        else
            zPixel = computeSliceSpacing(atRoiMetaData)/10; 
            if zPixel == 0
                zPixel = 1;
            end
        end
    end            

    switch lower(ptrRoi.Axe)    

        case 'axe'
            voxVolume = xPixel * yPixel * zPixel;

        case 'axes1'
            voxVolume = xPixel * yPixel * zPixel * yScale;

        case 'axes2'
            voxVolume = xPixel * yPixel * zPixel * xScale;

        case 'axes3'
            voxVolume = xPixel * yPixel * zPixel * zScale;

        otherwise   
            voxVolume = [];
    end
        
    if (strcmpi(tSliceMeta.Modality, 'pt') || ...
        strcmpi(tSliceMeta.Modality, 'nm'))&& ...
        strcmpi(sUnits, 'BQML' ) && ...     
        bSUVUnit == true 

        nbVoxels = tRoiComputed.cells;

        tRoiComputed.min    = min(imCData,[],'all')  * dSUVScale;
        tRoiComputed.max    = max(imCData,[],'all')  * dSUVScale;
        tRoiComputed.mean   = mean(imCData, 'all')   * dSUVScale;
        tRoiComputed.median = median(imCData, 'all') * dSUVScale;

        volMean = mean(imCData, 'all'); % To verify              
        tRoiComputed.sum    = voxVolume * nbVoxels * volMean * dSUVScale;
        tRoiComputed.std    = std(imCData,[],'all') * dSUVScale;           

        if ~isempty(tRoiComputed.max)
%             % Initialization 
%             ROIonlyPET = padarray(imCData * dSUVScale,[1 1 1],NaN);
% 
%             % SUVmax
%             [~,indMax] = max(ROIonlyPET(:));         
%             % SUVpeak (using 26 neighbors around SUVmax)
%             [indMaxX,indMaxY,indMaxZ] = ind2sub(size(ROIonlyPET),indMax);
%             connectivity = getneighbors(strel('arbitrary',conndef(3,'maximal')));
%             nPeak = length(connectivity);
%             neighborsMax = zeros(1,nPeak);
% 
%             for i=1:nPeak
%                 if connectivity(i,1)+indMaxX ~= 0 && ...
%                    connectivity(i,2)+indMaxY ~= 0 && ...
%                    connectivity(i,3)+indMaxZ ~= 0
%                     neighborsMax(i) = ROIonlyPET(connectivity(i,1)+indMaxX,connectivity(i,2)+indMaxY,connectivity(i,3)+indMaxZ);
%                 end
%             end
%             tRoiComputed.peak = mean(neighborsMax(~isnan(neighborsMax)));
             tRoiComputed.peak = computePeak(imCData, dSUVScale);
        else
            tRoiComputed.peak = [];
        end
        
        switch lower(ptrRoi.Axe)    

            case 'axe'
                tRoiComputed.area = nbVoxels * xPixel * yPixel;

            case 'axes1'
                tRoiComputed.area = nbVoxels * xPixel * zPixel;

            case 'axes2'
                tRoiComputed.area = nbVoxels * yPixel * zPixel;

            case 'axes3'
                tRoiComputed.area = nbVoxels * xPixel * yPixel;

            otherwise   
                tRoiComputed.area = []; 
        end

    else
        tRoiComputed.min    = min(imCData,[],'all');
        tRoiComputed.max    = max(imCData,[],'all');
        tRoiComputed.mean   = mean(imCData, 'all');
        tRoiComputed.median = median(imCData, 'all');
        tRoiComputed.std    = std(imCData,[],'all');

        if ~isempty(tRoiComputed.max)
%             % Initialization SUVpeak
%             ROIonlyPET = padarray(imCData,[1 1 1],NaN);
% 
%             % SUVmax
%             [~,indMax] = max(ROIonlyPET(:));         
%             % SUVpeak (using 26 neighbors around SUVmax)
%             [indMaxX,indMaxY,indMaxZ] = ind2sub(size(ROIonlyPET),indMax);
%             connectivity = getneighbors(strel('arbitrary',conndef(3,'maximal')));
%             nPeak = length(connectivity);
%             neighborsMax = zeros(1,nPeak);
% 
%             for i=1:nPeak
%                if connectivity(i,1)+indMaxX ~= 0 && ...
%                    connectivity(i,2)+indMaxY ~= 0 && ...
%                    connectivity(i,3)+indMaxZ ~= 0
%                     neighborsMax(i) = ROIonlyPET(connectivity(i,1)+indMaxX,connectivity(i,2)+indMaxY,connectivity(i,3)+indMaxZ);
%                end
%             end
%             tRoiComputed.peak = mean(neighborsMax(~isnan(neighborsMax)));
            tRoiComputed.peak = computePeak(imCData);

        else
            tRoiComputed.peak = [];   
        end

        nbVoxels  = tRoiComputed.cells;
        volMean   = tRoiComputed.mean;                    
        tRoiComputed.sum = voxVolume * nbVoxels * volMean;

        switch lower(ptrRoi.Axe)    

            case 'axe'
                tRoiComputed.area = nbVoxels * xPixel * yPixel;

            case 'axes1'
                tRoiComputed.area = nbVoxels * xPixel * zPixel;

            case 'axes2'
                tRoiComputed.area = nbVoxels * yPixel * zPixel;

            case 'axes3'
                tRoiComputed.area = nbVoxels * xPixel * yPixel;

            otherwise   
                tRoiComputed.area = []; 
        end
    end   
    
    tRoiComputed.SliceNb = ptrRoi.SliceNb;
    tRoiComputed.Axe     = ptrRoi.Axe;
    tRoiComputed.Color   = ptrRoi.Color;
    tRoiComputed.Tag     = ptrRoi.Tag;
  
end   

