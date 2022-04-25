function [tRoiComputed, mask] = computeRoi(imInput, atInputMetaData, imRoi, atRoiMetaData, ptrRoi, dSUVScale, bSUVUnit, bSegmented, bDoseKernel, bMovementApplied)  
%function tRoiComputed = computeRoi(imInput, atInputMetaData, imRoi, atRoiMetaData, ptrRoi, dSUVScale, bSUVUnit, bSegmented, bDoseKernel, bMovementApplied)  
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

    bUseRoiTemplate = false;
        
    if bSegmented == false && ...
       bDoseKernel == false && ... % Can't use input buffer for a kernel
       bMovementApplied == false   % Can't use input buffer if movement have been applied
        if numel(imInput) ~= numel(imRoi)
            pTemp{1} = ptrRoi;
            ptrRoiTemp = resampleROIs(imRoi, atRoiMetaData, imInput, atInputMetaData, pTemp, false);
            ptrRoi = ptrRoiTemp{1};
            
            imRoi  = imInput;
           
            atRoiMetaData = atInputMetaData;
    
            bUseRoiTemplate = true;
        end        
    end
    
    dImInputSize = numel(imInput);
    dImRoiSize   = numel(imRoi);
    
    tRoiComputed.MaxDistances = ptrRoi.MaxDistances;
   
    if ptrRoi.SliceNb <= numel(atRoiMetaData)
        tSliceMeta = atRoiMetaData{ptrRoi.SliceNb};
    else
        tSliceMeta = atRoiMetaData{1};
    end
    
    if size(imRoi, 3) == 1 
        if strcmpi(ptrRoi.Axe, 'Axe')
            imRoi=imRoi(:,:);
            imCData = imRoi; 
            imCInput = imInput;
       end
    else
        if strcmpi(ptrRoi.Axe, 'Axes1')
            imCData = permute(imRoi(ptrRoi.SliceNb,:,:), [3 2 1]);
            if dImInputSize == dImRoiSize
                imCInput = permute(imInput(ptrRoi.SliceNb,:,:), [3 2 1]);
            else
                imCInput = 0;
            end
       end

        if strcmpi(ptrRoi.Axe, 'Axes2')                    
            imCData = permute(imRoi(:,ptrRoi.SliceNb,:), [3 1 2]) ;
            if dImInputSize == dImRoiSize
                imCInput = permute(imInput(:,ptrRoi.SliceNb,:), [3 1 2]);
            else
                imCInput = 0;
            end
        end

        if strcmpi(ptrRoi.Axe, 'Axes3')
            imCData  = imRoi(:,:,ptrRoi.SliceNb);  
            if dImInputSize == dImRoiSize
                imCInput = imInput(:,:,ptrRoi.SliceNb);  
            else
                imCInput = 0;
            end
        end
    end
    
    if bUseRoiTemplate == true
        mask = roiTemplateToMask(ptrRoi, imCData);      
    else
        mask = createMask(ptrRoi.Object, imCData);         
    end

    if bSegmented == true && ...
       bDoseKernel == false && ... % Can't use input buffer for a kernel
       bMovementApplied == false   % Can't use input buffer if movement have been applied  
   
        dInputMin = min(imInput, [], 'all');
        imCDataMasked = imCData(mask);
        imCDataMasked = imCDataMasked(imCDataMasked>dInputMin);
    else    
        imCDataMasked = imCData(mask);
    end
    
    if numel(double(imCDataMasked)) == 0
        % smaler than 1 pixel
    end
        
    tRoiComputed.cells = numel(double(imCDataMasked));
    
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
    
    if (strcmpi(tSliceMeta.Modality, 'pt') || ...
        strcmpi(tSliceMeta.Modality, 'nm'))&& ...
        strcmpi(sUnits, 'BQML' ) && ...     
        bSUVUnit == true 

        xAxial = tSliceMeta.PixelSpacing(1)/10;
        yAxial = tSliceMeta.PixelSpacing(2)/10; 
        if size(imRoi, 3) == 1 
            zAxial = 1;
        else
            zAxial = computeSliceSpacing(atRoiMetaData); 
            zAxial = zAxial/10;
        end

        if strcmpi(ptrRoi.Axe, 'Axe')
             xPixel = xAxial;
             yPixel = yAxial;
             zPixel = zAxial;                 
        end    

        if strcmpi(ptrRoi.Axe, 'Axes1') % Coronal    

            if strcmpi(imageOrientation('get'), 'coronal')
                xPixel = xAxial;
                yPixel = yAxial;
                zPixel = zAxial;                                    
            end
            
            if strcmpi(imageOrientation('get'), 'sagittal')
                xPixel = yAxial;
                yPixel = xAxial;
                zPixel = zAxial;                                    
            end
            
            if strcmpi(imageOrientation('get'), 'axial')
                xPixel = yAxial;
                yPixel = zAxial;
                zPixel = xAxial;                                    
           end
       end

       if strcmpi(ptrRoi.Axe, 'Axes2') % Sagittal   
           
            if strcmpi(imageOrientation('get'), 'coronal')
                xPixel = yAxial;
                yPixel = xAxial;
                zPixel = zAxial;                                    
            end
           
            if strcmpi(imageOrientation('get'), 'sagittal')
                xPixel = zAxial;
                yPixel = yAxial;
                zPixel = xAxial;                                    
            end
            
            if strcmpi(imageOrientation('get'), 'axial')
                xPixel = yAxial;
                yPixel = zAxial;
                zPixel = xAxial;                                    
            end                
        end

        if strcmpi(ptrRoi.Axe, 'Axes3') % Axial  

            if strcmpi(imageOrientation('get'), 'coronal')
                xPixel = xAxial;
                yPixel = zAxial;
                zPixel = yAxial;                                    
            end
            
            if strcmpi(imageOrientation('get'), 'sagittal')
                xPixel = yAxial;
                yPixel = zAxial;
                zPixel = xAxial;                                    
            end
            
            if strcmpi(imageOrientation('get'), 'axial')
                xPixel = xAxial;
                yPixel = yAxial;
                zPixel = zAxial;                                    
            end
        end

        voxVolume = xPixel * yPixel * zPixel;
        nbVoxels = tRoiComputed.cells;

        tRoiComputed.min    = min(double(imCDataMasked),[],'all')  * dSUVScale;
        tRoiComputed.max    = max(double(imCDataMasked),[],'all')  * dSUVScale;
        tRoiComputed.mean   = mean(double(imCDataMasked), 'all')   * dSUVScale;
        tRoiComputed.median = median(double(imCDataMasked), 'all') * dSUVScale;

        volMean = mean(double(imCDataMasked), 'all'); % To verify              
        tRoiComputed.sum    = voxVolume * nbVoxels * volMean * dSUVScale;
        tRoiComputed.std    = std(double(imCDataMasked),[],'all') * dSUVScale;           

        if ~isempty(tRoiComputed.max)
            % Initialization 
            ROIonlyPET = padarray(imCDataMasked * dSUVScale,[1 1 1],NaN);

            % SUVmax
            [~,indMax] = max(ROIonlyPET(:));         
            % SUVpeak (using 26 neighbors around SUVmax)
            [indMaxX,indMaxY,indMaxZ] = ind2sub(size(ROIonlyPET),indMax);
            connectivity = getneighbors(strel('arbitrary',conndef(3,'maximal')));
            nPeak = length(connectivity);
            neighborsMax = zeros(1,nPeak);

            for i=1:nPeak
                if connectivity(i,1)+indMaxX ~= 0 && ...
                   connectivity(i,2)+indMaxY ~= 0 && ...
                   connectivity(i,3)+indMaxZ ~= 0
                    neighborsMax(i) = ROIonlyPET(connectivity(i,1)+indMaxX,connectivity(i,2)+indMaxY,connectivity(i,3)+indMaxZ);
                end
            end
            tRoiComputed.peak = mean(neighborsMax(~isnan(neighborsMax)));
        else
            tRoiComputed.peak = [];
        end

    %    tRoiComputed.area   = bwarea(mask) * xPixel * yPixel;

        tRoiComputed.area = numel(imCDataMasked) * xPixel * yPixel;

        if numel(imCInput) == numel(imCData)
            tRoiComputed.subtraction = max(imCInput(mask)-imCData(mask),[],'all') * dSUVScale;
        end

    else
        tRoiComputed.min    = min(double(imCDataMasked),[],'all');
        tRoiComputed.max    = max(double(imCDataMasked),[],'all');
        tRoiComputed.mean   = mean(double(imCDataMasked), 'all');
        tRoiComputed.median = median(double(imCDataMasked), 'all');
        tRoiComputed.std    = std(double(imCDataMasked),[],'all');

        if ~isempty(tRoiComputed.max)
            % Initialization SUVpeak
            ROIonlyPET = padarray(imCDataMasked,[1 1 1],NaN);

            % SUVmax
            [~,indMax] = max(ROIonlyPET(:));         
            % SUVpeak (using 26 neighbors around SUVmax)
            [indMaxX,indMaxY,indMaxZ] = ind2sub(size(ROIonlyPET),indMax);
            connectivity = getneighbors(strel('arbitrary',conndef(3,'maximal')));
            nPeak = length(connectivity);
            neighborsMax = zeros(1,nPeak);

            for i=1:nPeak
               if connectivity(i,1)+indMaxX ~= 0 && ...
                   connectivity(i,2)+indMaxY ~= 0 && ...
                   connectivity(i,3)+indMaxZ ~= 0
                    neighborsMax(i) = ROIonlyPET(connectivity(i,1)+indMaxX,connectivity(i,2)+indMaxY,connectivity(i,3)+indMaxZ);
               end
            end
            tRoiComputed.peak = mean(neighborsMax(~isnan(neighborsMax)));
        else
            tRoiComputed.peak = [];   
        end

        if isempty(tSliceMeta.PixelSpacing)
            xAxial = 0;
            yAxial = 0;
            zAxial = 0;
        else
            xAxial = tSliceMeta.PixelSpacing(1)/10;
            yAxial = tSliceMeta.PixelSpacing(2)/10;
            if size(imRoi, 3) == 1 
                zAxial = 1;
            else
                zAxial = computeSliceSpacing(atRoiMetaData); 
                zAxial = zAxial/10;
            end
        end            

        if strcmpi(ptrRoi.Axe, 'Axe')
             xPixel = xAxial;
             yPixel = yAxial;
             zPixel = zAxial;                 
        end    

        if strcmpi(ptrRoi.Axe, 'Axes1') % Coronal    

            if strcmpi(imageOrientation('get'), 'coronal')
                xPixel = xAxial;
                yPixel = yAxial;
                zPixel = zAxial;                                    
            end
            
            if strcmpi(imageOrientation('get'), 'sagittal')
                xPixel = yAxial;
                yPixel = xAxial;
                zPixel = zAxial;                                    
            end
            
            if strcmpi(imageOrientation('get'), 'axial')
                xPixel = yAxial;
                yPixel = zAxial;
                zPixel = xAxial;                                    
           end
       end

       if strcmpi(ptrRoi.Axe, 'Axes2') % Sagittal   
           
            if strcmpi(imageOrientation('get'), 'coronal')
                xPixel = yAxial;
                yPixel = xAxial;
                zPixel = zAxial;                                    
            end
           
            if strcmpi(imageOrientation('get'), 'sagittal')
                xPixel = zAxial;
                yPixel = yAxial;
                zPixel = xAxial;                                    
            end
            
            if strcmpi(imageOrientation('get'), 'axial')
                xPixel = yAxial;
                yPixel = zAxial;
                zPixel = xAxial;                                    
            end                
        end

        if strcmpi(ptrRoi.Axe, 'Axes3') % Axial  

            if strcmpi(imageOrientation('get'), 'coronal')
                xPixel = xAxial;
                yPixel = zAxial;
                zPixel = yAxial;                                    
            end
            
            if strcmpi(imageOrientation('get'), 'sagittal')
                xPixel = yAxial;
                yPixel = zAxial;
                zPixel = xAxial;                                    
            end
            
            if strcmpi(imageOrientation('get'), 'axial')
                xPixel = xAxial;
                yPixel = yAxial;
                zPixel = zAxial;                                    
            end
        end

        voxVolume = xPixel * yPixel * zPixel;
        nbVoxels  = tRoiComputed.cells;
        volMean   = tRoiComputed.mean;                    
        tRoiComputed.sum = voxVolume * nbVoxels * volMean;

%         tRoiComputed.area = bwarea(mask) * (xPixel/10) * (yPixel/10);
        tRoiComputed.area = numel(imCDataMasked) * xPixel * yPixel;

        if numel(imCInput) == numel(imCData) 
            if bSegmented == true
                tRoiComputed.subtraction = max(imCInput(mask)-imCData(mask), [], 'all');
            end
        end
    end   
    
    tRoiComputed.SliceNb = ptrRoi.SliceNb;
    tRoiComputed.Axe     = ptrRoi.Axe;
    tRoiComputed.Color   = ptrRoi.Color;
    tRoiComputed.Tag     = ptrRoi.Tag;
  
end   

