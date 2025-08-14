function [resampImage, atDcmMetaData] = resampleImage(dcmImage, atDcmMetaData, refImage, atRefMetaData, sMode, dRefOutputView, bUpdateDescription, dMovingSeriesOffset)
%function [resampImage, atDcmMetaData] = resampleImage(dcmImage, atDcmMetaData, refImage, atRefMetaData, sMode, dRefOutputView, bUpdateDescription, dMovingSeriesOffset)
%Resample any modalities.
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
        
    dimsRef = size(refImage);        
    dimsDcm = size(dcmImage);        
    
%    dimsRef(1)=477;
%    dimsRef(2)=954;
   
    dcmSliceThickness = computeSliceSpacing(atDcmMetaData);
    refSliceThickness = computeSliceSpacing(atRefMetaData);
          
    if dcmSliceThickness == 0  
        dcmSliceThickness = 1;
    end
      
    if atDcmMetaData{1}.PixelSpacing(1) == 0 && ...
       atDcmMetaData{1}.PixelSpacing(2) == 0 
        for jj=1:numel(atDcmMetaData)
            atDcmMetaData{1}.PixelSpacing(1) =1;
            atDcmMetaData{1}.PixelSpacing(2) =1;
        end       
    end

    if numel(dimsRef) == 2 % Reference is 2D
        
        if numel(dimsDcm) > 2 % Series is 3D
                                                                        
            if isfield(atRefMetaData{1}, 'DetectorInformationSequence')
                Rdcm = imref3d(dimsDcm, atDcmMetaData{1}.PixelSpacing(2), atDcmMetaData{1}.PixelSpacing(1), dcmSliceThickness);            

                [Mdti,~] = TransformMatrix(atDcmMetaData{1}, dcmSliceThickness, true);
                Mtf = Mdti;
                Mtf(1,1) = atRefMetaData{1}.PixelSpacing(2);
                Mtf(2,2) = atRefMetaData{1}.PixelSpacing(1);        
                Mtf(3,3) = atRefMetaData{1}.PixelSpacing(1);

                % First we transform into patient coordinates by multiplying by Mdti, and
                % then we convert again into image coordinates of the second volume by
                % multiplying by inv(Mtf)
                M =  inv(Mtf) * Mdti;
                M = M';

                TF = affine3d(M);
            
                sFieldOfViewShape       = atRefMetaData{1}.DetectorInformationSequence.Item_1.FieldOfViewShape;
                adFieldOfViewDimensions = atRefMetaData{1}.DetectorInformationSequence.Item_1.FieldOfViewDimensions;
                
                dImageMin = min(dcmImage,[],'all');

                [resampImage, ~] = imwarp(dcmImage, Rdcm, TF, 'Interp', sMode, 'FillValues', dImageMin);                                    
           
                if strcmpi(sFieldOfViewShape, 'RECTANGLE')
                    
                    dRowsSize    = atRefMetaData{1}.Rows*atRefMetaData{1}.PixelSpacing(1);
                    dColumnsSize = atRefMetaData{1}.Columns*atRefMetaData{1}.PixelSpacing(2);    
                    
                    % Compute the field of view offset                    
                    
                    % Set a buffer form the image rows culumns size

                    aTemp = zeros([atRefMetaData{1}.Rows atRefMetaData{1}.Columns size(resampImage, 3)]);
                    aTemp(aTemp==0) = dImageMin;
                    % Copy the image to the biging of the buffer

                    dRspSizeX = size(resampImage,1);
                    dRspSizeY = size(resampImage,2);
                    dRspSizeZ = size(resampImage,3);

                    dTmpSizeX = size(aTemp,1);
                    dTmpSizeY = size(aTemp,2);
                    dTmpSizeZ = size(aTemp,3);

                    if dRspSizeX > dTmpSizeX
                        dToX = dTmpSizeX;
                    else
                        dToX = dRspSizeX;                        
                    end

                    if dRspSizeY > dTmpSizeY
                        dToY = dTmpSizeY;
                    else
                        dToY = dRspSizeY;                        
                    end

                    if dRspSizeZ > dTmpSizeZ
                        dToZ = dTmpSizeZ;
                    else
                        dToZ = dRspSizeZ;                        
                    end

                    aTemp(1:dToX,1:dToY,1:dToZ) = resampImage(1:dToX, 1:dToY,1:dToZ);          

                    % Offset the image to the field of view position
                    if isempty(adFieldOfViewDimensions) 
                        dOffsetX = 0;
                        dOffsetY = (dColumnsSize/2);
                        aTemp = imtranslate(aTemp,[dOffsetX, dOffsetY, 0], 'nearest', 'OutputView', 'same', 'FillValues', dImageMin );                         
                    else
                        dOffsetX = (dRowsSize/2)-(adFieldOfViewDimensions(1)/2);
                        dOffsetY = (dColumnsSize/2)-(adFieldOfViewDimensions(2)/2);
                        aTemp = imtranslate(aTemp,[dOffsetX, dOffsetY, 0], 'nearest', 'OutputView', 'same', 'FillValues', dImageMin );   
                    end
                    
                    resampImage = aTemp;                     

                    clear aTemp;
                    
                    dimsRsp = size(resampImage);

                    if numel(atDcmMetaData) ~= 1
                        if dimsRsp(3) < numel(atDcmMetaData)
                            atDcmMetaData = atDcmMetaData(1:dimsRsp(3)); % Remove some slices
                        else
                            for cc=1:dimsRsp(3) - numel(atDcmMetaData)
                                atDcmMetaData{end+1} = atDcmMetaData{end}; %Add missing slice
                            end            
                        end                
                    end

                    computedSliceThikness = atRefMetaData{1}.PixelSpacing(1);

                    for jj=1:numel(atDcmMetaData)

                        atDcmMetaData{jj}.InstanceNumber  = jj;               
                        atDcmMetaData{jj}.NumberOfSlices  = dimsRsp(3);                

                        atDcmMetaData{jj}.PixelSpacing(1) = atRefMetaData{1}.PixelSpacing(1);
                        atDcmMetaData{jj}.PixelSpacing(2) = atRefMetaData{1}.PixelSpacing(2);
                        atDcmMetaData{jj}.SliceThickness  = computedSliceThikness;
                        atDcmMetaData{jj}.SpacingBetweenSlices  = computedSliceThikness;

                        atDcmMetaData{jj}.Rows    = dimsRsp(1);
                        atDcmMetaData{jj}.Columns = dimsRsp(2);
                        atDcmMetaData{jj}.NumberOfSlices = numel(atDcmMetaData);

                        atDcmMetaData{jj}.ImagePositionPatient(1) = -(atDcmMetaData{jj}.PixelSpacing(1)*dimsRsp(1)/2);               
                        atDcmMetaData{jj}.ImagePositionPatient(2) = -(atDcmMetaData{jj}.PixelSpacing(2)*dimsRsp(2)/2);               

                        if bUpdateDescription == true 
                            atDcmMetaData{jj}.SeriesDescription  = sprintf('RSP %s', atDcmMetaData{1}.SeriesDescription);
                        end   
                    end
            
                end                
            end
        else
            resampImage = dcmImage;
        end

        for cc=1:numel(atDcmMetaData)-1
            if atDcmMetaData{1}.ImagePositionPatient(3) < atDcmMetaData{2}.ImagePositionPatient(3)
                atDcmMetaData{cc+1}.ImagePositionPatient(3) = atDcmMetaData{cc}.ImagePositionPatient(3) + computedSliceThikness;               
                atDcmMetaData{cc+1}.SliceLocation = atDcmMetaData{cc}.SliceLocation + computedSliceThikness; 
            else
                atDcmMetaData{cc+1}.ImagePositionPatient(3) = atDcmMetaData{cc}.ImagePositionPatient(3) - computedSliceThikness;               
                atDcmMetaData{cc+1}.SliceLocation = atDcmMetaData{cc}.SliceLocation - computedSliceThikness;             
            end
        end
        
    else

        % Rdcm = imref3d(dimsDcm, atDcmMetaData{1}.PixelSpacing(2), atDcmMetaData{1}.PixelSpacing(1), dcmSliceThickness);
        % Rref = imref3d(dimsRef, atRefMetaData{1}.PixelSpacing(2), atRefMetaData{1}.PixelSpacing(1), refSliceThickness);

        % DICOM volume spatial reference
        dcmMeta   = atDcmMetaData{1};
        origin    = dcmMeta.ImagePositionPatient;     % [x0, y0, z0]
        spacing   = dcmMeta.PixelSpacing;             % [rowSpacing; colSpacing]
        % dimsDcm = [nRows, nCols, nSlices]
        Rdcm = imref3d( dimsDcm, ...
            ... % XWorldLimits along columns uses col‐spacing = spacing(2)
            [ origin(1), origin(1) + (dimsDcm(2)-1) * spacing(2) ], ...
            ... % YWorldLimits along rows uses row‐spacing = spacing(1)
            [ origin(2), origin(2) + (dimsDcm(1)-1) * spacing(1) ], ...
            ... % ZWorldLimits from first‐ to last‐slice center
            [ origin(3), origin(3) + (dimsDcm(3)-1) * dcmSliceThickness ] );
        
        % Reference volume spatial reference
        refMeta    = atRefMetaData{1};
        originRef  = refMeta.ImagePositionPatient;    % [x0, y0, z0]
        spacingRef = refMeta.PixelSpacing;            % [rowSpacing; colSpacing]
        % dimsRef = [nRows, nCols, nSlices]
        Rref = imref3d( dimsRef, ...
            ... % XWorldLimits along columns
            [ originRef(1), originRef(1) + (dimsRef(2)-1) * spacingRef(2) ], ...
            ... % YWorldLimits along rows
            [ originRef(2), originRef(2) + (dimsRef(1)-1) * spacingRef(1) ], ...
            ... % ZWorldLimits from first‐ to last‐slice center
            [ originRef(3), originRef(3) + (dimsRef(3)-1) * refSliceThickness ] );
                        
        if (round(Rdcm.ImageExtentInWorldX) ~= round(Rref.ImageExtentInWorldX)) && ...
           (round(Rdcm.ImageExtentInWorldY) ~= round(Rref.ImageExtentInWorldY))

            if dRefOutputView == true

                dRefOutputView = 2;
            end
        end

%         if (round(Rdcm.ImageExtentInWorldZ) ~= round(Rref.ImageExtentInWorldZ)) 
% 
%             if dRefOutputView == false
%                 if round(Rref.ImageExtentInWorldZ) > round(Rdcm.ImageExtentInWorldZ)
%                     dOffset = round(Rref.ImageExtentInWorldZ) - round(Rdcm.ImageExtentInWorldZ);
%                     dNbSlices = round(dOffset/refSliceThickness);
%                 end
%             end
% 
%         end

        [M, ~] = getTransformMatrix(atDcmMetaData{1}, dcmSliceThickness, atRefMetaData{1}, refSliceThickness);

         if dRefOutputView == false % Keep source z
             M(3,3) = 1;
         end

        TF = affine3d(M);

    %    if dRefOutputView == true
    %        if dimsDcm(3) ~= dimsRef(3)
    %            [resampImage, ~] = imwarp(dcmImage, Rdcm, TF,'Interp', sMode, 'FillValues', double(min(dcmImage,[],'all')));  
    %        else
    %            [resampImage, ~] = imwarp(dcmImage, TF,'Interp', sMode, 'FillValues', double(min(dcmImage,[],'all')), 'OutputView', imref3d(dimsRef));  
    %        end
    %        resampImage = imresize3(resampImage,[dimsRef(1) dimsRef(2) dimsRef(3)]);

    %    followOutput = affineOutputView(dimsDcm, TF, 'BoundsStyle', 'FollowOutput');
    %    [resampImage, Rrsmp] = imwarp(dcmImage, TF, 'Interp', sMode, 'FillValues', double(min(dcmImage,[],'all')), 'OutputView',followOutput);


    %    else

        if dRefOutputView == 2 

           [resampImage, RB] = imwarp(dcmImage, TF, 'Interp', sMode, 'FillValues', double(min(dcmImage,[],'all')), 'OutputView', imref3d(dimsRef)); 
        else       
           [resampImage, RB] = imwarp(dcmImage, Rdcm, TF,'Interp', sMode, 'FillValues', double(min(dcmImage,[],'all')));  
        end

        dimsRsp = size(resampImage);

        if dRefOutputView == true
            
            if dimsRsp(1)~=dimsRef(1) || ...
               dimsRsp(2)~=dimsRef(2) || ...     
               dimsRsp(3)~=dimsRef(3)

                resampImage = imresize3(resampImage, [dimsRef(1) dimsRef(2) dimsRef(3)],'Method', 'Nearest');
                dimsRsp = size(resampImage);
            end
        end

        if numel(atDcmMetaData) ~= 1

            if dimsRsp(3) < numel(atDcmMetaData)
                
                atDcmMetaData = atDcmMetaData(1:dimsRsp(3)); % Remove excess slices
            else
                for cc = 1:(dimsRsp(3) - numel(atDcmMetaData))
                    atDcmMetaData{end+1} = atDcmMetaData{end}; % Add missing slice
                end
            end
        end
                
        % Update metadata entries based on spatial reference
        for jj = 1:numel(atDcmMetaData)

            if numel(atRefMetaData) == numel(atDcmMetaData)
                refMeta = atRefMetaData{jj};
            else
                refMeta = atRefMetaData{1};
            end

            % atDcmMetaData{jj}.ImageOrientationPatient = ref.ImageOrientationPatient;
            atDcmMetaData{jj}.PixelSpacing           = refMeta.PixelSpacing;
            atDcmMetaData{jj}.Rows                   = dimsRef(1);
            atDcmMetaData{jj}.Columns                = dimsRef(2);
            atDcmMetaData{jj}.SpacingBetweenSlices   = RB.PixelExtentInWorldZ;
            atDcmMetaData{jj}.SliceThickness         = RB.PixelExtentInWorldZ;
            atDcmMetaData{jj}.InstanceNumber         = jj;
            atDcmMetaData{jj}.NumberOfSlices         = dimsRef(3);

            % % Compute X/Y origin differently for the OutputView case
            if dRefOutputView == 2

                shiftX = (Rdcm.PixelExtentInWorldX - Rref.PixelExtentInWorldX) / 2;
                shiftY = (Rdcm.PixelExtentInWorldY - Rref.PixelExtentInWorldY) / 2;
                
                % Apply to the reference ImagePositionPatient:
                origIPP = refMeta.ImagePositionPatient;
                x0      = origIPP(1) - shiftX;
                y0      = origIPP(2) - shiftY;

            else

                % Center original volume in-plane using half-pixel world-offsets
                % Reference origin and spacing
                origIPP     = atRefMetaData{1}.ImagePositionPatient;  % [x; y; z]
                origSpacing = atRefMetaData{1}.PixelSpacing;          % [row; col]
            
    
                % Compute world-coordinate of the reference grid’s center:
                centerX = origIPP(1) + ((dimsRef(2)-1) * origSpacing(2)) / 2;  % along cols
                centerY = origIPP(2) + ((dimsRef(1)-1) * origSpacing(1)) / 2;  % along rows
            
                % Get the **actual** spacing of your resampled image:
                newSpacing = atDcmMetaData{jj}.PixelSpacing;  % [row; col]
            
                % Compute half-extent of the resampled grid in world-units:
                halfX = ((dimsRsp(2)-1) * newSpacing(2)) / 2;  % along cols
                halfY = ((dimsRsp(1)-1) * newSpacing(1)) / 2;  % along rows
            
                % Subtract half-extent and then add half a pixel (in mm) to land on the center
                x0 = centerX - halfX + newSpacing(2)/2;
                y0 = centerY - halfY + newSpacing(1)/2;
            end

            atDcmMetaData{jj}.ImagePositionPatient(1) = x0;
            atDcmMetaData{jj}.ImagePositionPatient(2) = y0;

            if bUpdateDescription
                
                atDcmMetaData{jj}.SeriesDescription  = sprintf('RSP %s', atDcmMetaData{jj}.SeriesDescription);
            end
        end
    
        computedSliceThickness = refSliceThickness;

         % Align first-slice Z per DICOM when using OutputView
        if dRefOutputView == 2 && dimsRsp(3) ~= dimsDcm(3)

            % Compute slice-normal vector
            iop     = atRefMetaData{1}.ImageOrientationPatient;
            rowOri  = iop(1:3);
            colOri  = iop(4:6);
            normOri = cross(rowOri, colOri);

            % Determine Z discrepancy
            refZ    = atRefMetaData{1}.ImagePositionPatient(3);
            origZ   = atDcmMetaData{1}.ImagePositionPatient(3);
            deltaZ  = refZ - origZ;

            % Adjust if discrepancy aligns with acquisition direction
            if deltaZ * normOri(3) < 0
                atDcmMetaData{1}.ImagePositionPatient(3) = origZ - deltaZ;
                atDcmMetaData{1}.SliceLocation           = atDcmMetaData{1}.SliceLocation - deltaZ;
            end
        end

        % Update slice positions along Z
        for cc = 1:(numel(atDcmMetaData) - 1)
            if atDcmMetaData{1}.ImagePositionPatient(3) < atDcmMetaData{2}.ImagePositionPatient(3)
                atDcmMetaData{cc+1}.ImagePositionPatient(3) = atDcmMetaData{cc}.ImagePositionPatient(3) + computedSliceThickness;
                atDcmMetaData{cc+1}.SliceLocation           = atDcmMetaData{cc}.SliceLocation + computedSliceThickness;
            else
                atDcmMetaData{cc+1}.ImagePositionPatient(3) = atDcmMetaData{cc}.ImagePositionPatient(3) - computedSliceThickness;
                atDcmMetaData{cc+1}.SliceLocation           = atDcmMetaData{cc}.SliceLocation - computedSliceThickness;
            end
        end
    end
    
    if bUpdateDescription == true

        if ~exist('dMovingSeriesOffset', 'var')

            dMovingSeriesOffset = [];
            atInput = inputTemplate('get');
            
            for jj=1:numel(atInput)
                if strcmpi(atInput(jj).atDicomInfo{1}.SeriesInstanceUID, atDcmMetaData{1}.SeriesInstanceUID)
                    dMovingSeriesOffset = jj;
                    break;
                end
            end
        end

        if ~isempty(dMovingSeriesOffset)
            
            asDescription = seriesDescription('get');
            asDescription{dMovingSeriesOffset} = sprintf('RSP %s', asDescription{dMovingSeriesOffset});
            seriesDescription('set', asDescription);
    
            set(uiSeriesPtr('get'), 'String', asDescription);
            set(uiFusedSeriesPtr('get'), 'String', asDescription);            
        end
    end
  
end  

