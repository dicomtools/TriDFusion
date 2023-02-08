function tGate = dicomInfoComputeFrames(atDicomInfo)
%function tGate = dicomInfoComputeFrames(atDicomInfo)
%Split the 4D dicom images.
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

    tGate = [];
     
   
%    if strcmpi(atDicomInfo{1}.Modality, 'MR') || ...
%       strcmpi(atDicomInfo{1}.Modality, 'PT') && ...
     if strcmpi(atDicomInfo{1}.SeriesType{1}, 'STATIC') 
         return;
     end
          
     if numel(atDicomInfo) > 2
                 
        dNbGate   =1;
        dNbSlices =1;

     %   dFirstSpacing = spacingBetweenTwoSlices(atDicomInfo{1}, atDicomInfo{2});
     %   dLastSpacing  = dFirstSpacing;

        for jj=1:numel(atDicomInfo)-1

            if atDicomInfo{jj}.SliceLocation == 0 && ...
               atDicomInfo{jj+1}.SliceLocation == 0     
                continue;
            end

%            dSliceSpacing = spacingBetweenTwoSlices(atDicomInfo{jj},atDicomInfo{jj+1});
            dSliceSpacing = atDicomInfo{jj}.SpacingBetweenSlices;
            if dSliceSpacing == 0
                dSliceSpacing = spacingBetweenTwoSlices(atDicomInfo{jj},atDicomInfo{jj+1});
            end

            dComputedNextSliceLocation = str2double(sprintf('%.3f', atDicomInfo{jj}.SliceLocation + dSliceSpacing));
            dNextSliceLocation         = str2double(sprintf('%.3f', atDicomInfo{jj+1}.SliceLocation));
                    
            if dComputedNextSliceLocation ~= dNextSliceLocation % Inconsistent spacing 
                
                dComputedNextSliceLocation = str2double(sprintf('%.3f', atDicomInfo{jj}.SliceLocation - dSliceSpacing));

                if dComputedNextSliceLocation ~= dNextSliceLocation
                    
                    tGate{dNbGate}.GateNumber = dNbGate;
                    tGate{dNbGate}.NbSlices   = dNbSlices;       
                    tGate{dNbGate}.SeriesInstanceUID = atDicomInfo{jj}.SeriesInstanceUID;       

                    dNbGate = dNbGate+1;
                    dNbSlices = 0;                
                end
            else
                if ~strcmp(atDicomInfo{jj}.FrameOfReferenceUID, atDicomInfo{jj+1}.FrameOfReferenceUID) % Different series

                    tGate{dNbGate}.GateNumber = dNbGate;
                    tGate{dNbGate}.NbSlices   = dNbSlices;       
                    tGate{dNbGate}.SeriesInstanceUID = atDicomInfo{jj}.SeriesInstanceUID;       

                    dNbGate = dNbGate+1;
                    dNbSlices = 0;                

                end            
            end
            
   %         dLastSpacing = dSliceSpacing;
            dNbSlices = dNbSlices+1;

        end

        if dNbGate ~= 1 % last frame
            
            tGate{dNbGate}.GateNumber = dNbGate;
            tGate{dNbGate}.NbSlices   = dNbSlices;       
            tGate{dNbGate}.SeriesInstanceUID = atDicomInfo{jj}.SeriesInstanceUID; 
        end

    end                
end  