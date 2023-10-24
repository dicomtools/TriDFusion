function setView3DPanel(~, ~)
%function setView3DPanel(~, ~)   
%Set 3D Panel.
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

    hObject = view3DPanelMenuObject('get');

    if switchTo3DMode('get')     == true || ...
       switchToIsoSurface('get') == true || ...
       switchToMIPMode('get')    == true

        if strcmp(hObject.Checked, 'on')

            view3DPanel('set', false);

            hObject.Checked = 'off';

            uiMain3DPanel = uiMain3DPanelPtr('get');
            if ~isempty(uiMain3DPanel)

                set(uiMain3DPanel, 'Visible', 'off'); 

                uiOneWindow = uiOneWindowPtr('get');
                if ~isempty(uiOneWindow)

                    setOneWindowPosition(uiOneWindow);
                end
           end
        else
            view3DPanel('set', true);

            hObject.Checked = 'on';

            uiMain3DPanel = uiMain3DPanelPtr('get');

            if ~isempty(uiMain3DPanel)

                set(uiMain3DPanel, 'Visible','on'); 

                uiOneWindow = uiOneWindowPtr('get');
                if ~isempty(uiOneWindow)

                    setOneWindowPosition(uiOneWindow); 
                end
            end
        end
    end                                              
end
