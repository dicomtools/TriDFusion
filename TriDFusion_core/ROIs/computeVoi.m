function [tVoiComputed, atRoiComputed, imCData] = computeVoi(imInput, atInputMetaData, imVoi, atVoiMetaData, ptrVoiInput, atRoiInput, dSUVScale, bSUVUnit, bModifiedMatrix, bSegmented, bMovementApplied, transM)
%function [tVoiComputed, atRoiComputed, imCData] = computeVoi(imInput, atInputMetaData, imVoi, atVoiMetaData, ptrVoiInput, atRoiInput, dSUVScale, bSUVUnit, bModifiedMatrix, bSegmented, bMovementApplied, transM)
%Compute VOI values from ROIs object.
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

    if bModifiedMatrix  == false && ... 
       bMovementApplied == false && ...     
       bSegmented       == false 

        imCDataVoi = imInput;
        % atMetaData = atInputMetaData;
        imMask = false(size(imInput));

    else
        imCDataVoi = imVoi;        
        % atMetaData = atVoiMetaData;
        imMask = false(size(imVoi));
    end
    
    dNbRoi = numel(ptrVoiInput.RoisTag);
            
    imCMask  = cell(1, dNbRoi);
    imCData  = cell(1, dNbRoi);
    
    atRoiComputed = cell(1, dNbRoi);

    dNbCells = 0;
    dNbRemovedCells = 0;

    for uu=1:numel(ptrVoiInput.RoisTag)

        dTagOffset = find(strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[ptrVoiInput.RoisTag{uu}]} ), 1);

        if isempty(dTagOffset)
            continue;
        end
    
        tRoi = atRoiInput{dTagOffset};
        
        try
            [atRoiComputed{uu}, imCMask{uu}] = ...
                computeRoi(imInput, atInputMetaData, imVoi, atVoiMetaData, tRoi, dSUVScale, bSUVUnit, bModifiedMatrix, bSegmented, bMovementApplied, transM);                                      

        catch ME
            logErrorToFile(ME);
            
            tVoiComputed = [];
            atRoiComputed = [];
            return;
        end
                        
        switch lower(tRoi.Axe)    
            
            case 'axe'
                
                imCData{uu}  = imCDataVoi(:,:);
                                        
            case 'axes1'
                
                imCData{uu}  = permute(imCDataVoi(atRoiComputed{uu}.SliceNb,:,:), [3 2 1]);
                
            case 'axes2'
                
                imCData{uu} = permute(imCDataVoi(:,atRoiComputed{uu}.SliceNb,:), [3 1 2]);  
                
            case 'axes3'
                imCData{uu} = imCDataVoi(:,:,atRoiComputed{uu}.SliceNb);                   
        end 

    
        switch lower(tRoi.Axe)    
            case 'axe'
            imMask(:, :) = imMask(:, :)| imCMask{uu};

            case 'axes1'
            imMask(atRoiComputed{uu}.SliceNb, :, :) = ...
                imMask(atRoiComputed{uu}.SliceNb, :, :)|permuteBuffer(imCMask{uu}, 'coronal');
            
            case 'axes2'
            imMask(:, atRoiComputed{uu}.SliceNb, :) = ...
                imMask(:, atRoiComputed{uu}.SliceNb, :)|permuteBuffer(imCMask{uu}, 'sagittal');
            
            case 'axes3'
            imMask(:, :, atRoiComputed{uu}.SliceNb) = ...
            imMask(:, :, atRoiComputed{uu}.SliceNb)|imCMask{uu};
        end 

        if bSegmented      == true && ...
           bModifiedMatrix == true    % Can't use original matrix

            imCDataTemp =imCData{uu}(imCMask{uu}==1); 
            imCDataTemp = imCDataTemp(imCDataTemp>cropValue('get'));
            dNbCells = dNbCells+numel(imCDataTemp); 
            dNbRemovedCells = dNbRemovedCells+atRoiComputed{uu}.removedCells;
        else
            dNbCells = dNbCells+numel(imCData{uu}(imCMask{uu}==1)); 
       end         
    end 
    
    if bModifiedMatrix  == false && ... 
       bMovementApplied == false        % Can't use input buffer if movement have been applied
        if numel(imInput) ~= numel(imVoi)       
            atVoiMetaData = atInputMetaData; 
        end
    end
    
    xPixel = atVoiMetaData{1}.PixelSpacing(1)/10;
    yPixel = atVoiMetaData{1}.PixelSpacing(2)/10; 
    if size(imVoi, 3) == 1 
        zPixel = 1;
    else
        zPixel = computeSliceSpacing(atVoiMetaData)/10; 
        if zPixel == 0 % We can't determine the z size of a pixel, we will presume the pixel is square.
            zPixel = xPixel;
        end
    end
    
    dVoxVolume = xPixel * yPixel * zPixel; 
    
    imCMask = cat(1, imCMask{:});
    imCData = double(cat(1, imCData{:}));
    
    imCData = imCData(imCMask);                  
         
    if bSegmented      == true && ...
       bModifiedMatrix == true    % Can't use original matrix
   
        imCData = imCData(imCData>cropValue('get'));                
    end         

    tVoiComputed.cells = dNbCells;

    if isfield(atVoiMetaData{1}, 'RealWorldValueMappingSequence') % SUV SPECT
        if isfield(atVoiMetaData{1}.RealWorldValueMappingSequence.Item_1, 'MeasurementUnitsCodeSequence')
            if strcmpi(atVoiMetaData{1}.RealWorldValueMappingSequence.Item_1.MeasurementUnitsCodeSequence.Item_1.CodeValue, 'Bq/ml')
                sUnits = 'BQML';
            else
                sUnits = atVoiMetaData{1}.RealWorldValueMappingSequence.Item_1.MeasurementUnitsCodeSequence.Item_1.CodeValue;                                   
            end
        else
            sUnits = atVoiMetaData{1}.Units;            
        end
    else
        sUnits = atVoiMetaData{1}.Units;
    end

    if (strcmpi(atVoiMetaData{1}.Modality, 'pt') || ...
        strcmpi(atVoiMetaData{1}.Modality, 'nm'))&& ...
        strcmpi(sUnits, 'BQML' ) && ...     
        bSUVUnit == true 
        
        dMean =  mean(double(imCData), 'all');                  
        
        tVoiComputed.mean   = dMean * dSUVScale;

        tVoiComputed.min    = min   (imCData, [], 'all') * dSUVScale;
        tVoiComputed.max    = max   (imCData, [], 'all') * dSUVScale;
        tVoiComputed.median = median(imCData ,    'all') * dSUVScale;

        tVoiComputed.total  = dVoxVolume * dNbCells * dMean * dSUVScale;
        tVoiComputed.std  = std(imCData,[],'all') * dSUVScale;  
        tVoiComputed.sum  = sum(imCData, 'all') * dSUVScale;

        if ~isempty(tVoiComputed.max)
% 
%             % Initialization SUVpeak
%             ROIonlyPET = padarray(imCData * dSUVScale,[1 1 1],NaN);
% 
%             % SUVmax
%             [~,indMax] = max(ROIonlyPET(:));         
%             % SUVpeak (using 26 neighbors around SUVmax)
%             [indMaxX,indMaxY,indMaxZ] = ind2sub(size(ROIonlyPET),indMax);
%             connectivity = getneighbors(strel('arbitrary',conndef(3,'maximal')));
%             nPeak = length(connectivity);
%             neighborsMax = zeros(1,nPeak);
%             for i=1:nPeak
%                 if connectivity(i,1)+indMaxX ~= 0 && ...
%                    connectivity(i,2)+indMaxY ~= 0 && ...
%                    connectivity(i,3)+indMaxZ ~= 0
%                     neighborsMax(i) = ROIonlyPET(connectivity(i,1)+indMaxX,connectivity(i,2)+indMaxY,connectivity(i,3)+indMaxZ);
%                 end
%             end
%             tVoiComputed.peak = mean(neighborsMax(~isnan(neighborsMax)));
            tVoiComputed.peak = computePeak(imCData, dSUVScale);
        else
            tVoiComputed.peak = []; 
        end

        tVoiComputed.volume = dNbCells * dVoxVolume;

        if bSegmented      == true && ...
           bModifiedMatrix == true 
            tVoiComputed.removedVolume = dNbRemovedCells * dVoxVolume;
        end
        
    else   
        dMean = mean(imCData, 'all');
        
        tVoiComputed.mean   = dMean;

        tVoiComputed.min    = min(imCData   ,[],'all');
        tVoiComputed.max    = max(imCData   ,[],'all');
        tVoiComputed.median = median(imCData,   'all');
        tVoiComputed.std    = std(imCData   ,[],'all');    

        if ~isempty(tVoiComputed.max)

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
%             for i=1:nPeak
%                 if connectivity(i,1)+indMaxX ~= 0 && ...
%                    connectivity(i,2)+indMaxY ~= 0 && ...
%                    connectivity(i,3)+indMaxZ ~= 0
%                     neighborsMax(i) = ROIonlyPET(connectivity(i,1)+indMaxX,connectivity(i,2)+indMaxY,connectivity(i,3)+indMaxZ);
%                 end
%             end
%             tVoiComputed.peak = mean(neighborsMax(~isnan(neighborsMax)));   
            tVoiComputed.peak = computePeak(imCData);

        else
            tVoiComputed.peak = [];                   
        end

        tVoiComputed.total  = dVoxVolume * dNbCells * dMean;

        tVoiComputed.sum  = sum(imCData, 'all');
    
        tVoiComputed.volume = dNbCells * dVoxVolume;
        
        if bSegmented      == true && ...
           bModifiedMatrix == true 
            tVoiComputed.removedVolume = dNbRemovedCells * dVoxVolume;
        end

    end

%     tVoiComputed.maxDistance = computeVoiFarthestPoint(imMask, atMetaData);

%     tVoiComputedPlanes = computeVoiPlanesFarthestPoint(imMask, atMetaData);

    clear imMask;
    clear imCDataVoi;
%    clear imCData;
    clear imCMask;
end