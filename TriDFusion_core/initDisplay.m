function initDisplay(iMode)
%function initDisplay(iMode)
%Init Viewer Panel and Axes.
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

    % Segmentation Panel

     uiSegMainPanel = ...
        uipanel(fiMainWindowPtr('get'),...
                'Units'   , 'pixels',...
                'position', [0 ...
                             addOnWidth('get')+30 ...
                             300 ...
                             getMainWindowSize('ysize')-getTopWindowSize('ysize')-addOnWidth('get')-30 ...
                             ], ...
                'BackgroundColor', viewerBackgroundColor('get'), ...
                'ForegroundColor', viewerForegroundColor('get'), ...
                'Visible', 'off'...
                );
     uiSegMainPanelPtr('set', uiSegMainPanel);

     uiSegPanel = ...
         uipanel(uiSegMainPanelPtr('get'),...
                 'Units'   , 'pixels',...
                 'position', [0 ...
                              0 ...
                              280 ...
                              2000 ...
                              ],...
                'BackgroundColor', viewerBackgroundColor('get'), ...
                'ForegroundColor', viewerForegroundColor('get'), ...
                 'Visible', 'on'...
                 );
    uiSegPanelPtr('set', uiSegPanel);

    aSegMainPanelPosition = get(uiSegMainPanelPtr('get'), 'position');
    uiSegPanelSlider = ...
        uicontrol('Style'   , 'Slider', ...
                  'Parent'  , uiSegMainPanelPtr('get'),...
                  'Units'   , 'pixels',...
                  'position', [280 ...
                               0 ...
                               20 ...
                               aSegMainPanelPosition(4) ...
                               ],...
                  'Value', 0, ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback',@uiSegPanelSliderCallback ...
                  );
    uiSegPanelSliderPtr('set', uiSegPanelSlider);
    addlistener(uiSegPanelSlider, 'Value', 'PreSet', @uiSegPanelSliderCallback);

    initSegPanel();

    % Kernel Panel

    uiKernelMainPanel = ...
        uipanel(fiMainWindowPtr('get'),...
                'Units'   , 'pixels',...
                'position', [0 ...
                             addOnWidth('get')+30 ...
                             300 ...
                             getMainWindowSize('ysize')-getTopWindowSize('ysize')-addOnWidth('get')-30 ...
                             ],...
                'BackgroundColor', viewerBackgroundColor('get'), ...
                'ForegroundColor', viewerForegroundColor('get'), ...
                'Visible', 'off'...
                );
    uiKernelMainPanelPtr('set', uiKernelMainPanel);

    uiKernelPanel = ...
        uipanel(uiKernelMainPanelPtr('get'),...
                'Units'   , 'pixels',...
                'position', [0 ...
                             0 ...
                             280 ...
                             2000 ...
                             ],...
                'BackgroundColor', viewerBackgroundColor('get'), ...
                'ForegroundColor', viewerForegroundColor('get'), ...
                'Visible', 'on'...
                );
    uiKernelPanelPtr('set', uiKernelPanel);

    aKernelMainPanelPosition = get(uiKernelMainPanelPtr('get'), 'position');
    uiKernelPanelSlider = ...
        uicontrol('Style'   , 'Slider', ...
                  'Parent'  , uiKernelMainPanelPtr('get'),...
                  'Units'   , 'pixels',...
                  'position', [280 ...
                               0 ...
                               20 ...
                               aKernelMainPanelPosition(4) ...
                               ],...
                  'Value'   , 0, ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback',@uiKernelPanelSliderCallback ...
                  );
    uiKernelPanelSliderPtr('set', uiKernelPanelSlider);
    addlistener(uiKernelPanelSlider, 'Value', 'PreSet', @uiKernelPanelSliderCallback);

    initKernelPanel();

    % Roi Panel

    uiRoiMainPanel = ...
        uipanel(fiMainWindowPtr('get'),...
                'Units'   , 'pixels',...
                'position', [0 ...
                             addOnWidth('get')+30 ...
                             300 ...
                             getMainWindowSize('ysize')-getTopWindowSize('ysize')-addOnWidth('get')-30 ...
                             ],...
                'BackgroundColor', viewerBackgroundColor('get'), ...
                'ForegroundColor', viewerForegroundColor('get'), ...
                'Visible', 'off'...
                );
    uiRoiMainPanelPtr('set', uiRoiMainPanel);

    uiRoiPanel = ...
        uipanel(uiRoiMainPanelPtr('get'),...
                'Units'   , 'pixels',...
                'position', [0 ...
                             0 ...
                             280 ...
                             2000 ...
                             ],...
                'BackgroundColor', viewerBackgroundColor('get'), ...
                'ForegroundColor', viewerForegroundColor('get'), ...
                'Visible', 'on'...
                );
    uiRoiPanelPtr('set', uiRoiPanel);

    aRoiMainPanelPosition = get(uiRoiMainPanelPtr('get'), 'position');
    uiRoiPanelSlider = ...
        uicontrol('Style'   , 'Slider', ...
                  'Parent'  , uiRoiMainPanelPtr('get'),...
                  'Units'   , 'pixels',...
                  'position', [280 ...
                               0 ...
                               20 ...
                               aRoiMainPanelPosition(4) ...
                               ],...
                  'Value'   , 0, ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback',@uiRoiPanelSliderCallback ...
                  );
    uiRoiPanelSliderPtr('set', uiRoiPanelSlider);
    addlistener(uiRoiPanelSlider, 'Value', 'PreSet', @uiRoiPanelSliderCallback);

    initRoiPanel();


    if size(dicomBuffer('get'), 3) == 1 || ...
       iMode == 1

        if switchTo3DMode('get')     == true || ...
           switchToIsoSurface('get') == true || ...
           switchToMIPMode('get')    == true
            uiOneWindow = ...
                uipanel(fiMainWindowPtr('get'),...
                        'Units'          , 'pixels',...
                        'BorderWidth'    , showBorder('get'),...
                        'HighlightColor' , [0 1 1],...
                        'BackgroundColor', surfaceColor('get', background3DOffset('get')),...
                        'position', [680 ...
                                     addOnWidth('get')+30 ...
                                     getMainWindowSize('xsize')-680 ...
                                     getMainWindowSize('ysize')-getTopWindowSize('ysize')-addOnWidth('get')-30 ...
                                     ]...
                        );
            uiOneWindowPtr('set', uiOneWindow);

            uiMain3DPanel = ...
                uipanel(fiMainWindowPtr('get'),...
                        'Units'   , 'pixels',...
                        'position', [0 ...
                                     addOnWidth('get')+30 ...
                                     680 ...
                                     getMainWindowSize('ysize')-getTopWindowSize('ysize')-addOnWidth('get')-30 ...
                                    ],...
                        'BackgroundColor', viewerBackgroundColor('get'), ...
                        'ForegroundColor', viewerForegroundColor('get') ...
                       );
            uiMain3DPanelPtr('set', uiMain3DPanel);

            ui3DPanel = ...
                uipanel(uiMain3DPanelPtr('get'),...
                        'Units'   , 'pixels',...
                        'position', [0 ...
                                     0 ...
                                     660 ...
                                     2000 ...
                                     ], ...
                        'BackgroundColor', viewerBackgroundColor('get'), ...
                        'ForegroundColor', viewerForegroundColor('get') ...
                        );
            ui3DPanelPtr('set', ui3DPanel);

            aMain3DPanelPosition = get(uiMain3DPanelPtr('get'), 'position');
            ui3DPanelSlider = ...
                uicontrol('Style'   , 'Slider', ...
                          'Parent'  , uiMain3DPanelPtr('get'),...
                          'Units'   , 'pixels',...
                          'position', [660 ...
                                       0 ...
                                       20 ...
                                       aMain3DPanelPosition(4) ...
                                       ],...
                          'Value', 0, ...
                          'BackgroundColor', viewerBackgroundColor('get'), ...
                          'ForegroundColor', viewerForegroundColor('get'), ...
                          'Callback',@ui3DPanelSliderCallback ...
                          );
            ui3DPanelSliderPtr('set', ui3DPanelSlider);
            addlistener(ui3DPanelSlider,'Value','PreSet', @ui3DPanelSliderCallback);

        else
            uiOneWindow = ...
                uipanel(fiMainWindowPtr('get'),...
                        'Units'          , 'pixels',...
                        'BorderWidth'    , showBorder('get'),...
                        'HighlightColor' , [0 1 1],...
                        'BackgroundColor', backgroundColor('get'),...
                        'position', [0 ...
                                     addOnWidth('get')+30 ...
                                     getMainWindowSize('xsize') ...
                                     getMainWindowSize('ysize')-getTopWindowSize('ysize')-addOnWidth('get')-30 ...
                                     ]...
                        );
           uiOneWindowPtr('set', uiOneWindow);
        end

        axef = ...
            axes(uiOneWindowPtr('get'), ...
                 'Units'   , 'normalized', ...
                 'Ydir'    , 'reverse', ...
                 'Position', [0 0 1 1], ...
                 'Visible' , 'off'...
                 );
        axefPtr('set', axef, get(uiFusedSeriesPtr('get'), 'Value'));
        
        axefc = ...
            axes(uiOneWindowPtr('get'), ...
                 'Units'   ,'normalized', ...
                 'Ydir'    , 'reverse', ...
                 'Position', [0 0 1 1], ...
                 'Color'   ,'none',...
                 'Visible' , 'off'...
                 );
        axefcPtr('set', axefc, get(uiFusedSeriesPtr('get'), 'Value'));
        
%        axer = ...
%            axes(uiOneWindowPtr('get'), ...
%                 'Units'   , 'normalized', ...
%                 'Ydir'    , 'reverse', ...
%                 'Position', [0 0 1 1], ...
%                 'Visible' , 'off'...
%                 );
%        axis(axer, 'equal'); % Need equal axe for circle roi
%        axerPtr('set', axer, get(uiSeriesPtr('get'), 'Value'));
        
        axe = ...
            axes(uiOneWindowPtr('get'), ...
                 'Units'   , 'normalized', ...
                 'Ydir'    , 'reverse', ...
                 'Position', [0 0 1 1], ...
                 'Visible' , 'off'...
                 );
        axePtr('set', axe, get(uiSeriesPtr('get'), 'Value'));
        
%        linkaxes([axe axer],'xy');                                
%        uistack(axer, 'top');            
    else

        uiCorWindow = ...
            uipanel(fiMainWindowPtr('get'),...
                    'Units'          , 'pixels',...
                    'BorderWidth'    , showBorder('get'),...
                    'HighlightColor' , [0 1 1],...
                    'BackgroundColor', backgroundColor('get'),...
                    'position', [0 ...
                                 addOnWidth('get')+30+15 ...
                                 getMainWindowSize('xsize')/5 ...
                                 getMainWindowSize('ysize')-getTopWindowSize('ysize')-addOnWidth('get')-30-15 ...
                                 ]...
                    );
         uiCorWindowPtr('set', uiCorWindow);

         uiSliderCor = ...
             uicontrol(fiMainWindowPtr('get'), ...
                       'Style'   , 'Slider', ...
                       'Position', [0 ...
                                    addOnWidth('get')+30 ...
                                    getMainWindowSize('xsize')/5 ...
                                    15 ...
                                    ], ...
                       'Value'   , 0.5, ...
                       'Enable'  , 'on', ...
                       'BackgroundColor', viewerBackgroundColor('get'), ...
                       'ForegroundColor', viewerForegroundColor('get'), ...
                       'CallBack', @sliderCorCallback ...
                       );
         uiSliderCorPtr('set', uiSliderCor);
         addlistener(uiSliderCor, 'Value', 'PreSet', @sliderCorCallback);

         uiSagWindow = ...
             uipanel(fiMainWindowPtr('get'),...
                     'Units'          , 'pixels',...
                     'BorderWidth'    , showBorder('get'),...
                     'HighlightColor' , [0 1 1],...
                     'BackgroundColor', backgroundColor('get'),...
                     'position', [getMainWindowSize('xsize')/5 ...
                                  addOnWidth('get')+30+15 ...
                                  getMainWindowSize('xsize')/5 ...
                                  getMainWindowSize('ysize')-getTopWindowSize('ysize')-addOnWidth('get')-30-15 ...
                                  ]...
                     );
        uiSagWindowPtr('set', uiSagWindow);

        uiSliderSag = ...
            uicontrol(fiMainWindowPtr('get'), ...
                      'Style'   , 'Slider', ...
                      'Position', [(getMainWindowSize('xsize')/5) ...
                                   addOnWidth('get')+30 ...
                                   getMainWindowSize('xsize')/5 ...
                                   15 ...
                                   ], ...
                      'Value'   , 0.5, ...
                      'Enable'  , 'on', ...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...
                      'CallBack', @sliderSagCallback ...
                      );
        uiSliderSagPtr('set', uiSliderSag);
        addlistener(uiSliderSag,'Value','PreSet',@sliderSagCallback);

        uiTraWindow = ...
            uipanel(fiMainWindowPtr('get'),...
                    'Units'          , 'pixels',...
                    'BorderWidth'    , showBorder('get'),...
                    'HighlightColor' , [0 1 1],...
                    'BackgroundColor', backgroundColor('get'),...
                    'position', [(getMainWindowSize('xsize')/2.5) ...
                                 addOnWidth('get')+30+15 ...
                                 getMainWindowSize('xsize')/2.5 ...
                                 getMainWindowSize('ysize')-getTopWindowSize('ysize')-addOnWidth('get')-30-15 ...
                                 ]...
                                );
        uiTraWindowPtr('set', uiTraWindow);

        uiSliderTra = ...
            uicontrol(fiMainWindowPtr('get'), ...
                      'Style'   , 'Slider', ...
                      'Position', [(getMainWindowSize('xsize')/2.5) ...
                                   addOnWidth('get')+30 ...
                                   getMainWindowSize('xsize')/2.5 ...
                                   15 ...
                                   ], ...
                      'Value'   , 0.5, ...
                      'Enable'  , 'on', ...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...
                      'CallBack', @sliderTraCallback ...
                      );
        uiSliderTraPtr('set', uiSliderTra);
        addlistener(uiSliderTra, 'Value', 'PreSet', @sliderTraCallback);

        uiMipWindow = ...
            uipanel(fiMainWindowPtr('get'),...
                    'Units'          , 'pixels',...
                    'BorderWidth'    , showBorder('get'),...
                    'HighlightColor' , [0 1 1],...
                    'BackgroundColor', backgroundColor('get'),...
                    'position', [(getMainWindowSize('xsize')/1.25) ...
                                 addOnWidth('get')+30+15 ...
                                 getMainWindowSize('xsize')/5 ...
                                 getMainWindowSize('ysize')-getTopWindowSize('ysize')-addOnWidth('get')-30-15 ...
                                 ]...
                                );
        uiMipWindowPtr('set', uiMipWindow);
        
        if mipAngle('get') == 1
            dMipSliderValue = 0;
        else
            dMipSliderValue = mipAngle('get')/32;
        end
        
        uiSliderMip = ...
            uicontrol(fiMainWindowPtr('get'), ...
                      'Style'   , 'Slider', ...
                      'Position', [(getMainWindowSize('xsize')/1.25) ...
                                   addOnWidth('get')+30 ...
                                   getMainWindowSize('xsize')/5 ...
                                   15 ...
                                   ], ...
                      'Value'   , dMipSliderValue, ...
                      'Enable'  , 'on', ...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...
                      'CallBack', @sliderMipCallback ...
                      );
        uiSliderMipPtr('set', uiSliderMip);
        addlistener(uiSliderMip, 'Value', 'PreSet', @sliderMipCallback);

%        jScrollBar = findobj(uiSliderTraPtr('get'));
 %       jScrollBar.ButtonDownFcn =  @sliderTraCallback;
                        
        axes1f = ...
            axes(uiCorWindowPtr('get'), ...
                 'Units'   ,'normalized', ...
                 'Ydir'    , 'reverse', ...
                 'xlimmode','manual',...
                 'ylimmode','manual',...
                 'zlimmode','manual',...
                 'climmode','manual',...
                 'alimmode','manual',...
                 'Position', [0 0 1 1], ...
                 'Color'   ,'none',...
                 'Visible' , 'off'...
                 );
        axes1fPtr('set', axes1f, get(uiFusedSeriesPtr('get'), 'Value'));
        
        axes1fc = ...
            axes(uiCorWindowPtr('get'), ...
                 'Units'   ,'normalized', ...
                 'Ydir'    , 'reverse', ...
                 'xlimmode','manual',...
                 'ylimmode','manual',...
                 'zlimmode','manual',...
                 'climmode','manual',...
                 'alimmode','manual',...
                 'Position', [0 0 1 1], ...
                 'Color'   ,'none',...
                 'Visible' , 'off'...
                 );
        axes1fcPtr('set', axes1fc, get(uiFusedSeriesPtr('get'), 'Value'));
        
        axes1r = ...
           axes(uiCorWindowPtr('get'), ...
                'Units'   , 'normalized', ...
                'Ydir'    , 'reverse', ...
                'xlimmode', 'manual',...
                'ylimmode', 'manual',...
                'zlimmode', 'manual',...
                'climmode', 'manual',...
                'alimmode', 'manual',...
                'Position', [0 0 1 1], ...
                'Visible' , 'off'...
                );
       axis(axes1r, 'equal'); % Need equal axe for circle roi
       axes1rPtr('set', axes1r, get(uiSeriesPtr('get'), 'Value')); 
       
        axes1 = ...
            axes(uiCorWindowPtr('get'), ...
                 'Units'   , 'normalized', ...
                 'Ydir'    , 'reverse', ...
                 'xlimmode', 'manual',...
                 'ylimmode', 'manual',...
                 'zlimmode', 'manual',...
                 'climmode', 'manual',...
                 'alimmode', 'manual',...
                 'Position', [0 0 1 1], ...
                 'Visible' , 'off'...
                );
        axes1Ptr('set', axes1, get(uiSeriesPtr('get'), 'Value'));                            
        
%        linkaxes([axes1 axes1r],'xy');                                
%        uistack(axes1r, 'top');            
        
        axes2f = ...
            axes(uiSagWindowPtr('get'), ...
                 'Units'   ,'normalized', ...
                 'Ydir'    ,'reverse', ...
                 'xlimmode','manual',...
                 'ylimmode','manual',...
                 'zlimmode','manual',...
                 'climmode','manual',...
                 'alimmode','manual',...
                 'Position', [0 0 1 1], ...
                 'Color'   ,'none',...
                 'Visible' , 'off'...
                 );
        axes2fPtr('set', axes2f, get(uiFusedSeriesPtr('get'), 'Value'));
        
        axes2fc = ...
            axes(uiSagWindowPtr('get'), ...
                 'Units'   ,'normalized', ...
                 'Ydir'    ,'reverse', ...
                 'xlimmode','manual',...
                 'ylimmode','manual',...
                 'zlimmode','manual',...
                 'climmode','manual',...
                 'alimmode','manual',...
                 'Position', [0 0 1 1], ...
                 'Color'   ,'none',...
                 'Visible' , 'off'...
                 );
        axes2fcPtr('set', axes2fc, get(uiFusedSeriesPtr('get'), 'Value'));
        
         axes2r = ...
           axes(uiSagWindowPtr('get'), ...
                'Units'   , 'normalized', ...
                'Ydir'    , 'reverse', ...
                'xlimmode', 'manual',...
                'ylimmode', 'manual',...
                'zlimmode', 'manual',...
                'climmode', 'manual',...
                'alimmode', 'manual',...
                'Position', [0 0 1 1], ...
                'Visible' , 'off'...
                );
        axis(axes2r, 'equal'); % Need equal axe for circle roi
        axes2rPtr('set', axes2r, get(uiSeriesPtr('get'), 'Value'));  
       
        axes2 = ...
            axes(uiSagWindowPtr('get'), ...
                 'Units'   , 'normalized', ...
                 'Ydir'    , 'reverse', ...
                 'xlimmode', 'manual',...
                 'ylimmode', 'manual',...
                 'zlimmode', 'manual',...
                 'climmode', 'manual',...
                 'alimmode', 'manual',...
                 'Position', [0 0 1 1], ...
                 'Visible' , 'off'...
                 );
        axes2Ptr('set', axes2, get(uiSeriesPtr('get'), 'Value'));        
        
%        linkaxes([axes2 axes2r],'xy');                                
%        uistack(axes2r, 'top');    
        
        axes3f = ...
            axes(uiTraWindowPtr('get'), ...
                 'Units'   ,'normalized', ...
                 'Ydir'    ,'reverse', ...
                 'xlimmode','manual',...
                 'ylimmode','manual',...
                 'zlimmode','manual',...
                 'climmode','manual',...
                 'alimmode','manual',...
                 'Position', [0 0 1 1], ...
                 'Color'   ,'none',...
                 'Visible' , 'off'...
                 );
        axes3fPtr('set', axes3f, get(uiFusedSeriesPtr('get'), 'Value'));
        
        axes3fc = ...
            axes(uiTraWindowPtr('get'), ...
                 'Units'   ,'normalized', ...
                 'Ydir'    ,'reverse', ...
                 'xlimmode','manual',...
                 'ylimmode','manual',...
                 'zlimmode','manual',...
                 'climmode','manual',...
                 'alimmode','manual',...
                 'Position', [0 0 1 1], ...
                 'Color'   ,'none',...
                 'Visible' , 'off'...
                 );
        axes3fcPtr('set', axes3fc, get(uiFusedSeriesPtr('get'), 'Value'));
        
        axes3r = ...
           axes(uiTraWindowPtr('get'), ...
                'Units'   , 'normalized', ...
                'Ydir'    , 'reverse', ...
                'xlimmode', 'manual',...
                'ylimmode', 'manual',...
                'zlimmode', 'manual',...
                'climmode', 'manual',...
                'alimmode', 'manual',...
                'Position', [0 0 1 1], ...
                'Visible' , 'off'...
                );
       axis(axes3r, 'equal'); % Need equal axe for circle roi
       axes3rPtr('set', axes3r, get(uiSeriesPtr('get'), 'Value'));  
       
        axes3 = ...
            axes(uiTraWindowPtr('get'), ...
                 'Units'   ,'normalized', ...
                 'Ydir'    ,'reverse', ...
                 'xlimmode','manual',...
                 'ylimmode','manual',...
                 'zlimmode','manual',...
                 'climmode','manual',...
                 'alimmode','manual',...
                 'Position', [0 0 1 1], ...
                 'Visible' , 'off'...
                 );
        axes3Ptr('set', axes3, get(uiSeriesPtr('get'), 'Value'));                               
        
%        linkaxes([axes3 axes3r],'xy');                                
%        uistack(axes3r, 'top');    
        
        axesMipf = ...
            axes(uiMipWindowPtr('get'), ...
                 'Units'   ,'normalized', ...
                 'Ydir'    ,'reverse', ...
                 'xlimmode','manual',...
                 'ylimmode','manual',...
                 'zlimmode','manual',...
                 'climmode','manual',...
                 'alimmode','manual',...
                 'Position', [0 0 1 1], ...
                 'Color'   ,'none',...
                 'Visible' , 'off'...
                 );
        axesMipfPtr('set', axesMipf, get(uiFusedSeriesPtr('get'), 'Value'));
        
        axesMipfc = ...
            axes(uiMipWindowPtr('get'), ...
                 'Units'   ,'normalized', ...
                 'Ydir'    ,'reverse', ...
                 'xlimmode','manual',...
                 'ylimmode','manual',...
                 'zlimmode','manual',...
                 'climmode','manual',...
                 'alimmode','manual',...
                 'Position', [0 0 1 1], ...
                 'Color'   ,'none',...
                 'Visible' , 'off'...
                 );
        axesMipfcPtr('set', axesMipfc, get(uiFusedSeriesPtr('get'), 'Value'));
        
        axesMip = ...
            axes(uiMipWindowPtr('get'), ...
                 'Units'   ,'normalized', ...
                 'Ydir'    ,'reverse', ...
                 'xlimmode','manual',...
                 'ylimmode','manual',...
                 'zlimmode','manual',...
                 'climmode','manual',...
                 'alimmode','manual',...
                 'Position', [0 0 1 1], ...
                 'Visible' , 'off'...
                 );
        axesMipPtr('set', axesMip, get(uiSeriesPtr('get'), 'Value'));
                
    end

end
