function recordMultiGate3D(mRecord, sPath, sFileName, sExtention)
%function recordMultiGate3D(mRecord, sPath, sFileName, sExtention)
%Record 3D DICOM 4D Images.
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

    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

    if size(dicomBuffer('get', [], dSeriesOffset), 3) == 1
        progressBar(1, 'Error: Require a 3D Volume!');
        multiFrame3DRecord('set', false);
        mRecord.State = 'off';
        return;
    end
    

    atVoi = voiTemplate('get', dSeriesOffset);

    volGateObj = volGateObject('get');
    isoGateObj = isoGateObject('get');
    mipGateObj = mipGateObject('get');
    voiGateObj = voiGateObject('get');

    volIc = volICObject('get');
    mipIc = mipICObject('get');
    volFusionIc = volICFusionObject('get');
    mipFusionIc = mipICFusionObject('get');

    volObjBak  = volObject('get');
    isoObjBak  = isoObject('get');
    mipObjBak  = mipObject('get');
    
    aInputBuffer  = inputBuffer('get');

    atInputTemplate = inputTemplate('get');
    
    if isFusion('get') == true

        dFuseOffset    = get(uiFusedSeriesPtr('get'), 'Value');
        atFuseMetaData = atInputTemplate(dFuseOffset).atDicomInfo;
    end

    volGateFusionObj = volGateFusionObject('get');
    isoGateFusionObj = isoGateFusionObject('get');
    mipGateFusionObj = mipGateFusionObject('get');

    volFusionObjBak  = volFusionObject('get');
    isoFusionObjBak  = isoFusionObject('get');
    mipFusionObjBak  = mipFusionObject('get');

    voiObjBak = voiObject('get');

    if dSeriesOffset > numel(atInputTemplate) || ...
       numel(atInputTemplate) < 2 % Need a least 2 series

        progressBar(1, 'Error: Require at least two 3D Volume!');
        multiFrame3DRecord('set', false);
        mRecord.State = 'off';
        return;
    end

    % if ~isfield(atInputTemplate(dSeriesOffset).atDicomInfo{1}.din, 'frame') && ...
    %    gateUseSeriesUID('get') == true
    % 
    %     progressBar(1, 'Error: Require a dynamic 3D Volume!');
    %     multiFrame3DRecord('set', false);
    %     mRecord.State = 'off';
    %     return;
    % end

    setFigureToobarsVisible('off');

    setFigureTopMenuVisible('off');

    atMetaData = dicomMetaData('get', [], dSeriesOffset);

    if strcmpi('*.dcm', sExtention) || ...
       strcmpi('dcm'  , sExtention)
        
        if isfield(atMetaData{1}, 'SeriesDescription')
            sSeriesDescription = atMetaData{1}.SeriesDescription;
        else
            sSeriesDescription = '';
        end

        sSeriesDescription = getViewerSeriesDescriptionDialog(sprintf('MFSC-%s', sSeriesDescription));

        if isempty(sSeriesDescription)
            return;
        end
    end

    if gateUseSeriesUID('get') == true

        dOffset = dSeriesOffset;

        for idx=1: numel(atInputTemplate)

            dOffset = dOffset+1;

            if dOffset > numel(atInputTemplate) || ... % End of list
               ~strcmpi(atInputTemplate(dOffset).atDicomInfo{1}.SeriesInstanceUID, ... % Not the same series
                        atInputTemplate(dOffset-1).atDicomInfo{1}.SeriesInstanceUID)

                for bb=1:numel(atInputTemplate)

                    if strcmpi(atInputTemplate(bb).atDicomInfo{1}.SeriesInstanceUID, ... % Try to find the first frame
                        atInputTemplate(dOffset-1).atDicomInfo{1}.SeriesInstanceUID)

                        dOffset = bb;
                        break;
                    end

                end
            end

            if dOffset == dSeriesOffset

                dNbSeries = idx;
                break
            end
        end
    else
        dNbSeries = numel(atInputTemplate);
    end

    set(btn3DPtr('get')        , 'Enable', 'off');
    set(btnIsoSurfacePtr('get'), 'Enable', 'off');
    set(btnMIPPtr('get')       , 'Enable', 'off');

    if isFusion('get') == true

        set(btnFusionPtr ('get')   , 'Enable', 'off');
        set(btnLinkMipPtr('get')   , 'Enable', 'off');
        set(uiFusedSeriesPtr('get'), 'Enable', 'off');
    end

    set(uiOneWindowPtr('get'), 'Visible', 'off');

    if ~isempty(viewer3dObject('get'))

        if switchToMIPMode('get') == true

            set(mipObjBak, 'Visible', 'off'); 
        end

        if switchToIsoSurface('get') == true

            set(isoObjBak, 'Visible', 'off');
        end

        if switchTo3DMode('get') == true

            set(volObjBak, 'Visible', 'off');
        end

        if (isempty(volGateObj) && switchTo3DMode('get')     == true) || ...
           (isempty(isoGateObj) && switchToIsoSurface('get') == true) || ...
           (isempty(mipGateObj) && switchToMIPMode('get')    == true)

            mipObj  = cell(dNbSeries, 1);
            isoObj  = cell(dNbSeries, 1);
            volObj  = cell(dNbSeries, 1);

            dOffset = dSeriesOffset;

            for tt=1:dNbSeries

                set(uiSeriesPtr('get'), 'Value', dOffset);
                
                atMetaData = dicomMetaData('get', [], dOffset);
                if isempty(atMetaData)
        
                    atMetaData = atInputTemplate(dOffset).atDicomInfo;
                    dicomMetaData('set', atMetaData, dOffset);
                end
        
                aBuffer = squeeze(dicomBuffer('get', [], dOffset));
    
                if isempty(aBuffer)
    
                    aInputBuffer  = inputBuffer('get');
        
                    aBuffer = aInputBuffer{dOffset};
    
                    clear aInputBuffer;
    
                    if     strcmpi(imageOrientation('get'), 'axial')
        %                 aImage = aImage;
                    elseif strcmpi(imageOrientation('get'), 'coronal')
        
                        aBuffer = reorientBuffer(aBuffer, 'coronal');
        
                        atInputTemplate(dOffset).sOrientationView = 'coronal';
                    
                        inputTemplate('set', atInputTemplate);
        
                    elseif strcmpi(imageOrientation('get'), 'sagittal')
        
                        aBuffer = reorientBuffer(aBuffer, 'sagittal');
        
                        atInputTemplate(dOffset).sOrientationView = 'sagittal';
                    
                        inputTemplate('set', atInputTemplate);
                    end
        
                    dicomBuffer('set', aBuffer, dOffset);
                end
    
                aBuffer = aBuffer(:,:, end:-1:1);

                for dPriorityLoop=1:3
        
                    if switchToMIPMode('get') == true
        
                        dPriority = surface3DPriority('get', 'MaximumIntensityProjection');
        
                        if isempty(mipGateObj)&&(dPriority == dPriorityLoop)
    
                            mipObj{tt} = volshow(squeeze(aBuffer), ...
                                                 'Parent'        , viewer3dObject('get'), ...
                                                 'RenderingStyle', 'MaximumIntensityProjection',...
                                                 'Alphamap'      , get(mipObjBak, 'Alphamap'), ...
                                                 'Colormap'      , get(mipObjBak, 'Colormap'), ...
                                                 'Visible'       , 'off', ...
                                                 'Transformation', get(mipObjBak, 'Transformation')); 

                            mipGateObject('set', mipObj);
                        end   
                    end
        
                    if switchToIsoSurface('get') == true
        
                        dPriority = surface3DPriority('get', 'Isosurface');
        
                        if isempty(isoGateObj) &&(dPriority == dPriorityLoop)
    
                            isoObj{tt} = volshow(squeeze(aBuffer), ...
                                                 'Parent'         , viewer3dObject('get'), ...
                                                 'RenderingStyle' , 'Isosurface',...
                                                 'Alphamap'       , get(isoObjBak, 'Alphamap'), ...
                                                 'Colormap'       , get(isoObjBak, 'Colormap'), ...
                                                 'IsosurfaceValue', get(isoObjBak, 'IsosurfaceValue'), ...                                 
                                                 'Visible'        , 'off', ...
                                                 'Transformation' , get(isoObjBak, 'Transformation'));  

                            isoGateObject('set', isoObj);
                        end
                    end
        
                    if switchTo3DMode('get') == true
        
                        dPriority = surface3DPriority('get', 'VolumeRendering');
        
                        if isempty(volGateObj) &&(dPriority == dPriorityLoop)
        
                            volObj{tt} = volshow(squeeze(aBuffer), ...
                                                 'Parent'        , viewer3dObject('get'), ...
                                                 'RenderingStyle', 'VolumeRendering',...
                                                 'Alphamap'      , get(volObjBak, 'Alphamap'), ...
                                                 'Colormap'      , get(volObjBak, 'Colormap'), ...
                                                 'Visible'       , 'off', ...
                                                 'Transformation', get(volObjBak, 'Transformation'));  

                            volGateObject('set', volObj);
                          
                        end
                    end
                end
   
                dOffset = dOffset+1;

                if gateUseSeriesUID('get') == true
        
                    if dOffset > numel(atInputTemplate) || ... % End of list
                       ~strcmpi(atInputTemplate(dOffset).atDicomInfo{1}.SeriesInstanceUID, ... % Not the same series
                                atInputTemplate(dOffset-1).atDicomInfo{1}.SeriesInstanceUID)
        
                        for bb=1:numel(atInputTemplate)
        
                            if strcmpi(atInputTemplate(bb).atDicomInfo{1}.SeriesInstanceUID, ... % Try to find the first frame
                                atInputTemplate(dOffset-1).atDicomInfo{1}.SeriesInstanceUID)
        
                                dOffset = bb;
                                break;
                            end
        
                        end
                    end
                else
                    if dOffset > numel(atInputTemplate)
        
                        dOffset = 1;
                    end
                end
        
                progressBar(tt / dNbSeries, sprintf('Initializing surface %d of %d.', tt, dNbSeries));            
            end 
        end

        set(uiOneWindowPtr('get'), 'Visible', 'on');

    else
    
        ui3DGateWindow = ui3DGateWindowObject('get');
    
        if isempty(ui3DGateWindow)
    
            ui3DWindow = cell(dNbSeries, 1);

            if showBorder('get') == true
                sBorderType = 'line';
            else
                sBorderType = 'none';
            end

            for tt=1:dNbSeries
    
                if view3DPanel('get') == false
    
                    ui3DWindow{tt} = uipanel(fiMainWindowPtr('get'),...
                                          'Units'   , 'pixels',...
                                          'BorderType'     , sBorderType, ...
                                          'BackgroundColor', surfaceColor('get', background3DOffset('get')),...
                                          'position', [0 ...
                                                       addOnWidth('get')+30 ...
                                                       getMainWindowSize('xsize')-280 ...
                                                       getMainWindowSize('ysize')-getTopWindowSize('ysize')-addOnWidth('get')-30]);
                else
                    ui3DWindow{tt} = uipanel(fiMainWindowPtr('get'),...
                                          'Units'   , 'pixels',...
                                          'BorderType'     , sBorderType, ...
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
    
        for tt=1:dNbSeries
    
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
    
        ui3DVolColorbar = cell(dNbSeries, 1);
    
        for tt=1:dNbSeries
    
            if displayVolColorMap('get') == true && switchTo3DMode('get') == true
               
                if isFusion('get') == true && get(ui3DVolumePtr('get'), 'Value') == 2 % Fusion
                   
                    ui3DVolColorbar{tt} = volColorbar(ui3DWindow{tt}, get3DColorMap('one', colorMapVolFusionOffset('get')));
                else
                    ui3DVolColorbar{tt} = volColorbar(ui3DWindow{tt}, get3DColorMap('one', colorMapVolOffset('get')));
                end
    
                volColorObject('set', ui3DVolColorbar{tt});
            end
        end
    
        if displayVolColorMap('get') == false || switchTo3DMode('get') == false
           
            ui3DVolColorbar = '';
            volColorObject('set', '');
        end
    
        ui3DMipColorbar = cell(dNbSeries, 1);
    
        for tt=1:dNbSeries
    
            if displayMIPColorMap('get') == true && switchToMIPMode('get') == true
               
                if isFusion('get') == true && get(ui3DVolumePtr('get'), 'Value') == 2 % Fusion
                   
                    ui3DMipColorbar{tt} = mipColorbar(ui3DWindow{tt}, get3DColorMap('one', colorMapMipFusionOffset('get')));
                else
                    ui3DMipColorbar{tt} = mipColorbar(ui3DWindow{tt}, get3DColorMap('one', colorMapMipOffset('get')));
                end
    
                mipColorObject('set', ui3DMipColorbar{tt});
            end
        end
    
        if displayMIPColorMap('get') == false || switchToMIPMode('get') == false
           
            ui3DMipColorbar = '';
            mipColorObject('set', '');
        end
    
    %    dNbSurface = 0;
    %    if switchToMIPMode('get') == true
    %        dNbSurface = dNbSurface+1;
    %    end
    
    %    if switchToIsoSurface('get') == true
    %        dNbSurface = dNbSurface+1;
    %    end
    
    %    if switchTo3DMode('get') == true
    %        dNbSurface = dNbSurface+1;
    %    end
    
        % Initialize 3D object 
    
        mipObj       = cell(dNbSeries, 1);
        mipFusionObj = cell(dNbSeries, 1);
        isoObj       = cell(dNbSeries, 1);
        isoFusionObj = cell(dNbSeries, 1);
        volObj       = cell(dNbSeries, 1);
        volFusionObj = cell(dNbSeries, 1);
        voiGate      = cell(dNbSeries, 1);
    
        dOffset = dSeriesOffset;
        for tt=1:dNbSeries
    
            set(uiSeriesPtr('get'), 'Value', dOffset);
            
            atMetaData = dicomMetaData('get', [], dOffset);
            if isempty(atMetaData)
    
                atMetaData = atInputTemplate(dOffset).atDicomInfo;
                dicomMetaData('set', atMetaData, dOffset);
            end
    
            aBuffer = squeeze(dicomBuffer('get', [], dOffset));
            
            if isempty(aBuffer)
    
                aBuffer = aInputBuffer{dOffset};
    
                if     strcmpi(imageOrientation('get'), 'axial')
    %                 aImage = aImage;
                elseif strcmpi(imageOrientation('get'), 'coronal')
    
                    aBuffer = reorientBuffer(aBuffer, 'coronal');
    
                    atInputTemplate(dOffset).sOrientationView = 'coronal';
                
                    inputTemplate('set', atInputTemplate);
    
                elseif strcmpi(imageOrientation('get'), 'sagittal')
    
                    aBuffer = reorientBuffer(aBuffer, 'sagittal');
    
                    atInputTemplate(dOffset).sOrientationView = 'sagittal';
                
                    inputTemplate('set', atInputTemplate);
    
                end
    
                dicomBuffer('set', aBuffer, dOffset);
            end
    
            for dPriorityLoop=1:3
    
                if switchToMIPMode('get') == true
    
                    dPriority = surface3DPriority('get', 'MaximumIntensityProjection');
    
                    if isempty(mipGateObj)&&(dPriority == dPriorityLoop)
    
                        mipObj{tt} = initVolShow(aBuffer, ui3DWindow{tt}, 'MaximumIntensityProjection', atMetaData);
    
                        if isFusion('get') == true
    
                            if isempty(mipGateFusionObj)
    
                                mipFusionObj{tt} = initVolShow(squeeze(fusionBuffer('get', [], dFuseOffset)), ui3DWindow{tt}, 'MaximumIntensityProjection', atFuseMetaData);
                            end
                        end
                    end
    
                end
    
                if switchToIsoSurface('get') == true
    
                    dPriority = surface3DPriority('get', 'Isosurface');
    
                    if isempty(isoGateObj) &&(dPriority == dPriorityLoop)
    
                        isoObj{tt} = initVolShow(aBuffer, ui3DWindow{tt}, 'Isosurface', atMetaData);
    
                        if isFusion('get') == true
    
                            if isempty(isoGateFusionObj)
    
                                isoFusionObj{tt} = initVolShow(squeeze(fusionBuffer('get', [], dFuseOffset)), ui3DWindow{tt}, 'Isosurface', atFuseMetaData);
                            end
                        end
                    end
                end
    
                if switchTo3DMode('get') == true
    
                    dPriority = surface3DPriority('get', 'VolumeRendering');
    
                    if isempty(volGateObj) &&(dPriority == dPriorityLoop)
    
                        volObj{tt} = initVolShow(aBuffer, ui3DWindow{tt}, 'VolumeRendering', atMetaData);
    
                        if isFusion('get') == true
    
                            if isempty(volGateFusionObj)
    
                                volFusionObj{tt} = initVolShow(fusionBuffer('get', [], dFuseOffset), ui3DWindow{tt}, 'VolumeRendering', atFuseMetaData);
                            end
                        end
                    end
                end
    
            end
    
            if isempty(voiGateObj)
    
                if ~isempty(atVoi)
    
                    voiGate{dOffset} = initVoiIsoSurface(ui3DWindow{tt}, voi3DSmooth('get'));
                else
                    voiGate{dOffset} = '';
                end
            end
    
            set(ui3DWindow{tt}, 'Visible', 'off');
    
            dOffset = dOffset+1;
    
            if gateUseSeriesUID('get') == true
    
                if dOffset > numel(atInputTemplate) || ... % End of list
                   ~strcmpi(atInputTemplate(dOffset).atDicomInfo{1}.SeriesInstanceUID, ... % Not the same series
                            atInputTemplate(dOffset-1).atDicomInfo{1}.SeriesInstanceUID)
    
                    for bb=1:numel(atInputTemplate)
    
                        if strcmpi(atInputTemplate(bb).atDicomInfo{1}.SeriesInstanceUID, ... % Try to find the first frame
                            atInputTemplate(dOffset-1).atDicomInfo{1}.SeriesInstanceUID)
                            dOffset = bb;
                            break;
                        end
    
                    end
                end
            else
                if dOffset > numel(atInputTemplate)
                    dOffset = 1;
                end
            end
    
            progressBar(tt / dNbSeries, 'Initializing surface', 'red');
    
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
    
            aScaleFactors = volObjBak.ScaleFactors;
            aBackgroundColor = volObjBak.BackgroundColor;
    
            aPosition = volObjBak.CameraPosition;
            aUpVector = volObjBak.CameraUpVector;
    
            aVolAlphamap = volObjBak.Alphamap;
            aVolColormap = volObjBak.Colormap;
    
            if isFusion('get') == true
    
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
    
                volObj{tt}.ScaleFactors = aScaleFactors;
                volObj{tt}.BackgroundColor = aBackgroundColor;
    
                volObj{tt}.CameraPosition = aPosition;
                volObj{tt}.CameraUpVector = aUpVector;
    
                volObj{tt}.Alphamap = aVolAlphamap;
                volObj{tt}.Colormap = aVolColormap;
    
                if isFusion('get') == true
    
                    volFusionObj{tt}.ScaleFactors = aScaleFactors;
                    volFusionObj{tt}.BackgroundColor = aBackgroundColor;
    
                    volFusionObj{tt}.CameraPosition = aPosition;
                    volFusionObj{tt}.CameraUpVector = aUpVector;
    
                    volFusionObj{tt}.Alphamap = aVolFusionAlphamap;
                    volFusionObj{tt}.Colormap = aVolFusionColormap;
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
    end

    progressBar(1, 'Ready');
    
    if strcmpi('*.avi', sExtention) || ...
       strcmpi('avi'  , sExtention) || ...     
       strcmpi('*.mp4', sExtention) || ...
       strcmpi('mp4'  , sExtention)
        
        if strcmpi('*.avi', sExtention)

            tClassVideoWriter = VideoWriter([sPath sFileName], 'Motion JPEG AVI');

        else
            tClassVideoWriter = VideoWriter([sPath sFileName],  'MPEG-4');
        end

        tClassVideoWriter.FrameRate = 1/multiFrame3DSpeed('get');
        tClassVideoWriter.Quality = 100;

        open(tClassVideoWriter);
    end

    try

    set(fiMainWindowPtr('get'), 'Pointer', 'watch');
    drawnow;

    for tt=1:dNbSeries
        
       if ~multiFrame3DRecord('get')
            break;
       end

       % hold(axePtr('get', [], tt), 'on');
       
       set(uiSeriesPtr('get'), 'Value', tt);
       
       atMetaData = dicomMetaData('get', [], tt);
       if isempty(atMetaData)

           atMetaData = atInputTemplate(tt).atDicomInfo;
           dicomMetaData('set', atMetaData, tt);
       end

       if isempty( axePtr('get', [], tt) )

           axe = axePtr('get', [], dSeriesOffset);
           axePtr('set', axe, tt);
        end 

        if ~isempty(viewer3dObject('get'))

            if switchToMIPMode('get') == true

                set(mipObj{tt}, 'Visible', 'on');
            end

            if switchToIsoSurface('get') == true

                 set(isoObj{tt}, 'Visible', 'on');
            end

            if switchTo3DMode('get') == true

                set(volObj{tt}, 'Visible', 'on'); 
            end
        else
            set(ui3DWindow{tt}, 'Visible', 'on');

        end
       
        I = getframe(axePtr('get', [], tt ));
        [indI,cm] = rgb2ind(I.cdata, 256);

        if tt == 1

            if strcmpi('*.avi', sExtention) || ...
               strcmpi('avi'  , sExtention) || ...
               strcmpi('*.mp4', sExtention) || ...
               strcmpi('mp4'  , sExtention)

                 writeVideo(tClassVideoWriter, I);

            elseif strcmpi('*.gif', sExtention) || ...
                   strcmpi('gif'  , sExtention) 

                imwrite(indI, cm, [sPath sFileName], 'gif', 'Loopcount', inf, 'DelayTime', multiFrame3DSpeed('get'));

            elseif strcmpi('*.jpg', sExtention) || ...
                   strcmpi('jpg'  , sExtention)

                sDirName = sprintf('%s_%s_%s_JPG_3D', atMetaData{1}.PatientName, atMetaData{1}.PatientID, datetime('now','Format','MMMM-d-y-hhmmss'));
                sImgDirName = [sPath sDirName '//'];

                if~(exist(char(sImgDirName), 'dir'))

                    mkdir(char(sImgDirName));
                end

                newName = erase(sFileName, '.jpg');
                newName = sprintf('%s-%d.jpg', newName, tt);
                imwrite(indI, cm, [sImgDirName newName], 'jpg');

            elseif strcmpi('*.bmp', sExtention) || ...
                   strcmpi('bmp'  , sExtention) 

                sDirName = sprintf('%s_%s_%s_BMP_3D', atMetaData{1}.PatientName, atMetaData{1}.PatientID, datetime('now','Format','MMMM-d-y-hhmmss'));
                sImgDirName = [sPath sDirName '//'];

                if~(exist(char(sImgDirName), 'dir'))

                    mkdir(char(sImgDirName));
                end

                newName = erase(sFileName, '.bmp');
                newName = sprintf('%s-%d.bmp', newName, tt);
                imwrite(indI, cm, [sImgDirName newName], 'bmp');

            elseif strcmpi('*.png', sExtention) || ...
                   strcmpi('png'  , sExtention) 

                sDirName = sprintf('%s_%s_%s_PNG_3D', atMetaData{1}.PatientName, atMetaData{1}.PatientID, datetime('now','Format','MMMM-d-y-hhmmss'));
                sImgDirName = [sPath sDirName '//'];

                if~(exist(char(sImgDirName), 'dir'))

                    mkdir(char(sImgDirName));
                end

                newName = erase(sFileName, '.png');
                newName = sprintf('%s-%d.png', newName, tt);
                imwrite(indI, cm, [sImgDirName newName], 'png');    

             elseif strcmpi('*.dcm', sExtention) || ...
                    strcmpi('dcm'  , sExtention)

                sDcmDirName = outputDir('get');

                if isempty(sDcmDirName)

                    sDirName = sprintf('%s_%s_%s_DCM_3D', atMetaData{1}.PatientName, atMetaData{1}.PatientID, datetime('now','Format','MMMM-d-y-hhmmss'));
                    sDirName = cleanString(sDirName);
                    sDcmDirName = [sPath sDirName '//'];
    
                    if~(exist(char(sDcmDirName), 'dir'))

                        mkdir(char(sDcmDirName));
                    end
                end

                cSeriesInstanceUID = dicomuid;

                sOutFile = fullfile(sDcmDirName, sprintf('frame%d.dcm', tt));

                objectToDicomMultiFrame(sOutFile, axePtr('get', [], tt), sSeriesDescription, cSeriesInstanceUID, tt, dNbSeries, tt);               
            end
        else
             if strcmpi('*.avi', sExtention) || ...
                strcmpi('avi'  , sExtention) || ...
                strcmpi('*.mp4', sExtention) || ...
                strcmpi('mp4'  , sExtention)

                 writeVideo(tClassVideoWriter, I);

             elseif strcmpi('*.gif', sExtention) || ...
                    strcmpi('gif'  , sExtention)

                imwrite(indI, cm, [sPath sFileName], 'gif', 'WriteMode', 'append', 'DelayTime', multiFrame3DSpeed('get'));

            elseif strcmpi('*.jpg', sExtention) || ...  
                   strcmpi('jpg'  , sExtention)  

                newName = erase(sFileName, '.jpg');
                newName = sprintf('%s-%d.jpg', newName, tt);
                imwrite(indI, cm, [sImgDirName newName], 'jpg');

            elseif strcmpi('*.bmp', sExtention) || ...
                   strcmpi('bmp'  , sExtention)

                newName = erase(sFileName, '.bmp');
                newName = sprintf('%s-%d.bmp', newName, tt);
                imwrite(indI, cm, [sImgDirName newName], 'bmp');

            elseif strcmpi('*.png', sExtention) || ...
                   strcmpi('png'  , sExtention)

                newName = erase(sFileName, '.png');
                newName = sprintf('%s-%d.png', newName, tt);
                imwrite(indI, cm, [sImgDirName newName], 'png');   

              elseif strcmpi('*.dcm', sExtention) || ...
                     strcmpi('dcm'  , sExtention)

                 sOutFile = fullfile(sDcmDirName, sprintf('frame%d.dcm', tt));

                 objectToDicomMultiFrame(sOutFile, axePtr('get', [], tt), sSeriesDescription, cSeriesInstanceUID, tt, dNbSeries, tt);
            end
        end

        if ~isempty(viewer3dObject('get'))

            if switchToMIPMode('get') == true

                set(mipObj{tt}, 'Visible', 'off');
            end

            if switchToIsoSurface('get') == true

                 set(isoObj{tt}, 'Visible', 'off');
            end

            if switchTo3DMode('get') == true

                set(volObj{tt}, 'Visible', 'off'); 
            end

        else
            set(ui3DWindow{tt}, 'Visible', 'off');
        end

        progressBar(tt / dNbSeries, 'Recording', 'red');

    end

    if strcmpi('*.avi', sExtention) || ...
       strcmpi('avi'  , sExtention) || ...     
       strcmpi('*.mp4', sExtention) || ...
       strcmpi('mp4'  , sExtention)

        close(tClassVideoWriter);
    end

    if ~isempty(viewer3dObject('get'))

        if switchToMIPMode('get') == true

            set(mipObjBak, 'Visible', 'on'); 
        end

        if switchToIsoSurface('get') == true

            set(isoObjBak, 'Visible', 'on');
        end

        if switchTo3DMode('get') == true

            set(volObjBak, 'Visible', 'on');
        end
    else

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
    
        for tt=1:numel(ui3DWindow)
    
            set(ui3DWindow{tt}, 'Visible', 'off');
        end
    
        if switchTo3DMode('get') == true
    
            volObjBak.ScaleFactors    = aScaleFactors;
            volObjBak.BackgroundColor = aBackgroundColor;
            volObjBak.CameraPosition  = aPosition;
            volObjBak.CameraUpVector  = aUpVector;
            volObjBak.CameraViewAngle = dCameraViewAngle;
            volObjBak.Alphamap        = aVolAlphamap;
            volObjBak.Colormap        = aVolColormap;
    
            volObject('set', volObjBak);
    
            if isFusion('get') == true
    
                volFusionObjBak.ScaleFactors    = aScaleFactors;
                volFusionObjBak.BackgroundColor = aBackgroundColor;
                volFusionObjBak.CameraPosition  = aPosition;
                volFusionObjBak.CameraUpVector  = aUpVector;
                volFusionObjBak.CameraViewAngle = dCameraViewAngle;
                volFusionObjBak.Alphamap        = aVolFusionAlphamap;
                volFusionObjBak.Colormap        = aVolFusionColormap;
    
                volFusionObject('set', volFusionObjBak);
            end
    
            if ~isempty(volIc)
    
                volIc.surfObj = volObjBak;
                volICObject('set', volIc);
            end
    
            if ~isempty(volFusionIc)
    
                volFusionIc.surfObj = volFusionObjBak;
                volICFusionObject('set', volFusionIc);
            end
    
        end
    
        if switchToMIPMode('get') == true
    
            mipObjBak.ScaleFactors    = aScaleFactors;
            mipObjBak.BackgroundColor = aBackgroundColor;
            mipObjBak.CameraPosition  = aPosition;
            mipObjBak.CameraUpVector  = aUpVector;
            mipObjBak.CameraViewAngle = dCameraViewAngle;
            mipObjBak.Alphamap        = aMipAlphamap;
            mipObjBak.Colormap        = aMipColormap;
    
            if isFusion('get') == true
    
                mipFusionObjBak.ScaleFactors    = aScaleFactors;
                mipFusionObjBak.BackgroundColor = aBackgroundColor;
                mipFusionObjBak.CameraPosition  = aPosition;
                mipFusionObjBak.CameraUpVector  = aUpVector;
                mipFusionObjBak.CameraViewAngle = dCameraViewAngle;
                mipFusionObjBak.Alphamap        = aMipFusionAlphamap;
                mipFusionObjBak.Colormap        = aMipFusionColormap;
    
                mipFusionObject('set', mipFusionObjBak);
            end
    
            mipObject('set', mipObjBak);
    
            if ~isempty(mipIc)
    
                mipIc.surfObj = mipObjBak;
                mipICObject('set', mipIc);
            end
    
            if ~isempty(mipFusionIc)
    
                mipFusionIc.surfObj = mipFusionObjBak;
                mipICFusionObject('set', mipFusionIc);
            end
    
        end
    
        if switchToIsoSurface('get') == true
    
            isoObjBak.ScaleFactors    = aScaleFactors;
            isoObjBak.BackgroundColor = aBackgroundColor;
            isoObjBak.CameraPosition  = aPosition;
            isoObjBak.CameraUpVector  = aUpVector;
            isoObjBak.CameraViewAngle = dCameraViewAngle;
            isoObjBak.Isovalue        = aIsovalue;
            isoObjBak.IsosurfaceColor = aIsosurfaceColor;
    
            isoObject('set', isoObjBak);
    
            if isFusion('get') == true
    
                isoFusionObjBak.ScaleFactors    = aScaleFactors;
                isoFusionObjBak.BackgroundColor = aBackgroundColor;
                isoFusionObjBak.CameraPosition  = aPosition;
                isoFusionObjBak.CameraUpVector  = aUpVector;
                isoFusionObjBak.CameraViewAngle = dCameraViewAngle;
                isoFusionObjBak.Isovalue        = aFusionIsovalue;
                isoFusionObjBak.IsosurfaceColor = aFusionIsosurfaceColor;
    
                isoFusionObject('set', isoFusionObjBak);
            end
        end
    
        if displayVolColorMap('get') == true && switchTo3DMode('get') == true
           
            if isFusion('get') == true && get(ui3DVolumePtr('get'), 'Value') == 2 % Fusion
               
                uivolColorbar = volColorbar(uiOneWindowPtr('get'), get3DColorMap('one', colorMapVolFusionOffset('get')) );
            else
                uivolColorbar = volColorbar(uiOneWindowPtr('get'), get3DColorMap('one', colorMapVolOffset('get')) );
            end
    
            volColorObject('set', uivolColorbar);
        end
    
        if displayMIPColorMap('get') == true && switchToMIPMode('get') == true
            
            if isFusion('get') == true && get(ui3DVolumePtr('get'), 'Value') == 2 % Fusion
               
                uimipColorbar = mipColorbar(uiOneWindowPtr('get'), get3DColorMap('one', colorMapMipFusionOffset('get')));
            else
                uimipColorbar = mipColorbar(uiOneWindowPtr('get'), get3DColorMap('one', colorMapMipOffset('get')));
            end
    
            mipColorObject('set', uimipColorbar);
        end
    
    
        if ~isempty(voiObjBak)
    
            for ll=1:numel(voiObjBak)
    
                set(voiObjBak{ll}, 'CameraPosition', aPosition);
                set(voiObjBak{ll}, 'CameraUpVector', aUpVector);
                set(voiObjBak{ll}, 'BackgroundColor',aBackgroundColor);
            end
    
            voiObject  ('set', voiObjBak);
    
        end
    end

    set(uiOneWindowPtr('get'), 'Visible', 'on');

%        dicomBuffer('set', aBackup);

    set(uiSeriesPtr('get'), 'Value', dSeriesOffset);

    cropValue('set', min(dicomBuffer('get', [], dSeriesOffset), [], 'all'));

    set(btn3DPtr('get')        , 'Enable', 'on');
    set(btnIsoSurfacePtr('get'), 'Enable', 'on');
    set(btnMIPPtr('get')       , 'Enable', 'on');

    if isFusion('get') == true

        set(btnFusionPtr ('get')   , 'Enable', 'on');
        set(btnLinkMipPtr('get')   , 'Enable', 'on');
        set(uiFusedSeriesPtr('get'), 'Enable', 'on');
    end

    if strcmpi('*.avi', sExtention) || ...
       strcmpi('avi'  , sExtention) || ...
       strcmpi('*.mp4', sExtention) || ...
       strcmpi('mp4'  , sExtention) || ...
       strcmpi('*.gif', sExtention) || ...
       strcmpi('gif'  , sExtention)

        progressBar(1, sprintf('Write %s completed', [sPath sFileName]));

    elseif strcmpi('*.jpg', sExtention) || ...
           strcmpi('jpg'  , sExtention) || ...
           strcmpi('*.bmp', sExtention) || ...
           strcmpi('bmp'  , sExtention) || ...
           strcmpi('*.png', sExtention) || ...
           strcmpi('png'  , sExtention)  

        progressBar(1, sprintf('Write %d files to %s completed', dNbSeries, sImgDirName));

    elseif strcmpi('*.dcm', sExtention) || ...
           strcmpi('dcm'  , sExtention)

        progressBar(1, sprintf('Write %d files to %s completed', dNbSeries, sDcmDirName));
        
    end  

    catch
        progressBar(1, sprintf('Error: recordMultiGate3D()'));
    end

    setFigureToobarsVisible('on');

    setFigureTopMenuVisible('on');

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow;    
end
