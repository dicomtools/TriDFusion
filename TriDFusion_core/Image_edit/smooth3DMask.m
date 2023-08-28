function aMask = smooth3DMask(aMask, fSigma, dFilterSize ,dThreshold)
%function aMask = smooth3DMask(aMask, fSigma, dFilterSize ,dThreshold)
%Smooth a 3D mask.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2023, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    % Create a 3D Gaussian filter

    filter_size = ceil(dFilterSize * fSigma); 
    [x, y, z] = meshgrid(-filter_size:filter_size, -filter_size:filter_size, -filter_size:filter_size);

    gaussian_filter = exp(-(x.^2 + y.^2 + z.^2) / (2 * fSigma^2));
    gaussian_filter = gaussian_filter / sum(gaussian_filter(:)); % Normalize the filter
    
    % Apply the Gaussian filter to the mask using convolution        
    % Threshold the smoothed mask to get a binary result

    aMask = convn(aMask, gaussian_filter, 'same') >= dThreshold;

end