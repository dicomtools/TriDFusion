function setShowTextContoursCallback(~, ~) 
%function setShowTextContoursCallback()
%Show\Hide image contours text.
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
    
    if size(dicomBuffer('get'), 3) == 1 % 2D Image
                        
        if isShowTextContours('get', 'axe') == true
            isShowTextContours('set', 'axe', false);
            sShowTextEnable = 'off';
        else
            isShowTextContours('set', 'axe', true);
            sShowTextEnable = 'on';
        end        
        
        imAxeFc = imAxeFcPtr ('get', [], get(uiFusedSeriesPtr('get'), 'Value')); 
        if ~isempty(imAxeFc)
            set(imAxeFc, 'ShowText', sShowTextEnable);
        end       
    else
        imCoronalFc  = imCoronalFcPtr ('get', [], get(uiFusedSeriesPtr('get'), 'Value')); 
        imSagittalFc = imSagittalFcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')); 
        imAxialFc    = imAxialFcPtr   ('get', [], get(uiFusedSeriesPtr('get'), 'Value')); 
        if link2DMip('get') == true        
            imMipFc = imMipFcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));   
        end

        if ~isempty(imCoronalFc)
            sCoronalShowText = get(imCoronalFc, 'ShowText');                
        else
            sCoronalShowText = '';
        end  

        if strcmpi(sCoronalShowText, 'on')
            bCoronalShowText = true;
        else
            bCoronalShowText = false;
        end

        if ~isempty(imSagittalFc)
            sSagittalShowText = get(imSagittalFc, 'ShowText');
        else
            sSagittalShowText = '';                
        end  

        if strcmpi(sSagittalShowText, 'on')
            bSagittalShowText = true;
        else
            bSagittalShowText = false;
        end

        if ~isempty(imAxialFc)
            sAxialShowText = get(imAxialFc, 'ShowText');
        else
            sAxialShowText = '';                
        end  

        if strcmpi(sAxialShowText, 'on')
            bAxialShowText = true;
        else
            bAxialShowText = false;
        end

        if ~isempty(imMipFc) && link2DMip('get') == true
            sMipShowText = get(imMipFc, 'ShowText');
        else
            sMipShowText = '';                
        end  

        if strcmpi(sMipShowText, 'on')
            bMipShowText = true;
        else
            bMipShowText = false;
        end

        if link2DMip('get') == true
            sMipChkEnable = 'on';
            sMipTxtEnable = 'Inactive';
        else
            sMipChkEnable = 'off';
            sMipTxtEnable = 'on';
        end            

        dlgShowTextList = ...
            dialog('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-380/2) ...
                                (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-195/2) ...
                                380 ...
                                195 ...
                                ],...
                  'Color', viewerBackgroundColor('get'), ...
                  'Name', 'Display Plot Text'...
                   );     

         axeShowTextList = ...      
            axes(dlgShowTextList, ...
                 'Units'   , 'pixels', ...
                 'Position', get(dlgShowTextList, 'Position'), ...
                 'Color'   , viewerBackgroundColor('get'),...
                 'XColor'  , viewerForegroundColor('get'),...
                 'YColor'  , viewerForegroundColor('get'),...
                 'ZColor'  , viewerForegroundColor('get'),...             
                 'Visible' , 'off'...             
                 );
        axeShowTextList.Interactions = [zoomInteraction regionZoomInteraction rulerPanInteraction];
        axeShowTextList.Toolbar = [];

        chkCoronalTextEnable = ...
            uicontrol(dlgShowTextList,...
                      'style'          , 'checkbox',...
                      'enable'         , 'on',...
                      'value'          , bCoronalShowText,...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...                 
                      'Callback'       , @chkCoronalTextEnableCallback, ...
                      'position'       , [20 145 265 20]...
                      ); 

            uicontrol(dlgShowTextList,...
                      'style'              , 'text',...
                      'enable'             , 'Inactive',...
                      'string'             , 'Display coronal plot text',...
                      'horizontalalignment', 'left',...
                      'BackgroundColor'    , viewerBackgroundColor('get'), ...
                      'ForegroundColor'    , viewerForegroundColor('get'), ...                   
                      'ButtonDownFcn'      , @chkCoronalTextEnableCallback, ...
                      'position'           , [40 142 300 20]...
                      );

        chkSagittalTextEnable = ...
            uicontrol(dlgShowTextList,...
                      'style'          , 'checkbox',...
                      'enable'         , 'on',...
                      'value'          , bSagittalShowText,...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...                 
                      'Callback'       , @chkSagittalTextEnableCallback, ...
                      'position'       , [20 120 265 20]...
                      );                    

             uicontrol(dlgShowTextList,...
                      'style'              , 'text',...
                      'enable'             , 'Inactive',...
                      'string'             , 'Display sagittal plot text',...
                      'horizontalalignment', 'left',...
                      'BackgroundColor'    , viewerBackgroundColor('get'), ...
                      'ForegroundColor'    , viewerForegroundColor('get'), ...                   
                      'ButtonDownFcn'      , @chkSagittalTextEnableCallback, ...
                      'position'           , [40 117 300 20]...
                      );

        chkAxialTextEnable = ...
            uicontrol(dlgShowTextList,...
                      'style'          , 'checkbox',...
                      'enable'         , 'on',...
                      'value'          , bAxialShowText,...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...                 
                      'Callback'       , @chkAxialTextEnableCallback, ...
                      'position'       , [20 95 265 20]...
                      );                          

            uicontrol(dlgShowTextList,...
                      'style'              , 'text',...
                      'enable'             , 'Inactive',...
                      'string'             , 'Display axial plot text',...
                      'horizontalalignment', 'left',...
                      'BackgroundColor'    , viewerBackgroundColor('get'), ...
                      'ForegroundColor'    , viewerForegroundColor('get'), ...                   
                      'ButtonDownFcn'      , @chkAxialTextEnableCallback, ...
                      'position'           , [40 93 300 20]...
                      );

        chkMipTextEnable = ...
            uicontrol(dlgShowTextList,...
                      'style'          , 'checkbox',...
                      'enable'         , sMipChkEnable,...
                      'value'          , bMipShowText,...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...                 
                      'Callback'       , @chkMipTextEnableCallback, ...
                      'position'       , [20 70 265 20]...
                      ); 

            uicontrol(dlgShowTextList,...
                      'style'              , 'text',...
                      'enable'             , sMipTxtEnable,...
                      'string'             , 'Display MIP plot text',...
                      'horizontalalignment', 'left',...
                      'BackgroundColor'    , viewerBackgroundColor('get'), ...
                      'ForegroundColor'    , viewerForegroundColor('get'), ...                   
                      'ButtonDownFcn'      , @chkMipTextEnableCallback, ...
                      'position'           , [40 67 300 20]...
                      );

            % Cancel or Proceed

            uicontrol(dlgShowTextList,...
                      'String','Cancel',...
                      'Position',[285 7 75 25],...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...                
                      'Callback', @cancelShowTextCallback...
                      );

            uicontrol(dlgShowTextList,...
                      'String','Proceed',...
                      'Position',[200 7 75 25],...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...               
                      'Callback', @proceedShowTextCallback...
                      );         
    end
    
    function chkCoronalTextEnableCallback(hObject, ~)    
        
        imCoronalFc = imCoronalFcPtr ('get', [], get(uiFusedSeriesPtr('get'), 'Value')); 
        
        if get(chkCoronalTextEnable, 'Value') == true
            if strcmpi(get(hObject, 'Style'), 'checkbox')
                set(chkCoronalTextEnable, 'Value', true);
            else
                set(chkCoronalTextEnable, 'Value', false);
            end
        else
            if strcmpi(get(hObject, 'Style'), 'checkbox')
                set(chkCoronalTextEnable, 'Value', false);
            else
                set(chkCoronalTextEnable, 'Value', true);
            end
        end
        
        if get(chkCoronalTextEnable, 'Value') == true
            sShowCoronalTextEnable = 'on';
        else
            sShowCoronalTextEnable = 'off';
        end        
        
        if ~isempty(imCoronalFc)
            set(imCoronalFc, 'ShowText', sShowCoronalTextEnable);
        end        
    end

    function chkSagittalTextEnableCallback(hObject, ~)  
        
        imSagittalFc = imSagittalFcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')); 
        
        if get(chkSagittalTextEnable, 'Value') == true
            if strcmpi(get(hObject, 'Style'), 'checkbox')
                set(chkSagittalTextEnable, 'Value', true);
            else
                set(chkSagittalTextEnable, 'Value', false);
            end
        else
            if strcmpi(get(hObject, 'Style'), 'checkbox')
                set(chkSagittalTextEnable, 'Value', false);
            else
                set(chkSagittalTextEnable, 'Value', true);
            end
        end
        
        if get(chkSagittalTextEnable, 'Value') == true
            sShowSagittalTextEnable = 'on';
        else
            sShowSagittalTextEnable = 'off';
        end
        
        if ~isempty(imSagittalFc)
            set(imSagittalFc, 'ShowText', sShowSagittalTextEnable);
        end        
    end

    function chkAxialTextEnableCallback(hObject, ~)    
        
        imAxialFc = imAxialFcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')); 
        
        if get(chkAxialTextEnable, 'Value') == true
            if strcmpi(get(hObject, 'Style'), 'checkbox')
                set(chkAxialTextEnable, 'Value', true);
            else
                set(chkAxialTextEnable, 'Value', false);
            end
        else
            if strcmpi(get(hObject, 'Style'), 'checkbox')
                set(chkAxialTextEnable, 'Value', false);
            else
                set(chkAxialTextEnable, 'Value', true);
            end
        end
        
        if get(chkAxialTextEnable, 'Value') == true
            sShowAxialTextEnable = 'on';
        else
            sShowAxialTextEnable = 'off';
        end
        
        if ~isempty(imAxialFc)
            set(imAxialFc, 'ShowText', sShowAxialTextEnable);
        end        
    end

    function chkMipTextEnableCallback(hObject, ~)    
        
        imMipFc = imMipFcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));   
        
        if get(chkMipTextEnable, 'Value') == true
            if strcmpi(get(hObject, 'Style'), 'checkbox')
                set(chkMipTextEnable, 'Value', true);
            else
                set(chkMipTextEnable, 'Value', false);
            end
        else
            if strcmpi(get(hObject, 'Style'), 'checkbox')
                set(chkMipTextEnable, 'Value', false);
            else
                set(chkMipTextEnable, 'Value', true);
            end
        end 
        
        if get(chkMipTextEnable, 'Value') == true
            sShowMipTextEnable = 'on';
        else
            sShowMipTextEnable = 'off';
        end
            
        if ~isempty(imMipFc)
            set(imMipFc, 'ShowText', sShowMipTextEnable);
        end        
    end

    function cancelShowTextCallback(~, ~)
        
        imCoronalFc  = imCoronalFcPtr ('get', [], get(uiFusedSeriesPtr('get'), 'Value')); 
        imSagittalFc = imSagittalFcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')); 
        imAxialFc    = imAxialFcPtr   ('get', [], get(uiFusedSeriesPtr('get'), 'Value')); 
        if link2DMip('get') == true
            imMipFc = imMipFcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));   
        end  
        
        if isShowTextContours('get', 'coronal') == true
            sShowCoronalTextEnable = 'on';
        else
            sShowCoronalTextEnable = 'off';
        end
        
        if isShowTextContours('get', 'sagittal') == true
            sShowSagittalTextEnable = 'on';
        else
            sShowSagittalTextEnable = 'off';
        end
        
        if isShowTextContours('get', 'axial') == true
            sShowAxialTextEnable = 'on';
        else
            sShowAxialTextEnable = 'off';
        end
        
        if ~isempty(imCoronalFc)
            set(imCoronalFc, 'ShowText', sShowCoronalTextEnable);
        end
        
        if ~isempty(imSagittalFc)
            set(imSagittalFc, 'ShowText', sShowSagittalTextEnable);
        end

        if ~isempty(imAxialFc)
            set(imAxialFc, 'ShowText', sShowAxialTextEnable);
        end
        
        if link2DMip('get') == true
            
            if isShowTextContours('get', 'mip') == true
                sShowMipTextEnable = 'on';
            else
                sShowMipTextEnable = 'off';
            end
        
            if ~isempty(imMipFc)
                set(imMipFc, 'ShowText', sShowMipTextEnable);
            end
        end
        
        delete(dlgShowTextList);
    end

    function proceedShowTextCallback(~, ~)
        
        imCoronalFc  = imCoronalFcPtr ('get', [], get(uiFusedSeriesPtr('get'), 'Value')); 
        imSagittalFc = imSagittalFcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')); 
        imAxialFc    = imAxialFcPtr   ('get', [], get(uiFusedSeriesPtr('get'), 'Value')); 
        if link2DMip('get') == true
            imMipFc = imMipFcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));   
        end            
        
        if get(chkCoronalTextEnable, 'Value') == true
            isShowTextContours('set', 'coronal', true);
            sShowCoronalTextEnable = 'on';
        else
            isShowTextContours('set', 'coronal', false);
            sShowCoronalTextEnable = 'off';
        end
        
        if get(chkSagittalTextEnable, 'Value') == true
            isShowTextContours('set', 'sagittal', true);
            sShowSagittalTextEnable = 'on';
        else
            isShowTextContours('set', 'sagittal', false);
            sShowSagittalTextEnable = 'off';
        end
        
        if get(chkAxialTextEnable, 'Value') == true
            isShowTextContours('set', 'axial', true);
            sShowAxialTextEnable = 'on';
        else
            isShowTextContours('set', 'axial', false);
            sShowAxialTextEnable = 'off';
        end
        
        if ~isempty(imCoronalFc)
            set(imCoronalFc, 'ShowText', sShowCoronalTextEnable);
        end
        
        if ~isempty(imSagittalFc)
            set(imSagittalFc, 'ShowText', sShowSagittalTextEnable);
        end

        if ~isempty(imAxialFc)
            set(imAxialFc, 'ShowText', sShowAxialTextEnable);
        end

        if link2DMip('get') == true
            
            if get(chkMipTextEnable, 'Value') == true
                isShowTextContours('set', 'mip', true);                
                sShowMipTextEnable = 'on';
            else
                isShowTextContours('set', 'mip', false);                
                sShowMipTextEnable = 'off';
            end
        
            if ~isempty(imMipFc)
                set(imMipFc, 'ShowText', sShowMipTextEnable);
            end
        end
        
        delete(dlgShowTextList);
        
    end    
end



