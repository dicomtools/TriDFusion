function setRegistrationCallback(~, ~)
%function setRegistrationCallback(~, ~)
%Set Registration and Resampling Main Function.
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

    FIG_REGISTRATION_X = 850;
    FIG_REGISTRATION_Y = 745;

    if numel(seriesDescription('get')) < 2
        return;
    end

    tRegistration = registrationTemplate('get');

    if viewerUIFigure('get') == true

        dlgRegister = ...
            uifigure('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-FIG_REGISTRATION_X/2) ...
                                (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-FIG_REGISTRATION_Y/2) ...
                                FIG_REGISTRATION_X ...
                                FIG_REGISTRATION_Y ...
                                ],...
                   'Resize', 'off', ...
                   'Color', viewerBackgroundColor('get'),...
                   'WindowStyle', 'modal', ...
                   'Name' , 'Image Registration'...
                   );
    else

        dlgRegister = ...
            dialog('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-FIG_REGISTRATION_X/2) ...
                                (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-FIG_REGISTRATION_Y/2) ...
                                FIG_REGISTRATION_X ...
                                FIG_REGISTRATION_Y ...
                                ],...
                   'Color', viewerBackgroundColor('get'),...
                   'Name' , 'Image Registration'...
                   );
    end

    axeRegister = ...
        axes(dlgRegister, ...
             'Units'   , 'pixels', ...
             'Position', [0 0 FIG_REGISTRATION_X FIG_REGISTRATION_Y], ...
             'Color'   , viewerBackgroundColor('get'),...
             'XColor'  , viewerForegroundColor('get'),...
             'YColor'  , viewerForegroundColor('get'),...
             'ZColor'  , viewerForegroundColor('get'),...
             'Visible' , 'off'...
             );
    axeRegister.Interactions = [zoomInteraction regionZoomInteraction rulerPanInteraction];
    axeRegister.Toolbar = [];
%    if integrateToBrowser('get') == true
%        sLogo = './TriDFusion/logo.png';
%    else
%        sLogo = './logo.png';
%    end

%    javaFrame = get(dlgRegister,'JavaFrame');
%    javaFrame.setFigureIcon(javax.swing.ImageIcon(sLogo));

    lbRegWindow = ...
        uicontrol(dlgRegister,...
                  'style'   , 'listbox',...
                  'position', [365 0 485 745],...
                  'fontsize', 10,...
                  'Fontname', 'Monospaced',...
                  'Value'   , 1 ,...
                  'Selected', 'on',...
                  'enable'  , 'on',...
                  'string'  , seriesDescription('get'),...
                  'BackgroundColor', viewerAxesColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @lbRegWindowCallback...
                  );

    set(lbRegWindow, 'Max',2, 'Min',0);

         uicontrol(dlgRegister,...
                  'String','Reset',...
                  'Position',[15 700 100 25],...
                  'BackgroundColor', [0.2 0.039 0.027], ...
                  'ForegroundColor', [0.94 0.94 0.94], ...
                  'Callback', @resetRegistrationCallback...
                  );

     chkRegSeriesDescription = ...
          uicontrol(dlgRegister,...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , updateDescription('get'),...
                  'position', [220 650 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @updateRegDescriptionCallback...
                  );

          uicontrol(dlgRegister,...
                  'style'   , 'text',...
                  'FontWeight', 'bold',...
                  'string'  , 'Update Series Description',...
                  'horizontalalignment', 'left',...
                  'position', [15 647 200 20],...
                  'Enable', 'Inactive',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'ButtonDownFcn', @updateRegDescriptionCallback...
                  );

     chkRegResampleRegistration = ...
          uicontrol(dlgRegister,...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , referenceOutputView('get'),...
                  'position', [220 625 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @resampleRegistrationCallback...
                  );

          uicontrol(dlgRegister,...
                  'style'   , 'text',...
                  'FontWeight', 'bold',...
                  'string'  , 'Reference Output View',...
                  'horizontalalignment', 'left',...
                  'position', [15 622 200 20],...
                  'Enable', 'Inactive',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'ButtonDownFcn', @resampleRegistrationCallback...
                  );

    % Image Resampling

        uicontrol(dlgRegister,...
                  'style'   , 'text',...
                  'FontWeight', 'bold',...
                  'string'  , 'Image Resampling',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 575 200 20]...
                  );


          uicontrol(dlgRegister,...
                  'style'   , 'text',...
                  'string'  , 'Interpolation',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 547 200 20]...
                  );

    switch lower(tRegistration.Interpolation)
        case 'nearest'
            dInterpolation = 1;
        case 'linear'
            dInterpolation = 2;
        case 'cubic'
            dInterpolation = 3;
        case 'bilinear'
            dInterpolation = 4;
        case 'bicubic'
            dInterpolation = 5;            
        otherwise
            dInterpolation = 2;
    end

    uiInterpolation = ...
        uicontrol(dlgRegister, ...
                  'Style'   , 'popup', ...
                  'position', [220 550 130 20],...
                  'String'  , {'Nearest', 'Linear', 'Cubic', 'Bilinear', 'Bicubic'}, ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Value'   , dInterpolation, ...
                  'Callback', @interpolationCallback...
                  );

        uicontrol(dlgRegister,...
                  'String','Resample',...
                  'Position',[250 515 100 25],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @resampleCallback...
                  );

    % Image Registration

        uicontrol(dlgRegister,...
                  'style'   , 'text',...
                  'FontWeight', 'bold',...
                  'string'  , 'Image Registration',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 475 200 20]...
                  );

     chkRegAssociateSeries = ...
          uicontrol(dlgRegister,...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , associateRegistrationModality('get'),...
                  'position', [220 450 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @associateRegistrationCallback...
                  );

          uicontrol(dlgRegister,...
                  'style'   , 'text',...
                  'string'  , 'Move Associated Series',...
                  'horizontalalignment', 'left',...
                  'position', [15 447 200 20],...
                  'Enable', 'Inactive',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'ButtonDownFcn', @associateRegistrationCallback...
                  );


    % Transformation

          uicontrol(dlgRegister,...
                  'style'   , 'text',...
                  'string'  , 'Transformation',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 422 200 20]...
                  );

    switch lower(tRegistration.Transformation)
        case 'translation'
            dTransformValue = 1;
        case 'rigid'
            dTransformValue = 2;
        case 'similarity'
            dTransformValue = 3;
        case 'affine'
            dTransformValue = 4;
        case 'deformable'
            dTransformValue = 5;
        otherwise
            dTransformValue = 1;
    end

    uiTransformation = ...
        uicontrol(dlgRegister, ...
                  'Style'          , 'popup', ...
                  'position'       , [220 425 130 20],...
                  'String'         , {'Translation', 'Rigid', 'Similarity', 'Affine', 'Deformable'}, ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Value'          , dTransformValue, ...
                  'Callback'       , @setRegistrationTransformationCallback ...
                  );
    
    % Grid Regularization

    txtGridRegularization = ...
        uicontrol(dlgRegister,...
                  'style'   , 'text',...
                  'string'  , 'Grid Regularization',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 397 200 20]...
                  );

    uiGridRegularization = ...
        uicontrol(dlgRegister,...
                  'style'     , 'edit',...
                  'Background', 'white',...
                  'string'    , num2str(tRegistration.Deformable.GridRegularization),...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position'  , [220 400 130 20]...
                  );

    % Number Of Pyramid Levels

    txtPyramidLevelsMode = ...
        uicontrol(dlgRegister,...
                  'style'   , 'text',...
                  'string'  , 'Pyramid Levels Mode',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 347 200 20]...
                  );

    switch lower(tRegistration.Deformable.NumberOfPyramidLevelsMode)
        case 'automatic'
            dPyramidLevelsMode = 1;
        case 'manual'
            dPyramidLevelsMode = 2;
        otherwise
            dPyramidLevelsMode = 1;
    end

    uiPyramidLevelsMode = ...
        uicontrol(dlgRegister, ...
                  'Style'   , 'popup', ...
                  'Enable'  , 'on', ... 
                  'position', [220 350 130 20],...
                  'String'  , {'Automatic', 'Manual'}, ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Value'          , dPyramidLevelsMode, ...
                  'Callback'       , @setRegistrationTransformationCallback ...
                  );

    txtNumberOfPyramidLevels = ...
        uicontrol(dlgRegister,...
                  'style'   , 'text',...
                  'string'  , 'Number Of Pyramid Levels',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 322 200 20]...
                  );

    if strcmpi(tRegistration.Deformable.NumberOfPyramidLevelsMode, 'Automatic')
        sNumberOfPyramidLevelsEnable = 'off';
    else
        sNumberOfPyramidLevelsEnable = 'on';
    end

    uiNumberOfPyramidLevels = ...
        uicontrol(dlgRegister,...
                  'style'     , 'edit',...
                  'Enable'    , sNumberOfPyramidLevelsEnable, ... 
                  'Background', 'white',...
                  'string'    , num2str(tRegistration.Deformable.NumberOfPyramidLevels),...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position'  , [220 325 130 20]...
                  );

    % Grid Spacing

    txtGridSpacingMode = ...
        uicontrol(dlgRegister,...
                  'style'   , 'text',...
                  'string'  , 'Grid Spacing Mode',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 272 200 20]...
                  );

    switch lower(tRegistration.Deformable.GridSpacingMode)
        case 'automatic'
            dGridSpacingMode = 1;
        case 'manual'
            dGridSpacingMode = 2;
        otherwise
            dGridSpacingMode = 1;
    end

    uiGridSpacingMode = ...
        uicontrol(dlgRegister, ...
                  'Style'   , 'popup', ...
                  'Enable'  , 'on', ... 
                  'position', [220 275 130 20],...
                  'String'  , {'Automatic', 'Manual'}, ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Value'          , dGridSpacingMode, ...
                  'Callback'       , @setRegistrationTransformationCallback ...
                  );

    txtGridSpacing = ...
        uicontrol(dlgRegister,...
                  'style'   , 'text',...
                  'string'  , 'Grid Spacing',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 247 200 20]...
                  );

    if strcmpi(tRegistration.Deformable.GridSpacingMode, 'Automatic')
        sGridSpacingEnable = 'off';
    else
        sGridSpacingEnable = 'on';
    end

    uiGridSpacing = ...
        uicontrol(dlgRegister,...
                  'style'     , 'edit',...
                  'Enable'    , sGridSpacingEnable, ... 
                  'Background', 'white',...
                  'string'    , num2str(tRegistration.Deformable.GridSpacing),...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position'  , [220 250 130 20]...
                  );

    % Pixel Resolution 

    txtPixelResolutionMode = ...
        uicontrol(dlgRegister,...
                  'style'   , 'text',...
                  'string'  , 'Pixel Resolution Mode',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 197 200 20]...
                  );

    switch lower(tRegistration.Deformable.PixelResolutionMode)
        case 'automatic'
            dPixelResolutionMode = 1;
        case 'manual'
            dPixelResolutionMode = 2;
        otherwise
            dPixelResolutionMode = 1;
    end

    uiPixelResolutionMode = ...
        uicontrol(dlgRegister, ...
                  'Style'   , 'popup', ...
                  'Enable'  , 'on', ... 
                  'position', [220 200 130 20],...
                  'String'  , {'Automatic', 'Manual'}, ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Value'          , dPixelResolutionMode, ...
                  'Callback'       , @setRegistrationTransformationCallback ...
                  );

    txtPixelResolution = ...
        uicontrol(dlgRegister,...
                  'style'   , 'text',...
                  'string'  , 'Pixel Resolution',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 172 200 20]...
                  );

    if strcmpi(tRegistration.Deformable.PixelResolutionMode, 'Automatic')
        sPixelResolutionEnable = 'off';
    else
        sPixelResolutionEnable = 'on';
    end

    uiPixelResolution = ...
        uicontrol(dlgRegister,...
                  'style'     , 'edit',...
                  'Enable'    , sPixelResolutionEnable, ... 
                  'Background', 'white',...
                  'string'    , num2str(tRegistration.Deformable.PixelResolution),...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position'  , [220 175 130 20]...
                  );

    % Modality

    txtSeriesIntensity = ...
        uicontrol(dlgRegister,...
                  'style'   , 'text',...
                  'string'  , 'Series Intensity',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 397 200 20]...
                  );

    switch lower(tRegistration.Modality)
        case 'automatic'
            dModalityValue = 1;
        case 'monomodal'
            dModalityValue = 2;
        case 'multimodal'
            dModalityValue = 3;
        otherwise
            dModalityValue = 1;
    end


    uiModality = ...
        uicontrol(dlgRegister, ...
                  'Style'   , 'popup', ...
                  'Enable'  , 'on', ... 
                  'position', [220 400 130 20],...
                  'String'  , {'Automatic', 'Monomodal', 'Multimodal'}, ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Value'          , dModalityValue, ...
                  'Callback'       , @setRegistrationModalityCallback ...
                  );

    % Matric (Multimodal)

    if strcmpi(tRegistration.Modality, 'automatic') || ...
       strcmpi(tRegistration.Modality, 'multimodal')

        sMetricEnable = 'on';
        
    else
        sMetricEnable = 'off';
    end
    
    txtMatric = ...
        uicontrol(dlgRegister,...
                  'style'   , 'text',...
                  'FontWeight', 'bold',...
                  'string'  , 'Matric (Multimodal)',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 375 200 20]...
                  );

    % Nb Of Spatial Samples

    txtNbOfSpatialSamples = ...
        uicontrol(dlgRegister,...
                  'style'   , 'text',...
                  'string'  , 'Nb Of Spatial Samples',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 347 200 20]...
                  );

    uiNumberOfSpatialSamples = ...
        uicontrol(dlgRegister,...
                  'enable'    , sMetricEnable,...
                  'style'     , 'edit',...
                  'Background', 'white',...
                  'string'    , num2str(tRegistration.Metric.NumberOfSpatialSamples),...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position'  , [220 350 130 20]...
                  );

    % Nb Of Histogram Bins  

    txtNbOfHistogramBins = ...
        uicontrol(dlgRegister,...
                  'style'   , 'text',...
                  'string'  , 'Nb Of Histogram Bins',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 322 200 20]...
                  );

    uiNumberOfHistogramBins = ...
         uicontrol(dlgRegister,...
                  'enable'    , sMetricEnable,...
                  'style'     , 'edit',...
                  'Background', 'white',...
                  'string'    , num2str(tRegistration.Metric.NumberOfHistogramBins),...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position'  , [220 325 130 20]...
                  );

    % Use All Pixels

    txtUseAllPixels = ...
        uicontrol(dlgRegister,...
                  'style'   , 'text',...
                  'string'  , 'Use All Pixels',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 297 200 20]...
                  );

    if tRegistration.Metric.UseAllPixels == true
        dAllPixelsValue = 1;
    else
        dAllPixelsValue = 2;
    end

    uiUseAllPixels = ...
        uicontrol(dlgRegister, ...
                  'Style'   , 'popup', ...
                  'enable'    , sMetricEnable,...
                  'position', [220 300 130 20],...
                  'String'  , {'True' 'False'}, ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Value'   , dAllPixelsValue ...
                  );

    % Optimizer (Multimodal)

    if strcmpi(tRegistration.Modality, 'automatic') || ...
       strcmpi(tRegistration.Modality, 'multimodal')

        sOptimizerMultimodalEnable = 'on';
        
    else
        sOptimizerMultimodalEnable = 'off';
    end

    txtOptimizerMultimodal = ...
        uicontrol(dlgRegister,...
                  'style'   , 'text',...
                  'FontWeight', 'bold',...
                  'string'  , 'Optimizer (Multimodal)',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 275 200 20]...
                  );

    % Growth Factor

    txtGrowthFactor = ...
         uicontrol(dlgRegister,...
                  'style'   , 'text',...
                  'string'  , 'Growth Factor',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 247 200 20]...
                  );

    uiGrowthFactor = ...
        uicontrol(dlgRegister,...
                  'enable'    , sOptimizerMultimodalEnable,...
                  'style'     , 'edit',...
                  'Background', 'white',...
                  'string'    , num2str(tRegistration.Optimizer.GrowthFactor),...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position'  , [220 250 130 20]...
                  );

    % Epsilon

    txtEpsilon = ...
        uicontrol(dlgRegister,...
                  'style'   , 'text',...
                  'string'  , 'Epsilon (e-06)',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 222 200 20]...
                  );

    uiEpsilon = ...
         uicontrol(dlgRegister,...
                  'enable'    , sOptimizerMultimodalEnable,...
                  'style'     , 'edit',...
                  'Background', 'white',...
                  'string'    , num2str(tRegistration.Optimizer.Epsilon/1e-06),...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position'  , [220 225 130 20]...
                  );

    % Initial Radius

    txtInitialRadius = ...
        uicontrol(dlgRegister,...
                  'style'   , 'text',...
                  'string'  , 'Initial Radius (e-03)',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 197 200 20]...
                  );

    uiInitialRadius = ...
         uicontrol(dlgRegister,...
                  'enable'    , sOptimizerMultimodalEnable,...
                  'style'     , 'edit',...
                  'Background', 'white',...
                  'string'    , num2str(tRegistration.Optimizer.InitialRadius/1e-03),...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position'  , [220 200 130 20]...
                  );

    % Optimizer (Monomodal)

    if strcmpi(tRegistration.Modality, 'automatic') || ...
       strcmpi(tRegistration.Modality, 'monomodal')

         sOptimizerMonomodalEnable = 'on';
        
    else
        sOptimizerMonomodalEnable = 'off';
    end
    
    txtOptimizerMonomodal = ...
        uicontrol(dlgRegister,...
                  'style'   , 'text',...
                  'FontWeight', 'bold',...
                  'string'  , 'Optimizer (Monomodal)',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 175 200 20]...
                  );

    % Gradient Magnitude Tolerance
    
    txtGradientTolerance =...
        uicontrol(dlgRegister,...
                  'style'   , 'text',...
                  'string'  , 'Gradient Tolerance (e-04)',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 147 200 20]...
                  );

    uiGradientMagnitudeTolerance = ...
        uicontrol(dlgRegister,...
                  'enable'    , sOptimizerMonomodalEnable,...
                  'style'     , 'edit',...
                  'Background', 'white',...
                  'string'    , num2str(tRegistration.Optimizer.GradientMagnitudeTolerance/1e-04),...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position'  , [220 150 130 20]...
                  );

    % Minimum Step Length

    txtMinimumStepLength = ...
        uicontrol(dlgRegister,...
                  'style'   , 'text',...
                  'string'  , 'Minimum Step Length (e-05)',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 122 200 20]...
                  );

    uiMinimumStepLength = ...
        uicontrol(dlgRegister,...
                  'enable'    , sOptimizerMonomodalEnable,...
                  'style'     , 'edit',...
                  'Background', 'white',...
                  'string'    , num2str(tRegistration.Optimizer.MinimumStepLength/1e-05),...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position'  , [220 125 130 20]...
                  );

    % Maximum Step Length

    txtMaximumStepLength = ...
        uicontrol(dlgRegister,...
                  'style'   , 'text',...
                  'string'  , 'Maximum Step Length (e-02)',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 97 200 20]...
                  );

    uiMaximumStepLength = ...
        uicontrol(dlgRegister,...
                  'enable'    , sOptimizerMonomodalEnable,...
                  'style'     , 'edit',...
                  'Background', 'white',...
                  'string'    , num2str(tRegistration.Optimizer.MaximumStepLength/1e-02),...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position'  , [220 100 130 20]...
                  );

    % Relaxation Factor
    
    txtRelaxationFactor = ...
        uicontrol(dlgRegister,...
                  'style'   , 'text',...
                  'string'  , 'Relaxation Factor (e-01)',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 72 200 20]...
                  );

    uiRelaxationFactor = ...
        uicontrol(dlgRegister,...
                  'enable'    , sOptimizerMonomodalEnable,...
                  'style'     , 'edit',...
                  'Background', 'white',...
                  'string'    , num2str(tRegistration.Optimizer.RelaxationFactor/1e-01),...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position'  , [220 75 130 20]...
                  );

    % Maximum Iterations
    
    txtMaximumIterations = ...
        uicontrol(dlgRegister,...
                  'style'   , 'text',...
                  'string'  , 'Maximum Iterations',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [15 47 200 20]...
                  );

    uiMaximumIterations = ...
         uicontrol(dlgRegister,...
                  'enable'    , sOptimizerMonomodalEnable,...
                  'style'     , 'edit',...
                  'Background', 'white',...
                  'string'    , num2str(tRegistration.Optimizer.MaximumIterations),...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position'  , [220 50 130 20]...
                  );

        uicontrol(dlgRegister,...
                  'String','Register',...
                  'Position',[250 15 100 25],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @registerCallback...
                  );

    adLbSeries = zeros(size(seriesDescription('get')));
    dNextPosition = 1;

    setRegistrationTransformationCallback();

    function lbRegWindowCallback(~, ~)

        adLbOffset = get(lbRegWindow,  'Value');
        asLbString = get(lbRegWindow,  'String');
        asSeriesString = seriesDescription('get');

        if numel(adLbOffset) > numel(asLbString) || ...
           isempty(seriesDescription('get'))
            return;
        end

        if numel(adLbOffset) == 0 % No entry
            set(lbRegWindow, 'String', seriesDescription('get'));
            for jj=1:numel(adLbSeries)
                adLbSeries(jj) = 0;
            end
        elseif numel(adLbOffset) == 1 % First Entry
            dLbOffset = adLbOffset(1);

            for jj=1:numel(adLbSeries)
                if jj==dLbOffset
                    adLbSeries(dLbOffset) = 1;
                    asSeriesString{dLbOffset} = sprintf('1- %s', asSeriesString{dLbOffset});
                    dNextPosition = 2;
                else
                    adLbSeries(jj) = 0;
                end
            end

            set(lbRegWindow, 'String', asSeriesString);
        else
            dNbElementCurrent = 1;
            for ll=1:numel(adLbSeries) % Count Number of element are currently set to a position
                if adLbSeries(ll) ~= 0
                    dNbElementCurrent = dNbElementCurrent+1;
                end
            end

            if dNbElementCurrent > numel(adLbOffset) % Substract one position
                adNewSeries = zeros(size(seriesDescription('get')));
                for jj=1:numel(adNewSeries) % Set a new array
                    for kk=1:numel(adLbOffset)
                        if adLbOffset(kk)==jj
                            adNewSeries(jj)=adLbSeries(adLbOffset(kk));
                        end
                    end
                end

                for jj=1:numel(adNewSeries) % Reset all series with 0
                    if adNewSeries(jj) == 0
                        asLbString{jj}=sprintf('%s', asSeriesString{jj});
                    end
                end

                dMissingElement =1;
                for kk=1:numel(adLbSeries(adLbOffset)) % Find the series offset to substract
                    for jj=1:numel(adNewSeries)
                        if adNewSeries(jj) == dMissingElement
                            dMissingElement = dMissingElement+1;
                        end
                    end
                end

                for jj=1:numel(adNewSeries)
                    if adNewSeries(jj) > dMissingElement
                        adNewSeries(jj) = adNewSeries(jj)-1;
                        asLbString{jj}=sprintf('%d- %s', adNewSeries(jj), asSeriesString{jj});
                    end
                end

                adLbSeries = adNewSeries;
                dNextPosition = dNextPosition -1;

            else  % Add one position

                for jj=1:numel(adLbOffset)
                    dCurOffset = adLbOffset(jj);
                    for kk=1:numel(asSeriesString)
                        if kk==dCurOffset && ...
                           adLbSeries(kk) == 0

                            adLbSeries(kk) = dNextPosition;
                            asLbString{kk}=sprintf('%d- %s', adLbSeries(kk), asSeriesString{kk});
                            dNextPosition = dNextPosition+1;
                        end
                    end

                end
            end

            dListboxTop = get(lbRegWindow, 'ListboxTop');
            set(lbRegWindow, 'String', asLbString);
            set(lbRegWindow, 'ListboxTop', dListboxTop);
        end

    end

    function resetRegistrationCallback(~, ~)

        tInitInput = inputTemplate('get');

        dInitOffset = get(uiSeriesPtr('get'), 'Value');

        try

        % Deactivate main tool bar
        set(uiSeriesPtr('get'), 'Enable', 'off');
        mainToolBarEnable('off');

        set(dlgRegister, 'Pointer', 'watch');
        set(fiMainWindowPtr('get'), 'Pointer', 'watch');
        drawnow;

        for jj=1:numel(tInitInput)
            if jj ~= dInitOffset
                resetSeries(jj, false); % reset without initing the display
            end
        end

        resetSeries(dInitOffset, true);

        delete(dlgRegister);

        progressBar(1,'Ready');

        catch
            progressBar(1, 'Error:resetRegistrationCallback()');
        end

        % Reactivate main tool bar
        set(uiSeriesPtr('get'), 'Enable', 'on');
        mainToolBarEnable('on');

        set(fiMainWindowPtr('get'), 'Pointer', 'default');
        drawnow;

    end

    function interpolationCallback(~, ~)

        asInterpolation       = get(uiInterpolation, 'String');
        dInterpolationOffeset = get(uiInterpolation, 'Value');

        sInterpolation = asInterpolation{dInterpolationOffeset};

        tRegistration.Interpolation = sInterpolation;

        registrationTemplate('set', tRegistration);

    end

    function resampleCallback(~, ~)

        try

        if isFusion('get') == true
            setFusionCallback(); % Deactivate fusion
        end

        if isPlotContours('get') == true
           setPlotContoursCallback(); % Deactivate plot contours
        end

        dNbElements = 0;
        for ll=1:numel(adLbSeries) % Count Number of element are currently set to a position
            if adLbSeries(ll) ~= 0
                dNbElements = dNbElements+1;
            end
        end

        if dNbElements < 2
            progressBar(1, 'Error: At least 2 volumes must be selected!');
            h = msgbox('Error: resampleCallback(): At least 2 volumes must be selected!', 'Error');
%            if integrateToBrowser('get') == true
%                sLogo = './TriDFusion/logo.png';
%            else
%                sLogo = './logo.png';
%            end

%            javaFrame = get(h, 'JavaFrame');
%            javaFrame.setFigureIcon(javax.swing.ImageIcon(sLogo));
            return;
        end

        bResampleAxe = false;

        refImage = [];

        set(dlgRegister, 'Pointer', 'watch');
        set(fiMainWindowPtr('get'), 'Pointer', 'watch');
        drawnow;

        tRegistration = registrationTemplate('get');

        asInterpolation = get(uiInterpolation, 'String');
        sInterpolation  = asInterpolation{get(uiInterpolation, 'Value')};

        tRegistration.Interpolation = lower(sInterpolation);

        registrationTemplate('set', tRegistration);

        releaseRoiWait();

        tInput = inputTemplate('get');
        aInput = inputBuffer('get');

        dInitOffset = get(uiSeriesPtr('get'), 'Value');

        set(uiSeriesPtr('get'), 'Enable', 'off');

        bInitRef = true;
        dNextSeries = 1;
        for hh=1:dNbElements

            for kk=1:numel(adLbSeries)

%                set(uiSeriesPtr('get'), 'Value', kk);
                aBuffer    = dicomBuffer('get', [], kk);

                atMetaData = dicomMetaData('get', [], kk);

                if ~isempty(aInput{kk})

                    if  isempty(aBuffer)

                    %    if     strcmp(imageOrientation('get'), 'axial')
                   %         aBuffer = permute(aInput{kk}, [1 2 3]);
                   %     elseif strcmp(imageOrientation('get'), 'coronal')
                   %         aBuffer = permute(aInput{kk}, [3 2 1]);
                   %     elseif strcmp(imageOrientation('get'), 'sagittal')
                   %         aBuffer = permute(aInput{kk}, [3 1 2]);
                   %     end
                        aBuffer = aInput{kk};

                    end

                    % if isVsplash('get') == false && ...
                    %     ~(size(aInput{kk}, 3) == 1)
                    %     aMip = mipBuffer('get', [], kk);
                    % end

                end

                if isempty(atMetaData)

                    atMetaData = tInput(kk).atDicomInfo;
                end

                if adLbSeries(kk) == 1 && bInitRef == true

                    tInput(adLbSeries(kk)).bEdgeDetection = false;

              %      dInitOffset = kk;
                    bInitRef      = false;
                    atRefMetaData = atMetaData;
                    refImage      = aBuffer;
                    dNextSeries   = 2;

                    dicomBuffer('set', refImage, kk);

                    dicomMetaData('set', atRefMetaData, kk);

                    setQuantification(kk);

                    updateDescription('set', get(chkRegSeriesDescription, 'Value'));
                    % if size(aInput{kk}, 3) ~= 1
                    %     if isVsplash('get') == false
                    %         refMip = aMip;
                    %     end
                    % end

                    break;
                end

                if dNextSeries >1

                    if adLbSeries(kk) == dNextSeries

                        if dInitOffset == kk
                            bResampleAxe = true;
                        end

                        tInput(adLbSeries(kk)).bEdgeDetection = false;

                        progressBar(dNextSeries/dNbElements-0.000001, sprintf('Processing resampling %d/%d, please wait', dNextSeries-1, dNbElements-1));

               %         try
                        [aResampledBuffer, atResampledMetaData] = ...
                            resampleImage(aBuffer       , ...
                                          atMetaData    , ...
                                          refImage      , ...
                                          atRefMetaData , ...
                                          sInterpolation, ...
                                          referenceOutputView('get'), ...
                                          updateDescription('get'), ...
                                          kk);

                        atRoi = roiTemplate('get', kk);

                        atResampledRoi = ...
                            resampleROIs(aBuffer            , ...
                                         atMetaData         , ...
                                         aResampledBuffer   , ...
                                         atResampledMetaData, ...
                                         atRoi              , ...
                                         true);

                        roiTemplate('set', kk, atResampledRoi);

                        if size(aInput{kk}, 3) ~= 1

                            if isVsplash('get') == false

                            %    aResampledMip = resampleMip(aMip, atMetaData, refMip, atRefMetaData, sInterpolation, referenceOutputView('get'));

                                % aResampledMip = computeMIP(aResampledBuffer);

                                mipBuffer('set', computeMIP(aResampledBuffer), kk);
                            end
                        end

                %        catch
                %        end

                        dicomMetaData('set', atResampledMetaData, kk);

                        dicomBuffer('set', aResampledBuffer, kk);

                        clear aResampledBuffer;

                        setQuantification(kk);

                        dNextSeries = dNextSeries+1;

                    end
                end
            end

        end

        progressBar(1, 'Ready');

        inputTemplate('set', tInput);

        % set(uiSeriesPtr('get'), 'Value', dInitOffset);
        set(uiSeriesPtr('get'), 'Enable', 'on');

        set(dlgRegister, 'Pointer', 'default');
        delete(dlgRegister);

%        setQuantification(dInitOffset);

%        clearDisplay();
%        initDisplay(3);

    %    dicomViewerCore();

    %    initWindowLevel('set', true);
    %    quantificationTemplate('set', tInput(dInitOffset).tQuant);

%        dLink2DMip  = link2DMip('get');

%        link2DMip('set', true);

%        set(btnLinkMipPtr('get'), 'BackgroundColor', viewerButtonPushedBackgroundColor('get'));
%        set(btnLinkMipPtr('get'), 'ForegroundColor', viewerButtonPushedForegroundColor('get'));

%        dicomViewerCore();

        setViewerDefaultColor(true, dicomMetaData('get', [], dInitOffset));

%            triangulateCallback();
        if bResampleAxe == true

            if ~isempty(dicomBuffer('get', [], dInitOffset))

                resampleAxes(dicomBuffer('get'), dicomMetaData('get', [], dInitOffset));

                setImagesAspectRatio();
                
                if size(dicomBuffer('get', [], dInitOffset), 3) ~= 1
                    
                    plotRotatedRoiOnMip(axesMipPtr('get', [], dInitOffset), dicomBuffer('get', [], dInitOffset), mipAngle('get'));       
                end               
            end

            % if is3DEngine('get') == true
            %
            %     clearDisplay();
            %
            %     if size(dicomBuffer('get'), 3) == 1
            %         initDisplay(1);
            %     else
            %         initDisplay(3);
            %     end
            %
            %     dicomViewerCore();
            % end
        end

        sliderCorCallback();
        sliderSagCallback();
        sliderTraCallback();
        sliderMipCallback();

%        refreshImages();

%            refreshImages();
%        atMetaData = dicomMetaData('get');

%        if strcmpi(atMetaData{1}.Modality, 'ct') || dLink2DMip == false

%            link2DMip('set', false);

%            set(btnLinkMipPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
%            set(btnLinkMipPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
%        end

        catch
            progressBar(1, 'Error:resampleCallback()');
        end

        set(fiMainWindowPtr('get'), 'Pointer', 'default');
        drawnow;

    end

    function setRegistrationTransformationCallback(~, ~)

        asModality = get(uiTransformation, 'String');
        sTransformation  = asModality{get(uiTransformation, 'Value')};

        if strcmpi(sTransformation, 'Deformable')

            tRegistration = registrationTemplate('get');

            asNumberOfPyramidLevels = get(uiPyramidLevelsMode, 'String');
            sNumberOfPyramidLevels  = asNumberOfPyramidLevels{get(uiPyramidLevelsMode, 'Value')};

            tRegistration.Deformable.NumberOfPyramidLevelsMode = lower(sNumberOfPyramidLevels);

            asGridSpacingMode = get(uiGridSpacingMode, 'String');
            sGridSpacingMode  = asGridSpacingMode{get(uiGridSpacingMode, 'Value')};

            tRegistration.Deformable.GridSpacingMode = lower(sGridSpacingMode);

            asPixelResolutionMode = get(uiPixelResolutionMode, 'String');
            sPixelResolutionMode  = asPixelResolutionMode{get(uiPixelResolutionMode, 'Value')};

            tRegistration.Deformable.PixelResolutionMode = lower(sPixelResolutionMode);

            registrationTemplate('set', tRegistration);

            set(txtGridRegularization, 'visible', 'on');
            set(uiGridRegularization , 'visible', 'on');

            set(txtPyramidLevelsMode, 'visible', 'on');
            set(uiPyramidLevelsMode , 'visible', 'on');

            set(uiNumberOfPyramidLevels , 'Visible', 'on');
            set(txtNumberOfPyramidLevels, 'Visible', 'on');

            set(txtGridSpacingMode, 'Visible', 'on');
            set(uiGridSpacingMode , 'Visible', 'on');

            set(txtGridSpacing, 'Visible', 'on');
            set(uiGridSpacing , 'Visible', 'on');

            set(txtPixelResolutionMode, 'Visible', 'on');
            set(uiPixelResolutionMode , 'Visible', 'on');

            set(txtPixelResolution, 'Visible', 'on');
            set(uiPixelResolution , 'Visible', 'on');

            if strcmpi(tRegistration.Deformable.NumberOfPyramidLevelsMode, 'Automatic')
                sNumberOfPyramidLevelsEnable = 'off';
            else
                sNumberOfPyramidLevelsEnable = 'on';
            end
            set(uiNumberOfPyramidLevels, 'Enable', sNumberOfPyramidLevelsEnable);

            if strcmpi(tRegistration.Deformable.GridSpacingMode, 'Automatic')
                sGridSpacingEnable = 'off';
            else
                sGridSpacingEnable = 'on';
            end
            set(uiGridSpacing, 'Enable', sGridSpacingEnable);

            if strcmpi(tRegistration.Deformable.PixelResolutionMode, 'Automatic')
                sPixelResolutionEnable = 'off';
            else
                sPixelResolutionEnable = 'on';
            end
            set(uiPixelResolution, 'Enable', sPixelResolutionEnable);

            set(txtSeriesIntensity    , 'visible', 'off');
            set(txtMatric             , 'visible', 'off');
            set(txtNbOfSpatialSamples , 'visible', 'off');
            set(txtNbOfHistogramBins  , 'visible', 'off');
            set(txtUseAllPixels       , 'visible', 'off');
            set(txtOptimizerMonomodal , 'visible', 'off');
            set(txtOptimizerMultimodal, 'visible', 'off');
            set(txtGrowthFactor       , 'visible', 'off');
            set(txtEpsilon            , 'visible', 'off');
            set(txtInitialRadius      , 'visible', 'off');
            set(txtGradientTolerance  , 'visible', 'off');
            set(txtMinimumStepLength  , 'visible', 'off');
            set(txtMaximumStepLength  , 'visible', 'off');
            set(txtRelaxationFactor   , 'visible', 'off');
            set(txtMaximumIterations  , 'visible', 'off');

            set(uiModality              , 'visible', 'off');
            set(uiNumberOfSpatialSamples, 'visible', 'off');
            set(uiNumberOfHistogramBins , 'visible', 'off');
            set(uiUseAllPixels          , 'visible', 'off');

            set(uiGrowthFactor , 'visible', 'off');
            set(uiEpsilon      , 'visible', 'off');
            set(uiInitialRadius, 'visible', 'off');

            set(uiGradientMagnitudeTolerance, 'visible', 'off');
            set(uiMinimumStepLength         , 'visible', 'off');
            set(uiMaximumStepLength         , 'visible', 'off');
            set(uiRelaxationFactor          , 'visible', 'off');
            set(uiMaximumIterations         , 'visible', 'off');
        else
            setRegistrationModalityCallback();
        end
    end

    function setRegistrationModalityCallback(~, ~)

        asModality = get(uiTransformation, 'String');
        sTransformation  = asModality{get(uiTransformation, 'Value')};

        if ~strcmpi(sTransformation, 'Deformable')

            tRegistration = registrationTemplate('get');

            asModality = get(uiModality, 'String');
            sModality  = asModality{get(uiModality, 'Value')};

            tRegistration.Modality = lower(sModality);

            registrationTemplate('set', tRegistration);

            set(txtGridRegularization, 'visible', 'off');
            set(uiGridRegularization , 'visible', 'off');

            set(txtPyramidLevelsMode, 'visible', 'off');
            set(uiPyramidLevelsMode , 'visible', 'off');

            set(txtNumberOfPyramidLevels, 'Visible', 'off');
            set(uiNumberOfPyramidLevels , 'Visible', 'off');

            set(txtGridSpacingMode, 'Visible', 'off');
            set(uiGridSpacingMode , 'Visible', 'off');

            set(txtGridSpacing, 'Visible', 'off');
            set(uiGridSpacing , 'Visible', 'off');

            set(txtPixelResolutionMode, 'Visible', 'off');
            set(uiPixelResolutionMode , 'Visible', 'off');

            set(txtPixelResolution, 'Visible', 'off');
            set(uiPixelResolution , 'Visible', 'off');

            set(txtSeriesIntensity    , 'visible', 'on');
            set(txtMatric             , 'visible', 'on');
            set(txtNbOfSpatialSamples , 'visible', 'on');
            set(txtNbOfHistogramBins  , 'visible', 'on');
            set(txtUseAllPixels       , 'visible', 'on');
            set(txtOptimizerMonomodal , 'visible', 'on');
            set(txtOptimizerMultimodal, 'visible', 'on');
            set(txtGrowthFactor       , 'visible', 'on');
            set(txtEpsilon            , 'visible', 'on');
            set(txtInitialRadius      , 'visible', 'on');
            set(txtGradientTolerance  , 'visible', 'on');
            set(txtMinimumStepLength  , 'visible', 'on');
            set(txtMaximumStepLength  , 'visible', 'on');
            set(txtRelaxationFactor   , 'visible', 'on');
            set(txtMaximumIterations  , 'visible', 'on');

            % Metric (Multimodal)

            if strcmpi(tRegistration.Modality, 'automatic') || ...
               strcmpi(tRegistration.Modality, 'multimodal')
                sMetricEnable = 'on';
            else
                sMetricEnable = 'off';
            end

            set(uiModality              , 'enable' , 'on');
            set(uiModality              , 'visible', 'on');

            set(uiNumberOfSpatialSamples, 'enable', sMetricEnable);
            set(uiNumberOfHistogramBins , 'enable', sMetricEnable);
            set(uiUseAllPixels          , 'enable', sMetricEnable);

            set(uiNumberOfSpatialSamples, 'visible', 'on');
            set(uiNumberOfHistogramBins , 'visible', 'on');
            set(uiUseAllPixels          , 'visible', 'on');

            % Optimizer (Multimodal)

            if strcmpi(tRegistration.Modality, 'automatic') || ...
               strcmpi(tRegistration.Modality, 'multimodal')
                sOptimizerMultimodalEnable = 'on';
            else
                sOptimizerMultimodalEnable = 'off';
            end

            set(uiGrowthFactor , 'enable', sOptimizerMultimodalEnable);
            set(uiEpsilon      , 'enable', sOptimizerMultimodalEnable);
            set(uiInitialRadius, 'enable', sOptimizerMultimodalEnable);

            set(uiGrowthFactor , 'visible', 'on');
            set(uiEpsilon      , 'visible', 'on');
            set(uiInitialRadius, 'visible', 'on');

            % Optimizer (Monomodal)

            if strcmpi(tRegistration.Modality, 'automatic') || ...
               strcmpi(tRegistration.Modality, 'monomodal')
                sOptimizerMonomodalEnable = 'on';
            else
                sOptimizerMonomodalEnable = 'off';
            end

            set(uiGradientMagnitudeTolerance, 'enable', sOptimizerMonomodalEnable);
            set(uiMinimumStepLength         , 'enable', sOptimizerMonomodalEnable);
            set(uiMaximumStepLength         , 'enable', sOptimizerMonomodalEnable);
            set(uiRelaxationFactor          , 'enable', sOptimizerMonomodalEnable);
            set(uiMaximumIterations         , 'enable', sOptimizerMonomodalEnable);

            set(uiGradientMagnitudeTolerance, 'visible', 'on');
            set(uiMinimumStepLength         , 'visible', 'on');
            set(uiMaximumStepLength         , 'visible', 'on');
            set(uiRelaxationFactor          , 'visible', 'on');
            set(uiMaximumIterations         , 'visible', 'on');

       end

    end

    function registerCallback(~, ~)

        try

        if isFusion('get') == true
            setFusionCallback(); % Deactivate fusion
        end

        if isPlotContours('get') == true
           setPlotContoursCallback(); % Deactivate plot contours
        end

        dNbElements = 0;
        for ll=1:numel(adLbSeries) % Count Number of element are currently set to a position
            if adLbSeries(ll) ~= 0
                dNbElements = dNbElements+1;
            end
        end

        if dNbElements < 2
            set(fiMainWindowPtr('get'), 'Pointer', 'default');
            drawnow;

            progressBar(1, 'Error: At least 2 volumes must be selected!');
            h = msgbox('Error: registerCallback(): At least 2 volumes must be selected!', 'Error');
%            if integrateToBrowser('get') == true
%                sLogo = './TriDFusion/logo.png';
%            else
%                sLogo = './logo.png';
%            end

%            javaFrame = get(h, 'JavaFrame');
%            javaFrame.setFigureIcon(javax.swing.ImageIcon(sLogo));
            return;
        end

        bResampleAxe = false;

        set(dlgRegister, 'Pointer', 'watch');
        set(fiMainWindowPtr('get'), 'Pointer', 'watch');
        drawnow;

        releaseRoiWait();

        tRegistration = registrationTemplate('get');

        asInterpolation = get(uiInterpolation, 'String');
        sInterpolation  = asInterpolation{get(uiInterpolation, 'Value')};

        tRegistration.Interpolation = lower(sInterpolation);

        asTransformation = get(uiTransformation, 'String');
        sTransformation = asTransformation{get(uiTransformation, 'Value')};

        tRegistration.Transformation = lower(sTransformation);

        asModality = get(uiModality, 'String');
        sModality = asModality{get(uiModality, 'Value')};

        tRegistration.Modality = lower(sModality);

        % Deformable

        asNumberOfPyramidLevelsMode = get(uiPyramidLevelsMode, 'String');
        sNumberOfPyramidLevelsMode  = asNumberOfPyramidLevelsMode{get(uiPyramidLevelsMode, 'Value')};

        tRegistration.Deformable.NumberOfPyramidLevelsMode = lower(sNumberOfPyramidLevelsMode);
        tRegistration.Deformable.NumberOfPyramidLevels = str2double(get(uiNumberOfPyramidLevels, 'String'));
        dNumberOfPyramidLevels = str2double(get(uiNumberOfPyramidLevels, 'String'));

        tRegistration.Deformable.GridRegularization = str2double(get(uiGridRegularization, 'String'));
        dGridRegularization = str2double(get(uiGridRegularization, 'String'));

        asGridSpacingMode = get(uiGridSpacingMode, 'String');
        sGridSpacingMode  = asGridSpacingMode{get(uiGridSpacingMode, 'Value')};

        tRegistration.Deformable.GridSpacingMode = lower(sGridSpacingMode);
        tRegistration.Deformable.GridSpacing = str2num(get(uiGridSpacing, 'String'));
        aGridSpacing = str2num(get(uiGridSpacing, 'String'));

        asPixelResolutionMode = get(uiPixelResolutionMode, 'String');
        sPixelResolutionMode  = asPixelResolutionMode{get(uiPixelResolutionMode, 'Value')};

        tRegistration.Deformable.PixelResolutionMode = lower(sPixelResolutionMode);
        tRegistration.Deformable.PixelResolution = str2num(get(uiPixelResolution, 'String'));
        aPixelResolution = str2num(get(uiPixelResolution, 'String'));

        % Multimodal

        tRegistration.Metric.NumberOfSpatialSamples = str2double(get(uiNumberOfSpatialSamples, 'String'));
        tRegistration.Metric.NumberOfHistogramBins  = str2double(get(uiNumberOfHistogramBins , 'String'));

        asUseAllPixels = get(uiUseAllPixels, 'String');
        sUseAllPixels  = asUseAllPixels{get(uiUseAllPixels, 'Value')};

        if strcmpi(sUseAllPixels, 'True')
            bUseAllPixels = true;
        else
            bUseAllPixels = false;
        end
        tRegistration.Metric.UseAllPixels = bUseAllPixels;

        % Multimodal

        tRegistration.Optimizer.GrowthFactor = str2double(get(uiGrowthFactor, 'String'));

        dEpsilon = str2double(get(uiEpsilon, 'String')) * 1e-06;
        tRegistration.Optimizer.Epsilon = dEpsilon;

        dInitialRadius = str2double(get(uiInitialRadius, 'String')) * 1e-03;
        tRegistration.Optimizer.InitialRadius = dInitialRadius;

        % Monomodal

        dGradientMagnitudeTolerance = str2double(get(uiGradientMagnitudeTolerance, 'String')) * 1e-04;
        tRegistration.Optimizer.GradientMagnitudeTolerance = dGradientMagnitudeTolerance;

        dMinimumStepLength = str2double(get(uiMinimumStepLength, 'String')) * 1e-05;
        tRegistration.Optimizer.MinimumStepLength = dMinimumStepLength;

        dMaximumStepLength = str2double(get(uiMaximumStepLength, 'String')) * 1e-02;
        tRegistration.Optimizer.dMaximumStepLength = dMaximumStepLength;

        dRelaxationFactor = str2double(get(uiRelaxationFactor, 'String')) * 1e-01;
        tRegistration.Optimizer.RelaxationFactor = dRelaxationFactor;

        % Multimodal & Monomodal

        tRegistration.Optimizer.MaximumIterations = str2double(get(uiMaximumIterations, 'String'));

        registrationTemplate('set', tRegistration);

        sInterpolation = tRegistration.Interpolation;

        sMode     = tRegistration.Transformation;
        sModality = tRegistration.Modality;
        metric    = tRegistration.Metric;
        optimizer = tRegistration.Optimizer;

        tInput = inputTemplate('get');
        aInput = inputBuffer('get');

        dInitOffset = get(uiSeriesPtr('get'), 'Value');

        set(uiSeriesPtr('get'), 'Enable', 'off');

        registrationReport('set', '');

        % Nb of elelements to register
%        bNbElementsToRegister = 0;
%        for ll=1:numel(adLbSeries)
%            if adLbSeries(ll) ~= 0
%                bNbElementsToRegister = bNbElementsToRegister+1;
%            end
%        end
%        bNbElementsToRegister = bNbElementsToRegister-1; % Need to remove the reference

        bInitRef = true;
        dNextSeries = 1;

        for hh=1:dNbElements

            for kk=1:numel(adLbSeries)

%                set(uiSeriesPtr('get'), 'Value', kk);
                aBuffer    = dicomBuffer('get', [], kk);

                atMetaData = dicomMetaData('get', [], kk);

                if ~isempty(aInput{kk})

                    if(size(aInput{kk}, 3) == 1)

                        if  isempty(aBuffer)

                            aBuffer = aInput{kk};
                        end
                    else

                        if  isempty(aBuffer)

                            if     strcmpi(imageOrientation('get'), 'axial')
                                aBuffer = aInput{kk};
                            elseif strcmpi(imageOrientation('get'), 'coronal')
                                aBuffer = reorientBuffer(aInput{kk}, 'coronal');
                            elseif strcmpi(imageOrientation('get'), 'sagittal')
                                aBuffer = reorientBuffer(aInput{kk}, 'sagittal');
                            end
                        end
                    end
                end

                if isempty(atMetaData)

                    atMetaData = tInput(kk).atDicomInfo;
                end

                if adLbSeries(kk) == 1 && bInitRef == true

                    tInput(adLbSeries(kk)).bEdgeDetection = false;

                    bInitRef      = false;
                    atRefMetaData = atMetaData;
                    refImage      = aBuffer;
                    dNextSeries   = 2;

                    sRefStudyInstanceUID    = atMetaData{1}.StudyInstanceUID;
                    sRefFrameOfReferenceUID = atMetaData{1}.FrameOfReferenceUID;

                    if get(chkRegSeriesDescription, 'Value') == true

                        atRefMetaData{1}.SeriesDescription  = sprintf('REF-COREG %s', atRefMetaData{1}.SeriesDescription);
                        asDescription = seriesDescription('get');
                        asDescription{kk} = sprintf('REF-COREG %s', asDescription{kk});

                        seriesDescription('set', asDescription);
                    end

                    dicomBuffer('set', refImage, kk);

                    dicomMetaData('set', atRefMetaData, kk);

                    setQuantification(kk);

                    updateDescription('set', get(chkRegSeriesDescription, 'Value'));

                    % Apply constraint to registration

                    [asConstraintTagList, asConstraintTypeList] = roiConstraintList('get', kk);

                    bInvertMask = invertConstraint('get');

                    tRoiInput = roiTemplate('get', kk);

                    aLogicalMask = roiConstraintToMask(refImage, tRoiInput, asConstraintTagList, asConstraintTypeList, bInvertMask);

                    break;
                end

                if dNextSeries >1

                    if adLbSeries(kk) == dNextSeries

                        sStudyInstanceUID    = atMetaData{1}.StudyInstanceUID;
                        sSeriesInstanceUID   = atMetaData{1}.SeriesInstanceUID;
                        sFrameOfReferenceUID = atMetaData{1}.FrameOfReferenceUID;

                        % Registration condition 1
                        % If 2 series are selected, then even if the sub
                        % madality match the reference, we will register.

                        % if bNbElementsToRegister == 1
                        %     bProceedWithRegistration = true;
                        % else
                        %     if strcmpi(sStudyInstanceUID, sRefStudyInstanceUID) && ...
                        %        strcmpi(sFrameOfReferenceUID, sRefFrameOfReferenceUID)
                        %         bProceedWithRegistration = false;
                        %     else
                        %         bProceedWithRegistration = true;
                        %     end
                        % end
                        bProceedWithRegistration = true;
                        % End condition 1

                        % Registration condition 2
                        % If the current series have a slave modality
                        % that match the the reference

                        adAssociatedSeries = [];

                        % for ll=1:numel(adLbSeries)
                        %     if adLbSeries(ll) ~= 0

                        %         sCurrentStudyInstanceUID    = ...
                        %             tInput(adLbSeries(ll)).atDicomInfo{1}.StudyInstanceUID;

                        %         sCurrentSeriesInstanceUID = ...
                        %             tInput(adLbSeries(ll)).atDicomInfo{1}.SeriesInstanceUID;

                        %         sCurrentFrameOfReferenceUID = ...
                        %             tInput(adLbSeries(ll)).atDicomInfo{1}.FrameOfReferenceUID;

                        %         if ~(strcmpi(sRefStudyInstanceUID   , sCurrentStudyInstanceUID) && ... % We don't move the reference
                        %              strcmpi(sRefFrameOfReferenceUID, sCurrentFrameOfReferenceUID) )

                        %             if strcmpi(sStudyInstanceUID   , sCurrentStudyInstanceUID) && ... % Will need to move the sub modality
                        %                strcmpi(sFrameOfReferenceUID, sCurrentFrameOfReferenceUID)

                        %                 if ~strcmpi(sSeriesInstanceUID, sCurrentSeriesInstanceUID) % We don't want to register the series twice
                        %                     adAssociatedSeries{numel(adAssociatedSeries)+1} = adLbSeries(ll);
                        %                 end
                        %            end
                        %          end
                        %     end
                        % end
                        % End condition 2

                        % Registration condition 3
                        % If the option Move Associated Series is on

                        if get(chkRegAssociateSeries, 'Value') == true && ...
                           isempty(adAssociatedSeries) % The sub series is not on the list

                            for mm=1:numel(tInput)

                                sCurrentStudyInstanceUID = ...
                                    tInput(mm).atDicomInfo{1}.StudyInstanceUID;

                                sCurrentSeriesInstanceUID = ...
                                    tInput(mm).atDicomInfo{1}.SeriesInstanceUID;

                                sCurrentFrameOfReferenceUID = ...
                                    tInput(mm).atDicomInfo{1}.FrameOfReferenceUID;

                                if ~(strcmpi(sRefStudyInstanceUID   , sCurrentStudyInstanceUID) && ... % We don't move the reference
                                     strcmpi(sRefFrameOfReferenceUID, sCurrentFrameOfReferenceUID) )

                                    if strcmpi(sStudyInstanceUID   , sCurrentStudyInstanceUID) && ... % Will need to switch and move the sub modality
                                       strcmpi(sFrameOfReferenceUID, sCurrentFrameOfReferenceUID)

                                        if ~strcmpi(sSeriesInstanceUID, sCurrentSeriesInstanceUID) % We don't want to register the series twice
                                            adAssociatedSeries{numel(adAssociatedSeries)+1} = mm;
                                        end
                                    end
                                end
                            end
                        end
                        % End condition 3

                        if bProceedWithRegistration == true

                            if dInitOffset == kk

                                bResampleAxe = true;
                            end

                            progressBar(dNextSeries/dNbElements-0.000001, sprintf('Processing registration %d/%d, please wait', dNextSeries-1, dNbElements-1));

                            if strcmpi(sMode, 'Deformable')

                                [aRegistratedBuffer, atRegisteredMetaData, registratedGeomtform] = ...
                                    deformableRegistration(aBuffer      , ...
                                                           atMetaData   , ...
                                                           refImage     , ...
                                                           atRefMetaData, ...
                                                           aLogicalMask , ...
                                                           sInterpolation, ...
                                                           sNumberOfPyramidLevelsMode, ...
                                                           dNumberOfPyramidLevels, ...
                                                           dGridRegularization, ...
                                                           sGridSpacingMode, ...
                                                           aGridSpacing, ...
                                                           sPixelResolutionMode, ...
                                                           aPixelResolution, ...   
                                                           referenceOutputView('get'), ...
                                                           updateDescription('get'), ...
                                                           kk);
                            else
                                [aRegistratedBuffer, atRegisteredMetaData, Rmoving, Rregistered, registratedGeomtform] = ...
                                    registerImage(aBuffer      , ...
                                                  atMetaData   , ...
                                                  refImage     , ...
                                                  atRefMetaData, ...
                                                  aLogicalMask , ...
                                                  sMode        , ...
                                                  sInterpolation, ...
                                                  sModality    , ...
                                                  optimizer    , ...
                                                  metric       , ...
                                                  referenceOutputView('get'), ...
                                                  updateDescription('get'), ...
                                                  kk);
                            end

                            tInput(adLbSeries(kk)).tMovement.bMovementApplied = true;
                            % if isfield(registratedGeomtform, 'T')
                            %     tInput(adLbSeries(kk)).tMovement.aGeomtform = registratedGeomtform;
                            % else
                                tInput(adLbSeries(kk)).tMovement.aGeomtform = registratedGeomtform;
                            % end

                            sReport = sprintf('Registration %d', dNextSeries-1);
                            sReport = sprintf('%s\nFixed Series : %s', sReport, atRefMetaData{1}.SeriesDescription);
                            sReport = sprintf('%s\nMoving Series: %s', sReport, atRegisteredMetaData{1}.SeriesDescription);

                            if ~strcmpi(sMode, 'Deformable')

                                sRmoving     = R_regToString(Rmoving);
                                sReport      = sprintf('%s\n\nMoving Series:\n%s', sReport, sRmoving);
                                sRregistered = R_regToString(Rregistered);
                                sReport      = sprintf('%s\nRegistrated Series:\n%s\n', sReport, sRregistered);
    
                                if isfield(registratedGeomtform, 'T')
    
                                    sGeomtform = num2str(registratedGeomtform.T);
                                    dGeomtformSize = size(sGeomtform, 1);
                                    sReport = sprintf('%sGeomtform:',sReport);

                                    for go=1:dGeomtformSize

                                        sReport = sprintf('%s\n%s',sReport, sGeomtform(go,:));
                                    end

                                    sReport = sprintf('%s\n\n',sReport);
                                end
                            end

                            registrationReport('add', sReport);

%                            atRoi = roiTemplate('get', adLbSeries(kk));
%                            atRegistratedRoi = registerROIs(aBuffer, atMetaData, aRegistratedBuffer, atRegisteredMetaData, atRoi, registratedGeomtform);
%                            roiTemplate('set', adLbSeries(kk), atRegistratedRoi);

                       %     if referenceOutputView('get') == true
                       %         [aResampledBuffer, atResampledMetaData] = ...
                       %             resampleImage(aRegistratedBuffer, atRegisteredMetaData, refImage, atRefMetaData, sInterpolation, updateDescription('get'));

                       %         dicomBuffer('set', aResampledBuffer);
                       %         dicomMetaData('set', atResampledMetaData);
                       %     else
                            dicomBuffer('set', aRegistratedBuffer, kk);

                            dicomMetaData('set', atRegisteredMetaData, kk);

                            setQuantification(kk);
                       %     end

                            if link2DMip('get') == true

                                if size(aRegistratedBuffer, 3) ~= 1

                                    % aRegistratedMip = computeMIP(aRegistratedBuffer);

                                    mipBuffer('set', computeMIP(aRegistratedBuffer), kk);
                                end
                            end

                            % clear aRegistratedBuffer;

                            adLbSeries(kk) = 0; % This series is done

                            dNextSeries = dNextSeries+1;

                            if ~isempty(adAssociatedSeries) % We need to moved the associated series

                                dNbOfAssociatedSeries = numel(adAssociatedSeries);

                                for ee=1:dNbOfAssociatedSeries

                                    dAssociatedSeries = adAssociatedSeries{ee};

%                                    progressBar(ee/dNbOfAssociatedSeries-0.000001, sprintf('Moving sub series %d/%d, please wait', ee, dNbOfAssociatedSeries));

                                    % set(uiSeriesPtr('get'), 'Value', dAssociatedSeries);

                                    aBuffer    = dicomBuffer('get', [], dAssociatedSeries);

                                    atMetaData = dicomMetaData('get', [], dAssociatedSeries);

                                    if(size(aInput{dAssociatedSeries}, 3) == 1)

                                        if isempty(aBuffer)

                                            aBuffer = aInput{dAssociatedSeries};
                                        end
                                    else

                                        if  isempty(aBuffer)

                                            if     strcmpi(imageOrientation('get'), 'axial')
                                                aBuffer = aInput{dAssociatedSeries};
                                            elseif strcmpi(imageOrientation('get'), 'coronal')
                                                aBuffer = reorientBuffer(aInput{dAssociatedSeries}, 'coronal');
                                            elseif strcmpi(imageOrientation('get'), 'sagittal')
                                                aBuffer = reorientBuffer(aInput{dAssociatedSeries}, 'sagittal');
                                            end
                                        end
                                    end

                                    if isempty(atMetaData)

                                        atMetaData = tInput(dAssociatedSeries).atDicomInfo;
                                    end

                                    if strcmpi(sMode, 'Deformable')

                                        [aAssociatedRegistratedBuffer, atAssociatedRegisteredMetaData, registratedGeomtform] = ...
                                            deformableRegistration(aBuffer                   , ...
                                                                   atMetaData                , ...
                                                                   aRegistratedBuffer        , ...
                                                                   atRegisteredMetaData      , ...
                                                                   aLogicalMask              , ...
                                                                   sInterpolation            , ...
                                                                   sNumberOfPyramidLevelsMode, ...
                                                                   dNumberOfPyramidLevels    , ...
                                                                   dGridRegularization       , ...
                                                                   sGridSpacingMode          , ...
                                                                   aGridSpacing              , ...
                                                                   sPixelResolutionMode      , ...
                                                                   aPixelResolution          , ...
                                                                   referenceOutputView('get'), ...
                                                                   updateDescription('get')  , ...
                                                                   dAssociatedSeries, ...
                                                                   registratedGeomtform);                                        
                                    else

                                        [aAssociatedRegistratedBuffer, atAssociatedRegisteredMetaData, Rmoving, Rregistered] = ...
                                            registerImage(aBuffer             , ...
                                                          atMetaData          , ...
                                                          aRegistratedBuffer  , ...
                                                          atRegisteredMetaData, ...
                                                          aLogicalMask        , ...
                                                          sMode               , ...
                                                          sInterpolation, ...
                                                          sModality           , ...
                                                          optimizer           , ...
                                                          metric              , ...
                                                          referenceOutputView('get'), ...
                                                          updateDescription('get'), ...
                                                          dAssociatedSeries, ...
                                                          registratedGeomtform);
                                    end
                                    % 
                                    % tInput(dAssociatedSeries).tMovement.bMovementApplied = true;
                                    % if isfield(registratedGeomtform, 'T')
                                        tInput(dAssociatedSeries).tMovement.aGeomtform = registratedGeomtform;
                                    % else
                                    %     tInput(dAssociatedSeries).tMovement.aGeomtform = [];
                                    % end

                                    sReport = sprintf('Moving Series %d', ee);
                                    sReport = sprintf('%s\nFixed Series : %s', sReport, atRegisteredMetaData{1}.SeriesDescription);
                                    sReport = sprintf('%s\nMoving Series: %s', sReport, atAssociatedRegisteredMetaData{1}.SeriesDescription);

                                    if ~strcmpi(sMode, 'Deformable')

                                        sRmoving     = R_regToString(Rmoving);
                                        sReport      = sprintf('%s\n\nMoving Series:\n%s', sReport, sRmoving);
                                        sRregistered = R_regToString(Rregistered);
                                        sReport      = sprintf('%s\nRegistrated Series:\n%s\n', sReport, sRregistered);

                                        if isfield(registratedGeomtform, 'T')

                                            sGeomtform = num2str(registratedGeomtform.T);
                                            dGeomtformSize = size(sGeomtform, 1);
                                            sReport = sprintf('%sGeomtform:',sReport);

                                            for go=1:dGeomtformSize

                                                sReport = sprintf('%s\n%s',sReport, sGeomtform(go,:));
                                            end

                                            sReport = sprintf('%s\n\n',sReport);
                                        end
                                    end

                                    registrationReport('add', sReport);

                          %          if referenceOutputView('get') == true
                          %              [aAssociatedResampledBuffer, atAssiciatedResampledMetaData] = ...
                          %                  resampleImage(aAssociatedRegistratedBuffer, atAssociatedRegisteredMetaData, refImage, atRefMetaData, sInterpolation, updateDescription('get'));

                          %              dicomBuffer('set', aAssociatedResampledBuffer);
                          %              dicomMetaData('set', atAssiciatedResampledMetaData);
                          %          else
                                        dicomBuffer('set', aAssociatedRegistratedBuffer, dAssociatedSeries);

                                        dicomMetaData('set', atAssociatedRegisteredMetaData, dAssociatedSeries);

                                        setQuantification(dAssociatedSeries);
                          %          end

                                    if link2DMip('get') == true

                                        if size(aAssociatedRegistratedBuffer, 3) ~= 1

                                            % aRegistratedMip = computeMIP(aAssociatedRegistratedBuffer);

                                            mipBuffer('set', computeMIP(aAssociatedRegistratedBuffer), dAssociatedSeries);
                                        end
                                    end

                                    clear aAssociatedRegistratedBuffer;

                                    for vv=1:numel(adLbSeries)

                                        if adLbSeries(vv) ~= 0 && ...
                                           vv == dAssociatedSeries

                                            adLbSeries(vv) = 0; % This series is done
                                        end
                                    end

                                end

                            end

                            clear aRegistratedBuffer; 

                        end
                    end
                end
            end

        end

        progressBar(1, 'Ready');

        inputTemplate('set', tInput);

        % set(uiSeriesPtr('get'), 'Value', dInitOffset);

        set(uiSeriesPtr('get'), 'Enable', 'on');

%        isFusion('set', false);
%        set(btnFusionPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
%        set(btnFusionPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));

        set(dlgRegister, 'Pointer', 'default');

        delete(dlgRegister);

%        setQuantification(dInitOffset);

%        clearDisplay();
%        initDisplay(3);

  %      initWindowLevel('set', true);
  %      quantificationTemplate('set', tInput(dInitOffset).tQuant);
%        dLink2DMip  = link2DMip('get');

%        link2DMip('set', true);

%        set(btnLinkMipPtr('get'), 'BackgroundColor', viewerButtonPushedBackgroundColor('get'));
%        set(btnLinkMipPtr('get'), 'ForegroundColor', viewerButtonPushedForegroundColor('get'));

%        dicomViewerCore();

        if bResampleAxe == true

%            if ~isempty(refImage)
%                resampleAxes(refImage, atRefMetaData);

%                setImagesAspectRatio();
%            end

%            if is3DEngine('get') == true

                clearDisplay();

                if size(dicomBuffer('get', [], dInitOffset), 3) == 1
                    initDisplay(1);
                else
                    initDisplay(3);
                end

                dicomViewerCore();
 %           end
        end

        setViewerDefaultColor(true, dicomMetaData('get', [], dInitOffset));

%        sliderCorCallback();
%        sliderSagCallback();
%        sliderTraCallback();

        refreshImages();


%         triangulateCallback();

%        refreshImages();

%        atMetaData = dicomMetaData('get');

%        if strcmpi(atMetaData{1}.Modality, 'ct') ||dLink2DMip == false
%            link2DMip('set', false);

%            set(btnLinkMipPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
%            set(btnLinkMipPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
%        end
%        refreshImages();
 %       aBuffer = registerImage(aBuffer, atMetaData, refImage, tInput(iRefOffset).atDicomInfo, sMode, optimizer, metric);
        catch
            progressBar(1, 'Error:registerCallback()');
        end

        set(fiMainWindowPtr('get'), 'Pointer', 'default');
        drawnow;
    end

    function associateRegistrationCallback(hObject, ~)

        if get(chkRegAssociateSeries, 'Value') == true

            if strcmpi(get(hObject, 'Style'), 'Checkbox')

                set(chkRegAssociateSeries, 'Value', true);
            else
                set(chkRegAssociateSeries, 'Value', false);
            end
        else
            if strcmpi(hObject.Style, 'Checkbox')

                set(chkRegAssociateSeries, 'Value', false);
            else
                set(chkRegAssociateSeries, 'Value', true);
            end
        end

         associateRegistrationModality('set', get(chkRegAssociateSeries, 'Value'));
    end

    function updateRegDescriptionCallback(hObject, ~)

        if get(chkRegSeriesDescription, 'Value') == true

            if strcmpi(get(hObject, 'Style'), 'Checkbox')

                set(chkRegSeriesDescription, 'Value', true);
            else
                set(chkRegSeriesDescription, 'Value', false);
            end
        else
            if strcmpi(hObject.Style, 'Checkbox')

                set(chkRegSeriesDescription, 'Value', false);
            else
                set(chkRegSeriesDescription, 'Value', true);
            end
        end

         updateDescription('set', get(chkRegSeriesDescription, 'Value'));
    end

    function resampleRegistrationCallback(hObject, ~)

        if get(chkRegResampleRegistration, 'Value') == true

            if strcmpi(get(hObject, 'Style'), 'Checkbox')

                set(chkRegResampleRegistration, 'Value', true);
            else
                set(chkRegResampleRegistration, 'Value', false);
            end
        else
            if strcmpi(hObject.Style, 'Checkbox')

                set(chkRegResampleRegistration, 'Value', false);
            else
                set(chkRegResampleRegistration, 'Value', true);
            end
         end

        referenceOutputView('set', get(chkRegResampleRegistration, 'Value'));

    end
end
