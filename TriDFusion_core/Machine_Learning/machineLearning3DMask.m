function [aMask, aColor, dVolume] = machineLearning3DMask(sAction, sOrgan, aNiiImage, aMaskColor, dMaskVolume)  
%function  [aMask, aColor, dVolume] = machineLearning3DMask(sAction, sOrgan, aNiiImage, aMaskColor, dMaskVolume)  
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

    persistent paLiverVolume;
    persistent paLungsVolume;

    persistent paLungLowerLobeRightVolume;
    persistent paLungLowerLobeLeftVolume;
    persistent paLungMiddleLobeRightVolume;
    persistent paLungUpperLobeRightVolume;
    persistent paLungUpperLobeLeftVolume;

    if strcmpi(sAction, 'set')

        switch lower(sOrgan)

            case 'liver'

                paLiverMask   = aNiiImage;
                paLiverColor  = aMaskColor;
                paLiverVolume = dMaskVolume;

            case 'lungs'

                paLungsMask   = aNiiImage;
                paLungsColor  = aMaskColor;
                paLungsVolume = dMaskVolume;

            case 'lung_lower_lobe_right'

                paLungLowerLobeRightMask   = aNiiImage;
                paLungLowerLobeRightColor  = aMaskColor;                
                paLungLowerLobeRightVolume = dMaskVolume;

            case 'lung_lower_lobe_left'

                paLungLowerLobeLeftMask   = aNiiImage;
                paLungLowerLobeLeftColor  = aMaskColor;                
                paLungLowerLobeLeftVolume = dMaskVolume;

            case 'lung_middle_lobe_right'

                paLungMiddleLobeRightMask   = aNiiImage;
                paLungMiddleLobeRightColor  = aMaskColor;
                paLungMiddleLobeRightVolume = dMaskVolume;

            case 'lung_upper_lobe_right'

                paLungUpperLobeRightMask   = aNiiImage;
                paLungUpperLobeRightColor  = aMaskColor;
                paLungUpperLobeRightVolume = dMaskVolume;

            case 'lung_upper_lobe_left'

                paLungUpperLobeLeftMask   = aNiiImage;
                paLungUpperLobeLeftColor  = aMaskColor;                
                paLungUpperLobeLeftVolume = dMaskVolume;
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

        paLiverVolume = [];
        paLungsVolume = [];

        paLungLowerLobeRightVolume  = [];
        paLungLowerLobeLeftVolume   = [];
        paLungMiddleLobeRightVolume = [];
        paLungUpperLobeRightVolume  = [];
        paLungUpperLobeLeftVolume   = [];

    else
        switch lower(sOrgan)

            case 'liver'

                aMask   = paLiverMask;
                aColor  = paLiverColor;
                dVolume = paLiverVolume;

            case 'lungs'

                aMask   = paLungsMask;
                aColor  = paLungsColor;
                dVolume = paLungsVolume;

            case 'lung_lower_lobe_right'

                aMask   = paLungLowerLobeRightMask ;
                aColor  = paLungLowerLobeRightColor;                
                dVolume = paLungLowerLobeRightVolume;

            case 'lung_lower_lobe_left'

                aMask   = paLungLowerLobeLeftMask;
                aColor  = paLungLowerLobeLeftColor;                
                dVolume = paLungLowerLobeLeftVolume;

            case 'lung_middle_lobe_right'

                aMask   = paLungMiddleLobeRightMask;
                aColor  = paLungMiddleLobeRightColor;
                dVolume = paLungMiddleLobeRightVolume;

            case 'lung_upper_lobe_right'

                aMask   = paLungUpperLobeRightMask;
                aColor  = paLungUpperLobeRightColor;
                dVolume = paLungUpperLobeRightVolume;

            case 'lung_upper_lobe_left'
                
                aMask   = paLungUpperLobeLeftMask;
                aColor  = paLungUpperLobeLeftColor;                     
                dVolume = paLungUpperLobeLeftVolume;
        end        
    end
   
end