function mainWindowMenu()
%function mainWindowMenu()
%Set Figure Main Menu.
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

    mFile = uimenu(fiMainWindowPtr('get'),'Label','File');
    uimenu(mFile,'Label', 'Open...', 'Callback',@setSourceCallback);
    uimenu(mFile,'Label', 'Import Dose Kernel...','Callback', @importDoseKernelCallback);
    uimenu(mFile,'Label', 'Import STL Model...','Callback', @importSTLCallback);
    uimenu(mFile,'Label', 'Import Contours...','Callback', @importContoursCallback);    
    uimenu(mFile,'Label', 'Import CERR planC...','Callback', @importCerrPlanCCallback, 'Separator','on');
    uimenu(mFile,'Label', 'Import CERR Dose Volume...','Callback', @importCerrDoseVolumeCallback);
    uimenu(mFile,'Label', 'Import CERR Dose Constraint...','Callback', @importCerrDoseConstraintCallback);

    uimenu(mFile,'Label', 'Export DICOM...','Callback', @writeDICOMCallback, 'Separator','on');
    uimenu(mFile,'Label', 'Export DICOM All Series...','Callback', @writeDICOMAllSeriesCallback);
 %   uimenu(mFile,'Label', 'Export to Excel...','Callback', @exportAllSeriesResultCallback);
    uimenu(mFile,'Label', 'Export ISO Model to STL...','Callback', @exportISOtoSTLCallback);
    uimenu(mFile,'Label', 'Print Preview...','Callback', 'filemenufcn(gcbf,''FilePrintPreview'')', 'Separator','on');
    uimenu(mFile,'Label', 'Print...','Callback', 'printdlg(gcbf)');
    uimenu(mFile,'Label', 'Exit' ,'Callback', 'close', 'Separator','on');

    mEdit = uimenu(fiMainWindowPtr('get'),'Label','Edit');
    uimenu(mEdit,'Label', 'Copy Display', 'Callback', @copyDisplayCallback);
    uimenu(mEdit,'Label', 'Patient Dose...', 'Callback', @setPatientDoseCallback, 'Separator','on');    
    mOptions = uimenu(mEdit,'Label', 'Viewer Properties...', 'Callback', @setOptionsCallback);
    optionsPanelMenuObject('set', mOptions);

    mView = uimenu(fiMainWindowPtr('get'),'Label','View');
    mAxial    = uimenu(mView, 'Label','Axial Plane'   , 'Callback', @setOrientationCallback);
    mSagittal = uimenu(mView, 'Label','Sagittal Plane', 'Callback', @setOrientationCallback);
    mCoronal  = uimenu(mView, 'Label','Coronal plane' , 'Callback', @setOrientationCallback);

    mVsplashAxial    = uimenu(mView, 'Label','V-Splash Axial'   , 'Callback', @setVsplashViewCallback, 'Separator','on');
    mVsplashSagittal = uimenu(mView, 'Label','V-Splash Sagittal', 'Callback', @setVsplashViewCallback);
    mVslashCoronal   = uimenu(mView, 'Label','V-Splash Coronal' , 'Callback', @setVsplashViewCallback);
    mVslashAll       = uimenu(mView, 'Label','V-Splash All'     , 'Callback', @setVsplashViewCallback);

    if strcmpi(imageOrientation('get'), 'Sagittal')
        set(mAxial   , 'Checked', 'off');
        set(mSagittal, 'Checked', 'on' );
        set(mCoronal , 'Checked', 'off');
    elseif strcmpi(imageOrientation('get'), 'Coronal')
        set(mAxial   , 'Checked', 'off');
        set(mSagittal, 'Checked', 'off' );
        set(mCoronal , 'Checked', 'on');
    else
        set(mAxial   , 'Checked', 'on');
        set(mSagittal, 'Checked', 'off' );
        set(mCoronal , 'Checked', 'off');
    end

    if strcmpi(vSplahView('get'), 'Coronal')
        set(mVsplashAxial   , 'Checked', 'off');
        set(mVsplashSagittal, 'Checked', 'off');
        set(mVslashCoronal  , 'Checked', 'on');
        set(mVslashAll      , 'Checked', 'off');
    elseif strcmpi(vSplahView('get'), 'Sagittal')
        set(mVsplashAxial   , 'Checked', 'off');
        set(mVsplashSagittal, 'Checked', 'on');
        set(mVslashCoronal  , 'Checked', 'off');
        set(mVslashAll      , 'Checked', 'off');
    elseif strcmpi(vSplahView('get'), 'Axial')
        set(mVsplashAxial   , 'Checked', 'on');
        set(mVsplashSagittal, 'Checked', 'off');
        set(mVslashCoronal  , 'Checked', 'off');
        set(mVslashAll      , 'Checked', 'off');
    else % strcmpi(vSplahView('get'), 'All')
        set(mVsplashAxial   , 'Checked', 'off');
        set(mVsplashSagittal, 'Checked', 'off');
        set(mVslashCoronal  , 'Checked', 'off');
        set(mVslashAll      , 'Checked', 'on');
    end

    mViewCam      = uimenu(mView, 'Label','Camera Toolbar'   , 'Callback', @setViewToolbar, 'Separator','on');
    mViewEdit     = uimenu(mView, 'Label','Plot Edit Toolbar', 'Callback', @setViewToolbar);
    mViewPlayback = uimenu(mView, 'Label','Playback Toolbar' , 'Callback', @setViewToolbar);
    viewPlaybackObject('set', mViewPlayback);

    mViewRoi = uimenu(mView, 'Label','ROI Toolbar' , 'Callback', @setViewToolbar);
    viewRoiObject('set', mViewRoi);

    mViewSegPanel = uimenu(mView, 'Label','Segmentation Panel' , 'Callback', @setViewSegPanel, 'Separator', 'on');
    viewSegPanelMenuObject('set', mViewSegPanel);

    mViewKernelPanel = uimenu(mView, 'Label','Kernel Panel', 'Callback', @setViewKernelPanel);
    viewKernelPanelMenuObject('set', mViewKernelPanel);

    mViewRoiPanel = uimenu(mView, 'Label','ROI Panel', 'Callback', @setViewRoiPanel);
    viewRoiPanelMenuObject('set', mViewRoiPanel);
    
    m3DPanel = uimenu(mView, 'Label','3D Edit Panel', 'Callback', @setView3DPanel);
    view3DPanelMenuObject('set', m3DPanel);

    uimenu(mView, 'Label','Registration Report', 'Callback', @viewRegistrationReport, 'Separator','on');

    mInsert = uimenu(fiMainWindowPtr('get'),'Label','Insert');
    mEditPlot = uimenu(mInsert, 'Label','Plot Editor', 'Callback', @setInsertMenuCallback);
    uimenu(mInsert, 'Label','Line'        , 'Callback', @setInsertMenuCallback, 'Separator','on');
    uimenu(mInsert, 'Label','Arrow'       , 'Callback', @setInsertMenuCallback);
    uimenu(mInsert, 'Label','Text Arrow'  , 'Callback', @setInsertMenuCallback);
    uimenu(mInsert, 'Label','Double Arrow', 'Callback', @setInsertMenuCallback);
    uimenu(mInsert, 'Label','Text Box'    , 'Callback', @setInsertMenuCallback);
    uimenu(mInsert, 'Label','Rectangle'   , 'Callback', @setInsertMenuCallback);
    uimenu(mInsert, 'Label','Ellipse'     , 'Callback', @setInsertMenuCallback);

    mTools = uimenu(fiMainWindowPtr('get'),'Label','Tools');
%     uimenu(mTools, 'Label','Fusion'      , 'Callback', @setFusionCallback);
%     rotate3DMenu  ('set', uimenu(mTools, 'Label','Rotate 3D'  , 'Callback', @setRotate3DCallback));
    panMenu       ('set', uimenu(mTools, 'Label','Pan'        , 'Callback', @setPanCallback));
    zoomMenu      ('set', uimenu(mTools, 'Label','Zoom'       , 'Callback', @setZoomCallback));
    rotate3DMenu  ('set', uimenu(mTools, 'Label','Rotate 3D'  , 'Callback', @setRotate3DCallback));
 %   dataCursorMenu('set', uimenu(mTools, 'Label','Data Cursor', 'Callback', @setDataCursorCallback));
    uimenu(mTools, 'Label','Reset View', 'Callback','toolsmenufcn ResetView');


    mHelp = uimenu(fiMainWindowPtr('get'),'Label','Help');
    uimenu(mHelp,'Label', 'User Manual', 'Callback', @helpViewerCallback);
    uimenu(mHelp,'Label', 'About', 'Callback', @aboutViewerCallback, 'Separator','on');

    
    function copyDisplayCallback(~, ~)
        
        try
            hFig = fiMainWindowPtr('get');
            
            set(hFig, 'Pointer', 'watch');
            
%            rdr = get(hFig,'Renderer');
            inv = get(hFig,'InvertHardCopy');

%            set(hFig,'Renderer','Painters');
            set(hFig,'InvertHardCopy','Off');

            drawnow;
            hgexport(hFig,'-clipboard');

%            set(hFig,'Renderer',rdr);        
            set(hFig,'InvertHardCopy',inv);        
        catch
        end
        
        set(hFig, 'Pointer', 'default');
        
    end   
    
    function setOrientationCallback(hObject, ~)

        bRefresh = false;
        if switchTo3DMode('get')     == false && ...
           switchToIsoSurface('get') == false && ...
           switchToMIPMode('get')    == false && ...
           ~isempty(dicomBuffer('get'))

            releaseRoiWait();

%                iOffset = get(uiSeriesPtr('get'), 'Value');
%                if iOffset <= numel(tInput)

%                    aInput = inputBuffer('get');

                aInput  = dicomBuffer('get');
                aFusion = fusionBuffer('get');

                if strcmpi(get(hObject, 'Label'), 'Axial Plane') && ...
                  ~strcmpi(imageOrientation('get'), 'axial')

                    set(mAxial   , 'Checked', 'on' );
                    set(mCoronal , 'Checked', 'off');
                    set(mSagittal, 'Checked', 'off');

                    refreshImages();

                    viewSegPanel('set', false);
                    objSegPanel = viewSegPanelMenuObject('get');
                    if ~isempty(objSegPanel)
                        objSegPanel.Checked = 'off';
                    end

                    viewKernelPanel('set', false);
                    objKernelPanel = viewKernelPanelMenuObject('get');
                    if ~isempty(objKernelPanel)
                        objKernelPanel.Checked = 'off';
                    end

                    if strcmp(imageOrientation('get'), 'coronal')
                        aInput = permute(aInput, [3 2 1]);
                        if isFusion('get') == true
                            aFusion = permute(aFusion, [3 2 1]);
                        end
                    elseif strcmp(imageOrientation('get'), 'sagittal')
                        aInput = permute(aInput, [2 3 1]);
                        if isFusion('get') == true
                            aFusion = permute(aFusion, [2 3 1]);
                        end
                    else
                        aInput = permute(aInput, [1 2 3]);
                        if isFusion('get') == true
                            aFusion = permute(aFusion, [1 2 3]);
                        end

                    end

                    imageOrientation('set', 'axial');

                    bRefresh = true;

                elseif strcmpi(get(hObject, 'Label'), 'Coronal Plane') && ...
                      ~strcmpi(imageOrientation('get'), 'coronal')

                    set(mAxial   , 'Checked', 'off');
                    set(mCoronal , 'Checked', 'on' );
                    set(mSagittal, 'Checked', 'off');

                    triangulateCallback();

                    viewSegPanel('set', false);
                    objSegPanel = viewSegPanelMenuObject('get');
                    if ~isempty(objSegPanel)
                        objSegPanel.Checked = 'off';
                    end

                    viewKernelPanel('set', false);
                    objKernelPanel = viewKernelPanelMenuObject('get');
                    if ~isempty(objKernelPanel)
                        objKernelPanel.Checked = 'off';
                    end

                    if strcmp(imageOrientation('get'), 'sagittal')
                        aInput = permute(aInput, [1 3 2]);
                        if isFusion('get') == true
                            aFusion = permute(aFusion, [1 3 2]);
                        end
                   else
                        aInput = permute(aInput, [3 2 1]);
                        if isFusion('get') == true
                            aFusion = permute(aFusion, [3 2 1]);
                        end
                    end

                    imageOrientation('set', 'coronal');

                    bRefresh = true;

               elseif strcmpi(get(hObject, 'Label'), 'Sagittal Plane') && ...
                      ~strcmp(imageOrientation('get'), 'sagittal')

                    set(mAxial   , 'Checked', 'off');
                    set(mCoronal , 'Checked', 'off');
                    set(mSagittal, 'Checked', 'on' );

                    triangulateCallback();

                    viewSegPanel('set', false);
                    objSegPanel = viewSegPanelMenuObject('get');
                    if ~isempty(objSegPanel)
                        objSegPanel.Checked = 'off';
                    end

                    viewKernelPanel('set', false);
                    objKernelPanel = viewKernelPanelMenuObject('get');
                    if ~isempty(objKernelPanel)
                        objKernelPanel.Checked = 'off';
                    end

                    if strcmp(imageOrientation('get'), 'coronal')
                        aInput = permute(aInput, [1 3 2]);
                        if isFusion('get') == true
                            aFusion = permute(aFusion, [1 3 2]);
                        end
                   else
                        aInput = permute(aInput, [3 1 2]);
                         if isFusion('get') == true
                            aFusion = permute(aFusion, [3 1 2]);
                         end
                    end

                    imageOrientation('set', 'sagittal');

                    bRefresh = true;

                end

                if  bRefresh == true

                    dicomBuffer('set', aInput);
                    if isFusion('get') == true
                        fusionBuffer('set', aFusion);
                    end

                    clearDisplay();
                    initDisplay(3);
                    dicomViewerCore();

                    refreshImages();
                end

          %  end
        end
    end

    function setVsplashViewCallback(hObject, ~)
        if switchTo3DMode('get')     == false && ...
           switchToIsoSurface('get') == false && ...
           switchToMIPMode('get')    == false && ...
           ~isempty(dicomBuffer('get'))

            bChangeActiveView = false;

            if strcmpi(get(hObject, 'Label'), 'V-Splash Axial') && ...
              ~strcmpi(vSplahView('get'), 'axial')

                vSplahView('set', 'axial');

                set(mVsplashAxial   , 'Checked', 'on');
                set(mVsplashSagittal, 'Checked', 'off');
                set(mVslashCoronal  , 'Checked', 'off');
                set(mVslashAll      , 'Checked', 'off');

                bChangeActiveView = true;

            elseif strcmpi(get(hObject, 'Label'), 'V-Splash Coronal') && ...
              ~strcmpi(vSplahView('get'), 'coronal')

                vSplahView('set', 'coronal');

                set(mVsplashAxial   , 'Checked', 'off');
                set(mVsplashSagittal, 'Checked', 'off');
                set(mVslashCoronal  , 'Checked', 'on');
                set(mVslashAll      , 'Checked', 'off');

                bChangeActiveView = true;

            elseif strcmpi(get(hObject, 'Label'), 'V-Splash Sagittal') && ...
              ~strcmpi(vSplahView('get'), 'sagittal')

                vSplahView('set', 'sagittal');

                set(mVsplashAxial   , 'Checked', 'off');
                set(mVsplashSagittal, 'Checked', 'on');
                set(mVslashCoronal  , 'Checked', 'off');
                set(mVslashAll      , 'Checked', 'off');

                bChangeActiveView = true;

            elseif strcmpi(get(hObject, 'Label'), 'V-Splash All') && ...
              ~strcmpi(vSplahView('get'), 'all')

                vSplahView('set', 'all');

                set(mVsplashAxial   , 'Checked', 'off');
                set(mVsplashSagittal, 'Checked', 'off');
                set(mVslashCoronal  , 'Checked', 'off');
                set(mVslashAll      , 'Checked', 'on');

                bChangeActiveView = true;

            end

            if bChangeActiveView == true && ...
               isVsplash('get') == true

                im = dicomBuffer('get');

                iCoronalSize  = size(im,1);
                iSagittalSize = size(im,2);
                iAxialSize    = size(im,3);

                iCoronal  = sliceNumber('get', 'coronal');
                iSagittal = sliceNumber('get', 'sagittal');
                iAxial    = sliceNumber('get', 'axial');

                multiFramePlayback('set', false);
                multiFrameRecord  ('set', false);

                mPlay = playIconMenuObject('get');
                if ~isempty(mPlay)
                    mPlay.State = 'off';
          %          playIconMenuObject('set', '');
                end

                mRecord = recordIconMenuObject('get');
                if ~isempty(mRecord)
                    mRecord.State = 'off';
          %          recordIconMenuObject('set', '');
                end

                clearDisplay();
                initDisplay(3);

                dicomViewerCore();

                % restore position
                set(uiSliderCorPtr('get'), 'Value', iCoronal / iCoronalSize);
                sliceNumber('set', 'coronal', iCoronal);

                set(uiSliderSagPtr('get'), 'Value', iSagittal / iSagittalSize);
                sliceNumber('set', 'sagittal', iSagittal);

                set(uiSliderTraPtr('get'), 'Value', 1 - (iAxial / iAxialSize));
                sliceNumber('set', 'axial', iAxial);

                refreshImages();

            end
        end
    end

    function setViewToolbar(source, ~)

        releaseRoiWait();

        switch source.Label
            case 'Camera Toolbar'
                cameratoolbar toggle;

                if camToolbar('get')
                    set(mViewCam, 'Checked', 'off');
                    camToolbar('set', false);
                else
                    set(mViewCam, 'Checked', 'on');
                    camToolbar('set', true);
                end

            case 'Plot Edit Toolbar'
                plotedit(fiMainWindowPtr('get'), 'plotedittoolbar', 'toggle');

                if editToolbar('get')

                    set(mViewEdit, 'Checked', 'off');
                    editToolbar('set', false);

                    plotEditSetAxeBorder(false);
                    mainToolBarEnable('on');
                    plotedit('off');

                else
                    toolButtons = plotedit(fiMainWindowPtr('get'),'gettoolbuttons');
            %        set(findall(toolButtons, 'tag', 'Annotation.InsertLine'       ), 'Visible', 'off');
            %        set(findall(toolButtons, 'tag', 'Annotation.InsertEllipse'    ), 'Visible', 'off');
            %        set(findall(toolButtons, 'tag', 'Annotation.InsertRectangle'  ), 'Visible', 'off');
            %        set(findall(toolButtons, 'tag', 'Annotation.InsertTextbox'    ), 'Visible', 'off');
            %        set(findall(toolButtons, 'tag', 'Annotation.InsertTextArrow'  ), 'Visible', 'off');
            %        set(findall(toolButtons, 'tag', 'Annotation.InsertDoubleArrow'), 'Visible', 'off');
            %        set(findall(toolButtons, 'tag', 'Annotation.InsertArrow'      ), 'Visible', 'off');
                    set(findall(toolButtons, 'tag', 'Annotation.AlignDistribute'  ), 'Visible', 'off');

                    set(mViewEdit, 'Checked', 'on');
                    editToolbar('set', true);

                    plotEditSetAxeBorder(true);
                    mainToolBarEnable('off');
                    plotedit('on');
                end

            case 'Playback Toolbar'
                if playback3DToolbar('get')

             %       set(mViewPlayback, 'Checked', 'off');
                    setPlaybackToolbar('off');

                else
            %        set(mViewPlayback, 'Checked', 'on');
                    setPlaybackToolbar('on');
                end

            case 'ROI Toolbar'
                if roiToolbar('get')

     %               set(mViewRoi, 'Checked', 'off');
     %               roiToolbar('set', false);

                    setRoiToolbar('off');

                else
    %                set(mViewRoi, 'Checked', 'on');
    %                roiToolbar('set', true);

                    setRoiToolbar('on');
                end

       %     case 'Segmentation Panel'

          %            tbSeg = uitoolbar(fiMainWindowPtr('get'));

         %             uicontrol(fiMainWindowPtr('get'), ...
         %                     'Style'   , 'Slider', ...
         %                     'Position', [0 0 14 70], ...
         %                     'Value'   , 0.5, ...
         %                     'Enable'  , 'on' ...
         %                     );
    %



        end
    end

    function plotEditSetAxeBorder(bStatus)

        if bStatus == true

            if exist('axe', 'var')
                set(uiOneWindowPtr('get'), 'HighlightColor', [0 1 1]);
                set(uiOneWindowPtr('get'), 'BorderWidth'   , 1);
            end

            if ~isempty(axes1Ptr('get')) && ...
               ~isempty(axes2Ptr('get')) && ...
               ~isempty(axes3Ptr('get'))

                set(uiCorWindowPtr('get'), 'HighlightColor', [0 1 1]);
                set(uiCorWindowPtr('get'), 'BorderWidth'   , 1);

                set(uiSagWindowPtr('get'), 'HighlightColor', [0 1 1]);
                set(uiSagWindowPtr('get'), 'BorderWidth'   , 1);

                set(uiTraWindowPtr('get'), 'HighlightColor', [0 1 1]);
                set(uiTraWindowPtr('get'), 'BorderWidth'   , 1);
            end
        else

            if exist('axe', 'var')
                set(uiOneWindowPtr('get'), 'BorderWidth', showBorder('get'));
            end

            if ~isempty(axes1Ptr('get')) && ...
               ~isempty(axes2Ptr('get')) && ...
               ~isempty(axes3Ptr('get'))

                set(uiCorWindowPtr('get'), 'BorderWidth', showBorder('get'));
                set(uiSagWindowPtr('get'), 'BorderWidth', showBorder('get'));
                set(uiTraWindowPtr('get'), 'BorderWidth', showBorder('get'));
            end
        end

    end

    function setInsertMenuCallback(source, ~)

        releaseRoiWait();

        switch source.Label
                case 'Line'
                editPlot('set', true);
                set(mEditPlot, 'Checked', 'on');
                mainToolBarEnable('off');

                plotEditSetAxeBorder(true);
                activePlotObject('line');

            case 'Arrow'
                editPlot('set', true);
                set(mEditPlot, 'Checked', 'on');
                mainToolBarEnable('off');

                plotEditSetAxeBorder(true);
                activePlotObject('arrow');

            case 'Text Arrow'
                editPlot('set', true);
                set(mEditPlot, 'Checked', 'on');
                mainToolBarEnable('off');

                plotEditSetAxeBorder(true);
                activePlotObject('textarrow')

            case 'Double Arrow'
                editPlot('set', true);
                set(mEditPlot, 'Checked', 'on');
                mainToolBarEnable('off');

                plotEditSetAxeBorder(true);
                activePlotObject('doublearrow')

            case 'Text Box'
                editPlot('set', true);
                set(mEditPlot, 'Checked', 'on');
                mainToolBarEnable('off');

                plotEditSetAxeBorder(true);
                activePlotObject('textbox');

            case 'Rectangle'
                editPlot('set', true);
                set(mEditPlot, 'Checked', 'on');
                set(btnTriangulatePtr('get'), 'Enable', 'off');
                mainToolBarEnable('off');

                plotEditSetAxeBorder(true);
                activePlotObject('rectangle');

            case 'Ellipse'
                editPlot('set', true);
                set(mEditPlot, 'Checked', 'on');
                mainToolBarEnable('off');

                plotEditSetAxeBorder(true);
                activePlotObject('ellipse');


            case 'Plot Editor'
                if editPlot('get')
                    set(mEditPlot, 'Checked', 'off');
                    mainToolBarEnable('on');

                    if panTool('get') || zoomTool('get')
                      set(btnTriangulatePtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
                      set(btnTriangulatePtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
                    else
                      set(btnTriangulatePtr('get'), 'BackgroundColor', viewerButtonPushedBackgroundColor('get'));
                      set(btnTriangulatePtr('get'), 'ForegroundColor', viewerButtonPushedForegroundColor('get'));
                    end

                    editPlot('set', false);
                    plotEditSetAxeBorder(false);
                    plotedit('off');

                else
                    set(mEditPlot, 'Checked', 'on');

                    mainToolBarEnable('off');

                    editPlot('set', true);
                    plotEditSetAxeBorder(false);
                    plotedit('on');
                end

        end

    end

    function activePlotObject(sObject)

        hPlotEdit = plotedit(fiMainWindowPtr('get'), 'getmode');
        hMode = hPlotEdit.ModeStateData.CreateMode;
        hMode.ModeStateData.ObjectName = sObject;

        activateuimode(hPlotEdit, hMode.Name);

    end
end
