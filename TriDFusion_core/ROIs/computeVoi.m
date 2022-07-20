function [tVoiComputed, atRoiComputed, voiMask] = computeVoi(imInput, atInputMetaData, imRoi, atVoiMetaData, ptrVoiInput, tRoiInput, dSUVScale, bSUVUnit, bSegmented, bDoseKernel, bMovementApplied)
%function [tVoiComputed, atRoiComputed, voiMask] = computeVoi(imInput, atInputMetaData, imRoi, atVoiMetaData, ptrVoiInput, tRoiInput, dSUVScale, bSUVUnit, bSegmented, bDoseKernel, bMovementApplied)
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

    sAxe = [];
    
    xAxial = 0;
    yAxial = 0; 
    zAxial = 0;

    dNbRoi = 0;
    
    atRoiMetaData = atVoiMetaData;            

    imRoiCompute = imRoi;
    if bSegmented == false && ...
       bDoseKernel == false && ... % Can't use input buffer for a kernel
       bMovementApplied == false   % Can't use input buffer if movement have been applied 
   
        if numel(imInput) ~= numel(imRoi)           
            atVoiMetaData = atInputMetaData; 
            imRoi = imInput;
        end        
    end    
    
    dImInputSize = numel(imInput);
    dImRoiSize   = numel(imRoi);
       
    dSpacing = computeSliceSpacing(atVoiMetaData);

    for bb=1: numel(ptrVoiInput.RoisTag)
        for cc=1:numel(tRoiInput)
            if strcmpi(ptrVoiInput.RoisTag{bb}, tRoiInput{cc}.Tag)                
                     
                try
                    [atRoiComputed{bb}, roiMask] = computeRoi(imInput, atInputMetaData, imRoiCompute, atRoiMetaData, tRoiInput{cc}, dSUVScale, bSUVUnit, bSegmented, bDoseKernel, bMovementApplied);                                      
                catch
                    break;
                end
                
                tVoiMask{bb}.SliceNb = atRoiComputed{bb}.SliceNb;
                tVoiMask{bb}.Axe     = atRoiComputed{bb}.Axe;

                if ~exist('voiMask', 'var')
                    voiMask = roiMask;                      
                else
                    voiMask = cat(2, voiMask , roiMask);
                end
                
                if size(imRoi, 3) == 1 
                    if strcmpi(tRoiInput{cc}.Axe, 'Axe')
                        imRoi=imRoi(:,:);
                        imCData  = imRoi;   
                        imCInput = imInput;
                        sAxe = 'Axe';                           
                   end
                else
                    if strcmpi(tRoiInput{cc}.Axe, 'Axes1')
                        imCData  = permute(imRoi(tRoiInput{cc}.SliceNb,:,:), [3 2 1]);
                        if dImInputSize == dImRoiSize
                            imCInput = permute(imInput(tRoiInput{cc}.SliceNb,:,:), [3 2 1]);
                        else
                            imCInput = 0;
                        end
                        sAxe = 'Axes1';
                    end

                    if strcmpi(tRoiInput{cc}.Axe, 'Axes2')                    
                        imCData  = permute(imRoi(:,tRoiInput{cc}.SliceNb,:), [3 1 2]) ;
                        if dImInputSize == dImRoiSize
                            imCInput = permute(imInput(:,tRoiInput{cc}.SliceNb,:), [3 1 2]) ;
                        else
                            imCInput = 0;
                        end                                
                        sAxe = 'Axes2';
                    end

                    if strcmpi(tRoiInput{cc}.Axe, 'Axes3')
                        imCData  = imRoi(:,:,tRoiInput{cc}.SliceNb);  
                        if dImInputSize == dImRoiSize
                            imCInput = imInput(:,:,tRoiInput{cc}.SliceNb); 
                        else
                            imCInput = 0;
                        end                                   
                        sAxe = 'Axes3';
                   end
                end
                
                if ~exist('voiCData', 'var')
                    voiCData  = imCData;
                    voiCInput = imCInput;
                else
                    voiCData  = cat(2, voiCData, imCData);
                    voiCInput = cat(2, voiCInput, imCInput);
               end

                if numel(atVoiMetaData) >= atRoiComputed{bb}.SliceNb
                    xAxial = xAxial + (atVoiMetaData{atRoiComputed{bb}.SliceNb}.PixelSpacing(1)/10);
                    yAxial = yAxial + (atVoiMetaData{atRoiComputed{bb}.SliceNb}.PixelSpacing(2)/10); 
                else
                    xAxial = xAxial + (atVoiMetaData{1}.PixelSpacing(1)/10);
                    yAxial = yAxial + (atVoiMetaData{1}.PixelSpacing(2)/10); 
                end

                zAxial = zAxial + (dSpacing/10); % To do, use slice location for CT and MR

                dNbRoi = dNbRoi+1;
                break;
            end
        end
    end        
    
    
    if ~isempty(sAxe)

        if strcmpi(sAxe, 'Axe')
            xPixel = xAxial;
            yPixel = yAxial;
            zPixel = zAxial;                 
       end   

        if strcmpi(sAxe, 'Axes1') % Coronal    

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

       if strcmpi(sAxe, 'Axes2') % Sagittal   
           
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

        if strcmpi(sAxe, 'Axes3') % Axial  

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

        xPixel = xPixel / dNbRoi;
        yPixel = yPixel / dNbRoi; 
        zPixel = zPixel / dNbRoi;

        if exist('voiCData', 'var') && ...
           exist('voiMask' , 'var')
       
            if bSegmented == false && ...
               bDoseKernel == false && ... % Can't use input buffer for a kernel
               bMovementApplied == false   % Can't use input buffer if movement have been applied 
           
                voiCDataMasked = voiCData(voiMask);
                voiCDataMasked = voiCDataMasked(voiCDataMasked>cropValue('get'));
            else    
                voiCDataMasked = voiCData(voiMask);
            end         

            tVoiComputed.cells  = numel(double(voiCDataMasked));

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

                voxVolume = xPixel * yPixel * zPixel;
                nbVoxels = tVoiComputed.cells;

                tVoiComputed.min    = min(double(voiCDataMasked),[], 'all') * dSUVScale;
                tVoiComputed.max    = max(double(voiCDataMasked),[], 'all') * dSUVScale;
                tVoiComputed.mean   = mean(double(voiCDataMasked), 'all')   * dSUVScale;
                tVoiComputed.median = median(double(voiCDataMasked), 'all') * dSUVScale;

                volMean =  mean(double(voiCDataMasked), 'all');                  
                tVoiComputed.sum  = voxVolume * nbVoxels * volMean * dSUVScale;
                tVoiComputed.std  = std(double(voiCDataMasked),[],'all') * dSUVScale;  

                if ~isempty(tVoiComputed.max)

                    % Initialization SUVpeak
                    ROIonlyPET = padarray(voiCDataMasked * dSUVScale,[1 1 1],NaN);

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
                    tVoiComputed.peak = mean(neighborsMax(~isnan(neighborsMax)));
                else
                    tVoiComputed.peak = []; 
                end

     %           tVoiComputed.volume = bwarea(voiMask) * xPixel * yPixel * zPixel;
                tVoiComputed.volume = numel(voiCDataMasked) * xPixel * yPixel * zPixel;

                if numel(voiCInput) == numel(voiCData)
                    tVoiComputed.subtraction = max(voiCInput(voiMask)-voiCData(voiMask),[],'all') * dSUVScale;
                end
            else               
                tVoiComputed.min    = min(double(voiCDataMasked),[],'all');
                tVoiComputed.max    = max(double(voiCDataMasked),[],'all');
                tVoiComputed.mean   = mean(double(voiCDataMasked), 'all');
                tVoiComputed.median = median(double(voiCDataMasked), 'all');
                tVoiComputed.std    = std(double(voiCDataMasked),[],'all');    

                if ~isempty(tVoiComputed.max)

                    % Initialization SUVpeak
                    ROIonlyPET = padarray(voiCDataMasked,[1 1 1],NaN);

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
                    tVoiComputed.peak = mean(neighborsMax(~isnan(neighborsMax)));                
                else
                    tVoiComputed.peak = [];                   
                end

                voxVolume = xPixel * yPixel * zPixel;
                nbVoxels  = tVoiComputed.cells;
                volMean   = tVoiComputed.mean;                    
                tVoiComputed.sum = voxVolume * nbVoxels * volMean;

     %           tVoiComputed.volume = bwarea(voiMask) * (xPixel/10) * (yPixel/10) * (zPixel/10);
                tVoiComputed.volume = numel(voiCDataMasked) * xPixel * yPixel * zPixel;
                if numel(voiCInput) == numel(voiCData)               
                    tVoiComputed.subtraction = max(voiCInput(voiMask)-voiCData(voiMask),[],'all');
                end
            end
        else
            tVoiComputed  = [];
            atRoiComputed = [];
        end   
    else
        tVoiComputed  = [];
        atRoiComputed = [];        
    end
    
end