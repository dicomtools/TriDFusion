function setSourceCallback(~, ~)
%function setSourceCallback(~, ~)
%Open a New DICOM Series.
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

     sCurrentDir  = viewerRootPath('get');

     sMatFile = [sCurrentDir '/' 'lastOpenDir.mat'];
     % load last data directory
     if exist(sMatFile, 'file')
                                % lastDirMat mat file exists, load it
        load('-mat', sMatFile);
        if exist('openLastUsedDir', 'var')
            sCurrentDir = openLastUsedDir;
        end
        if sCurrentDir == 0
            sCurrentDir = pwd;
        end
     end

    bValidDir = false;

    sMainDir{1} = uigetdir(sCurrentDir);

    if sMainDir{1} ~= 0
        
         % Deactivate main tool bar 
        set(uiSeriesPtr('get'), 'Enable', 'off');                        
        mainToolBarEnable('off');       
        
        sMainDir{1} = [sMainDir{1} '/'];

        try
            openLastUsedDir = sMainDir{1};
            save(sMatFile, 'openLastUsedDir');
        catch
            progressBar(1 , sprintf('Warning: Cant save file %s', sMatFile));
%            h = msgbox(sprintf('Warning: Cant save file %s', sMatFile), 'Warning');
%            if integrateToBrowser('get') == true
%                sLogo = './TriDFusion/logo.png';
%            else
%                sLogo = './logo.png';
%            end

%            javaFrame = get(h, 'JavaFrame');
%            javaFrame.setFigureIcon(javax.swing.ImageIcon(sLogo));
        end

      %  aDirlist = dir(sMainDir{1});

        f = java.io.File(char(sMainDir{1}));
        aDirlist = f.listFiles();

        j=1;
        for dDirOffset = 1 : numel(aDirlist)
            if aDirlist(dDirOffset).isDirectory

                asSubDir{j} = [sMainDir{1} char(aDirlist(dDirOffset).getName)];

                if asSubDir{j}(end) ~= '\' || ...
                   asSubDir{j}(end) ~= '/'
                    asSubDir{j} = [asSubDir{j} '/'];
                end
                j = j+1;
                bValidDir = true;

            end
        end

        if bValidDir == true
            mainDir('set', asSubDir);
        else
            mainDir('set', sMainDir);
        end

        if(numel(mainDir('get')))
            
            % Restore ISOsurface default value. Those value will be use in
            % setIsoSurfaceCallback(~, ~). 

            isoColorOffset        ('set', defaultIsoColorOffset('get') ); 
            isoSurfaceValue       ('set', defaultIsoSurfaceValue('get')); 
            isoColorFusionOffset  ('set', defaultIsoColorFusionOffset('get')); 
            isoSurfaceFusionValue ('set', defaultIsoSurfaceFusionValue('get'));
        
            if isFusion('get') == true % Deactivate fusion
                 setFusionCallback();
            end
            
            set(fiMainWindowPtr('get'), 'Pointer', 'watch');
            drawnow;

            copyRoiPtr('set', '');

            isMoveImageActivated('set', false);

            releaseRoiWait();

            isFusion('set', false);
            
            outputDir('set', '');

            inputTemplate('set', '');
            inputBuffer('set', '');
            inputContours('set', '');

            dicomMetaData('reset');
            dicomBuffer  ('reset');
            fusionBuffer ('reset');

            mipBuffer      ('reset');
            mipFusionBuffer('reset');

            initWindowLevel('set', true);
            initFusionWindowLevel ('set', true);
            roiTemplate('reset');
            voiTemplate('reset');

            getMipAlphaMap('set', '', 'auto');
            getVolAlphaMap('set', '', 'auto');

            getMipFusionAlphaMap('set', '', 'auto');
            getVolFusionAlphaMap('set', '', 'auto');

            deleteAlphaCurve('vol');
            deleteAlphaCurve('volfusion');

            volColorObj = volColorObject('get');
            if ~isempty(volColorObj)
                delete(volColorObj);
                volColorObject('set', '');
            end

            deleteAlphaCurve('mip');
            deleteAlphaCurve('mipfusion');

            mipColorObj = mipColorObject('get');
            if ~isempty(mipColorObj)
                delete(mipColorObj);
                mipColorObject('set', '');
            end

            logoObj = logoObject('get');
            if ~isempty(logoObj)
                delete(logoObj);
                logoObject('set', '');
            end

            volObj = volObject('get');
            if ~isempty(volObj)
                delete(volObj);
                volObject('set', '');
            end

            volFuisonObj = volFusionObject('get');
            if ~isempty(volFuisonObj)
                delete(volFuisonObj);
                volFusionObject('set', '');
            end

            isoObj = isoObject('get');
            if ~isempty(isoObj)
                delete(isoObj);
                isoObject('set', '');
            end

            mipObj = mipObject('get');
            if ~isempty(mipObj)
                delete(mipObj);
                mipObject('set', '');
            end

            mipFusionObj = mipFusionObject('get');
            if ~isempty(mipFusionObj)
                delete(mipFusionObj);
                mipObject('set', '');
            end

            voiObj = voiObject('get');
            if ~isempty(voiObj)
                for vv=1:numel(voiObj)
                    delete(voiObj{vv})
                end
                voiObject('set', '');
            end

            isoGateObj = isoGateObject('get');
            if ~isempty(isoGateObj)
                for vv=1:numel(isoGateObj)
                    delete(isoGateObj{vv});
                end
                isoGateObject('set', '');
            end

            mipGateObj = mipGateObject('get');
            if ~isempty(mipGateObj)
                for vv=1:numel(mipGateObj)
                    delete(mipGateObj{vv});
                end
                mipGateObject('set', '');
            end

            volGateObj = volGateObject('get');
            if ~isempty(volGateObj)
                for vv=1:numel(volGateObj)
                    delete(volGateObj{vv})
                end
                volGateObject('set', '');
            end

            voiGateObj = voiGateObject('get');
            if ~isempty(voiGateObj)
                for tt=1:numel(voiGateObj)
                    for ll=1:numel(voiGateObj{tt})
                        delete(voiGateObj{tt}{ll});
                    end
                end
                voiGateObject('set', '');
            end

            ui3DGateWindowObj = ui3DGateWindowObject('get');
            if ~isempty(ui3DGateWindowObj)
                for vv=1:numel(ui3DGateWindowObj)
                    delete(ui3DGateWindowObj{vv})
                end
                ui3DGateWindowObject('set', '');
            end

            uiSegMainPanel = uiSegMainPanelPtr('get');
            if ~isempty(uiSegMainPanel)
                set(uiSegMainPanel, 'Visible', 'off');
            end

            viewSegPanel('set', false);
            objSegPanel = viewSegPanelMenuObject('get');
            if ~isempty(objSegPanel)
                objSegPanel.Checked = 'off';
            end

            uiKernelMainPanel = uiKernelMainPanelPtr('get');
            if ~isempty(uiKernelMainPanel)
                set(uiKernelMainPanel, 'Visible', 'off');
            end

            viewKernelPanel('set', false);
            objKernelPanel = viewKernelPanelMenuObject('get');
            if ~isempty(objKernelPanel)
                objKernelPanel.Checked = 'off';
            end

            uiRoiMainPanel = uiRoiMainPanelPtr('get');
            if ~isempty(uiRoiMainPanel)
                set(uiRoiMainPanel, 'Visible', 'off');
            end

            viewRoiPanel('set', false);
            objRoiPanel = viewRoiPanelMenuObject('get');
            if ~isempty(objRoiPanel)
                objRoiPanel.Checked = 'off';
            end

            view3DPanel('set', false);
            init3DPanel('set', true);

            obj3DPanel = view3DPanelMenuObject('get');
            if ~isempty(obj3DPanel)
                obj3DPanel.Checked = 'off';
            end

            mPlay = playIconMenuObject('get');
            if ~isempty(mPlay)
                mPlay.State = 'off';
         %       playIconMenuObject('set', '');
            end

            mRecord = recordIconMenuObject('get');
            if ~isempty(mRecord)
                mRecord.State = 'off';
          %      recordIconMenuObject('set', '');
            end
            
            isoMaskCtSerieOffset ('set', 1);    
            kernelCtSerieOffset  ('set', 1);
            mipFusionBufferOffset('set', 1);
    
            multiFrame3DPlayback('set', false);
            multiFrame3DRecord  ('set', false);
            multiFrame3DIndex   ('set', 1);
            multiFrame3DZoom    ('set', 0);
%            setPlaybackToolbar('off');

            multiFramePlayback('set', false);
            multiFrameRecord  ('set', false);
            multiFrameZoom    ('set', 'in' , 1);
            multiFrameZoom    ('set', 'out', 1);
            multiFrameZoom    ('set', 'axe', []);
            
            isPlotContours('set', false);

            clearDisplay();
            initDisplay(3);

            set(uiSeriesPtr('get'), 'Value' , 1);
            set(uiSeriesPtr('get'), 'String', ' ');

            set(uiFusedSeriesPtr('get'), 'Value' , 1    );
            set(uiFusedSeriesPtr('get'), 'String', ' '  );

            isVsplash('set', false);
            set(btnVsplashPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
            set(btnVsplashPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
    
            asMainDir = mainDir('get');

            registrationReport('set', '');

            dNewNbEntry = 1;
            for jj=1: numel(asMainDir)

                tNewDatasets = dicomInfoSortFolder(asMainDir{jj});

                if isfield(tNewDatasets, 'Contours')
                    inputContours('add', tNewDatasets.Contours{:});
                end

                if isfield(tNewDatasets, 'FileNames'   ) && ...
                   isfield(tNewDatasets, 'DicomInfos'  ) && ...
                   isfield(tNewDatasets, 'DicomBuffers')

                    atNewFrameInfo = dicomInfoComputeFrames(tNewDatasets.DicomInfos);

           %         sFileList = datasets.FileNames;
                    if strcmpi(tNewDatasets.DicomInfos{1}.SeriesType{1}, 'GATED'  ) || ...
                       strcmpi(tNewDatasets.DicomInfos{1}.SeriesType{1}, 'DYNAMIC') || ...
                       ~isempty(atNewFrameInfo)

                        if strcmpi(tNewDatasets.DicomInfos{1}.SeriesType{1}, 'GATED'  ) || ...
                           strcmpi(tNewDatasets.DicomInfos{1}.SeriesType{1}, 'DYNAMIC')
                       
                            dNewNbFrames    = numel(tNewDatasets.DicomInfos) / tNewDatasets.DicomInfos{1}.NumberOfSlices;
                            dNewNbOfSlices = tNewDatasets.DicomInfos{1}.NumberOfSlices;

                            for dNewFramesLoop=1:dNewNbFrames

                                dNewFrameOffset = dNewFramesLoop-1;
                                dNewFrom = 1+ (dNewFrameOffset * dNewNbOfSlices);
                                dNewTo   = dNewNbOfSlices * dNewFramesLoop;

                                asNewFilesList{dNewNbEntry}  = tNewDatasets.FileNames(dNewFrom:dNewTo);
                                atNewDicomInfo{dNewNbEntry}  = tNewDatasets.DicomInfos(dNewFrom:dNewTo);
                                aNewDicomBuffer{dNewNbEntry} = tNewDatasets.DicomBuffers(dNewFrom:dNewTo);

                                for dNewSeriesLoop = 1: numel(atNewDicomInfo{dNewNbEntry})
                                    atNewDicomInfo{dNewNbEntry}{dNewSeriesLoop}.SeriesDescription = ...
                                        sprintf('%s (Frame %d)', atNewDicomInfo{dNewNbEntry}{dNewSeriesLoop}.SeriesDescription, dNewFramesLoop);
                                    atNewDicomInfo{dNewNbEntry}{dNewSeriesLoop}.din.frame = dNewFramesLoop;
                                end

                                dNewNbEntry = dNewNbEntry+1;

                            end
                        else

                            for dNewFramesLoop=1:numel(atNewFrameInfo)

                                if dNewFramesLoop == 1
                                    dNewFrameOffset = dNewFramesLoop-1;
                                    dNewNbOfSlices  = atNewFrameInfo{dNewFramesLoop}.NbSlices;

                                    dNewFrom = 1+ (dNewFrameOffset * dNewNbOfSlices);
                                    dNewTo   = dNewNbOfSlices * dNewFramesLoop;
                                else
                                    dNewNbOfSlices  = atNewFrameInfo{dNewFramesLoop}.NbSlices;
                                    
                                    dNewFrom = 1+dLastTo;
                                    dNewTo   = dNewNbOfSlices + dLastTo;                                    
                                end

                                asNewFilesList{dNewNbEntry}  = tNewDatasets.FileNames(dNewFrom:dNewTo);
                                atNewDicomInfo{dNewNbEntry}  = tNewDatasets.DicomInfos(dNewFrom:dNewTo);
                                aNewDicomBuffer{dNewNbEntry} = tNewDatasets.DicomBuffers(dNewFrom:dNewTo);
                                for dNewSeriesLoop = 1: numel(atNewDicomInfo{dNewNbEntry})
                                    atNewDicomInfo{dNewNbEntry}{dNewSeriesLoop}.SeriesDescription = ...
                                        sprintf('%s (Frame %d)', atNewDicomInfo{dNewNbEntry}{dNewSeriesLoop}.SeriesDescription, dNewFramesLoop);
                                    atNewDicomInfo{dNewNbEntry}{dNewSeriesLoop}.din.frame = dNewFramesLoop;
                                end

                                dNewNbEntry = dNewNbEntry+1;                                
                                dLastTo   = dNewTo;
                           end

                        end
                    else
                                                
                        asNewFilesList{dNewNbEntry}  = tNewDatasets.FileNames;
                        atNewDicomInfo{dNewNbEntry}  = tNewDatasets.DicomInfos;
                        aNewDicomBuffer{dNewNbEntry} = tNewDatasets.DicomBuffers;

                        dNewNbEntry = dNewNbEntry+1;
                    end

                end
            end

            switchTo3DMode    ('set', false);
            switchToIsoSurface('set', false);
            switchToMIPMode   ('set', false);

            if exist('asNewFilesList' , 'var') && ...
               exist('atNewDicomInfo' , 'var') && ...
               exist('aNewDicomBuffer', 'var')

               rotate3d off

               set(btnFusionPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
               set(btnFusionPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));

               set(btn3DPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
               set(btn3DPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));

               set(btnIsoSurfacePtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
               set(btnIsoSurfacePtr('get'), 'ForegroundColor', viewerForegroundColor('get'));

               set(btnMIPPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
               set(btnMIPPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));

               set(btnTriangulatePtr('get'), 'BackgroundColor', viewerButtonPushedBackgroundColor('get'));
               set(btnTriangulatePtr('get'), 'ForegroundColor', viewerButtonPushedForegroundColor('get'));

               imageOrientation('set', 'axial');

               for ii=1: numel(asNewFilesList)
                    atNewInput(ii).asFilesList  = asNewFilesList{ii};
                    atNewInput(ii).atDicomInfo  = atNewDicomInfo{ii};
                    atNewInput(ii).aDicomBuffer = aNewDicomBuffer{ii};

                    atNewInput(ii).sOrientationView    = 'Axial';
                    
                    atNewInput(ii).bEdgeDetection      = false;
                    atNewInput(ii).bFlipLeftRight      = false;
                    atNewInput(ii).bFlipAntPost        = false;
                    atNewInput(ii).bFlipHeadFeet       = false;
                    atNewInput(ii).bDoseKernel         = false;
                    atNewInput(ii).bMathApplied        = false;
                    atNewInput(ii).bFusedDoseKernel    = false;
                    atNewInput(ii).bFusedEdgeDetection = false;
                    
                    atNewInput(ii).tMovement = [];
                    
                    atNewInput(ii).tMovement.bMovementApplied = false;
                    atNewInput(ii).tMovement.aGeomtform       = [];
                    
                    atNewInput(ii).tMovement.atSeq{1}.sAxe         = [];
                    atNewInput(ii).tMovement.atSeq{1}.aTranslation = [];
                    atNewInput(ii).tMovement.atSeq{1}.dRotation    = [];                   
                end

                inputTemplate('set', atNewInput);

                if numel(inputTemplate('get')) ~= 0

                    for ii = 1 : numel(inputTemplate('get'))

                        if isempty(atNewInput(ii).atDicomInfo{1}.SeriesDate)
                            sSeriesDate = '00010101';
                        else
                            sSeriesDate = atNewInput(ii).atDicomInfo{1}.SeriesDate;
                        end

                        if isempty(atNewInput(ii).atDicomInfo{1}.SeriesTime)
                            sSeriesTime = '000000';
                        else
                            sSeriesTime = atNewInput(ii).atDicomInfo{1}.SeriesTime;
                        end

                        sNewVolSeriesDate = sprintf('%s%s', sSeriesDate, sSeriesTime);

                        if contains(sNewVolSeriesDate,'.')
                            sNewVolSeriesDate = extractBefore(sNewVolSeriesDate,'.');
                        end
                        sNewVolSeriesDate = datetime(sNewVolSeriesDate,'InputFormat','yyyyMMddHHmmss');
                        sNewVolSeriesDescription = atNewInput(ii).atDicomInfo{1}.SeriesDescription;

                        sNewVolumes{ii} = sprintf('%s %s', sNewVolSeriesDescription, sNewVolSeriesDate);
                    end

                    seriesDescription('set', sNewVolumes);

                    set(uiSeriesPtr('get'), 'String', sNewVolumes);

                    if  numel(sNewVolumes) > 1
                        set(uiFusedSeriesPtr('get'), 'String', sNewVolumes);
                        set(uiFusedSeriesPtr('get'), 'Value', 2);
                    else
                        set(uiFusedSeriesPtr('get'), 'String', sNewVolumes);
                        set(uiFusedSeriesPtr('get'), 'Value', 1);
                   end

                end

                setInputOrientation();

                setDisplayBuffer();

                setQuantification();

                clearDisplay();
                initDisplay(3);

%                link2DMip('set', true);

%                set(btnLinkMipPtr('get'), 'BackgroundColor', viewerButtonPushedBackgroundColor('get'));
%                set(btnLinkMipPtr('get'), 'ForegroundColor', viewerButtonPushedForegroundColor('get')); 
                    
                dicomViewerCore();

                setContours();

                setViewerDefaultColor(true, dicomMetaData('get'));
                
                refreshImages();
               
%                atMetaData = dicomMetaData('get');

%                if strcmpi(atMetaData{1}.Modality, 'ct')
%                    link2DMip('set', false);

%                    set(btnLinkMipPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
%                    set(btnLinkMipPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));       
%                end    

        
                if size(dicomBuffer('get'), 3) ~= 1
                    setPlaybackToolbar('on');
                end

                setRoiToolbar('on'); 
                
                % Reactivate main tool bar 
                set(uiSeriesPtr('get'), 'Enable', 'on');                        
                mainToolBarEnable('on');    
            else
                progressBar(1 , 'Error: TriDFusion: no volumes detected!');
                h = msgbox('Error: TriDFusion: no volumes detected!', 'Error');
%                if integrateToBrowser('get') == true
%                    sLogo = './TriDFusion/logo.png';
%                else
%                    sLogo = './logo.png';
%                end
%                javaFrame = get(h, 'JavaFrame');
%                javaFrame.setFigureIcon(javax.swing.ImageIcon(sLogo));
                set(fiMainWindowPtr('get'), 'Pointer', 'default');
                drawnow;
                return;
            end

            set(fiMainWindowPtr('get'), 'Pointer', 'default');
            drawnow;
        end
    end
end
