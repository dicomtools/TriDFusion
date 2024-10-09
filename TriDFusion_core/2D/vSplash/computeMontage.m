function imComputed = computeMontage(im, sAxe, dSlice)
%function imComputed = computeMontage(im, sAxe, dSlice)
%Compute 2D vSplash Montage.
%See TriDFuison.doc (or pdf) for more information about options.
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

    dVsplashLayoutX = vSplashLayout('get', 'x');
    dVsplashLayoutY = vSplashLayout('get', 'y');

    switch lower(sAxe)
        case 'coronal'
            [lFirst, ~] = computeVsplashLayout(im, sAxe, dSlice);        

            lOffset=lFirst; 
            for bb=1:dVsplashLayoutY
                imMontage{bb} = cat(2, permute(im(lOffset,:,:), [3 2 1]), permute(im(lOffset+1,:,:), [3 2 1]));                    
                lOffset = lOffset+2;
                for cc=1:dVsplashLayoutX-2
                    imMontage{bb} = cat(2, imMontage{bb}, permute(im(lOffset,:,:), [3 2 1]));
                    lOffset = lOffset+1;
                end                                         
            end

        case 'sagittal'
            [lFirst, ~] = computeVsplashLayout(im, sAxe, dSlice);        

            lOffset=lFirst; 
            for bb=1:dVsplashLayoutY
                imMontage{bb} = cat(2, permute(im(:,lOffset,:), [3 1 2]), permute(im(:,lOffset+1,:), [3 1 2]));                    
                lOffset = lOffset+2;
                for cc=1:dVsplashLayoutX-2
                    imMontage{bb} = cat(2, imMontage{bb}, permute(im(:,lOffset,:), [3 1 2]));
                    lOffset = lOffset+1;
                end                                        
            end

        case 'axial'
%            tMontage = montage(im, 'Size', [dVsplashLayoutX dVsplashLayoutY]);
%            imComputed = tMontage.CData;
             % dAxialSliceNumber = size(dicomBuffer('get'), 3)-dSlice+1;

            [lFirst, ~] = computeVsplashLayout(im, sAxe, dSlice);   

            lOffset=lFirst; 
            for bb=1:dVsplashLayoutY
                imMontage{bb} = cat(2, im(:,:,lOffset), im(:,:,lOffset+1));                    
                lOffset = lOffset+2;
                for cc=1:dVsplashLayoutX-2
                    imMontage{bb} = cat(2, imMontage{bb}, im(:,:,lOffset));
                    lOffset = lOffset+1;
               end                                        
            end

    end

    imComputed = cat(1, imMontage{1}, imMontage{2});
    for dd=3:dVsplashLayoutY
        imComputed = cat(1, imComputed, imMontage{dd});
    end    

end