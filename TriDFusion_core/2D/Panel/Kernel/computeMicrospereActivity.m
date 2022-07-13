function aImage = computeMicrospereActivity(aImage, atMetaData, sTreatmentType, dMicrosphereVolume)
%function aWithMicrosphereActivity = computeMicrospereActivity(aImage, sTreatmentType, dMicrosphereVolume)
%Add microsphere activity to an image.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Note: option settings must fit on one line and can contain one semicolon at most.
%Options can be strings, cell arrays of strings, or numerical arrays.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2022, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    uiSeries = uiSeriesPtr('get');
    dSeriesOffset = get(uiSeries, 'Value');
    
    atInputTemplate = inputTemplate('get');

    atRoi = roiTemplate('get', dSeriesOffset);
    atVoi = voiTemplate('get', dSeriesOffset);
    
    paInputBuffer = inputBuffer('get');
    if     strcmpi(imageOrientation('get'), 'axial')
        aInputBuffer = permute(paInputBuffer{dSeriesOffset}, [1 2 3]);
    elseif strcmpi(imageOrientation('get'), 'coronal')
        aInputBuffer = permute(paInputBuffer{dSeriesOffset}, [3 2 1]);
    elseif strcmpi(imageOrientation('get'), 'sagittal')
        aInputBuffer = permute(paInputBuffer{dSeriesOffset}, [3 1 2]);
    end
    
    if size(aInputBuffer, 3) ==1

        if atInputTemplate(dSeriesOffset).bFlipLeftRight == true
            aInputBuffer=aInputBuffer(:,end:-1:1);
        end

        if atInputTemplate(dSeriesOffset).bFlipAntPost == true
            aInputBuffer=aInputBuffer(end:-1:1,:);
        end            
    else
        if atInputTemplate(dSeriesOffset).bFlipLeftRight == true
            aInputBuffer=aInputBuffer(:,end:-1:1,:);
        end

        if atInputTemplate(dSeriesOffset).bFlipAntPost == true
            aInputBuffer=aInputBuffer(end:-1:1,:,:);
        end

        if atInputTemplate(dSeriesOffset).bFlipHeadFeet == true
            aInputBuffer=aInputBuffer(:,:,end:-1:1);
        end 
    end 
            
    atInputMetaData = atInputTemplate(dSeriesOffset).atDicomInfo;
    
    bDoseKernel      = atInputTemplate(dSeriesOffset).bDoseKernel;
    bMovementApplied = atInputTemplate(dSeriesOffset).tMovement.bMovementApplied;
    
    tRoiQuant = quantificationTemplate('get');

    if isfield(tRoiQuant, 'tSUV')
        dSUVScale = tRoiQuant.tSUV.dScale;
    else
        dSUVScale = 0;
    end
    
    bSUVUnit = true;    
    bSegmented = false;
           
    if strcmpi(sTreatmentType, 'TheraSphere')
        dSphereMultiplicator = 2500; % BQ per sphere
    elseif strcmpi(sTreatmentType, 'SIRsphere')
        dSphereMultiplicator = 50;
    else
        sErrorMessage = sprintf('Error: %s is not supported', sTreatmentType);
        errordlg(sErrorMessage);
        progressBar(1 , sErrorMessage);                   
        return;
    end
       
    dNbVois = numel(atVoi);
    for vv=1:dNbVois
        
        if mod(vv, 5)==1 || vv == dNbVois
            progressBar(vv/dNbVois-0.0001, sprintf('Processing microsphere %d/%d', vv, dNbVois ) );
        end
        
        [tVoiComputed, ~, aVoiMask] = computeVoi(aInputBuffer, atInputMetaData, aImage, atMetaData, atVoi{vv}, atRoi, dSUVScale, bSUVUnit, bSegmented, bDoseKernel, bMovementApplied);
        
        dNbSphere = round(tVoiComputed.volume \ dMicrosphereVolume)+1;
                  
        aImage(aVoiMask) = dNbSphere * dSphereMultiplicator \ numel(aVoiMask(aVoiMask~=0));  
                 
    end
    
end