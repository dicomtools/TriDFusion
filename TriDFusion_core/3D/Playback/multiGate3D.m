function multiGate3D(mPlay)
%function multiGate3D(mPlay)
%Play 3D DICOM 4D Images.
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

     if size(dicomBuffer('get'), 3) == 1
        progressBar(1, 'Error: Require a 3D Volume!');
        multiFrame3DPlayback('set', false);
        mPlay.State = 'off';
        return;
     end

    volGateObj = volGateObject('get');
    isoGateObj = isoGateObject('get');
    mipGateObj = mipGateObject('get');
    voiGateObj = voiGateObject('get');

    volObjBak  = volObject('get');
    isoObjBak  = isoObject('get');
    mipObjBak  = mipObject('get');

    if isFusion('get') == true
        tFuseInput     = inputTemplate('get');
        iFuseOffset    = get(uiFusedSeriesPtr('get'), 'Value');
        atFuseMetaData = tFuseInput(iFuseOffset).atDicomInfo;
    end

    volGateFusionObj = volGateFusionObject('get');
    isoGateFusionObj = isoGateFusionObject('get');
    mipGateFusionObj = mipGateFusionObject('get');

    volFusionObjBak  = volFusionObject('get');
    isoFusionObjBak  = isoFusionObject('get');
    mipFusionObjBak  = mipFusionObject('get');

%    voiObjBak = voiObject('get');

%          aBackup = dicomBuffer('get');
    aInput  = inputBuffer('get');

    tInput = inputTemplate('get');

    dZoomBak = multiFrame3DZoom('get');

    iSeriesOffset = get(uiSeriesPtr('get'), 'Value');
    if iSeriesOffset > numel(tInput) || ...
       numel(tInput) < 2 % Need a least 2 series
        progressBar(1, 'Error: Require at least two 3D Volume!');
        multiFrame3DPlayback('set', false);
        mPlay.State = 'off';
        return;
    end

    if ~isfield(tInput(iSeriesOffset).atDicomInfo{1}.din, 'frame') && ...
       gateUseSeriesUID('get') == true
        progressBar(1, 'Error: Require a dynamic 3D Volume!');
        multiFrame3DPlayback('set', false);
        mPlay.State = 'off';
        return;
    end

    if gateUseSeriesUID('get') == true
        iOffset = iSeriesOffset;

        for idx=1: numel(tInput)

            iOffset = iOffset+1;

            if iOffset > numel(tInput) || ... % End of list
               ~strcmpi(tInput(iOffset).atDicomInfo{1}.SeriesInstanceUID, ... % Not the same series
                        tInput(iOffset-1).atDicomInfo{1}.SeriesInstanceUID)
                for bb=1:numel(tInput)
                    if strcmpi(tInput(bb).atDicomInfo{1}.SeriesInstanceUID, ... % Try to find the first frame
                        tInput(iOffset-1).atDicomInfo{1}.SeriesInstanceUID)
                        iOffset = bb;
                        break;
                    end

                end
            end
            if iOffset == iSeriesOffset
                iNbSeries = idx;
                break
            end
        end
    else
        iNbSeries = numel(tInput);
    end

    set(btn3DPtr('get')        , 'Enable', 'off');
    set(btnIsoSurfacePtr('get'), 'Enable', 'off');
    set(btnMIPPtr('get')       , 'Enable', 'off');

    if isFusion('get') == true
        set(btnFusionPtr('get'), 'Enable', 'off');
    end

    set(uiOneWindowPtr('get'), 'Visible', 'off');

    ui3DGateWindow = ui3DGateWindowObject('get');

    if isempty(ui3DGateWindow)

        for tt=1:iNbSeries
            if view3DPanel('get') == false
                ui3DWindow{tt} = uipanel(fiMainWindowPtr('get'),...
                                      'Units'   , 'pixels',...
                                      'BorderWidth', showBorder('get'),...
                                      'HighlightColor', [0 1 1],...
                                      'BackgroundColor', surfaceColor('get', background3DOffset('get')),...
                                      'position', [0 ...
                                                   addOnWidth('get')+30 ...
                                                   getMainWindowSize('xsize')-280 ...
                                                   getMainWindowSize('ysize')-getTopWindowSize('ysize')-addOnWidth('get')-30]);
            else
                ui3DWindow{tt} = uipanel(fiMainWindowPtr('get'),...
                                      'Units'   , 'pixels',...
                                      'BorderWidth', showBorder('get'),...
                                      'HighlightColor', [0 1 1],...
                                      'BackgroundColor', surfaceColor('get', background3DOffset('get')),...
                                      'position', [680 ...
                                                   addOnWidth('get')+30 ...
                                                   getMainWindowSize('xsize')-680 ...
                                                   getMainWindowSize('ysize')-getTopWindowSize('ysize')-addOnWidth('get')-30]);
            end
            ui3DWindow{tt}.Visible = 'off';
        end

    end

    if isempty(ui3DGateWindow)
        ui3DGateWindowObject('set', ui3DWindow);
    else
        ui3DWindow = ui3DGateWindow;
    end

    ui3DLogo = ui3DLogoObject('get');
    if ~isempty(ui3DLogo)
        for tt=1:numel(ui3DLogo)
            delete(ui3DLogo{tt});
        end
    end

    for tt=1:iNbSeries
        ui3DLogo{tt} = displayLogo(ui3DWindow{tt});
    end
    ui3DLogoObject('set', ui3DLogo);

    uiVolColorbar = volColorObject('get');
    if ~isempty(uiVolColorbar)
        delete(uiVolColorbar);
    end
    volColorObject('set', '');

    uiMipColorbar = mipColorObject('get');
    if ~isempty(uiMipColorbar)
        delete(uiMipColorbar);
    end
    mipColorObject('set', '');

    for tt=1:iNbSeries
        if displayVolColorMap('get') == true && ...
           switchTo3DMode('get') == true
            if isFusion('get') == true && ...
               get(ui3DVolumePtr('get'), 'Value') == 2 % Fusion
                ui3DVolColorbar{tt} = volColorbar(ui3DWindow{tt}, get3DColorMap('one', colorMapVolFusionOffset('get')));
            else
                ui3DVolColorbar{tt} = volColorbar(ui3DWindow{tt}, get3DColorMap('one', colorMapVolOffset('get')));
            end
            volColorObject('set', ui3DVolColorbar{tt});
        end
    end

    if displayVolColorMap('get') == false || ...
       switchTo3DMode('get') == false

        ui3DVolColorbar = '';
        volColorObject('set', '');
    end

    for tt=1:iNbSeries
        if displayMIPColorMap('get') == true && ...
           switchToMIPMode('get') == true
            if isFusion('get') == true && ...
               get(ui3DVolumePtr('get'), 'Value') == 2 % Fusion
                ui3DMipColorbar{tt} = mipColorbar(ui3DWindow{tt}, get3DColorMap('one', colorMapMipFusionOffset('get')));
            else
                ui3DMipColorbar{tt} = mipColorbar(ui3DWindow{tt}, get3DColorMap('one', colorMapMipOffset('get')));
            end
            mipColorObject('set', ui3DMipColorbar{tt});
        end
    end

    if displayMIPColorMap('get') == false || ...
       switchToMIPMode('get') == false
        ui3DMipColorbar = '';
        mipColorObject('set', '');
    end

    multiFrame3DPlayback('set', false);

    dNbSurface = 0;
    if switchToMIPMode('get') == true
        dNbSurface = dNbSurface+1;
    end

    if switchToIsoSurface('get') == true
        dNbSurface = dNbSurface+1;
    end

    if switchTo3DMode('get') == true
        dNbSurface = dNbSurface+1;
    end

    iOffset = iSeriesOffset;
    for tt=1:iNbSeries

        set(uiSeriesPtr('get'), 'Value', iOffset);
        atCoreMetaData = dicomMetaData('get');
        if isempty(atCoreMetaData)
            atCoreMetaData = tInput(iOffset).atDicomInfo;
            dicomMetaData('set', atCoreMetaData);
        end

        aBuffer = dicomBuffer('get');

        if isempty(aBuffer)
            if     strcmp(imageOrientation('get'), 'axial')
                aBuffer = permute(aInput{iOffset}, [1 2 3]);
            elseif strcmp(imageOrientation('get'), 'coronal')
                aBuffer = permute(aInput{iOffset}, [3 2 1]);
            elseif strcmp(imageOrientation('get'), 'sagittal')
                aBuffer = permute(aInput{iOffset}, [3 1 2]);
            end

            dicomBuffer('set', aBuffer);
        end

        for dPriorityLoop=1:3

            if switchToMIPMode('get') == true

                dPriority = surface3DPriority('get', 'MaximumIntensityProjection');

                if isempty(mipGateObj)&&(dPriority == dPriorityLoop)
                    mipObj{tt} = initVolShow(aBuffer, ui3DWindow{tt}, 'MaximumIntensityProjection', atCoreMetaData);
                    if isFusion('get') == true
                        if isempty(mipGateFusionObj)
                            mipFusionObj{tt} = initVolShow(fusionBuffer('get'), ui3DWindow{tt}, 'MaximumIntensityProjection', atFuseMetaData);
                        end
                    end
                end

            end

            if switchToIsoSurface('get') == true

                dPriority = surface3DPriority('get', 'Isosurface');

                if isempty(isoGateObj) &&(dPriority == dPriorityLoop)
                    isoObj{tt} = initVolShow(aBuffer, ui3DWindow{tt}, 'Isosurface', atCoreMetaData);
                    if isFusion('get') == true
                        if isempty(isoGateFusionObj)
                            isoFusionObj{tt} = initVolShow(fusionBuffer('get'), ui3DWindow{tt}, 'Isosurface', atFuseMetaData);
                        end
                    end
                end
            end

            if switchTo3DMode('get') == true

                dPriority = surface3DPriority('get', 'VolumeRendering');

                if isempty(volGateObj) &&(dPriority == dPriorityLoop)
                    volObj{tt} = initVolShow(aBuffer, ui3DWindow{tt}, 'VolumeRendering', atCoreMetaData);
                    if isFusion('get') == true
                        if isempty(volGateFusionObj)
                            volFusionObj{tt} = initVolShow(fusionBuffer('get'), ui3DWindow{tt}, 'VolumeRendering', atFuseMetaData);
                        end
                    end
                end
            end

        end

        if isempty(voiGateObj)
            if isfield(tInput(iOffset), 'tVoi')
%                voiTemplate('set', tInput(iOffset).tVoi);             
                voiGate{iOffset} = initVoiIsoSurface(ui3DWindow{tt});
            else
                voiGate{iOffset} = '';
            end
        end

        set(ui3DWindow{tt}, 'Visible', 'off');

        iOffset = iOffset+1;

        if gateUseSeriesUID('get') == true

            if iOffset > numel(tInput) || ... % End of list
               ~strcmpi(tInput(iOffset).atDicomInfo{1}.SeriesInstanceUID, ... % Not the same series
                        tInput(iOffset-1).atDicomInfo{1}.SeriesInstanceUID)
                for bb=1:numel(tInput)
                    if strcmpi(tInput(bb).atDicomInfo{1}.SeriesInstanceUID, ... % Try to find the first frame
                        tInput(iOffset-1).atDicomInfo{1}.SeriesInstanceUID)
                        iOffset = bb;
                        break;
                    end

                end
            end
        else
            if iOffset > numel(tInput)
                iOffset = 1;
            end
        end

        progressBar(tt / iNbSeries, 'Initializing surface');

    end

    if isempty(voiGateObj)
        voiGateObject('set', voiGate);
    else
        voiGate = voiGateObj;
    end

    if switchToMIPMode('get') == true

        if isempty(mipGateObj)
            mipGateObject('set', mipObj);
        else
            mipObj = mipGateObj;
        end

        if isFusion('get') == true
            if isempty(mipGateFusionObj)
                mipGateFusionObject('set', mipFusionObj);
            else
                mipFusionObj = mipGateFusionObj;
            end
        end

        dCameraViewAngle = mipObjBak.CameraViewAngle;
        multiFrame3DZoom('set', dCameraViewAngle);

        aScaleFactors    = mipObjBak.ScaleFactors;
        aBackgroundColor = mipObjBak.BackgroundColor;
        aPosition        = mipObjBak.CameraPosition;
        aUpVector        = mipObjBak.CameraUpVector;
        aMipAlphamap     = mipObjBak.Alphamap;
        aMipColormap     = mipObjBak.Colormap;

        if isFusion('get') == true
            aMipFusionAlphamap = mipFusionObjBak.Alphamap;
            aMipFusionColormap = mipFusionObjBak.Colormap;
        else
            if ~isempty(mipGateFusionObj)
                aZeros = zeros(256,1);
                for tt=1:numel(mipGateFusionObj)
                    mipGateFusionObj{tt}.Alphamap = aZeros;
                end
            end
        end

        for tt=1:numel(mipObj)
            mipObj{tt}.ScaleFactors    = aScaleFactors;
            mipObj{tt}.BackgroundColor = aBackgroundColor;
            mipObj{tt}.CameraPosition  = aPosition;
            mipObj{tt}.CameraUpVector  = aUpVector;
            mipObj{tt}.Alphamap        = aMipAlphamap;
            mipObj{tt}.Colormap        = aMipColormap;

            if isFusion('get') == true
                mipFusionObj{tt}.ScaleFactors    = aScaleFactors;
                mipFusionObj{tt}.BackgroundColor = aBackgroundColor;
                mipFusionObj{tt}.CameraPosition  = aPosition;
                mipFusionObj{tt}.CameraUpVector  = aUpVector;
                mipFusionObj{tt}.Alphamap        = aMipFusionAlphamap;
                mipFusionObj{tt}.Colormap        = aMipFusionColormap;
            end

        end
    else
        if ~isempty(mipGateObj)
            aZeros = zeros(256,1);
            for tt=1:numel(mipGateObj)
                mipGateObj{tt}.Alphamap = aZeros;
            end
        end

        if ~isempty(mipGateFusionObj)
            aZeros = zeros(256,1);
            for tt=1:numel(mipGateFusionObj)
                mipGateFusionObj{tt}.Alphamap = aZeros;
            end
        end
    end

    if switchToIsoSurface('get') == true

        if isempty(isoGateObj)
            isoGateObject('set', isoObj);
        else
            isoObj = isoGateObj;
        end

        if isFusion('get') == true
            if isempty(isoGateFusionObj)
                isoGateFusionObject('set', isoFusionObj);
            else
                isoFusionObj = isoGateFusionObj;
            end
        end

        dCameraViewAngle = isoObjBak.CameraViewAngle;
        multiFrame3DZoom('set', dCameraViewAngle);

        aScaleFactors    = isoObjBak.ScaleFactors;
        aBackgroundColor = isoObjBak.BackgroundColor;
        aPosition        = isoObjBak.CameraPosition;
        aUpVector        = isoObjBak.CameraUpVector;
        aIsovalue        = isoObjBak.Isovalue;
        aIsosurfaceColor = isoObjBak.IsosurfaceColor;

        if isFusion('get') == true
            aFusionIsovalue        = isoFusionObjBak.Isovalue;
            aFusionIsosurfaceColor = isoFusionObjBak.IsosurfaceColor;
        else
             aFusionIsovalue = 1;
        end

        for tt=1:numel(isoObj)
            isoObj{tt}.ScaleFactors    = aScaleFactors;
            isoObj{tt}.BackgroundColor = aBackgroundColor;
            isoObj{tt}.CameraPosition  = aPosition;
            isoObj{tt}.CameraUpVector  = aUpVector;
            isoObj{tt}.Isovalue        = aIsovalue;
            isoObj{tt}.IsosurfaceColor = aIsosurfaceColor;

            if isFusion('get') == true
                isoFusionObj{tt}.ScaleFactors    = aScaleFactors;
                isoFusionObj{tt}.BackgroundColor = aBackgroundColor;
                isoFusionObj{tt}.CameraPosition  = aPosition;
                isoFusionObj{tt}.CameraUpVector  = aUpVector;
                isoFusionObj{tt}.Isovalue        = aFusionIsovalue;
                isoFusionObj{tt}.IsosurfaceColor = aFusionIsosurfaceColor;
            end

        end
    else
        if ~isempty(isoGateObj)
            for tt=1:numel(isoGateObj)
                isoGateObj{tt}.Isovalue = 1;
            end
        end

        if ~isempty(isoGateFusionObj)
            for tt=1:numel(isoGateFusionObj)
                isoGateFusionObj{tt}.Isovalue = 1;
            end
        end
    end

    if switchTo3DMode('get') == true
        if isempty(volGateObj)
            volGateObject('set', volObj);
        else
            volObj = volGateObj;
        end

        if isFusion('get') == true
            if isempty(volGateFusionObj)
                volGateFusionObject('set', volFusionObj);
            else
                volFusionObj = volGateFusionObj;
            end
        end

        dCameraViewAngle = volObjBak.CameraViewAngle;
        multiFrame3DZoom('set', dCameraViewAngle);

        bLighting        = volObjBak.Lighting;
        aScaleFactors    = volObjBak.ScaleFactors;
        aBackgroundColor = volObjBak.BackgroundColor;
        aPosition        = volObjBak.CameraPosition;
        aUpVector        = volObjBak.CameraUpVector;
        aVolAlphamap     = volObjBak.Alphamap;
        aVolColormap     = volObjBak.Colormap;

        if isFusion('get') == true
            bFusionLighting    = volFusionObjBak.Lighting;
            aVolFusionAlphamap = volFusionObjBak.Alphamap;
            aVolFusionColormap = volFusionObjBak.Colormap;
        else
            if ~isempty(volGateFusionObj)
                aZeros = zeros(256,1);
                for tt=1:numel(volGateFusionObj)
                    volGateFusionObj{tt}.Alphamap = aZeros;
                end
            end
        end

        for tt=1:numel(volObj)

            volObj{tt}.Lighting        = bLighting;
            volObj{tt}.ScaleFactors    = aScaleFactors;
            volObj{tt}.BackgroundColor = aBackgroundColor;
            volObj{tt}.CameraPosition  = aPosition;
            volObj{tt}.CameraUpVector  = aUpVector;
            volObj{tt}.Alphamap        = aVolAlphamap;
            volObj{tt}.Colormap        = aVolColormap;

            if isFusion('get') == true
                volFusionObj{tt}.Lighting        = bFusionLighting;
                volFusionObj{tt}.ScaleFactors    = aScaleFactors;
                volFusionObj{tt}.BackgroundColor = aBackgroundColor;
                volFusionObj{tt}.CameraPosition  = aPosition;
                volFusionObj{tt}.CameraUpVector  = aUpVector;
                volFusionObj{tt}.Alphamap        = aVolFusionAlphamap;
                volFusionObj{tt}.Colormap        = aVolFusionColormap;
            end
        end
    else
        if ~isempty(volGateObj)
            aZeros = zeros(256,1);
            for tt=1:numel(volGateObj)
                volGateObj{tt}.Alphamap = aZeros;
            end
        end

        if ~isempty(volGateFusionObj)
            aZeros = zeros(256,1);
            for tt=1:numel(volGateFusionObj)
                volGateFusionObj{tt}.Alphamap = aZeros;
            end
        end
    end

    if ~isempty(voiGate)
         for tt=1:numel(voiGate)
            if ~isempty(voiGate{tt})
                for ll=1:numel(voiGate{tt})
                    if displayVoi('get') == true
                        set(voiGate{tt}{ll}, 'Renderer', 'Isosurface');
                    else
                        set(voiGate{tt}{ll}, 'Renderer', 'LabelOverlayRendering');
                    end
                end
             end
         end
    end

    multiFrame3DPlayback('set', true);

    clickUp();

    initGate3DObject('set', false);

    progressBar(1, 'Ready');

    while multiFrame3DPlayback('get')

        for tt=1:iNbSeries
            if ~multiFrame3DPlayback('get')
                break;
            end

            set(uiSeriesPtr('get'), 'Value', tt);

            set(ui3DWindow{tt}, 'Visible', 'on');

            if switchTo3DMode('get') == true
                volObject('set', volObj{tt});

                if isFusion('get') == true && ...
                   get(ui3DVolumePtr('get'), 'Value') == 2 % Fusion
                    volIc = volICFusionObject('get');
                    if ~isempty(volIc)
                        volIc.surfObj = volFusionObj{tt};
                    end
                else
                    volIc = volICObject('get');
                    if ~isempty(volIc)
                        volIc.surfObj = volObj{tt};
                    end
                end
            end

            if switchToMIPMode('get') == true

                mipObject('set', mipObj{tt});

                if isFusion('get') == true && ...
                    get(ui3DVolumePtr('get'), 'Value') == 2 % Fusion
                    mipIc = mipICFusionObject('get');
                    if ~isempty(mipIc)
                        mipIc.surfObj = mipFusionObj{tt};
                   end
                else
                    mipIc = mipICObject('get');
                    if ~isempty(mipIc)
                        mipIc.surfObj = mipObj{tt};
                    end
                end
            end

            if switchToIsoSurface('get') == true
                isoObject('set', isoObj{tt});
            end

            pause(multiFrame3DSpeed('get'));

            if strcmpi(windowButton('get'), 'down')
                initGate3DObject('set', true);
            end

            waitfor(fiMainWindowPtr('get'), 'Userdata', 'up');

            if initGate3DObject('get') == true

                aBackgroundColor = surfaceColor('get', background3DOffset('get'));

                dCameraViewAngle = multiFrame3DZoom('get');

                if switchTo3DMode('get') == true
                    aScaleFactors = volObj{tt}.ScaleFactors;
                    aPosition = volObj{tt}.CameraPosition;
                    aUpVector = volObj{tt}.CameraUpVector;
                elseif switchToMIPMode('get') == true
                    aScaleFactors = mipObj{tt}.ScaleFactors;
                    aPosition = mipObj{tt}.CameraPosition;
                    aUpVector = mipObj{tt}.CameraUpVector;
                else
                    aScaleFactors = isoObj{tt}.ScaleFactors;
                    aPosition = isoObj{tt}.CameraPosition;
                    aUpVector = isoObj{tt}.CameraUpVector;
                end

                if switchTo3DMode('get') == true
                    aVolAlphamap = getVolAlphaMap('get', dicomBuffer('get'), tInput(tt).atDicomInfo);
                    aVolColormap = get3DColorMap('one', colorMapVolOffset('get') );
                    bLighting    = volLighting('get');

                    if isFusion('get') == true
                        aVolFusionAlphamap = getVolFusionAlphaMap('get', fusionBuffer('get'), atFuseMetaData);
                        aVolFusionColormap = get3DColorMap('one', colorMapVolFusionOffset('get') );
                        bFusionLighting    = volFusionLighting('get');
                    end
                end

                if switchToMIPMode('get') == true
                    aMipAlphamap = getMipAlphaMap('get', dicomBuffer('get'), tInput(tt).atDicomInfo);
                    aMipColormap = get3DColorMap('one', colorMapMipOffset('get') );

                    if isFusion('get') == true
                        aMipFusionAlphamap = getMipFusionAlphaMap('get', fusionBuffer('get'), atFuseMetaData);
                        aMipFusionColormap = get3DColorMap('one', colorMapMipFusionOffset('get') );
                    end

                end

                if switchToIsoSurface('get') == true
                    aIsovalue        =  isoSurfaceValue('get');
                    aIsosurfaceColor =  surfaceColor('one', isoColorOffset('get') );

                    if isFusion('get') == true
                        aFusionIsovalue        =  isoSurfaceFusionValue('get');
                        aFusionIsosurfaceColor =  surfaceColor('one', isoColorFusionOffset('get') );
                    end

                end

                if ~isempty(ui3DVolColorbar)
                    for oo=1:numel(ui3DVolColorbar)
                        delete(ui3DVolColorbar{oo});
                    end
                    volColorObject('set', '');
                end

                if ~isempty(ui3DMipColorbar)
                    for oo=1:numel(ui3DMipColorbar)
                        delete(ui3DMipColorbar{oo});
                    end
                    mipColorObject('set', '');
                end

                for oo=1:iNbSeries

                    if switchTo3DMode('get') == true
                        volObj{oo}.Lighting        = bLighting;
                        volObj{oo}.ScaleFactors    = aScaleFactors;
                        volObj{oo}.CameraPosition  = aPosition;
                        volObj{oo}.CameraUpVector  = aUpVector;
                        volObj{oo}.CameraViewAngle = dCameraViewAngle;
                        volObj{oo}.Alphamap        = aVolAlphamap;
                        volObj{oo}.Colormap        = aVolColormap;
                        volObj{oo}.BackgroundColor = aBackgroundColor;

                        if isFusion('get') == true
                            volFusionObj{oo}.Lighting        = bFusionLighting;
                            volFusionObj{oo}.ScaleFactors    = aScaleFactors;
                            volFusionObj{oo}.CameraPosition  = aPosition;
                            volFusionObj{oo}.CameraUpVector  = aUpVector;
                            volFusionObj{oo}.CameraViewAngle = dCameraViewAngle;
                            volFusionObj{oo}.Alphamap        = aVolFusionAlphamap;
                            volFusionObj{oo}.Colormap        = aVolFusionColormap;
                            volFusionObj{oo}.BackgroundColor = aBackgroundColor;
                        end
                    end

                    if switchToMIPMode('get') == true
                        mipObj{oo}.ScaleFactors    = aScaleFactors;
                        mipObj{oo}.CameraPosition  = aPosition;
                        mipObj{oo}.CameraUpVector  = aUpVector;
                        mipObj{oo}.CameraViewAngle = dCameraViewAngle;
                        mipObj{oo}.Alphamap        = aMipAlphamap;
                        mipObj{oo}.Colormap        = aMipColormap;
                        mipObj{oo}.BackgroundColor = aBackgroundColor;

                        if isFusion('get') == true
                            mipFusionObj{oo}.ScaleFactors    = aScaleFactors;
                            mipFusionObj{oo}.CameraPosition  = aPosition;
                            mipFusionObj{oo}.CameraUpVector  = aUpVector;
                            mipFusionObj{oo}.CameraViewAngle = dCameraViewAngle;
                            mipFusionObj{oo}.Alphamap        = aMipFusionAlphamap;
                            mipFusionObj{oo}.Colormap        = aMipFusionColormap;
                            mipFusionObj{oo}.BackgroundColor = aBackgroundColor;
                        end
                    end

                    if switchToIsoSurface('get') == true
                        isoObj{oo}.ScaleFactors    = aScaleFactors;
                        isoObj{oo}.CameraPosition  = aPosition;
                        isoObj{oo}.CameraUpVector  = aUpVector;
                        isoObj{oo}.CameraViewAngle = dCameraViewAngle;
                        isoObj{oo}.Isovalue        = aIsovalue;
                        isoObj{oo}.IsosurfaceColor = aIsosurfaceColor;
                        isoObj{oo}.BackgroundColor = aBackgroundColor;

                        if isFusion('get') == true
                            isoFusionObj{oo}.ScaleFactors    = aScaleFactors;
                            isoFusionObj{oo}.CameraPosition  = aPosition;
                            isoFusionObj{oo}.CameraUpVector  = aUpVector;
                            isoFusionObj{oo}.CameraViewAngle = dCameraViewAngle;
                            isoFusionObj{oo}.Isovalue        = aFusionIsovalue;
                            isoFusionObj{oo}.IsosurfaceColor = aFusionIsosurfaceColor;
                            isoFusionObj{oo}.BackgroundColor = aBackgroundColor;
                        end

                    end

                    if ~isempty(voiGate)
                        for ll=1:numel(voiGate{oo})
                            if displayVoi('get') == true
                                set(voiGate{oo}{ll}, 'Renderer', 'Isosurface');
                                set(voiGate{oo}{ll}, 'CameraPosition' , aPosition);
                                set(voiGate{oo}{ll}, 'CameraUpVector' , aUpVector);
                                set(voiGate{oo}{ll}, 'CameraViewAngle', dCameraViewAngle);
                                set(voiGate{oo}{ll}, 'BackgroundColor', aBackgroundColor);
                            else
                                set(voiGate{oo}{ll}, 'Renderer', 'LabelOverlayRendering');
                            end
                        end
                    end

                    delete(ui3DLogo{oo});
                    ui3DLogo{oo} = displayLogo(ui3DWindow{oo});

                    if displayVolColorMap('get') == true && ...
                       switchTo3DMode('get') == true

                        if isFusion('get') == true && ...
                            get(ui3DVolumePtr('get'), 'Value') == 2 % Fusion
                            ui3DVolColorbar{oo} = volColorbar(ui3DWindow{oo}, aVolFusionColormap);
                        else
                            ui3DVolColorbar{oo} = volColorbar(ui3DWindow{oo}, aVolColormap);
                        end

                        volColorObject('set', ui3DVolColorbar{oo});
                    end

                    if displayMIPColorMap('get') == true && ...
                       switchToMIPMode('get') == true
                        if isFusion('get') == true && ...
                           get(ui3DVolumePtr('get'), 'Value') == 2 % Fusion
                            ui3DMipColorbar{oo} = mipColorbar(ui3DWindow{oo}, aMipFusionColormap);
                        else
                            ui3DMipColorbar{oo} = mipColorbar(ui3DWindow{oo}, aMipColormap);
                        end

                        mipColorObject('set', ui3DMipColorbar{oo});
                    end

              %      progressBar(oo/iNbSeries, 'Updating Surfaces');

                end

                ui3DLogoObject('set', ui3DLogo);

                initGate3DObject('set', false);

          %      progressBar(1, 'Ready');

            end

            set(ui3DWindow{tt}, 'Visible', 'off');

        end

    end

    if ~isempty(ui3DVolColorbar)
        for oo=1:numel(ui3DVolColorbar)
            delete(ui3DVolColorbar{oo});
        end
        volColorObject('set', '');
    else
        volColorObj = volColorObject('get');
        if ~isempty(volColorObj) && ...
            displayVolColorMap('get') == false
            delete(volColorObj);
            volColorObject('set', '');
        end
    end

    if ~isempty(ui3DMipColorbar)
        for oo=1:numel(ui3DMipColorbar)
            delete(ui3DMipColorbar{oo});
        end
        mipColorObject('set', '');
    else
        mipColorObj = mipColorObject('get');
        if ~isempty(mipColorObj) && ...
            displayMIPColorMap('get') == false
            delete(mipColorObj);
            mipColorObject('set', '');
        end
    end


    for tt=1:numel(ui3DWindow)
        set(ui3DWindow{tt}, 'Visible', 'off');
    end

    if switchTo3DMode('get') == true

        volObjBak.Lighting        = volObj{1}.Lighting;
        volObjBak.ScaleFactors    = volObj{1}.ScaleFactors;
        volObjBak.BackgroundColor = volObj{1}.BackgroundColor;
        volObjBak.CameraPosition  = volObj{1}.CameraPosition;
        volObjBak.CameraUpVector  = volObj{1}.CameraUpVector;
        volObjBak.CameraViewAngle = volObj{1}.CameraViewAngle;
        volObjBak.Alphamap        = volObj{1}.Alphamap;
        volObjBak.Colormap        = volObj{1}.Colormap;

        volObject('set', volObjBak);

        if isFusion('get') == true
            volFusionObjBak.Lighting        = volFusionObj{1}.Lighting;
            volFusionObjBak.ScaleFactors    = volFusionObj{1}.ScaleFactors;
            volFusionObjBak.BackgroundColor = volFusionObj{1}.BackgroundColor;
            volFusionObjBak.CameraPosition  = volFusionObj{1}.CameraPosition;
            volFusionObjBak.CameraUpVector  = volFusionObj{1}.CameraUpVector;
            volFusionObjBak.CameraViewAngle = volFusionObj{1}.CameraViewAngle;
            volFusionObjBak.Alphamap        = volFusionObj{1}.Alphamap;
            volFusionObjBak.Colormap        = volFusionObj{1}.Colormap;

            volFusionObject('set', volFusionObjBak);
        end

        volIc = volICObject('get');
        if ~isempty(volIc)
            volIc.surfObj = volObjBak;
            volICObject('set', volIc);
        end

        volIc = volICFusionObject('get');
        if ~isempty(volIc)
            volIc.surfObj = volFusionObjBak;
            volICFusionObject('set', volIc);
        end

    end

    if switchToMIPMode('get') == true

        mipObjBak.ScaleFactors    = mipObj{1}.ScaleFactors;
        mipObjBak.BackgroundColor = mipObj{1}.BackgroundColor;
        mipObjBak.CameraPosition  = mipObj{1}.CameraPosition;
        mipObjBak.CameraUpVector  = mipObj{1}.CameraUpVector;
        mipObjBak.CameraViewAngle = mipObj{1}.CameraViewAngle;
        mipObjBak.Alphamap        = mipObj{1}.Alphamap;
        mipObjBak.Colormap        = mipObj{1}.Colormap;

        if isFusion('get') == true
            mipFusionObjBak.ScaleFactors    = mipFusionObj{1}.ScaleFactors;
            mipFusionObjBak.BackgroundColor = mipFusionObj{1}.BackgroundColor;
            mipFusionObjBak.CameraPosition  = mipFusionObj{1}.CameraPosition;
            mipFusionObjBak.CameraUpVector  = mipFusionObj{1}.CameraUpVector;
            mipFusionObjBak.CameraViewAngle = mipFusionObj{1}.CameraViewAngle;
            mipFusionObjBak.Alphamap        = mipFusionObj{1}.Alphamap;
            mipFusionObjBak.Colormap        = mipFusionObj{1}.Colormap;

            mipFusionObject('set', mipFusionObjBak);
        end

        mipObject('set', mipObjBak);

        mipIc = mipICObject('get');
        if ~isempty(mipIc)
            mipIc.surfObj = mipObjBak;
            mipICObject('set', mipIc);
        end

        mipIc = mipICFusionObject('get');
        if ~isempty(mipIc)
            mipIc.surfObj = mipFusionObjBak;
            mipICFusionObject('set', mipIc);
        end

    end

    if switchToIsoSurface('get') == true

        isoObjBak.ScaleFactors    = isoObj{1}.ScaleFactors;
        isoObjBak.BackgroundColor = isoObj{1}.BackgroundColor;
        isoObjBak.CameraPosition  = isoObj{1}.CameraPosition;
        isoObjBak.CameraUpVector  = isoObj{1}.CameraUpVector;
        isoObjBak.CameraViewAngle = isoObj{1}.CameraViewAngle;
        isoObjBak.Isovalue        = isoObj{1}.Isovalue;
        isoObjBak.IsosurfaceColor = isoObj{1}.IsosurfaceColor;

        isoObject('set', isoObjBak);

        if isFusion('get') == true
            isoFusionObjBak.ScaleFactors    = isoFusionObj{1}.ScaleFactors;
            isoFusionObjBak.BackgroundColor = isoFusionObj{1}.BackgroundColor;
            isoFusionObjBak.CameraPosition  = isoFusionObj{1}.CameraPosition;
            isoFusionObjBak.CameraUpVector  = isoFusionObj{1}.CameraUpVector;
            isoFusionObjBak.CameraViewAngle = isoFusionObj{1}.CameraViewAngle;
            isoFusionObjBak.Isovalue        = isoFusionObj{1}.Isovalue;
            isoFusionObjBak.IsosurfaceColor = isoFusionObj{1}.IsosurfaceColor;

            isoFusionObject('set', isoFusionObjBak);
        end
    end

    if displayVolColorMap('get') == true && ...
       switchTo3DMode('get') == true

        if isFusion('get') == true && ...
           get(ui3DVolumePtr('get'), 'Value') == 2 % Fusion
            uivolColorbar = volColorbar(uiOneWindowPtr('get'), get3DColorMap('one', colorMapVolFusionOffset('get')) );
        else
            uivolColorbar = volColorbar(uiOneWindowPtr('get'), get3DColorMap('one', colorMapVolOffset('get')) );
        end
        volColorObject('set', uivolColorbar);
    end

    if displayMIPColorMap('get') == true && ...
        switchToMIPMode('get') == true
        if isFusion('get') == true && ...
           get(ui3DVolumePtr('get'), 'Value') == 2 % Fusion
            uimipColorbar = mipColorbar(uiOneWindowPtr('get'), get3DColorMap('one', colorMapMipFusionOffset('get')));
        else
            uimipColorbar = mipColorbar(uiOneWindowPtr('get'), get3DColorMap('one', colorMapMipOffset('get')));
        end
        mipColorObject('set', uimipColorbar);
    end

%    if ~isempty(voiObjBak)
%        for ll=1:numel(voiObjBak)
%            set(voiObjBak{ll}, 'CameraPosition', aPosition);
%            set(voiObjBak{ll}, 'CameraUpVector', aUpVector);
%            set(voiObjBak{ll}, 'BackgroundColor',aBackgroundColor);
%            set(voiObjBak{ll}, 'CameraViewAngle',dCameraViewAngle);
%        end

%        voiObject  ('set', voiObjBak);
%    end

    multiFrame3DZoom('set', dZoomBak);

    set(uiOneWindowPtr('get'), 'Visible', 'on');

    set(uiSeriesPtr('get'), 'Value', iSeriesOffset);

  %  dicomBuffer('set', aBackup);

    set(btn3DPtr('get')        , 'Enable', 'on');
    set(btnIsoSurfacePtr('get'), 'Enable', 'on');
    set(btnMIPPtr('get')       , 'Enable', 'on');

    if isFusion('get') == true
        set(btnFusionPtr('get'), 'Enable', 'on');
    end

end
