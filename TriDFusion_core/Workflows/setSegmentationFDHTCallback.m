function setSegmentationFDHTCallback(~, ~)
%function setSegmentationFDHTCallback()
%Run FDHT Tumor Segmentation, The tool is called from the main menu.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2023, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    DLG_FDHT_PERCENT_X = 380;
    DLG_FDHT_PERCENT_Y = 160;

    dlgFDHTSegmentation = ...
        dialog('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-DLG_FDHT_PERCENT_X/2) ...
                            (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-DLG_FDHT_PERCENT_Y/2) ...
                            DLG_FDHT_PERCENT_X ...
                            DLG_FDHT_PERCENT_Y ...
                            ],...
               'MenuBar', 'none',...
               'Resize', 'off', ...    
               'NumberTitle','off',...
               'MenuBar', 'none',...
               'Color', viewerBackgroundColor('get'), ...
               'Name', 'FDHT Segmentation',...
               'Toolbar','none'...               
               ); 

%     % Boundary percent of max
% 
%         uicontrol(dlgFDHTSegmentation,...
%                   'style'   , 'text',...
%                   'Enable'  , 'On',...
%                   'string'  , 'Boundary percent of max',...
%                   'horizontalalignment', 'left',...
%                   'BackgroundColor', viewerBackgroundColor('get'), ...
%                   'ForegroundColor', viewerForegroundColor('get'), ...                   
%                   'position', [20 162 250 20]...
%                   );
% 
%     edtFDHTBoundaryPercentOfMaxValue = ...
%         uicontrol(dlgFDHTSegmentation, ...
%                   'Style'   , 'Edit', ...
%                   'Position', [285 165 75 20], ...
%                   'String'  , num2str(FDHTSegmentationBoundaryPercentValue('get')), ...
%                   'Enable'  , 'on', ...
%                   'BackgroundColor', viewerBackgroundColor('get'), ...
%                   'ForegroundColor', viewerForegroundColor('get'), ...
%                   'CallBack', @edtFDHTBoundaryPercentOfMaxValueCallback ...
%                   ); 

    % Bone mask threshold

        uicontrol(dlgFDHTSegmentation,...
                  'style'   , 'text',...
                  'Enable'  , 'On',...
                  'string'  , 'Bone mask threshold (HU)',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'position', [20 112 250 20]...
                  );

    edtFDHTBoneMaskThresholdValue = ...
        uicontrol(dlgFDHTSegmentation, ...
                  'Style'   , 'Edit', ...
                  'Position', [285 115 75 20], ...
                  'String'  , num2str(FDHTSegmentationBoneMaskThresholdValue('get')), ...
                  'Enable'  , 'on', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', @edtFDHTBoneMaskThresholdValueCallback ...
                  ); 
    % Smallest Contour (ml)

        uicontrol(dlgFDHTSegmentation,...
                  'style'   , 'text',...
                  'Enable'  , 'On',...
                  'string'  , 'Smallest Contour (ml)',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'position', [20 87 250 20]...
                  );

    edtFDHTSmalestVoiValue = ...
        uicontrol(dlgFDHTSegmentation, ...
                  'Style'   , 'Edit', ...
                  'Position', [285 90 75 20], ...
                  'String'  , num2str(FDHTSmalestVoiValue('get')), ...
                  'Enable'  , 'on', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'CallBack', @edtFDHTSmalestVoiValueCallback ...
                  );        

    % Pixel Edge

        uicontrol(dlgFDHTSegmentation,...
                  'style'   , 'text',...
                  'Enable'  , 'Inactive',...
                  'string'  , 'Pixel Edge',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'ButtonDownFcn'  , @chkFDHTPixelEdgeCallback, ...
                  'position', [40 62 150 20]...
                  );

    chkFDHTPixelEdge = ...
        uicontrol(dlgFDHTSegmentation,...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , pixelEdge('get'),...
                  'position', [20 65 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'Callback', @chkFDHTPixelEdgeCallback...
                  );

     % Cancel or Proceed

     uicontrol(dlgFDHTSegmentation,...
               'String','Cancel',...
               'Position',[285 7 75 25],...
               'BackgroundColor', viewerBackgroundColor('get'), ...
               'ForegroundColor', viewerForegroundColor('get'), ...                
               'Callback', @cancelFDHTSegmentationCallback...
               );

     uicontrol(dlgFDHTSegmentation,...
              'String','Continue',...
              'Position',[200 7 75 25],...
              'BackgroundColor', viewerBackgroundColor('get'), ...
              'ForegroundColor', viewerForegroundColor('get'), ...               
              'Callback', @proceedFDHTSegmentationCallback...
              );    

    function edtFDHTSmalestVoiValueCallback(~, ~)

        dObjectValue = str2double(get(edtFDHTSmalestVoiValue, 'String'));

        if dObjectValue < 0

            dObjectValue = 0;

            set(edtFDHTSmalestVoiValue, 'String', num2str(dObjectValue));
        end

        FDHTSmalestVoiValue('set', dObjectValue);

    end

    function chkFDHTPixelEdgeCallback(hObject, ~)  
                
        bObjectValue = get(chkFDHTPixelEdge, 'Value');
        
        if strcmpi(get(hObject, 'Style'), 'text')
            
            set(chkFDHTPixelEdge, 'Value', ~bObjectValue);
        end        
        
        bObjectValue = get(chkFDHTPixelEdge, 'Value');

        pixelEdge('set', bObjectValue);
        
        % Set contour panel checkbox
        set(chkPixelEdgePtr('get'), 'Value', pixelEdge('get'));
    end

%     function edtFDHTBoundaryPercentOfMaxValueCallback(~, ~)     
% 
%         dBoundaryPercent = str2double(get(edtFDHTBoundaryPercentOfMaxValue, 'String'));
% 
%         if dBoundaryPercent <= 0
% 
%             dBoundaryPercent = 10;
%             set(edtFDHTBoundaryPercentOfMaxValue, 'String', num2str(dBoundaryPercent));
% 
%         elseif dBoundaryPercent >= 100
%             
%             dBoundaryPercent = 10;
%             set(edtFDHTBoundaryPercentOfMaxValue, 'String', num2str(dBoundaryPercent));           
%         end
% 
%         FDHTSegmentationBoundaryPercentValue('set', dBoundaryPercent);
% 
%     end

    function edtFDHTBoneMaskThresholdValueCallback(~, ~)     

        dBoneMaskThreshold = str2double(get(edtFDHTBoneMaskThresholdValue, 'String'));

        if dBoneMaskThreshold <= 0

            dBoneMaskThreshold = 100;
            set(edtFDHTBoneMaskThresholdValue, 'String', num2str(dBoneMaskThreshold));        
        end

        FDHTSegmentationBoneMaskThresholdValue('set', dBoneMaskThreshold);

    end

    function cancelFDHTSegmentationCallback(~, ~)   

        delete(dlgFDHTSegmentation);
    end
    
    function proceedFDHTSegmentationCallback(~, ~)

        dSmalestVoiValue   = str2double(get(edtFDHTSmalestVoiValue, 'String'));
        dPixelEdge         = get(chkFDHTPixelEdge, 'value');
%         dBoundaryPercent   = str2double(get(edtFDHTBoundaryPercentOfMaxValue, 'String'))/100;
        dBoneMaskThreshold = str2double(get(edtFDHTBoneMaskThresholdValue, 'String'));

        delete(dlgFDHTSegmentation);

        setSegmentationFDHT(dBoneMaskThreshold, dSmalestVoiValue, dPixelEdge); 
    end

end