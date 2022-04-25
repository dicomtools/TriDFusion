function [aAlphaMap, sAlphaType] = getMipAlphaMap(sAction, im, sTypeOrtMetaData, aValue)
%function [aAlphaMap, sAlphaType] = getMipAlphaMap(sAction, im, sTypeOrtMetaData, aValue)
%Get/Set the MIP AlphaMap, base on scan type.
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

    if strcmpi('set', sAction)
        if strcmpi(sTypeOrtMetaData, 'Linear')
            if exist('aValue', 'var')
                paAlphaMap   = aValue;
            else
                paAlphaMap = linspace(0, mipLinearAlphaValue('get'), 256)';                        
            end
            pasAlphaType = sTypeOrtMetaData;
            
        elseif strcmpi(sTypeOrtMetaData, 'Custom')            
            mipICObj = mipICObject('get');
            if isempty(mipICObj)
                paAlphaMap = linspace(0, 1, 256)';
            else
                paAlphaMap = computeAlphaMap(mipICObj);
            end
            pasAlphaType = sTypeOrtMetaData;
            
        elseif strcmpi(sTypeOrtMetaData, 'MR')
           paAlphaMap   = defaultMipAlphaMap(im, 'MR');
           pasAlphaType = sTypeOrtMetaData;

        elseif strcmpi(sTypeOrtMetaData, 'CT')     
            paAlphaMap   = defaultMipAlphaMap(im, 'CT');
            pasAlphaType = sTypeOrtMetaData;
            
        elseif strcmpi(sTypeOrtMetaData, 'PET')     
            paAlphaMap   = defaultMipAlphaMap(im, 'PET');
            pasAlphaType = sTypeOrtMetaData;  
            
        elseif strcmpi(sTypeOrtMetaData, 'Auto')               
            paAlphaMap   = '';
            pasAlphaType = 'Auto';       
        end 
    else
        if strcmpi(pasAlphaType, 'Custom')

            mipICObj = mipICObject('get');
            if ~isempty(mipICObj)
                paAlphaMap = computeAlphaMap(mipICObj);
            end
        elseif strcmpi(pasAlphaType, 'Linear')
            paAlphaMap = linspace(0, mipLinearAlphaValue('get'), 256)';                        
            
        elseif strcmpi(pasAlphaType, 'Auto')
            if strcmpi(sTypeOrtMetaData{1}.Modality, 'CT')
                paAlphaMap   = defaultMipAlphaMap(im, 'CT');
                pasAlphaType = 'Auto';
            elseif strcmpi(sTypeOrtMetaData{1}.Modality, 'MR')
                paAlphaMap   = defaultMipAlphaMap(im, 'MR');
                pasAlphaType = 'Auto';    
            else
                paAlphaMap   = defaultMipAlphaMap(im, 'PET');
                pasAlphaType = 'Auto';                  
            end            
        end
    end

    aAlphaMap  = paAlphaMap;
    sAlphaType = pasAlphaType;                        

end