function initRoi()
%function initRoi()
%Init ROIs Main Function.
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

    tInitInput = inputTemplate('get');        
    iOffset = get(uiSeriesPtr('get'), 'Value');
    if iOffset > numel(tInitInput)  
        return;
    end

    if isfield(tInitInput(iOffset), 'tRoi')

        for bb=1:numel(tInitInput(iOffset).tRoi)
            
            progressBar(bb/numel(tInitInput(iOffset).tRoi), sprintf('processing ROI %d/%d', bb, numel(tInitInput(iOffset).tRoi)));

            if     strcmpi(tInitInput(iOffset).tRoi{bb}.Axe, 'axes1')
                axRoi = axes1Ptr('get');
            elseif strcmpi(tInitInput(iOffset).tRoi{bb}.Axe, 'axes2')
                axRoi = axes2Ptr('get');
            elseif strcmpi(tInitInput(iOffset).tRoi{bb}.Axe, 'axes3')
                axRoi = axes3Ptr('get');
            elseif strcmpi(tInitInput(iOffset).tRoi{bb}.Axe, 'axe')
                axRoi = axePtr('get');
            else
                return;

            end

            set(fiMainWindowPtr('get'),'CurrentAxes',axRoi)

            switch lower(tInitInput(iOffset).tRoi{bb}.Type)
                case lower('images.roi.line')

                    roiPtr = drawline(axRoi, ...
                                      'Position'    , tInitInput(iOffset).tRoi{bb}.Position, ...
                                      'Color'       , tInitInput(iOffset).tRoi{bb}.Color, ...
                                      'LineWidth'   , tInitInput(iOffset).tRoi{bb}.LineWidth, ...
                                      'Label'       , tInitInput(iOffset).tRoi{bb}.Label, ...
                                      'LabelVisible', tInitInput(iOffset).tRoi{bb}.LabelVisible, ...
                                      'Tag'         , tInitInput(iOffset).tRoi{bb}.Tag);  

                    uimenu(roiPtr.UIContextMenu,'Label', 'Snap To Circles', 'UserData',roiPtr, 'Callback',@snapLinesToCirclesCallback); 
                    uimenu(roiPtr.UIContextMenu,'Label', 'Snap To Rectangles', 'UserData',roiPtr, 'Callback',@snapLinesToRectanglesCallback); 

                    uimenu(roiPtr.UIContextMenu,'Label', 'Edit Label'     , 'UserData',roiPtr, 'Callback',@editLabelCallback, 'Separator', 'on');         
                    uimenu(roiPtr.UIContextMenu,'Label', 'Hide/View Label', 'UserData',roiPtr, 'Callback',@hideViewLabelCallback); 
                    uimenu(roiPtr.UIContextMenu,'Label', 'Edit Color'     , 'UserData',roiPtr, 'Callback',@editColorCallback);

                    cropMenu(roiPtr);  

                    uimenu(roiPtr.UIContextMenu,'Label', 'Display Result' , 'UserData',roiPtr, 'Callback',@figRoiDialogCallback, 'Separator', 'on'); 


                case lower('images.roi.freehand')

                    roiPtr = drawfreehand(axRoi, ...
                                          'Position'    , tInitInput(iOffset).tRoi{bb}.Position, ...
                                          'Waypoints'   , tInitInput(iOffset).tRoi{bb}.Waypoints, ...
                                          'Color'       , tInitInput(iOffset).tRoi{bb}.Color, ...
                                          'FaceAlpha'   , tInitInput(iOffset).tRoi{bb}.FaceAlpha, ...
                                          'LineWidth'   , tInitInput(iOffset).tRoi{bb}.LineWidth, ...
                                          'Label'       , tInitInput(iOffset).tRoi{bb}.Label, ...
                                          'LabelVisible', tInitInput(iOffset).tRoi{bb}.LabelVisible, ...
                                          'Tag'         , tInitInput(iOffset).tRoi{bb}.Tag);  

                    roiDefaultMenu(roiPtr);

                    uimenu(roiPtr.UIContextMenu,'Label', 'Clear Waypoints' , 'UserData',roiPtr, 'Callback',@clearWaypointsCallback); 

                    cropMenu(roiPtr);   

                    uimenu(roiPtr.UIContextMenu,'Label', 'Display Result' , 'UserData',roiPtr, 'Callback',@figRoiDialogCallback, 'Separator', 'on'); 

                    addlistener(roiPtr, 'WaypointAdded'  , @waypointEvents);
                    addlistener(roiPtr, 'WaypointRemoved', @waypointEvents);

                case lower('images.roi.assistedfreehand')

                    roiPtr = drawassisted(axRoi, ...
                                          'Position'    , tInitInput(iOffset).tRoi{bb}.Position, ...
                                          'Waypoints'   , tInitInput(iOffset).tRoi{bb}.Waypoints, ...
                                          'Color'       , tInitInput(iOffset).tRoi{bb}.Color, ...
                                          'FaceAlpha'   , tInitInput(iOffset).tRoi{bb}.FaceAlpha, ...
                                          'LineWidth'   , tInitInput(iOffset).tRoi{bb}.LineWidth, ...
                                          'Label'       , tInitInput(iOffset).tRoi{bb}.Label, ...
                                          'LabelVisible', tInitInput(iOffset).tRoi{bb}.LabelVisible, ...
                                          'Tag'         , tInitInput(iOffset).tRoi{bb}.Tag);  

                    roiDefaultMenu(roiPtr);

                    uimenu(roiPtr.UIContextMenu,'Label', 'Clear Waypoints' , 'UserData',roiPtr, 'Callback',@clearWaypointsCallback); 

                    cropMenu(roiPtr);       

                    uimenu(roiPtr.UIContextMenu,'Label', 'Display Result' , 'UserData',roiPtr, 'Callback',@figRoiDialogCallback, 'Separator', 'on'); 

                    addlistener(roiPtr, 'WaypointAdded'  , @waypointEvents);
                    addlistener(roiPtr, 'WaypointRemoved', @waypointEvents);

                case lower('images.roi.polygon')

                    roiPtr = drawpolygon(axRoi, ...
                                         'Position'    , tInitInput(iOffset).tRoi{bb}.Position, ...
                                         'Color'       , tInitInput(iOffset).tRoi{bb}.Color, ...
                                         'FaceAlpha'   , tInitInput(iOffset).tRoi{bb}.FaceAlpha, ...
                                         'LineWidth'   , tInitInput(iOffset).tRoi{bb}.LineWidth, ...
                                         'Label'       , tInitInput(iOffset).tRoi{bb}.Label, ...
                                         'LabelVisible', tInitInput(iOffset).tRoi{bb}.LabelVisible, ...
                                         'Tag'         , tInitInput(iOffset).tRoi{bb}.Tag);  

                    roiDefaultMenu(roiPtr);

                    cropMenu(roiPtr);   

                    uimenu(roiPtr.UIContextMenu,'Label', 'Display Result' , 'UserData',roiPtr, 'Callback',@figRoiDialogCallback, 'Separator', 'on'); 

                case lower('images.roi.circle')

                    roiPtr = drawcircle(axRoi, ...
                                        'Position'     , tInitInput(iOffset).tRoi{bb}.Position, ...
                                        'Radius'       , tInitInput(iOffset).tRoi{bb}.Radius, ...
                                        'Color'        , tInitInput(iOffset).tRoi{bb}.Color, ...
                                        'FaceAlpha'    , tInitInput(iOffset).tRoi{bb}.FaceAlpha, ...
                                        'LineWidth'    , tInitInput(iOffset).tRoi{bb}.LineWidth, ...
                                        'Label'        , tInitInput(iOffset).tRoi{bb}.Label, ...
                                        'LabelVisible' , tInitInput(iOffset).tRoi{bb}.LabelVisible, ...
                                        'Tag'          , tInitInput(iOffset).tRoi{bb}.Tag);  

                    roiDefaultMenu(roiPtr);

                    cropMenu(roiPtr);

                    uimenu(roiPtr.UIContextMenu,'Label', 'Display Result' , 'UserData',roiPtr, 'Callback',@figRoiDialogCallback, 'Separator', 'on'); 

                case lower('images.roi.ellipse')

                    roiPtr = drawellipse(axRoi, ...
                                         'Position'     , tInitInput(iOffset).tRoi{bb}.Position, ...
                                         'SemiAxes'     , tInitInput(iOffset).tRoi{bb}.SemiAxes, ...
                                         'RotationAngle', tInitInput(iOffset).tRoi{bb}.RotationAngle, ...
                                         'Color'        , tInitInput(iOffset).tRoi{bb}.Color, ...
                                         'FaceAlpha'    , tInitInput(iOffset).tRoi{bb}.FaceAlpha, ...
                                         'LineWidth'    , tInitInput(iOffset).tRoi{bb}.LineWidth, ...
                                         'Label'        , tInitInput(iOffset).tRoi{bb}.Label, ...
                                         'LabelVisible' , tInitInput(iOffset).tRoi{bb}.LabelVisible, ...
                                         'Tag'          , tInitInput(iOffset).tRoi{bb}.Tag);  

                    roiDefaultMenu(roiPtr);

                    cropMenu(roiPtr);  

                    uimenu(roiPtr.UIContextMenu,'Label', 'Display Result' , 'UserData',roiPtr, 'Callback',@figRoiDialogCallback, 'Separator', 'on'); 

                case lower('images.roi.rectangle')
                    roiPtr = drawrectangle(axRoi, ...
                                          'Position'     , tInitInput(iOffset).tRoi{bb}.Position, ...
                                          'Color'        , tInitInput(iOffset).tRoi{bb}.Color, ...
                                          'FaceAlpha'    , tInitInput(iOffset).tRoi{bb}.FaceAlpha, ...
                                          'LineWidth'    , tInitInput(iOffset).tRoi{bb}.LineWidth, ...
                                          'Label'        , tInitInput(iOffset).tRoi{bb}.Label, ...
                                          'LabelVisible' , tInitInput(iOffset).tRoi{bb}.LabelVisible, ...
                                          'Tag'          , tInitInput(iOffset).tRoi{bb}.Tag);  

                    roiDefaultMenu(roiPtr);

                    cropMenu(roiPtr);   

                    uimenu(roiPtr.UIContextMenu,'Label', 'Display Result' , 'UserData',roiPtr, 'Callback',@figRoiDialogCallback, 'Separator', 'on'); 

            end

            addlistener(roiPtr, 'DeletingROI', @deleteRoiEvents );
            addlistener(roiPtr, 'ROIMoved'   , @movedRoiEvents  );

            tInitInput(iOffset).tRoi{bb}.Object = roiPtr;
        end

        inputTemplate('set', tInitInput);
        roiTemplate('set', tInitInput(iOffset).tRoi);
        
        progressBar(1, 'Ready');
        
    end

end