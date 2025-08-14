function maskContourFromMenuCallback(hObject, ~)
%function maskContourFromMenuCallback(hObject, ~)
%Mask a ROI or VOI, the function is called from a menu.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2022, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    try

    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

    imBuffer      = dicomBuffer('get', [], dSeriesOffset);
    if isempty(imBuffer)
        return; 
    end

    sMaskType = get(hObject, 'Label');
    sMaskTag  = get(hObject, 'UserData');

    atRoiTemplate = roiTemplate('get', dSeriesOffset);
    if ~iscell(atRoiTemplate)
        atRoiTemplate = {}; 
    end

    atVoiTemplate = voiTemplate('get', dSeriesOffset);
    if ~iscell(atVoiTemplate)
        atVoiTemplate = {}; 
    end

    if isempty(atRoiTemplate)
        return; 
    end  

    volSize   = size(imBuffer);         % [nx, ny, nz]
    imMask    = false(volSize);
    cropVal   = cropValue('get');
    isInside  = startsWith(sMaskType,'Inside','IgnoreCase',true);
    repeatAll = contains(sMaskType,'Every','IgnoreCase',true);

    % Find matching VOI index (if any)
    dVoi = [];
    if ~isempty(atVoiTemplate)
        voiTags = cellfun(@(v)v.Tag, atVoiTemplate, 'UniformOutput', false);
        dVoi    = find(strcmp(voiTags, sMaskTag), 1);
    end

    % Find matching ROI index (if no VOI) 

    roiTags = cellfun(@(r)r.Tag, atRoiTemplate, 'UniformOutput', false);
    dRoi    = find(strcmp(roiTags, sMaskTag), 1);

    % Build the full-volume mask 
    if ~isempty(dVoi)
        % OR together each ROI inside the VOI
        roiList = atVoiTemplate{dVoi}.RoisTag;
        for k = 1:numel(roiList)
            % find ROI index by tag
            idx = find(strcmp(roiTags, roiList{k}),1);
            if isempty(idx)
                continue; 
            end
            imMask = imMask | buildMask(atRoiTemplate{idx}, imBuffer, volSize, repeatAll);
        end

    elseif ~isempty(dRoi)
        % single ROI
        imMask = buildMask(atRoiTemplate{dRoi}, imBuffer, volSize, repeatAll);

    else
        return;  % no match
    end

    % Apply the mask if any voxel selected 

    if any(imMask(:))

        if isInside
            imBuffer(imMask) = cropVal;
        else
            imBuffer(~imMask) = cropVal;
        end

        modifiedMatrixValueMenuOption('set', true);

        dicomBuffer('set', imBuffer, dSeriesOffset);

        setQuantification(dSeriesOffset);

        refreshImages();

        if size(imBuffer,3) ~= 1
            
            mipBuffer('set', computeMIP(gather(imBuffer)), dSeriesOffset);
    
            sliderMipCallback();
        end

    end
    
    clear imBuffer;

    catch ME
        logErrorToFile(ME);
        progressBar(1, 'Error:maskContourFromMenuCallback()');
    end
  
end

%------------------------------------------------------------------------
function maskImage = buildMask(tpl, imBuf, volSize, repeatAll)
% Returns one [X×Y×Z] logical mask for tpl (.SliceNb & .Axe),
% repeated on every slice if repeatAll==true.

    [nx,ny,nz] = size(imBuf);
    ax         = lower(tpl.Axe);
    sn         = tpl.SliceNb;
    maskImage  = false(volSize);

    switch ax
        case 'axe'    % 2D plane 
            m2d = roiTemplateToMask(tpl.Object, imBuf(:,:));
            if repeatAll
                maskImage = repmat(m2d, [1,1]);
            else
                maskImage(:,:) = m2d;
            end

        case 'axes1'  % Coronal
            slice2d = permute(imBuf(sn,:,:), [3 2 1]);          % [X×Z]
            m2d     = roiTemplateToMask(tpl, slice2d);
            m3slice = permute(m2d, [3 2 1]);            % [X×1×Z]
            if repeatAll
                maskImage = repmat(m3slice, [nx 1 1]);
            else
                maskImage(sn,:,:) = m3slice;
            end

        case 'axes2'  % Sagittal
            slice2d = permute(imBuf(:,sn,:), [3 1 2]);          % [X×Z]
            m2d     = roiTemplateToMask(tpl, slice2d);
            m3slice = permute(m2d, [2 3 1]);            % [X×1×Z]
            if repeatAll
                maskImage = repmat(m3slice, [1 ny 1]);
            else
                maskImage(:,sn,:) = m3slice;
            end     

        case 'axes3'  % Axial
            m2d = roiTemplateToMask(tpl, imBuf(:,:,sn));
            if repeatAll
                maskImage = repmat(m2d, [1,1,nz]);
            else
                maskImage(:,:,sn) = m2d;
            end

        otherwise
            % leave maskImage all false
    end
end