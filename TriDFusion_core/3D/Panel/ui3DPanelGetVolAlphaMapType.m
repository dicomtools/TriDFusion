function [dVolAlphaOffset, sVolMapSliderEnable] = ui3DPanelGetVolAlphaMapType(sType, atMetaData)
%function aObject = ui3DPanelGetVolAlphaMapType(sAction, aValue)
%Get 3D Panel Volume Alphamap Type.
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

    if strcmpi(sType, 'linear')
        dVolAlphaOffset = 1;
        sVolMapSliderEnable = 'on';
    elseif strcmpi(sType, 'custom')
        dVolAlphaOffset = 2;
        sVolMapSliderEnable = 'off';
    elseif strcmpi(sType, 'mr')
        dVolAlphaOffset = 3;
        sVolMapSliderEnable = 'off';
    elseif strcmpi(sType, 'ct')
        dVolAlphaOffset = 4;
        sVolMapSliderEnable = 'off';
    elseif strcmpi(sType, 'pt')
        dVolAlphaOffset = 5;
        sVolMapSliderEnable = 'off';      
    elseif strcmpi(sType, 'auto')  
        if strcmpi(atMetaData{1}.Modality, 'mr')
            dVolAlphaOffset = 3;
            sVolMapSliderEnable = 'off';             
        elseif strcmpi(atMetaData{1}.Modality, 'ct')
            dVolAlphaOffset = 4;
            sVolMapSliderEnable = 'off';            
        else
            dVolAlphaOffset = 5;
            sVolMapSliderEnable = 'off';              
        end
    end    
end