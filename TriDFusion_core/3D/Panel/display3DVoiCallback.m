function display3DVoiCallback(~, ~)
%function display3DVoiCallback()
%Display 3D VOI
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

    if switchTo3DMode('get')     == false && ...
       switchToIsoSurface('get') == false && ...
       switchToMIPMode('get')    == false
        return;
    end

    displayVoi('set', get(ui3DDispVoiPtr('get'), 'Value'));

    voiObj = voiObject('get');
    if isempty(voiObj)
        voiObj = initVoiIsoSurface(uiOneWindowPtr('get'));
        voiObject('set', voiObj);
    else          

        aVoiEnableList = voi3DEnableList('get');            
        if isempty(aVoiEnableList)
            for aa=1:numel(voiObj)
                aVoiEnableList{aa} = true;
            end
        end

        aVoiTransparencyList = voi3DTransparencyList('get');            
        if isempty(aVoiTransparencyList)
            for aa=1:numel(voiObj)
                aVoiTransparencyList{aa} = slider3DVoiTransparencyValue('get');
            end
        end

        if strcmpi(voi3DRenderer('get'), 'VolumeRendering')

            for ll=1:numel(voiObj)

                if get(ui3DDispVoiPtr('get'), 'Value') == true && aVoiEnableList{ll} == true
                    aAlphamap = compute3DVoiAlphamap(aVoiTransparencyList{ll});
                else
                    aAlphamap = zeros(256,1);
                end                    

                progressBar(ll/numel(voiObj)-0.0001, sprintf('Processing VOI %d/%d', ll, numel(voiObj) ) );      
                set(voiObj{ll}, 'Alphamap', aAlphamap);
            end                
        else                    
            for ll=1:numel(voiObj)
                if get(ui3DDispVoiPtr('get'), 'Value') == true && aVoiEnableList{ll} == true
                    sRenderer = 'Isosurface';
                else
                    sRenderer = 'LabelOverlayRendering';
                end                    

                progressBar(ll/numel(voiObj)-0.0001, sprintf('Processing VOI %d/%d', ll, numel(voiObj) ) );      
                set(voiObj{ll}, 'Renderer', sRenderer);
            end
        end
    end

   progressBar(1, 'Ready');      

   initGate3DObject('set', true);        

end