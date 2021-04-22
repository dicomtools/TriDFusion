function writeISOtoSTL(sStlFileName)
%function exportISOtoSTLCallback(~, ~)
%Write 3D ISO surface to .stl Model.
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

    isoObj = isoObject('get');
    if ~isempty(isoObj)

        try
                      
        set(fiMainWindowPtr('get'), 'Pointer', 'watch');
        drawnow;  
    
        progressBar(0.999999, 'Processing write stl, please wait');

        aSurfaceColor = surfaceColor('all');
        dColorOffset = isoColorOffset('get');

        im = dicomBuffer('get');
        im = im(:,:,end:-1:1);

        atDcmMetaData = dicomMetaData('get');

        dMin = min(im, [], 'all');
        dMax = max(im, [], 'all');
        dScale = abs(dMin)+abs(dMax);

        dOffset = dScale*isoObj.Isovalue;
        dIsoValue = dMin+dOffset;

        dcmSliceThickness = computeSliceSpacing(atDcmMetaData);

        dimsRef = size(im);
        dimsDcm = size(im);
        dimsRef(1) =  dimsRef(1)*volumeScaleFator('get', 'x');
        dimsRef(2) =  dimsRef(2)*volumeScaleFator('get', 'y');
        dimsRef(3) =  dimsRef(3)*volumeScaleFator('get', 'z');

        f = diag([dimsRef(:) ./ dimsDcm(:);1]);

        TF = affine3d(f);

        Rdcm  = imref3d(size(im),atDcmMetaData{1}.PixelSpacing(2),atDcmMetaData{1}.PixelSpacing(1),dcmSliceThickness);

        sMode = 'linear';
        [resampImage, ~] = imwarp(im, Rdcm, TF, 'Interp', sMode, 'FillValues', cropValue('get'));

        fv = isosurface(resampImage, dIsoValue, aSurfaceColor{dColorOffset}); % Make patch w. faces "out"

        cVals = fv.vertices(fv.faces(:,1),3); % Colour by Z height.
        cLims = [min(cVals) max(cVals)];      % Transform height values

        nCols = 255;
        %cMap = jet(nCols);        % onto an 8-bit colour map
        aIsoCol = isoObj.IsosurfaceColor;
        cMap = zeros(nCols, 3);
        cMap(:,1) = aIsoCol(1)*255;
        cMap(:,2) = aIsoCol(2)*255;
        cMap(:,3) = aIsoCol(3)*255;

        fColsDbl = interp1(linspace(cLims(1), cLims(2), nCols), cMap, cVals);
        fCols8bit = fColsDbl*255; % Pass cols in 8bit (0-255) RGB triplets

        stlwrite(sStlFileName, fv, 'FaceColor', fCols8bit);

        progressBar(1, sprintf('Write %s completed', sStlFileName));
        
        catch
            progressBar(1, 'Error:writeISOtoSTL()');                
        end

        set(fiMainWindowPtr('get'), 'Pointer', 'default');
        drawnow; 
    
    else
        progressBar(1, 'Error: Please initiate the iso surface!');
        h = msgbox('Error: writeISOtoSTL(): Please initiate the iso surface!', 'Error');
%        if integrateToBrowser('get') == true
%            sLogo = './TriDFusion/logo.png';
%        else
%            sLogo = './logo.png';
%        end

%        javaFrame = get(h, 'JavaFrame');
%        javaFrame.setFigureIcon(javax.swing.ImageIcon(sLogo));                
    end
end
