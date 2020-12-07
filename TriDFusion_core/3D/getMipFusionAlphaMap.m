function [aAlphaMap, sAlphaType] = getMipFusionAlphaMap(sAction, im, sTypeOrtMetaData, aValue)
%function [aAlphaMap, sAlphaType] = getMipFusionAlphaMap(sAction, im, sTypeOrtMetaData, aValue)
%Get Fusion AlphaMap, base on scan type.
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

    persistent paAlphaMap;
    persistent pasAlphaType;

    if strcmp('set', sAction)
        if strcmp(sTypeOrtMetaData, 'linear')
            if exist('aValue', 'var')
                paAlphaMap   = aValue;
            else
                paAlphaMap = linspace(0, mipLinearFuisonAlphaValue('get'), 256)';                        
            end
            pasAlphaType = sTypeOrtMetaData;
            
        elseif strcmp(sTypeOrtMetaData, 'custom')            
            mipICObj = mipICFusionObject('get');
            if isempty(mipICObj)
                paAlphaMap = linspace(0, 1, 256)';
            else
                paAlphaMap = computeAlphaMap(mipICObj);
            end
            pasAlphaType = sTypeOrtMetaData;
            
        elseif strcmp(sTypeOrtMetaData, 'mr')
           paAlphaMap   = defaultMipFusionAlphaMap(im, 'mr');
           pasAlphaType = sTypeOrtMetaData;

        elseif strcmp(sTypeOrtMetaData, 'ct')     
            paAlphaMap   = defaultMipFusionAlphaMap(im, 'ct');
            pasAlphaType = sTypeOrtMetaData;
            
        elseif strcmp(sTypeOrtMetaData, 'pt')     
            paAlphaMap   = defaultMipFusionAlphaMap(im, 'pt');
            pasAlphaType = sTypeOrtMetaData;  
            
        elseif strcmp(sTypeOrtMetaData, 'auto')               
            paAlphaMap   = '';
            pasAlphaType = 'auto';       
        end 
    else
        if strcmp(pasAlphaType, 'custom')

            mipICObj = mipICFusionObject('get');
            if ~isempty(mipICObj)
                paAlphaMap = computeAlphaMap(mipICObj);
            end            
        elseif strcmp(pasAlphaType, 'linear')
            paAlphaMap = linspace(0, mipLinearFuisonAlphaValue('get'), 256)';                                  
        elseif strcmpi(pasAlphaType, 'auto')
            if strcmpi(sTypeOrtMetaData{1}.Modality, 'ct')
                paAlphaMap   = defaultMipFusionAlphaMap(im, 'ct');
                pasAlphaType = 'auto';
            elseif strcmpi(sTypeOrtMetaData{1}.Modality, 'mr')
                paAlphaMap   = defaultMipFusionAlphaMap(im, 'mr');
                pasAlphaType = 'auto';    
            else
                paAlphaMap   = defaultMipFusionAlphaMap(im, 'pt');
                pasAlphaType = 'auto';                  
            end            
        end
    end

    aAlphaMap  = paAlphaMap;
    sAlphaType = pasAlphaType;              
    
end