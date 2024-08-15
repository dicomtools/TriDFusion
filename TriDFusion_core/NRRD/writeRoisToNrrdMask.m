function writeRoisToNrrdMask(sOutDir, bSubDir, sNrrdName, aInputBuffer, atInputMeta, aDicomBuffer, atDicomMeta, dOffset, bIndex)
%function writeRoisToNrrdMask(sOutDir, bSubDir, sNrrdName, aInputBuffer, atInputMeta, aDicomBuffer, atDicomMeta, dOffset, bIndex)
%Export ROIs To .nrrd mask.
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

    atInput = inputTemplate('get');
    if dOffset > numel(atInput)
        return;
    end

    try

    set(fiMainWindowPtr('get'), 'Pointer', 'watch');
    drawnow;

%     dicomdict('factory');    
        
    % Set series label
    
%     sSeriesDescription = getViewerSeriesDescriptionDialog(sprintf('MASK-%s', atDicomMeta{1}.SeriesDescription));
%     if isempty(sSeriesDescription)
%         return;
%     end
%     
%     for sd=1:numel(atDicomMeta)
%         atDicomMeta{sd}.SeriesDescription = sSeriesDescription;
%     end
        
    tRoiInput = roiTemplate('get', dOffset);
    tVoiInput = voiTemplate('get', dOffset);
    
    bUseRoiTemplate = false;
    if numel(aInputBuffer) ~= numel(aDicomBuffer)              
        
        tRoiInput = resampleROIs(aDicomBuffer, atDicomMeta, aInputBuffer, atInputMeta, tRoiInput, false); 
        
        atDicomMeta  = atInputMeta; 
        aDicomBuffer = aInputBuffer;      
        
        bUseRoiTemplate = true;            
    end        

    aBufferSize = size(aDicomBuffer);

    aMaskBuffer = single(zeros(aBufferSize));
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

                        if bIndex == 1
                            aSlice( roiMask) =cc;
                            aSlice(~roiMask) =0;                            
                        elseif bIndex == 2
                            aSlice( roiMask) =getBrownFatLesionTypeMaskValue(tRoiInput{tt}.LesionType);
                            aSlice(~roiMask) =0;                             
                        elseif bIndex == 3
                            aSlice( roiMask) =getPSMALesionTypeMaskValue(tRoiInput{tt}.LesionType);
                            aSlice(~roiMask) =0;                             
                        else
                            aSlice( roiMask) =1;
                            aSlice(~roiMask) =0;
                        end

                        aSliceMask =  aMaskBuffer(:,:);

                        if bIndex
                             aMaskBuffer(:,:) = aSlice+aSliceMask;
                       else
                            aMaskBuffer(:,:) = aSlice|aSliceMask;
                       end
                    end
                    
                    if strcmpi(tRoiInput{tt}.Axe, 'Axes1')                           

                        aSlice =  permute(aDicomBuffer(dSliceNb,:,:), [3 2 1]);

                        if bUseRoiTemplate == true
                            roiMask = roiTemplateToMask(tRoiInput{tt}, aSlice);      
                        else                                
                            roiMask = createMask(tRoiInput{tt}.Object, aSlice);
                        end

                        if bIndex == 1
                            aSlice( roiMask) =cc;
                            aSlice(~roiMask) =0;  
                        elseif bIndex == 2
                            aSlice( roiMask) =getBrownFatLesionTypeMaskValue(tRoiInput{tt}.LesionType);
                            aSlice(~roiMask) =0;                               
                        elseif bIndex == 3
                            aSlice( roiMask) =getPSMALesionTypeMaskValue(tRoiInput{tt}.LesionType);
                            aSlice(~roiMask) =0; 
                        else
                            aSlice( roiMask) =1;
                            aSlice(~roiMask) =0;
                        end

                        aSliceMask =  permute(aMaskBuffer(dSliceNb,:,:), [3 2 1]);

                        if bIndex 
                            aSlice = aSlice+aSliceMask;
                        else
                            aSlice = aSlice|aSliceMask;
                        end
                        aMaskBuffer(dSliceNb,:,:) = permute(reshape(aSlice, [1 size(aSlice)]), [1 3 2]);
                    end
                    
                    if strcmpi(tRoiInput{tt}.Axe, 'Axes2')                           

                        aSlice = permute(aDicomBuffer(:,dSliceNb,:), [3 1 2]);

                        if bUseRoiTemplate == true
                            roiMask = roiTemplateToMask(tRoiInput{tt}, aSlice);      
                        else
                            roiMask = createMask(tRoiInput{tt}.Object, aSlice);
                        end
                        
                        if bIndex == 1
                            aSlice( roiMask) =cc;
                            aSlice(~roiMask) =0;  
                        elseif bIndex == 2
                            aSlice( roiMask) =getBrownFatLesionTypeMaskValue(tRoiInput{tt}.LesionType);
                            aSlice(~roiMask) =0;                               
                        elseif bIndex == 3
                            aSlice( roiMask) =getPSMALesionTypeMaskValue(tRoiInput{tt}.LesionType);
                            aSlice(~roiMask) =0;                             
                        else
                            aSlice( roiMask) =1;
                            aSlice(~roiMask) =0;
                        end

                        aSliceMask =  permute(aMaskBuffer(:,dSliceNb,:), [3 1 2]);

                        if bIndex 
                            aSlice = aSlice+aSliceMask;
                        else
                            aSlice = aSlice|aSliceMask;
                        end

                        aMaskBuffer(:,dSliceNb,:) = permute(reshape(aSlice, [1 size(aSlice)]), [3 1 2]);
                    end
                    
                    if strcmpi(tRoiInput{tt}.Axe, 'Axes3')                           
                            
                        aSlice = aDicomBuffer(:,:,dSliceNb);

                        if bUseRoiTemplate == true
                            roiMask = roiTemplateToMask(tRoiInput{tt}, aSlice);      
                        else
                            roiMask = createMask(tRoiInput{tt}.Object, aSlice);
                        end

                        if bIndex == 1
                            aSlice( roiMask) =cc;
                            aSlice(~roiMask) =0;                            
                        elseif bIndex == 2
                            aSlice( roiMask) =getBrownFatLesionTypeMaskValue(tRoiInput{tt}.LesionType);
                            aSlice(~roiMask) =0;                               
                        elseif bIndex == 3
                            aSlice( roiMask) =getPSMALesionTypeMaskValue(tRoiInput{tt}.LesionType);
                            aSlice(~roiMask) =0;                             
                        else
                            aSlice( roiMask) =1;
                            aSlice(~roiMask) =0;
                        end

                        aSliceMask =  aMaskBuffer(:,:,dSliceNb);

                        if bIndex
                            aMaskBuffer(:,:,dSliceNb) = aSlice+aSliceMask;                        
                        else
                            aMaskBuffer(:,:,dSliceNb) = aSlice|aSliceMask;                        
                        end
                        
                    end
                    break;
                end                
            end
        end
    end

%     aMaskBuffer(aMaskBuffer~=0) = aDicomBuffer(aMaskBuffer~=0);
%     aMaskBuffer(aMaskBuffer==0) = min(double(aDicomBuffer),[], 'all');

    if bIndex == false
        aMaskBuffer(aMaskBuffer~=0) = 1;
        aMaskBuffer(aMaskBuffer==0) = 0;
    end

    if bSubDir == true
        sDate = sprintf('%s', datetime('now','Format','MMMM-d-y-hhmmss'));
        sWriteDir = char(sOutDir) + "TriDFusion_Contours-NRRD-MASK_" + char(sDate) + '/';
        if ~(exist(char(sWriteDir), 'dir'))
            mkdir(char(sWriteDir));
        end
    else
        sWriteDir = char(sOutDir); 
    end
         
    origin = atDicomMeta{end}.ImagePositionPatient;
    
    pixelspacing = zeros(3,1);

    pixelspacing(1) = atDicomMeta{1}.PixelSpacing(1);
    pixelspacing(2) = atDicomMeta{1}.PixelSpacing(2);
    pixelspacing(3) = computeSliceSpacing(atDicomMeta);

%     if ~isempty(atDicomMeta{1}.SliceThickness)
%         if atDicomMeta{1}.SliceThickness ~= 0
%             pixelspacing(3) = atDicomMeta{1}.SliceThickness;
%         else
%             pixelspacing(3) = computeSliceSpacing(atDicomMeta);
%         end           
%     else    
%         pixelspacing(3) = computeSliceSpacing(atDicomMeta);
%     end

    sNrrdImagesName = sprintf('%s%s', sWriteDir, sNrrdName);

%     if size(aMaskBuffer, 3) ~=1
%         aMaskBuffer = imrotate3(aMaskBuffer, 90, [0 0 1], 'nearest');
%         aMaskBuffer = aMaskBuffer(end:-1:1,:,:);
%     else
%         aMaskBuffer = imrotate(aMaskBuffer, 90, 'nearest');
%         aMaskBuffer = aMaskBuffer(end:-1:1,:);        
%     end

    if size(aMaskBuffer, 3) ~=1

        aMaskBuffer = aMaskBuffer(:,:,end:-1:1);
    end

    nrrdWriter(sNrrdImagesName, squeeze(aMaskBuffer), pixelspacing, origin, 'raw'); % Write .nrrd images 

    progressBar(1, sprintf('Export NRRD mask to %s completed', char(sWriteDir)));

    catch
        progressBar(1, 'Error:writeRoisToNrrdMask()');
    end

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow;

    function dMaskValue = getBrownFatLesionTypeMaskValue(sLesionType)

        switch lower(sLesionType)
             
            case 'cervical' 
                dMaskValue = 1;
            case 'supraclavicular'
                dMaskValue = 2;
            case 'mediastinal'
                dMaskValue = 3;
            case 'paraspinal'
                dMaskValue = 4;
            case 'axillary'
                dMaskValue = 5;
            case 'abdominal'
                dMaskValue = 6;
                
            otherwise
                dMaskValue = 7;
        end
    end

    function dMaskValue = getPSMALesionTypeMaskValue(sLesionType)

        switch lower(sLesionType)
             
            case 'lymph nodes' 
                dMaskValue = 1;
            case 'soft tissue' 
                dMaskValue = 2;                
            case 'bone'
                dMaskValue = 3;
            case 'liver'
                dMaskValue = 4;
            case 'primary disease'
                dMaskValue = 5;                 
            case 'lung'
                dMaskValue = 6; 
            case 'parotid'
                dMaskValue = 7;      
            case 'blood pool'
                dMaskValue = 8;  

            otherwise
                dMaskValue = 9;
        end
    end
end
