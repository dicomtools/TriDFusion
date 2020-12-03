function aImage = readDcm4che3(fileInput, din)
%function aImage = readDcm4che3(fileInput, din)
%Return the dicom buffer.
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

%        try 
%            din = org.dcm4che.io.DicomInputStream(...
%                    java.io.BufferedInputStream(java.io.FileInputStream(char(fileInput))));    
%        catch 
%           aImage = ''; 
%           return;
%        end  

%        dataset = din.readDataset(-1, -1);
%        pixeldata = dataset.getInts(org.dcm4che.data.Tag.PixelData);

%        rows = dataset.getInt(org.dcm4che.data.Tag.Rows, 0);
%        cols = dataset.getInt(org.dcm4che.data.Tag.Columns,0);

if 0
    pixeldata = din.pixeldata;

    rows = din.rows;
    cols = din.cols;
%        frames = din.nbOfFrames;

    try
        aImg = reshape(pixeldata, cols, rows);

        aAlignImage = zeros(rows, cols);
        for i =1 :rows-1
            for j=1 :cols-1
                aAlignImage(i, j)= aImg(cols-j,i);
            end
        end

        aImage = aAlignImage(1:rows,cols:-1:1);
   catch
        aImage = dicomread(char(fileInput));
    end
else
    aImage = dicomread(char(fileInput));
end

end