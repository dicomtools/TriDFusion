function setSegmentationFDGPercentCallback(~, ~)
%function setSegmentationFDGPercentCallback()
%Run FDG Tumor Segmentation, The tool is called from the main menu.
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

        DLG_FDG_BOUNDARY_PERCENT_X = 380;
        DLG_FDG_BOUNDARY_PERCENT_Y = 110;
    
        dlgPercentFDGSegmentation = ...
            dialog('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-DLG_FDG_BOUNDARY_PERCENT_X/2) ...
                                (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-DLG_FDG_BOUNDARY_PERCENT_Y/2) ...
                                DLG_FDG_BOUNDARY_PERCENT_X ...
                                DLG_FDG_BOUNDARY_PERCENT_Y ...
                                ],...
                   'MenuBar', 'none',...
                   'Resize', 'off', ...    
                   'NumberTitle','off',...
                   'MenuBar', 'none',...
                   'Color', viewerBackgroundColor('get'), ...
                   'Name', 'Ga68 DOTATATE Segmentation Mean and SD',...
                   'Toolbar','none'...               
                   ); 


            % Normal Liver Standard Deviation
    
            uicontrol(dlgPercentFDGSegmentation,...
                      'style'   , 'text',...
                      'Enable'  , 'On',...
                      'string'  , 'Boundary percent of max',...
                      'horizontalalignment', 'left',...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...                   
                      'position', [20 62 250 20]...
                      );
    
        edtBoundaryPercentOfMaxValue = ...
            uicontrol(dlgPercentFDGSegmentation, ...
                      'Style'   , 'Edit', ...
                      'Position', [285 65 75 20], ...
                      'String'  , num2str(FDGSegmentationBoundaryPercentValue('get')), ...
                      'Enable'  , 'on', ...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...
                      'CallBack', @edtBoundaryPercentOfMaxValueCallback ...
                      ); 

         % Cancel or Proceed
    
         uicontrol(dlgPercentFDGSegmentation,...
                   'String','Cancel',...
                   'Position',[285 7 75 25],...
                   'BackgroundColor', viewerBackgroundColor('get'), ...
                   'ForegroundColor', viewerForegroundColor('get'), ...                
                   'Callback', @cancelFDGSegmentationCallback...
                   );
    
         uicontrol(dlgPercentFDGSegmentation,...
                  'String','Continue',...
                  'Position',[200 7 75 25],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...               
                  'Callback', @proceedFDGSegmentationCallback...
                  );    

    function edtBoundaryPercentOfMaxValueCallback(~, ~)     

        dBoundaryPercent = str2double(get(edtBoundaryPercentOfMaxValue, 'String'));

        if dBoundaryPercent <= 0

            dBoundaryPercent = 10;
            set(edtBoundaryPercentOfMaxValue, 'String', num2str(dBoundaryPercent));

        elseif dBoundaryPercent >= 100
            
            dBoundaryPercent = 10;
            set(edtBoundaryPercentOfMaxValue, 'String', num2str(dBoundaryPercent));           
        end

        FDGSegmentationBoundaryPercentValue('set', dBoundaryPercent);

    end

    function cancelFDGSegmentationCallback(~, ~)   

        delete(dlgPercentFDGSegmentation);
    end
    
    function proceedFDGSegmentationCallback(~, ~)

        dBoundaryPercent = str2double(get(edtBoundaryPercentOfMaxValue, 'String'))/100;

        delete(dlgPercentFDGSegmentation);

        setSegmentationFDGPercent(dBoundaryPercent, 41, 65); % Percent of peak
    end

end