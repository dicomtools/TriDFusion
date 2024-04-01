function uiLogo = displayLogo(uiWindow)
%function uiLogo = displayLogo(uiWindow)
%Display Viewer Logo.
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

    if (switchTo3DMode('get')     == false && ...
        switchToIsoSurface('get') == false && ...
        switchToMIPMode('get')    == false)

        if size(dicomBuffer('get'), 3) == 1  || ...
          (isVsplash('get') == true && ...
          strcmpi(vSplahView('get'), 'axial')) || ...
          (isVsplash('get') == true && ...
          strcmpi(vSplahView('get'), 'coronal')) || ...
          (isVsplash('get') == true && ...
          strcmpi(vSplahView('get'), 'sagittal'))

            if isFusion('get') == true
                uiLogo = axes(uiWindow,...
                              'Units'   , 'pixels',...
                              'position', [5 35 70 30],...
                              'color', 'cyan',...
                              'visible', 'off'...
                             );
                uiLogo.Interactions = [zoomInteraction regionZoomInteraction rulerPanInteraction];
                uiLogo.Toolbar.Visible = 'off';
                disableDefaultInteractivity(uiLogo);
            else
                uiLogo = axes(uiWindow,...
                              'Units'   , 'pixels',...
                              'position', [5 15 70 30],...
                              'color', 'cyan',...
                              'visible', 'off'...
                             );
                uiLogo.Interactions = [zoomInteraction regionZoomInteraction rulerPanInteraction];
                uiLogo.Toolbar.Visible = 'off';
                disableDefaultInteractivity(uiLogo);
            end
        else
            uiLogo =  axes(uiWindow,...
                           'Units'   , 'pixels',...
                           'position', [5 15 70 30],...
                           'color', 'cyan',...
                           'visible', 'off'...
                          );
            uiLogo.Interactions = [zoomInteraction regionZoomInteraction rulerPanInteraction];
            uiLogo.Toolbar.Visible = 'off';
            disableDefaultInteractivity(uiLogo);
      end

   else
        uiLogo =  axes(uiWindow,...
                       'Units'   , 'pixels',...
                       'position', [5 15 70 30],...
                       'color', 'cyan',...
                       'visible', 'off'...
                      );
        uiLogo.Interactions = [zoomInteraction regionZoomInteraction rulerPanInteraction];
        uiLogo.Toolbar.Visible = 'off';
        disableDefaultInteractivity(uiLogo);
 end

   t = text(uiLogo, 0, 0, 'TriDFusion (3DF)');

   if switchTo3DMode('get')     == true || ...
      switchToIsoSurface('get') == true || ...
      switchToMIPMode('get')    == true

       if strcmp(surfaceColor('get', background3DOffset('get')), 'black')||...
          strcmp(surfaceColor('get', background3DOffset('get')), 'blue' )

            t.Color = [0.8500 0.8500 0.8500];
       else
            t.Color = [0.1500 0.1500 0.1500];
       end
   else
       if strcmp(backgroundColor('get'), 'black')
            t.Color = [0.8500 0.8500 0.8500];
       else
            t.Color = [0.1500 0.1500 0.1500];
       end
   end

%    logoObject('set', uiLogo);

end
