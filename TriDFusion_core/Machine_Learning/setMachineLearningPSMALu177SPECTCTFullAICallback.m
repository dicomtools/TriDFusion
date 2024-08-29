function setMachineLearningPSMALu177SPECTCTFullAICallback(hObject, ~)
%function setMachineLearningPSMALu177SPECTCTFullAICallback()
%Run PSMA Lu177 SPECT/CT Full AI Tumor Segmentation, The tool is called from the main menu.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2024, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    [sPredictScript] = validateNnUNetv2Installation();
    
    dlgPSMALu177SPECTCTFullAISegmentation  = [];
  
    if ~isempty(sPredictScript) ... % External Segmentor is installed

        if exist('hObject', 'var')

            DLG_PSMA_LU177_SPECTCT_PERCENT_X = 380;
            DLG_PSMA_LU177_SPECTCT_PERCENT_Y = 215;

            if viewerUIFigure('get') == true
        
                dlgPSMALu177SPECTCTFullAISegmentation = ...
                    uifigure('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-DLG_PSMA_LU177_SPECTCT_PERCENT_X/2) ...
                                        (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-DLG_PSMA_LU177_SPECTCT_PERCENT_Y/2) ...
                                        DLG_PSMA_LU177_SPECTCT_PERCENT_X ...
                                        DLG_PSMA_LU177_SPECTCT_PERCENT_Y ...
                                        ],...
                           'Resize', 'off', ...
                           'Color', viewerBackgroundColor('get'),...
                           'WindowStyle', 'modal', ...
                           'Name' , 'PSMA Lu177 Machine Learning Full AI SPECT CT Segmentation'...
                           );
            else       
                dlgPSMALu177SPECTCTFullAISegmentation = ...
                    dialog('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-DLG_PSMA_LU177_SPECTCT_PERCENT_X/2) ...
                                        (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-DLG_PSMA_LU177_SPECTCT_PERCENT_Y/2) ...
                                        DLG_PSMA_LU177_SPECTCT_PERCENT_X ...
                                        DLG_PSMA_LU177_SPECTCT_PERCENT_Y ...
                                        ],...
                           'MenuBar', 'none',...
                           'Resize', 'off', ...    
                           'NumberTitle','off',...
                           'MenuBar', 'none',...
                           'Color', viewerBackgroundColor('get'), ...
                           'Name', 'PSMA Lu177 Machine Learning Full AI SPECT CT Segmentation',...
                           'Toolbar','none'...               
                           );    
            end

            % Trainer with Dice and CE Loss
        
                uicontrol(dlgPSMALu177SPECTCTFullAISegmentation,...
                          'style'   , 'text',...
                          'Enable'  , 'Inactive',...
                          'string'  , 'Trainer with Dice and CE Loss, no smoothing',...
                          'horizontalalignment', 'left',...
                          'BackgroundColor', viewerBackgroundColor('get'), ...
                          'ForegroundColor', viewerForegroundColor('get'), ...                   
                          'ButtonDownFcn'  , @chkPSMALu177SPECTCTFullAICELossCallback, ...
                          'position', [40 165 250 20]...
                          );
        
            chkPSMALu177SPECTCTFullAICELoss = ...
                uicontrol(dlgPSMALu177SPECTCTFullAISegmentation,...
                          'style'   , 'checkbox',...
                          'enable'  , 'on',...
                          'value'   , machineLearningPSMALu177CELoss('get'),...
                          'position', [20 165 20 20],...
                          'BackgroundColor', viewerBackgroundColor('get'), ...
                          'ForegroundColor', viewerForegroundColor('get'), ...                   
                          'Callback', @chkPSMALu177SPECTCTFullAICELossCallback...
                          );

            % Classify Segmentation
        
                uicontrol(dlgPSMALu177SPECTCTFullAISegmentation,...
                          'style'   , 'text',...
                          'Enable'  , 'Inactive',...
                          'string'  , 'Classify the Segmentation',...
                          'horizontalalignment', 'left',...
                          'BackgroundColor', viewerBackgroundColor('get'), ...
                          'ForegroundColor', viewerForegroundColor('get'), ...                   
                          'ButtonDownFcn'  , @chkPSMALu177SPECTCTFullAIClassifySegmentationCallback, ...
                          'position', [40 140 250 20]...
                          );
        
            chkPSMALu177SPECTCTFullAIClassifySegmentation = ...
                uicontrol(dlgPSMALu177SPECTCTFullAISegmentation,...
                          'style'   , 'checkbox',...
                          'enable'  , 'on',...
                          'value'   , machineLearningPSMALu177ClassifySegmentation('get'),...
                          'position', [20 140 20 20],...
                          'BackgroundColor', viewerBackgroundColor('get'), ...
                          'ForegroundColor', viewerForegroundColor('get'), ...                   
                          'Callback', @chkPSMALu177SPECTCTFullAIClassifySegmentationCallback...
                          );

            % Smooth mask

                uicontrol(dlgPSMALu177SPECTCTFullAISegmentation,...
                          'style'   , 'text',...
                          'Enable'  , 'Inactive',...
                          'string'  , 'Smooth Mask',...
                          'horizontalalignment', 'left',...
                          'BackgroundColor', viewerBackgroundColor('get'), ...
                          'ForegroundColor', viewerForegroundColor('get'), ...
                          'ButtonDownFcn'  , @chkPSMALu177SPECTCTFullAISmoothMaskCallback, ...
                          'position', [40 115 150 20]...
                          );

            chkPSMALu177SPECTCTFullAISmoothMask = ...
                uicontrol(dlgPSMALu177SPECTCTFullAISegmentation,...
                          'style'   , 'checkbox',...
                          'enable'  , 'on',...
                          'value'   , machineLearningPSMALu177SmoothMask('get'),...
                          'position', [20 115 20 20],...
                          'BackgroundColor', viewerBackgroundColor('get'), ...
                          'ForegroundColor', viewerForegroundColor('get'), ...
                          'Callback', @chkPSMALu177SPECTCTFullAISmoothMaskCallback...
                          );
             % Pixel Edge
        
                uicontrol(dlgPSMALu177SPECTCTFullAISegmentation,...
                          'style'   , 'text',...
                          'Enable'  , 'Inactive',...
                          'string'  , 'Pixel Edge',...
                          'horizontalalignment', 'left',...
                          'BackgroundColor', viewerBackgroundColor('get'), ...
                          'ForegroundColor', viewerForegroundColor('get'), ...                   
                          'ButtonDownFcn'  , @chkPSMALu177SPECTCTFullAIPixelEdgeCallback, ...
                          'position', [40 90 150 20]...
                          );
        
            chkPSMALu177SPECTCTFullAIPixelEdge = ...
                uicontrol(dlgPSMALu177SPECTCTFullAISegmentation,...
                          'style'   , 'checkbox',...
                          'enable'  , 'on',...
                          'value'   , pixelEdge('get'),...
                          'position', [20 90 20 20],...
                          'BackgroundColor', viewerBackgroundColor('get'), ...
                          'ForegroundColor', viewerForegroundColor('get'), ...                   
                          'Callback', @chkPSMALu177SPECTCTFullAIPixelEdgeCallback...
                          );

            % Smallest Contour (ml)
        
                uicontrol(dlgPSMALu177SPECTCTFullAISegmentation,...
                          'style'   , 'text',...
                          'Enable'  , 'On',...
                          'string'  , 'Smallest Contour (ml)',...
                          'horizontalalignment', 'left',...
                          'BackgroundColor', viewerBackgroundColor('get'), ...
                          'ForegroundColor', viewerForegroundColor('get'), ...                   
                          'position', [20 65 250 20]...
                          );
        
            edtPSMALu177SPECTCTFullAISmallestVoiValue = ...
                uicontrol(dlgPSMALu177SPECTCTFullAISegmentation, ...
                          'Style'   , 'Edit', ...
                          'Position', [285 65 75 20], ...
                          'String'  , num2str(machineLearningPSMALu177SmallestVoiValue('get')), ...
                          'Enable'  , 'on', ...
                          'BackgroundColor', viewerBackgroundColor('get'), ...
                          'ForegroundColor', viewerForegroundColor('get'), ...
                          'CallBack', @edtPSMALu177SPECTCTFullAISmallestVoiValueCallback ...
                          );  
        
             % Cancel or Proceed
        
             uicontrol(dlgPSMALu177SPECTCTFullAISegmentation,...
                       'String','Cancel',...
                       'Position',[285 7 75 25],...
                       'BackgroundColor', viewerBackgroundColor('get'), ...
                       'ForegroundColor', viewerForegroundColor('get'), ...                
                       'Callback', @cancelPSMALu177SPECTCTFullAISegmentationCallback...
                       );
        
             uicontrol(dlgPSMALu177SPECTCTFullAISegmentation,...
                      'String','Proceed',...
                      'Position',[200 7 75 25],...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...               
                      'Callback', @proceedPSMALu177SPECTCTFullAISegmentationCallback...
                      );               
        else

            % Options

            tPSMALu177SPECTCTFullAI.options.CELossTrainer        = machineLearningPSMALu177CELoss('get');
            tPSMALu177SPECTCTFullAI.options.classifySegmentation = machineLearningPSMALu177ClassifySegmentation('get');
            tPSMALu177SPECTCTFullAI.options.smoothMask           = machineLearningPSMALu177SmoothMask('get');
            tPSMALu177SPECTCTFullAI.options.smallestVoiValue     = machineLearningPSMALu177SmallestVoiValue('get');
            tPSMALu177SPECTCTFullAI.options.pixelEdge            = pixelEdge('get');
    
            setMachineLearningPSMALu177SPECTCTFullAI(sPredictScript, tPSMALu177SPECTCTFullAI); 
        end
    end

    function chkPSMALu177SPECTCTFullAICELossCallback(hObject, ~)

        bObjectValue = get(chkPSMALu177SPECTCTFullAICELoss, 'Value');

        if strcmpi(get(hObject, 'Style'), 'text')

            set(chkPSMALu177SPECTCTFullAICELoss, 'Value', ~bObjectValue);
        end

        bObjectValue = get(chkPSMALu177SPECTCTFullAICELoss, 'Value');

        machineLearningPSMALu177CELoss('set', bObjectValue);
    end

    function chkPSMALu177SPECTCTFullAIClassifySegmentationCallback(hObject, ~)

        bObjectValue = get(chkPSMALu177SPECTCTFullAIClassifySegmentation, 'Value');

        if strcmpi(get(hObject, 'Style'), 'text')

            set(chkPSMALu177SPECTCTFullAIClassifySegmentation, 'Value', ~bObjectValue);
        end

        bObjectValue = get(chkPSMALu177SPECTCTFullAIClassifySegmentation, 'Value');

        machineLearningPSMALu177ClassifySegmentation('set', bObjectValue);
    end

    function chkPSMALu177SPECTCTFullAISmoothMaskCallback(hObject, ~)

        bObjectValue = get(chkPSMALu177SPECTCTFullAISmoothMask, 'Value');

        if strcmpi(get(hObject, 'Style'), 'text')

            set(chkPSMALu177SPECTCTFullAISmoothMask, 'Value', ~bObjectValue);
        end

        bObjectValue = get(chkPSMALu177SPECTCTFullAISmoothMask, 'Value');

        machineLearningPSMALu177SmoothMask('set', bObjectValue);
    end

    function edtPSMALu177SPECTCTFullAISmallestVoiValueCallback(~, ~)

        dObjectValue = str2double(get(edtPSMALu177SPECTCTFullAISmallestVoiValue, 'String'));

        if dObjectValue < 0

            dObjectValue = 0;

            set(edtPSMALu177SPECTCTFullAISmallestVoiValue, 'String', num2str(dObjectValue));
        end

        machineLearningPSMALu177SmallestVoiValue('set', dObjectValue);

    end

    function chkPSMALu177SPECTCTFullAIPixelEdgeCallback(hObject, ~)  
                
        bObjectValue = get(chkPSMALu177SPECTCTFullAIPixelEdge, 'Value');
        
        if strcmpi(get(hObject, 'Style'), 'text')
            
            set(chkPSMALu177SPECTCTFullAIPixelEdge, 'Value', ~bObjectValue);
        end        
        
        bObjectValue = get(chkPSMALu177SPECTCTFullAIPixelEdge, 'Value');

        pixelEdge('set', bObjectValue);
        
        % Set contour panel checkbox

        set(chkPixelEdgePtr('get'), 'Value', pixelEdge('get'));
    end

    function cancelPSMALu177SPECTCTFullAISegmentationCallback(~, ~)   

        delete(dlgPSMALu177SPECTCTFullAISegmentation);
    end
    
    function proceedPSMALu177SPECTCTFullAISegmentationCallback(~, ~)

        % Options

        tPSMALu177SPECTCTFullAI.options.CELossTrainer        =            get(chkPSMALu177SPECTCTFullAICELoss, 'Value');
        tPSMALu177SPECTCTFullAI.options.classifySegmentation =            get(chkPSMALu177SPECTCTFullAIClassifySegmentation, 'Value');
        tPSMALu177SPECTCTFullAI.options.smoothMask           =            get(chkPSMALu177SPECTCTFullAISmoothMask, 'Value');
        tPSMALu177SPECTCTFullAI.options.smallestVoiValue     = str2double(get(edtPSMALu177SPECTCTFullAISmallestVoiValue , 'String'));
        tPSMALu177SPECTCTFullAI.options.pixelEdge            =            get(chkPSMALu177SPECTCTFullAIPixelEdge, 'Value');
        
        delete(dlgPSMALu177SPECTCTFullAISegmentation);

        setMachineLearningPSMALu177SPECTCTFullAI(sPredictScript, tPSMALu177SPECTCTFullAI); 
    end

end