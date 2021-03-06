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
                 'Position', [0 0 1 1], ... 
                 'Visible' , 'off'...
                 );  
        axefPtr('set', axef);

        axe = ...
            axes(uiOneWindowPtr('get'), ...
                 'Units'   , 'normalized', ...
                 'Position', [0 0 1 1], ... 
                 'Visible' , 'off'...
                 );  
        axePtr('set', axe);
    else     

        uiCorWindow = ...
            uipanel(fiMainWindowPtr('get'),...
                    'Units'          , 'pixels',...
                    'BorderWidth'    , showBorder('get'),...
                    'HighlightColor' , [0 1 1],...
                    'BackgroundColor', backgroundColor('get'),...
                    'position', [0 ...
                                 addOnWidth('get')+30+15 ...
                                 getMainWindowSize('xsize')/4 ...
                                 getMainWindowSize('ysize')-getTopWindowSize('ysize')-addOnWidth('get')-30-15 ...
                                 ]...
                    );                       
         uiCorWindowPtr('set', uiCorWindow);

         uiSliderCor = ...
             uicontrol(fiMainWindowPtr('get'), ...
                       'Style'   , 'Slider', ...
                       'Position', [0 ...
                                    addOnWidth('get')+30 ...
                                    getMainWindowSize('xsize')/4 ...
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
                     'position', [getMainWindowSize('xsize')/4 ...
                                  addOnWidth('get')+30+15 ...
                                  getMainWindowSize('xsize')/4 ... 
                                  getMainWindowSize('ysize')-getTopWindowSize('ysize')-addOnWidth('get')-30-15 ...
                                  ]...
                     );  
        uiSagWindowPtr('set', uiSagWindow);

        uiSliderSag = ...
            uicontrol(fiMainWindowPtr('get'), ...
                      'Style'   , 'Slider', ...
                      'Position', [(getMainWindowSize('xsize')/4) ...
                                   addOnWidth('get')+30 ...
                                   getMainWindowSize('xsize')/4 ...
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
                    'position', [(getMainWindowSize('xsize')/2) ...
                                 addOnWidth('get')+30+15 ...
                                 getMainWindowSize('xsize')/2 ...
                                 getMainWindowSize('ysize')-getTopWindowSize('ysize')-addOnWidth('get')-30-15 ...
                                 ]...
                                );   
        uiTraWindowPtr('set', uiTraWindow);

        uiSliderTra = ...
            uicontrol(fiMainWindowPtr('get'), ...
                      'Style'   , 'Slider', ...
                      'Position', [(getMainWindowSize('xsize')/2) ...
                                   addOnWidth('get')+30 ...
                                   getMainWindowSize('xsize')/2 ...
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


%        jScrollBar = findobj(uiSliderTraPtr('get'));
 %       jScrollBar.ButtonDownFcn =  @sliderTraCallback;

        axes1f = ...
            axes(uiCorWindowPtr('get'), ...
                 'Units'   ,'normalized', ...
                 'xlimmode','manual',...
                 'ylimmode','manual',...
                 'zlimmode','manual',...
                 'climmode','manual',...
                 'alimmode','manual',...                              
                 'Position', [0 0 1 1], ...
                 'Color'   ,'none',...
                 'Visible' , 'off'...
                 );                  
        axes1fPtr('set', axes1f);

        axes1 = ...
            axes(uiCorWindowPtr('get'), ...
                 'Units'   , 'normalized', ...
                 'xlimmode', 'manual',...
                 'ylimmode', 'manual',...
                 'zlimmode', 'manual',...
                 'climmode', 'manual',...
                 'alimmode', 'manual',...   
                 'Position', [0 0 1 1], ... 
                 'Visible' , 'off'...
                );  
        axes1Ptr('set', axes1);

        axes2f = ...
            axes(uiSagWindowPtr('get'), ...
                 'Units'   ,'normalized', ...
                 'xlimmode','manual',...
                 'ylimmode','manual',...
                 'zlimmode','manual',...
                 'climmode','manual',...
                 'alimmode','manual',...                              
                 'Position', [0 0 1 1], ...
                 'Color'   ,'none',...
                 'Visible' , 'off'...
                 );  
        axes2fPtr('set', axes2f);

        axes2 = ...
            axes(uiSagWindowPtr('get'), ...
                 'Units'   , 'normalized', ...
                 'xlimmode', 'manual',...
                 'ylimmode', 'manual',...
                 'zlimmode', 'manual',...
                 'climmode', 'manual',...
                 'alimmode', 'manual',...                             
                 'Position', [0 0 1 1], ...
                 'Visible' , 'off'...
                 );
        axes2Ptr('set', axes2);

        axes3f = ...
            axes(uiTraWindowPtr('get'), ...
                 'Units'   ,'normalized', ...
                 'xlimmode','manual',...
                 'ylimmode','manual',...
                 'zlimmode','manual',...
                 'climmode','manual',...
                 'alimmode','manual',...                              
                 'Position', [0 0 1 1], ...
                 'Color'   ,'none',...
                 'Visible' , 'off'...
                 );  
        axes3fPtr('set', axes3f);

        axes3 = ...
            axes(uiTraWindowPtr('get'), ...
                 'Units'   ,'normalized', ...
                 'xlimmode','manual',...
                 'ylimmode','manual',...
                 'zlimmode','manual',...
                 'climmode','manual',...
                 'alimmode','manual',...                              
                 'Position', [0 0 1 1], ...
                 'Visible' , 'off'...
                 );
        axes3Ptr('set', axes3);
    end

end