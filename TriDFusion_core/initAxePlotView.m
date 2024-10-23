function initAxePlotView(pAxe)
%function initAxePlotView(pAxe)
%Init axe plot view initial value.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2024, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    % Initialize and store the original view settings manually

    tOrigInfo.XLim                  = get(pAxe, 'XLim');
    tOrigInfo.XLimMode              = get(pAxe, 'XLimMode');
    tOrigInfo.YLim                  = get(pAxe, 'YLim');
    tOrigInfo.YLimMode              = get(pAxe, 'YLimMode');
    tOrigInfo.ZLim                  = get(pAxe, 'ZLim');
    tOrigInfo.ZLimMode              = get(pAxe, 'ZLimMode');
    
    tOrigInfo.CameraPosition        = get(pAxe, 'CameraPosition');
    tOrigInfo.CameraPositionMode    = get(pAxe, 'CameraPositionMode');
    tOrigInfo.CameraTarget          = get(pAxe, 'CameraTarget');
    tOrigInfo.CameraTargetMode      = get(pAxe, 'CameraTargetMode');
    tOrigInfo.CameraUpVector        = get(pAxe, 'CameraUpVector');
    tOrigInfo.CameraUpVectorMode    = get(pAxe, 'CameraUpVectorMode');
    tOrigInfo.CameraViewAngle       = get(pAxe, 'CameraViewAngle');
    tOrigInfo.CameraViewAngleMode   = get(pAxe, 'CameraViewAngleMode');
    
    tOrigInfo.View                  = get(pAxe, 'View');
    tOrigInfo.DataAspectRatio       = get(pAxe, 'DataAspectRatio');
    tOrigInfo.DataAspectRatioMode   = get(pAxe, 'DataAspectRatioMode');
    tOrigInfo.PlotBoxAspectRatio    = get(pAxe, 'PlotBoxAspectRatio');
    tOrigInfo.PlotBoxAspectRatioMode = get(pAxe, 'PlotBoxAspectRatioMode');
    
    % Store all properties in the app data for later use
    setappdata(pAxe, 'matlab_graphics_resetplotview', tOrigInfo);
end