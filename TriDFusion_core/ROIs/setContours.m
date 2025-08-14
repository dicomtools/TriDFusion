function setContours(tContours, bInitDisplay)
%function setContours(tContours, bInitDisplay)
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

    atInput = inputTemplate('get');
    if exist('tContours','var')
         if ~exist('bInitDisplay','var')
            bInitDisplay = false;
         end
        atContours = tContours;
    else
        if ~exist('bInitDisplay','var')
            bInitDisplay = true;
        end
        atContours = inputContours('get');
    end

    bNbContours = 0;

    dSeriesValue = get(uiSeriesPtr('get'), 'Value');

    if isempty(atContours)
        return;
    end

    try

    set(fiMainWindowPtr('get'), 'Pointer', 'watch');
    drawnow limitrate;

    for bb=1:numel(atInput)

        if isempty(dicomBuffer('get', [], bb))
            aInputBuffer = inputBuffer('get');

            aImageSize = size(aInputBuffer{bb});

            clear aInputBuffer;
        else
            aImageSize = size(dicomBuffer('get', [], bb));
        end

        for cc=1:numel(atContours)

            for dd=1:numel(atContours{cc})

                if ~isempty(atContours{cc}(dd).Referenced)

                    if strcmpi(atInput(bb).atDicomInfo{1}.FrameOfReferenceUID, ... % Find matching series
                               atContours{cc}(dd).Referenced.FrameOfReferenceUID)

                        if strcmpi(atInput(bb).atDicomInfo{1}.SeriesInstanceUID, ... % Find matching series
                                   atContours{cc}(dd).Referenced.SeriesInstanceUID)

         %                   hold on;

                            bNbContours = bNbContours+1;

                   %         if dSeriesValue ~= bb

                   %             set(uiSeriesPtr('get'), 'Value', bb);
                   %             setSeriesCallback();
                   %         end

                            set(uiCorWindowPtr('get'), 'Visible', 'off');
                            set(uiSagWindowPtr('get'), 'Visible', 'off');
                            set(uiTraWindowPtr('get'), 'Visible', 'off');
                            set(uiMipWindowPtr('get'), 'Visible', 'off');

%                             set(uiSliderLevelPtr ('get'), 'Visible', 'off');
%                             set(uiSliderWindowPtr('get'), 'Visible', 'off');

                            set(lineColorbarIntensityMaxPtr('get'), 'Visible', 'off');
                            set(lineColorbarIntensityMinPtr('get'), 'Visible', 'off');

                            set(textColorbarIntensityMaxPtr('get'), 'Visible', 'off');
                            set(textColorbarIntensityMinPtr('get'), 'Visible', 'off');

                            set(uiSliderCorPtr('get'), 'Visible', 'off');
                            set(uiSliderSagPtr('get'), 'Visible', 'off');
                            set(uiSliderTraPtr('get'), 'Visible', 'off');
                            set(uiSliderMipPtr('get'), 'Visible', 'off');

                            segments = atContours{cc}(dd).ContourData;
                            if ~cellfun(@isempty,segments)

                    %            xfm = getAffineXfm(atInput(bb).atDicomInfo);

                                sliceThikness = computeSliceSpacing(atInput(bb).atDicomInfo);
                                if sliceThikness == 0 % We can't determine the z size of a pixel, we will presume the pixel is square.
                                    if atInput(bb).atDicomInfo{1}.PixelSpacing(1) ~= 0
                                        sliceThikness = atInput(bb).atDicomInfo{1}.PixelSpacing(1);
                                    else
                                        sliceThikness =1;
                                    end
                                end

                                [xfm,~] = TransformMatrix(atInput(bb).atDicomInfo{1}, sliceThikness, false);

                                asTag = cell(numel(segments), 1);

                                set(uiSeriesPtr('get'), 'Value', bb);

                                % drawnow;

                                progressBar( bNbContours/numel(atContours{cc})-0.0001, sprintf('Volume %d: Processing contour %d/%d', bb, bNbContours, numel(atContours{cc}) ));

                                points = cell(numel(segments), 1);
                                for j=1:numel(segments)

                                    a3DOffset = segments{j};
                                    [outX, outY, outZ] = transformPointsForward(invert(affine3d(xfm')), a3DOffset(:,1), a3DOffset(:,2), a3DOffset(:,3));
                                    points{j} = [abs(outX(:)) abs(outY(:))] ;
                                    z = round(abs(outZ(:)));   % Axial

%                                    out = pctransform(pointCloud(segments{j}),invert(affine3d(xfm')));

%                                    points{j} = [abs(out.Location(:,1)) abs(out.Location(:,2))] ;
%                                    z = round(abs(out.Location(:,3)));   % Axial

                                    ROI.Position = [points{j}(:,1)+1, points{j}(:,2)+1];

                                    bFlip = getImagePosition(bb);
                                    if bFlip == true

                                        try
                                            dSliceNb =  aImageSize(3)-z(1);
                                        catch ME
                                            logErrorToFile(ME);  
                                            dSliceNb =  z(1)+1;
                                        end
                        %                sliceNumber('set', 'axial', dSliceNb);

                                    else
                                        dSliceNb =  z(1)+1;
                        %                sliceNumber('set', 'axial', dSliceNb);
                                    end

                                    sTag   = num2str(generateUniqueNumber(false));
    %                                axRoi  = axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value'));
                                    
                                    rawColor = atContours{cc}(dd).Color;

                                    if isnumeric(rawColor) && numel(rawColor) == 3
                                        aColor = rawColor(:)' / 255;
                                    else
                                        % Set default color to cyan [0 1 1]
                                        aColor = [0 1 1];
                                    end
                                    % aColor = [atContours{cc}(dd).Color(1)/255 atContours{cc}(dd).Color(2)/255 atContours{cc}(dd).Color(3)/255];
                                    
                                    sLabel = atContours{cc}(dd).ROIName;

    %                                pRoi = drawfreehand(axRoi, 'Smoothing', 1, 'Position', ROI.Position, 'Color', aColor, 'LineWidth', 1, 'Label', sLabel, 'LabelVisible', 'off', 'Tag', sTag, 'Visible', 'off', 'FaceSelectable', 0, 'FaceAlpha', 0);
    %                                pRoi.Waypoints(:) = false;

                                    sLesionType = 'Unspecified';

                                    [~, asLesionType, asLesionShortName] = getLesionType('');
                                    for jj=1:numel(asLesionShortName)
                                        if contains(sLabel, asLesionShortName{jj})
                                            sLesionType = asLesionType{jj};
                                            break;
                                        end
                                    end

                                    addContourToTemplate(bb, 'Axes3', dSliceNb, 'images.roi.freehand', ROI.Position, sLabel, 'off', aColor, 1, roiFaceAlphaValue('get'), 0, 1, sTag, sLesionType);

    %                                addRoi(pRoi, bb);

    %                                roiDefaultMenu(pRoi);

    %                                uimenu(pRoi.UIContextMenu,'Label', 'Hide/View Face Alpha', 'UserData', pRoi, 'Callback', @hideViewFaceAlhaCallback);
    %                                uimenu(pRoi.UIContextMenu,'Label', 'Clear Waypoints' , 'UserData', pRoi, 'Callback', @clearWaypointsCallback);

    %                                constraintMenu(pRoi);

    %                                cropMenu(pRoi);

    %                                uimenu(pRoi.UIContextMenu,'Label', 'Display Statistics ' , 'UserData', pRoi, 'Callback', @figRoiDialogCallback, 'Separator', 'on');

             %                       set(fiMainWindowPtr('get'), 'WindowScrollWheelFcn' , @wheelScroll);

%                                     asTag{numel(asTag)+1} = sTag;
                                     asTag{j} = sTag;

                                end

                                if ~isempty(asTag)

                                    createVoiFromRois(bb, asTag, sLabel, aColor, sLesionType);
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    if bInitDisplay == true

        set(uiSeriesPtr('get'), 'Value', dSeriesValue);

        setSeriesCallback();

        if bNbContours ~= 0 && ~exist('tContours','var')

            set(uiCorWindowPtr('get'), 'Visible', 'on');
            set(uiSagWindowPtr('get'), 'Visible', 'on');
            set(uiTraWindowPtr('get'), 'Visible', 'on');
            set(uiMipWindowPtr('get'), 'Visible', 'on');

%             set(uiSliderLevelPtr ('get'), 'Visible', 'on');
%             set(uiSliderWindowPtr('get'), 'Visible', 'on');

            set(lineColorbarIntensityMaxPtr('get'), 'Visible', 'on');
            set(lineColorbarIntensityMinPtr('get'), 'Visible', 'on');

            set(textColorbarIntensityMaxPtr('get'), 'Visible', 'on');
            set(textColorbarIntensityMinPtr('get'), 'Visible', 'on');

            set(uiSliderCorPtr('get'), 'Visible', 'on');
            set(uiSliderSagPtr('get'), 'Visible', 'on');
            set(uiSliderTraPtr('get'), 'Visible', 'on');
            set(uiSliderMipPtr('get'), 'Visible', 'on');

    %        hold off;
            setVoiRoiSegPopup();

            refreshImages();

            progressBar( 1, 'Ready');

        end
    end

    catch ME
       logErrorToFile(ME);  
       progressBar(1, 'Error:setContours()');
   end

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow limitrate;

%    % From Use DICOM RT for 3D Semantic Segmentation of Medical images
%    % by Takuji Fukumoto
%    function A = getAffineXfm(headers)
%        % Constants
%        if length(headers) == 1 % Some NM series
%            N =  headers{1}.NumberOfSlices;
%        else
%            N = length(headers);
%        end
%        dr = headers{1}.PixelSpacing(1);
%        dc = headers{1}.PixelSpacing(2);
%        F(:,1) = headers{1}.ImageOrientationPatient(1:3);
%        F(:,2) = headers{1}.ImageOrientationPatient(4:6);
%        T1 = headers{1}.ImagePositionPatient;
%        TN = headers{end}.ImagePositionPatient;
%        k = (T1 - TN) ./ (1 - N);
%        % Build affine transformation
%        A = [[F(1,1)*dr F(1,2)*dc k(1) T1(1)]; ...
%            [F(2,1)*dr F(2,2)*dc k(2) T1(2)]; ...
%            [F(3,1)*dr F(3,2)*dc k(3) T1(3)]; ...
%            [0         0         0    1    ]];
%    end

end
