function sR_reg = R_regToString(R_reg)
%function sR_reg = R_regToString(R_reg)
%Register any modalities.
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

    sR_reg = sprintf('       XWorldLimits: [%f %f]\n',R_reg.XWorldLimits);
    sR_reg = sprintf('%s       YWorldLimits: [%f %f]\n',sR_reg, R_reg.YWorldLimits);
    if isfield(R_reg, 'ZWorldLimits') % 3D Images
        sR_reg = sprintf('%s       ZWorldLimits: [%f %f]\n',sR_reg, R_reg.ZWorldLimits);
    end

    sR_reg = sprintf('%s          ImageSize: [%f %f %f]\n',sR_reg, R_reg.ImageSize);

    sR_reg = sprintf('%sPixelExtentInWorldX: %f\n',sR_reg, R_reg.PixelExtentInWorldX);
    sR_reg = sprintf('%sPixelExtentInWorldY: %f\n',sR_reg, R_reg.PixelExtentInWorldY);
    if isfield(R_reg, 'PixelExtentInWorldZ')
        sR_reg = sprintf('%sPixelExtentInWorldZ: %f\n',sR_reg, R_reg.PixelExtentInWorldZ);
    end

    sR_reg = sprintf('%sImageExtentInWorldX: %f\n',sR_reg, R_reg.ImageExtentInWorldX);
    sR_reg = sprintf('%sImageExtentInWorldY: %f\n',sR_reg, R_reg.ImageExtentInWorldY);
    if isfield(R_reg, 'ImageExtentInWorldZ')        
        sR_reg = sprintf('%sImageExtentInWorldZ: %f\n',sR_reg, R_reg.ImageExtentInWorldZ);
    end

    sR_reg = sprintf('%s   XIntrinsicLimits: [%f %f]\n',sR_reg, R_reg.XIntrinsicLimits);
    sR_reg = sprintf('%s   YIntrinsicLimits: [%f %f]\n',sR_reg, R_reg.YIntrinsicLimits);
    if isfield(R_reg, 'ZIntrinsicLimits')        
        sR_reg = sprintf('%s   ZIntrinsicLimits: [%f %f]',sR_reg, R_reg.ZIntrinsicLimits);              
    end
end