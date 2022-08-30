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

    if ~isempty(dicomBuffer('get'))
               
        set(btnTriangulatePtr('get') , 'Enable', sEnable);        
        set(btnPanPtr('get')         , 'Enable', sEnable);
        set(btnZoomPtr('get')        , 'Enable', sEnable);

        set(btnFusionPtr('get')      , 'Enable', sEnable);
        set(uiFusedSeriesPtr('get')  , 'Enable', sEnable);

        if numel(inputTemplate('get')) > 1
            set(btnRegisterPtr('get'), 'Enable', sEnable); 
        end

        set(btnMathPtr('get'), 'Enable', sEnable);
        
        if size(dicomBuffer('get'), 3) ~= 1 

            set(btn3DPtr('get')          , 'Enable', sEnable);
            set(btnIsoSurfacePtr('get')  , 'Enable', sEnable);
            set(btnMIPPtr('get')         , 'Enable', sEnable); 

            set(btnLinkMipPtr('get')     , 'Enable', sEnable);

            set(btnVsplashPtr('get')     , 'Enable', sEnable);
            set(uiEditVsplahXPtr('get')  , 'Enable', sEnable);
            set(uiEditVsplahYPtr('get')  , 'Enable', sEnable);

        else
            set(btn3DPtr('get')        , 'Enable', 'off');
            set(btnIsoSurfacePtr('get'), 'Enable', 'off');
            set(btnMIPPtr('get')       , 'Enable', 'off'); 

            set(btnVsplashPtr('get')   , 'Enable', 'off');
            set(uiEditVsplahXPtr('get'), 'Enable', 'off');
            set(uiEditVsplahYPtr('get'), 'Enable', 'off');
            
            set(btnLinkMipPtr('get')   , 'Enable', 'off');            
        end
    else
        set(btn3DPtr('get')          , 'Enable', 'off');
        set(btnIsoSurfacePtr('get')  , 'Enable', 'off');
        set(btnMIPPtr('get')         , 'Enable', 'off'); 

        set(btnVsplashPtr('get')     , 'Enable', 'off');
        set(uiEditVsplahXPtr('get')  , 'Enable', 'off');
        set(uiEditVsplahYPtr('get')  , 'Enable', 'off');
            
        set(btnTriangulatePtr('get') , 'Enable', 'off');        
        set(btnPanPtr('get')         , 'Enable', 'off');
        set(btnZoomPtr('get')        , 'Enable', 'off');
        
        set(btnRegisterPtr('get')    , 'Enable', 'off'); 
        set(btnMathPtr('get')        , 'Enable', 'off');
        
        set(btnFusionPtr('get')      , 'Enable', 'off');
        set(uiFusedSeriesPtr('get')  , 'Enable', 'off');
     
        set(btnLinkMipPtr('get')     , 'Enable', 'off');
    end    
        
end