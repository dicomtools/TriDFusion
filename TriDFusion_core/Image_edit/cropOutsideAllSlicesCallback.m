function cropOutsideAllSlicesCallback(hObject,~)
%function cropOutsideAllSlicesCallback(hObject,~)
%Crop Outside All Slices.
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

    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');
    im = dicomBuffer('get', [], dSeriesOffset);
    if isempty(im), return; end

    % Exit if not in simple 2D mode
    if switchTo3DMode('get')     || ...
       switchToIsoSurface('get') || ...
       switchToMIPMode('get')
        return;
    end

    % Get axes 
    pAxe = getAxeFromMousePosition(dSeriesOffset);
    if isempty(pAxe), return; end

    try
        % Busy cursor
        fw = fiMainWindowPtr('get');
        set(fw, 'Pointer', 'watch'); drawnow;

        % Prep sizes and crop value
        [nx, ny, nz] = size(im);
        cropVal      = cropValue('get');

        % Grab the three 2D‐view pointers once
        ax1 = axes1Ptr('get', [], dSeriesOffset);
        ax2 = axes2Ptr('get', [], dSeriesOffset);
        ax3 = axes3Ptr('get', [], dSeriesOffset);

        if nz == 1
            % 2D slice (XY) —
            mask2d = createMask(hObject.UserData, im(:,:));
            im(~mask2d) = cropVal;

        elseif ~isempty(ax1) && pAxe == ax1
            % Coronal (YZ) view 
            slice2d = permute(im(1,:,:), [3 2 1]);          % [nz × ny]
            mask2d  = createMask(hObject.UserData, slice2d);
            mask3d  = permute(repmat(mask2d, [1,1,nx]), [3 2 1]);
            im(~mask3d) = cropVal;

        elseif ~isempty(ax2) && pAxe == ax2
            % Sagittal (XZ) view
            slice2d = permute(im(:,1,:), [3 1 2]);          % [nz × nx]
            mask2d  = createMask(hObject.UserData, slice2d);
            mask3d  = permute(repmat(mask2d, [1,1,ny]), [2 3 1]);
            im(~mask3d) = cropVal;

        elseif ~isempty(ax3) && pAxe == ax3
            % Axial (XY) view
            mask2d = createMask(hObject.UserData, im(:,:,1)); 
            mask3d = repmat(mask2d, [1,1,nz]);
            im(~mask3d) = cropVal;
        end

        progressBar(1, 'Ready');

        modifiedMatrixValueMenuOption('set', true);

        dicomBuffer('set', im, dSeriesOffset);

        setQuantification(dSeriesOffset);

        refreshImages();

        if nz ~= 1
            mipBuffer('set', computeMIP(gather(im)), dSeriesOffset);
    
            sliderMipCallback();
        end

        clear im;

    catch ME
        logErrorToFile(ME);
        progressBar(1, 'Error:cropOutsideAllSlicesCallback()');
    end

    % Restore pointer
    set(fw, 'Pointer', 'default');
    drawnow;
end                        
