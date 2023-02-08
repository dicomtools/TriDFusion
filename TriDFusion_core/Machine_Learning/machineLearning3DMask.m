function [aMask, aColor] = machineLearning3DMask(sAction, sOrgan, aNiiImage, aMaskColor)  
%function  aMask = machineLearning3DMask(sAction, sOrgan, aNiiImage, aMaskColor)  
%Get\set 3D machine learning mask.
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

    persistent paLiverMask;
    persistent paLungsMask;
    
    persistent paLungLowerLobeRightMask;
    persistent paLungLowerLobeLeftMask;
    persistent paLungMiddleLobeRightMask;
    persistent paLungUpperLobeRightMask;
    persistent paLungUpperLobeLeftMask;

    persistent paLiverColor;
    persistent paLungsColor;

    persistent paLungLowerLobeRightColor;
    persistent paLungLowerLobeLeftColor;
    persistent paLungMiddleLobeRightColor;
    persistent paLungUpperLobeRightColor;
    persistent paLungUpperLobeLeftColor;

    if strcmpi(sAction, 'set')
        switch lower(sOrgan)
            case 'liver'
                paLiverMask  = aNiiImage;
                paLiverColor = aMaskColor;

            case 'lungs'
                paLungsMask  = aNiiImage;
                paLungsColor = aMaskColor;

            case 'lung_lower_lobe_right'
                paLungLowerLobeRightMask  = aNiiImage;
                paLungLowerLobeRightColor = aMaskColor;                

            case 'lung_lower_lobe_left'
                paLungLowerLobeLeftMask  = aNiiImage;
                paLungLowerLobeLeftColor = aMaskColor;                

            case 'lung_middle_lobe_right'
                paLungMiddleLobeRightMask  = aNiiImage;
                paLungMiddleLobeRightColor = aMaskColor;

            case 'lung_upper_lobe_right'
                paLungUpperLobeRightMask  = aNiiImage;
                paLungUpperLobeRightColor = aMaskColor;

            case 'lung_upper_lobe_left'
                paLungUpperLobeLeftMask  = aNiiImage;
                paLungUpperLobeLeftColor = aMaskColor;                
        end

    elseif strcmpi(sAction, 'init')
        
        paLiverMask  = [];
        paLungsMask  = [];

        paLiverColor = [];
        paLungsColor = [];

        paLungLowerLobeRightMask   = [];
        paLungLowerLobeLeftMask    = [];
        paLungMiddleLobeRightMask  = [];
        paLungUpperLobeRightMask   = [];
        paLungUpperLobeLeftMask    = [];

        paLungLowerLobeRightColor  = [];
        paLungLowerLobeLeftColor   = [];
        paLungMiddleLobeRightColor = [];
        paLungUpperLobeRightColor  = [];
        paLungUpperLobeLeftColor   = [];        

    else
        switch lower(sOrgan)
            case 'liver'
                aMask  = paLiverMask;
                aColor = paLiverColor;

            case 'lungs'
                aMask  = paLungsMask;
                aColor = paLungsColor;

            case 'lung_lower_lobe_right'
                aMask  = paLungLowerLobeRightMask ;
                aColor = paLungLowerLobeRightColor;                

            case 'lung_lower_lobe_left'
                aMask  = paLungLowerLobeLeftMask;
                aColor = paLungLowerLobeLeftColor;                

            case 'lung_middle_lobe_right'
                aMask  = paLungMiddleLobeRightMask;
                aColor = paLungMiddleLobeRightColor;

            case 'lung_upper_lobe_right'
                aMask  = paLungUpperLobeRightMask;
                aColor = paLungUpperLobeRightColor;

            case 'lung_upper_lobe_left'
                aMask  = paLungUpperLobeLeftMask;
                aColor = paLungUpperLobeLeftColor;                     
        end        
    end
   
end