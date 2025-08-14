function resetSeries(dSeriesOffset, bInitDisplay)
%function resetSeries(dSeriesOffset, bInitDisplay)
%Reset a series.
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
    
    releaseRoiWait();

    atInitInput = inputTemplate('get');
    
    dInitOffset = get(uiSeriesPtr('get'), 'Value');

    if link2DMip('get') == false
        sLinkMipEnable = 'on';
        sLinkMipBackgroundColor = viewerButtonPushedBackgroundColor('get');
        sLinkMipForegroundColor = viewerButtonPushedForegroundColor('get');
        
        btnLinkMip = btnLinkMipPtr('get');
        
        set(btnLinkMip, 'Enable', sLinkMipEnable);
        set(btnLinkMip, 'BackgroundColor', sLinkMipBackgroundColor);
        set(btnLinkMip, 'ForegroundColor', sLinkMipForegroundColor);

        set(btnLinkMipPtr('get'), 'CData', resizeTopBarIcon('link_mip_white.png'));
        
        link2DMip('set', true);
    end

    if isFusion('get') == true

        isFusion('set', false);

        set(btnFusionPtr('get'), 'BackgroundColor', viewerBackgroundColor ('get'));
        set(btnFusionPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));

        set(btnFusionPtr('get'), 'CData', resizeTopBarIcon('fusion_grey.png'));
    end

     if isPlotContours('get') == true

         isPlotContours('set', false);
%         setPlotContoursCallback(); % Deactivate plot contours
     end
    
    if switchToIsoSurface('get') == true

        switchToIsoSurface('set', false);

        set(btnIsoSurfacePtr('get'), 'BackgroundColor', viewerBackgroundColor ('get'));
        set(btnIsoSurfacePtr('get'), 'ForegroundColor', viewerForegroundColor('get'));

        set(btnIsoSurfacePtr('get'), 'CData', resizeTopBarIcon('3d_iso_grey.png'));
    end

    if switchToMIPMode('get') == true

        switchToMIPMode('set', false);

        set(btnMIPPtr('get'), 'BackgroundColor', viewerBackgroundColor ('get'));
        set(btnMIPPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));

        set(btnMIPPtr('get'), 'CData', resizeTopBarIcon('3d_mip_grey.png'));
   end

    if switchToMIPMode('get') == true

        switchToMIPMode('set', false);

        set(btn3DPtr('get'), 'BackgroundColor', viewerBackgroundColor ('get'));
        set(btn3DPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));

        set(btn3DPtr('get'), 'CData', resizeTopBarIcon('3d_volume_grey.png'));
   end

    aInput = inputBuffer('get');

  %  bReOrientedImage = false;
  %  if ~strcmpi(imageOrientation('get'), 'axial')
        
%        bReOrientedImage = true;

        % clear all contour
        
        atRoi = roiTemplate('get', dSeriesOffset);

        roiConstraintList('reset', dSeriesOffset); % Delete all masks

        for rr=1:numel(atRoi)

            if roiHasMaxDistances(atRoi{rr}) == true

                maxDistances = atRoi{rr}.MaxDistances; % Cache the field to avoid repeated lookups

                objectsToDelete = [maxDistances.MaxXY.Line, ...
                                   maxDistances.MaxCY.Line, ...
                                   maxDistances.MaxXY.Text, ...
                                   maxDistances.MaxCY.Text];
                % Delete only valid objects
                delete(objectsToDelete(isvalid(objectsToDelete)));     
            end

            if isfield(atRoi{rr}, 'Object') && isvalid(atRoi{rr}.Object)

                delete(atRoi{rr}.Object);
            end
        end

        voiRoiTag('set', '');

        roiTemplate('reset', dSeriesOffset);
        voiTemplate('reset', dSeriesOffset);        

        roiTemplateEvent('reset', dSeriesOffset);
        voiTemplateEvent('reset', dSeriesOffset);

        roiTemplateBackup('reset', dSeriesOffset);
        voiTemplateBackup('reset', dSeriesOffset);   

        % Clear all plot edit 

        atPlotEdit = plotEditTemplate('get', dSeriesOffset);

        for pe=1:numel(atPlotEdit)

            if isfield(atPlotEdit{pe}, 'Object') && isvalid(atPlotEdit{pe}.Object)

                delete(atPlotEdit{pe}.Object);
            end
        end

        plotEditTemplate('set', dSeriesOffset, []);

        % Set axial 
     
        imageOrientation('set', 'axial');
%    end

%    if     strcmpi(imageOrientation('get'), 'axial')
        aBuffer = aInput{dSeriesOffset};
%    elseif strcmpi(imageOrientation('get'), 'coronal')
%        aBuffer = permute(aInput{dSeriesOffset}, [3 2 1]);
%    elseif strcmpi(imageOrientation('get'), 'sagittal')
%        aBuffer = permute(aInput{dSeriesOffset}, [3 1 2]);
%    end
    
    % Reset Series Description
    
    asDescription = seriesDescription('get');
    
    if isempty(atInitInput(dSeriesOffset).atDicomInfo{1}.SeriesDate)
        sInitSeriesDate = '';
    else
        sSeriesDate = atInitInput(dSeriesOffset).atDicomInfo{1}.SeriesDate;
        if isempty(atInitInput(dSeriesOffset).atDicomInfo{1}.SeriesTime)
            sSeriesTime = '000000';
        else
            sSeriesTime = atInitInput(dSeriesOffset).atDicomInfo{1}.SeriesTime;
        end

        sInitSeriesDate = sprintf('%s%s', sSeriesDate, sSeriesTime);
    end

    if ~isempty(sInitSeriesDate)

        if contains(sInitSeriesDate,'.')

            sInitSeriesDate = extractBefore(sInitSeriesDate,'.');
        end
        
        % Ensure acquisitionTime is valid
        if all(sInitSeriesDate == '0') || isempty(sInitSeriesDate)
            
            sInitSeriesDate = '00010101010101'; % Default to midnight if invalid
        end

        sInitSeriesDate = datetime(sInitSeriesDate,'InputFormat','yyyyMMddHHmmss');
    end

    sInitSeriesDescription = atInitInput(dSeriesOffset).atDicomInfo{1}.SeriesDescription;

    asDescription{dSeriesOffset} = sprintf('%s %s', sInitSeriesDescription, sInitSeriesDate);
    
    seriesDescription('set', asDescription);

    set(uiSeriesPtr('get'), 'String', asDescription);
    set(uiFusedSeriesPtr('get'), 'String', asDescription);

    set(uiSeriesPtr('get'), 'Value', dSeriesOffset);

    aCurrentBuffer   = dicomBuffer('get', [], dSeriesOffset);
    aCurrentMeteData = dicomMetaData('get', [], dSeriesOffset);

    bImageIsResampled = false;
    if numel(aBuffer) ~= numel(aCurrentBuffer)

        if ~isempty(aCurrentBuffer)

            bImageIsResampled = true;
        end
    end
    
    % Reset ROIs

    atRoi = roiTemplate('get', dSeriesOffset);            
    atVoi = voiTemplate('get', dSeriesOffset);            

    if ~isempty(atRoi)       

        if bImageIsResampled == true

            [atResampledRoi, atResampledVoi] = resampleROIs(aCurrentBuffer, aCurrentMeteData, aBuffer, atInitInput(dSeriesOffset).atDicomInfo, atRoi, true, atVoi, dSeriesOffset);

            roiTemplate('set', dSeriesOffset, atResampledRoi);     
            voiTemplate('set', dSeriesOffset, atResampledVoi);     
       end
    end                
    
    % Reset Template

    if strcmpi(atInitInput(dSeriesOffset).atDicomInfo{1}.Modality, 'RTDOSE')
        bDoseKernel = true;
    else
        bDoseKernel = false;
    end

    atInitInput(dSeriesOffset).sOrientationView    = 'Axial';
    
    atInitInput(dSeriesOffset).bEdgeDetection      = false;
    atInitInput(dSeriesOffset).bFlipLeftRight      = false;
    atInitInput(dSeriesOffset).bFlipAntPost        = false;
    atInitInput(dSeriesOffset).bFlipHeadFeet       = false;
    atInitInput(dSeriesOffset).bDoseKernel         = bDoseKernel;
    atInitInput(dSeriesOffset).bMathApplied        = false;
    atInitInput(dSeriesOffset).bFusedDoseKernel    = false;
    atInitInput(dSeriesOffset).bFusedEdgeDetection = false;
    
    atInitInput(dSeriesOffset).tMovement = [];
    
    atInitInput(dSeriesOffset).tMovement.bMovementApplied = false;
    atInitInput(dSeriesOffset).tMovement.aGeomtform       = [];
    
    atInitInput(dSeriesOffset).tMovement.atSeq{1}.sAxe         = [];
    atInitInput(dSeriesOffset).tMovement.atSeq{1}.aTranslation = [];
    atInitInput(dSeriesOffset).tMovement.atSeq{1}.dRotation    = []; 
        
    dFusionSeriesOffset = get(uiFusedSeriesPtr('get'), 'Value');
    if dFusionSeriesOffset <= numel(atInitInput)

        atInitInput(dFusionSeriesOffset).bEdgeDetection = false;
    end

    inputTemplate('set', atInitInput);
    
    % Reset Display Buffer
    fusionBuffer('set', [], dSeriesOffset);

    dicomBuffer('set', aBuffer, dSeriesOffset);

    if size(aBuffer, 3) ~= 1
        mipBuffer('set', atInitInput(dSeriesOffset).aMip, dSeriesOffset);
    end 

    dicomMetaData('set', atInitInput(dSeriesOffset).atDicomInfo);

    setQuantification(dSeriesOffset);
    
    set(uiSeriesPtr('get'), 'Value', dInitOffset);

    setColorbarLabel();

    if bInitDisplay == true
        
%        if bImageIsResampled 

            initWindowLevel('set', true);

            clearDisplay();
            initDisplay(3);

            if isInterpolated('get') == true

                isInterpolated('set', false);

                setImageInterpolation(false);
            end

            dicomViewerCore();

            setViewerDefaultColor(true, dicomMetaData('get', [], dInitOffset));
            
%        else
%            [lMin, lMax] = setWindowLevel(aBuffer, atInitInput(dSeriesOffset).atDicomInfo);    

%             set(axes1Ptr('get', [], dInitOffset), 'CLim', [lMin lMax]);
%             set(axes2Ptr('get', [], dInitOffset), 'CLim', [lMin lMax]);
%             set(axes3Ptr('get', [], dInitOffset), 'CLim', [lMin lMax]);

%             if strcmpi(atInitInput(dSeriesOffset).atDicomInfo{1}.Modality, 'ct')
%                [lMax, lMin] = computeWindowLevel(2500, 415);
%             end

%             set(axesMipPtr('get', [], dInitOffset), 'CLim', [lMin lMax]);         
%        end        

%        refreshImages();
    end
    
    modifiedMatrixValueMenuOption('set', false);
    
    triangulateCallback();
end