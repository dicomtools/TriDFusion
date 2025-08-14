function exportContoursReport(bSUVUnit, bSegmented, bModifiedMatrix, bExpendVoi, sFileName, bOpenExcel)
%function exportContoursReport(bSUVUnit, bSegmented, bModifiedMatrix, bExpendVoi, sFileName, bOpenExcel)
%Generate a simplified Contours Report.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2024, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    atInput = inputTemplate('get');

    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

    try
        matlab.io.internal.getExcelInstance;
        bExcelInstance = true;
    catch exception
        logErrorToFile(exception);
%            warning(message('MATLAB:xlswrite:NoCOMServer'));
        bExcelInstance = false;
    end

    if exist('bOpenExcel', 'var')

        if bOpenExcel == false

            bExcelInstance = false;
        end
    end
        
    atMetaData = dicomMetaData('get', [], get(uiSeriesPtr('get'), 'Value'));

    atVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
    atRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

    if bExpendVoi == true

        bExpendedDisplay = true;
    else
        bExpendedDisplay = false;

        if ~isempty(atRoiInput)

            if any(cellfun(@(roi) strcmpi(roi.ObjectType, 'roi'), atRoiInput))

                bExpendedDisplay = true;
            end
        end
    end

    aDisplayBuffer = dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value'));

    aInput = inputBuffer('get');

    if     strcmpi(imageOrientation('get'), 'axial')
        aInputBuffer = permute(aInput{dSeriesOffset}, [1 2 3]);
    elseif strcmpi(imageOrientation('get'), 'coronal')
        aInputBuffer = permute(aInput{dSeriesOffset}, [3 2 1]);
    elseif strcmpi(imageOrientation('get'), 'sagittal')
        aInputBuffer = permute(aInput{dSeriesOffset}, [3 1 2]);
    end

    if size(aDisplayBuffer, 3) ==1

        if atInput(dSeriesOffset).bFlipLeftRight == true
            aInputBuffer = aInputBuffer(:,end:-1:1);
        end

        if atInput(dSeriesOffset).bFlipAntPost == true
            aInputBuffer = aInputBuffer(end:-1:1,:);
        end
    else
        if atInput(dSeriesOffset).bFlipLeftRight == true
            aInputBuffer = aInputBuffer(:,end:-1:1,:);
        end

        if atInput(dSeriesOffset).bFlipAntPost == true
            aInputBuffer = aInputBuffer(end:-1:1,:,:);
        end

        if atInput(dSeriesOffset).bFlipHeadFeet == true
            aInputBuffer = aInputBuffer(:,:,end:-1:1);
        end
    end

    atInputMetaData = atInput(dSeriesOffset).atDicomInfo;

    bMovementApplied = atInput(dSeriesOffset).tMovement.bMovementApplied;

    if ~isempty(atRoiInput) || ...
       ~isempty(atVoiInput)

        transM = eye(3);

        if bModifiedMatrix  == false && ... 
           bSegmented       == false && ...
           bMovementApplied == false

            if numel(aInputBuffer) ~= ...
               numel(aDisplayBuffer)
                
                [atRoiInput, atVoiInput, transM] = resampleROIs(aDisplayBuffer, atMetaData, aInputBuffer, atInputMetaData, atRoiInput, false, atVoiInput, dSeriesOffset);
            end
        end

        filter = {'*.csv'};
 %       info = dicomMetaData('get', [], get(uiSeriesPtr('get'), 'Value'));

        sCurrentDir  = viewerRootPath('get');

        sMatFile = [sCurrentDir '/' 'lastRoiDir.mat'];
        % load last data directory
        if exist(sMatFile, 'file')
                        % lastDirMat mat file exists, load it
            load('-mat', sMatFile);
            if exist('saveRoiLastUsedDir', 'var')
               sCurrentDir = saveRoiLastUsedDir;
            end
            if sCurrentDir == 0
                sCurrentDir = pwd;
            end
        end

%            sDate = sprintf('%s', datetime('now','Format','MMMM-d-y-hhmmss'));

        sSeriesDate = atMetaData{1}.SeriesDate;

        if isempty(sSeriesDate)
            sSeriesDate = '-';
        else
            sSeriesDate = datetime(sSeriesDate,'InputFormat','yyyyMMdd');
        end

        if exist('sFileName', 'var')

            [path, file, ext] = fileparts(sFileName);
            file = sprintf('%s%s', file, ext);
            path = sprintf('%s/', path);

        else
            [file, path] = uiputfile(filter, 'Save ROI/VOI result', sprintf('%s/%s_%s_%s_%s_CONTOURS_TriDFusion.csv' , ...
                sCurrentDir, cleanString(atMetaData{1}.PatientName), cleanString(atMetaData{1}.PatientID), cleanString(atMetaData{1}.SeriesDescription), sSeriesDate) );
        end

        if file ~= 0

%                 try
%
%                 set(figRoiWindow, 'Pointer', 'watch');
%                 drawnow;

            try
                saveRoiLastUsedDir = [path '/'];
                save(sMatFile, 'saveRoiLastUsedDir');
            catch ME
                logErrorToFile(ME);
                progressBar(1 , sprintf('Warning: Cant save file %s', sMatFile));
%                    h = msgbox(sprintf('Warning: Cant save file %s', sMatFile), 'Warning');
%                    if integrateToBrowser('get') == true
%                        sLogo = './TriDFusion/logo.png';
%                    else
%                        sLogo = './logo.png';
%                    end

%                    javaFrame = get(h, 'JavaFrame');
%                    javaFrame.setFigureIcon(javax.swing.ImageIcon(sLogo));
            end

            if exist(sprintf('%s%s', path, file), 'file')

                delete(sprintf('%s%s', path, file));
            end

            tRoiQuant = quantificationTemplate('get');

            if isfield(tRoiQuant, 'tSUV')
                dSUVScale = tRoiQuant.tSUV.dScale;
            else
                dSUVScale = 1;
            end

            % Count number of elements

            dNumberOfLines = 1;
            if ~isempty(atVoiInput) % Scan VOI

                for aa=1:numel(atVoiInput)

                    if ~isempty(atVoiInput{aa}.RoisTag) % Found a VOI

                        dNumberOfLines = dNumberOfLines+1;

                        for cc=1:numel(atVoiInput{aa}.RoisTag)

                            for bb=1:numel(atRoiInput)

                                % if isstruct(atRoiInput{bb}) && isfield(atRoiInput{bb}, 'Object') && isvalid(atRoiInput{bb}.Object)

                                    if strcmpi(atVoiInput{aa}.RoisTag{cc}, atRoiInput{bb}.Tag) % Found a VOI/ROI

                                        dNumberOfLines = dNumberOfLines+1;

                                    end
                                % end
                            end
                        end
                    end
                end
            end

            for bb=1:numel(atRoiInput) % Scan ROI

                % if isstruct(atRoiInput{bb}) && isfield(atRoiInput{bb}, 'Object') && isvalid(atRoiInput{bb}.Object)

                    if strcmpi(atRoiInput{bb}.ObjectType, 'roi') % Found a ROI

                        dNumberOfLines = dNumberOfLines+1;
                    end
                % end
            end

            bDoseKernel = atInput(dSeriesOffset).bDoseKernel;

            if bDoseKernel == true

                if isfield(atMetaData{1}, 'DoseUnits')

                    if ~isempty(atMetaData{1}.DoseUnits)

                        sUnits = char(atMetaData{1}.DoseUnits);
                    else
                        sUnits = 'dose';
                    end
                else
                    sUnits = 'dose';
                end

            else

                if bSUVUnit == true

                    if (strcmpi(atMetaData{1}.Modality, 'pt') || ...
                        strcmpi(atMetaData{1}.Modality, 'nm'))&& ...
                        strcmpi(atMetaData{1}.Units, 'BQML' )

                        sSUVtype = viewerSUVtype('get');
                        sUnits   = sprintf('SUV/%s', sSUVtype);
                    else

                        if (strcmpi(atMetaData{1}.Modality, 'ct'))
                           sUnits = 'HU';
                        else
                           sUnits = 'Counts';
                        end
                    end
                else
                     if (strcmpi(atMetaData{1}.Modality, 'ct'))
                        sUnits = 'HU';
                     else
                        if (strcmpi(atMetaData{1}.Modality, 'pt') || ...
                            strcmpi(atMetaData{1}.Modality, 'nm'))&& ...
                            strcmpi(atMetaData{1}.Units, 'BQML' )
                            sUnits = 'BQML';
                        else
                            sUnits = 'Counts';
                        end
                    end
                end
            end

            asVoiRoiHeader{1} = sprintf('Patient Name, %s'      , cleanString(atMetaData{1}.PatientName, '_'));
            asVoiRoiHeader{2} = sprintf('Patient ID, %s'        , atMetaData{1}.PatientID);
            asVoiRoiHeader{3} = sprintf('Series Description, %s', cleanString(atMetaData{1}.SeriesDescription, '_'));
            asVoiRoiHeader{4} = sprintf('Accession Number, %s'  , atMetaData{1}.AccessionNumber);
            asVoiRoiHeader{5} = sprintf('Series Date, %s'       , atMetaData{1}.SeriesDate);
            asVoiRoiHeader{6} = sprintf('Series Time, %s'       , atMetaData{1}.SeriesTime);
            asVoiRoiHeader{7} = sprintf('Unit, %s'              , sUnits);
            asVoiRoiHeader{8} = (' ');

            dNumberOfLines = dNumberOfLines + numel(asVoiRoiHeader); % Add header and cell description to number of needed lines

            asCell = cell(dNumberOfLines, 15); % Create an empty cell array

            dLineOffset = 1;
            for ll=1:numel(asVoiRoiHeader)

                asCell{dLineOffset,1}  = asVoiRoiHeader{ll};
                for tt=2:21
                    asCell{dLineOffset,tt}  = (' ');
                end

                dLineOffset = dLineOffset+1;
            end

            if bExpendedDisplay == true

                asCell{dLineOffset,1}  = 'Name';
                asCell{dLineOffset,2}  = 'Image number';
                asCell{dLineOffset,3}  = 'Nb Cells';
                asCell{dLineOffset,4}  = 'Total';
                asCell{dLineOffset,5}  = 'Sum';
                asCell{dLineOffset,6}  = 'Mean';
                asCell{dLineOffset,7}  = 'Min';
                asCell{dLineOffset,8}  = 'Max';
                asCell{dLineOffset,9}  = 'Median';
                asCell{dLineOffset,10}  = 'Deviation';
                asCell{dLineOffset,11} = 'Peak';
                asCell{dLineOffset,12} = 'Max Diameter (mm)';
                asCell{dLineOffset,13} = 'Max SAD (mm)';
                asCell{dLineOffset,14} = 'Area (cm2)';
                asCell{dLineOffset,15} = 'Volume (cm3)';
                
                if bSegmented == true && ...
                   bModifiedMatrix == true

                    asCell{dLineOffset,16} = 'Subtracted Area (cm2)';
                    asCell{dLineOffset,17} = 'Subtracted Volume (cm3)';
                    for tt=18:21
                        asCell{dLineOffset,tt}  = (' ');
                    end                    
                else

                    for tt=16:21
                        asCell{dLineOffset,tt}  = (' ');
                    end
                end
            else
                asCell{dLineOffset,1}  = 'Name';
                asCell{dLineOffset,2}  = 'Nb Cells';
                asCell{dLineOffset,3}  = 'Total';
                asCell{dLineOffset,4}  = 'Sum';
                asCell{dLineOffset,5}  = 'Mean';
                asCell{dLineOffset,6}  = 'Min';
                asCell{dLineOffset,7}  = 'Max';
                asCell{dLineOffset,8}  = 'Median';
                asCell{dLineOffset,9}  = 'Deviation';
                asCell{dLineOffset,10} = 'Peak';
                asCell{dLineOffset,11} = 'Volume (cm3)';

                if bSegmented == true && ...
                   bModifiedMatrix == true
                    
                    asCell{dLineOffset,12} = 'Subtracted Volume (cm3)';
                    for tt=13:21
                        asCell{dLineOffset,tt}  = (' ');
                    end                    
                else

                    for tt=12:21
                        asCell{dLineOffset,tt}  = (' ');
                    end
                end
            end

            dLineOffset = dLineOffset+1;

            if bExpendedDisplay == true

                dNbRois = numel(atRoiInput);

                for ro=1:dNbRois

                    if strcmpi(atRoiInput{ro}.ObjectType, 'voi-roi')

                        if ~isfield(atRoiInput{ro}, 'MaxDistances') 

                            tMaxDistances = computeRoiFarthestPoint(aDisplayBuffer, atMetaData, atRoiInput{ro}, false, false);

                            atRoiInput{ro}.MaxDistances = tMaxDistances;

                            % roiTemplate('set', dSeriesOffset, atRoiInput);
                       end
                    end
                end
            end

            dNbVois = numel(atVoiInput);

            if ~isempty(atVoiInput) % Scan VOIs

                for aa=1:dNbVois

                    if ~isempty(atVoiInput{aa}.RoisTag) % Found a valid VOI

                        if dNbVois > 10
                            if mod(aa, 5)==1 || aa == dNbVois
                                progressBar(aa/dNbVois-0.0001, sprintf('Computing voi %d/%d', aa, dNbVois ) );
                            end
                        end

                        [tVoiComputed, atRoiComputed] = ...
                            computeVoi(aInputBuffer, ...
                                       atInputMetaData, ...
                                       aDisplayBuffer, ...
                                       atMetaData, ...
                                       atVoiInput{aa}, ...
                                       atRoiInput, ...
                                       dSUVScale, ...
                                       bSUVUnit, ...
                                       bModifiedMatrix, ...
                                       bSegmented, ...
                                       bMovementApplied, ...
                                       transM);

                        if ~isempty(tVoiComputed)

                            sVoiName = atVoiInput{aa}.Label;

                            if bExpendedDisplay == true

                                asCell{dLineOffset,1}  = (sVoiName);
                                asCell{dLineOffset,2}  = (' ');
                                asCell{dLineOffset,3}  = [tVoiComputed.cells];
                                asCell{dLineOffset,4}  = [tVoiComputed.total];
                                asCell{dLineOffset,5}  = [tVoiComputed.sum];
                                asCell{dLineOffset,6}  = [tVoiComputed.mean];
                                asCell{dLineOffset,7}  = [tVoiComputed.min];
                                asCell{dLineOffset,8}  = [tVoiComputed.max];
                                asCell{dLineOffset,9}  = [tVoiComputed.median];
                                asCell{dLineOffset,10}  = [tVoiComputed.std];
                                asCell{dLineOffset,11} = [tVoiComputed.peak];
                                asCell{dLineOffset,12} = (' ');
                                asCell{dLineOffset,13} = (' ');
                                asCell{dLineOffset,14} = (' ');
                                asCell{dLineOffset,15} = [tVoiComputed.volume];

                                if bSegmented == true && ...
                                   bModifiedMatrix == true
                                    
                                    asCell{dLineOffset,16} = (' ');
                                    asCell{dLineOffset,17} = [tVoiComputed.removedVolume];
                                    for tt=18:21
                                        asCell{dLineOffset,tt}  = (' ');
                                    end                    
                                else

                                    for tt=16:21
                                        asCell{dLineOffset,tt}  = (' ');
                                    end
                                end
    
                            else
                                asCell{dLineOffset,1}  = (sVoiName);
                                asCell{dLineOffset,2}  = [tVoiComputed.cells];
                                asCell{dLineOffset,3}  = [tVoiComputed.total];
                                asCell{dLineOffset,4}  = [tVoiComputed.sum];
                                asCell{dLineOffset,5}  = [tVoiComputed.mean];
                                asCell{dLineOffset,6}  = [tVoiComputed.min];
                                asCell{dLineOffset,7}  = [tVoiComputed.max];
                                asCell{dLineOffset,8}  = [tVoiComputed.median];
                                asCell{dLineOffset,9}  = [tVoiComputed.std];
                                asCell{dLineOffset,10} = [tVoiComputed.peak];
                                asCell{dLineOffset,11} = [tVoiComputed.volume];

                                if bSegmented == true && ...
                                   bModifiedMatrix == true
                                    
                                    asCell{dLineOffset,12} = [tVoiComputed.removedVolume];
                                    for tt=13:21
                                        asCell{dLineOffset,tt}  = (' ');
                                    end                    
                                else

                                    for tt=12:21
                                        asCell{dLineOffset,tt}  = (' ');
                                    end
                                end
                            end

                            dLineOffset = dLineOffset+1;

                            if bExpendedDisplay == true

                                dNbTags = numel(atRoiComputed);

                                for bb=1:dNbTags % Scan VOI/ROIs

                                    if ~isempty(atRoiComputed{bb})

                                        if dNbTags > 100
                                             if mod(bb, 10)==1 || bb == dNbTags
                                                progressBar( bb/dNbTags-0.0001, sprintf('Computing roi %d/%d, please wait.', bb, dNbTags) );
                                             end
                                        end

                                        if strcmpi(atRoiComputed{bb}.Axe, 'Axe')
                                            sSliceNb = num2str(atRoiComputed{bb}.SliceNb);
                                        elseif strcmpi(atRoiComputed{bb}.Axe, 'Axes1')
                                            sSliceNb = ['C:' num2str(atRoiComputed{bb}.SliceNb)];
                                        elseif strcmpi(atRoiComputed{bb}.Axe, 'Axes2')
                                            sSliceNb = ['S:' num2str(atRoiComputed{bb}.SliceNb)];
                                        elseif strcmpi(atRoiComputed{bb}.Axe, 'Axes3')
                                            sSliceNb = ['A:' num2str(size(aDisplayBuffer, 3)-atRoiComputed{bb}.SliceNb+1)];
                                        end

                                        asCell{dLineOffset,1}  = (' ');
                                        asCell{dLineOffset,2}  = (sSliceNb);
                                        asCell{dLineOffset,3}  = [atRoiComputed{bb}.cells];
                                        asCell{dLineOffset,4}  = [atRoiComputed{bb}.total];
                                        asCell{dLineOffset,5}  = [atRoiComputed{bb}.sum];
                                        asCell{dLineOffset,6}  = [atRoiComputed{bb}.mean];
                                        asCell{dLineOffset,7}  = [atRoiComputed{bb}.min];
                                        asCell{dLineOffset,8}  = [atRoiComputed{bb}.max];
                                        asCell{dLineOffset,9}  = [atRoiComputed{bb}.median];
                                        asCell{dLineOffset,10} = [atRoiComputed{bb}.std];
                                        asCell{dLineOffset,11} = [atRoiComputed{bb}.peak];

                                        if ~isempty(atRoiComputed{bb}.MaxDistances)

                                            if atRoiComputed{bb}.MaxDistances.MaxXY.Length == 0
                                                asCell{dLineOffset, 12} = ('NaN');
                                            else
                                                asCell{dLineOffset, 12} = [atRoiComputed{bb}.MaxDistances.MaxXY.Length];
                                            end

                                            if atRoiComputed{bb}.MaxDistances.MaxCY.Length == 0
                                                asCell{dLineOffset, 13} = ('NaN');
                                            else
                                                asCell{dLineOffset, 13} = [atRoiComputed{bb}.MaxDistances.MaxCY.Length];
                                            end
                                        else
                                            asCell{dLineOffset,12} = (' ');
                                            asCell{dLineOffset,13} = (' ');
                                        end
                                        asCell{dLineOffset,14} = [atRoiComputed{bb}.area];
                                        asCell{dLineOffset,15} = (' ');

                                        if bSegmented == true && ...
                                           bModifiedMatrix == true
                                            
                                            asCell{dLineOffset,16} = [atRoiComputed{bb}.removedArea];
                                            for tt=17:21
                                                asCell{dLineOffset,tt}  = (' ');
                                            end                    
                                        else
        
                                            for tt=16:21
                                                asCell{dLineOffset,tt}  = (' ');
                                            end
                                        end

                                        dLineOffset = dLineOffset+1;
                                    end
                                end
                            end
                        end
                    end
                end
            end

            if bExpendedDisplay == true

                dNbRois = numel(atRoiInput);

                for bb=1:dNbRois % Scan ROIs

                    % if isvalid(atRoiInput{bb}.Object)
                    % if isstruct(atRoiInput{bb}) && isfield(atRoiInput{bb}, 'Object') && isvalid(atRoiInput{bb}.Object)

                        if strcmpi(atRoiInput{bb}.ObjectType, 'roi')

                            if dNbRois > 100
                                if mod(bb, 10)==1 || bb == dNbRois
                                    progressBar( bb/dNbRois-0.0001, sprintf('Computing roi %d/%d, please wait.', bb, dNbRois) );
                                end
                            end

                            if ~isfield(atRoiInput{bb}, 'MaxDistances')

                                tMaxDistances = computeRoiFarthestPoint(aDisplayBuffer, atMetaData, atRoiInput{bb}, false, false);

                                atRoiInput{bb}.MaxDistances = tMaxDistances;

                                % roiTemplate('set', dSeriesOffset, atRoiInput);
                           end

                            tRoiComputed = ...
                                computeRoi(aInputBuffer, ...
                                           atInputMetaData, ...
                                           aDisplayBuffer, ...
                                           atMetaData, ...
                                           atRoiInput{bb}, ...
                                           dSUVScale, ...
                                           bSUVUnit, ...
                                           bModifiedMatrix, ...
                                           bSegmented, ...
                                           bMovementApplied, ...
                                           transM);

                            sRoiName = atRoiInput{bb}.Label;

                            if strcmpi(atRoiInput{bb}.Axe, 'Axe')
                                sSliceNb = num2str(atRoiInput{bb}.SliceNb);
                            elseif strcmpi(atRoiInput{bb}.Axe, 'Axes1')
                                sSliceNb = ['C:' num2str(atRoiInput{bb}.SliceNb)];
                            elseif strcmpi(atRoiInput{bb}.Axe, 'Axes2')
                                sSliceNb = ['S:' num2str(atRoiInput{bb}.SliceNb)];
                            elseif strcmpi(atRoiInput{bb}.Axe, 'Axes3')
                                sSliceNb = ['A:' num2str(size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 3)-atRoiInput{bb}.SliceNb+1)];
                            end

                            asCell{dLineOffset, 1}  = (sRoiName);
                            asCell{dLineOffset, 2}  = (sSliceNb);
                            asCell{dLineOffset, 3}  = [tRoiComputed.cells];
                            asCell{dLineOffset, 4}  = [tRoiComputed.total];
                            asCell{dLineOffset, 5}  = [tRoiComputed.sum];
                            asCell{dLineOffset, 6}  = [tRoiComputed.mean];
                            asCell{dLineOffset, 7}  = [tRoiComputed.min];
                            asCell{dLineOffset, 8}  = [tRoiComputed.max];
                            asCell{dLineOffset, 9}  = [tRoiComputed.median];
                            asCell{dLineOffset, 10} = [tRoiComputed.std];
                            asCell{dLineOffset, 11} = [tRoiComputed.peak];
                            if ~isempty(tRoiComputed.MaxDistances)
                                if tRoiComputed.MaxDistances.MaxXY.Length == 0
                                    asCell{dLineOffset, 12} = ('NaN');
                                else
                                    asCell{dLineOffset, 12} = [tRoiComputed.MaxDistances.MaxXY.Length];
                                end

                                if tRoiComputed.MaxDistances.MaxCY.Length == 0
                                    asCell{dLineOffset, 13} = ('NaN');
                                else
                                    asCell{dLineOffset, 13} = [tRoiComputed.MaxDistances.MaxCY.Length];
                                end
                            else
                                asCell{dLineOffset, 12} = (' ');
                                asCell{dLineOffset, 13} = (' ');
                            end
                            asCell{dLineOffset, 14} = tRoiComputed.area;
                            asCell{dLineOffset, 15} = (' ');

                            if bSegmented == true && ...
                               bModifiedMatrix == true
                                
                                asCell{dLineOffset,16} = tRoiComputed.removedArea;
                                for tt=17:21
                                    asCell{dLineOffset,tt}  = (' ');
                                end                    
                            else

                                for tt=16:21
                                    asCell{dLineOffset,tt}  = (' ');
                                end
                            end

                            dLineOffset = dLineOffset+1;

                        end
                    % end
                end
            end

            progressBar( 0.99, sprintf('Writing file %s, please wait.', file) );

            cell2csv(sprintf('%s%s', path, file), asCell, ',');

            if bExcelInstance == true
                winopen(sprintf('%s%s', path, file));
            end

            try
                saveRoiLastUsedDir = path;
                save(sMatFile, 'saveRoiLastUsedDir');
            catch ME
                logErrorToFile(ME);
                progressBar(1 , sprintf('Warning: Cant save file %s', sMatFile));
%                        h = msgbox(sprintf('Warning: Cant save file %s', sMatFile), 'Warning');
%                        if integrateToBrowser('get') == true
%                            sLogo = './TriDFusion/logo.png';
%                        else
%                            sLogo = './logo.png';
%                        end

%                        javaFrame = get(h, 'JavaFrame');
%                        javaFrame.setFigureIcon(javax.swing.ImageIcon(sLogo));
            end

            progressBar(1, sprintf('Write %s%s completed', path, file));
%
%                 catch
%                     progressBar(1, 'Error: exportCurrentSeriesResultCallback()');
%                 end
%
%                 set(figRoiWindow, 'Pointer', 'default');
%                 drawnow;
        end
    end
end
