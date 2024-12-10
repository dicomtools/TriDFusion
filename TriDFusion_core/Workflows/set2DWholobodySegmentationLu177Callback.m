function set2DWholobodySegmentationLu177Callback(~, ~)
%function set2DWholobodySegmentationLu177Callback()
%Run Lu177 Tumor Segmentation, The tool is called from the main menu.
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

    % atInput = inputTemplate('get');

    dSerieOffset = get(uiSeriesPtr('get'), 'Value');

    atMetaData = dicomMetaData('get', [], dSerieOffset);

    atRoi = roiTemplate('get', dSerieOffset);

    % dNbRoi = numel(atRoi);

    aImage = dicomBuffer('get', [], dSerieOffset);
                 
    asImageType = lower(atMetaData{1}.ImageType);  
   
    bWholeBody = false;
    if find(contains(asImageType, 'whole body')) 
        bWholeBody = true;
    end

    if bWholeBody == false
        progressBar(0, 'Error:set2DWholobodySegmentationLu177Callback()  Wholobody image not found!');
        msgbox('Error: set2DWholobodySegmentationLu177Callback(): Wholobody image not found!', 'Error');      
        return;
    end

    bLine1Offset  =0;
    bLine2Offset  =0;
 
    bLine1Detected = false;
    bLine2Detected = false;
    if ~isempty(atRoi)

        for jj=1:numel(atRoi)
            if strcmpi(atRoi{jj}.Type, 'images.roi.line')

                bLine1Detected = true;
                bLine1Offset = jj;

                  % Get the position of the line's endpoints
                linePos = atRoi{1}.Position;
                
                % Calculate the midpoint of the line
                midPoint = mean(linePos, 1); % Average the x and y coordinates separately
                
                % Get the image size
                [~, imgWidth, ~] = size(aImage);
                
                % Determine if the line is on the left or right side of the image
                if midPoint(1) < imgWidth / 2
                    bLIne1IsOntheLeft = true;
                else
                    bLIne1IsOntheLeft = false;
                end 
                break;
            end
        end

        if numel(atRoi) > 1

            if bLine1Detected == true
                for jj=1:numel(atRoi)
                    if jj == bLine1Offset
                        continue;
                    end
                          
                    if strcmpi(atRoi{jj}.Type, 'images.roi.line')
                        bLine2Detected = true;
                        bLine2Offset = jj;
            
                        % Get the position of the line's endpoints
                        linePos = atRoi{2}.Position;
                        
                        % Calculate the midpoint of the line
                        midPoint = mean(linePos, 1); % Average the x and y coordinates separately
                        
                        % Get the image size
                        [~, imgWidth, ~] = size(aImage);
                        
                        % Determine if the line is on the left or right side of the image
                        if midPoint(1) < imgWidth / 2
                            bLIne2IsOntheLeft = true;
                        else
                            bLIne2IsOntheLeft = false;
                        end                         
                    end
                end        
            end
   
        end
    end
    
    dEndloop = 1;
    if bLine2Detected == true 
        dEndloop = 2;
    end

    for jj=1:dEndloop

        if bLine1Detected == true  
    
            aArms = aImage;
            % Assuming 'img' is your grayscale image and 'hLine' is the line ROI
            [rows, cols] = size(aArms);
            
            if jj == 1
                % Get the line position
                linePos = atRoi{bLine1Offset}.Position;
            else
                 % Get the line position
                linePos = atRoi{bLine2Offset}.Position;              
            end
            
            % Compute the slope and intercept
            x1 = linePos(1,1); y1 = linePos(1,2);
            x2 = linePos(2,1); y2 = linePos(2,2);
            m = (y2 - y1) / (x2 - x1);
            b = y1 - m * x1;
            
            % Generate X and Y coordinate matrices
            [X, Y] = meshgrid(1:cols, 1:rows);
            
            % Determine the pixels to the right of the line
            % This might need to be adjusted based on the orientation of the line
            
            if jj == 1
                if bLIne1IsOntheLeft == true
                    % Set pixels to the right of the line to black
                    onRight = Y > (m * X + b);
                    aArms(onRight) = 0;
                    sLabel = 'Right Arm';
               else
                    % Set pixels to the right of the line to black
                    onLeft = Y <= (m * X + b);
                    aArms(~onLeft) = 0;            
                    sLabel = 'Left Arm';
                end
            else
                if bLIne2IsOntheLeft == true
                    % Set pixels to the right of the line to black
                    onRight = Y > (m * X + b);
                    aArms(onRight) = 0;
                    sLabel = 'Right Arm';
               else
                    % Set pixels to the right of the line to black
                    onLeft = Y <= (m * X + b);
                    aArms(~onLeft) = 0;            
                    sLabel = 'Left Arm';
                end                
            end

            B = bwboundaries(aArms,  4, 'noholes');
    
            % Initialize variables to keep track of the largest boundary
            adArm = [];
            adArmSize = 0;
            
            % Iterate through all the boundaries found
            for i = 1:length(B)
                currentBoundary = B{i}; % Get the current boundary
                currentSize = size(currentBoundary, 1); % The number of points in the current boundary
                
                % If this boundary is larger than the largest found so far, update the largest
                if currentSize > adArmSize
                    adArmSize = currentSize;
                    adArm = currentBoundary;
                end
            end
    
            if jj == 1
                aColor = [1 1 0];
            else    
                aColor = [1 0.5 0];
            end

            curentMask = adArm;
    
            sTag = num2str(randi([-(2^52/2),(2^52/2)],1));
        
            aPosition = flip(curentMask, 2);
        
            pRoi = images.roi.Freehand(axePtr('get', [], dSerieOffset), ...
                                       'Smoothing'     , 1, ...
                                       'Position'      , aPosition, ...
                                       'Color'         , aColor, ...
                                       'LineWidth'     , 1, ...
                                       'Label'         , sLabel, ...
                                       'LabelVisible'  , 'off', ...
                                       'Tag'           , sTag, ...
                                       'Visible'       , 'off', ...
                                       'FaceSelectable', 0, ...
                                       'FaceAlpha'     , roiFaceAlphaValue('get') ...
                                       );
            
            if ~isempty(pRoi.Waypoints(:))
     
                pRoi.Waypoints(:) = false;
            end
        
            addRoi(pRoi, dSerieOffset, 'Unspecified');

            addRoiMenu(pRoi);

            % addlistener(pRoi, 'WaypointAdded'  , @waypointEvents);
            % addlistener(pRoi, 'WaypointRemoved', @waypointEvents); 

            % roiDefaultMenu(pRoi);
            % 
            % uimenu(pRoi.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData', pRoi, 'Callback', @hideViewFaceAlhaCallback);
            % uimenu(pRoi.UIContextMenu,'Label', 'Clear Waypoints'     , 'UserData', pRoi, 'Callback', @clearWaypointsCallback);
            % 
            % constraintMenu(pRoi);
            % 
            % cropMenu(pRoi);
            % 
            % uimenu(pRoi.UIContextMenu,'Label', 'Display Statistics ' , 'UserData',pRoi, 'Callback',@figRoiDialogCallback, 'Separator', 'on');
            % 
            clear aArms;
        end
    end

%     aImage = imresize(aImage , PIXEL_EDGE_RATIO, 'nearest'); % do not go directly through pixel centers

    B = bwboundaries(aImage,  4, 'noholes');

    % Initialize variables to keep track of the largest and second largest boundaries
    adWholebody = [];
    adSource = [];

    adWholebodySize = 0;
    adSourceSize = 0;
    
    % Iterate through all the boundaries found
    for i = 1:length(B)
        currentBoundary = B{i}; % Get the current boundary
        currentSize = size(currentBoundary, 1); % The number of points in the current boundary
        
        % Check if this boundary is the largest found so far
        if currentSize > adWholebodySize
            % Move the current largest to second largest
            adSourceSize = adWholebodySize;
            adSource = adWholebody;
            
            % Update the largest
            adWholebodySize = currentSize;
            adWholebody = currentBoundary;
        elseif currentSize > adSourceSize
            % Update the second largest
            adSourceSize = currentSize;
            adSource = currentBoundary;
        end
    end

%    adWholebody = (adWholebody + 1) / PIXEL_EDGE_RATIO;
%    adWholebody = reducepoly(adWholebody);    
% 
%    adSource = (adSource + 1) / PIXEL_EDGE_RATIO;
%    adSource = reducepoly(adSource);    

    for jj=1:2
        
        if jj==1
            aColor = [1 0 1];
            curentMask = adWholebody;
            sLabel = 'Wholebody';
        else
            aColor = [1 0 0];
            curentMask = adSource;
            sLabel = 'Source';
        end   
    
        sTag = num2str(randi([-(2^52/2),(2^52/2)],1));
    
        aPosition = flip(curentMask, 2);
    
        pRoi = images.roi.Freehand(axePtr('get', [], dSerieOffset), ...
                                   'Smoothing'     , 1, ...
                                   'Position'      , aPosition, ...
                                   'Color'         , aColor, ...
                                   'LineWidth'     , 1, ...
                                   'Label'         , sLabel, ...
                                   'LabelVisible'  , 'off', ...
                                   'Tag'           , sTag, ...
                                   'Visible'       , 'off', ...
                                   'FaceSelectable', 0, ...
                                   'FaceAlpha'     , roiFaceAlphaValue('get') ...
                                   );
        
        if ~isempty(pRoi.Waypoints(:))

            pRoi.Waypoints(:) = false;
        end
    
        addRoi(pRoi, dSerieOffset, 'Unspecified');

        addRoiMenu(pRoi);

        % addlistener(pRoi, 'WaypointAdded'  , @waypointEvents);
        % addlistener(pRoi, 'WaypointRemoved', @waypointEvents); 

        % roiDefaultMenu(pRoi);
        % 
        % uimenu(pRoi.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData', pRoi, 'Callback', @hideViewFaceAlhaCallback);
        % uimenu(pRoi.UIContextMenu,'Label', 'Clear Waypoints'     , 'UserData', pRoi, 'Callback', @clearWaypointsCallback);
        % 
        % constraintMenu(pRoi);
        % 
        % cropMenu(pRoi);
        % 
        % uimenu(pRoi.UIContextMenu,'Label', 'Display Statistics ' , 'UserData',pRoi, 'Callback',@figRoiDialogCallback, 'Separator', 'on');
    end

    atRoiInput = roiTemplate('get', dSerieOffset);

    refreshImages();

    if numel(get(uiSeriesPtr('get'), 'String')) >= dSerieOffset+1

        for jj=1:numel(atRoiInput) % Copy ROIs to the POST

            if strcmpi(atRoiInput{jj}.Type, 'images.roi.line')
                continue;
            end

            copyRoiVoiToSerie(dSerieOffset, dSerieOffset+1, atRoiInput{jj}, 1);
        end
    end

    if 0
    % exportResultToExcel

    if ~isempty(atRoiInput)

        filter = {'*.csv'};
 %       info = dicomMetaData('get', [], get(uiSeriesPtr('get'), 'Value'));

        sCurrentDir  = viewerRootPath('get');

        sMatFile = [sCurrentDir '/' 'lastRoiDir.mat'];
        % load last data directory
        if exist(sMatFile, 'file')
                        % lastDirMat mat file exists, load it
            load('-mat', sMatFile);
            if exist('saveRoiLastUsedDir', 'var')
               sCurrentDir = saveRoiLastUsedDir;
            end
            if sCurrentDir == 0
                sCurrentDir = pwd;
            end
        end
        
%            sDate = sprintf('%s', datetime('now','Format','MMMM-d-y-hhmmss'));

        sSeriesDate = atMetaData{1}.SeriesDate;
        
        if isempty(sSeriesDate)
            sSeriesDate = '-';
        else
            sSeriesDate = datetime(sSeriesDate,'InputFormat','yyyyMMdd');
        end

        [file, path] = uiputfile(filter, 'Save ROI/VOI result', sprintf('%s/%s_%s_%s_%s_CONTOURS_TriDFusion.csv' , ...
            sCurrentDir, cleanString(atMetaData{1}.PatientName), cleanString(atMetaData{1}.PatientID), cleanString(atMetaData{1}.SeriesDescription), sSeriesDate) );

        if file ~= 0

%                 try
% 
%                 set(figRoiWindow, 'Pointer', 'watch');
%                 drawnow;

            try
                saveRoiLastUsedDir = [path '/'];
                save(sMatFile, 'saveRoiLastUsedDir');
            catch
                progressBar(1 , sprintf('Warning: Cant save file %s', sMatFile));
%                    h = msgbox(sprintf('Warning: Cant save file %s', sMatFile), 'Warning');
%                    if integrateToBrowser('get') == true
%                        sLogo = './TriDFusion/logo.png';
%                    else
%                        sLogo = './logo.png';
%                    end

%                    javaFrame = get(h, 'JavaFrame');
%                    javaFrame.setFigureIcon(javax.swing.ImageIcon(sLogo));
            end

            if exist(sprintf('%s%s', path, file), 'file')
                delete(sprintf('%s%s', path, file));
            end
        
            dNbSeries = 1;
            if numel(get(uiSeriesPtr('get'), 'String')) >= dSerieOffset+1
                dNbSeries = 2;
            end

            for jj=1: dNbSeries

                if jj==2
                    dSerieOffset = dSerieOffset+1;
                end
                
                atRoiInput = roiTemplate('get', dSerieOffset);
                atMetaData = dicomMetaData('get', [], dSerieOffset);
                if isempty(atMetaData)
                    atMetaData = atInput(dSerieOffset).atDicomInfo;
                end

    
                % Count number of elements
    
                dNumberOfLines = 1;
    
                for bb=1:numel(atRoiInput) % Scan ROI
                    if ~strcmpi(atRoiInput{bb}.Type, 'images.roi.line') % Found a ROI
    
                        dNumberOfLines = dNumberOfLines+1;
                    end
                end
    
                sUnits = 'Counts';
       
                asVoiRoiHeader{1} = sprintf('Patient Name, %s'      , cleanString(atMetaData{1}.PatientName, '_'));
                asVoiRoiHeader{2} = sprintf('Patient ID, %s'        , atMetaData{1}.PatientID);
                asVoiRoiHeader{3} = sprintf('Series Description, %s', cleanString(atMetaData{1}.SeriesDescription, '_'));
                asVoiRoiHeader{4} = sprintf('Accession Number, %s'  , atMetaData{1}.AccessionNumber);
                asVoiRoiHeader{5} = sprintf('Series Date, %s'       , atMetaData{1}.SeriesDate);
                asVoiRoiHeader{6} = sprintf('Series Time, %s'       , atMetaData{1}.SeriesTime);
                asVoiRoiHeader{7} = sprintf('Unit, %s'              , sUnits);
                asVoiRoiHeader{8} = (' ');
    
                dNumberOfLines = dNumberOfLines + numel(asVoiRoiHeader); % Add header and cell description to number of needed lines
    
                asCell = cell(dNumberOfLines, 15); % Create an empty cell array
    
                dLineOffset = 1;
                for ll=1:numel(asVoiRoiHeader)
    
                    asCell{dLineOffset,1}  = asVoiRoiHeader{ll};
                    for tt=2:21
                        asCell{dLineOffset,tt}  = (' ');
                    end
    
                    dLineOffset = dLineOffset+1;
                end
    
                asCell{dLineOffset,1}  = 'Name';
                asCell{dLineOffset,2}  = 'Nb Cells';
                asCell{dLineOffset,3}  = 'Total';
                asCell{dLineOffset,4}  = 'Sum';
                asCell{dLineOffset,5}  = 'Mean';
                asCell{dLineOffset,6}  = 'Min';
                asCell{dLineOffset,7}  = 'Max';
                asCell{dLineOffset,8}  = 'Median';
                asCell{dLineOffset,9}  = 'Deviation';
                asCell{dLineOffset,10} = 'Peak';
                asCell{dLineOffset,11} = 'Max Diameter (mm)';
                asCell{dLineOffset,12} = 'Max SAD (mm)';
                asCell{dLineOffset,13} = 'Area (cm2)';
                for tt=14:21
                    asCell{dLineOffset,tt}  = (' ');
                end
    
                dLineOffset = dLineOffset+1;
    
                dNbRois = numel(atRoiInput);
                for bb=1:dNbRois % Scan ROIs
                    if ~strcmpi(atRoiInput{bb}.Type, 'images.roi.line')
    
                        mask = roiTemplateToMask(atRoiInput{bb}, aImage);      
                        imCData = double(aImage(mask));
    
                        tRoiComputed.min    = min(imCData,[],'all');
                        tRoiComputed.max    = max(imCData,[],'all');
                        tRoiComputed.mean   = mean(imCData, 'all');
                        tRoiComputed.median = median(imCData, 'all');
                        tRoiComputed.std    = std(imCData,[],'all');
                        tRoiComputed.peak   = computePeak(imCData);
                        tRoiComputed.cells = numel(imCData);
    
                        nbVoxels  = tRoiComputed.cells;
                        volMean   = tRoiComputed.mean; 
    
                        xPixel = atMetaData{1}.PixelSpacing(1)/10;
                        yPixel = atMetaData{1}.PixelSpacing(2)/10;
                        voxVolume = xPixel * yPixel;
    
                        tRoiComputed.total = voxVolume * nbVoxels * volMean;
    
                        tRoiComputed.sum = sum(imCData, 'all');
    
                        tRoiComputed.area = nbVoxels * xPixel * yPixel;
               
                        tRoiComputed.MaxDistances = atRoiInput{bb}.MaxDistances;
    
                        sRoiName = atRoiInput{bb}.Label;
    
                        asCell{dLineOffset, 1}  = (sRoiName);
                        asCell{dLineOffset, 2}  = [tRoiComputed.cells];
                        asCell{dLineOffset, 3}  = [tRoiComputed.total];
                        asCell{dLineOffset, 4}  = [tRoiComputed.sum];
                        asCell{dLineOffset, 5}  = [tRoiComputed.mean];
                        asCell{dLineOffset, 6}  = [tRoiComputed.min];
                        asCell{dLineOffset, 7}  = [tRoiComputed.max];
                        asCell{dLineOffset, 8}  = [tRoiComputed.median];
                        asCell{dLineOffset, 9} = [tRoiComputed.std];
                        asCell{dLineOffset, 10} = [tRoiComputed.peak];
                        if ~isempty(tRoiComputed.MaxDistances)
                            if tRoiComputed.MaxDistances.MaxXY.Length == 0
                                asCell{dLineOffset, 11} = ('NaN');
                            else
                                asCell{dLineOffset, 11} = [tRoiComputed.MaxDistances.MaxXY.Length];
                            end
    
                            if tRoiComputed.MaxDistances.MaxCY.Length == 0
                                asCell{dLineOffset, 12} = ('NaN');
                            else
                                asCell{dLineOffset, 12} = [tRoiComputed.MaxDistances.MaxCY.Length];
                            end
                        else
                            asCell{dLineOffset, 11} = (' ');
                            asCell{dLineOffset, 12} = (' ');
                        end
                        asCell{dLineOffset, 13} = tRoiComputed.area;
                        asCell{dLineOffset, 14} = (' ');
                        
                        for tt=15:21
                            asCell{dLineOffset,tt}  = (' ');
                        end
    
                        dLineOffset = dLineOffset+1;
    
                    end
    
                end
               
                if jj==1
                    sSheet = 'ANT';
                else
                    sSheet = 'POST';
                end

                writecell(asCell, sprintf('%s%s.xlsx', path, file), 'Sheet', sSheet);
            end

            try
                saveRoiLastUsedDir = path;
                save(sMatFile, 'saveRoiLastUsedDir');
            catch
                    progressBar(1 , sprintf('Warning: Cant save file %s', sMatFile));
%                        h = msgbox(sprintf('Warning: Cant save file %s', sMatFile), 'Warning');
%                        if integrateToBrowser('get') == true
%                            sLogo = './TriDFusion/logo.png';
%                        else
%                            sLogo = './logo.png';
%                        end

%                        javaFrame = get(h, 'JavaFrame');
%                        javaFrame.setFigureIcon(javax.swing.ImageIcon(sLogo));
            end

            progressBar(1, sprintf('Write %s%s completed', path, file));
% 
%                 catch
%                     progressBar(1, 'Error: exportCurrentSeriesResultCallback()');
%                 end
% 
%                 set(figRoiWindow, 'Pointer', 'default');
%                 drawnow;
        end
    end
    end

    clear aImage;

end