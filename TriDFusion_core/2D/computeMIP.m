function imComputed = computeMIP(im)
%function imComputed = computeMIP(im)
%Compute 2D MIP.
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
% along with TriDFusion.  If not, see <http://www.gnu.org/licenses/>. 
 
    if canUseGPU()
%         aImage = gpuArray(uint16(im));
        try    
            bGPUArray = true;
            
            aImage = gpuArray(single(im));
        catch
            bGPUArray = false;
            
            aImage = single(im);            
        end
    else
        bGPUArray = false;

        aImage = single(im);
    end

    aSize = size(im);

    if bGPUArray == true
        imComputed = gpuArray.zeros(32, aSize(2), aSize(3), 'single'); % Preallocate on GPU if possible
    else
        imComputed = zeros(32, aSize(2), aSize(3), 'single');
    end

    angles = 11:11:351;

    imComputed(1,:,:) = max(im, [], 1);

    for  cc = 2:32
        
        angle = angles(cc-1); % Corresponding angle 

        if mod(cc,4)==1 || cc == 32 || cc==2         

            progressBar(cc/32-0.00001, sprintf('Computing MIP angle %d/32', cc));               
        end
        
%        aRotatedImage = imrotate3(im, rr, [0 0 1], 'linear','crop', 'FillValues', min(im, [], 'all'));
        aRotatedImage = imrotate(aImage, angle, 'bilinear', 'crop');

        imComputed(cc,:,:) = max(aRotatedImage, [], 1);
               
    end    

    imComputed = gather(squeeze(imComputed));

    clear aImage;
    clear aRotatedImage;

    progressBar(1, 'Ready');               

end

