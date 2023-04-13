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
    uimenu(mFile,'Label', 'Open...'                       , 'Callback',@setSourceCallback);
    uimenu(mFile,'Label', 'Import .raw file...'           ,'Callback', @importRawCallback);
    uimenu(mFile,'Label', 'Import .stl file...'           ,'Callback', @importSTLCallback);
    uimenu(mFile,'Label', 'Import .nii file...'           ,'Callback', @importNIICallback);
    uimenu(mFile,'Label', 'Import .nii mask file...'      ,'Callback', @importNIIMaskCallback);
    uimenu(mFile,'Label', 'Import RT-Structure...'        ,'Callback', @importContoursCallback);    
    uimenu(mFile,'Label', 'Import CERR planC...'          ,'Callback', @importCerrPlanCCallback, 'Separator','on');
    uimenu(mFile,'Label', 'Import CERR Dose Volume...'    ,'Callback', @importCerrDoseVolumeCallback);
    uimenu(mFile,'Label', 'Import CERR Dose Constraint...','Callback', @importCerrDoseConstraintCallback);
    uimenu(mFile,'Label', 'Import Dose Kernel...'         ,'Callback', @importDoseKernelCallback);

    uimenu(mFile,'Label', 'Export DICOM...'                   ,'Callback', @writeDICOMCallback, 'Separator','on');
    uimenu(mFile,'Label', 'Export DICOM All Series...'        ,'Callback', @writeDICOMAllSeriesCallback);
 %   uimenu(mFile,'Label', 'Export to Excel...','Callback', @exportAllSeriesResultCallback);
    uimenu(mFile,'Label', 'Export Contours to DICOM-Mask...'  ,'Callback', @writeRoisToDicomMaskCallback);
    uimenu(mFile,'Label', 'Export Contours to RT-Structure...','Callback', @writeRTStructCallback);
    uimenu(mFile,'Label', 'Export 3D ISO Model to STL...'     ,'Callback', @exportISOtoSTLCallback);
    uimenu(mFile,'Label', 'Export 3D Rendering to Slices...'  ,'Callback', @export3DToSlicesCallback);
    
    uimenu(mFile,'Label', 'Print Preview...','Callback', 'filemenufcn(gcbf,''FilePrintPreview'')', 'Separator','on');
    uimenu(mFile,'Label', 'Print...','Callback', 'printdlg(gcbf)');
    uimenu(mFile,'Label', 'Exit' ,'Callback', 'close', 'Separator','on');

    mEdit = uimenu(fiMainWindowPtr('get'),'Label','Edit');
    uimenu(mEdit,'Label', 'Copy Display'   , 'Callback', @copyDisplayCallback);
    uimenu(mEdit,'Label', 'Patient Dose...', 'Callback', @setPatientDoseCallback, 'Separator','on');    

    mOptions = uimenu(mEdit,'Label', 'Viewer Properties...', 'Callback', @setOptionsCallback);
    optionsPanelMenuObject('set', mOptions);

    mView = uimenu(fiMainWindowPtr('get'),'Label','View');
       
    mVsplashAxial    = uimenu(mView, 'Label','V-Splash Axial'   , 'Callback', @setVsplashViewCallback, 'Separator','on');
    mVsplashSagittal = uimenu(mView, 'Label','V-Splash Sagittal', 'Callback', @setVsplashViewCallback);
    mVslashCoronal   = uimenu(mView, 'Label','V-Splash Coronal' , 'Callback', @setVsplashViewCallback);
    mVslashAll       = uimenu(mView, 'Label','V-Splash All'     , 'Callback', @setVsplashViewCallback);

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

    mViewCam  = uimenu(mView, 'Label','Camera Toolbar'   , 'Callback', @setViewToolbar, 'Separator','on');
    mViewEdit = uimenu(mView, 'Label','Plot Edit Toolbar', 'Callback', @setViewToolbar);

    mViewRoi = uimenu(mView, 'Label','ROI Toolbar' , 'Callback', @setViewToolbar);
    viewRoiObject('set', mViewRoi);

    mViewPlayback = uimenu(mView, 'Label','Playback Toolbar' , 'Callback', @setViewToolbar);
    viewPlaybackObject('set', mViewPlayback);    
    
    mViewSegPanel = uimenu(mView, 'Label','Image Panel' , 'Callback', @setViewSegPanel, 'Separator', 'on');
    viewSegPanelMenuObject('set', mViewSegPanel);

    mViewKernelPanel = uimenu(mView, 'Label','Kernel Panel', 'Callback', @setViewKernelPanel);
    viewKernelPanelMenuObject('set', mViewKernelPanel);

    mViewRoiPanel = uimenu(mView, 'Label','Contour Panel', 'Callback', @setViewRoiPanel);
    viewRoiPanelMenuObject('set', mViewRoiPanel);
    
    m3DPanel = uimenu(mView, 'Label','3D Panel', 'Callback', @setView3DPanel);
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
%    mTotalSegmentation = uimenu(mTools, 'Label','Total Segmentation', 'Callback', @totalSegmentationCallback);
   
%     uimenu(mTools, 'Label','Fusion'      , 'Callback', @setFusionCallback);
%     rotate3DMenu  ('set', uimenu(mTools, 'Label','Rotate 3D'  , 'Callback', @setRotate3DCallback));
    panMenu       ('set', uimenu(mTools, 'Label','Pan'      , 'Callback', @setPanCallback));
    zoomMenu      ('set', uimenu(mTools, 'Label','Zoom'     , 'Callback', @setZoomCallback));
    rotate3DMenu  ('set', uimenu(mTools, 'Label','Rotate 3D', 'Callback', @setRotate3DCallback));
 %   dataCursorMenu('set', uimenu(mTools, 'Label','Data Cursor', 'Callback', @setDataCursorCallback)); 
    uimenu(mTools, 'Label','Reset View', 'Callback','toolsmenufcn ResetView');
    
    mAxial    = uimenu(mTools, 'Label','Original Orientation'     , 'Callback', @setOrientationCallback, 'Separator','on');
    mCoronal  = uimenu(mTools, 'Label','Permute Coronal to Axial' , 'Callback', @setOrientationCallback);
    mSagittal = uimenu(mTools, 'Label','Permute Sagittal to Axial', 'Callback', @setOrientationCallback);
    
    axialOrientationMenuPtr   ('set', mAxial   );
    coronalOrientationMenuPtr ('set', mCoronal );    
    sagittalOrientationMenuPtr('set', mSagittal);
    
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
    
    uimenu(mTools, 'Label','Registration'                  , 'Callback', @setRegistrationCallback, 'Separator','on');
    uimenu(mTools, 'Label','Mathematic'                    , 'Callback', @setMathCallback);
    uimenu(mTools, 'Label','Compute 2D MIP'                , 'Callback', @computeMIPCallback, 'Separator','on');
    uimenu(mTools, 'Label','Create Planar from a 3D Series', 'Callback', @convertSeriesToPlanarCallback, 'Separator','on');
    uimenu(mTools, 'Label','Dice Contours'                 , 'Callback', @diceContoursCallback, 'Separator','on');
    uimenu(mTools, 'Label','Reset Series'                  , 'Callback', @resetSeriesCallback, 'Separator','on');


    mWorkflows = uimenu(fiMainWindowPtr('get'),'Label','Workflows');  
    mSegmentation = uimenu(mWorkflows,'Label','Segmentation');  
    uimenu(mSegmentation, 'Label','FDG Tumor Segmentation'                       , 'Callback', @setSegmentationFDGCallback);
    uimenu(mSegmentation, 'Label','Ga68 DOTATATE Segmentation (Machine Learning)', 'Callback', @setMachineLearningGa68DOTATATECallback);
    uimenu(mWorkflows   , 'Label','PET/CT Fusion', 'Callback', @setPETCTFusionCallback);
    
    
    mModules = uimenu(fiMainWindowPtr('get'),'Label','Modules');
    mMachineLearning = uimenu(mModules, 'Label','Machine Learning');
    uimenu(mMachineLearning, 'Label','Machine Learning Segmentation', 'Callback', @setMachineLearningSegmentationCallback);

    mMachineReport = uimenu(mMachineLearning, 'Label','Machine Learning Report', 'Separator','on');
    uimenu(mMachineReport, 'Label','3D SPECT Lung Shunt Report'      , 'Callback', @generate3DLungShuntReportCallback);
    uimenu(mMachineReport, 'Label','3D SPECT Lung Lobe Ration Report', 'Callback', @generate3DLungLobeReportCallback);
    uimenu(mMachineReport, 'Label','PET Y90 Liver Dosimetry Report'  , 'Callback', @generatePETLiverDosimetryReportCallback);

    uimenu(mMachineLearning, 'Label','3D SPECT Lung Shunt'     , 'Callback', @setMachineLearning3DLungShuntCallback, 'Separator','on');
    uimenu(mMachineLearning, 'Label','3D SPECT Lung Lobe Ratio', 'Callback', @setMachineLearning3DLobeLungCallback);
    uimenu(mMachineLearning, 'Label','PET Y90 Liver Dosimetry' , 'Callback', @setMachineLearningPETLiverDosimetryCallback);

    mRadiomics = uimenu(mModules, 'Label','Radiomics');
    uimenu(mRadiomics, 'Label','Compute Radiomics', 'Callback', @extractRadiomicsFromContoursCallback);

    mHelp = uimenu(fiMainWindowPtr('get'),'Label','Help');
    uimenu(mHelp,'Label', 'Shortcuts', 'Callback'  , @shortcutsViewerCallback);
    uimenu(mHelp,'Label', 'User Manual', 'Callback', @helpViewerCallback);
    uimenu(mHelp,'Label', 'About', 'Callback'      , @aboutViewerCallback, 'Separator','on');
    
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
           isVsplash('get') == false
       
            try

            set(fiMainWindowPtr('get'), 'Pointer', 'watch');
            drawnow;
            
            if strcmpi(get(hObject, 'Label'), 'Axial Plane') && ...
               strcmpi(imageOrientation('get'), 'axial')
           
                set(fiMainWindowPtr('get'), 'Pointer', 'default');
                drawnow;
                return;
            end
            
            if strcmpi(get(hObject, 'Label'), 'Coronal Plane') && ...
               strcmpi(imageOrientation('get'), 'coronal')
           
                set(fiMainWindowPtr('get'), 'Pointer', 'default');
                drawnow;           
            
                return;
            end
            
            if strcmpi(get(hObject, 'Label'), 'Sagittal Plane') && ...                
               strcmpi(imageOrientation('get'), 'sagittal')
           
                set(fiMainWindowPtr('get'), 'Pointer', 'default');
                drawnow;
            
                return;
            end
                      
            releaseRoiWait();

            if isFusion('get') == true
                setFusionCallback(); % Deactivate fusion
            end

            if isPlotContours('get') == true
               setPlotContoursCallback(); % Deactivate plot contours
            end
            
            atInputTemplate = inputTemplate('get');
            aInputBuffer    = inputBuffer('get');

            dSeriesOffset = get(uiSeriesPtr('get'), 'Value');
            
            sSeriesInstanceUID = atInputTemplate(dSeriesOffset).atDicomInfo{1}.SeriesInstanceUID;                        
                   
            for kk=1:numel(atInputTemplate) % Scan all series
                
                if strcmpi(sSeriesInstanceUID, atInputTemplate(kk).atDicomInfo{1}.SeriesInstanceUID) % Same series
                                
                    aDicomBuffer = aInputBuffer{kk};
                    atDicomInfo  = atInputTemplate(dSeriesOffset).atDicomInfo;
                    
            
                    if size(aDicomBuffer, 3) == 1
                        continue;
                    end
            
                    if strcmpi(get(hObject, 'Label'), 'Original Orientation')
                        
                        atInputTemplate(kk).sOrientationView = 'Axial';
                        
                        imageOrientation('set', 'axial');

                        dicomBuffer  ('set', aDicomBuffer, kk);
                        dicomMetaData('set', atDicomInfo , kk);
                        
                        if link2DMip('get') == true                                                
                            aReorientedMip = computeMIP(aDicomBuffer);
                            mipBuffer('set', aReorientedMip, kk);
                        end
                        
                        bRefresh = true;

                    elseif strcmpi(get(hObject, 'Label'), 'Permute Coronal to Axial')
                                            
                        atInputTemplate(kk).sOrientationView = 'Coronal';
                       
                        imageOrientation('set', 'coronal');

                        aDicomBuffer = reorientBuffer(aDicomBuffer, 'coronal');
                                             
                        dicomBuffer('set', aDicomBuffer, kk);
                        
                        if link2DMip('get') == true
                            aReorientedMip = computeMIP(aDicomBuffer);
                            mipBuffer('set', aReorientedMip, kk);
                        end
                                               
                        aImageOrientationPatient = zeros(6,1);
        
                        % Axial
                        
                        aImageOrientationPatient(1) = 1;
                        aImageOrientationPatient(5) = 1;
                        
                        dImagePositionPatient = atDicomInfo{1}.ImagePositionPatient;
                        dSliceLocation        = atDicomInfo{1}.SliceLocation;
        
                        x = atDicomInfo{1}.PixelSpacing(1);
                        y = atDicomInfo{1}.PixelSpacing(2);
                        z = computeSliceSpacing(atDicomInfo);                        
                        
                        adBufferSize = size(aDicomBuffer);                        
                        
                        if numel(atDicomInfo) ~= 1
                            if adBufferSize(3) < numel(atDicomInfo)
                                atDicomInfo = atDicomInfo(1:numel(atDicomInfo)); % Remove some slices
                            else
                                for cc=1:adBufferSize(3) - numel(atDicomInfo)
                                    atDicomInfo{end+1} = atDicomInfo{end}; %Add missing slice
                                end            
                            end                
                        end
                        
                        for oo=0:numel(atDicomInfo)-1
                            
                            if oo+1 <= adBufferSize(3) 
                                
                                if isfield(atDicomInfo{oo+1}, 'RescaleSlope')
                                    dTrueMin = min(aDicomBuffer(:,:,oo+1), [],'all');
                                    dTrueMax = max(aDicomBuffer(:,:,oo+1), [],'all');
                                    dTrueRange = dTrueMax-dTrueMin;
                                    fSlope = dTrueRange/65535;                            


                                    atDicomInfo{oo+1}.RescaleSlope = 1;
                                end
                                
                                if isfield(atDicomInfo{oo+1}, 'RescaleIntercept')                                
%                                    atDicomInfo{oo+1}.RescaleIntercept = 0;
                                end
                           end
                            
                            if isfield(atDicomInfo{oo+1}, 'InstanceNumber')
                                atDicomInfo{oo+1}.InstanceNumber = oo+1;
                            end
                            
                            atDicomInfo{oo+1}.PixelSpacing(1) = z;
                            atDicomInfo{oo+1}.PixelSpacing(2) = y;
                            atDicomInfo{oo+1}.NumberOfSlices  = adBufferSize(3);
                            atDicomInfo{oo+1}.ImageOrientationPatient = aImageOrientationPatient;
                            
                            atDicomInfo{oo+1}.ImagePositionPatient(1) = dImagePositionPatient(1);
                            atDicomInfo{oo+1}.ImagePositionPatient(2) = dImagePositionPatient(2);                            
                            atDicomInfo{oo+1}.ImagePositionPatient(3) = dImagePositionPatient(3) - (oo*x);  
                            
                            atDicomInfo{oo+1}.SliceLocation = dSliceLocation - (oo*x);  
                            
                            atDicomInfo{oo+1}.SliceThickness  = x;
                            atDicomInfo{oo+1}.SpacingBetweenSlices  = x;       
                            
                            atDicomInfo{oo+1}.Rows    = adBufferSize(1);
                            atDicomInfo{oo+1}.Columns = adBufferSize(2);                
                        end
                        
                        dicomMetaData('set', atDicomInfo , kk);
                        
                        bRefresh = true;

                   elseif strcmpi(get(hObject, 'Label'), 'Permute Sagittal to Axial')
                                               
                        atInputTemplate(kk).sOrientationView = 'Sagittal';

                        imageOrientation('set', 'sagittal');

                        aImageOrientationPatient = zeros(6,1);
        
                        % Axial
                        
                        aImageOrientationPatient(1) = 1;
                        aImageOrientationPatient(5) = 1;
                        
                        dImagePositionPatient = atDicomInfo{1}.ImagePositionPatient;
                        dSliceLocation        = atDicomInfo{1}.SliceLocation;
                                                
                        x = atDicomInfo{1}.PixelSpacing(1);
                        y = atDicomInfo{1}.PixelSpacing(2);
                        z = computeSliceSpacing(atDicomInfo);  
                                                                        
                        aDicomBuffer = reorientBuffer(aDicomBuffer, 'sagittal');
                        
                        dicomBuffer('set', aDicomBuffer, kk);
                        
                        if link2DMip('get') == true                        
                            aReorientedMip = computeMIP(aDicomBuffer);
                            mipBuffer('set', aReorientedMip, kk);
                        end            
                        
                        adBufferSize = size(aDicomBuffer);
                        
                        if numel(atDicomInfo) ~= 1
                            if adBufferSize(3) < numel(atDicomInfo)
                                atDicomInfo = atDicomInfo(1:numel(atDicomInfo)); % Remove some slices
                            else
                                for cc=1:adBufferSize(3) - numel(atDicomInfo)
                                    atDicomInfo{end+1} = atDicomInfo{end}; %Add missing slice
                                end            
                            end                
                        end
    
                        for oo=0:numel(atDicomInfo)-1
                            
                            if oo+1 <= adBufferSize(3) 
                                
                                if isfield(atDicomInfo{oo+1}, 'RescaleSlope')
                                    dTrueMin = min(aDicomBuffer(:,:,oo+1), [],'all');
                                    dTrueMax = max(aDicomBuffer(:,:,oo+1), [],'all');
                                    dTrueRange = dTrueMax-dTrueMin;
                                    fSlope = dTrueRange/65535;                            


                                    atDicomInfo{oo+1}.RescaleSlope = 1;
                                end
                                
                                if isfield(atDicomInfo{oo+1}, 'RescaleIntercept')                                
%                                    atDicomInfo{oo+1}.RescaleIntercept = 0;
                                end
                            end
                            
                            if isfield(atDicomInfo{oo+1}, 'InstanceNumber')
                                atDicomInfo{oo+1}.InstanceNumber = oo+1;
                            end
                            
                            atDicomInfo{oo+1}.PixelSpacing(1) = x;
                            atDicomInfo{oo+1}.PixelSpacing(2) = z;
                            atDicomInfo{oo+1}.NumberOfSlices  = adBufferSize(3);
                            atDicomInfo{oo+1}.ImageOrientationPatient = aImageOrientationPatient; 
                            atDicomInfo{oo+1}.ImagePositionPatient(1) = dImagePositionPatient(1);
                            atDicomInfo{oo+1}.ImagePositionPatient(2) = dImagePositionPatient(2);
                            atDicomInfo{oo+1}.ImagePositionPatient(3) = dImagePositionPatient(3) - (oo*y);                            
                            
                            atDicomInfo{oo+1}.SliceLocation = dSliceLocation - (oo*y);  

                            atDicomInfo{oo+1}.SliceThickness  = y;
                            atDicomInfo{oo+1}.SpacingBetweenSlices  = y;  
                            
                            atDicomInfo{oo+1}.Rows    = adBufferSize(1);
                            atDicomInfo{oo+1}.Columns = adBufferSize(2);                              
                        end
                        
                        dicomMetaData('set', atDicomInfo , kk);
               
                        bRefresh = true;
                    end
                end
            end
            
            inputTemplate('set', atInputTemplate);

            if  bRefresh == true
                
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
                        
                clearDisplay();
                initDisplay(3);
                dicomViewerCore();

                refreshImages();
            end
            
            catch
                progressBar(1, 'Error:setOrientationCallback()');
            end            
            
            set(fiMainWindowPtr('get'), 'Pointer', 'default');
            drawnow;
            
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

            if ~isempty(axes1Ptr  ('get', [], get(uiSeriesPtr('get'), 'Value'))) && ...
               ~isempty(axes2Ptr  ('get', [], get(uiSeriesPtr('get'), 'Value'))) && ...
               ~isempty(axes3Ptr  ('get', [], get(uiSeriesPtr('get'), 'Value'))) && ...
               ~isempty(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value'))) && ...
               isVsplash('get') == false

                set(uiCorWindowPtr('get'), 'HighlightColor', [0 1 1]);
                set(uiCorWindowPtr('get'), 'BorderWidth'   , 1);

                set(uiSagWindowPtr('get'), 'HighlightColor', [0 1 1]);
                set(uiSagWindowPtr('get'), 'BorderWidth'   , 1);

                set(uiTraWindowPtr('get'), 'HighlightColor', [0 1 1]);
                set(uiTraWindowPtr('get'), 'BorderWidth'   , 1);
                
                set(uiMipWindowPtr('get'), 'HighlightColor', [0 1 1]);
                set(uiMipWindowPtr('get'), 'BorderWidth'   , 1);                
            end
        else

            if exist('axe', 'var')
                set(uiOneWindowPtr('get'), 'BorderWidth', showBorder('get'));
            end

            if ~isempty(axes1Ptr  ('get', [], get(uiSeriesPtr('get'), 'Value'))) && ...
               ~isempty(axes2Ptr  ('get', [], get(uiSeriesPtr('get'), 'Value'))) && ...
               ~isempty(axes3Ptr  ('get', [], get(uiSeriesPtr('get'), 'Value'))) && ...
               ~isempty(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value'))) && ...
               isVsplash('get') == false

                set(uiCorWindowPtr('get'), 'BorderWidth', showBorder('get'));
                set(uiSagWindowPtr('get'), 'BorderWidth', showBorder('get'));
                set(uiTraWindowPtr('get'), 'BorderWidth', showBorder('get'));
                set(uiMipWindowPtr('get'), 'BorderWidth', showBorder('get'));
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

    function resetSeriesCallback(~, ~)

        try
            
        % Deactivate main tool bar 
                
        set(uiSeriesPtr('get'), 'Enable', 'off');                
        mainToolBarEnable('off');
        
        set(fiMainWindowPtr('get'), 'Pointer', 'watch');
        drawnow;        

        resetSeries( get(uiSeriesPtr('get'), 'Value'), true);       
                
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

    function convertSeriesToPlanarCallback(~, ~)
        
    DLG_CONVERT_TO_PLANAR_X = 380;
    DLG_CONVERT_TO_PLANAR_Y = 200;
    
    dlgConvertToPlanar = ...
        dialog('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-DLG_CONVERT_TO_PLANAR_X/2) ...
                            (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-DLG_CONVERT_TO_PLANAR_Y/2) ...
                            DLG_CONVERT_TO_PLANAR_X ...
                            DLG_CONVERT_TO_PLANAR_Y ...
                            ],...
               'MenuBar', 'none',...
               'Resize', 'off', ...    
               'NumberTitle','off',...
               'MenuBar', 'none',...
               'Color', viewerBackgroundColor('get'), ...
               'Name', 'Convert 3D Series To Planar',...
               'Toolbar','none'...               
               );           
           
        axes(dlgConvertToPlanar, ...
             'Units'   , 'pixels', ...
             'Position', [0 0 DLG_CONVERT_TO_PLANAR_X DLG_CONVERT_TO_PLANAR_Y], ...
             'Color'   , viewerBackgroundColor('get'),...
             'XColor'  , viewerForegroundColor('get'),...
             'YColor'  , viewerForegroundColor('get'),...
             'ZColor'  , viewerForegroundColor('get'),...             
             'Visible' , 'off'...             
             );           

        uicontrol(dlgConvertToPlanar,...
                  'style'   , 'text',...
                  'string'  , 'Convert method',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'position', [20 137 150 20]...
                  );
              
    uiConverMethod = ...
        uicontrol(dlgConvertToPlanar, ...
                  'enable'  , 'on',...
                  'Style'   , 'popup', ...
                  'position', [200 140 160 20],...
                  'String'  , {'Current slice', 'All slices add', 'All slices max'}, ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                    
                  'Value'   , 2 ...
                 );

        uicontrol(dlgConvertToPlanar,...
                  'style'   , 'text',...
                  'string'  , 'Plane to convert',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'position', [20 112 150 20]...
                  );
              
    uiPlaneSelection = ...
        uicontrol(dlgConvertToPlanar, ...
                  'enable'  , 'on',...
                  'Style'   , 'popup', ...
                  'position', [200 115 160 20],...
                  'String'  , {'Coronal', 'Sagittal', 'Axial'}, ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                    
                  'Value'   , 3, ...
                  'Callback', @uiPlaneSelectionCallback...
                  );


        uicontrol(dlgConvertToPlanar,...
                  'style'   , 'text',...
                  'string'  , 'From slice:',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'position', [20 87 150 20]...
                  );

    edtFromSlice = ...
      uicontrol(dlgConvertToPlanar,...
                'style'     , 'edit',...
                'Background', 'white',...
                'string'    , '1',...
                'BackgroundColor', viewerBackgroundColor('get'), ...
                'ForegroundColor', viewerForegroundColor('get'), ...                 
                'position'  , [200 90 145 20], ...
                'Callback', @edtFromSliceCallback...
                );

        uicontrol(dlgConvertToPlanar,...
                  'style'   , 'text',...
                  'string'  , 'To Slice:',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'position', [20 62 150 20]...
                  );

    dPlaneSelection  = get(uiPlaneSelection, 'Value');    
    asPlaneSelection = get(uiPlaneSelection, 'String');    
   
    if ~isempty(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')))
        
        if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 3) == 1
            sToSlice = '1'; % 2D image
        else
            aImageSize = size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')));

            if     strcmpi(asPlaneSelection{dPlaneSelection}, 'Coronal')
                sToSlice = num2str(aImageSize(1));
            elseif strcmpi(asPlaneSelection{dPlaneSelection}, 'Sagittal')
                sToSlice = num2str(aImageSize(2));
            else
                sToSlice = num2str(aImageSize(3));
            end
        end
    else
        sToSlice = '1'; % No image
    end

    edtToSlice = ...
      uicontrol(dlgConvertToPlanar,...
                'style'     , 'edit',...
                'Background', 'white',...
                'string'    , sToSlice,...
                'BackgroundColor', viewerBackgroundColor('get'), ...
                'ForegroundColor', viewerForegroundColor('get'), ...                 
                'position'  , [200 65 145 20], ...
                'Callback', @edtToSliceCallback...
                );

     % Cancel or Proceed

     uicontrol(dlgConvertToPlanar,...
               'String','Cancel',...
               'Position',[285 7 75 25],...
               'BackgroundColor', viewerBackgroundColor('get'), ...
               'ForegroundColor', viewerForegroundColor('get'), ...                
               'Callback', @cancelConvertToPlanarCallback...
               );

     uicontrol(dlgConvertToPlanar,...
              'String','Proceed',...
              'Position',[200 7 75 25],...
              'BackgroundColor', viewerBackgroundColor('get'), ...
              'ForegroundColor', viewerForegroundColor('get'), ...               
              'Callback', @proceedConvertToPlanarCallback...
              );

        function uiPlaneSelectionCallback(~, ~)

            if ~isempty(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')))
                
                if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 3) == 1
                    sToSlice = '1'; % 2D image
                else
                    aImageSize = size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')));

                    dPlaneSelection  = get(uiPlaneSelection, 'Value');    
                    asPlaneSelection = get(uiPlaneSelection, 'String');   

                    if     strcmpi(asPlaneSelection{dPlaneSelection}, 'Coronal')
                        sToSlice = num2str(aImageSize(1));
                    elseif strcmpi(asPlaneSelection{dPlaneSelection}, 'Sagittal')
                        sToSlice = num2str(aImageSize(2));
                    else
                        sToSlice = num2str(aImageSize(3));
                    end
                end
            else
                sToSlice = '1'; % No image
            end

            set(edtFromSlice, 'string', '1');
            set(edtToSlice  , 'string', sToSlice);          
        end

        function edtFromSliceCallback(~, ~)

            dPlaneSelection  = get(uiPlaneSelection, 'Value');    
            asPlaneSelection = get(uiPlaneSelection, 'String');    

            if ~isempty(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')))
                
                if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 3) == 1
                    dFromSliceMax = 1; % 2D image
                else
                    aImageSize = size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')));
        
                    if     strcmpi(asPlaneSelection{dPlaneSelection}, 'Coronal')
                        dFromSliceMax = aImageSize(1);
                    elseif strcmpi(asPlaneSelection{dPlaneSelection}, 'Sagittal')
                        dFromSliceMax = aImageSize(2);
                    else
                        dFromSliceMax = aImageSize(3);
                    end
                end
            else
                dFromSliceMax = 1; % No image
            end

            dFromSlice = str2double(get(edtFromSlice, 'string'));
            dToSlice   = str2double(get(edtToSlice  , 'string'));

            if dFromSlice < 0
                set(edtFromSlice  , 'string', '1');
                dFromSlice = 1;
            end

            if dFromSlice > dToSlice
                set(edtFromSlice  , 'string', num2str(dToSlice));
            end

            if dFromSlice > dFromSliceMax
                set(edtFromSlice  , 'string', num2str(dFromSliceMax));
            end

        end

        function edtToSliceCallback(~, ~)

            dPlaneSelection  = get(uiPlaneSelection, 'Value');    
            asPlaneSelection = get(uiPlaneSelection, 'String');    

            if ~isempty(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')))
                
                if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 3) == 1
                    dToSliceMax = 1; % 2D image
                else
                    aImageSize = size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')));
        
                    if     strcmpi(asPlaneSelection{dPlaneSelection}, 'Coronal')
                        dToSliceMax = aImageSize(1);
                    elseif strcmpi(asPlaneSelection{dPlaneSelection}, 'Sagittal')
                        dToSliceMax = aImageSize(2);
                    else
                        dToSliceMax = aImageSize(3);
                    end
                end
            else
                dToSliceMax = 1; % No image
            end

            dFromSlice = str2double(get(edtFromSlice, 'string'));
            dToSlice   = str2double(get(edtToSlice  , 'string'));

            if dToSlice < 0 
                set(edtToSlice  , 'string', num2str(dToSliceMax));
                dToSlice = dToSliceMax;
            end

            if dToSlice < dFromSlice
                set(edtToSlice  , 'string', num2str(dFromSlice));
            end

            if dToSlice > dToSliceMax
                set(edtToSlice  , 'string', num2str(dToSliceMax));
            end


        end

        function cancelConvertToPlanarCallback(~, ~)
            delete(dlgConvertToPlanar);
        end
          
        function proceedConvertToPlanarCallback(~, ~)  

            dPlaneValue   = get(uiPlaneSelection, 'Value');
            asPlaneString = get(uiPlaneSelection, 'String');
            sPlane = asPlaneString{dPlaneValue};

            dMethodValue   = get(uiConverMethod, 'Value');
            asMethodString = get(uiConverMethod, 'String');
            sMethod = asMethodString{dMethodValue};

            dFromSlice = str2double(get(edtFromSlice, 'String'));
            dToSlice   = str2double(get(edtToSlice  , 'String'));

            convert3DSeriesToPlanar(sPlane, sMethod, dFromSlice, dToSlice);
            
            delete(dlgConvertToPlanar);

        end

    end

    function diceContoursCallback(~, ~)
        
        DLG_DICE_CONTOURS_X = 380;
        DLG_DICE_CONTOURS_Y = 160;

        dlgDiceContours = ...
            dialog('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-DLG_DICE_CONTOURS_X/2) ...
                                (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-DLG_DICE_CONTOURS_Y/2) ...
                                DLG_DICE_CONTOURS_X ...
                                DLG_DICE_CONTOURS_Y ...
                                ],...
                   'MenuBar', 'none',...
                   'Resize', 'off', ...    
                   'NumberTitle','off',...
                   'MenuBar', 'none',...
                   'Color', viewerBackgroundColor('get'), ...
                   'Name', 'Dice Contours',...
                   'Toolbar','none'...               
                   );           

            axes(dlgDiceContours, ...
                 'Units'   , 'pixels', ...
                 'Position', [0 0 DLG_DICE_CONTOURS_X DLG_DICE_CONTOURS_Y], ...
                 'Color'   , viewerBackgroundColor('get'),...
                 'XColor'  , viewerForegroundColor('get'),...
                 'YColor'  , viewerForegroundColor('get'),...
                 'ZColor'  , viewerForegroundColor('get'),...             
                 'Visible' , 'off'...             
                 );
                       
        atVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
        asContoursLabel = [];
        dContour1Offset = 1;
        dContour2Offset = 1;      
        dNbVOIs = 0;
        if ~isempty(atVoiInput)
            dNbVOIs = numel(atVoiInput);
            if dNbVOIs >= 2
                for jj=1:dNbVOIs
                    asContoursLabel{jj}=atVoiInput{jj}.Label;
                    dContour1Offset = 1;
                    dContour2Offset = 2;
                end
            else
                asContoursLabel = ' ';                
            end
        else
            asContoursLabel = ' ';            
        end
        
             uicontrol(dlgDiceContours,...
                      'style'   , 'text',...
                      'string'  , 'Volume-of-interest 1',...
                      'horizontalalignment', 'left',...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...                   
                      'position', [20 117 150 20]...
                      );
                  
        uiContours1 = ...
            uicontrol(dlgDiceContours, ...
                      'enable'  , 'on',...
                      'Style'   , 'popup', ...
                      'position', [200 120 160 20],...
                      'String'  , asContoursLabel, ...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...                    
                      'Value'   , dContour1Offset ...
                      );
                  
            uicontrol(dlgDiceContours,...
                      'style'   , 'text',...
                      'string'  , 'Volume-of-interest 2',...
                      'horizontalalignment', 'left',...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...                   
                      'position', [20 87 150 20]...
                      );

        uiContours2 = ...
            uicontrol(dlgDiceContours, ...
                      'enable'  , 'on',...
                      'Style'   , 'popup', ...
                      'position', [200 90 160 20],...
                      'String'  , asContoursLabel, ...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...                    
                      'Value'   , dContour2Offset ...
                      );
                  
            uicontrol(dlgDiceContours,...
                      'style'   , 'text',...
                      'string'  , 'Dice Value:',...
                      'horizontalalignment', 'left',...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...                   
                      'position', [20 55 150 20]...
                      );
                  
        txtDice = ...
            uicontrol(dlgDiceContours,...
                      'style'   , 'text',...
                      'string'  , '0',...
                      'horizontalalignment', 'left',...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...                   
                      'position', [200 55 150 20]...
                      );
                  
         % Cancel or Proceed

         uicontrol(dlgDiceContours,...
                   'String','Cancel',...
                   'Position',[285 7 75 25],...
                   'BackgroundColor', viewerBackgroundColor('get'), ...
                   'ForegroundColor', viewerForegroundColor('get'), ...                
                   'Callback', @cancelDiceContoursCallback...
                   );

         uicontrol(dlgDiceContours,...
                  'String','Compute',...
                  'Position',[200 7 75 25],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...               
                  'Callback', @computeDiceContoursCallback...
                  );  
              
        function cancelDiceContoursCallback(~, ~) 
            
            delete(dlgDiceContours);
        end
        
        function computeDiceContoursCallback(~, ~)
            
            atRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
            
            if dNbVOIs >= 2
                
%                tQuant = quantificationTemplate('get');

%                if isfield(tQuant, 'tSUV')
%                    dSUVScale = tQuant.tSUV.dScale;
%                else
%                    dSUVScale = 0;
%                end
        
 %               atMetaData = dicomMetaData('get', [], get(uiSeriesPtr('get'), 'Value'));

                aDisplayBuffer = dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value'));
                
                aMask1 = zeros(size(aDisplayBuffer));
                aMask2 = zeros(size(aDisplayBuffer));
        
                dContour1Offset = get(uiContours1, 'Value');
                dContour2Offset = get(uiContours2, 'Value');
                
                asRoisTag1 = atVoiInput{dContour1Offset}.RoisTag;
                        
                for kk=1:numel(asRoisTag1)
                    
                    aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[asRoisTag1{kk}]} );
                    ptrRoi = atRoiInput{find(aTagOffset, 1)};
        
                    switch lower(ptrRoi.Axe)    

                        case 'axe'
                            imCData = aDisplayBuffer(:,:); 

                        case 'axes1'
                            imCData = permute(aDisplayBuffer(ptrRoi.SliceNb,:,:), [3 2 1]);

                        case 'axes2'
                            imCData = permute(aDisplayBuffer(:,ptrRoi.SliceNb,:), [3 1 2]) ;

                        case 'axes3'
                            imCData = aDisplayBuffer(:,:,ptrRoi.SliceNb);  

                        otherwise   
                    end          
                    
                    mask = roiTemplateToMask(ptrRoi, imCData);  
                    imCData(imCData~=0)=0;
                    imCData(mask)=1;
                    
                    switch lower(ptrRoi.Axe)    

                        case 'axe'
                            aMask1 = imCData; 

                        case 'axes1'
                            aMask1(ptrRoi.SliceNb,:,:) = aMask1(ptrRoi.SliceNb,:,:)|imCData;

                        case 'axes2'
                            aMask1(:,ptrRoi.SliceNb,:) = aMask1(:,ptrRoi.SliceNb,:)|imCData;

                        case 'axes3'
                            aMask1(:,:,ptrRoi.SliceNb) = aMask1(:,:,ptrRoi.SliceNb)|imCData;  

                        otherwise   
                    end   
                    
                end
                                
                asRoisTag2 = atVoiInput{dContour2Offset}.RoisTag;
                for kk=1:numel(asRoisTag2)
                    
                    aTagOffset = strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), {[asRoisTag2{kk}]} );
                    ptrRoi = atRoiInput{find(aTagOffset, 1)};
        
                    switch lower(ptrRoi.Axe)    

                        case 'axe'
                            imCData = aDisplayBuffer(:,:); 

                        case 'axes1'
                            imCData = permute(aDisplayBuffer(ptrRoi.SliceNb,:,:), [3 2 1]);

                        case 'axes2'
                            imCData = permute(aDisplayBuffer(:,ptrRoi.SliceNb,:), [3 1 2]) ;

                        case 'axes3'
                            imCData = aDisplayBuffer(:,:,ptrRoi.SliceNb);  

                        otherwise   
                    end          
                    
                    mask = roiTemplateToMask(ptrRoi, imCData);  
                    imCData(imCData~=0)=0;
                    imCData(mask)=1;
                    
                    switch lower(ptrRoi.Axe)    

                        case 'axe'
                            aMask2 =imCData; 

                        case 'axes1'
                            aMask2(ptrRoi.SliceNb,:,:) = aMask2(ptrRoi.SliceNb,:,:)|imCData;

                        case 'axes2'
                            aMask2(:,ptrRoi.SliceNb,:) = aMask2(:,ptrRoi.SliceNb,:)|imCData;

                        case 'axes3'
                            aMask2(:,:,ptrRoi.SliceNb) = aMask2(:,:,ptrRoi.SliceNb)|imCData;  

                        otherwise   
                    end   
                    
                end                
                
                dDiceValue = dice(aMask1, aMask2);
                
                set(txtDice, 'String', num2str(dDiceValue));
                
%                delete(dlgDiceContours);

            else
                
                delete(dlgDiceContours);               
            end
        end
        
    end

end
