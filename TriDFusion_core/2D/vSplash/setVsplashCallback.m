function setVsplashCallback(~, ~)
%function setVsplashCallback(~, ~)
%Set 2D vSplash.
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

    im = dicomBuffer('get');

    if isempty(im)
        return;
    end
    
    % Deactivate main tool bar 
    set(uiSeriesPtr('get'), 'Enable', 'off');                        
    mainToolBarEnable('off');   
    
%    try
        
    releaseRoiWait();

    set(btnTriangulatePtr('get'), 'BackgroundColor', viewerButtonPushedBackgroundColor('get'));
    set(btnTriangulatePtr('get'), 'ForegroundColor', viewerButtonPushedForegroundColor('get'));
    set(btnTriangulatePtr('get'), 'FontWeight', 'bold');

    set(zoomMenu('get'), 'Checked', 'off');
    set(btnZoomPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
    set(btnZoomPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
    set(btnZoomPtr('get'), 'FontWeight', 'normal');
    zoomTool('set', false);
    zoom('off');           

    set(panMenu('get'), 'Checked', 'off');
    set(btnPanPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
    set(btnPanPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));          
    set(btnPanPtr('get'), 'FontWeight', 'normal');
    panTool('set', false);
    pan('off');     

    set(rotate3DMenu('get'), 'Checked', 'off');         
    rotate3DTool('set', false);
    rotate3d off;

    set(dataCursorMenu('get'), 'Checked', 'off');
    dataCursorTool('set', false);              
    datacursormode('off'); 
    
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

    if isVsplash('get') == false

        releaseRoiWait();

        isVsplash('set', true);

        set(btnVsplashPtr('get'), 'BackgroundColor', viewerButtonPushedBackgroundColor('get'));
        set(btnVsplashPtr('get'), 'ForegroundColor', viewerButtonPushedForegroundColor('get'));
        set(btnVsplashPtr('get'), 'FontWeight', 'bold');
        
        if isPlotContours('get') == true % Deactivate plot contour
            setPlotContoursCallback();            
        end

        clearDisplay();
        initDisplay(3);

        dicomViewerCore();

%        if isFusion('get') == false
%            set(btnFusionPtr ('get')   , 'Enable', 'off');
%            set(btnLinkMipPtr('get')   , 'Enable', 'off');
%            set(uiFusedSeriesPtr('get'), 'Enable', 'off');
%        end


    else
        isVsplash('set', false);

        set(btnVsplashPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
        set(btnVsplashPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));
        set(btnVsplashPtr('get'), 'FontWeight', 'normal');
        
%        isPlotContours('set', false);

        clearDisplay();
        initDisplay(3);

%        link2DMip('set', true);

%        set(btnLinkMipPtr('get'), 'BackgroundColor', viewerButtonPushedBackgroundColor('get'));
%        set(btnLinkMipPtr('get'), 'ForegroundColor', viewerButtonPushedForegroundColor('get')); 
                
        dicomViewerCore();

%        set(btnFusionPtr('get')    , 'Enable', 'on');
%        set(btnLinkMipPtr('get')   , 'Enable', 'on');
%        set(uiFusedSeriesPtr('get'), 'Enable', 'on');
    end

    % restore position
    set(uiSliderCorPtr('get'), 'Value', iCoronal / iCoronalSize);
    sliceNumber('set', 'coronal', iCoronal);

    set(uiSliderSagPtr('get'), 'Value', iSagittal / iSagittalSize);
    sliceNumber('set', 'sagittal', iSagittal);

    set(uiSliderTraPtr('get'), 'Value', 1 - (iAxial / iAxialSize));
    sliceNumber('set', 'axial', iAxial);

    refreshImages();
    
%    catch
%        progressBar(1, 'Error:setVsplashCallback()');                        
%    end
    
    % Reactivate main tool bar 
    set(uiSeriesPtr('get'), 'Enable', 'on');                        
    mainToolBarEnable('on');   
    
%    if isVsplash('get') == false
        
%        atMetaData = dicomMetaData('get');

%        if strcmpi(atMetaData{1}.Modality, 'ct')
%            link2DMip('set', false);

%            set(btnLinkMipPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
%            set(btnLinkMipPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));         
%        end         
%    end
    
end
