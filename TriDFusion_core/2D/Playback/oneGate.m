function oneGate(sDirection)
%function oneGate(sDirection)
%Dispay 2D DICOM 4D Images Previous or Next Gate.
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

    aCurrentBuffer = dicomBuffer('get', [], dSeriesOffset);
    if size(aCurrentBuffer, 3) == 1
        progressBar(1, 'Error: Require a 3D Volume!');
        set(uiSeriesPtr('get'), 'Enable', 'on');
        return;
    end

    atInputTemplate = inputTemplate('get');

    if dSeriesOffset > numel(atInputTemplate) || ...
        numel(atInputTemplate) < 2 % Need a least 2 series
        set(uiSeriesPtr('get'), 'Enable', 'on');
        return;
    end

%     if ~isfield(atInputTemplate(dSeriesOffset).atDicomInfo{1}.din, 'frame') && ...
%        gateUseSeriesUID('get') == true
%         set(uiSeriesPtr('get'), 'Enable', 'on');
%         return
%     end

    tRefreshRoi = roiTemplate('get', dSeriesOffset);
    if ~isempty(tRefreshRoi)
        for bb=1:numel(tRefreshRoi)
            if isvalid(tRefreshRoi{bb}.Object)
                tRefreshRoi{bb}.Object.Visible = 'off';
            end
        end
    end

    set(uiSeriesPtr('get'), 'Enable', 'off');

    aInput = inputBuffer('get');

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

                                dOffset = cc-1;
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

    % Get current Axes

    axes1 = axes1Ptr('get', [], dSeriesOffset);
    axes2 = axes2Ptr('get', [], dSeriesOffset);
    axes3 = axes3Ptr('get', [], dSeriesOffset);

    if isVsplash('get') == false
        axesMip = axesMipPtr('get', [], dSeriesOffset);
    end

    % Get current CData

    imCoronal  = imCoronalPtr ('get', [], dSeriesOffset);
    imSagittal = imSagittalPtr('get', [], dSeriesOffset);
    imAxial    = imAxialPtr   ('get', [], dSeriesOffset);

    if isVsplash('get') == false
        imMip = imMipPtr('get', [], dSeriesOffset);
    end

    % Set new serie offset

    set(uiSeriesPtr('get'), 'Value', dOffset);

    % Set new Axes

    if isempty(axes1Ptr('get', [], dOffset))
        axes1Ptr('set', axes1, dOffset);
    end

    if isempty(axes2Ptr('get', [], dOffset))
        axes2Ptr('set', axes2, dOffset);
    end

    if isempty(axes3Ptr('get', [], dOffset))
        axes3Ptr('set', axes3, dOffset);
    end

    if isVsplash('get') == false
        if isempty(axesMipPtr('get', [], dOffset))
            axesMipPtr('set', axesMip, dOffset);
        end
    end

    % Set new CData

    if isempty(imCoronalPtr('get', [], dOffset))
        imCoronalPtr('set', imCoronal, dOffset);
    end

    if isempty(imSagittalPtr('get', [], dOffset))
        imSagittalPtr('set', imSagittal, dOffset);
    end

    if isempty(imAxialPtr('get', [], dOffset))
        imAxialPtr('set', imAxial, dOffset);
    end

    if isVsplash('get') == false
        if isempty(imMipPtr('get', [], dOffset))
            imMipPtr('set', imMip, dOffset);
        end
    end

    aBuffer = dicomBuffer('get', [], dOffset);
    
    if isempty(aBuffer)

        aBuffer = aInput{dOffset};

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

    if size(aCurrentBuffer) ~= size(aBuffer)

        set(uiSeriesPtr('get'), 'Value', dSeriesOffset);
        set(uiSeriesPtr('get'), 'Enable', 'on');
        progressBar(1, 'Error: Resample or Register the series fail!');
        return;
    end

    atCoreMetaData = dicomMetaData('get', [], dOffset);
    if isempty(atCoreMetaData)

        atCoreMetaData = atInputTemplate(dOffset).atDicomInfo;
        dicomMetaData('set', atCoreMetaData, dOffset);
    end

    if gateUseSeriesUID('get') == false && ...
       gateLookupTable('get')  == true

        if strcmpi(atCoreMetaData{1}.Modality, 'ct')
            if min(aBuffer, [], 'all') >= 0
                lMin = min(aBuffer, [], 'all');
                lMax = max(aBuffer, [], 'all');
            else
                [lMax, lMin] = computeWindowLevel(500, 50);
            end
        else
            if strcmpi(gateLookupType('get'), 'Relative')

                sUnitDisplay = getSerieUnitValue(dOffset);

                if strcmpi(sUnitDisplay, 'SUV')
                    tQuant = quantificationTemplate('get');
                    if tQuant.tSUV.dScale
                        lMin = suvWindowLevel('get', 'min')/tQuant.tSUV.dScale;
                        lMax = suvWindowLevel('get', 'max')/tQuant.tSUV.dScale;
                    else
                        lMin = min(aBuffer, [], 'all');
                        lMax = max(aBuffer, [], 'all');
                    end
                else
                    lMin = min(aBuffer, [], 'all');
                    lMax = max(aBuffer, [], 'all');
                end
            else
                for jj=1:numel(aInput)
%                    set(uiSeriesPtr('get'), 'Value', jj);
                    aBuffer = dicomBuffer('get', [], jj);
                    if isempty(aBuffer)

                        aBuffer = aInput{jj};
        
                        if     strcmpi(imageOrientation('get'), 'axial')
            %                 aImage = aImage;
                        elseif strcmpi(imageOrientation('get'), 'coronal')
            
                            aBuffer = reorientBuffer(aBuffer, 'coronal');
            
                            atInputTemplate(jj).sOrientationView = 'coronal';
                        
                            inputTemplate('set', atInputTemplate);
            
                        elseif strcmpi(imageOrientation('get'), 'sagittal')
            
                            aBuffer = reorientBuffer(aBuffer, 'sagittal');
            
                            atInputTemplate(jj).sOrientationView = 'sagittal';
                        
                            inputTemplate('set', atInputTemplate);
                        end

                        dicomBuffer('set', aBuffer, jj);
                    end

                    if jj == 1
                        lMin = min(aBuffer, [], 'all');
                        lMax = max(aBuffer, [], 'all');
                    else
                        lBufferMin = min(aBuffer, [], 'all');
                        lBufferMax = max(aBuffer, [], 'all');

                        if lBufferMin < lMin

                            lMin = lBufferMin;
                        end

                        if lBufferMax > lMax

                            lMax = lBufferMax;
                        end
                    end
                end

%                set(uiSeriesPtr('get'), 'Value', dOffset);

            end
        end

        setWindowMinMax(lMax, lMin);
    end

    aBuffer = dicomBuffer('get', [], dOffset);
    if isempty(aBuffer)

        aBuffer = aInput{dOffset};

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

    cropValue('set', min(dicomBuffer('get', [], dOffset), [], 'all'));

if 1
     if gateUseSeriesUID('get') == false

        if aspectRatio('get') == true

            atCoreMetaData = dicomMetaData('get', [], dOffset);

            if ~isempty(atCoreMetaData{1}.PixelSpacing)
                
                x = atCoreMetaData{1}.PixelSpacing(1);
                y = atCoreMetaData{1}.PixelSpacing(2);
                z = computeSliceSpacing(atCoreMetaData);

                if x == 0
                    x = 1;
                end

                if y == 0
                    y = 1;
                end

                if z == 0
                    z = x;
                end
            else

                x = computeAspectRatio('x', atCoreMetaData);
                y = computeAspectRatio('y', atCoreMetaData);
                z = 1;
            end
            
            daspect(axes1Ptr('get', [], dOffset), [z y x]);
            daspect(axes2Ptr('get', [], dOffset), [z x y]);
            daspect(axes3Ptr('get', [], dOffset), [x y z]);

            if isVsplash('get') == false                                    
                daspect(axesMipPtr('get', [], dOffset), [z y x]);
            end
                    
%           if strcmp(imageOrientation('get'), 'axial')
%                daspect(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [z x y]);
%                daspect(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [z y x]);
%                daspect(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [x y z]);
%                if link2DMip('get') == true && isVsplash('get') == false
%                    daspect(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), [z x y]);
%                end
%           elseif strcmp(imageOrientation('get'), 'coronal')
%                daspect(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [x y z]);
%                daspect(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [y z x]);
%                daspect(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [z x y]);
%                if link2DMip('get') == true && isVsplash('get') == false
%                    daspect(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), [x y z]);
%                end

%            elseif strcmp(imageOrientation('get'), 'sagittal')
%                daspect(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [y x z]);
%                daspect(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [x z y]);
%                daspect(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [z x y]);
%                if link2DMip('get') == true && isVsplash('get') == false
%                    daspect(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), [y x z]);
%                end
%           end

        else
            x =1;
            y =1;
            z =1;

            daspect(axes1Ptr('get', [], dOffset), [z x y]);
            daspect(axes2Ptr('get', [], dOffset), [z y x]);
            daspect(axes3Ptr('get', [], dOffset), [x y z]);
            if isVsplash('get') == false
                daspect(axesMipPtr('get', [], dOffset), [z y x]);
            end

            axis(axes1Ptr('get', [], dOffset), 'normal');
            axis(axes2Ptr('get', [], dOffset), 'normal');
            axis(axes3Ptr('get', [], dOffset), 'normal');
            if isVsplash('get') == false
                axis(axesMipPtr('get', [], dOffset), 'normal');
            end

        end

        aspectRatioValue('set', 'x', x);
        aspectRatioValue('set', 'y', y);
        aspectRatioValue('set', 'z', z);
    end
end

    set(uiSeriesPtr('get'), 'Enable', 'on');

    setOverlayPatientInformation(dOffset);

    refreshImages();

    if size(dicomBuffer('get', [], dOffset), 3) ~=1
        
        sliderMipCallback();
        % plotRotatedRoiOnMip(axesMipPtr('get', [], dOffset), dicomBuffer('get', [], dOffset), mipAngle('get'));       
    end

end
