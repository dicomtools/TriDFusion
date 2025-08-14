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

    aRefSize = size(refImage);  % [X, Y, Z]

    % Prepare VOI ordering tags
    orderTags = {};
    for v = 1:numel(atVoi)
        orderTags = [orderTags, atVoi{v}.RoisTag]; %#ok<AGROW>
    end

    % Containers
    globalNewRois     = {};
    globalAllNewCells = {};
    globalRemovedTags = {};

    % VOI-based resampling
    for v = 1:numel(atVoi)
        voi = atVoi{v};
        tags = voi.RoisTag;

        if isempty(tags)
            continue; 
        end

        % find indices in atRoi belonging to VOI
        roiTagsAll = cellfun(@(r) r.Tag, atRoi, 'UniformOutput', false);
        roiIdxs = find(ismember(roiTagsAll, tags));

        if isempty(roiIdxs)
            continue; 
        end

        % sort and block
        sliceNums = arrayfun(@(i) atRoi{i}.SliceNb, roiIdxs);
        [sortedSlices, sortOrder] = sort(sliceNums);
        sortedIdxs = roiIdxs(sortOrder);
        gaps = [Inf; diff(sortedSlices(:))];
        blockStarts = find(gaps>1);
        blockEnds = [blockStarts(2:end)-1; numel(sortedIdxs)];
        % process blocks
        for b = 1:numel(blockStarts)
            idxsBlock = sortedIdxs(blockStarts(b):blockEnds(b));
            localNew = {};
            localCells = {};
            removed = {};
            destAxes = {};
            destSlices = [];
            origPerDest = [];
            % down-sample
            for j = idxsBlock(:)'
                roi = atRoi{j};
                origSl = roi.SliceNb;
                axe = lower(roi.Axe);

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

                % bounds check
                switch axe
                    case 'axes1', maxS = aRefSize(2);
                    case 'axes2', maxS = aRefSize(1);
                    otherwise, maxS = aRefSize(3);
                end
                if newSlice<1 || newSlice>maxS
                    removed{end+1}=roi.Tag; 
                    continue;
                end
                % collision
                cidx = find(strcmp(destAxes,axe)&destSlices==newSlice,1);
                if isempty(cidx)
                    destAxes{end+1}=axe;
                    destSlices(end+1)=newSlice;
                    origPerDest(end+1)=origSl;
                elseif origPerDest(cidx)~=origSl
                    removed{end+1}=roi.Tag; 
                    continue;
                end

                % update geometry
                switch lower(roi.Type)
                    case 'images.roi.circle'
                        roi.Position(:,1:2)=aNewPos(:,1:2); 
                        roi.Radius=aRad;
                    case 'images.roi.ellipse'
                        roi.Position(:,1:2)=aNewPos(:,1:2); 
                        roi.SemiAxes=aSemi;
                    case 'images.roi.rectangle'
                        roi.Position(1:4)=aNewPos(1:4);
                    otherwise
                        roi.Position(:,1:2)=aNewPos(:,1:2);
                end
                roi.SliceNb = newSlice;

                % update graphic
                if bUpdateObject && ~isstruct(roi.Object) && isvalid(roi.Object)
                    roi.Object.Position=roi.Position;
                    if isprop(roi.Object,'Radius'), roi.Object.Radius=roi.Radius; end
                    if isprop(roi.Object,'SemiAxes'), roi.Object.SemiAxes=roi.SemiAxes; end
                end
                localNew{end+1}=roi;
            end
            % up-sample
            for ax=unique(destAxes)
                idxs=find(strcmp(destAxes,ax)); dList=sort(destSlices(idxs));
                for m=dList(1):dList(end)
                    if any(dList==m), continue; end
                    prev=dList(dList<m);
                    refSl=~isempty(prev)*max(prev)+isempty(prev)*dList(1);
                    for k=1:numel(localNew)
                        if strcmpi(localNew{k}.Axe,ax) && localNew{k}.SliceNb==refSl
                            r0=localNew{k}; rTemp=rmfield_if_exists(r0,'Object');
                            rTemp.SliceNb=m; rTemp.Tag=num2str(generateUniqueNumber(false));
                            atVoi{v}.RoisTag{end+1}=rTemp.Tag;
                            if bUpdateObject, rTemp=addRoiFromTemplate(rTemp,dSeriesOffset); end
                            localCells{end+1}=rTemp;
                        end
                    end
                end
            end
            globalNewRois=[globalNewRois;localNew(:)];
            globalAllNewCells=[globalAllNewCells;localCells(:)];
            globalRemovedTags=[globalRemovedTags;removed(:)];
        end
    end

    % Process standalone ROIs ('roi') once, retain them
    for idx=1:numel(atRoi)

        roi=atRoi{idx};

        if isfield(roi,'ObjectType') && strcmp(roi.ObjectType,'roi')

            [aNewPos,aRad,aSemi,transM] = ...
                computeRoiScaledPosition(refImage, ...
                                         atRefMetaData, ...
                                         dcmImage, ...
                                         atDcmMetaData,roi);
            % update geometry
            switch lower(roi.Type)
                case 'images.roi.circle'
                    roi.Position(:,1:2)=aNewPos(:,1:2); roi.Radius=aRad;
                    roi.SliceNb = round(aNewPos(1,3));
                case 'images.roi.ellipse'
                    roi.Position(:,1:2)=aNewPos(:,1:2); roi.SemiAxes=aSemi;
                    roi.SliceNb = round(aNewPos(1,3));
                 case 'images.roi.rectangle'
                    roi.Position(1:4)=aNewPos(1:4);
                    roi.SliceNb = round(aNewPos(1,5));
                otherwise
                    roi.Position(:,1:2)=aNewPos(:,1:2);
                    roi.SliceNb = round(aNewPos(1,3));
            end
            
            if bUpdateObject && ~isstruct(roi.Object) && isvalid(roi.Object)

                roi.Object.Position=roi.Position;

                if isprop(roi.Object,'Radius') 
                    roi.Object.Radius=roi.Radius; 
                end

                if isprop(roi.Object,'SemiAxes')
                    roi.Object.SemiAxes=roi.SemiAxes; 
                end
            end

            globalNewRois{end+1}=roi;
        end
    end

    % Combine and finalize
    atRoi=[globalNewRois;globalAllNewCells];
    for v=1:numel(atVoi)
        atVoi{v}.RoisTag=setdiff(atVoi{v}.RoisTag,globalRemovedTags,'stable');
    end
    if ~isempty(orderTags)
        roiTags=cellfun(@(r)r.Tag,atRoi,'UniformOutput',false);
        [~,ordIdx]=ismember(roiTags,orderTags);
        ordIdx(ordIdx==0)=numel(orderTags)+1;
        [~,sortIdx]=sortrows([(1:numel(ordIdx))',ordIdx(:)],[2 1]);
        atRoi=atRoi(sortIdx);
    end
end

function s=rmfield_if_exists(s,field)

    if isfield(s,field)
        s=rmfield(s,field); 
    end
end
