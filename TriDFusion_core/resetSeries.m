function resetSeries(dOffset, bInitDisplay)
%function resetSeries(dOffset, bInitDisplay)
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

    tInitInput = inputTemplate('get');
    
    dInitOffset = get(uiSeriesPtr('get'), 'Value');
    
    if link2DMip('get') == false
        sLinkMipEnable = 'on';
        sLinkMipBackgroundColor = viewerButtonPushedBackgroundColor('get');
        sLinkMipForegroundColor = viewerButtonPushedForegroundColor('get');
        
        btnLinkMip = btnLinkMipPtr('get');
        
        set(btnLinkMip, 'Enable', sLinkMipEnable);
        set(btnLinkMip, 'BackgroundColor', sLinkMipBackgroundColor);
        set(btnLinkMip, 'ForegroundColor', sLinkMipForegroundColor);
        
        link2DMip('set', true);
    end
    
    if isFusion('get') == true
        setFusionCallback(); % Deactivate fusion
    end

    if isPlotContours('get') == true
       setPlotContoursCallback(); % Deactivate plot contours
    end

    aInput = inputBuffer('get');

    bReOrientedImage = false;
    if ~strcmpi(imageOrientation('get'), 'axial')
        
        bReOrientedImage = true;

        % clear all contour
        
        atRoi = roiTemplate('get', dOffset);

        roiConstraintList('reset', dOffset); % Delete all masks

        if isfield(tInitInput(dOffset), 'tRoi')
            for rr=1:numel(atRoi)
                if ~isempty(atRoi{rr}.MaxDistances)
                    delete(atRoi{rr}.MaxDistances.MaxXY.Line);
                    delete(atRoi{rr}.MaxDistances.MaxCY.Line);
                    delete(atRoi{rr}.MaxDistances.MaxXY.Text);
                    delete(atRoi{rr}.MaxDistances.MaxCY.Text);
                end
                delete(atRoi{rr}.Object);
            end

            tInitInput(dOffset).tRoi = [];
        end

        if isfield(tInitInput(dOffset), 'tVoi')
            tInitInput(dOffset).tVoi = [];
        end

        voiRoiTag('set', '');

        roiTemplate('reset', dOffset);
        voiTemplate('reset', dOffset);        
        
        % Set axial 
     
        imageOrientation('set', 'axial');
    end

%    if     strcmpi(imageOrientation('get'), 'axial')
        aBuffer = permute(aInput{dOffset}, [1 2 3]);
%    elseif strcmpi(imageOrientation('get'), 'coronal')
%        aBuffer = permute(aInput{dOffset}, [3 2 1]);
%    elseif strcmpi(imageOrientation('get'), 'sagittal')
%        aBuffer = permute(aInput{dOffset}, [3 1 2]);
%    end
    
    % Reset Series Description
    
    asDescription = seriesDescription('get');
    
    if isempty(tInitInput(dOffset).atDicomInfo{1}.SeriesDate)
        sInitSeriesDate = '';
    else
        sSeriesDate = tInitInput(dOffset).atDicomInfo{1}.SeriesDate;
        if isempty(tInitInput(dOffset).atDicomInfo{1}.SeriesTime)
            sSeriesTime = '000000';
        else
            sSeriesTime = tInitInput(dOffset).atDicomInfo{1}.SeriesTime;
        end

        sInitSeriesDate = sprintf('%s%s', sSeriesDate, sSeriesTime);
    end

    if ~isempty(sInitSeriesDate)
        if contains(sInitSeriesDate,'.')
            sInitSeriesDate = extractBefore(sInitSeriesDate,'.');
        end

        sInitSeriesDate = datetime(sInitSeriesDate,'InputFormat','yyyyMMddHHmmss');
    end

    sInitSeriesDescription = tInitInput(dOffset).atDicomInfo{1}.SeriesDescription;

    asDescription{dOffset} = sprintf('%s %s', sInitSeriesDescription, sInitSeriesDate);
    
    seriesDescription('set', asDescription);
           
    set(uiSeriesPtr('get'), 'Value', dOffset);

    aCurrentBuffer   = dicomBuffer('get');
    aCurrentMeteData = dicomMetaData('get');

    bImageIsResampled = false;
    if numel(aBuffer) ~= numel(aCurrentBuffer)
        if ~isempty(aCurrentBuffer)
            bImageIsResampled = true;
        end
    end
    
    % Reset ROIs

    atRoi = roiTemplate('get', dOffset);            
    if ~isempty(atRoi)       
        if bImageIsResampled == true
            atResampledRoi = resampleROIs(aCurrentBuffer, aCurrentMeteData, aBuffer, tInitInput(dOffset).atDicomInfo, atRoi, true);
            roiTemplate('set', dOffset, atResampledRoi);                
        end
    end                
    
    % Reset Template

    tInitInput(dOffset).bEdgeDetection = false;
    tInitInput(dOffset).bFlipLeftRight = false;
    tInitInput(dOffset).bFlipAntPost   = false;
    tInitInput(dOffset).bFlipHeadFeet  = false;
    tInitInput(dOffset).bDoseKernel    = false;
    tInitInput(dOffset).bMathApplied   = false;
    tInitInput(dOffset).bFusedDoseKernel    = false;
    tInitInput(dOffset).bFusedEdgeDetection = false;
    tInitInput(dOffset).tMovement = [];
    tInitInput(dOffset).tMovement.bMovementApplied = false;
    tInitInput(dOffset).tMovement.aGeomtform = [];
    tInitInput(dOffset).tMovement.atSeq{1}.sAxe = [];
    tInitInput(dOffset).tMovement.atSeq{1}.aTranslation = [];
    tInitInput(dOffset).tMovement.atSeq{1}.dRotation = []; 
        
    dFuseOffset = get(uiFusedSeriesPtr('get'), 'Value');
    if dFuseOffset <= numel(tInitInput)
        tInitInput(dFuseOffset).bEdgeDetection = false;
    end

    inputTemplate('set', tInitInput);
    
    % Reset Display Buffer
   
    dicomBuffer('set', aBuffer);

    if size(aBuffer, 3) ~= 1
        mipBuffer('set', tInitInput(dOffset).aMip, dOffset);
    end 

    dicomMetaData('set', tInitInput(dOffset).atDicomInfo);

    setQuantification(dOffset);
    
    set(uiSeriesPtr('get'), 'Value', dInitOffset);

    if bInitDisplay == true
        
        if bImageIsResampled == true || ...
           bReOrientedImage  == true      

            initWindowLevel('set', true);

            clearDisplay();
            initDisplay(3);

            dicomViewerCore();
        else
            [lMin, lMax] = setWindowLevel(aBuffer, tInitInput(dOffset).atDicomInfo);    

             set(axes1Ptr('get', [], dInitOffset), 'CLim', [lMin lMax]);
             set(axes2Ptr('get', [], dInitOffset), 'CLim', [lMin lMax]);
             set(axes3Ptr('get', [], dInitOffset), 'CLim', [lMin lMax]);

             if strcmpi(tInitInput(dOffset).atDicomInfo{1}.Modality, 'ct')
                [lMax, lMin] = computeWindowLevel(2500, 415);
             end

             set(axesMipPtr('get', [], dInitOffset), 'CLim', [lMin lMax]);         
        end        

        refreshImages();
    end
    
end