function mainToolBarEnable(sEnable)
%function mainToolBarEnable(sEnable)
%Activate/Deactivate all toolbar btn.
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

    set(btn3DPtr('get')          , 'Enable', sEnable);
    set(btnIsoSurfacePtr('get')  , 'Enable', sEnable);
    set(btnTriangulatePtr('get') , 'Enable', sEnable);        
    set(btnMIPPtr('get')         , 'Enable', sEnable);            
    set(btnPanPtr('get')         , 'Enable', sEnable);
    set(btnZoomPtr('get')        , 'Enable', sEnable);
    
    if numel(inputTemplate('get')) > 1
        set(btnRegisterPtr('get'), 'Enable', sEnable); 
    end
    
    if numel(dicomBuffer('get'))
        set(btnMathPtr('get'), 'Enable', 'on');
    end

    if size(dicomBuffer('get'), 3) ~= 1 && ...
       numel(dicomBuffer('get'))
        set(btnVsplashPtr('get')   , 'Enable', 'on');
        set(uiEditVsplahXPtr('get'), 'Enable', 'on');
        set(uiEditVsplahYPtr('get'), 'Enable', 'on');
    end    
%        set(uiSliderWindowPtr('get') , 'Enable', sEnable);
%        set(uiSliderLevel  , 'Enable', sEnable);           
end