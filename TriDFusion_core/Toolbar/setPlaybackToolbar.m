function setPlaybackToolbar(sVisible)
%function setPlaybackToolbar(sVisible)
%Init and View ON/OFF Playback Toolbar.
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

    tbPlayback = playbackMenuObject('get');

    mViewPlayback = viewPlaybackObject('get');
    if strcmp(sVisible, 'off')
        mViewPlayback.Checked = 'off';
        playback3DToolbar('set', false);
    else
        mViewPlayback.Checked = 'on';
        playback3DToolbar('set', true);
    end

    if isempty(tbPlayback)

        sRootPath  = viewerRootPath('get');
        sIconsPath = sprintf('%s/icons/', sRootPath);

        tbPlayback = uitoolbar(fiMainWindowPtr('get'));
        playbackMenuObject('set', tbPlayback);

        if strcmp(sVisible, 'off')
            tbPlayback.Visible = 'off';
        else
            tbPlayback.Visible = 'on';
        end

        [img,~] = imread(sprintf('%s//backward.png', sIconsPath));
        img = double(img)/255;

        mBackward = uitoggletool(tbPlayback,'CData',img,'TooltipString','Backward');
        mBackward.ClickedCallback = @playbackCallback;

        [img,~] = imread(sprintf('%s//play.png', sIconsPath));
        img = double(img)/255;

        mPlay = uitoggletool(tbPlayback,'CData',img,'TooltipString','Play');
        mPlay.ClickedCallback = @playbackCallback;

        playIconMenuObject('set', mPlay);

        [img,~] = imread(sprintf('%s//foward.png', sIconsPath));
        img = double(img)/255;

        mFoward = uitoggletool(tbPlayback,'CData',img,'TooltipString','Foward');
        mFoward.ClickedCallback = @playbackCallback;

        [img,~] = imread(sprintf('%s//record.png', sIconsPath));
        img = double(img)/255;

        mRecord = uitoggletool(tbPlayback,'CData',img,'TooltipString','Record');
        mRecord.ClickedCallback = @playbackCallback;

        recordIconMenuObject('set', mRecord);

        % ---- %

        [img,~] = imread(sprintf('%s//arrow-down.png', sIconsPath));
        img = double(img)/255;

        mSpeedDown = uitoggletool(tbPlayback,'CData',img,'TooltipString','Speed Down', 'Separator', 'on');
        mSpeedDown.ClickedCallback = @playbackCallback;

         [img,~] = imread(sprintf('%s//arrow-up.png', sIconsPath));
       img = double(img)/255;

        mSpeedUp = uitoggletool(tbPlayback,'CData',img,'TooltipString','Speed Up');
        mSpeedUp.ClickedCallback = @playbackCallback;

        % ---- %
        [img,~] = imread(sprintf('%s//zoom-out.png', sIconsPath));
        img = double(img)/255;

        mZoomOut = uitoggletool(tbPlayback,'CData',img,'TooltipString','Zoom Out', 'Separator', 'on');
        mZoomOut.ClickedCallback = @playbackCallback;

        [img,~] = imread(sprintf('%s//zoom-in.png', sIconsPath));
        img = double(img)/255;

        mZoomIn = uitoggletool(tbPlayback,'CData',img,'TooltipString','Zoom In');
        mZoomIn.ClickedCallback = @playbackCallback;

        [img,~] = imread(sprintf('%s//gate.png', sIconsPath));
        img = double(img)/255;

        mGate = uitoggletool(tbPlayback,'CData',img,'TooltipString','Gate', 'Separator', 'on');
        mGate.ClickedCallback = @playbackCallback;
        gateIconMenuObject('set', mGate);

    else
        if strcmp(sVisible, 'off')
            tbPlayback.Visible = 'off';
        else
            tbPlayback.Visible = 'on';
        end
    end

    function playbackCallback(hObject, ~)

        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true

            switch  hObject.TooltipString

                case 'Play'

                    if  multiFrame3DRecord('get') == false
                        if multiFrame3DPlayback('get') == false

                            mPlay.State = 'on';
                            multiFrame3DPlayback('set', true);

                            if strcmpi(get(mGate, 'State'), 'on')
%                                set(uiSeriesPtr('get'), 'Enable', 'off');
                                multiGate3D(mPlay);
                            else
                                multiFrame3D(mPlay);
                            end
                        else
%                            set(uiSeriesPtr('get'), 'Enable', 'on');
                            mPlay.State = 'off';
                            multiFrame3DPlayback('set', false);
                        end
                    end


                 case 'Foward'

                     if multiFrame3DPlayback('get') == false && ...
                        multiFrame3DRecord('get')   == false
                         
                         if strcmpi(get(mGate, 'State'), 'on')

                            set(mFoward, 'Enable', 'off');
                            oneGate3D(hObject.TooltipString);
                            set(mFoward, 'Enable', 'on');

                         else
                             if multiFrame3DIndex('get') == 120
                                multiFrame3DIndex('set', 1);
                             else
                                multiFrame3DIndex('set', multiFrame3DIndex('get')+1);
                             end

                             set(mFoward, 'Enable', 'off');
                             oneFrame3D();
                             set(mFoward, 'Enable', 'on');
                        end
                      end

                      set(mFoward, 'State', 'off');

                 case 'Backward'

                     if multiFrame3DPlayback('get') == false && ...
                        multiFrame3DRecord('get')   == false
                        if strcmpi(get(mGate, 'State'), 'on')

                            set(mBackward, 'Enable', 'off');
                            oneGate3D(hObject.TooltipString);
                            set(mBackward, 'Enable', 'on');
                       else
                            if multiFrame3DIndex('get') == 1
                               multiFrame3DIndex('set', 120);
                            else
                               multiFrame3DIndex('set', multiFrame3DIndex('get')-1);
                            end

                            set(mBackward, 'Enable', 'off');
                            oneFrame3D();
                            set(mBackward, 'Enable', 'on');
                        end
                     end

                     set(mBackward, 'State', 'off');

                 case 'Record'

                    if multiFrame3DPlayback('get') == false

                        if multiFrame3DRecord('get') == false

                            filter = {'*.avi';'*.mp4';'*.gif';'*.dcm';'*.jpg';'*.bmp';'*.png'};
                            info = dicomMetaData('get');

                            sCurrentDir  = viewerRootPath('get');

                            sMatFile = [sCurrentDir '/' 'lastGifDir.mat'];
                            % load last data directory
                            if exist(sMatFile, 'file')

                                load('-mat', sMatFile);
                                if exist('animatedGifLastUsedDir', 'var')
                                   sCurrentDir = animatedGifLastUsedDir;
                                end
                                if sCurrentDir == 0
                                    sCurrentDir = pwd;
                                end
                            end

                            [file, path, indx] = uiputfile(filter, 'Save Images', sprintf('%s/%s_%s_%s_3D_Playback_TriDFusion' , sCurrentDir, cleanString(info{1}.PatientName), cleanString(info{1}.PatientID), cleanString(info{1}.SeriesDescription)) );

                            if file ~= 0

                                set(mRecord, 'State', 'on');
                                multiFrame3DRecord('set', true);

                                if strcmpi(get(mGate, 'State'), 'on')

%                                    set(uiSeriesPtr('get'), 'Enable', 'off');
                                    recordMultiGate3D(mRecord, path, file, filter{indx});
                                else
                                    recordMultiFrame3D(mRecord, path, file, filter{indx});
                                end

%                                set(uiSeriesPtr('get'), 'Enable', 'on');
                                set(mRecord, 'State', 'off');
                                multiFrame3DRecord('set', false);

                                try
                                    animatedGifLastUsedDir = [path '/'];
                                    save(sMatFile, 'animatedGifLastUsedDir');
                                catch
                                    progressBar(1 , sprintf('Warning: Cant save file %s', sMatFile));
%                                    h = msgbox(sprintf('Warning: Cant save file %s', sMatFile), 'Warning');
%                                    if integrateToBrowser('get') == true
%                                        sLogo = './TriDFusion/logo.png';
%                                    else
%                                        sLogo = './logo.png';
%                                    end

%                                    javaFrame = get(h, 'JavaFrame');
%                                    javaFrame.setFigureIcon(javax.swing.ImageIcon(sLogo));
                                end
                            else
                                set(mRecord, 'State', 'off');
                            end
                        else
                            set(mRecord, 'State', 'off');
                            multiFrame3DRecord('set', false);
                        end
                    end

                case 'Speed Down'
                    set(mSpeedDown, 'State', 'off');

                    if multiFrame3DSpeed('get') < 2
                        multiFrame3DSpeed('set', multiFrame3DSpeed('get')+0.01);
                    end

                case 'Speed Up'
                    set(mSpeedUp, 'State', 'off');
                    if multiFrame3DSpeed('get') > 0.01
                        multiFrame3DSpeed('set', multiFrame3DSpeed('get')-0.01);
                    end

                case 'Zoom In'
                    set(mZoomIn, 'State', 'off');
                    multiFrame3DZoom('set', multiFrame3DZoom('get')/1.2);

                    if multiFrame3DZoom('get') > 1.2
                        multiFrame3DZoom('set', multiFrame3DZoom('get')/1.2);
                    end

                    if multiFrame3DPlayback('get') == false && ...
                        multiFrame3DRecord('get')  == false
                        set(mZoomIn, 'Enable', 'off');
                        zoom3D('in', 1.2);
                        set(mZoomIn, 'Enable', 'on');
                    end

                    initGate3DObject('set', true);

                case 'Zoom Out'
                    set(mZoomOut, 'State', 'off');
                    multiFrame3DZoom('set', multiFrame3DZoom('get')*1.2);

                     if multiFrame3DPlayback('get') == false && ...
                        multiFrame3DRecord('get')   == false
                        set(mZoomOut, 'Enable', 'off');
                        zoom3D('out', 1.2);
                        set(mZoomOut, 'Enable', 'on');
                     end

                     initGate3DObject('set', true);

                case 'Gate'

                    mPlay.State = 'off';
                    multiFrame3DPlayback('set', false);

            end
        else
            switch  hObject.TooltipString

                case 'Play'

                    if  multiFrameRecord('get') == false

                        if multiFramePlayback('get') == false

                            mPlay.State = 'on';
                            multiFramePlayback('set', true);

                            if strcmpi(get(mGate, 'State'), 'on')

                                set(uiSeriesPtr('get'), 'Enable', 'off');
                                multiGate(mPlay, gca(fiMainWindowPtr('get')));
                            else
                                if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 4) ~= 1
                                    multiFrameScreenCapture(mPlay);
                                else
                                    multiFrame(mPlay, gca(fiMainWindowPtr('get')));
                                end

                            end
                        else
                            set(uiSeriesPtr('get'), 'Enable', 'on');
                            mPlay.State = 'off';
                            multiFramePlayback('set', false);   
                        end
                    end

                 case 'Foward'

                     set(mFoward, 'State', 'off');

                     if multiFramePlayback('get') == false && ...
                        multiFrameRecord('get')   == false

                        set(mFoward, 'Enable', 'off');

                        if strcmpi(get(mGate, 'State'), 'on')

                            if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 3) ~= 1

                                oneGate(hObject.TooltipString);
                            end
                               
                        else
                            if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 4) ~= 1
                                screenCaptureFrame('Next');
                            else
                                if size(dicomBuffer('get', [], get(uiSeriesPtr('get'))), 3) ~=1
                                    oneFrame(hObject.TooltipString);
                                end
                            end
                        end

                        set(mFoward, 'Enable', 'on');
                     end           


                 case 'Backward'

                     set(mBackward, 'State', 'off');

                         if multiFrame3DPlayback('get') == false && ...
                            multiFrame3DRecord('get')   == false

                            set(mBackward, 'Enable', 'off');

                            if strcmpi(get(mGate, 'State'), 'on')
                               
                                if size(dicomBuffer('get', [], get(uiSeriesPtr('get'))), 3) ~=1

                                    oneGate(hObject.TooltipString);
                                end
                            else
                                if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 4) ~= 1
                                    screenCaptureFrame('Previous');
                                else
                                    if size(dicomBuffer('get', [], get(uiSeriesPtr('get'))), 3) ~=1
                                        oneFrame(hObject.TooltipString);
                                    end
                                end
                            end

                            set(mBackward, 'Enable', 'on');
                         end                     

                 case 'Record'

                    if multiFramePlayback('get') == false

                        if multiFrameRecord('get') == false

                            filter = {'*.avi';'*.mp4';'*.gif';'*.dcm';'*.jpg';'*.bmp';'*.png'};
                            info = dicomMetaData('get');

                            sCurrentDir  = viewerRootPath('get');

                            sMatFile = [sCurrentDir '/' 'lastGifDir.mat'];
                            % load last data directory
                            if exist(sMatFile, 'file')

                                load(sMatFile, 'animatedGifLastUsedDir');
                                if exist('animatedGifLastUsedDir', 'var')

                                   sCurrentDir = animatedGifLastUsedDir;
                                end
                                
                                if sCurrentDir == 0
                                    sCurrentDir = pwd;
                                end
                            end

                            [file, path, indx] = uiputfile(filter, 'Save Images', sprintf('%s/%s_%s_%s_2D_Playback_TriDFusion' , sCurrentDir, cleanString(info{1}.PatientName), cleanString(info{1}.PatientID), cleanString(info{1}.SeriesDescription)) );

                            if file ~= 0

                                set(mRecord, 'State', 'on');
                                multiFrameRecord('set', true);

                                if strcmpi(get(mGate, 'State'), 'on')
                                    set(uiSeriesPtr('get'), 'Enable', 'off');
                                    recordMultiGate(mRecord, path, file, filter{indx}, gca(fiMainWindowPtr('get')));
                                else
                                    recordMultiFrame(mRecord, path, file, filter{indx}, gca(fiMainWindowPtr('get')));
                                end

                                set(uiSeriesPtr('get'), 'Enable', 'on');
                                set(mRecord, 'State', 'off');
                                multiFrameRecord('set', false);

                                try
                                    animatedGifLastUsedDir = [path '/'];
                                    save(sMatFile, 'animatedGifLastUsedDir');
                                catch
                                    progressBar(1 , sprintf('Warning: Cant save file %s', sMatFile));
%                                    h = msgbox(sprintf('Warning: Cant save file %s', sMatFile), 'Warning');
%                                    if integrateToBrowser('get') == true
%                                        sLogo = './TriDFusion/logo.png';
%                                    else
%                                        sLogo = './logo.png';
%                                    end

%                                    javaFrame = get(h, 'JavaFrame');
%                                    javaFrame.setFigureIcon(javax.swing.ImageIcon(sLogo));
                                end
                            else
                                set(mRecord, 'State', 'off');
                            end
                        else
                            set(mRecord, 'State', 'off');
                            multiFrameRecord('set', false);
                        end
                    end

                case 'Speed Down'
                    
                    set(mSpeedDown, 'State', 'off');

                    if multiFrameSpeed('get') < 2
                        multiFrameSpeed('set', multiFrameSpeed('get')+0.01);
                    end

                case 'Speed Up'

                    set(mSpeedUp, 'State', 'off');

                    if size(dicomBuffer('get'), 3) ~=1

                        if multiFrameSpeed('get') > 0.01
                            multiFrameSpeed('set', multiFrameSpeed('get')-0.01);
                        end
                    end

                case 'Zoom In'
                    
                    set(mZoomIn, 'State', 'off');

                    if size(dicomBuffer('get'), 3) ~=1

                        set(mZoomIn, 'Enable', 'off');

                        multiFrameZoom('set', 'out', 1);

                        if multiFrameZoom('get', 'axe') ~= gca(fiMainWindowPtr('get'))
                            multiFrameZoom('set', 'in', 1);
                        end

                        dZFactor = multiFrameZoom('get', 'in');
                        dZFactor = dZFactor+0.025;
                        multiFrameZoom('set', 'in', dZFactor);

                        switch gca(fiMainWindowPtr('get'))
                            case axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
                                zoom(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), dZFactor);
                                multiFrameZoom('set', 'axe', axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')));

                            case axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
                                zoom(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), dZFactor);
                                multiFrameZoom('set', 'axe', axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')));
                                
                            case axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
                                zoom(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), dZFactor);
                                multiFrameZoom('set', 'axe', axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')));
                                
                            case axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value'))
                                zoom(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), dZFactor);
                                multiFrameZoom('set', 'axe', axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')));
                                
                            otherwise
                                zoom(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), dZFactor);
                                multiFrameZoom('set', 'axe', axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')));
                        end

                        set(mZoomIn, 'Enable', 'on');

                    end

                case 'Zoom Out'
                    set(mZoomOut, 'State', 'off');

                    if size(dicomBuffer('get'), 3) ~=1

                        set(mZoomOut, 'Enable', 'off');

                        multiFrameZoom('set', 'in', 1);

                        if multiFrameZoom('get', 'axe') ~= gca(fiMainWindowPtr('get'))
                            multiFrameZoom('set', 'out', 1);
                        end

                        dZFactor = multiFrameZoom('get', 'out');
                        if dZFactor > 0.025
                            dZFactor = dZFactor-0.025;
                            multiFrameZoom('set', 'out', dZFactor);
                        end

                        switch gca(fiMainWindowPtr('get'))
                            case axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
                                zoom(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), dZFactor);
                                multiFrameZoom('set', 'axe', axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')));

                            case axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
                                zoom(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), dZFactor);
                                multiFrameZoom('set', 'axe', axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')));
                                
                            case axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value'))
                                zoom(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), dZFactor);
                                multiFrameZoom('set', 'axe', axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')));
                                
                            case axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value'))
                                zoom(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), dZFactor);
                                multiFrameZoom('set', 'axe', axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')));
                                
                            otherwise
                                zoom(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), dZFactor);
                                multiFrameZoom('set', 'axe', axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')));
                        end

                        set(mZoomOut, 'Enable', 'on');

                    end

                case 'Gate'

                    mPlay.State = 'off';
                    multiFramePlayback('set', false);

             end

 %           set(mPlay     , 'State', 'off');
 %           set(mFoward   , 'State', 'off');
 %           set(mBackward , 'State', 'off');
 %           set(mRecord   , 'State', 'off');
 %           set(mSpeedDown, 'State', 'off');
 %           set(mSpeedUp  , 'State', 'off');
 %           set(mZoomIn   , 'State', 'off');
 %           set(mZoomOut  , 'State', 'off');
        end

    end
end
