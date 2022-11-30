function [imCData, logicalMask] = computeHistogram(imInput, atInputMetaData, imRoiVoi, atRoiVoiMetaData, ptrRoiVoi, tRoiInput, dSUVScale, bSUVUnit, bModifiedMatrix, bSegmented, bDoseKernel, bMovementApplied)
%function [imCData, logicalMask] = computeHistogram(imInput, atInputMetaData, imRoiVoi, atRoiVoiMetaData, ptrRoiVoi, tRoiInput, dSUVScale, bSUVUnit, bModifiedMatrix, bSegmented, bDoseKernel, bMovementApplied)
%Compute Histogram from ROIs.
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
    
    if strcmpi(ptrRoiVoi.ObjectType, 'roi') || ...
       strcmpi(ptrRoiVoi.ObjectType, 'voi-roi')
      
        progressBar(0.99, 'Computing Histogram, please wait!');          
        
        if bModifiedMatrix  == false && ... 
           bMovementApplied == false        % Can't use input buffer if movement have been applied

            if numel(imInput) ~= numel(imRoiVoi)
                
                pTemp{1} = ptrRoiVoi;
                ptrRoiTemp = resampleROIs(imRoiVoi, atRoiVoiMetaData, imInput, atInputMetaData, pTemp, false);
                ptrRoiVoi = ptrRoiTemp{1};
            end        

            imRoiVoi = imInput;

        end
    
        switch lower(ptrRoiVoi.Axe)    

            case 'axe'
                imCData = imRoiVoi(:,:); 

            case 'axes1'
                imCData = permute(imRoiVoi(ptrRoiVoi.SliceNb,:,:), [3 2 1]);

            case 'axes2'
                imCData = permute(imRoiVoi(:,ptrRoiVoi.SliceNb,:), [3 1 2]) ;

            case 'axes3'
                imCData  = imRoiVoi(:,:,ptrRoiVoi.SliceNb);  

            otherwise   
                logicalMask = []; 
                imCData = [];
                return;
        end
        
        if strcmpi(ptrRoiVoi.Type, 'images.roi.line')
            logicalMask = createMask(ptrRoiVoi.Object, imCData);
        else
            logicalMask = roiTemplateToMask(ptrRoiVoi, imCData);
        end
                            
    else
        imRoiVoiBak = imRoiVoi;
       
        for bb=1: numel(ptrRoiVoi.RoisTag)
            
            progressBar(bb/numel(ptrRoiVoi.RoisTag), sprintf('Computing Histogram ROI %d/%d, please wait!', bb, numel(ptrRoiVoi.RoisTag)));          

            for cc=1:numel(tRoiInput)
                if strcmpi(ptrRoiVoi.RoisTag{bb}, tRoiInput{cc}.Tag)
                    
                    if bModifiedMatrix  == false && ... 
                       bMovementApplied == false        % Can't use input buffer if movement have been applied
                        imRoiVoi = imRoiVoiBak;
                        if numel(imInput) ~= numel(imRoiVoi)
                            pTemp{1} = tRoiInput{cc};
                            ptrRoiTemp = resampleROIs(imRoiVoi, atRoiVoiMetaData, imInput, atInputMetaData, pTemp, false);
                             tRoiInput{cc} = ptrRoiTemp{1};
                        end        

                        imRoiVoi = imInput;
                    end    
                    
                    switch lower(tRoiInput{cc}.Axe)    

                        case 'axe'
                            imCData = imRoiVoi(:,:); 

                        case 'axes1'
                            imCData = permute(imRoiVoi(tRoiInput{cc}.SliceNb,:,:), [3 2 1]);

                        case 'axes2'
                            imCData = permute(imRoiVoi(:,tRoiInput{cc}.SliceNb,:), [3 1 2]) ;

                        case 'axes3'
                            imCData  = imRoiVoi(:,:,tRoiInput{cc}.SliceNb);  

                        otherwise   
                            logicalMask = []; 
                            imCData = [];
                            return;
                    end                    
                    
                    if strcmpi(tRoiInput{cc}.Type, 'images.roi.line')
                        roiMask = createMask(tRoiInput{cc}.Object, imCData);
                    else
                        roiMask = roiTemplateToMask(tRoiInput{cc}, imCData);
                    end

                    if ~exist('voiMask', 'var')
                        voiMask = roiMask;                      
                    else
                        voiMask = cat(2, voiMask , roiMask);
                    end

                    if ~exist('voiCData', 'var')
                        voiCData = imCData;
                    else
                        voiCData = cat(2, voiCData, imCData);
                    end

                end
            end
        end 

        if exist('voiCData', 'var')
            imCData = voiCData;
        end

        if exist('voiMask', 'var')
            logicalMask = voiMask;
        end
        
        clear imRoiVoiBak;
        
    end

    if  (strcmpi(atRoiVoiMetaData{1}.Modality, 'pt') || ...
         strcmpi(atRoiVoiMetaData{1}.Modality, 'nm'))&& ...
         strcmpi(atRoiVoiMetaData{1}.Units, 'BQML' ) && ...     
         bSUVUnit == true                 
        imCData = imCData * dSUVScale;              
    end   
    
    imCData = imCData(logicalMask);

    if bSegmented  == true && ...      
       bModifiedMatrix == true    % Can't use original matrix
  
        imCData = imCData(imCData>cropValue('get'));                            
    end    
        
    progressBar(1, 'Ready');          
    
end