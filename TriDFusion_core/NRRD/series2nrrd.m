function series2nrrd(dSeriesOffset, sNrrdImagesName, dConvFactor)
%function series2nrrd(dSeriesOffset, sNrrdImagesName, dConvFactor)
%Export series to .nrrd file type.
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
% TriDFusion development has been led by: Daniel Lafontaine
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

    atMetaData  = dicomMetaData('get', [], dSeriesOffset);
    if isempty(atMetaData)
        atInput = inputTemplate('get');
        atMetaData = atInput(dSeriesOffset).atDicomInfo;
    end        

    origin = atMetaData{end}.ImagePositionPatient;
    
    pixelspacing = zeros(3,1);

    pixelspacing(1) = atMetaData{1}.PixelSpacing(1);
    pixelspacing(2) = atMetaData{1}.PixelSpacing(2);
    pixelspacing(3) = computeSliceSpacing(atMetaData);

%     if ~isempty(atMetaData{1}.SliceThickness)
%         if atMetaData{1}.SliceThickness ~= 0
%             pixelspacing(3) = atMetaData{1}.SliceThickness;
%         else
%             pixelspacing(3) = computeSliceSpacing(atMetaData);
%         end           
%     else    
%         pixelspacing(3) = computeSliceSpacing(atMetaData);
%     end

%     sNrrdImagesName = sprintf('%s%s.nrrd', sOutDir, cleanString(atMetaData{1}.SeriesDescription));

    aBuffer = dicomBuffer('get', [], dSeriesOffset);
    if isempty(aBuffer)
        aInputBuffer = inputBuffer('get');
        aBuffer = aInputBuffer{dSeriesOffset};
        clear aInputBuffer;
    end


    if size(aBuffer, 3) ~=1       

        aBuffer = aBuffer(:,:,end:-1:1);
    end
    
    aBuffer = aBuffer * dConvFactor;
    
    nrrdWriter(sNrrdImagesName, squeeze(aBuffer), pixelspacing, origin, 'raw'); % Write .nrrd images 
end