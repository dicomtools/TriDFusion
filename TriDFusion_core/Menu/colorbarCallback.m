function colorbarCallback(hObject, ~)
%function colorbarCallback(hObject, ~)
%Display 2D Colorbar Menu.
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
% along with TriDFusion.  If not, see <http://www.gnu.org/licenses/
    
    windowButton('set', 'up'); % Fix for Linux

    atInput = inputTemplate('get');

    dFusedSeriesOffset = get(uiFusedSeriesPtr('get'), 'Value');
    % if dFusedSeriesOffset > numel(atInput)
    %     return;
    % end

    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');
    % if dSeriesOffset > numel(atInput)
    %     return;
    % end

    % if(numel(hObject.UIContextMenu.Children) > 1)
    % 
    %     if strcmpi(get(hObject, 'Tag'), 'Fusion Colorbar')
    % 
    %         dColorbarOffset = fusionColorMapOffset('get');
    %     else
    %         dColorbarOffset = colorMapOffset('get');
    %     end
    % 
    %     asColorMap = getColorMapsName();
    % 
    %     for mm = 1:numel(hObject.UIContextMenu.Children)
    % 
    %         if strcmpi(hObject.UIContextMenu.Children(mm).Text, asColorMap{dColorbarOffset})    
    %             set(hObject.UIContextMenu.Children(mm), 'Checked', 'on');
    %         else
    %             set(hObject.UIContextMenu.Children(mm), 'Checked', 'off');
    %         end
    %     end
    % end
    
    
    if ~isempty(hObject.ContextMenu)
        
        refreshColorbar(hObject);
    end

    c = uicontextmenu(fiMainWindowPtr('get'));
    set(c, 'tag', get(hObject, 'Tag'));
    % set(c, 'MenuSelectedFcn', @handleColormapSelection);

    set(hObject, 'UIContextMenu', c);

    if strcmpi(get(hObject, 'Tag'), 'Fusion Colorbar') && isVsplash('get') == false

        d = uimenu(c,'Label','Tools');
        set(d, 'tag', get(hObject, 'Tag'));
        set(d, 'MenuSelectedFcn', @handleColorbarTools);
       
        if isCombineMultipleFusion('get') == true
            set(d, 'Enable', 'off');
        else
            set(d, 'Enable', 'on');
        end

        mEdge = uimenu(d,'Label','Edge Detection', 'Callback',@setColorbarEdgeDetection);

        mManualSync = uimenu(d,'Label','Manual Alignment');
        set(mManualSync, 'MenuSelectedFcn', @handleColorbarManualAlignment);

        mMoveImage         = uimenu(mManualSync,'Label','Move Image'               , 'Callback',@setMoveImageCallback);
        mMoveAssociated    = uimenu(mManualSync,'Label','Move Associated Series'   , 'Callback',@setMoveAssociatedSeriesCallback);
        mUpdateDescription = uimenu(mManualSync,'Label','Update Series Description', 'Callback',@setMoveUpdateSeriesDescriptionCallback);

        if associateRegistrationModality('get') == true
            set(mMoveAssociated, 'Checked', true);
        else
            set(mMoveAssociated, 'Checked', false);
        end

        if updateDescription('get') == true
            set(mUpdateDescription, 'Checked', true);
        else
            set(mUpdateDescription, 'Checked', false);
        end

        if isMoveImageActivated('get') == true
            set(mEdge             , 'Enable' , 'off');
            set(mMoveImage        , 'Checked', true);
            set(mMoveAssociated   , 'Enable' , 'on');
            set(mUpdateDescription, 'Enable' , 'on');
        else
            set(mEdge             , 'Enable' , 'on');
            set(mMoveImage        , 'Checked', false);
            set(mMoveAssociated   , 'Enable' , 'off');
            set(mUpdateDescription, 'Enable' , 'off');
        end

        sModality = atInput(dFusedSeriesOffset).atDicomInfo{1}.Modality;
%        if ~strcmpi(sModality, 'CT')

            mPlot = uimenu(d,'Label','Plot Contours');
            set(mPlot, 'MenuSelectedFcn', @handleColorbarPlotContours);
      %      set(mPlot, 'tag', get(hObject, 'Tag'));

            mPlotContours = uimenu(mPlot,'Label','Show Contours', 'Callback', @setPlotContoursCallback);
            if isPlotContours('get') == true
                set(mPlotContours, 'Checked', true);
            else
                set(mPlotContours, 'Checked', false);
            end

            mPlotFace = uimenu(mPlot,'Label','Show Face Alpha', 'Callback', @setShowFaceAlphContoursCallback);
            if isShowFaceAlphaContours('get') == true
                set(mPlotFace, 'Checked', true);
            else
                set(mPlotFace, 'Checked', false);
            end

            mLevelList = uimenu(mPlot,'Label','Set Level List', 'Callback', @setLevelListContoursCallback);
            set(mLevelList, 'Checked', false);

            mLevelStep = uimenu(mPlot,'Label','Set Level Step', 'Callback', @setLevelStepContoursCallback);
            set(mLevelStep, 'Checked', false);

            mLineWidth = uimenu(mPlot,'Label','Set Line Width', 'Callback', @setLineWidthContoursCallback);
            set(mLineWidth, 'Checked', false);

            mPlotText = uimenu(mPlot,'Label','Show Text', 'Callback', @setShowTextContoursCallback);
            if size(dicomBuffer('get'), 3) == 1 % 2D Image
                if isShowTextContours('get', 'axe') == true
                    set(mPlotText, 'Checked', true);
                else
                    set(mPlotText, 'Checked', false);
                end
            else
                set(mPlotText, 'Checked', false);
            end

            mTextList = uimenu(mPlot,'Label','Set Text List', 'Callback', @setTextListContoursCallback);
            set(mTextList, 'Checked', false);

            if isPlotContours('get') == true
                set(mPlotText , 'Enable', 'on');
                set(mPlotFace , 'Enable', 'on');
                set(mLevelList, 'Enable', 'on');
                set(mLevelStep, 'Enable', 'on');
                set(mLineWidth, 'Enable', 'on');
                if size(dicomBuffer('get'), 3) == 1 % 2D Image
                    if isShowTextContours('get', 'axe') == true
                        set(mTextList , 'Enable', 'on');
                    else
                        set(mTextList , 'Enable', 'off');
                    end
                else
                    if isShowTextContours('get', 'coronal')  == true || ...
                       isShowTextContours('get', 'sagittal') == true || ...
                       isShowTextContours('get', 'axial')    == true || ...
                       isShowTextContours('get', 'mip')      == true
                        set(mTextList , 'Enable', 'on');
                    else
                        set(mTextList , 'Enable', 'off');
                    end
                end
            else
                set(mPlotText , 'Enable', 'off');
                set(mPlotFace , 'Enable', 'off');
                set(mLevelList, 'Enable', 'off');
                set(mLevelStep, 'Enable', 'off');
                set(mLineWidth, 'Enable', 'off');
                set(mTextList , 'Enable', 'off');
            end
     %   end
    end

    if strcmpi(get(hObject, 'Tag'), 'Fusion Colorbar')

        if isscalar(atInput)

            if atInput(dFusedSeriesOffset).bFusedEdgeDetection == true

                set(findall(d, 'Label', 'Edge Detection'), 'Checked', 'on');
            end
        else
            if atInput(dFusedSeriesOffset).bEdgeDetection == true

                set(findall(d, 'Label', 'Edge Detection'), 'Checked', 'on');
            end
        end
        sModality = atInput(dFusedSeriesOffset).atDicomInfo{1}.Modality;

    else
%        if atInput(dSeriesOffset).bEdgeDetection == true
%            set(findall(d, 'Label', 'Edge Detection'), 'Checked', 'on');
%        end

        sModality = atInput(dSeriesOffset).atDicomInfo{1}.Modality;
    end

    e = uimenu(c,'Label','Window');
    set(e, 'tag', get(hObject, 'Tag'));
    set(e, 'MenuSelectedFcn', @handleWindowSelection);

    if isCombineMultipleFusion('get') == true && strcmpi(get(hObject, 'Tag'), 'Fusion Colorbar')
        set(e, 'Enable', 'off');
    else
        set(e, 'Enable', 'on');
    end

    uimenu(e,'Label','Manual Input', 'Callback',@setColorbarWindowLevel);

    if strcmpi(get(hObject, 'Tag'), 'Fusion Colorbar')

        i = uimenu(c,'Label','Multi-Fusion');
        set(i, 'tag', get(hObject, 'Tag'));
        set(i, 'MenuSelectedFcn', @handleColorbarMultiFusion);

        mCombineRGB = uimenu(i,'Label','Combine RGB', 'Callback',@setFusionCombineRGB);
        if isCombineMultipleFusion('get') == true
            set(mCombineRGB, 'Checked', true);
        else
            set(mCombineRGB, 'Checked', false);
        end
        set(mCombineRGB, 'Enable', 'on');

        mNormalizeToLiver = uimenu(i,'Label','Normalize to Liver', 'Callback',@setFusionNormalizeToLiverCallback);
        set(mNormalizeToLiver, 'Checked', false);
        if isCombineMultipleFusion('get') == true && ...
           isVsplash('get') == false
            if isRGBFusionNormalizeToLiver('get') == false
                set(mNormalizeToLiver, 'Enable', 'on');
            else
                set(mNormalizeToLiver, 'Enable', 'off');
            end
        else
            set(mNormalizeToLiver, 'Enable', 'off');
        end

        mIntensity = uimenu(i,'Label','Intensity Min\Max', 'Callback',@setFusionImagesIntensity);
        set(mIntensity, 'Checked', false);
        if isCombineMultipleFusion('get') == true
            set(mIntensity, 'Enable', 'on');
        else
            set(mIntensity, 'Enable', 'off');
        end

        mShowRGBColormap = uimenu(i,'Label','Show RGB Colormap', 'Separator','on','Callback',@showRGBColormapImageCallback);
        if size(dicomBuffer('get'), 3) == 1 || ...
           isVsplash('get') == true
            set(mShowRGBColormap , 'Enable', 'off');
        else
            set(mShowRGBColormap , 'Enable', 'on');
        end

        axeRGBImage = axeRGBImagePtr('get');
        if ~isempty(axeRGBImage)
            set(mShowRGBColormap, 'Checked', false);
        else
            set(mShowRGBColormap, 'Checked', true);
        end

        mRGBplus  = uimenu(i,'Label','RGB plus' , 'Callback', @changeRGBColormapImageCallback);
        mRGBblock = uimenu(i,'Label','RGB block', 'Callback', @changeRGBColormapImageCallback);
        mRGBwheel = uimenu(i,'Label','RGB wheel', 'Callback', @changeRGBColormapImageCallback);
        mRGBcube  = uimenu(i,'Label','RGB cube' , 'Callback', @changeRGBColormapImageCallback);

        if ~isempty(axeRGBImage) && ...
           size(dicomBuffer('get'), 3) ~= 1 && ...
           isVsplash('get') == false
            set(mRGBplus , 'Enable', 'on');
            set(mRGBblock, 'Enable', 'on');
            set(mRGBwheel, 'Enable', 'on');
            set(mRGBcube , 'Enable', 'on');
        else
            set(mRGBplus , 'Enable', 'off');
            set(mRGBblock, 'Enable', 'off');
            set(mRGBwheel, 'Enable', 'off');
            set(mRGBcube , 'Enable', 'off');
        end

        sImageName = getRGBColormapImage('get');

        if    strcmpi(sImageName, 'rgb-plus.png')
            set(mRGBplus, 'Checked', 'on');
        elseif strcmpi(sImageName, 'rgb-block.png')
            set(mRGBblock, 'Checked', 'on');
        elseif strcmpi(sImageName, 'rgb-wheel.png')
            set(mRGBwheel, 'Checked', 'on');
        elseif strcmpi(sImageName, 'rgb-cube.png')
            set(mRGBcube, 'Checked', 'on');
        else
        end
    end

    if strcmpi(sModality, 'CT')
        % Create uimenus with labels and tags
        asMenuLabels = {'(F1) Lung', '(F2) Soft Tissue', '(F3) Bone', '(F4) Liver', ...
                        '(F5) Brain', '(F6) Head and Neck', '(F7) Enchanced Lung', ...
                        '(F8) Mediastinum', '(F9) Temporal Bone', '(F9) Vertebra', ...
                        '(F9) All', 'Custom'};

        asMenuTags = {'Lung', 'SoftTissue', 'Bone', 'Liver', 'Brain', 'HeadAndNeck', ...
                      'EnhancedLung', 'Mediastinum', 'TemporalBone', 'Vertebra', ...
                      'All', 'Custom'};

        menus = gobjects(1, numel(asMenuLabels));
        for i = 1:numel(asMenuLabels)
            menus(i) = uimenu(e, 'Label', asMenuLabels{i}, 'Checked', 'off', 'Callback', @setCTColorbarWindowLevel, 'Tag', asMenuTags{i});
        end
        set(menus(end), 'Enable', 'off');

        % Get window and level
        if strcmpi(get(hObject, 'Tag'), 'Fusion Colorbar')
            dMax = fusionWindowLevel('get', 'max');
            dMin = fusionWindowLevel('get', 'min');
        else
            dMax = windowLevel('get', 'max');
            dMin = windowLevel('get', 'min');
        end
        [dWindow, dLevel] = computeWindowMinMax(dMax, dMin);
        sWindowName = getWindowName(dWindow, dLevel);

        % Set checked menu based on window name
        checkedMenu = findobj(menus, 'Tag', regexprep(sWindowName, '\s', ''));
        if ~isempty(checkedMenu)

            set(checkedMenu, 'Checked', 'on');
            
        else
            set(findobj(menus, 'Tag', 'Custom'), 'Checked', 'on');
        end
    end

    asColorMap = getColorMapsName();

    if strcmpi(get(hObject, 'Tag'), 'Fusion Colorbar')

        dColorbarOffset = fusionColorMapOffset('get');
    else
        dColorbarOffset = colorMapOffset('get');
    end
     
    menuItems = gobjects(numel(asColorMap), 1);
    for i = 1:numel(asColorMap)

        if i==dColorbarOffset
            sChecked = 'on';
        else
            sChecked = 'off';
        end

        menuItems(i) = uimenu(c, 'Label', asColorMap{i}, 'Checked', sChecked, 'Callback', @setColorOffset);
    end

    % set(hObject, 'UIContextMenu', c);

    function setColorOffset(hObject, ~)

        dColormapOffset = getColorMapOffset(get(hObject, 'Label'));

        if strcmpi(get(get(hObject, 'Parent'), 'Tag'), 'Fusion Colorbar')

            fusionColorMapOffset('set', dColormapOffset);
        else
            colorMapOffset('set', dColormapOffset);
        end     

        refreshColorMap();   

    end

    function setColorbarEdgeDetection(hObject, ~)

        atInput = inputTemplate('get');
        aInput = inputBuffer('get');

        iSeriesOffset = get(uiSeriesPtr('get'), 'Value');
        if iSeriesOffset > numel(atInput)
            return;
        end

        if strcmpi(get(get(hObject, 'Parent'), 'Tag'), 'Fusion Colorbar')

            iFusionOffset   = get(uiFusedSeriesPtr('get'), 'Value');
            if iFusionOffset > numel(atInput)
                return;
            end

            if isscalar(atInput)
                bEdge = atInput(iFusionOffset).bFusedEdgeDetection;
            else
                bEdge = atInput(iFusionOffset).bEdgeDetection;
            end

            if bEdge == true

                aBufferImage = dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value'));

                tMetaData  = dicomMetaData('get', [], get(uiSeriesPtr('get'), 'Value'));
                if isempty(tMetaData)
                    tMetaData = atInput(iSeriesOffset).atDicomInfo;
                end

                if isscalar(atInput)
                    atInput(iFusionOffset).bFusedEdgeDetection = false;
                else
                    atInput(iFusionOffset).bEdgeDetection = false;
                end

                set(uiSeriesPtr('get'), 'Value', iFusionOffset);
                aFuseImage = dicomBuffer('get');
                if isempty(aFuseImage)
                    aFuseImage = aInput{iFusionOffset};
                end

                tFuseMetaData = dicomMetaData('get');
                if isempty(tFuseMetaData)
                    tFuseMetaData = atInput(iFusionOffset).atDicomInfo;
                end

                if size(aFuseImage, 3) == 1

                    if iSeriesOffset ~= iFusionOffset
                        if atInput(iSeriesOffset).bFlipLeftRight == true
                            aFuseImage=aFuseImage(:,end:-1:1);
                        end

                        if atInput(iSeriesOffset).bFlipAntPost == true
                            aFuseImage=aFuseImage(end:-1:1,:);
                        end
                    end

                    [x1,y1,~] = size(aBufferImage);
                    aFuseImage = imresize(aFuseImage, [x1 y1]);

                else

                    if iSeriesOffset ~= iFusionOffset
                        if atInput(iSeriesOffset).bFlipLeftRight == true
                            aFuseImage=aFuseImage(:,end:-1:1,:);
                        end

                        if atInput(iSeriesOffset).bFlipAntPost == true
                            aFuseImage=aFuseImage(end:-1:1,:,:);
                        end

                        if atInput(iSeriesOffset).bFlipHeadFeet == true
                            aFuseImage=aFuseImage(:,:,end:-1:1);
                        end
                    end

                    if strcmpi(imageOrientation('get'), 'coronal')
                        aFuseImage = permute(aFuseImage, [3 2 1]);
                    elseif strcmpi(imageOrientation('get'), 'sagittal')
                        aFuseImage = permute(aFuseImage, [2 3 1]);
                    else
                        aFuseImage = permute(aFuseImage, [1 2 3]);
                    end


%                    if ( ( tMetaData{1}.ReconstructionDiameter ~= 700 && ...
%                           strcmpi(tMetaData{1}.Modality, 'ct') ) || ...
%                       ( tFuseMetaData{1}.ReconstructionDiameter ~= 700 && ...
%                         strcmpi(tFuseMetaData{1}.Modality, 'ct') ) ) && ...
%                       numel(tMetaData) ~= 1 && ...
%                       numel(tFuseMetaData) ~= 1

                    if numel(aFuseImage) ~= numel(aBufferImage) % Resample image

                        [aFuseImage, ~] = ...
                            resampleImageTransformMatrix(aFuseImage, ...
                                                         tFuseMetaData, ...
                                                         aBufferImage, ...
                                                         tMetaData, ...
                                                         'linear', ...
                                                         false ...
                                                         );

                    end

%                    else

%                        [aFuseImage, ~] = ...
%                            resampleImage(aFuseImage, ...
%                                          tFuseMetaData, ...
%                                          aBufferImage, ...
%                                          tMetaData, ...
%                                          'linear', ...
%                                          false ...
%                                          );

%                    end


                end

                set(uiSeriesPtr('get'), 'Value', iSeriesOffset);

                fusionBuffer('set', aFuseImage, get(uiFusedSeriesPtr('get'), 'Value'));

            else

                if isscalar(atInput)
                    atInput(iFusionOffset).bFusedEdgeDetection = true;
                else
                    atInput(iFusionOffset).bEdgeDetection = true;
                end

                dFudgeFactor = fudgeFactorSegValue('get');
                sMethod = edgeSegMethod('get');

                imf = fusionBuffer('get', [], get(uiFusedSeriesPtr('get'), 'Value'));

                imEdge = getEdgeDetection(imf, sMethod, dFudgeFactor);

                fusionBuffer('set', imEdge, get(uiFusedSeriesPtr('get'), 'Value'));

            end

            inputTemplate('set', atInput);

            setFusionColorbarLabel();

            refreshImages();

        end
    end

    function setColorbarWindowLevel(hObject,~)


        atInput = inputTemplate('get');

        if strcmpi(get(get(hObject, 'Parent'), 'Tag'), 'Fusion Colorbar')

            dColorbarScale = fusionColorbarScale('get');

            dMax = fusionWindowLevel('get', 'max');
            dMin = fusionWindowLevel('get', 'min');

            dSeriesOffset = get(uiFusedSeriesPtr('get'), 'Value');

            sUnitDisplay = getSerieUnitValue(dSeriesOffset);

            bDefaultUnit = isFusionColorbarDefaultUnit('get');

        else

            dColorbarScale = colorbarScale('get');

            dMax = windowLevel('get', 'max');
            dMin = windowLevel('get', 'min');

            dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

            sUnitDisplay = getSerieUnitValue(dSeriesOffset);

            bDefaultUnit = isColorbarDefaultUnit('get');
        end

        if viewerUIFigure('get') == true
    
            dlgWindowLevel = ...
                uifigure('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-380/2) ...
                                    (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-165/2) ...
                                    380 ...
                                    205 ...
                                    ],...
                       'Resize', 'off', ...
                       'Color', viewerBackgroundColor('get'),...
                       'WindowStyle', 'modal', ...
                       'Name' , 'Lookup Table'...
                       );
        else
            dlgWindowLevel = ...
                dialog('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-380/2) ...
                                    (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-165/2) ...
                                    380 ...
                                    205 ...
                                    ],...
                      'Color', viewerBackgroundColor('get'), ...
                      'Name', 'Lookup Table'...
                       );
        end

        edtColorbarScale = ...
          uicontrol(dlgWindowLevel,...
                    'style'     , 'edit',...
                    'Background', 'white',...
                    'string'    , num2str(dColorbarScale),...
                    'BackgroundColor', viewerBackgroundColor('get'), ...
                    'ForegroundColor', viewerForegroundColor('get'), ...
                    'Callback', @edtColorbarScaleCallback, ...
                    'position'  , [200 165 150 20] ...
                    );

         uicontrol(dlgWindowLevel,...
                  'style'   , 'text',...
                  'string'  , 'Colorbar Scale (%)',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [20 162 150 20]...
                  );

        if strcmpi(sUnitDisplay, 'SUV') || strcmpi(sUnitDisplay, 'HU')
            if strcmpi(sUnitDisplay, 'HU')
                if bDefaultUnit == true
                    sUnitDisplay = 'Window Level';

                    [dWindow, dLevel] = computeWindowMinMax(dMax, dMin);
                else
                    sUnitDisplay = 'HU';

                end
            else
                if bDefaultUnit == true

                    if isfield(atInput(dSeriesOffset).tQuant, 'tSUV')
                        dMax = dMax*atInput(dSeriesOffset).tQuant.tSUV.dScale;
                        dMin = dMin*atInput(dSeriesOffset).tQuant.tSUV.dScale;
                    end
                end
            end
            bUnitEnable = 'on';
        else
            bUnitEnable = 'off';
        end

        if strcmpi(sUnitDisplay, 'SUV')

            if bDefaultUnit == true
                sSUVtype = viewerSUVtype('get');
                if isfield(atInput(dSeriesOffset).tQuant, 'tSUV')
                    sUnitType = sprintf('Unit in SUV/%s', sSUVtype);
                else
                    sUnitType = 'Unit in BQML';
                end
            else
               sUnitType = 'Unit in BQML';
            end
        else
            sUnitType = sprintf('Unit in %s', sUnitDisplay);
        end

        chkUnitType = ...
            uicontrol(dlgWindowLevel,...
                      'style'   , 'checkbox',...
                      'enable'  , bUnitEnable,...
                      'value'   , bDefaultUnit,...
                      'position', [20 115 20 20],...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...
                      'Callback', @chkUnitTypeCallback...
                      );

        txtUnitType = ...
             uicontrol(dlgWindowLevel,...
                      'style'   , 'text',...
                      'string'  , sUnitType,...
                      'horizontalalignment', 'left',...
                      'position', [40 115 200 20],...
                      'Enable', 'Inactive',...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...
                      'ButtonDownFcn', @chkUnitTypeCallback...
                      );

      if strcmpi(sUnitDisplay, 'Window Level')
          sMaxDisplay = 'Window Value';
          sMaxValue = num2str(dWindow);
      else
          sMaxDisplay = 'Max Value';
          sMaxValue = num2str(dMax);
      end

         uicontrol(dlgWindowLevel,...
                  'style'   , 'text',...
                  'string'  , sMaxDisplay,...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [20 87 150 20]...
                  );

      edtMaxValue = ...
          uicontrol(dlgWindowLevel,...
                    'style'     , 'edit',...
                    'Background', 'white',...
                    'string'    , sMaxValue,...
                    'BackgroundColor', viewerBackgroundColor('get'), ...
                    'ForegroundColor', viewerForegroundColor('get'), ...
                    'position'  , [200 90 150 20] ...
                    );
      set(edtMaxValue, 'KeyPressFcn', @checkKeyPress);

      if strcmpi(sUnitDisplay, 'Window Level')
          sMinDisplay = 'Level Value';
          sMinValue = num2str(dLevel);
      else
          sMinDisplay = 'Min Value';
          sMinValue = num2str(dMin);
      end
         uicontrol(dlgWindowLevel,...
                  'style'   , 'text',...
                  'string'  , sMinDisplay,...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [20 62 150 20]...
                  );

      edtMinValue = ...
          uicontrol(dlgWindowLevel,...
                    'style'     , 'edit',...
                    'Background', 'white',...
                    'string'    , sMinValue,...
                    'BackgroundColor', viewerBackgroundColor('get'), ...
                    'ForegroundColor', viewerForegroundColor('get'), ...
                    'position'  , [200 65 150 20] ...
                    );
     set(edtMinValue, 'KeyPressFcn', @checkKeyPress);

     % Cancel or Proceed

     uicontrol(dlgWindowLevel,...
               'String','Cancel',...
               'Position',[285 7 75 25],...
               'BackgroundColor', viewerBackgroundColor('get'), ...
               'ForegroundColor', viewerForegroundColor('get'), ...
               'Callback', @cancelWindowLCallback...
               );

     uicontrol(dlgWindowLevel,...
              'String','Proceed',...
              'Position',[200 7 75 25],...
              'BackgroundColor', viewerBackgroundColor('get'), ...
              'ForegroundColor', viewerForegroundColor('get'), ...
              'Callback', @proceedWindowLCallback...
              );

        function checkKeyPress(~, event)
            if strcmp(event.Key, 'return')
                drawnow;
                proceedWindowLCallback();
            end
        end

        function edtColorbarScaleCallback(hObject, ~)

            if str2double(get(hObject, 'String')) < 0
                set(hObject, 'String', '100');
            end
        end

        function chkUnitTypeCallback(hChkObject, ~)

            if strcmpi(get(chkUnitType, 'Enable'), 'off')
                return;
            end

            if strcmpi(get(hChkObject, 'Style'), 'text')
                if get(chkUnitType, 'Value') == true

                    set(chkUnitType, 'Value', false);

                else
                    set(chkUnitType, 'Value', true);
                end
            end

            if  get(chkUnitType, 'Value') == false
                if contains(lower(get(hChkObject, 'String')), 'suv')
                    sUnitDisplay = 'BQML';
                else
                    sUnitDisplay = 'HU';
                end
            else
                if contains(lower(get(hChkObject, 'String')), 'bqml')
                    sUnitDisplay = 'SUV';
                else
                    sUnitDisplay = 'Window Level';
                end
            end

            if strcmpi(sUnitDisplay, 'SUV')
                sSUVtype  = viewerSUVtype('get');
                sUnitType = sprintf('Unit in SUV/%s', sSUVtype);
            else
                sUnitType = sprintf('Unit in %s', sUnitDisplay);
            end

            set(txtUnitType, 'String', sUnitType);

            if strcmpi(get(get(hObject, 'Parent'), 'Tag'), 'Fusion Colorbar')

                isFusionColorbarDefaultUnit('set', get(chkUnitType, 'Value'));

                dMaxValue = fusionWindowLevel('get', 'max');
                dMinValue = fusionWindowLevel('get', 'min');
            else
                isColorbarDefaultUnit('set', get(chkUnitType, 'Value'));

                dMaxValue = windowLevel('get', 'max');
                dMinValue = windowLevel('get', 'min');
            end

            switch (sUnitDisplay)

                case 'Window Level'

                    [dWindow, dLevel] = computeWindowMinMax(dMaxValue, dMinValue);

                    sMinValue = num2str(dLevel);
                    sMaxValue = num2str(dWindow);

                case 'HU'

                    sMinValue = num2str(dMinValue);
                    sMaxValue = num2str(dMaxValue);

                case 'SUV'

                    if isfield(atInput(dSeriesOffset).tQuant, 'tSUV')
    
                        sMinValue = dMinValue*atInput(dSeriesOffset).tQuant.tSUV.dScale;
                        sMaxValue = dMaxValue*atInput(dSeriesOffset).tQuant.tSUV.dScale;
                    end

                case 'BQML'

                    sMinValue = num2str(dMinValue);
                    sMaxValue = num2str(dMaxValue);
            end

            set(edtMinValue, 'String', sMinValue);
            set(edtMaxValue, 'String', sMaxValue);
        end

        function cancelWindowLCallback(~, ~)

            delete(dlgWindowLevel);
        end

        function proceedWindowLCallback(~, ~)

            dColorbarScale = str2double(get(edtColorbarScale, 'String'));

            if dColorbarScale < 0
                dColorbarScale = 100;
            end

            lMax = str2double(get(edtMaxValue, 'String'));
            lMin = str2double(get(edtMinValue, 'String'));

            if strcmpi(sUnitDisplay, 'SUV')
             
                if isfield(atInput(dSeriesOffset).tQuant, 'tSUV')

                    lMin = lMin/atInput(dSeriesOffset).tQuant.tSUV.dScale;
                    lMax = lMax/atInput(dSeriesOffset).tQuant.tSUV.dScale;
                end
            end

            if strcmpi(sUnitDisplay, 'Window Level')
                [lMax, lMin] = computeWindowLevel(lMax, lMin);
            end

            if strcmpi(get(get(hObject, 'Parent'), 'Tag'), 'Fusion Colorbar')

                fusionColorbarScale('set', dColorbarScale);

                fusionWindowLevel('set', 'max', lMax);
                fusionWindowLevel('set', 'min' ,lMin);

                getFusionInitWindowMinMax('set', lMax, lMin);

%                 set(uiFusionSliderWindowPtr('get'), 'value', 0.5);
%                 set(uiFusionSliderLevelPtr('get') , 'value', 0.5);

                if switchTo3DMode('get')     == false && ...
                   switchToIsoSurface('get') == false && ...
                   switchToMIPMode('get')    == false

%                     if size(dicomBuffer('get'), 3) == 1
%                         set(axefPtr('get'), 'CLim', [lMin lMax]);
%                     else
%                         set(axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))  , 'CLim', [lMin lMax]);
%                         set(axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))  , 'CLim', [lMin lMax]);
%                         set(axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))  , 'CLim', [lMin lMax]);
%                         if link2DMip('get') == true && isVsplash('get') == false
%                             set(axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'CLim', [lMin lMax]);
%                         end
%                     end


                    % Compute colorbar line y offset

                    dYOffsetMax = computeLineFusionColorbarIntensityMaxYOffset(get(uiFusedSeriesPtr('get'), 'Value'));
                    dYOffsetMin = computeLineFusionColorbarIntensityMinYOffset(get(uiFusedSeriesPtr('get'), 'Value'));

                    % Ajust the intensity

                    set(lineFusionColorbarIntensityMaxPtr('get'), 'YData', [0.1 0.1]);
                    set(lineFusionColorbarIntensityMinPtr('get'), 'YData', [0.9 0.9]);

                    setFusionColorbarIntensityMinScaleValue(dYOffsetMin, ...
                                                            fusionColorbarScale('get'), ...
                                                            isFusionColorbarDefaultUnit('get'),...
                                                            get(uiFusedSeriesPtr('get'), 'Value')...
                                                            );

                    setFusionColorbarIntensityMaxScaleValue(dYOffsetMax, ...
                                                            fusionColorbarScale('get'), ...
                                                            isFusionColorbarDefaultUnit('get'),...
                                                            get(uiFusedSeriesPtr('get'), 'Value')...
                                                           );


                    setFusionAxesIntensity(get(uiFusedSeriesPtr('get'), 'Value'));

                    refreshImages();
                end
            else
                colorbarScale('set', dColorbarScale);

                windowLevel('set', 'max', lMax);
                windowLevel('set', 'min' ,lMin);

                getInitWindowMinMax('set', lMax, lMin);

%                 set(uiSliderWindowPtr('get'), 'value', 0.5);
%                 set(uiSliderLevelPtr('get') , 'value', 0.5);

                if switchTo3DMode('get')     == false && ...
                   switchToIsoSurface('get') == false && ...
                   switchToMIPMode('get')    == false

%                     if size(dicomBuffer('get'), 3) == 1
%                         set(axePtr('get', [], get(uiSeriesPtr('get'), 'Value')), 'CLim', [lMin lMax]);
%                     else
%                         set(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'CLim', [lMin lMax]);
%                         set(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'CLim', [lMin lMax]);
%                         set(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'CLim', [lMin lMax]);
%                         if link2DMip('get') == true && isVsplash('get') == false
%                             set(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), 'CLim', [lMin lMax]);
%                         end
%                     end

                    % Compute colorbar line y offset

                    dYOffsetMax = computeLineColorbarIntensityMaxYOffset(get(uiSeriesPtr('get'), 'Value'));
                    dYOffsetMin = computeLineColorbarIntensityMinYOffset(get(uiSeriesPtr('get'), 'Value'));

                    % Ajust the intensity

                    set(lineColorbarIntensityMaxPtr('get'), 'YData', [0.1 0.1]);
                    set(lineColorbarIntensityMinPtr('get'), 'YData', [0.9 0.9]);
                    
                    setColorbarIntensityMinScaleValue(dYOffsetMin, ...
                                                      colorbarScale('get'), ...
                                                      isColorbarDefaultUnit('get'), ...
                                                      get(uiSeriesPtr('get'), 'Value')...
                                                      );

                    setColorbarIntensityMaxScaleValue(dYOffsetMax, ...
                                                      colorbarScale('get'), ...
                                                      isColorbarDefaultUnit('get'), ...
                                                      get(uiSeriesPtr('get'), 'Value')...
                                                      );



                    setAxesIntensity(get(uiSeriesPtr('get'), 'Value'));

                    refreshImages();
                end
            end

            delete(dlgWindowLevel)
        end

    end

    function setCTColorbarWindowLevel(hObject, ~)

        switch lower(get(hObject, 'Label'))

            case '(f1) lung'
                [lMax, lMin] = computeWindowLevel(1200, -500);

            case '(f2) soft tissue'
                [lMax, lMin] = computeWindowLevel(500, 50);

            case '(f3) bone'
                [lMax, lMin] = computeWindowLevel(500, 200);

            case '(f4) liver'
                [lMax, lMin] = computeWindowLevel(240, 40);

            case '(f5) brain'
                [lMax, lMin] = computeWindowLevel(80, 40);

            case '(f6) head and neck'
                [lMax, lMin] = computeWindowLevel(350, 90);

            case '(f7) enchanced lung'
                [lMax, lMin] = computeWindowLevel(2000, -600);

            case '(f8) mediastinum'
                [lMax, lMin] = computeWindowLevel(350, 50);

            case '(f9) temporal bone'
                [lMax, lMin] = computeWindowLevel(1000, 350);

            case '(f9) vertebra'
                [lMax, lMin] = computeWindowLevel(2500, 415);

%             case lower('(F9) Scout CT')
%                 [lMax, lMin] = computeWindowLevel(350, 50);
            case '(f9) all'
                [lMax, lMin] = computeWindowLevel(2000, 0);
            otherwise
                % to do
        end

        if strcmpi(get(get(hObject, 'Parent'), 'Tag'), 'Fusion Colorbar')

            fusionWindowLevel('set', 'max', lMax);
            fusionWindowLevel('set', 'min' ,lMin);

%             if size(fusionBuffer('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 3) == 1
%                 set(axefPtr('get'), 'CLim', [lMin lMax]);
%             else
%                 set(axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'CLim', [lMin lMax]);
%                 set(axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'CLim', [lMin lMax]);
%                 set(axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'CLim', [lMin lMax]);
%                 if link2DMip('get') == true && isVsplash('get') == false
%                     set(axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'CLim', [lMin lMax]);
%                 end
%             end

            % Compute colorbar line y offset

            dYOffsetMax = computeLineFusionColorbarIntensityMaxYOffset(get(uiFusedSeriesPtr('get'), 'Value'));
            dYOffsetMin = computeLineFusionColorbarIntensityMinYOffset(get(uiFusedSeriesPtr('get'), 'Value'));

            % Ajust the intensity

            set(lineFusionColorbarIntensityMaxPtr('get'), 'YData', [0.1 0.1]);
            set(lineFusionColorbarIntensityMinPtr('get'), 'YData', [0.9 0.9]);

            setFusionColorbarIntensityMaxScaleValue(dYOffsetMax, ...
                                                    fusionColorbarScale('get'), ...
                                                    isFusionColorbarDefaultUnit('get'),...
                                                    get(uiFusedSeriesPtr('get'), 'Value')...
                                                   );

            setFusionColorbarIntensityMinScaleValue(dYOffsetMin, ...
                                                    fusionColorbarScale('get'), ...
                                                    isFusionColorbarDefaultUnit('get'),...
                                                    get(uiFusedSeriesPtr('get'), 'Value')...
                                                    );

            setFusionAxesIntensity(get(uiFusedSeriesPtr('get'), 'Value'));
        else
            windowLevel('set', 'max', lMax);
            windowLevel('set', 'min' ,lMin);

%             if size(dicomBuffer('get'), 3) == 1
%                 set(axePtr('get', [], get(uiSeriesPtr('get'), 'Value')), 'CLim', [lMin lMax]);
%             else
%                 set(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'CLim', [lMin lMax]);
%                 set(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'CLim', [lMin lMax]);
%                 set(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'CLim', [lMin lMax]);
%                 if link2DMip('get') == true && isVsplash('get') == false
%                     set(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), 'CLim', [lMin lMax]);
%                 end
%             end

            % Ajust the intensity

            % Compute colorbar line y offset

            dYOffsetMax = computeLineColorbarIntensityMaxYOffset(get(uiSeriesPtr('get'), 'Value'));
            dYOffsetMin = computeLineColorbarIntensityMinYOffset(get(uiSeriesPtr('get'), 'Value'));

            % Ajust the intensity

            set(lineColorbarIntensityMaxPtr('get'), 'YData', [0.1 0.1]);
            set(lineColorbarIntensityMinPtr('get'), 'YData', [0.9 0.9]);

            setColorbarIntensityMaxScaleValue(dYOffsetMax, ...
                                              colorbarScale('get'), ...
                                              isColorbarDefaultUnit('get'), ...
                                              get(uiSeriesPtr('get'), 'Value')...
                                              );

            setColorbarIntensityMinScaleValue(dYOffsetMin, ...
                                              colorbarScale('get'), ...
                                              isColorbarDefaultUnit('get'), ...
                                              get(uiSeriesPtr('get'), 'Value')...
                                              );

            setAxesIntensity(get(uiSeriesPtr('get'), 'Value'));

        end

    end

    function setMoveAssociatedSeriesCallback(hObject, ~)

        bMoveAssociatedSeries = get(hObject, 'Checked');

        if bMoveAssociatedSeries == true
            associateRegistrationModality('set', false);
        else
            associateRegistrationModality('set', true);
        end
    end

    function setMoveUpdateSeriesDescriptionCallback(hObject, ~)

        bUpdateSeriesDescription = get(hObject, 'Checked');

        if bUpdateSeriesDescription == true
            updateDescription('set', false);
        else
            updateDescription('set', true);
        end
    end

    function handleWindowSelection(hObject, ~)

        atInput = inputTemplate('get');
    
        dFusedSeriesOffset = get(uiFusedSeriesPtr('get'), 'Value');
        dSeriesOffset      = get(uiSeriesPtr('get'), 'Value');


        if strcmpi(get(hObject, 'Tag'), 'Fusion Colorbar')

            sModality = atInput(dFusedSeriesOffset).atDicomInfo{1}.Modality;
    
        else
            sModality = atInput(dSeriesOffset).atDicomInfo{1}.Modality;
        end

        if strcmpi(sModality, 'CT')
    
            % Get window and level
            if strcmpi(get(hObject, 'Tag'), 'Fusion Colorbar')
                dMax = fusionWindowLevel('get', 'max');
                dMin = fusionWindowLevel('get', 'min');
            else
                dMax = windowLevel('get', 'max');
                dMin = windowLevel('get', 'min');
            end
            [dWindow, dLevel] = computeWindowMinMax(dMax, dMin);
            sWindowName = getWindowName(dWindow, dLevel);
    
            % Set checked menu based on window name
            checkedMenu = findobj(hObject.Children, 'Tag', regexprep(sWindowName, '\s', ''));
            if ~isempty(checkedMenu)
    
                set(checkedMenu, 'Checked', 'on');
                
            else
                set(findobj(hObject.Children, 'Tag', 'Custom'), 'Checked', 'on');
            end
        end
        
    end

    function handleColorbarTools(hObject, ~)

        atInput = inputTemplate('get');

        if strcmpi(get(get(hObject, 'Parent'), 'Tag'), 'Fusion Colorbar')

            iFusionOffset   = get(uiFusedSeriesPtr('get'), 'Value');

            if iFusionOffset > numel(atInput)
                return;
            end

            if isscalar(atInput)
                bEdge = atInput(iFusionOffset).bFusedEdgeDetection;
            else
                bEdge = atInput(iFusionOffset).bEdgeDetection;
            end

            if bEdge == true
                set(findall(hObject.Children, 'Label', 'Edge Detection'), 'Checked', 'on');
            else
                set(findall(hObject.Children, 'Label', 'Edge Detection'), 'Checked', 'off');
            end
        end

    end
    
    function handleColorbarManualAlignment(hObject, ~)

        if isMoveImageActivated('get') == true

            set(findall(hObject.Children, 'Label', 'Move Image'), 'Checked', 'on');

            set(findall(hObject.Children, 'Label', 'Move Associated Series'   ), 'Enable', 'on');
            set(findall(hObject.Children, 'Label', 'Update Series Description'), 'Enable', 'on');
        else
            set(findall(hObject.Children, 'Label', 'Move Image'), 'Checked', 'off');

            set(findall(hObject.Children, 'Label', 'Move Associated Series'   ), 'Enable', 'off');
            set(findall(hObject.Children, 'Label', 'Update Series Description'), 'Enable', 'off');                
        end

        if associateRegistrationModality('get') == true

            set(findall(hObject.Children, 'Label', 'Move Associated Series'), 'Checked', 'on');
        else
            set(findall(hObject.Children, 'Label', 'Move Associated Series'), 'Checked', 'off');
        end

        if updateDescription('get') == true

            set(findall(hObject.Children, 'Label', 'Update Series Description'), 'Checked', 'on');
        else
            set(findall(hObject.Children, 'Label', 'Update Series Description'), 'Checked', 'off');
        end

    end

    function handleColorbarPlotContours(hObject, ~)

        if isPlotContours('get') == true

            set(findall(hObject.Children, 'Label', 'Show Contours'), 'Checked', 'on');

            set(findall(hObject.Children, 'Label', 'Show Face Alpha'), 'Enable', 'on');
            set(findall(hObject.Children, 'Label', 'Set Level List' ), 'Enable', 'on');
            set(findall(hObject.Children, 'Label', 'Set Level Step' ), 'Enable', 'on');
            set(findall(hObject.Children, 'Label', 'Set Line Width' ), 'Enable', 'on');
            set(findall(hObject.Children, 'Label', 'Show Text'      ), 'Enable', 'on');
         
            if size(dicomBuffer('get'), 3) == 1 % 2D Image

                if isShowTextContours('get', 'axe') == true

                    set(findall(hObject.Children, 'Label', 'Set Text List'), 'Enable', 'on');
                else
                    set(findall(hObject.Children, 'Label', 'Set Text List'), 'Enable', 'off');
                end
            else
                if isShowTextContours('get', 'coronal')  == true || ...
                   isShowTextContours('get', 'sagittal') == true || ...
                   isShowTextContours('get', 'axial')    == true || ...
                   isShowTextContours('get', 'mip')      == true

                    set(findall(hObject.Children, 'Label', 'Set Text List'), 'Enable', 'on');
                else
                    set(findall(hObject.Children, 'Label', 'Set Text List'), 'Enable', 'off');
                end
            end                
      else
            set(findall(hObject.Children, 'Label', 'Show Contours'), 'Checked', 'off');

            set(findall(hObject.Children, 'Label', 'Show Face Alpha'), 'Enable', 'off');
            set(findall(hObject.Children, 'Label', 'Set Level List' ), 'Enable', 'off');
            set(findall(hObject.Children, 'Label', 'Set Level Step' ), 'Enable', 'off');
            set(findall(hObject.Children, 'Label', 'Set Line Width' ), 'Enable', 'off');
            set(findall(hObject.Children, 'Label', 'Show Text'      ), 'Enable', 'off');                
            set(findall(hObject.Children, 'Label', 'Set Text List'  ), 'Enable', 'off');
        end

        if isShowFaceAlphaContours('get') == true

            set(findall(hObject.Children, 'Label', 'Show Face Alpha'), 'Checked', 'on');
        else
            set(findall(hObject.Children, 'Label', 'Show Face Alpha'), 'Checked', 'off');
        end

        if size(dicomBuffer('get', [], dSeriesOffset), 3) == 1 % 2D Image

            if isShowTextContours('get', 'axe') == true
                set(findall(hObject.Children, 'Label', 'Show Text'), 'Checked', 'on');
            else
                set(findall(hObject.Children, 'Label', 'Show Text'), 'Checked', 'off');
            end
        else
            set(findall(hObject.Children, 'Label', 'Show Text'), 'Checked', 'off');
        end
    end

    function handleColorbarMultiFusion(hObject, ~)
            
        if isCombineMultipleFusion('get') == true

            set(findall(hObject.Children, 'Label', 'Combine RGB'), 'Checked', 'on');
          
        else
            set(findall(hObject.Children, 'Label', 'Combine RGB'), 'Checked', 'off');

            set(findall(hObject.Children, 'Label', 'Intensity Min\Max'), 'Enable', 'off');
        end
        set(findall(hObject.Children, 'Label', 'Combine RGB'), 'Enable', 'on');

        set(findall(hObject.Children, 'Label', 'Normalize to Liver'), 'Checked', 'off');
        if isCombineMultipleFusion('get') == true && ...
           isVsplash('get') == false

            if isRGBFusionNormalizeToLiver('get') == false

                set(findall(hObject.Children, 'Label', 'Normalize to Liver'), 'Enable', 'on');
            else
                set(findall(hObject.Children, 'Label', 'Normalize to Liver'), 'Enable', 'off');
            end
        else
            set(findall(hObject.Children, 'Label', 'Normalize to Liver'), 'Enable', 'off');
        end

        set(findall(hObject.Children, 'Label', 'Intensity Min\Max'), 'Checked', 'off');
        if isCombineMultipleFusion('get') == true
            set(findall(hObject.Children, 'Label', 'Intensity Min\Max'), 'Enable', 'on');
        else
            set(findall(hObject.Children, 'Label', 'Intensity Min\Max'), 'Enable', 'off');
        end

        if size(dicomBuffer('get', [], dSeriesOffset), 3) == 1 || ...
           isVsplash('get') == true

            set(findall(hObject.Children, 'Label', 'Show RGB Colormap'), 'Enable', 'off');
        else
            set(findall(hObject.Children, 'Label', 'Show RGB Colormap'), 'Enable', 'on');
        end

        axeRGBImage = axeRGBImagePtr('get');
        if ~isempty(axeRGBImage)

            set(findall(hObject.Children, 'Label', 'Show RGB Colormap'), 'Checked', 'on');
        else
            set(findall(hObject.Children, 'Label', 'Show RGB Colormap'), 'Checked', 'off');
        end

        if ~isempty(axeRGBImage) && ...
           size(dicomBuffer('get', [], dSeriesOffset), 3) ~= 1 && ...
           isVsplash('get') == false

            set(findall(hObject.Children, 'Label', 'RGB plus' ), 'Enable', 'on');
            set(findall(hObject.Children, 'Label', 'RGB block'), 'Enable', 'on');
            set(findall(hObject.Children, 'Label', 'RGB wheel'), 'Enable', 'on');
            set(findall(hObject.Children, 'Label', 'RGB cube' ), 'Enable', 'on');

        else
            set(findall(hObject.Children, 'Label', 'RGB plus' ), 'Enable', 'off');
            set(findall(hObject.Children, 'Label', 'RGB block'), 'Enable', 'off');
            set(findall(hObject.Children, 'Label', 'RGB wheel'), 'Enable', 'off');
            set(findall(hObject.Children, 'Label', 'RGB cube' ), 'Enable', 'off');
        end    

        sImageName = getRGBColormapImage('get');

        if    strcmpi(sImageName, 'rgb-plus.png')
            set(findall(hObject.Children, 'Label', 'RGB plus' ), 'Checked', 'on');
        elseif strcmpi(sImageName, 'rgb-block.png')
            set(findall(hObject.Children, 'Label', 'RGB block'), 'Checked', 'on');
        elseif strcmpi(sImageName, 'rgb-wheel.png')
            set(findall(hObject.Children, 'Label', 'RGB wheel'), 'Checked', 'on');
        elseif strcmpi(sImageName, 'rgb-cube.png')
            set(findall(hObject.Children, 'Label', 'RGB cube'), 'Checked', 'on');
        else
        end       
    end
    
    function  refreshColorbar(hObject)

        if strcmpi(get(hObject, 'Tag'), 'Fusion Colorbar')
            
            sModality = atInput(dFusedSeriesOffset).atDicomInfo{1}.Modality;

            dColorbarOffset = fusionColorMapOffset('get');
        else
            sModality = atInput(dSeriesOffset).atDicomInfo{1}.Modality;

            dColorbarOffset = colorMapOffset('get');
        end

        asColorMap = getColorMapsName();
        sColorMap = asColorMap{dColorbarOffset};

        dToolsMenuOffset = [];
        dWindowMenuOffset = [];
        dMultiFusionMenuOffset = [];

        for tt = 1:numel(hObject.ContextMenu.Children)

            if strcmpi(hObject.ContextMenu.Children(tt).Text, 'Tools') 
                dToolsMenuOffset = tt;
                continue;
            end

            if strcmpi(hObject.ContextMenu.Children(tt).Text, 'Window') 
                dWindowMenuOffset = tt;
                continue;
            end

            if strcmpi(hObject.ContextMenu.Children(tt).Text, 'Multi-Fusion')
                dMultiFusionMenuOffset = tt;
                continue;
            end

            if strcmpi(hObject.ContextMenu.Children(tt).Text, sColorMap)
                hObject.ContextMenu.Children(tt).Checked = true;
            else
                hObject.ContextMenu.Children(tt).Checked = false;
            end

            drawnow;
        end

        % Window

        if ~isempty(dWindowMenuOffset)

            if isCombineMultipleFusion('get') == true && ...
               strcmpi(get(hObject, 'Tag'), 'Fusion Colorbar')
                
                set(hObject.ContextMenu.Children(dWindowMenuOffset), 'Enable', 'off');
            else
                set(hObject.ContextMenu.Children(dWindowMenuOffset), 'Enable', 'on');
            end
        end

        if strcmpi(sModality, 'CT')

            % Create uimenus with labels and tags
            asMenuLabels = {'(F1) Lung', '(F2) Soft Tissue', '(F3) Bone', '(F4) Liver', ...
                            '(F5) Brain', '(F6) Head and Neck', '(F7) Enchanced Lung', ...
                            '(F8) Mediastinum', '(F9) Temporal Bone', '(F9) Vertebra', ...
                            '(F9) All', 'Custom'};
    
            asMenuTags = {'Lung', 'SoftTissue', 'Bone', 'Liver', 'Brain', 'HeadAndNeck', ...
                          'EnhancedLung', 'Mediastinum', 'TemporalBone', 'Vertebra', ...
                          'All', 'Custom'};
    
            menus = gobjects(1, numel(asMenuLabels));
    
            % Get window and level
            if strcmpi(get(hObject, 'Tag'), 'Fusion Colorbar')
                dMax = fusionWindowLevel('get', 'max');
                dMin = fusionWindowLevel('get', 'min');
            else
                dMax = windowLevel('get', 'max');
                dMin = windowLevel('get', 'min');
            end
            [dWindow, dLevel] = computeWindowMinMax(dMax, dMin);
            sWindowName = getWindowName(dWindow, dLevel);
    
            dWindowOffset = find(~cellfun('isempty', strfind(asMenuTags, sWindowName)), 1); % Find non-empty matches
            
            if ~isempty(dWindowMenuOffset)

                if ~isempty(dWindowOffset)


                    bCustomWindow = true;

                    for jj=1:numel(hObject.ContextMenu.Children(dWindowMenuOffset).Children)

                        if strcmpi(hObject.ContextMenu.Children(dWindowMenuOffset).Children(jj).Text, sWindowName)

                            bCustomWindow = false;
                            hObject.ContextMenu.Children(dWindowMenuOffset).Children(jj).Checked = 'on';
                        else
                            hObject.ContextMenu.Children(dWindowMenuOffset).Children(jj).Checked = false;
                        end
                    end

                    if bCustomWindow == true

                        for jj=1:numel(hObject.ContextMenu.Children(dWindowMenuOffset).Children)

                            if strcmpi(hObject.ContextMenu.Children(dWindowMenuOffset).Children(jj).Text, 'Custom')

                                hObject.ContextMenu.Children(dWindowMenuOffset).Children(jj).Checked = true;
                            end                           
                        end    
                    end

                end
            end
        end

        % Update tools

        if ~isempty(dToolsMenuOffset)

            if isCombineMultipleFusion('get') == true

                set(hObject.ContextMenu.Children(dToolsMenuOffset), 'Enable', 'off');
            else
                set(hObject.ContextMenu.Children(dToolsMenuOffset), 'Enable', 'on');
            end
            
            % Update Tools submenu

            dToolsEdgeDetectionMenuOffset = [];
            dToolsManualAlignmentMenuOffset = [];
            dToolsPlotContoursMenuOffset = [];

            for tt=1:numel(hObject.ContextMenu.Children(dToolsMenuOffset).Children) 

                if strcmpi(hObject.ContextMenu.Children(dToolsMenuOffset).Children(tt).Text, 'Edge Detection') 

                    dToolsEdgeDetectionMenuOffset = tt;
                end

                if strcmpi(hObject.ContextMenu.Children(dToolsMenuOffset).Children(tt).Text, 'Manual Alignment') 

                    dToolsManualAlignmentMenuOffset = tt;
                end

                if strcmpi(hObject.ContextMenu.Children(dToolsMenuOffset).Children(tt).Text, 'Plot Contours') 

                    dToolsPlotContoursMenuOffset = tt;
                end                
            end

            % Manual Alignment

            if ~isempty(dToolsManualAlignmentMenuOffset)

                dToolsManualAlignmentMoveImageMenuOffset = [];
                dToolsManualAlignmentMoveAssociatedSeriesMenuOffset = [];
                dToolsManualAlignmentUpdateSeriesDescriptionMenuOffset = [];

                for ta=1:numel(hObject.ContextMenu.Children(dToolsMenuOffset).Children(dToolsManualAlignmentMenuOffset).Children)

                    % Move Image                    
                    if strcmpi(hObject.ContextMenu.Children(dToolsMenuOffset).Children(dToolsManualAlignmentMenuOffset).Children(ta).Text, 'Move Image') 

                        dToolsManualAlignmentMoveImageMenuOffset = ta;
                    end

                    % Move Associated Series
                    if strcmpi(hObject.ContextMenu.Children(dToolsMenuOffset).Children(dToolsManualAlignmentMenuOffset).Children(ta).Text, 'Move Associated Series') 

                        dToolsManualAlignmentMoveAssociatedSeriesMenuOffset = ta;
                    end

                    % Update Series Description    
                    if strcmpi(hObject.ContextMenu.Children(dToolsMenuOffset).Children(dToolsManualAlignmentMenuOffset).Children(ta).Text, 'Update Series Description') 

                        dToolsManualAlignmentUpdateSeriesDescriptionMenuOffset = ta;
                    end                    
                end
                
                % Move Associated Series

                if ~isempty(dToolsManualAlignmentMoveAssociatedSeriesMenuOffset)

                    if associateRegistrationModality('get') == true
                        
                        hObject.ContextMenu.Children(dToolsMenuOffset).Children(dToolsManualAlignmentMenuOffset).Children(dToolsManualAlignmentMoveAssociatedSeriesMenuOffset).Checked = true;

                    else
                        hObject.ContextMenu.Children(dToolsMenuOffset).Children(dToolsManualAlignmentMenuOffset).Children(dToolsManualAlignmentMoveAssociatedSeriesMenuOffset).Checked = false;
                    end
                end

                % Update Series Description

                if ~isempty(dToolsManualAlignmentUpdateSeriesDescriptionMenuOffset)

                    if updateDescription('get') == true
    
                        hObject.ContextMenu.Children(dToolsMenuOffset).Children(dToolsManualAlignmentMenuOffset).Children(dToolsManualAlignmentUpdateSeriesDescriptionMenuOffset).Checked = true;
    
                    else
                        hObject.ContextMenu.Children(dToolsMenuOffset).Children(dToolsManualAlignmentMenuOffset).Children(dToolsManualAlignmentUpdateSeriesDescriptionMenuOffset).Checked = false;
                    end
                end
                
                if isMoveImageActivated('get') == true

                    % Menu Edge
                    if ~isempty(dToolsEdgeDetectionMenuOffset)

                        set(hObject.ContextMenu.Children(dToolsMenuOffset).Children(dToolsEdgeDetectionMenuOffset), 'Enable' , 'off');
                    end

                    % Menu Move Image
                    if ~isempty(dToolsManualAlignmentMoveImageMenuOffset)

                        set(hObject.ContextMenu.Children(dToolsMenuOffset).Children(dToolsManualAlignmentMenuOffset).Children(dToolsManualAlignmentMoveImageMenuOffset), 'Checked', true);
                    end

                    % Menu Move Associated
                    if ~isempty(dToolsManualAlignmentUpdateSeriesDescriptionMenuOffset)

                        set(hObject.ContextMenu.Children(dToolsMenuOffset).Children(dToolsManualAlignmentMenuOffset).Children(dToolsManualAlignmentMoveAssociatedSeriesMenuOffset), 'Enable', 'on');
                    end

                    % Menu Update Description
                    if ~isempty(dToolsManualAlignmentUpdateSeriesDescriptionMenuOffset)

                        set(hObject.ContextMenu.Children(dToolsMenuOffset).Children(dToolsManualAlignmentMenuOffset).Children(dToolsManualAlignmentUpdateSeriesDescriptionMenuOffset), 'Enable' , 'on');
                    end
                else
                    % Menu Edge
                    if ~isempty(dToolsEdgeDetectionMenuOffset)

                        set(hObject.ContextMenu.Children(dToolsMenuOffset).Children(dToolsEdgeDetectionMenuOffset), 'Enable' , 'on');
                    end

                    % Menu Move Image
                    if ~isempty(dToolsManualAlignmentMoveImageMenuOffset)

                        set(hObject.ContextMenu.Children(dToolsMenuOffset).Children(dToolsManualAlignmentMenuOffset).Children(dToolsManualAlignmentMoveImageMenuOffset), 'Checked', false);
                    end

                    % Menu Move Associated
                    if ~isempty(dToolsManualAlignmentUpdateSeriesDescriptionMenuOffset)

                        set(hObject.ContextMenu.Children(dToolsMenuOffset).Children(dToolsManualAlignmentMenuOffset).Children(dToolsManualAlignmentMoveAssociatedSeriesMenuOffset), 'Enable', 'off');
                    end

                    % Menu Update Description
                    if ~isempty(dToolsManualAlignmentUpdateSeriesDescriptionMenuOffset)

                        set(hObject.ContextMenu.Children(dToolsMenuOffset).Children(dToolsManualAlignmentMenuOffset).Children(dToolsManualAlignmentUpdateSeriesDescriptionMenuOffset), 'Enable' , 'off');
                    end
                end
            end

            % Plot Contours

            if ~isempty(dToolsPlotContoursMenuOffset)
                
                dToolsPlotContoursShowContoursMenuOffset = [];
                dToolsPlotContoursShowFaceAlphaMenuOffset = [];
                dToolsPlotContoursSetLevelListMenuOffset = [];
                dToolsPlotContoursSetLevelStepMenuOffset = [];
                dToolsPlotContoursSetLineWidthMenuOffset = [];
                dToolsPlotContoursShowTextMenuOffset = [];
                dToolsPlotContoursSetTextListMenuOffset = [];
         
                for pc=1:numel(hObject.ContextMenu.Children(dToolsMenuOffset).Children(dToolsPlotContoursMenuOffset).Children)

                    % Show Contours
                    if strcmpi(hObject.ContextMenu.Children(dToolsMenuOffset).Children(dToolsPlotContoursMenuOffset).Children(pc).Text, 'Show Contours') 

                        dToolsPlotContoursShowContoursMenuOffset = pc;
                    end

                    % Show Face Alpha
                    if strcmpi(hObject.ContextMenu.Children(dToolsMenuOffset).Children(dToolsPlotContoursMenuOffset).Children(pc).Text, 'Show Face Alpha') 

                        dToolsPlotContoursShowFaceAlphaMenuOffset = pc;
                    end

                    % Set Level List
                    if strcmpi(hObject.ContextMenu.Children(dToolsMenuOffset).Children(dToolsPlotContoursMenuOffset).Children(pc).Text, 'Set Level List') 

                        dToolsPlotContoursSetLevelListMenuOffset = pc;
                    end

                    % Set Level Step
                    if strcmpi(hObject.ContextMenu.Children(dToolsMenuOffset).Children(dToolsPlotContoursMenuOffset).Children(pc).Text, 'Set Level Step') 

                        dToolsPlotContoursSetLevelStepMenuOffset = pc;
                    end

                    % Set Line Width
                    if strcmpi(hObject.ContextMenu.Children(dToolsMenuOffset).Children(dToolsPlotContoursMenuOffset).Children(pc).Text, 'Set Line Width') 

                        dToolsPlotContoursSetLineWidthMenuOffset = pc;
                    end

                    % Show Text
                    if strcmpi(hObject.ContextMenu.Children(dToolsMenuOffset).Children(dToolsPlotContoursMenuOffset).Children(pc).Text, 'Show Text') 

                        dToolsPlotContoursShowTextMenuOffset = pc;
                    end

                    % Set Text List
                    if strcmpi(hObject.ContextMenu.Children(dToolsMenuOffset).Children(dToolsPlotContoursMenuOffset).Children(pc).Text, 'Set Text List') 

                        dToolsPlotContoursSetTextListMenuOffset = pc;
                    end                    
                end

                % Show Contours

                if ~isempty(dToolsPlotContoursShowContoursMenuOffset)

                    if isPlotContours('get') == true

                        set(hObject.ContextMenu.Children(dToolsMenuOffset).Children(dToolsPlotContoursMenuOffset).Children(dToolsPlotContoursShowContoursMenuOffset), 'Checked', true);
                    else
                        set(hObject.ContextMenu.Children(dToolsMenuOffset).Children(dToolsPlotContoursMenuOffset).Children(dToolsPlotContoursShowContoursMenuOffset), 'Checked', false);
                    end                
                end
              
                % Show Face Alpha

                if ~isempty(dToolsPlotContoursShowFaceAlphaMenuOffset)

                    if isShowFaceAlphaContours('get') == true

                        set(hObject.ContextMenu.Children(dToolsMenuOffset).Children(dToolsPlotContoursMenuOffset).Children(dToolsPlotContoursShowFaceAlphaMenuOffset), 'Checked', true);
                    else
                        set(hObject.ContextMenu.Children(dToolsMenuOffset).Children(dToolsPlotContoursMenuOffset).Children(dToolsPlotContoursShowFaceAlphaMenuOffset), 'Checked', false);
                    end
                end

                % Set Level List

                if ~isempty(dToolsPlotContoursSetLevelListMenuOffset)

                    set(hObject.ContextMenu.Children(dToolsMenuOffset).Children(dToolsPlotContoursMenuOffset).Children(dToolsPlotContoursSetLevelListMenuOffset), 'Checked', false);
                end

                % Set Level Step

                if ~isempty(dToolsPlotContoursSetLevelStepMenuOffset)

                    set(hObject.ContextMenu.Children(dToolsMenuOffset).Children(dToolsPlotContoursMenuOffset).Children(dToolsPlotContoursSetLevelStepMenuOffset), 'Checked', false);
                end

                % Set Line Width

                if ~isempty(dToolsPlotContoursSetLineWidthMenuOffset)

                    set(hObject.ContextMenu.Children(dToolsMenuOffset).Children(dToolsPlotContoursMenuOffset).Children(dToolsPlotContoursSetLineWidthMenuOffset), 'Checked', false);
                end

                % Show Text

                if ~isempty(dToolsPlotContoursShowTextMenuOffset)
            
                    if size(dicomBuffer('get', [], dSeriesOffset), 3) == 1 % 2D Image

                        if isShowTextContours('get', 'axe') == true

                            set(hObject.ContextMenu.Children(dToolsMenuOffset).Children(dToolsPlotContoursMenuOffset).Children(dToolsPlotContoursShowTextMenuOffset), 'Checked', true);
                        else
                            set(hObject.ContextMenu.Children(dToolsMenuOffset).Children(dToolsPlotContoursMenuOffset).Children(dToolsPlotContoursShowTextMenuOffset), 'Checked', false);
                        end
                    else
                        set(hObject.ContextMenu.Children(dToolsMenuOffset).Children(dToolsPlotContoursMenuOffset).Children(dToolsPlotContoursShowTextMenuOffset), 'Checked', false);
                    end
                end

                % Set Text List

                if ~isempty(dToolsPlotContoursSetTextListMenuOffset)

                    set(hObject.ContextMenu.Children(dToolsMenuOffset).Children(dToolsPlotContoursMenuOffset).Children(dToolsPlotContoursSetTextListMenuOffset), 'Checked', false);
                end

                % Show Contours

                if ~isempty(dToolsPlotContoursShowContoursMenuOffset)  && ... % Show Contours
                   ~isempty(dToolsPlotContoursShowFaceAlphaMenuOffset) && ... % Show Face Alpha
                   ~isempty(dToolsPlotContoursSetLevelListMenuOffset)  && ... % Set Level List
                   ~isempty(dToolsPlotContoursSetLevelStepMenuOffset)  && ... % Set Level Step
                   ~isempty(dToolsPlotContoursSetLineWidthMenuOffset)  && ... % Set Line Width                 
                   ~isempty(dToolsPlotContoursShowTextMenuOffset)      && ... % Show Text
                   ~isempty(dToolsPlotContoursSetTextListMenuOffset)          % Set Text List

                    if isPlotContours('get') == true
                      
                        % Show Text
                        set(hObject.ContextMenu.Children(dToolsMenuOffset).Children(dToolsPlotContoursMenuOffset).Children(dToolsPlotContoursShowTextMenuOffset)     , 'Enable', 'on');

                        % Show Face Alpha
                        set(hObject.ContextMenu.Children(dToolsMenuOffset).Children(dToolsPlotContoursMenuOffset).Children(dToolsPlotContoursShowFaceAlphaMenuOffset), 'Enable', 'on');

                        % Set Level List
                        set(hObject.ContextMenu.Children(dToolsMenuOffset).Children(dToolsPlotContoursMenuOffset).Children(dToolsPlotContoursSetLevelListMenuOffset) , 'Enable', 'on');

                        % Set Level Step
                        set(hObject.ContextMenu.Children(dToolsMenuOffset).Children(dToolsPlotContoursMenuOffset).Children(dToolsPlotContoursSetLevelStepMenuOffset) , 'Enable', 'on');

                        % Set Line Width        
                        set(hObject.ContextMenu.Children(dToolsMenuOffset).Children(dToolsPlotContoursMenuOffset).Children(dToolsPlotContoursSetLineWidthMenuOffset) , 'Enable', 'on');

                        % Set Text List
                        if size(dicomBuffer('get', [], dSeriesOffset), 3) == 1 % 2D Image

                            if isShowTextContours('get', 'axe') == true

                                set(hObject.ContextMenu.Children(dToolsMenuOffset).Children(dToolsPlotContoursMenuOffset).Children(dToolsPlotContoursSetTextListMenuOffset)  , 'Enable', 'on');
                            else
                                set(hObject.ContextMenu.Children(dToolsMenuOffset).Children(dToolsPlotContoursMenuOffset).Children(dToolsPlotContoursSetTextListMenuOffset)  , 'Enable', 'off');
                            end
                        else
                            if isShowTextContours('get', 'coronal')  == true || ...
                               isShowTextContours('get', 'sagittal') == true || ...
                               isShowTextContours('get', 'axial')    == true || ...
                               isShowTextContours('get', 'mip')      == true
                                
                                set(hObject.ContextMenu.Children(dToolsMenuOffset).Children(dToolsPlotContoursMenuOffset).Children(dToolsPlotContoursSetTextListMenuOffset)  , 'Enable', 'on');
                            else
                                set(hObject.ContextMenu.Children(dToolsMenuOffset).Children(dToolsPlotContoursMenuOffset).Children(dToolsPlotContoursSetTextListMenuOffset)  , 'Enable', 'off');
                            end
                        end
                    else
                        % Show Text
                        set(hObject.ContextMenu.Children(dToolsMenuOffset).Children(dToolsPlotContoursMenuOffset).Children(dToolsPlotContoursShowTextMenuOffset)     , 'Enable', 'off');
                        % Show Face Alpha
                        set(hObject.ContextMenu.Children(dToolsMenuOffset).Children(dToolsPlotContoursMenuOffset).Children(dToolsPlotContoursShowFaceAlphaMenuOffset), 'Enable', 'off');
                        % Set Level List
                        set(hObject.ContextMenu.Children(dToolsMenuOffset).Children(dToolsPlotContoursMenuOffset).Children(dToolsPlotContoursSetLevelListMenuOffset) , 'Enable', 'off');
                        % Set Level Step
                        set(hObject.ContextMenu.Children(dToolsMenuOffset).Children(dToolsPlotContoursMenuOffset).Children(dToolsPlotContoursSetLevelStepMenuOffset) , 'Enable', 'off');
                        % Set Line Width        
                        set(hObject.ContextMenu.Children(dToolsMenuOffset).Children(dToolsPlotContoursMenuOffset).Children(dToolsPlotContoursSetLineWidthMenuOffset) , 'Enable', 'off');
                        % Set Text List
                        set(hObject.ContextMenu.Children(dToolsMenuOffset).Children(dToolsPlotContoursMenuOffset).Children(dToolsPlotContoursSetTextListMenuOffset)  , 'Enable', 'off');
                    end
                end

                % Edge Detection

                if ~isempty(dToolsEdgeDetectionMenuOffset)

                    if strcmpi(get(hObject, 'Tag'), 'Fusion Colorbar')

                        if isscalar(atInput)

                            if atInput(dFusedSeriesOffset).bFusedEdgeDetection == true

                                set(findall(hObject.ContextMenu.Children(dToolsMenuOffset).Children(dToolsEdgeDetectionMenuOffset), 'Label', 'Edge Detection'), 'Checked', 'on');
                            end
                        else
                            if atInput(dFusedSeriesOffset).bEdgeDetection == true

                                set(findall(hObject.ContextMenu.Children(dToolsMenuOffset).Children(dToolsEdgeDetectionMenuOffset), 'Label', 'Edge Detection'), 'Checked', 'on');
                            end
                        end

                        % sModality = atInput(dFusedSeriesOffset).atDicomInfo{1}.Modality;
                    % else
                
                        % sModality = atInput(dSeriesOffset).atDicomInfo{1}.Modality;
                    end         
                end
            end
        end

        % Multi Fusion

        if ~isempty(dMultiFusionMenuOffset)

            if strcmpi(get(hObject, 'Tag'), 'Fusion Colorbar')

                dMultiFusionCombineRGBMenuOffset = [];
                dMultiFusionNormalizeToLiverMenuOffset = [];
                dMultiFusionIntensityMinMaxMenuOffset = [];
                dMultiFusionShowRGBColormapMenuOffset = [];
                dMultiFusionRGBPlusMenuOffset = [];
                dMultiFusionRGBBlockMenuOffset = [];
                dMultiFusionRGBWheelMenuOffset = [];
                dMultiFusionRGBCubeMenuOffset = [];
                 
                for mf=1:numel(hObject.ContextMenu.Children(dMultiFusionMenuOffset).Children)

                    % Combine RGB 
                    if strcmpi(hObject.ContextMenu.Children(dMultiFusionMenuOffset).Children(mf).Text, 'Combine RGB') 

                        dMultiFusionCombineRGBMenuOffset = mf;
                    end

                    % Normalize to Liver
                    if strcmpi(hObject.ContextMenu.Children(dMultiFusionMenuOffset).Children(mf).Text, 'Normalize to Liver') 

                        dMultiFusionNormalizeToLiverMenuOffset = mf;
                    end    

                    % Intensity Min\Max
                    if strcmpi(hObject.ContextMenu.Children(dMultiFusionMenuOffset).Children(mf).Text, 'Intensity Min\Max') 

                        dMultiFusionIntensityMinMaxMenuOffset = mf;
                    end    

                    % Show RGB Colormap
                    if strcmpi(hObject.ContextMenu.Children(dMultiFusionMenuOffset).Children(mf).Text, 'Show RGB Colormap') 

                        dMultiFusionShowRGBColormapMenuOffset = mf;
                    end  

                    % RGB plus
                    if strcmpi(hObject.ContextMenu.Children(dMultiFusionMenuOffset).Children(mf).Text, 'RGB plus') 

                        dMultiFusionRGBPlusMenuOffset = mf;
                    end    

                    % RGB block
                    if strcmpi(hObject.ContextMenu.Children(dMultiFusionMenuOffset).Children(mf).Text, 'RGB block') 

                        dMultiFusionRGBBlockMenuOffset = mf;
                    end        

                    % RGB wheel
                    if strcmpi(hObject.ContextMenu.Children(dMultiFusionMenuOffset).Children(mf).Text, 'RGB wheel') 

                        dMultiFusionRGBWheelMenuOffset = mf;
                    end  

                    % RGB cube 
                    if strcmpi(hObject.ContextMenu.Children(dMultiFusionMenuOffset).Children(mf).Text, 'RGB cube') 

                        dMultiFusionRGBCubeMenuOffset = mf;
                    end                 

                end

                % Combine RGB

                if ~isempty(dMultiFusionCombineRGBMenuOffset)
        
                    if isCombineMultipleFusion('get') == true

                        set(hObject.ContextMenu.Children(dMultiFusionMenuOffset).Children(dMultiFusionCombineRGBMenuOffset), 'Checked', true);
                    else
                        set(hObject.ContextMenu.Children(dMultiFusionMenuOffset).Children(dMultiFusionCombineRGBMenuOffset), 'Checked', false);
                    end

                    set(hObject.ContextMenu.Children(dMultiFusionMenuOffset).Children(dMultiFusionCombineRGBMenuOffset), 'Enable', 'on');
                end

                % Normalize to Liver

                if ~isempty(dMultiFusionNormalizeToLiverMenuOffset)

                    set(hObject.ContextMenu.Children(dMultiFusionMenuOffset).Children(dMultiFusionNormalizeToLiverMenuOffset), 'Checked', false);

                    if isCombineMultipleFusion('get') == true && ...
                       isVsplash('get') == false

                        if isRGBFusionNormalizeToLiver('get') == false

                            set(hObject.ContextMenu.Children(dMultiFusionMenuOffset).Children(dMultiFusionNormalizeToLiverMenuOffset), 'Enable', 'on');
                        else
                            set(hObject.ContextMenu.Children(dMultiFusionMenuOffset).Children(dMultiFusionNormalizeToLiverMenuOffset), 'Enable', 'off');
                        end
                    else
                        set(hObject.ContextMenu.Children(dMultiFusionMenuOffset).Children(dMultiFusionNormalizeToLiverMenuOffset), 'Enable', 'off');
                    end
                end

                % Intensity Min\Max

                if ~isempty(dMultiFusionIntensityMinMaxMenuOffset)
                    
                    set(hObject.ContextMenu.Children(dMultiFusionMenuOffset).Children(dMultiFusionIntensityMinMaxMenuOffset), 'Checked', false);

                    if isCombineMultipleFusion('get') == true

                        set(hObject.ContextMenu.Children(dMultiFusionMenuOffset).Children(dMultiFusionIntensityMinMaxMenuOffset), 'Enable', 'on');
                    else
                        set(hObject.ContextMenu.Children(dMultiFusionMenuOffset).Children(dMultiFusionIntensityMinMaxMenuOffset), 'Enable', 'off');
                    end
                end
                
                % Show RGB Colormap

                if ~isempty(dMultiFusionShowRGBColormapMenuOffset)
                    
                    if size(dicomBuffer('get', [], dSeriesOffset), 3) == 1 || ...
                       isVsplash('get') == true

                        set(hObject.ContextMenu.Children(dMultiFusionMenuOffset).Children(dMultiFusionShowRGBColormapMenuOffset), 'Enable', 'off');
                    else
                        set(hObject.ContextMenu.Children(dMultiFusionMenuOffset).Children(dMultiFusionShowRGBColormapMenuOffset), 'Enable', 'on');
                    end

                    axeRGBImage = axeRGBImagePtr('get');
                    if ~isempty(axeRGBImage)
                        set(hObject.ContextMenu.Children(dMultiFusionMenuOffset).Children(dMultiFusionShowRGBColormapMenuOffset), 'Checked', false);
                    else
                        set(hObject.ContextMenu.Children(dMultiFusionMenuOffset).Children(dMultiFusionShowRGBColormapMenuOffset), 'Checked', true);
                    end
                end

                % RGB plus
                % RGB block    
                % RGB wheel
                % RGB cube 

                if ~isempty(dMultiFusionRGBPlusMenuOffset)  && ... % RGB plus
                   ~isempty(dMultiFusionRGBBlockMenuOffset) && ... % RGB block
                   ~isempty(dMultiFusionRGBWheelMenuOffset) && ... % RGB wheel
                   ~isempty(dMultiFusionRGBCubeMenuOffset)         % RGB cube

                    if ~isempty(axeRGBImage) && ...
                       size(dicomBuffer('get', [], dSeriesOffset), 3) ~= 1 && ...
                       isVsplash('get') == false

                        set(hObject.ContextMenu.Children(dMultiFusionMenuOffset).Children(dMultiFusionRGBPlusMenuOffset) , 'Enable', 'on'); % RGB plus
                        set(hObject.ContextMenu.Children(dMultiFusionMenuOffset).Children(dMultiFusionRGBBlockMenuOffset), 'Enable', 'on'); % RGB block
                        set(hObject.ContextMenu.Children(dMultiFusionMenuOffset).Children(dMultiFusionRGBWheelMenuOffset), 'Enable', 'on'); % RGB wheel
                        set(hObject.ContextMenu.Children(dMultiFusionMenuOffset).Children(dMultiFusionRGBCubeMenuOffset) , 'Enable', 'on'); % RGB cube
                    else
                        set(hObject.ContextMenu.Children(dMultiFusionMenuOffset).Children(dMultiFusionRGBPlusMenuOffset) , 'Enable', 'off'); % RGB plus
                        set(hObject.ContextMenu.Children(dMultiFusionMenuOffset).Children(dMultiFusionRGBBlockMenuOffset), 'Enable', 'off'); % RGB block
                        set(hObject.ContextMenu.Children(dMultiFusionMenuOffset).Children(dMultiFusionRGBWheelMenuOffset), 'Enable', 'off'); % RGB wheel
                        set(hObject.ContextMenu.Children(dMultiFusionMenuOffset).Children(dMultiFusionRGBCubeMenuOffset) , 'Enable', 'off'); % RGB cube
                    end
            
                    sImageName = getRGBColormapImage('get');

                    % RGB plus
                    if strcmpi(sImageName, 'rgb-plus.png')

                        set(hObject.ContextMenu.Children(dMultiFusionMenuOffset).Children(dMultiFusionRGBPlusMenuOffset) , 'Checked', true);  % RGB plus
                    else
                        set(hObject.ContextMenu.Children(dMultiFusionMenuOffset).Children(dMultiFusionRGBPlusMenuOffset) , 'Checked', false); % RGB plus
                    end
                    
                    % RGB block
                    if strcmpi(sImageName, 'rgb-block.png')

                        set(hObject.ContextMenu.Children(dMultiFusionMenuOffset).Children(dMultiFusionRGBBlockMenuOffset), 'Checked', true);  % RGB block
                    else
                        set(hObject.ContextMenu.Children(dMultiFusionMenuOffset).Children(dMultiFusionRGBBlockMenuOffset), 'Checked', false); % RGB block
                    end
                    
                    % RGB wheel
                    if strcmpi(sImageName, 'rgb-wheel.png')

                        set(hObject.ContextMenu.Children(dMultiFusionMenuOffset).Children(dMultiFusionRGBWheelMenuOffset), 'Checked', true);  % RGB wheel
                    else
                        set(hObject.ContextMenu.Children(dMultiFusionMenuOffset).Children(dMultiFusionRGBWheelMenuOffset), 'Checked', false); % RGB wheel
                    end 
                    
                    % RGB cube
                    if strcmpi(sImageName, 'rgb-cube.png')

                        set(hObject.ContextMenu.Children(dMultiFusionMenuOffset).Children(dMultiFusionRGBCubeMenuOffset) , 'Checked', true);  % RGB cube
                    else
                        set(hObject.ContextMenu.Children(dMultiFusionMenuOffset).Children(dMultiFusionRGBCubeMenuOffset) , 'Checked', false); % RGB cube
                    end
                end
            end

        end        
    end

end
