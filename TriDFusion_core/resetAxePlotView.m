function resetAxePlotView(pAxe)
%function resetAxePlotView(pAxe)
%Reset axe plot view to it initial value.
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

    tOrigInfo = getappdata(pAxe, 'matlab_graphics_resetplotview');
    
    if ~isempty(tOrigInfo)
        set(pAxe,'DataAspectRatioMode'   , tOrigInfo.DataAspectRatioMode);
        set(pAxe,'DataAspectRatio'       , tOrigInfo.DataAspectRatio);
        set(pAxe,'CameraViewAngleMode'   , tOrigInfo.CameraViewAngleMode);
        set(pAxe,'PlotBoxAspectRatioMode', tOrigInfo.PlotBoxAspectRatioMode);
        set(pAxe,'CameraPositionMode'    , tOrigInfo.CameraPositionMode);
        set(pAxe,'CameraTargetMode'      , tOrigInfo.CameraTargetMode);
        set(pAxe,'CameraUpVectorMode'    , tOrigInfo.CameraUpVectorMode);
        set(pAxe,'XLimMode'              , tOrigInfo.XLimMode);
        set(pAxe,'XLim'                  , tOrigInfo.XLim);
        set(pAxe,'YLimMode'              , tOrigInfo.YLimMode);
        set(pAxe,'YLim'                  , tOrigInfo.YLim);
        set(pAxe,'ZLimMode'              , tOrigInfo.ZLimMode);
        set(pAxe,'View'                  , tOrigInfo.View);
    end
end