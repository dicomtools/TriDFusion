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
     if contains(lower(atDicomInfo{1}.SeriesType), 'static') 
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
                if atDicomInfo{jj}.Rows    == atDicomInfo{jj+1}.Rows && ...
                   atDicomInfo{jj}.Columns == atDicomInfo{jj+1}.Columns     
                    dNbSlices = dNbSlices+1;
                    continue;
                end
            end

%            dSliceSpacing = spacingBetweenTwoSlices(atDicomInfo{jj},atDicomInfo{jj+1});
            dSliceSpacing = atDicomInfo{jj}.SpacingBetweenSlices;
            if dSliceSpacing == 0
                dSliceSpacing = spacingBetweenTwoSlices(atDicomInfo{jj},atDicomInfo{jj+1});
            end

            dComputedNextSliceLocation = str2double(sprintf('%.3f', abs(atDicomInfo{jj}.SliceLocation) + abs(dSliceSpacing)));
            dNextSliceLocation         = str2double(sprintf('%.3f', abs(atDicomInfo{jj+1}.SliceLocation)));
                    
            if dComputedNextSliceLocation>dNextSliceLocation % Patch for resul seies
                dSliceRatio = dComputedNextSliceLocation/dNextSliceLocation;
            else
                dSliceRatio = dNextSliceLocation/dComputedNextSliceLocation;
            end
         
            if dSliceRatio > 0.9 % Within 10% of the computed next slice
                dInconsistentSpacing = false;
            else
                dInconsistentSpacing = true;
            end

            if dInconsistentSpacing == true                         || ... % Inconsistent spacing 
               atDicomInfo{jj}.Rows       ~= atDicomInfo{jj+1}.Rows || ... % Inconsistent size
               atDicomInfo{jj}.Columns    ~= atDicomInfo{jj+1}.Columns  

                dComputedNextSliceLocation = str2double(sprintf('%.3f', atDicomInfo{jj}.SliceLocation - dSliceSpacing));

                if dComputedNextSliceLocation ~= dNextSliceLocation      || ...
                   atDicomInfo{jj}.Rows       ~= atDicomInfo{jj+1}.Rows  || ... % Inconsistent size
                   atDicomInfo{jj}.Columns    ~= atDicomInfo{jj+1}.Columns  

                    tGate{dNbGate}.GateNumber = dNbGate;
                    tGate{dNbGate}.NbSlices   = dNbSlices;       
                    tGate{dNbGate}.SeriesInstanceUID = atDicomInfo{jj}.SeriesInstanceUID;       

                    dNbGate = dNbGate+1;
                    dNbSlices = 0;                
                end
            else
                if ~strcmp(atDicomInfo{jj}.FrameOfReferenceUID, atDicomInfo{jj+1}.FrameOfReferenceUID) % Different series

                    if dInconsistentSpacing == true
                        tGate{dNbGate}.GateNumber = dNbGate;
                        tGate{dNbGate}.NbSlices   = dNbSlices;       
                        tGate{dNbGate}.SeriesInstanceUID = atDicomInfo{jj}.SeriesInstanceUID;       
    
                        dNbGate = dNbGate+1;
                        dNbSlices = 0;                
                    end
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