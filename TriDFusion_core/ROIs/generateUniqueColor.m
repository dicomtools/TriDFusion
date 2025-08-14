function aColor = generateUniqueColor(bInit)   
%function aColor = generateUniqueColor(bInit)
%The function return an unique number.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2025, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    persistent pdHue
    
    if isempty(pdHue) || bInit
        pdHue = rand();
        if bInit, return; end
    end
    
    % For bright colors 
    dSaturation = 0.95;
    dValue      = 1;
    
    dGoldenRatioConjugate = 0.618033988749895;
    pdHue = mod(pdHue + dGoldenRatioConjugate, 1);
    
    % compute RGB
    rgb = hsv2rgb([pdHue, dSaturation, dValue]);
    
    % helper to go linear
    toLinear = @(c) (c<=0.03928) .* (c/12.92) + (c>0.03928) .* (((c+0.055)/1.055).^2.4);
    
    R = toLinear(rgb(1));
    G = toLinear(rgb(2));
    B = toLinear(rgb(3));
    
    Y = 0.2126*R + 0.7152*G + 0.0722*B;            % relative luminance
    contrast = (Y + 0.05) / 0.05;
    
    % require at least, say, 4.5:1 contrast
    while contrast < 4.5
        pdHue = mod(pdHue + dGoldenRatioConjugate, 1);
        rgb    = hsv2rgb([pdHue, dSaturation, dValue]);
        R = toLinear(rgb(1)); G = toLinear(rgb(2)); B = toLinear(rgb(3));
        Y = 0.2126*R + 0.7152*G + 0.0722*B;
        contrast = (Y + 0.05)/0.05;
    end
    
    aColor = rgb;

end
