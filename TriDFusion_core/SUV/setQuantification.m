function setQuantification(dSeriesOffset)
%function setQuantification(~, ~)
%Set SUV Quantification Template.
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

    tInput = inputTemplate('get');

    if exist('dSeriesOffset', 'var')
        aInputBuffer  = dicomBuffer('get', [], dSeriesOffset);
        if isempty(aInputBuffer)
            aInputBuffer = inputBuffer('get');
            aInputBuffer = aInputBuffer{dSeriesOffset};
        end

        dLoopBegin = dSeriesOffset;
        dLoopEnd   = dSeriesOffset;
    else
        aInputBuffer = inputBuffer('get');

        dLoopBegin = 1;
        dLoopEnd   = numel(tInput);
    end

    for cc=dLoopBegin:dLoopEnd

        if exist('dSeriesOffset', 'var')
            aInput = aInputBuffer;
        else
            aInput = aInputBuffer{cc};
        end

        tInput(cc).tQuant.tCount.dMin = min(aInput,[],'all');
        tInput(cc).tQuant.tCount.dMax = max(aInput,[],'all');
        tInput(cc).tQuant.tCount.dSum = sum(aInput,'all');

        if exist('dSeriesOffset', 'var')
            atQuantDicomInfo = dicomMetaData('get', [], dSeriesOffset);
            if isempty(atQuantDicomInfo)
                atQuantDicomInfo = tInput(dSeriesOffset).atDicomInfo;
            end
        else
            atQuantDicomInfo = tInput(cc).atDicomInfo;
        end

        sModality = lower(tInput(cc).atDicomInfo{1}.Modality);
        if strcmpi(sModality, 'ct') || strcmpi(sModality, 'mr')

            xPixel = 0;
            yPixel = 0;
%            zPixel = 0;
            for jj=1: numel(atQuantDicomInfo)-1

                xPixel = xPixel + (atQuantDicomInfo{jj}.PixelSpacing(1)/10);
                yPixel = yPixel + (atQuantDicomInfo{jj}.PixelSpacing(2)/10);

%                if atQuantDicomInfo{jj  }.SliceLocation - ...
%                   atQuantDicomInfo{jj+1}.SliceLocation > 0
%                    zPixel = atQuantDicomInfo{jj  }.SliceLocation - ...
%                             atQuantDicomInfo{jj+1}.SliceLocation + ...
%                             zPixel;

%                elseif atQuantDicomInfo{jj+1}.SliceLocation - ...
%                       atQuantDicomInfo{jj  }.SliceLocation > 0
%                    zPixel = atQuantDicomInfo{jj+1}.SliceLocation - ...
%                             atQuantDicomInfo{jj  }.SliceLocation + ...
%                             zPixel;
%                end

            %    zPixel = zPixel + (tInput(cc).atDicomInfo{jj}.SliceThickness /10);
            end
            xPixel = xPixel / numel(atQuantDicomInfo);
            yPixel = yPixel / numel(atQuantDicomInfo);
            zPixel = computeSliceSpacing(atQuantDicomInfo);
%            zPixel = zPixel / (numel(atQuantDicomInfo)-1);

            voxVolume = xPixel * yPixel * zPixel;
            nbVoxels = numel(aInput);
            volMean =  mean(aInput,'all');

            tInput(cc).tQuant.tHU.dMin = tInput(cc).tQuant.tCount.dMin;
            tInput(cc).tQuant.tHU.dMax = tInput(cc).tQuant.tCount.dMax;
            tInput(cc).tQuant.tHU.dTot = voxVolume * nbVoxels * volMean;

        elseif strcmpi(sModality, 'pt') || strcmpi(sModality, 'nm')

            dScale = computeSUV(atQuantDicomInfo, viewerSUVtype('get'));

            if dScale ~= 0
                xPixel = 0;
                yPixel = 0;
%                zPixel = 0;

                for jj=1: numel(atQuantDicomInfo)
                    xPixel = xPixel + (atQuantDicomInfo{jj}.PixelSpacing(1)/10);
                    yPixel = yPixel + (atQuantDicomInfo{jj}.PixelSpacing(2)/10);
                end

                xPixel = xPixel / numel(atQuantDicomInfo);
                yPixel = yPixel / numel(atQuantDicomInfo);
                zPixel = computeSliceSpacing(atQuantDicomInfo);

                voxVolume = xPixel * yPixel * zPixel;
                nbVoxels = numel(aInput);
                volMean =  mean(aInput,'all');

                tInput(cc).tQuant.tSUV.dScale = dScale;
                tInput(cc).tQuant.tSUV.dMin =  tInput(cc).tQuant.tCount.dMin * dScale;
                tInput(cc).tQuant.tSUV.dMax =  tInput(cc).tQuant.tCount.dMax * dScale;
                tInput(cc).tQuant.tSUV.dTot =  voxVolume * nbVoxels * volMean;
                tInput(cc).tQuant.tSUV.dmCi =  (voxVolume * nbVoxels * volMean) / 3.7E7 / 10;
            end
        else
        end
    end

    if exist('dSeriesOffset', 'var')
        
        inputTemplate('set', tInput);

        quantificationTemplate('set', tInput(dSeriesOffset).tQuant, dSeriesOffset);
%            inputTemplate('set', tInput);
%        cropValue('set', tInput(dSeriesOffset).tQuant.tCount.dMin);
        sModality = tInput(dSeriesOffset).atDicomInfo{1}.Modality;
        if strcmpi(sModality, 'ct')
%            imageSegEditValue('set', 'lower', 44 );
%            imageSegEditValue('set', 'upper', 100);
            imageSegEditValue('set', 'lower', tInput(dSeriesOffset).tQuant.tCount.dMin);
            imageSegEditValue('set', 'upper', tInput(dSeriesOffset).tQuant.tCount.dMax);
        else
            imageSegEditValue('set', 'lower', tInput(dSeriesOffset).tQuant.tCount.dMin);
            imageSegEditValue('set', 'upper', tInput(dSeriesOffset).tQuant.tCount.dMax);
        end
    else
        inputTemplate('set', tInput);
        quantificationTemplate('set', tInput(1).tQuant);
        cropValue('set', tInput(1).tQuant.tCount.dMin);

        sModality = tInput(1).atDicomInfo{1}.Modality;
        if strcmpi(sModality, 'ct')
%            imageSegEditValue('set', 'lower', 44 );
%            imageSegEditValue('set', 'upper', 100);
            imageSegEditValue('set', 'lower', tInput(1).tQuant.tCount.dMin);
            imageSegEditValue('set', 'upper', tInput(1).tQuant.tCount.dMax);
        else
            imageSegEditValue('set', 'lower', tInput(1).tQuant.tCount.dMin);
            imageSegEditValue('set', 'upper', tInput(1).tQuant.tCount.dMax);
        end

    end
    
    setKernelCtDoseMapUiValues();
    setResampleToCTIsoMaskValues();
    setRoiPanelCtUiValues();

end
