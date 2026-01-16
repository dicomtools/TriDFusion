function [atRoi, atVoi, transM] = resampleROIs(dcmImage, atDcmMetaData, refImage, atRefMetaData, atRoi, bUpdateObject, atVoi, dSeriesOffset)
%function  [atRoi, atVoi, transM] = resampleROIs(dcmImage, atDcmMetaData, refImage, atRefMetaData, atRoi, bUpdateObject, atVoi, dSeriesOffset)
%Resample any ROIs.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Note: option settings must fit on one line and can contain one semicolon at most.
%Options can be strings, cell arrays of strings, or numerical arrays.
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

    transM = [];

    if isempty(atRoi)
        return;
    end

    aRefSize = size(refImage);  % [ny, nx, nz]

    % Prepare VOI ordering tags
    orderTags = {};
    for v = 1:numel(atVoi)
        orderTags = [orderTags, atVoi{v}.RoisTag]; %#ok<AGROW>
    end

    % Containers
    globalNewRois     = {};
    globalAllNewCells = {};
    globalRemovedTags = {};

    % ========================= VOI-BASED RESAMPLING =====================
    for v = 1:numel(atVoi)
        voi  = atVoi{v};
        tags = voi.RoisTag;

        if isempty(tags)
            continue;
        end

        % find indices in atRoi belonging to this VOI
        roiTagsAll = cellfun(@(r) r.Tag, atRoi, 'UniformOutput', false);
        roiIdxs    = find(ismember(roiTagsAll, tags));

        if isempty(roiIdxs)
            continue;
        end

        % sort by slice and split into contiguous blocks (per VOI)
        sliceNums = arrayfun(@(ii) atRoi{ii}.SliceNb, roiIdxs);
        [sortedSlices, sortOrder] = sort(sliceNums);
        sortedIdxs = roiIdxs(sortOrder);

        gaps        = [Inf; diff(sortedSlices(:))];
        blockStarts = find(gaps > 1);
        blockEnds   = [blockStarts(2:end)-1; numel(sortedIdxs)];

        for b = 1:numel(blockStarts)
            idxsBlock = sortedIdxs(blockStarts(b):blockEnds(b));

            localNew    = {};
            localCells  = {};
            removed     = {};
            destAxes    = {};
            destSlices  = [];
            origPerDest = [];

            % --------------------- down-sample ---------------------------
            for j = idxsBlock(:)'
                roi    = atRoi{j};
                origSl = roi.SliceNb;
                axe    = lower(roi.Axe);

                [aNewPos, aRad, aSemi, transM] = ...
                    computeRoiScaledPosition(refImage, ...
                                             atRefMetaData, ...
                                             dcmImage, ...
                                             atDcmMetaData, ...
                                             roi);

                switch lower(roi.Type)
                    case 'images.roi.circle'
                        newSlice = round(aNewPos(1,3));
                    case 'images.roi.ellipse'
                        newSlice = round(aNewPos(1,3));
                    case 'images.roi.rectangle'
                        newSlice = round(aNewPos(1,5));
                    otherwise
                        newSlice = round(aNewPos(1,3));
                end

                % bounds check per axe
                switch axe
                    case 'axes1', maxS = aRefSize(1);
                    case 'axes2', maxS = aRefSize(2);
                    otherwise,    maxS = aRefSize(3);
                end

                if newSlice < 1 || newSlice > maxS
                    removed{end+1} = roi.Tag; %#ok<AGROW>
                    continue;
                end

                % avoid collisions with different original slices
                cidx = find(strcmp(destAxes, axe) & destSlices == newSlice, 1);
                if isempty(cidx)
                    destAxes{end+1}   = axe;        %#ok<AGROW>
                    destSlices(end+1) = newSlice;   %#ok<AGROW>
                    origPerDest(end+1)= origSl;     %#ok<AGROW>
                elseif origPerDest(cidx) ~= origSl
                    removed{end+1} = roi.Tag; %#ok<AGROW>
                    continue;
                end

                % update geometry in pixel space
                switch lower(roi.Type)
                    case 'images.roi.circle'
                        roi.Position(:,1:2) = aNewPos(:,1:2);
                        roi.Radius          = aRad;

                    case 'images.roi.ellipse'
                        roi.Position(:,1:2) = aNewPos(:,1:2);
                        roi.SemiAxes        = aSemi;

                    case 'images.roi.rectangle'
                        roi.Position(1:4)   = aNewPos(1:4);

                    otherwise
                        roi.Position(:,1:2) = aNewPos(:,1:2);
                end

                roi.SliceNb = newSlice;

                % update graphic object
                if bUpdateObject && ~isstruct(roi.Object) && isvalid(roi.Object)
                    roi.Object.Position = roi.Position;
                    if isprop(roi.Object,'Radius')
                        roi.Object.Radius = roi.Radius;
                    end
                    if isprop(roi.Object,'SemiAxes')
                        roi.Object.SemiAxes = roi.SemiAxes;
                    end
                end

                localNew{end+1} = roi; %#ok<AGROW>
            end

            % --------------------- up-sample (fill gaps) -----------------
            for ax = unique(destAxes)
                idxs  = strcmp(destAxes, ax);
                dList = sort(destSlices(idxs));

                for m = dList(1):dList(end)
                    if any(dList == m)
                        continue;
                    end

                    prev  = dList(dList < m);
                    if isempty(prev)
                        refSl = dList(1);
                    else
                        refSl = max(prev);
                    end

                    for k = 1:numel(localNew)
                        if strcmpi(localNew{k}.Axe, ax) && localNew{k}.SliceNb == refSl

                            r0    = localNew{k};
                            rTemp = rmfield_if_exists(r0, 'Object');

                            rTemp.SliceNb = m;
                            rTemp.Tag     = num2str(generateUniqueNumber(false));

                            atVoi{v}.RoisTag{end+1} = rTemp.Tag;

                            if bUpdateObject
                                rTemp = addRoiFromTemplate(rTemp, dSeriesOffset);
                            end

                            localCells{end+1} = rTemp; %#ok<AGROW>
                        end
                    end
                end
            end

            globalNewRois     = [globalNewRois;     localNew(:)];    %#ok<AGROW>
            globalAllNewCells = [globalAllNewCells; localCells(:)];  %#ok<AGROW>
            globalRemovedTags = [globalRemovedTags; removed(:)];     %#ok<AGROW>
        end
    end

    % ================= STANDALONE ROIs (ObjectType == 'roi') ============
    for idx = 1:numel(atRoi)

        roi = atRoi{idx};

        if isfield(roi,'ObjectType') && strcmp(roi.ObjectType,'roi')

            [aNewPos, aRad, aSemi, transM] = ...
                computeRoiScaledPosition(refImage, ...
                                         atRefMetaData, ...
                                         dcmImage, ...
                                         atDcmMetaData, roi);

            switch lower(roi.Type)
                case 'images.roi.circle'
                    roi.Position(:,1:2) = aNewPos(:,1:2);
                    roi.Radius          = aRad;
                    roi.SliceNb         = round(aNewPos(1,3));

                case 'images.roi.ellipse'
                    roi.Position(:,1:2) = aNewPos(:,1:2);
                    roi.SemiAxes        = aSemi;
                    roi.SliceNb         = round(aNewPos(1,3));

                case 'images.roi.rectangle'
                    roi.Position(1:4)   = aNewPos(1:4);
                    roi.SliceNb         = round(aNewPos(1,5));

                otherwise
                    roi.Position(:,1:2) = aNewPos(:,1:2);
                    roi.SliceNb         = round(aNewPos(1,3));
            end

            if bUpdateObject && ~isstruct(roi.Object) && isvalid(roi.Object)

                roi.Object.Position = roi.Position;

                if isprop(roi.Object,'Radius')
                    roi.Object.Radius = roi.Radius;
                end

                if isprop(roi.Object,'SemiAxes')
                    roi.Object.SemiAxes = roi.SemiAxes;
                end
            end

            globalNewRois{end+1} = roi; %#ok<AGROW>
        end
    end

    % ===================== COMBINE AND FINALIZE =========================
    atRoi = [globalNewRois; globalAllNewCells];

    for v = 1:numel(atVoi)
        atVoi{v}.RoisTag = setdiff(atVoi{v}.RoisTag, globalRemovedTags, 'stable');
    end

    % preserve original VOI / ROI ordering as much as possible
    if ~isempty(orderTags)
        roiTags = cellfun(@(r) r.Tag, atRoi, 'UniformOutput', false);
        [~, ordIdx] = ismember(roiTags, orderTags);
        ordIdx(ordIdx == 0) = numel(orderTags) + 1;
        [~, sortIdx] = sortrows([(1:numel(ordIdx))', ordIdx(:)], [2 1]);
        atRoi = atRoi(sortIdx);
    end

    % ================= REBUILD VOI COR/SAG LINES (NEW PART) =============
    % Only if we are updating graphics, have VOIs, and a true 3-D volume.
    if bUpdateObject && ~isempty(atVoi) && numel(aRefSize) >= 3 && aRefSize(3) ~= 1 
        imSizeOverride = aRefSize;   % [ny nx nz]
        for v = 1:numel(atVoi)
            if isempty(atVoi{v})
                continue;
            end
            atVoi{v} = rebuildVoiMaskAndLines(atVoi{v}, atRoi, dSeriesOffset, imSizeOverride);
        end
    end
end

function s = rmfield_if_exists(s, field)
    if isfield(s, field)
        s = rmfield(s, field);
    end
end
