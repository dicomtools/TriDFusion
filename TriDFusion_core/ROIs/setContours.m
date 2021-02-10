function setContours()
%function setContours()
%Set Contours to Input Template.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Note: option settings must fit on one line and can contain one semicolon at most.
%Options can be strings, cell arrays of strings, or numerical arrays.
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

    atInput    = inputTemplate('get');
    atContours = inputContours('get');
     
    bNbContours = 0;
    bMultipleSeries = false;
    
    dSeriesValue = get(uiSeriesPtr('get'), 'Value');
   
    if isempty(atContours)
        return;
    end
        
    for bb=1:numel(atInput)
        
        for cc=1:numel(atContours)
            
            for dd=1:numel(atContours{cc})
                
                if strcmpi(atInput(bb).atDicomInfo{1}.SeriesInstanceUID, ... % Find matching series
                           atContours{cc}(dd).Referenced.SeriesInstanceUID)
                       
                    hold on;                        
                       
                    bNbContours = bNbContours+1;
                    
                    if dSeriesValue ~= bb
                        bMultipleSeries = true;

                        set(uiSeriesPtr('get'), 'Value', bb);
                        setSeriesCallback();
                    end
                    
                    set(uiCorWindowPtr('get'), 'Visible', 'off');
                    set(uiSagWindowPtr('get'), 'Visible', 'off');
                    set(uiTraWindowPtr('get'), 'Visible', 'off');

                    set(uiSliderLevelPtr ('get'), 'Visible', 'off');
                    set(uiSliderWindowPtr('get'), 'Visible', 'off');

                    set(uiSliderCorPtr('get'), 'Visible', 'off');
                    set(uiSliderSagPtr('get'), 'Visible', 'off');   
                    set(uiSliderTraPtr('get'), 'Visible', 'off'); 
                    
                    segments = atContours{cc}(dd).ContourData;   
                    
                    xfm = getAffineXfm(atInput(bb).atDicomInfo);
                                        
                    asTag = [];
                                        
                    for j=1:numel(segments)
                        
                        progressBar( j/numel(segments), sprintf('Processing Contour ROI %d/%d', j, numel(segments)) );      
                        
                        out = pctransform(pointCloud(segments{j}),invert(affine3d(xfm')));

                        points{j} = [abs(out.Location(:,1)) abs(out.Location(:,2))] ;
                        z = round(abs(out.Location(:,3)));   % Axial                    
                        
                        ROI.Position = [points{j}(:,1), points{j}(:,2)];
                                                                                                
                        sliceNumber('set', 'axial', z(1)+1);

                        sTag   = num2str(rand);
                        axRoi  = axes3Ptr('get');
                        aColor = [atContours{cc}(dd).Color(1)/255 atContours{cc}(dd).Color(2)/255 atContours{cc}(dd).Color(3)/255];
                        sLabel = atContours{cc}(dd).ROIName;
                        
                        pRoi = drawfreehand(axRoi, 'Position', ROI.Position, 'Color', aColor, 'LineWidth', 1, 'Label', '', 'LabelVisible', 'off', 'Tag', sTag, 'Visible', 'off');    
                        
                        gca = axes3Ptr('get');
                                            
                        addRoi(pRoi);                  

                        roiDefaultMenu(pRoi);

                        uimenu(pRoi.UIContextMenu,'Label', 'Clear Waypoints' , 'UserData', pRoi, 'Callback', @clearWaypointsCallback); 

                        cropMenu(pRoi);

                        uimenu(pRoi.UIContextMenu,'Label', 'Display Result' , 'UserData', pRoi, 'Callback', @figRoiDialogCallback, 'Separator', 'on'); 

                        set(fiMainWindowPtr('get'), 'WindowScrollWheelFcn' , @wheelScroll);

                        asTag{numel(asTag)+1} = sTag;                        
                    end

                    if ~isempty(asTag)
                        createVoiFromRois(asTag, sLabel);
                    end            
               
                end
            end
        end
    end
    
    if bMultipleSeries == true
        set(uiSeriesPtr('get'), 'Value', dSeriesValue);
        setSeriesCallback();
    end    
    
    if bNbContours ~= 0
        
        set(uiCorWindowPtr('get'), 'Visible', 'on');
        set(uiSagWindowPtr('get'), 'Visible', 'on');
        set(uiTraWindowPtr('get'), 'Visible', 'on');

        set(uiSliderLevelPtr ('get'), 'Visible', 'on');
        set(uiSliderWindowPtr('get'), 'Visible', 'on');

        set(uiSliderCorPtr('get'), 'Visible', 'on');
        set(uiSliderSagPtr('get'), 'Visible', 'on');   
        set(uiSliderTraPtr('get'), 'Visible', 'on');      

        hold off;
    
        refreshImages();
        
        progressBar( 1, 'Ready');      

    end
    
    % From Use DICOM RT for 3D Semantic Segmentation of Medical images
    % by Takuji Fukumoto
    function A = getAffineXfm(headers)
        % Constants
        N = length(headers);
        dr = headers{1}.PixelSpacing(1);
        dc = headers{1}.PixelSpacing(2);
        F(:,1) = headers{1}.ImageOrientationPatient(1:3);
        F(:,2) = headers{1}.ImageOrientationPatient(4:6);
        T1 = headers{1}.ImagePositionPatient;
        TN = headers{end}.ImagePositionPatient;
        k = (T1 - TN) ./ (1 - N);
        % Build affine transformation
        A = [[F(1,1)*dr F(1,2)*dc k(1) T1(1)]; ...
            [F(2,1)*dr F(2,2)*dc k(2) T1(2)]; ...
            [F(3,1)*dr F(3,2)*dc k(3) T1(3)]; ...
            [0         0         0    1    ]];
    end    

end 