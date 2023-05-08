function oneGate3D(sDirection)
%function oneGate3D(sDirection)
%Display 3D DICOM 4D Next Or Previous Gate.
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

    volObjBak = volObject('get');
    isoObjBak = isoObject('get');
    mipObjBak = mipObject('get');

    atInputTemplate = inputTemplate('get');
    
    if isFusion('get') == true
        dFuseOffset    = get(uiFusedSeriesPtr('get'), 'Value');
        atFuseMetaData = atInputTemplate(dFuseOffset).atDicomInfo;
    end

    volFusionObjBak  = volFusionObject('get');
    isoFusionObjBak  = isoFusionObject('get');
    mipFusionObjBak  = mipFusionObject('get');

    voiObjBak = voiObject('get');

    if size(dicomBuffer('get'), 3) == 1
        progressBar(1, 'Error: Require a 3D Volume!');
        return;
    end
    
    atVoi = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

    atInputTemplate = inputTemplate('get');

    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');
    if dSeriesOffset > numel(atInputTemplate) || ...
        numel(atInputTemplate) < 2 % Need a least 2 series
        return;
    end

    if ~isfield(atInputTemplate(dSeriesOffset).atDicomInfo{1}.din, 'frame') && ...
       gateUseSeriesUID('get') == true
        return
    end

    aInputBuffer  = inputBuffer('get');

    if strcmpi(sDirection, 'Foward')
        dOffset = dSeriesOffset+1;
        if gateUseSeriesUID('get') == true
            if dOffset > numel(atInputTemplate) || ... % End of list
               ~strcmpi(atInputTemplate(dSeriesOffset).atDicomInfo{1}.SeriesInstanceUID, ... % Not the same series
                        atInputTemplate(dOffset).atDicomInfo{1}.SeriesInstanceUID)
                for bb=1:numel(atInputTemplate)
                    if strcmpi(atInputTemplate(bb).atDicomInfo{1}.SeriesInstanceUID, ... % Try to find the first frame
                               atInputTemplate(dSeriesOffset).atDicomInfo{1}.SeriesInstanceUID)
                        dOffset = bb;
                        break;
                    end
                end
            end
        else
            if dOffset > numel(atInputTemplate)
                dOffset =1;
            end
        end
    else
        dOffset = dSeriesOffset-1;

        if gateUseSeriesUID('get') == true
            if dOffset == 0 || ... % The list start at 1
               ~strcmpi(atInputTemplate(dSeriesOffset).atDicomInfo{1}.SeriesInstanceUID, ... % Not the same series
                        atInputTemplate(dOffset).atDicomInfo{1}.SeriesInstanceUID)

                bOffsetFound = false;
                for bb=1:numel(atInputTemplate)
                    if strcmpi(atInputTemplate(bb).atDicomInfo{1}.SeriesInstanceUID, ... % Try to find the first frame
                               atInputTemplate(dSeriesOffset).atDicomInfo{1}.SeriesInstanceUID)
                        for cc=bb:numel(atInputTemplate) % Found the first frame
                            if cc >= numel(atInputTemplate) || ... % End of list
                               ~strcmpi(atInputTemplate(dSeriesOffset).atDicomInfo{1}.SeriesInstanceUID, ... % Try to find the last frame
                                        atInputTemplate(cc).atDicomInfo{1}.SeriesInstanceUID)
                                dOffset = cc;
                                bOffsetFound = true;
                                break;
                            end
                        end
                    end

                    if bOffsetFound == true
                        break
                    end

                end
            end
        else
            if dOffset == 0
                dOffset = numel(atInputTemplate);
            end
        end
    end
    
    if isempty( axePtr('get', [], dOffset) )
        axe = axePtr('get', [], dSeriesOffset);
        axePtr('set', axe, dOffset);
    end
       
    set(uiSeriesPtr('get'), 'Value', dOffset);
    
    atMetaData = dicomMetaData('get', [], dOffset);
    if isempty(atMetaData)
        atMetaData = atInputTemplate(dOffset).atDicomInfo;
        dicomMetaData('set', atMetaData, dOffset);
    end

    aBuffer = squeeze(dicomBuffer('get', [], dOffset));

    if isempty(aBuffer)
        aBuffer = aInputBuffer{dOffset};
%        if     strcmp(imageOrientation('get'), 'axial')
%            aBuffer = permute(aInputBuffer{dOffset}, [1 2 3]);
%        elseif strcmp(imageOrientation('get'), 'coronal')
%            aBuffer = permute(aInputBuffer{dOffset}, [3 2 1]);
%        elseif strcmp(imageOrientation('get'), 'sagittal')
%            aBuffer = permute(aInputBuffer{dOffset}, [3 1 2]);
%        end

        dicomBuffer('set', aBuffer, dOffset);
    end

    dicomMetaData('set', atInputTemplate(dOffset).atDicomInfo);

    cropValue('set', min(dicomBuffer('get', [], dOffset), [], 'all'));

    if switchTo3DMode('get') == true

        bLighting           = volObjBak.Lighting;
        aVolScaleFactors    = volObjBak.ScaleFactors;
        aVolBackgroundColor = volObjBak.BackgroundColor;
        aVolCameraPosition  = volObjBak.CameraPosition;
        aVolCameraUpVector  = volObjBak.CameraUpVector;
        aVolAlphamap        = volObjBak.Alphamap;
        aVolColormap        = volObjBak.Colormap;

        if isFusion('get') == true
            bFusionLighting    = volFusionObjBak.Lighting;
            aVolFusionAlphamap = volFusionObjBak.Alphamap;
            aVolFusionColormap = volFusionObjBak.Colormap;
        end
    end

    if switchToMIPMode('get') == true

        aMipScaleFactors    = mipObjBak.ScaleFactors;
        aMipBackgroundColor = mipObjBak.BackgroundColor;
        aMipCameraPosition  = mipObjBak.CameraPosition;
        aMipCameraUpVector  = mipObjBak.CameraUpVector;
        aMipAlphamap        = mipObjBak.Alphamap;
        aMipColormap        = mipObjBak.Colormap;

        if isFusion('get') == true
            aMipFusionAlphamap = mipFusionObjBak.Alphamap;
            aMipFusionColormap = mipFusionObjBak.Colormap;
        end
    end

    if switchToIsoSurface('get') == true

        aIsoScaleFactors    = isoObjBak.ScaleFactors;
        aIsoBackgroundColor = isoObjBak.BackgroundColor;
        aIsoCameraPosition  = isoObjBak.CameraPosition;
        aIsoCameraUpVector  = isoObjBak.CameraUpVector;
        aIsovalue           = isoObjBak.Isovalue;
        aIsosurfaceColor    = isoObjBak.IsosurfaceColor;

        if isFusion('get') == true
            aFusionIsovalue        = isoFusionObjBak.Isovalue;
            aFusionIsosurfaceColor = isoFusionObjBak.IsosurfaceColor;
        end
    end

    if switchTo3DMode('get') == true

        delete(volObjBak);
        volObject('set', '');

        if isFusion('get') == true
            delete(volFusionObjBak);
            volFusionObject('set', '');
        end
    end

    if switchToMIPMode('get') == true

        delete(mipObjBak);
        mipObject('set', '');

        if isFusion('get') == true
            delete(mipFusionObjBak);
            mipFusionObject('set', '');
        end
    end

    if switchToIsoSurface('get') == true
        delete(isoObjBak);
        isoObject('set', '');
        if isFusion('get') == true
            delete(isoFusionObjBak);
            isoFusionObject('set', '');
        end
    end

    if ~isempty(voiObjBak)
        for ll=1:numel(voiObjBak)
            delete(voiObjBak{ll});
        end

%        voiTemplate('set', '');
        voiObject  ('set', '');
    end

    clearDisplay();
    initDisplay(1);

    init3DPanel('set', true);

    for dPriorityLoop=1:3
        if switchToMIPMode('get') == true
            dPriority = surface3DPriority('get', 'MaximumIntensityProjection');
            if dPriority == dPriorityLoop

                mipObj = initVolShow(aBuffer, uiOneWindowPtr('get'), 'MaximumIntensityProjection', atMetaData);
                if isFusion('get') == true
                    mipFusionObj = initVolShow(squeeze(fusionBuffer('get', [], dFuseOffset)), uiOneWindowPtr('get'), 'MaximumIntensityProjection', atFuseMetaData);
                end
            end
        end

        if switchToIsoSurface('get') == true
            dPriority = surface3DPriority('get', 'Isosurface');
            if dPriority == dPriorityLoop
                isoObj = initVolShow(aBuffer, uiOneWindowPtr('get'), 'Isosurface', atMetaData);
                if isFusion('get') == true
                    isoFusionObj = initVolShow(squeeze(fusionBuffer('get', [], dFuseOffset)), uiOneWindowPtr('get'), 'Isosurface', atFuseMetaData);
                end
            end
        end

        if switchTo3DMode('get') == true
            dPriority = surface3DPriority('get', 'VolumeRendering');
            if dPriority == dPriorityLoop
                volObj = initVolShow(aBuffer, uiOneWindowPtr('get'), 'VolumeRendering', atMetaData);
                if isFusion('get') == true
                    volFusionObj = initVolShow(squeeze(fusionBuffer('get', [], dFuseOffset)), uiOneWindowPtr('get'), 'VolumeRendering', atFuseMetaData);
                end
            end
        end
    end

    if switchTo3DMode('get') == true
        volObj.Lighting        = bLighting;
        volObj.ScaleFactors    = aVolScaleFactors;
        volObj.BackgroundColor = aVolBackgroundColor;
        volObj.CameraPosition  = aVolCameraPosition;
        volObj.CameraUpVector  = aVolCameraUpVector;
        volObj.Alphamap        = aVolAlphamap;
        volObj.Colormap        = aVolColormap;

        volObject('set', volObj);

        if isFusion('get') == true
            volFusionObj.Lighting        = bFusionLighting;
            volFusionObj.ScaleFactors    = aVolScaleFactors;
            volFusionObj.BackgroundColor = aVolBackgroundColor;
            volFusionObj.CameraPosition  = aVolCameraPosition;
            volFusionObj.CameraUpVector  = aVolCameraUpVector;
            volFusionObj.Alphamap        = aVolFusionAlphamap;
            volFusionObj.Colormap        = aVolFusionColormap;

            volFusionObject('set', volFusionObj);
        end

        volIc = volICObject('get');
        if ~isempty(volIc)
            if isFusion('get') == true && ...
               get(ui3DVolumePtr('get'), 'Value') == 2 % Fusion
                volIc.surfObj = volFusionObj;
            else
                volIc.surfObj = volObj;
            end
        end

        if displayVolColorMap('get') == true
            uivolColorbar = volColorbar(uiOneWindowPtr('get'), aVolColormap);
            volColorObject('set', uivolColorbar);
        end
    end

    if switchToMIPMode('get') == true

        mipObj.ScaleFactors    = aMipScaleFactors;
        mipObj.BackgroundColor = aMipBackgroundColor;
        mipObj.CameraPosition  = aMipCameraPosition;
        mipObj.CameraUpVector  = aMipCameraUpVector;
        mipObj.Alphamap        = aMipAlphamap;
        mipObj.Colormap        = aMipColormap;

        mipObject('set', mipObj);

        if isFusion('get') == true
            mipFusionObj.ScaleFactors    = aMipScaleFactors;
            mipFusionObj.BackgroundColor = aMipBackgroundColor;
            mipFusionObj.CameraPosition  = aMipCameraPosition;
            mipFusionObj.CameraUpVector  = aMipCameraUpVector;
            mipFusionObj.Alphamap        = aMipFusionAlphamap;
            mipFusionObj.Colormap        = aMipFusionColormap;

            mipFusionObject('set', mipFusionObj);
        end


        mipIc = mipICObject('get');
        if ~isempty(mipIc)
            if isFusion('get') == true && ...
               get(ui3DVolumePtr('get'), 'Value') == 2 % Fusion
                mipIc.surfObj = mipFusionObj;
            else
                mipIc.surfObj = mipObj;
            end
        end

        if displayMIPColorMap('get') == true && ...
            switchToMIPMode('get') == true
            uimipColorbar = mipColorbar(uiOneWindowPtr('get'), aMipAlphamap);
            mipColorObject('set', uimipColorbar);
        end
    end

    if switchToIsoSurface('get') == true

        isoObj.ScaleFactors    = aIsoScaleFactors;
        isoObj.BackgroundColor = aIsoBackgroundColor;
        isoObj.CameraPosition  = aIsoCameraPosition;
        isoObj.CameraUpVector  = aIsoCameraUpVector;
        isoObj.Isovalue        = aIsovalue;
        isoObj.IsosurfaceColor = aIsosurfaceColor;

        isoObject('set', isoObj);

        if isFusion('get') == true
            isoFusionObj.ScaleFactors    = aIsoScaleFactors;
            isoFusionObj.BackgroundColor = aIsoBackgroundColor;
            isoFusionObj.CameraPosition  = aIsoCameraPosition;
            isoFusionObj.CameraUpVector  = aIsoCameraUpVector;
            isoFusionObj.Isovalue        = aFusionIsovalue;
            isoFusionObj.IsosurfaceColor = aFusionIsosurfaceColor;

            isoFusionObject('set', isoFusionObj);
        end
    end

    if ~isempty(atVoi)
        
        voiObj = initVoiIsoSurface(uiOneWindowPtr('get'), voi3DSmooth('get'));

        if ~isempty(voiObj)
            for ll=1:numel(voiObj)
                if displayVoi('get') == true
                    set(voiObj{ll}, 'Renderer', 'Isosurface');
                else
                    set(voiObj{ll}, 'Renderer', 'LabelOverlayRendering');
               end
            end
        end

        voiObject  ('set', voiObj);
    end

    uiLogo = displayLogo(uiOneWindowPtr('get'));
    logoObject('set', uiLogo);

end
