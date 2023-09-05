function actGate = dicomInfoComputeFrames(atDicomInfo)
%function actGate = dicomInfoComputeFrames(atDicomInfo)
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

    actGate = [];
     
   
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

%             if ~strcmpi(atDicomInfo{jj}.ContentTime,  atDicomInfo{jj+1}.ContentTime)
%             end

            if atDicomInfo{jj}.SliceLocation == 0 && ...
               atDicomInfo{jj+1}.SliceLocation == 0   
                if atDicomInfo{jj}.Rows    == atDicomInfo{jj+1}.Rows && ...
                   atDicomInfo{jj}.Columns == atDicomInfo{jj+1}.Columns     
                    dNbSlices = dNbSlices+1;
                    continue;
                end
            end

             dSliceSpacing = spacingBetweenTwoSlices(atDicomInfo{jj},atDicomInfo{jj+1});
             if dSliceSpacing == 0
                 dSliceSpacing = atDicomInfo{jj}.SpacingBetweenSlices;
                 if dSliceSpacing == 0
                     dSliceSpacing =1;
                 end
             end

            dComputedNextSliceLocation = atDicomInfo{jj}.SliceLocation + dSliceSpacing;
            dNextSliceLocation         = atDicomInfo{jj+1}.SliceLocation;
                    
            if dComputedNextSliceLocation>dNextSliceLocation % For GE result seies
                dSliceRatio = dComputedNextSliceLocation/dNextSliceLocation;
            else
                dSliceRatio = dNextSliceLocation/dComputedNextSliceLocation;
            end
         
            if dSliceRatio > 0.9 && dSliceRatio < 1.1 % Within 10% of the computed next slice
                
                dInconsistentSpacing = false;                
            else
                dComputedNextSliceLocation = atDicomInfo{jj}.SliceLocation - dSliceSpacing;
                dNextSliceLocation         = atDicomInfo{jj+1}.SliceLocation;

                if dComputedNextSliceLocation>dNextSliceLocation % For GE result seies
                    dSliceRatio = dComputedNextSliceLocation/dNextSliceLocation;
                else
                    dSliceRatio = dNextSliceLocation/dComputedNextSliceLocation;
                end
             
                if dSliceRatio > 0.9 && dSliceRatio < 1.1 % Within 10% of the computed next slice
                    dInconsistentSpacing = false;
                else
                    dInconsistentSpacing = true;
                end
            end

            if atDicomInfo{jj}.SpacingBetweenSlices ~= 0
                if abs(dSliceSpacing) > (2*abs(atDicomInfo{jj}.SpacingBetweenSlices)) % The computed spacing is too far
                    dInconsistentSpacing = true;
                end
            end

            if dInconsistentSpacing == true                         || ... % Inconsistent spacing 
               atDicomInfo{jj}.Rows       ~= atDicomInfo{jj+1}.Rows || ... % Inconsistent size
               atDicomInfo{jj}.Columns    ~= atDicomInfo{jj+1}.Columns  

                dComputedNextSliceLocation = atDicomInfo{jj}.SliceLocation + dSliceSpacing;

                if dComputedNextSliceLocation ~= dNextSliceLocation      || ...
                   atDicomInfo{jj}.Rows       ~= atDicomInfo{jj+1}.Rows  || ... % Inconsistent size
                   atDicomInfo{jj}.Columns    ~= atDicomInfo{jj+1}.Columns  

                    actGate{dNbGate}.GateNumber = dNbGate;
                    actGate{dNbGate}.NbSlices   = dNbSlices;       
                    actGate{dNbGate}.SeriesInstanceUID = atDicomInfo{jj}.SeriesInstanceUID;       

                    dNbGate = dNbGate+1;
                    dNbSlices = 0;                
                end
            else
                if ~strcmp(atDicomInfo{jj}.FrameOfReferenceUID, atDicomInfo{jj+1}.FrameOfReferenceUID) % Different series

                    if dInconsistentSpacing == true
                        actGate{dNbGate}.GateNumber = dNbGate;
                        actGate{dNbGate}.NbSlices   = dNbSlices;       
                        actGate{dNbGate}.SeriesInstanceUID = atDicomInfo{jj}.SeriesInstanceUID;       
    
                        dNbGate = dNbGate+1;
                        dNbSlices = 0;                
                    end
                end            
            end
            
   %         dLastSpacing = dSliceSpacing;
            dNbSlices = dNbSlices+1;

        end

        if dNbGate ~= 1 % last frame
            
            actGate{dNbGate}.GateNumber = dNbGate;
            actGate{dNbGate}.NbSlices   = dNbSlices;       
            actGate{dNbGate}.SeriesInstanceUID = atDicomInfo{jj}.SeriesInstanceUID; 
        end

    end                
end  