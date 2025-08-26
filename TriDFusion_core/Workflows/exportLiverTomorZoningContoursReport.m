function exportLiverTomorZoningContoursReport(bSUVUnit, sFileName)
%function exportLiverTomorZoningContoursReport(bSUVUnit, sFileName)
%Generate a Liver Tomor Zoning Contours Report.
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
        
    atMetaData = dicomMetaData('get', [], get(uiSeriesPtr('get'), 'Value'));

    atVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
    atRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

    aDisplayBuffer = dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value'));

    aInput = inputBuffer('get');
    aInputBuffer = aInput{dSeriesOffset};

    atInputMetaData = atInput(dSeriesOffset).atDicomInfo;

    if ~isempty(atVoiInput)


        [path, file, ext] = fileparts(sFileName);
        file = sprintf('%s%s', file, ext);
        path = sprintf('%s/', path);

        if file ~= 0

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

                    dNumberOfLines = dNumberOfLines+1; 
                end          
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
            asCell{dLineOffset,12} = 'Subtracted Volume (cm3)';
            asCell{dLineOffset,13} = 'Mean Liver Ratio';

            for tt=14:21
                asCell{dLineOffset,tt}  = (' ');
            end                    

            dLineOffset = dLineOffset+1;

            dNbVois = numel(atVoiInput);

            % Compute Normalization NormalLiver mean

            dNormalizationNormalLiverMean = [];

            for aa=1:dNbVois

                if ~contains(lower(atVoiInput{aa}.Label), 'normal liver')
                    continue;
                end

                if ~isempty(atVoiInput{aa}.RoisTag) % Found a valid VOI

                    tVoiComputed = ...
                        computeVoi(aInputBuffer, ...
                                   atInputMetaData, ...
                                   aInputBuffer, ...
                                   atMetaData, ...
                                   atVoiInput{aa}, ...
                                   atRoiInput, ...
                                   dSUVScale, ...
                                   bSUVUnit, ...
                                   false, ...
                                   false, ...
                                   false, ...
                                   eye(3));

                    if ~isempty(tVoiComputed)

                        dNormalizationNormalLiverMean = tVoiComputed.mean;
                    end
                end
            end

   
            if ~isempty(atVoiInput) % Scan VOIs

                for aa=1:dNbVois

                    if contains(lower(atVoiInput{aa}.Label), 'lesion')
                        continue;
                    end

                    if contains(lower(atVoiInput{aa}.Label), 'normal liver')
                        continue;
                    end

                    if ~isempty(atVoiInput{aa}.RoisTag) % Found a valid VOI

                        tVoiComputed = ...
                            computeVoi(aInputBuffer, ...
                                       atInputMetaData, ...
                                       aDisplayBuffer, ...
                                       atMetaData, ...
                                       atVoiInput{aa}, ...
                                       atRoiInput, ...
                                       dSUVScale, ...
                                       bSUVUnit, ...
                                       true, ...
                                       true, ...
                                       false, ...
                                       eye(3));

                        if ~isempty(tVoiComputed)

                            sVoiName = sprintf('Normal %s', atVoiInput{aa}.Label);
                            sVoiName = replace(sVoiName, '-LIV', '');

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
                                
                            asCell{dLineOffset,12} = [tVoiComputed.removedVolume];
                            
                            if ~isempty(dNormalizationNormalLiverMean)

                                dRatio = tVoiComputed.mean / dNormalizationNormalLiverMean;
                                asCell{dLineOffset,13} = dRatio;
                                
                                for tt=14:21
                                    asCell{dLineOffset,tt}  = (' ');
                                end                    
                            else
                                for tt=13:21
                                    asCell{dLineOffset,tt}  = (' ');
                                end                                
                            end

                            dLineOffset = dLineOffset+1;
                        end
                    end
                end

                % Lesions  
                
                for aa=1:dNbVois

                    if ~contains(lower(atVoiInput{aa}.Label), 'lesion')
                        continue;
                    end

                    if ~isempty(atVoiInput{aa}.RoisTag) % Found a valid VOI

                        tVoiComputed = ...
                            computeVoi(aInputBuffer, ...
                                       atInputMetaData, ...
                                       aInputBuffer, ...
                                       atMetaData, ...
                                       atVoiInput{aa}, ...
                                       atRoiInput, ...
                                       dSUVScale, ...
                                       bSUVUnit, ...
                                       false, ...
                                       false, ...
                                       false, ...
                                       eye(3));

                        if ~isempty(tVoiComputed)

                            sVoiName = atVoiInput{aa}.Label;
                            sVoiName = replace(sVoiName, '-LIV', '');

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
                             
                            if ~isempty(dNormalizationNormalLiverMean)

                                dRatio = tVoiComputed.mean / dNormalizationNormalLiverMean;
                                asCell{dLineOffset,13} = [dRatio];
                                
                                for tt=14:21
                                    asCell{dLineOffset,tt}  = (' ');
                                end                   
                            else
                                for tt=13:21
                                    asCell{dLineOffset,tt}  = (' ');
                                end                                  
                            end

                            dLineOffset = dLineOffset+1;
                        end
                    end
                end

                % NormalLiver  
                
                for aa=1:dNbVois

                    if ~contains(lower(atVoiInput{aa}.Label), 'normal liver')
                        continue;
                    end

                    if ~isempty(atVoiInput{aa}.RoisTag) % Found a valid VOI

                        tVoiComputed = ...
                            computeVoi(aInputBuffer, ...
                                       atInputMetaData, ...
                                       aInputBuffer, ...
                                       atMetaData, ...
                                       atVoiInput{aa}, ...
                                       atRoiInput, ...
                                       dSUVScale, ...
                                       bSUVUnit, ...
                                       false, ...
                                       false, ...
                                       false, ...
                                       eye(3));

                        if ~isempty(tVoiComputed)

                            sVoiName = sprintf('Normalization %s', atVoiInput{aa}.Label);

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
                            
                            if ~isempty(dNormalizationNormalLiverMean)

                                dRatio = tVoiComputed.mean / dNormalizationNormalLiverMean;
                                asCell{dLineOffset,13} = [dRatio];
                                
                                for tt=14:21
                                    asCell{dLineOffset,tt}  = (' ');
                                end     
                            else
                                 for tt=13:21
                                    asCell{dLineOffset,tt}  = (' ');
                                end                                
                            end

                            dLineOffset = dLineOffset+1;
                        end
                    end
                end

                
            end

            cell2csv(sprintf('%s%s', path, file), asCell, ',');

            progressBar(1, sprintf('Write %s%s completed', path, file));

        end
    end

    clear aDisplayBuffer;
    clear aInput;
    clear aInputBuffer;

end
