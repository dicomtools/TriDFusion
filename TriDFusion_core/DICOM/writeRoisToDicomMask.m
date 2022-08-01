function writeRoisToDicomMask(sOutDir, bSubDir, aInputBuffer, atInputMeta, aDicomBuffer, atDicomMeta, dOffset)
%function writeRoisToDicomMask(sOutDir, bSubDir, aInputBuffer, atInputMeta, aDicomBuffer, atDicomMeta, dOffset)
%Export ROIs To DICOM mask.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2021, Daniel Lafontaine, on behalf of the TriDFusion development team.
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
% along with TriDFusion.cIf not, see <http://www.gnu.org/licenses/>.

    tInput = inputTemplate('get');
    if dOffset > numel(tInput)
        return;
    end

    try

    set(fiMainWindowPtr('get'), 'Pointer', 'watch');
    drawnow;

    dicomdict('factory');    
        
    % Set series label
    
    sSeriesDescription = getViewerSeriesDescriptionDialog(sprintf('MASK-%s', atDicomMeta{1}.SeriesDescription));
    if isempty(sSeriesDescription)
        return;
    end
    
    for sd=1:numel(atDicomMeta)
        atDicomMeta{sd}.SeriesDescription = sSeriesDescription;
    end
        
    tRoiInput = roiTemplate('get', dOffset);
    tVoiInput = voiTemplate('get', dOffset);
    
    bUseRoiTemplate = false;
    if modifiedImagesContourMatrix('get') == false
        if numel(aInputBuffer) ~= numel(aDicomBuffer)              
            
            tRoiInput = resampleROIs(aDicomBuffer, atDicomMeta, aInputBuffer, atInputMeta, tRoiInput, false); 
            
            atDicomMeta  = atInputMeta; 
            aDicomBuffer = aInputBuffer;      
            
            bUseRoiTemplate = true;            
        end        
    end    
    
    aMaskBuffer = zeros(size(aDicomBuffer));
 %   aMaskBuffer(aMaskBuffer==0) = min(double(aDicomBuffer),[], 'all');
 
    nbContours = numel(tVoiInput);
    for cc=1:nbContours
        
        if mod(cc,5)==1 || cc == 1 || cc == nbContours
            progressBar( cc / nbContours - 0.000001, sprintf('Processing contour %d/%d, please wait', cc, nbContours) );
        end

        nbRois = numel(tVoiInput{cc}.RoisTag);
        for rr=1:nbRois

            for tt=1:numel(tRoiInput)
                if strcmpi(tVoiInput{cc}.RoisTag{rr}, tRoiInput{tt}.Tag)

                    dSliceNb = tRoiInput{tt}.SliceNb;

                    if strcmpi(tRoiInput{tt}.Axe, 'Axe')
                                                    
                        aSlice = aDicomBuffer(:,:);

                        if bUseRoiTemplate == true
                            roiMask = roiTemplateToMask(tRoiInput{tt}, aSlice);      
                        else
                            roiMask = createMask(tRoiInput{tt}.Object, aSlice);
                        end

                        aSlice( roiMask) =1;
                        aSlice(~roiMask) =0;

                        aSliceMask =  aMaskBuffer(:,:);
                        aMaskBuffer(:,:) = aSlice|aSliceMask;
                    end
                    
                    if strcmpi(tRoiInput{tt}.Axe, 'Axes1')                           

                        aSlice =  permute(aDicomBuffer(dSliceNb,:,:), [3 2 1]);

                        if bUseRoiTemplate == true
                            roiMask = roiTemplateToMask(tRoiInput{tt}, aSlice);      
                        else                                
                            roiMask = createMask(tRoiInput{tt}.Object, aSlice);
                        end

                        aSlice( roiMask) =1;
                        aSlice(~roiMask) =0;

                        aSliceMask =  permute(aMaskBuffer(dSliceNb,:,:), [3 2 1]);
                        aSlice = aSlice|aSliceMask;
                        aMaskBuffer(dSliceNb,:,:) = permute(reshape(aSlice, [1 size(aSlice)]), [1 3 2]);
                    end
                    
                    if strcmpi(tRoiInput{tt}.Axe, 'Axes2')                           

                        aSlice = permute(aDicomBuffer(:,dSliceNb,:), [3 1 2]);

                        if bUseRoiTemplate == true
                            roiMask = roiTemplateToMask(tRoiInput{tt}, aSlice);      
                        else
                            roiMask = createMask(tRoiInput{tt}.Object, aSlice);
                        end

                        aSlice( roiMask) =1;
                        aSlice(~roiMask) =0;

                        aSliceMask =  permute(aMaskBuffer(:,dSliceNb,:), [3 1 2]);
                        aSlice = aSlice|aSliceMask;
                        aMaskBuffer(:,dSliceNb,:) = permute(reshape(aSlice, [1 size(aSlice)]), [3 1 2]);
                    end
                    
                    if strcmpi(tRoiInput{tt}.Axe, 'Axes3')                           
                            
                        aSlice = aDicomBuffer(:,:,dSliceNb);

                        if bUseRoiTemplate == true
                            roiMask = roiTemplateToMask(tRoiInput{tt}, aSlice);      
                        else
                            roiMask = createMask(tRoiInput{tt}.Object, aSlice);
                        end

                        aSlice( roiMask) =1;
                        aSlice(~roiMask) =0;

                        aSliceMask =  aMaskBuffer(:,:,dSliceNb);
                        aMaskBuffer(:,:,dSliceNb) = aSlice|aSliceMask;                        
                        
                    end
                    break;
                end                
            end
        end
    end

    aMaskBuffer(aMaskBuffer~=0) = aDicomBuffer(aMaskBuffer~=0);
    aMaskBuffer(aMaskBuffer==0) = min(double(aDicomBuffer),[], 'all');
    
    if bSubDir == true
        sDate = sprintf('%s', datetime('now','Format','MMMM-d-y-hhmmss'));
        sWriteDir = char(sOutDir) + "TriDFusion_Contours-MASK_" + char(sDate) + '/';
        if ~(exist(char(sWriteDir), 'dir'))
            mkdir(char(sWriteDir));
        end
    else
        sWriteDir = char(sOutDir); 
    end
    
    writeDICOM(aMaskBuffer, atDicomMeta, sWriteDir, dOffset);

    catch
        progressBar(1, 'Error:writeRoisToDicomMask()');
    end

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow;

end
