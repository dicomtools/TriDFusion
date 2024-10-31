function tGetLimit = axesLimitsFromTemplate(pAxe, tSetLimit)
%function tGetLimit = axesLimitsFromTemplate(pAxe, tSetLimit)
%Set axe Limit and camera view from a source axe.
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

    if exist('tSetLimit', 'var')

        xLim = get(pAxe, 'XLim');
        yLim = get(pAxe, 'YLim');
        
        dCameraViewAngle = tSetLimit.CameraViewAngle;
        
        xCenter = mean(xLim);
        yCenter = mean(yLim);
        
        % Calculate the new limits based on backup the CameraViewAngle
        
        newXLim = xCenter + (xLim - xCenter) / dCameraViewAngle;  
        newYLim = yCenter + (yLim - yCenter) / dCameraViewAngle;

        set(pAxe, 'XLim'                  , newXLim, ...
                  'YLim'                  , newYLim, ...
                  'XLimMode'              , tSetLimit.XLimMode, ...
                  'YLimMode'              , tSetLimit.YLimMode, ...
                  'ZLim'                  , tSetLimit.ZLim, ...
                  'ZLimMode'              , tSetLimit.ZLimMode, ...
                  'CameraPosition'        , tSetLimit.CameraPosition, ...
                  'CameraPositionMode'    , tSetLimit.CameraPositionMode, ...
                  'CameraTarget'          , tSetLimit.CameraTarget, ...
                  'CameraTargetMode'      , tSetLimit.CameraTargetMode, ...
                  'CameraUpVector'        , tSetLimit.CameraUpVector, ...
                  'CameraUpVectorMode'    , tSetLimit.CameraUpVectorMode, ...
                  'CameraViewAngle'       , tSetLimit.CameraViewAngle, ...
                  'CameraViewAngleMode'   , tSetLimit.CameraViewAngleMode, ...
                  'View'                  , tSetLimit.View, ...
                  'DataAspectRatio'       , tSetLimit.DataAspectRatio, ...
                  'DataAspectRatioMode'   , tSetLimit.DataAspectRatioMode, ...
                  'PlotBoxAspectRatio'    , tSetLimit.PlotBoxAspectRatio, ...
                  'PlotBoxAspectRatioMode', tSetLimit.PlotBoxAspectRatioMode);        
    else
        tGetLimit.XLim                   = get(pAxe, 'XLim');
        tGetLimit.YLim                   = get(pAxe, 'YLim');
        tGetLimit.XLimMode               = get(pAxe, 'XLimMode');
        tGetLimit.YLimMode               = get(pAxe, 'YLimMode');
        tGetLimit.ZLim                   = get(pAxe, 'ZLim');
        tGetLimit.ZLimMode               = get(pAxe, 'ZLimMode');
        tGetLimit.CameraPosition         = get(pAxe, 'CameraPosition');
        tGetLimit.CameraPositionMode     = get(pAxe, 'CameraPositionMode');
        tGetLimit.CameraTarget           = get(pAxe, 'CameraTarget');
        tGetLimit.CameraTargetMode       = get(pAxe, 'CameraTargetMode');
        tGetLimit.CameraUpVector         = get(pAxe, 'CameraUpVector');
        tGetLimit.CameraUpVectorMode     = get(pAxe, 'CameraUpVectorMode');
        tGetLimit.CameraViewAngle        = get(pAxe, 'CameraViewAngle');
        tGetLimit.CameraViewAngleMode    = get(pAxe, 'CameraViewAngleMode');
        tGetLimit.View                   = get(pAxe, 'View');
        tGetLimit.DataAspectRatio        = get(pAxe, 'DataAspectRatio');
        tGetLimit.DataAspectRatioMode    = get(pAxe, 'DataAspectRatioMode');
        tGetLimit.PlotBoxAspectRatio     = get(pAxe, 'PlotBoxAspectRatio');
        tGetLimit.PlotBoxAspectRatioMode = get(pAxe, 'PlotBoxAspectRatioMode');  
    end
 
end