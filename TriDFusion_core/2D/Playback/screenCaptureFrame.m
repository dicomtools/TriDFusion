function screenCaptureFrame(sDirection)
%function screenCaptureFrame(sDirection)
%Play 2D multiframe screen capture Images.
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

    atInputTemplate = inputTemplate('get');
    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

    set(uiSeriesPtr('get'), 'Enable', 'off');

    aInput  = inputBuffer('get');

    if strcmpi(sDirection, 'next')
        dOffset = dSeriesOffset+1; 
    else
        dOffset = dSeriesOffset-1; 
    end

    if strcmpi(sDirection, 'next')

        if dOffset > numel(atInputTemplate) || ... % End of list
           ~strcmpi(atInputTemplate(dOffset).atDicomInfo{1}.SeriesInstanceUID, ... % Not the same series
                    atInputTemplate(dSeriesOffset).atDicomInfo{1}.SeriesInstanceUID)

            for bb=1:numel(atInputTemplate)
    
                if strcmpi(atInputTemplate(bb).atDicomInfo{1}.SeriesInstanceUID, ... % Try to find the first frame
                    atInputTemplate(dSeriesOffset).atDicomInfo{1}.SeriesInstanceUID)
    
                    dOffset = bb; % First offset
                    break;
                end
            end
   
        end
    else
        if dOffset < 1 || ... % End of list
           ~strcmpi(atInputTemplate(dOffset).atDicomInfo{1}.SeriesInstanceUID, ... % Not the same series
                    atInputTemplate(dSeriesOffset).atDicomInfo{1}.SeriesInstanceUID)

            for bb=1:numel(atInputTemplate)
    
                if strcmpi(atInputTemplate(bb).atDicomInfo{1}.SeriesInstanceUID, ... % Try to find the first frame
                    atInputTemplate(dSeriesOffset).atDicomInfo{1}.SeriesInstanceUID)
    
                    dOffset = bb; % Last offset
                end
            end
   
        end
    end

    % Get current Axes

    axe = axePtr('get', [], dSeriesOffset);

    % Get current CData

    imPtr  = imAxePtr ('get', [], dSeriesOffset);

    % Set new serie offset

    set(uiSeriesPtr('get'), 'Value', dOffset);

    % Set new Axes

    if isempty(axePtr('get', [], dOffset))

        axePtr('set', axe, dOffset);
    end

    % Set new CData

    if isempty(imAxePtr('get', [], dOffset))
        imAxePtr('set', imPtr, dOffset);
    end

    aBuffer = dicomBuffer('get', [], dOffset);
    if isempty(aBuffer)

        aBuffer = aInput{dOffset};
        
        dicomBuffer('set', aBuffer, dOffset);
    end

    atCoreMetaData = dicomMetaData('get', [], dOffset);
    if isempty(atCoreMetaData)

        atCoreMetaData = atInputTemplate(dOffset).atDicomInfo;
        dicomMetaData('set', atCoreMetaData, dOffset);
    end

    refreshImages();
            
    try
        tRefreshRoi = roiTemplate('get', dOffset);
        if ~isempty(tRefreshRoi)
            for bb=1:numel(tRefreshRoi)
                if isvalid(tRefreshRoi{bb}.Object)
                    tRefreshRoi{bb}.Object.Visible = 'off';
                end
            end
        end
    catch ME   
        logErrorToFile(ME);
    end

    cropValue('set', min(dicomBuffer('get', [], dOffset), [], 'all'));

    set(uiSeriesPtr('get'), 'Enable', 'on');

end
