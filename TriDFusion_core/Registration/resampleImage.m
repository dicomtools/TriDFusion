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

                [Mdti,~] = TransformMatrix(atDcmMetaData{1}, dcmSliceThickness);
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

        Rdcm = imref3d(dimsDcm, atDcmMetaData{1}.PixelSpacing(2), atDcmMetaData{1}.PixelSpacing(1), dcmSliceThickness);
        Rref = imref3d(dimsRef, atRefMetaData{1}.PixelSpacing(2), atRefMetaData{1}.PixelSpacing(1), refSliceThickness);

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
               [resampImage, ~] = imwarp(dcmImage, TF, 'Interp', sMode, 'FillValues', double(min(dcmImage,[],'all')), 'OutputView', imref3d(dimsRef)); 
           else       
               [resampImage, ~] = imwarp(dcmImage, Rdcm, TF,'Interp', sMode, 'FillValues', double(min(dcmImage,[],'all')));  
           end

            dimsRsp = size(resampImage);

            if dRefOutputView == true
                
                if dimsRsp(1)~=dimsRef(1) || ...
                   dimsRsp(2)~=dimsRef(2) || ...     
                   dimsRsp(3)~=dimsRef(3)

                    resampImage=imresize3(resampImage, [dimsRef(1) dimsRef(2) dimsRef(3)],'Method', 'Nearest');
                    dimsRsp = size(resampImage);
                end
            end

    %        dimsRsp = size(resampImage);         
    %        xMoveOffset = (dimsRsp(1)-dimsRef(1))/2;
    %        yMoveOffset = (dimsRsp(2)-dimsRef(2))/2;

    %        resampImage = imtranslate(resampImage,[-xMoveOffset, -yMoveOffset, 0], 'nearest', 'OutputView', 'same', 'FillValues', min(resampImage, [], 'all') );         

    %        [resampImage, Rrsmp] = imwarp(dcmImage, Rdcm, TF, 'Interp', sMode, 'FillValues', double(min(dcmImage,[],'all')));  
    %    end


        if numel(atDcmMetaData) ~= 1
            if dimsRsp(3) < numel(atDcmMetaData)
                atDcmMetaData = atDcmMetaData(1:numel(atRefMetaData)); % Remove some slices
            else
                for cc=1:dimsRsp(3) - numel(atDcmMetaData)
                    atDcmMetaData{end+1} = atDcmMetaData{end}; %Add missing slice
                end            
            end                
        end

        if dRefOutputView == 2
            for jj=1:numel(atDcmMetaData)
                if numel(atRefMetaData) == numel(atDcmMetaData)
                    atDcmMetaData{jj}.ImagePositionPatient    = atRefMetaData{jj}.ImagePositionPatient;
                    atDcmMetaData{jj}.ImageOrientationPatient = atRefMetaData{jj}.ImageOrientationPatient;
                    atDcmMetaData{jj}.PixelSpacing            = atRefMetaData{jj}.PixelSpacing;  
                    atDcmMetaData{jj}.Rows                    = atRefMetaData{jj}.Rows;  
                    atDcmMetaData{jj}.Columns                 = atRefMetaData{jj}.Columns;  
                    atDcmMetaData{jj}.SpacingBetweenSlices    = atRefMetaData{jj}.SpacingBetweenSlices;  
                    atDcmMetaData{jj}.SliceThickness          = atRefMetaData{jj}.SliceThickness;      
                    atDcmMetaData{jj}.SliceLocation           = atRefMetaData{jj}.SliceLocation;      
                else
                    atDcmMetaData{jj}.ImagePositionPatient    = atRefMetaData{1}.ImagePositionPatient;
                    atDcmMetaData{jj}.ImageOrientationPatient = atRefMetaData{1}.ImageOrientationPatient;
                    atDcmMetaData{jj}.PixelSpacing            = atRefMetaData{1}.PixelSpacing;  
                    atDcmMetaData{jj}.Rows                    = atRefMetaData{1}.Rows;  
                    atDcmMetaData{jj}.Columns                 = atRefMetaData{1}.Columns;  
                    atDcmMetaData{jj}.SpacingBetweenSlices    = atRefMetaData{1}.SpacingBetweenSlices;  
                    atDcmMetaData{jj}.SliceThickness          = atRefMetaData{1}.SliceThickness;      
                    atDcmMetaData{jj}.SliceLocation           = atRefMetaData{1}.SliceLocation;                    
                end
            end            
        else
            if dRefOutputView == false % Keep source z
                computedSliceThikness = dcmSliceThickness;
            else
                computedSliceThikness = (dimsRef(3) * refSliceThickness) / dimsRsp(3); 
            end
        %    computedSliceThikness = Rrsmp.PixelExtentInWorldZ; 
    
            for jj=1:numel(atDcmMetaData)
    
                atDcmMetaData{jj}.InstanceNumber  = jj;               
                atDcmMetaData{jj}.NumberOfSlices  = dimsRsp(3);                
    
        %        atDcmMetaData{jj}.PixelSpacing(1) = atRefMetaData{1}.PixelSpacing(1);
        %        atDcmMetaData{jj}.PixelSpacing(2) = atRefMetaData{1}.PixelSpacing(2);
                atDcmMetaData{jj}.PixelSpacing(1) = dimsDcm(1)/dimsRsp(1)*atDcmMetaData{jj}.PixelSpacing(1);
                atDcmMetaData{jj}.PixelSpacing(2) = dimsDcm(2)/dimsRsp(2)*atDcmMetaData{jj}.PixelSpacing(2);
                atDcmMetaData{jj}.SliceThickness  = atRefMetaData{1}.SliceThickness;
                atDcmMetaData{jj}.SpacingBetweenSlices  = computedSliceThikness;
    
                atDcmMetaData{jj}.Rows    = dimsRsp(1);
                atDcmMetaData{jj}.Columns = dimsRsp(2);
                atDcmMetaData{jj}.NumberOfSlices = numel(atDcmMetaData);
    
                atDcmMetaData{jj}.ImagePositionPatient(1) = -(atDcmMetaData{jj}.PixelSpacing(1)*dimsRsp(1)/2);               
                atDcmMetaData{jj}.ImagePositionPatient(2) = -(atDcmMetaData{jj}.PixelSpacing(2)*dimsRsp(2)/2);               
        %        atDcmMetaData{jj}.ImagePositionPatient(3) = atRefMetaData{1}.ImagePositionPatient(3);               
    
                if bUpdateDescription == true 
                    atDcmMetaData{jj}.SeriesDescription  = sprintf('RSP %s', atDcmMetaData{1}.SeriesDescription);
                end           
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

