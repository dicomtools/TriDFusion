function atRoi = resampleROIs(dcmImage, atDcmMetaData, refImage, atRefMetaData, sMode)
%function aROIsPosition = resampleROIs(dcmImage, atDcmMetaData, refImage, sMode)
%Resample any ROIs.
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

    atRoi = roiTemplate('get');
    
    tInput = inputTemplate('get');        
    iOffset = get(uiSeriesPtr('get'), 'Value');
    if iOffset > numel(tInput)  
        return;
    end 
    
    dimsRef = size(refImage);        
    dimsDcm = size(dcmImage);

    if numel(dimsRef)==numel(dimsDcm)
        if dimsRef == dimsDcm
            return;
        end
    end   
    
        
    dcmSliceThickness = computeSliceSpacing(atDcmMetaData);

    yScale = size(refImage,1)/size(dcmImage,1);
    xScale = size(refImage,2)/size(dcmImage,2);
    zScale = size(refImage,3)/size(dcmImage,3);
    f = [ yScale 0      0      0
          0      xScale 0      0
          0      0      zScale 0
          0      0      0      1];
      
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

    for jj=1:numel(atRoi)
        if atRoi{jj}.Object.Parent ==  axes3Ptr('get')

            yScale = size(refImage,1)/size(dcmImage,1);
            xScale = size(refImage,2)/size(dcmImage,2);
                                     
         %   bw = createMask(atRoi{jj}.Object, size(dcmImage,1), size(dcmImage,2));
         %   bw = poly2mask(atRoi{jj}.Object.Position(:,1),atRoi{jj}.Object.Position(:,2),size(dcmImage,1), size(dcmImage,2));
            f = [ yScale 0            0
                  0      xScale       0
                  0      0            1];    
         %   TF = affine2d(f);

         %   Rdcm = imref2d(size(bw));

         %   [bw2, ~] = imwarp(bw, Rdcm, TF,'Interp', sMode, 'FillValues', double(min(bw,[],'all')) );  

         %   B = bwboundaries(bw2);

         %   aROIsPosition{jj} = flip(B{1}, 2);
            try
                TF = maketform('affine', f);
                atRoi{jj}.Object.Position = tformfwd(TF,atRoi{jj}.Object.Position(:,1), atRoi{jj}.Object.Position(:,2));  
                atRoi{jj}.Object.Position(:) = atRoi{jj}.Object.Position(:)-1;
                atRoi{jj}.Position = atRoi{jj}.Object.Position;
                atRoi{jj}.SliceNb = round(atRoi{jj}.SliceNb*zScale);                
            catch
            end
            
        end
    end
    
    roiTemplate('set', atRoi);    
    
    function A = getAffineXfm(headers)
        % Constants
        N = length(headers);
        dr = headers{1}.PixelSpacing(1);
        dc = headers{1}.PixelSpacing(2);
        F(:,1) = headers{1}.ImageOrientationPatient(1:3);
        F(:,2) = headers{1}.ImageOrientationPatient(4:6);
        T1 = headers{1}.ImagePositionPatient;
        TN = headers{end}.ImagePositionPatient;
        k = (T1 - TN) ./ (1 - N);
        % Build affine transformation
        A = [[F(1,1)*dr F(1,2)*dc k(1) T1(1)]; ...
            [F(2,1)*dr F(2,2)*dc k(2) T1(2)]; ...
            [F(3,1)*dr F(3,2)*dc k(3) T1(3)]; ...
            [0         0         0    1    ]];
    end  
    
end  

