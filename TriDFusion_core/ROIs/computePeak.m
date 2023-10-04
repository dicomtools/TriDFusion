function dPeak = computePeak(imCData, dSUVScale)   
%function dPeak = computePeak(imCData, dSUVScale)   
%Compute peak from ROI\VOI object.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Note: option settings must fit on one line and can contain one semicolon at most.
%Options can be strings, cell arrays of strings, or numerical arrays.
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

    if exist('dSUVScale', 'var')

        % Initialization 

        ROIonlyPET = padarray(imCData * dSUVScale,[1 1 1],NaN);

        % SUVmax
        [~,indMax] = max(ROIonlyPET(:));  

        % SUVpeak (using 26 neighbors around SUVmax)
        [indMaxX,indMaxY,indMaxZ] = ind2sub(size(ROIonlyPET),indMax);
        connectivity = getneighbors(strel('arbitrary',conndef(3,'maximal')));
        nPeak = length(connectivity);
        neighborsMax = zeros(1,nPeak);

        for i=1:nPeak
            if connectivity(i,1)+indMaxX ~= 0 && ...
               connectivity(i,2)+indMaxY ~= 0 && ...
               connectivity(i,3)+indMaxZ ~= 0
                neighborsMax(i) = ROIonlyPET(connectivity(i,1)+indMaxX,connectivity(i,2)+indMaxY,connectivity(i,3)+indMaxZ);
            end
        end

        dPeak = mean(neighborsMax(~isnan(neighborsMax)));
    else
        % Initialization SUVpeak
        ROIonlyPET = padarray(imCData,[1 1 1],NaN);

        % max
        [~,indMax] = max(ROIonlyPET(:));         

        % peak (using 26 neighbors around SUVmax)
        [indMaxX,indMaxY,indMaxZ] = ind2sub(size(ROIonlyPET),indMax);
        connectivity = getneighbors(strel('arbitrary',conndef(3,'maximal')));
        nPeak = length(connectivity);
        neighborsMax = zeros(1,nPeak);

        for i=1:nPeak
           if connectivity(i,1)+indMaxX ~= 0 && ...
               connectivity(i,2)+indMaxY ~= 0 && ...
               connectivity(i,3)+indMaxZ ~= 0
                neighborsMax(i) = ROIonlyPET(connectivity(i,1)+indMaxX,connectivity(i,2)+indMaxY,connectivity(i,3)+indMaxZ);
           end
        end

        dPeak = mean(neighborsMax(~isnan(neighborsMax))); 
    end
end