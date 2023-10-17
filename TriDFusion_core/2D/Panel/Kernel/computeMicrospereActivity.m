function [aImage, acReport] = computeMicrospereActivity(aImage, atMetaData, sTreatmentType, dMicrosphereVolume)
%function [aImage, acReport] = computeMicrospereActivity(aImage, atMetaData, sTreatmentType, dMicrosphereVolume)
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
    
    atRoi = roiTemplate('get', dSeriesOffset);
    atVoi = voiTemplate('get', dSeriesOffset);
    
    if isempty(atVoi)
        return;
    end                   
    
    xPixel = atMetaData{1}.PixelSpacing(1)/10;
    yPixel = atMetaData{1}.PixelSpacing(2)/10; 
    if size(aImage, 3) == 1 
        zPixel = 1;
    else
        zPixel = computeSliceSpacing(atMetaData)/10; 
    end

    dVoxVolume = xPixel * yPixel * zPixel;      
    
    if strcmpi(sTreatmentType, 'TheraSphere')
        dSphereMultiplicator = 2500; % BQ per sphere
    elseif strcmpi(sTreatmentType, 'SIRsphere')
        dSphereMultiplicator = 61.65;
    else
        sErrorMessage = sprintf('Error: %s is not supported', sTreatmentType);
        errordlg(sErrorMessage);
        progressBar(1 , sErrorMessage);                   
        return;
    end
       
    dNbVois = numel(atVoi);

    acReport = cell(dNbVois, 8);

    for vv=1:dNbVois
        
        dNbRois = numel(atVoi{vv}.RoisTag);

        if mod(vv, 5)==1 || vv == dNbVois
            progressBar(vv/dNbVois-0.0001, sprintf('Processing microsphere %d/%d', vv, dNbVois ) );
        end

        voiMask = zeros(size(aImage));

        for rr=1:dNbRois
          
            aTagOffset = strcmp( cellfun( @(atRoi) atRoi.Tag, atRoi, 'uni', false ), {[atVoi{vv}.RoisTag{rr}]} );

            tRoi = atRoi{find(aTagOffset, 1)};

            switch lower(tRoi.Axe)     
                
                case 'axe'
                    voiMask = roiTemplateToMask(tRoi, dicomBuffer('get')) | voiMask;

                case 'axes1'
                    voiMask(tRoi.SliceNb,:,:) = roiTemplateToMask(tRoi, dicomBuffer('get')) | permute(voiMask(tRoi.SliceNb,:,:), [3 2 1]);

                case 'axes2'
                    voiMask(:,tRoi.SliceNb,:) = roiTemplateToMask(tRoi, dicomBuffer('get')) | permute(voiMask(:,tRoi.SliceNb,:), [3 1 2]);

               case 'axes3'
                    voiMask(:,:,tRoi.SliceNb) = roiTemplateToMask(tRoi, dicomBuffer('get')) | voiMask(:,:,tRoi.SliceNb);
            end 

        end
  
        dNbCells = numel( aImage(voiMask~=0) );                     

        dContourVolume = dNbCells*dVoxVolume;

        dNbSphere = round(dContourVolume / dMicrosphereVolume);
        if dNbSphere == 0
            dNbSphere = 1;
        end

        dActivity = dNbSphere * dSphereMultiplicator / dNbCells / dVoxVolume;
        aImage(voiMask~=0) = dActivity;  

        acReport{vv,1} = sprintf('Label: %s'        , atVoi{vv}.Label);
        acReport{vv,2} = sprintf('Nb Cells: %s'     , num2str(dNbCells));
        acReport{vv,3} = sprintf('Voxel Volume: %s' , num2str(dVoxVolume));
        acReport{vv,4} = sprintf('Volume (cm3): %s' , num2str(dNbCells*dVoxVolume));
        acReport{vv,5} = sprintf('Preset (cm3): %s' ,num2str(dMicrosphereVolume));
        acReport{vv,6} = sprintf('Nb Sphere: %s'    ,num2str(dNbSphere));
        acReport{vv,7} = sprintf('Multiplicator: %s',num2str(dSphereMultiplicator));
        acReport{vv,8} = sprintf('Activity: %s'     ,num2str(dActivity));
    end
    
    progressBar(1, 'Ready');
    
end