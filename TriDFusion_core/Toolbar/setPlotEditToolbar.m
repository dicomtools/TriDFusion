function setPlotEditToolbar(sVisible)
%function setPlotEditToolbar(sVisible)
%Init and View ON/OFF plot edit Toolbar.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2025, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    uiTopToolbar = uiTopToolbarPtr('get');
    if isempty(uiTopToolbar)
        return;
    end
    
    mViewPlotEdit = viewPlotEditObject('get');

    if strcmp(sVisible, 'off')
        mViewPlotEdit.Checked = 'off';
        plotEditToolbar('set', false);
    else
        mViewPlotEdit.Checked = 'on';
        plotEditToolbar('set', true);
    end

    acPlotEditMenu = plotEditMenuObject('get');
    if isempty(acPlotEditMenu)

        sRootPath  = viewerRootPath('get');
        sIconsPath = sprintf('%s/icons/', sRootPath);
    
        % paint-bucket
        mColor = addToolbarIcon(uiTopToolbar, ...
            fullfile(sIconsPath,'paint-bucket_grey.png'), ...
            fullfile(sIconsPath,'paint-bucket_light_grey.png'), ...
            fullfile(sIconsPath,'paint-bucket_white.png'), ...
            'Color', ...
            'Change plot color', ...
            @plotEditColorCallback, ...
            'Separator', true, ... 
            'SeparatorWidth', 2);
        acPlotEditMenu{1} = mColor;
    
    
        mTextBold = addToolbarIcon(uiTopToolbar, ...
            fullfile(sIconsPath,'bold_grey.png'), ...
            fullfile(sIconsPath,'bold_light_grey.png'), ...
            fullfile(sIconsPath,'bold_white.png'), ...
            'Bold', ...
            'Text Bold', ...
            @plotEditBoldCallback);
        acPlotEditMenu{2} = mTextBold;
 
        if strcmpi(plotEditFontWeight('get'), 'Bold')
            
            set(mTextBold, 'CData', mTextBold.UserData.pressed);
        end
    
        mTextItalic = addToolbarIcon(uiTopToolbar, ...
            fullfile(sIconsPath,'italic_grey.png'), ...
            fullfile(sIconsPath,'italic_light_grey.png'), ...
            fullfile(sIconsPath,'italic_white.png'), ...
            'Italic', ...
            'Text Italic', ...
            @plotEditItalicCallback);
        acPlotEditMenu{3} = mTextItalic;
    
        if strcmpi(plotEditFontAngle('get'), 'Italic')
            
            set(mTextItalic, 'CData', mTextItalic.UserData.pressed);
        end
    
        % Text Font
        mTextFont = addToolbarIcon(uiTopToolbar, ...
            fullfile(sIconsPath,'font_grey.png'), ...
            fullfile(sIconsPath,'font_light_grey.png'), ...
            fullfile(sIconsPath,'font_white.png'), ...
            'Font', ...
            'Text Font', ...
            @plotEditFontCallback);
        acPlotEditMenu{4} = mTextFont; 

        % Single Arrow
        mSingleArrow = addToolbarIcon(uiTopToolbar, ...
            fullfile(sIconsPath,'insert-single-arrow_grey.png'), ...
            fullfile(sIconsPath,'insert-single-arrow_light_grey.png'), ...
            fullfile(sIconsPath,'insert-single-arrow_green.png'), ...
            'Single-Arrow', ...
            'Insert Single Arrow', ...
            @plotEditInsertSingleArrowCallback);
        acPlotEditMenu{5} = mSingleArrow;
    
        % Text Single Arrow
        mTextSingleArrow = addToolbarIcon(uiTopToolbar, ...
            fullfile(sIconsPath,'insert-text-single-arrow_grey.png'), ...
            fullfile(sIconsPath,'insert-text-single-arrow_light_grey.png'), ...
            fullfile(sIconsPath,'insert-text-single-arrow_white.png'), ...
            'Text-Single-Arrow', ...
            'Insert Text Single Arrow', ...
            @plotEditInsertTextSingleArrowCallback);
        acPlotEditMenu{6} = mTextSingleArrow;
    
        % Double Arrow
        mDoubleArrow = addToolbarIcon(uiTopToolbar, ...
            fullfile(sIconsPath,'insert-double-arrow_grey.png'), ...
            fullfile(sIconsPath,'insert-double-arrow_light_grey.png'), ...
            fullfile(sIconsPath,'insert-double-arrow_green.png'), ...
            'Double-Arrow', ...
            'Insert Double Arrow', ...
            @plotEditInsertDoubleArrowCallback);
        acPlotEditMenu{7} = mDoubleArrow;
    
        % Text Double Arrow
        mTextDoubleArrow = addToolbarIcon(uiTopToolbar, ...
            fullfile(sIconsPath,'insert-text-double-arrow_grey.png'), ...
            fullfile(sIconsPath,'insert-text-double-arrow_light_grey.png'), ...
            fullfile(sIconsPath,'insert-text-double-arrow_white.png'), ...
            'Text-Double-Arrow', ...
            'Insert Text Double Arrow', ...
            @plotEditInsertTextDoubleArrowCallback);
        acPlotEditMenu{8} = mTextDoubleArrow;
    
        % Text 
        mText = addToolbarIcon(uiTopToolbar, ...
            fullfile(sIconsPath,'insert-text_grey.png'), ...
            fullfile(sIconsPath,'insert-text_light_grey.png'), ...
            fullfile(sIconsPath,'insert-text_green.png'), ...
            'Text', ...
            'Insert Text', ...
            @plotEditInsertTextCallback);
        acPlotEditMenu{9} = mText;

        plotEditMenuObject('set', acPlotEditMenu);
    else

        panelH = uiTopToolbarPtr('get');
 
        bExit = false;
        for i = 1:numel(acPlotEditMenu)
            hBtn = acPlotEditMenu{i};
            if ishghandle(hBtn)
                if strcmpi(get(hBtn, 'Visible'), sVisible)
                    bExit = true;
                    break;
                end
            end
        end

        if bExit == true
            return;
        end

        setToolbarObjectVisibility(panelH, acPlotEditMenu, sVisible);

    end
    
    function plotEditColorCallback(~, ~)

        aColor = uisetcolor([plotEditColor('get')],'Select a color');
        if isequal(aColor,0)
            return;
        end     

        plotEditColor('set', aColor);
        
        panelH = uiTopToolbarPtr('get');
        bg  = reshape(get(panelH,'BackgroundColor'),1,1,3);

        bgCol = squeeze(bg(1,1,:))';    % [0.2 0.2 0.2]
        
        allHandles = { ...
            mColor, ...
            mSingleArrow, ...
            mTextSingleArrow, ...
            mDoubleArrow, ...
            mTextDoubleArrow, ...
            mText       ...  
        };
        
        for k = 1:numel(allHandles)
            h = allHandles{k};
            origImg = h.UserData.hover_orig;  
            h.UserData.hover = recolorIcon(origImg, bgCol, aColor);
        end

        for k = 1:numel(allHandles)
            h = allHandles{k};
            origImg = h.UserData.pressed_orig;  
            h.UserData.pressed = recolorIcon(origImg, bgCol, aColor);
        end

        set(mColor, 'CData', mColor.UserData.default);
        
    end

    function plotEditBoldCallback(~, ~)

        if isequal(mTextBold.CData, mTextBold.UserData.pressed)

            plotEditFontWeight('set', 'Normal');
            set(mTextBold, 'CData', mTextBold.UserData.default);
        else
            plotEditFontWeight('set', 'Bold');
            set(mTextBold, 'CData', mTextBold.UserData.pressed);
        end

    end

    function plotEditItalicCallback(~, ~)

        if isequal(mTextItalic.CData, mTextItalic.UserData.pressed)
            
            plotEditFontWeight('set', 'Normal');
            set(mTextItalic, 'CData', mTextItalic.UserData.default);
        else
            plotEditFontWeight('set', 'Bold');
            set(mTextItalic, 'CData', mTextItalic.UserData.pressed);
        end      
    end

    function plotEditFontCallback(~, ~)

        set(mTextFont, 'CData', mTextFont.UserData.pressed);

        optsout = uisetfont(struct('FontName'  , plotEditFontName('get'), ...
                                   'FontSize'  , plotEditFontSize('get'), ...
                                   'FontAngle' , plotEditFontAngle('get'), ...
                                   'FontWeight', plotEditFontWeight('get')), ...            
                                   'Select a font');
                                 
        if ~isstruct(optsout)  % Cancelled
            return;
        end   

        plotEditFontName  ('set', optsout.FontName);
        plotEditFontSize  ('set', optsout.FontSize);
        plotEditFontAngle ('set', optsout.FontAngle);
        plotEditFontWeight('set', optsout.FontWeight);

        set(mTextFont, 'CData', mTextFont.UserData.default);
      
        if strcmpi(optsout.FontWeight, 'Bold')
            set(mTextBold, 'CData', mTextBold.UserData.pressed);
        else
            set(mTextBold, 'CData', mTextBold.UserData.default);
        end
        
        if strcmpi(optsout.FontAngle, 'Italic')
            set(mTextItalic, 'CData', mTextItalic.UserData.pressed);
        else
            set(mTextItalic, 'CData', mTextItalic.UserData.default);
        end
    end

    function plotEditInsertSingleArrowCallback(~, ~)
        
        if exitCondition() 
            return;
        end

        if ~isequal(mText.CData, mText.UserData.default)

            interactiveText(); % Delete the current instance       
            set(mText.CData, mText.UserData.default);
        end

        toggles = { mDoubleArrow, mTextSingleArrow, mTextDoubleArrow };
        
        for k = 1:numel(toggles)
            h = toggles{k};
            if ~isequal(h.CData, h.UserData.default)

                interactiveArrow();    % delete the current arrow
                set(h.CData, h.UserData.default);
            end
        end

        set(mSingleArrow, 'CData', mSingleArrow.UserData.pressed);

        interactiveArrow('showText', false, 'doubleArrow', false);
    end

    function plotEditInsertTextSingleArrowCallback(~, ~)

        if exitCondition()
            return;
        end

        if ~isequal(mText.CData, mText.UserData.default)

            interactiveText(); % Delete the current instance       
            set(mText.CData, mText.UserData.default);
        end

        toggles = { mSingleArrow, mDoubleArrow, mTextDoubleArrow };
        
        for k = 1:numel(toggles)
            h = toggles{k};
            if ~isequal(h.CData, h.UserData.default)

                interactiveArrow();    % delete the current arrow
                set(h.CData, h.UserData.default);
            end
        end

        set(mTextSingleArrow, 'CData', mTextSingleArrow.UserData.pressed);

        interactiveArrow('showText', true, 'doubleArrow', false);
    end

    function plotEditInsertDoubleArrowCallback(~, ~)

        if exitCondition()
            return;
        end

        if ~isequal(mText.CData, mText.UserData.default)

            interactiveText(); % Delete the current instance       
            set(mText.CData, mText.UserData.default);
        end

        toggles = { mSingleArrow, mTextSingleArrow, mTextDoubleArrow };
        
        for k = 1:numel(toggles)
            h = toggles{k};
            if ~isequal(h.CData, h.UserData.default)

                interactiveArrow();    % delete the current arrow
                set(h.CData, h.UserData.default);
            end
        end

        set(mDoubleArrow, 'CData', mDoubleArrow.UserData.pressed);

        interactiveArrow('showText', false, 'doubleArrow', true);

    end

    function plotEditInsertTextDoubleArrowCallback(~, ~)

        if exitCondition()            
            return;
        end

        if ~isequal(mText.CData, mText.UserData.default)

            interactiveText(); % Delete the current instance       
            set(mText.CData, mText.UserData.default);
        end

        toggles = { mSingleArrow, mTextSingleArrow, mDoubleArrow };
        
        for k = 1:numel(toggles)
            h = toggles{k};
            if ~isequal(h.CData, h.UserData.default)

                interactiveArrow();    % delete the current arrow
                set(h.CData, h.UserData.default);
            end
        end

        set(mTextDoubleArrow, 'CData', mTextDoubleArrow.UserData.pressed);

        interactiveArrow('showText', true, 'doubleArrow', true);
    end

    function plotEditInsertTextCallback(~, ~)

        if exitCondition()
            return;
        end

        toggles = { mSingleArrow, mDoubleArrow, mTextSingleArrow, mTextDoubleArrow };
        
        for k = 1:numel(toggles)

            h = toggles{k};
            
            if ~isequal(h.CData, h.UserData.default)

                interactiveArrow(); % delete current arrow thread 
                
            end
        end

        set(mText, 'CData', mText.UserData.pressed);
        
        interactiveText();    

    end

    function dExit = exitCondition()

        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true || ...
           isVsplash('get')          == true 

            dExit = true;
        else
            dExit = false;            
        end
    end


    function newImg = recolorIcon(origImg, bgCol, aColor)

        G = origImg(:,:,2);
        mask = G>bgCol(2) & G>origImg(:,:,1) & G>origImg(:,:,3);
        maxG = max(G(mask));
        alpha = (G - bgCol(2)) / (maxG - bgCol(2));
        alpha(~mask) = 0;
        newImg = origImg;
        delta = aColor - bgCol;
        for c = 1:3
            ch = origImg(:,:,c);
            ch(mask) = bgCol(c) + alpha(mask)*delta(c);
            newImg(:,:,c) = ch;
        end
    end

end