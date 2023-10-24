function pAxe = getAxeFromMousePosition(dSeriesOffset)        
%function pAxe = getAxeFromMousePosition(dSeriesOffset)
%Return mouse position associated axe.
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

    if size(dicomBuffer('get', [], dSeriesOffset), 3) == 1
        pAxe = axePtr('get', [], dSeriesOffset);
    else
        
        if     isPanelFullScreen(btnUiCorWindowFullScreenPtr('get'))
            pAxe = axes1Ptr('get', [], dSeriesOffset);   % Coronal

        elseif isPanelFullScreen(btnUiSagWindowFullScreenPtr('get'))
            pAxe = axes2Ptr('get', [], dSeriesOffset);   % Sagittal

        elseif isPanelFullScreen(btnUiTraWindowFullScreenPtr('get'))
            pAxe = axes3Ptr('get', [], dSeriesOffset);   % Axial

        elseif isPanelFullScreen(btnUiMipWindowFullScreenPtr('get'))
            pAxe = axesMipPtr('get', [], dSeriesOffset); % MIP
       
        else
            if isVsplash('get') == true &&  ~strcmpi(vSplahView('get'), 'all')
                
                if strcmpi(vSplahView('get'), 'Coronal')
                    pAxe = axes1Ptr('get', [], dSeriesOffset);   % Coronal

                elseif strcmpi(vSplahView('get'), 'Sagittal')
                    pAxe = axes2Ptr('get', [], dSeriesOffset);   % Sagittal

                elseif strcmpi(vSplahView('get'), 'Axial')
                    pAxe = axes3Ptr('get', [], dSeriesOffset);   % Axial
                else

                end
            else

                % Get the current point
        
                current_point = get(fiMainWindowPtr('get'), 'CurrentPoint');
                mouseX = current_point(1, 1);
                mouseY = current_point(1, 2);
                
                posCor = getpixelposition(uiCorWindowPtr('get', dSeriesOffset));
                posSag = getpixelposition(uiSagWindowPtr('get', dSeriesOffset));
                posTra = getpixelposition(uiTraWindowPtr('get', dSeriesOffset));
        
                if mouseX > posCor(1) && mouseX < (posCor(1)+posCor(3)) && ...      % Coronal
                   mouseY > posCor(2) && mouseY < (posCor(2)+posCor(4))   
        
                    pAxe = axes1Ptr('get', [], dSeriesOffset);
        
                elseif  mouseX > posSag(1) && mouseX < (posSag(1)+posSag(3)) && ... % Sagittal
                        mouseY > posSag(2) && mouseY < (posSag(2)+posSag(4))     
                    pAxe = axes2Ptr('get', [], dSeriesOffset);
        
                elseif  mouseX > posTra(1) && mouseX < (posTra(1)+posTra(3)) && ... % Axial
                        mouseY > posTra(2) && mouseY < (posTra(2)+posTra(4))    
                    pAxe = axes3Ptr('get', [], dSeriesOffset);
        
                else
                    pAxe = axesMipPtr('get', [], dSeriesOffset); % MIP
                end     
            end
        end
    end
end

