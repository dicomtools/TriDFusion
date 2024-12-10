function exportSimplifiedContoursReport(bSUVUnit, bSegmented, bModifiedMatrix)
%function exportSimplifiedContoursReport(bSUVUnit, bSegmented, bModifiedMatrix)
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

    dOffset = get(uiSeriesPtr('get'), 'Value');

    try
        matlab.io.internal.getExcelInstance;
        bExcelInstance = true;
    catch exception 
%            warning(message('MATLAB:xlswrite:NoCOMServer'));
        bExcelInstance = false;
    end

    atMetaData = dicomMetaData('get', [], get(uiSeriesPtr('get'), 'Value'));

    atVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
    atRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

    aDisplayBuffer = dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value'));

    aInput = inputBuffer('get');
    if     strcmpi(imageOrientation('get'), 'axial')
        aInputBuffer = permute(aInput{dOffset}, [1 2 3]);
    elseif strcmpi(imageOrientation('get'), 'coronal')
        aInputBuffer = permute(aInput{dOffset}, [3 2 1]);
    elseif strcmpi(imageOrientation('get'), 'sagittal')
        aInputBuffer = permute(aInput{dOffset}, [3 1 2]);
    end

    if size(aDisplayBuffer, 3) ==1
        
        if atInput(dOffset).bFlipLeftRight == true
            aInputBuffer=aInputBuffer(:,end:-1:1);
        end

        if atInput(dOffset).bFlipAntPost == true
            aInputBuffer=aInputBuffer(end:-1:1,:);
        end            
    else
        if atInput(dOffset).bFlipLeftRight == true
            aInputBuffer=aInputBuffer(:,end:-1:1,:);
        end

        if atInput(dOffset).bFlipAntPost == true
            aInputBuffer=aInputBuffer(end:-1:1,:,:);
        end

        if atInput(dOffset).bFlipHeadFeet == true
            aInputBuffer=aInputBuffer(:,:,end:-1:1);
        end 
    end
    
    atInputMetaData = atInput(dOffset).atDicomInfo;

    if ~isempty(atRoiInput) || ...
       ~isempty(atVoiInput)

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

        [file, path] = uiputfile(filter, 'Save contours result', sprintf('%s/%s_%s_%s_%s_CONTOURS_TriDFusion.csv' , ...
            sCurrentDir, cleanString(atMetaData{1}.PatientName), cleanString(atMetaData{1}.PatientID), cleanString(atMetaData{1}.SeriesDescription), sSeriesDate) );
        if file ~= 0

%            try

%            set(fiMainWindowPtr('get'), 'Pointer', 'watch');
%            drawnow;

            try
                saveRoiLastUsedDir = [path '/'];
                save(sMatFile, 'saveRoiLastUsedDir');
            catch
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
                dSUVScale = 0;
            end

      
            % Count number of elements

            dNumberOfLines = 1;
            if ~isempty(atVoiInput) % Scan VOI
                for aa=1:numel(atVoiInput)
                    if ~isempty(atVoiInput{aa}.RoisTag) % Found a VOI

                        dNumberOfLines = dNumberOfLines+1;
if 0                    

                        for cc=1:numel(atVoiInput{aa}.RoisTag)
                            for bb=1:numel(atRoiInput)
                               if isvalid(atRoiInput{bb}.Object)
                                    if strcmpi(atVoiInput{aa}.RoisTag{cc}, atRoiInput{bb}.Tag) % Found a VOI/ROI

                                        dNumberOfLines = dNumberOfLines+1;

                                    end
                                end
                            end
                        end
end                        
                    end
                    
                end
            end

            for bb=1:numel(atRoiInput) % Scan ROI
                if isvalid(atRoiInput{bb}.Object)
                    if strcmpi(atRoiInput{bb}.ObjectType, 'roi') % Found a ROI

                        dNumberOfLines = dNumberOfLines+1;
                    end
                end
            end

            bDoseKernel      = atInput(dOffset).bDoseKernel;
            bMovementApplied = atInput(dOffset).tMovement.bMovementApplied;
            
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
            asVoiRoiHeader{9} = ('MTV');
            asVoiRoiHeader{10} = ('TLG');
            asVoiRoiHeader{11} = (' ');

            dNumberOfLines = dNumberOfLines + numel(asVoiRoiHeader) + 3; % Add header and cell description to number of needed lines % Add MTV and GTV

            asCell = cell(dNumberOfLines, 21); % Create an empty cell array

            dLineOffset = 1;
            for ll=1:numel(asVoiRoiHeader)

                asCell{dLineOffset,1}  = asVoiRoiHeader{ll};
                for tt=2:21
                    asCell{dLineOffset,tt}  = (' ');
                end

                dLineOffset = dLineOffset+1;
            end

            asCell{dLineOffset,1} = 'Name';
%            asCell{dLineOffset,2}  = 'Image number';
            asCell{dLineOffset,2} = 'Nb Cells';
            asCell{dLineOffset,3} = 'Total';
            asCell{dLineOffset,4} = 'Sum';
            asCell{dLineOffset,5} = 'Mean';
            asCell{dLineOffset,6} = 'Min';
            asCell{dLineOffset,7} = 'Max';
            asCell{dLineOffset,8} = 'Median';
            asCell{dLineOffset,9} = 'Deviation';
            asCell{dLineOffset,10} = 'Peak';
            asCell{dLineOffset,11} = 'Max Diagomal Coronal (mm)';
            asCell{dLineOffset,12} = 'Max Diagomal Sagittal (mm)';
            asCell{dLineOffset,13} = 'Max Diagomal Axial (mm)';
            asCell{dLineOffset,14} = 'Volume (ml)';
            
            for tt=15:21
                asCell{dLineOffset,tt}  = (' ');
            end

            dLineOffset = dLineOffset+1;

            dNbVois = numel(atVoiInput);

            dMTV = 0;
            imCMask  = [];


            if ~isempty(atVoiInput) % Scan VOIs
                for aa=1:dNbVois
                    if ~isempty(atVoiInput{aa}.RoisTag) % Found a valid VOI

                        if dNbVois > 10
                            if mod(aa, 5)==1 || aa == dNbVois
                                progressBar(aa/dNbVois-0.0001, sprintf('Computing VOI %d/%d', aa, dNbVois ) );
                            end
                        end

                       
                        tMaxDistances = computeVoiPlanesFarthestPoint( atVoiInput{aa}, atRoiInput, atMetaData, aDisplayBuffer, false);

                        [tVoiComputed, ~, imCData] = ...
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
                                       bDoseKernel, ...
                                       bMovementApplied);
                        
                        if ~isempty(tVoiComputed)

                            sVoiName = atVoiInput{aa}.Label;

                            asCell{dLineOffset,1}  = (sVoiName);
                            asCell{dLineOffset,2} = [tVoiComputed.cells];
                            asCell{dLineOffset,3} = [tVoiComputed.total];
                            asCell{dLineOffset,4} = [tVoiComputed.sum];
                            asCell{dLineOffset,5} = [tVoiComputed.mean];
                            asCell{dLineOffset,6} = [tVoiComputed.min];
                            asCell{dLineOffset,7} = [tVoiComputed.max];
                            asCell{dLineOffset,8} = [tVoiComputed.median];
                            asCell{dLineOffset,9} = [tVoiComputed.std];
                            asCell{dLineOffset,10} = [tVoiComputed.peak];

                            if isempty(tMaxDistances.Coronal)
                                asCell{dLineOffset,11} = ('NaN');
                            else
                                asCell{dLineOffset,11} = [tMaxDistances.Coronal.MaxLength];
                            end

                            if isempty(tMaxDistances.Sagittal)
                                asCell{dLineOffset,12} = ('NaN');
                            else
                                asCell{dLineOffset,12} = [tMaxDistances.Sagittal.MaxLength];
                            end

                            if isempty(tMaxDistances.Axial)
                                asCell{dLineOffset,13} = ('NaN');
                            else
                                asCell{dLineOffset,13} = [tMaxDistances.Axial.MaxLength];
                            end

                            asCell{dLineOffset,14} = [tVoiComputed.volume];

                            for tt=15:21
                                asCell{dLineOffset,tt}  = (' ');
                            end

                            dLineOffset = dLineOffset+1;
                            
                            dMTV = dMTV+tVoiComputed.volume;
                            imCMask=[imCData(:);imCMask];

                        end
                    end
                end
            end    

            if dMTV ~= 0
                asCell{9,2} = sprintf('%.3f', dMTV);
            end

            if ~isempty(imCMask)

                dMean = mean(imCMask, 'All');

                if bDoseKernel == false && ...
                   bSUVUnit    == true

                    if (strcmpi(atMetaData{1}.Modality, 'pt') || ...
                        strcmpi(atMetaData{1}.Modality, 'nm'))&& ...
                        strcmpi(atMetaData{1}.Units, 'BQML' )
                        dMean = dMean*dSUVScale;
                    end
                end
            
                asCell{10,2} =  sprintf('%.3f', dMTV*dMean);               

                clear imCMask;
            end
            
            progressBar( 0.99, sprintf('Writing file %s, please wait', file) );

            cell2csv(sprintf('%s%s', path, file), asCell, ',');

            if bExcelInstance == true
                winopen(sprintf('%s%s', path, file));
            end

            try
                saveRoiLastUsedDir = path;
                save(sMatFile, 'saveRoiLastUsedDir');
            catch
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

%            catch
%                progressBar(1, 'Error: exportSimplifiedContoursReport()');
%            end

%             set(fiMainWindowPtr('get'), 'Pointer', 'default');
%             drawnow;
        end
    end



end