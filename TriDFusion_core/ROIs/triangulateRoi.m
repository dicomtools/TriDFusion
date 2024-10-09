function triangulateRoi(sRoiTag)
%function triangulateRoi(sRoiTag)
%Set the slices number of the 2D triangulation, based on a ROI.
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

    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

    im = dicomBuffer('get', [], dSeriesOffset);
    
    atRoiInput = roiTemplate('get',dSeriesOffset);

    if isempty(atRoiInput)
        return;
    end

    if size(im, 3) ~= 1 % 3D
   
       dTagOffset = find(strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), sRoiTag ), 1); 
                       
       if ~isempty(dTagOffset)

            tRoi = atRoiInput{dTagOffset};

            origInfo = getappdata(tRoi.Object.Parent, 'matlab_graphics_resetplotview');

            if isempty(origInfo)
                bIsZoomed = false;
            elseif isequal(get(tRoi.Object.Parent,'XLim'), origInfo.XLim) && ...
                isequal(get(tRoi.Object.Parent,'YLim'), origInfo.YLim) 
                bIsZoomed = false;
            else
                bIsZoomed = true;
            end
            
           if ~isempty(tRoi.MaxDistances)

                p1x = tRoi.MaxDistances.MaxXY.Line.XData(1);
                p2x = tRoi.MaxDistances.MaxXY.Line.XData(2);
                p1y = tRoi.MaxDistances.MaxXY.Line.YData(1);
                p2y = tRoi.MaxDistances.MaxXY.Line.YData(2);

                midX = round(mean([p1x, p2x]));
                midY = round(mean([p1y, p2y]));
            else 
                midX = round(tRoi.Position(1,1));
                midY = round(tRoi.Position(1,2));                        
            end

            iCoronalSize  = size(im,1);
            iSagittalSize = size(im,2);
            iAxialSize    = size(im,3);

            dSliceNb = tRoi.SliceNb;            

            switch lower(tRoi.Axe)
                
                case 'axes1'

                    if ( (midX <= iSagittalSize) &&...
                         (midY <= iAxialSize) )

                        set(uiSliderSagPtr('get'), 'Value', midX / iSagittalSize);
                        set(uiSliderTraPtr('get'), 'Value', 1 - (midY / iAxialSize));
                        set(uiSliderCorPtr('get'), 'Value', dSliceNb / iCoronalSize);

                        sliceNumber('set', 'sagittal', midX);
                        sliceNumber('set', 'axial'   , midY);
                        sliceNumber('set', 'coronal' , dSliceNb);

                        refreshImages();

                        if bIsZoomed == true
                            
                            xx = tRoi.Object.Parent.XLim;
                            yy = tRoi.Object.Parent.YLim;

                            xOffset = diff(xx)/2;
                            yOffset = diff(yy)/2;
            
                            Xlimit = [midX-xOffset midX+xOffset];
                            tRoi.Object.Parent.XLim = Xlimit;

                            Ylimit = [midY-yOffset midY+yOffset];
                            tRoi.Object.Parent.YLim = Ylimit;
                        end
                    end

                case 'axes2'

                    if ( (midX <= iCoronalSize) &&...
                         (midY <= iAxialSize) )

                        set(uiSliderCorPtr('get'), 'Value', midX / iCoronalSize);
                        set(uiSliderTraPtr('get'), 'Value', 1 - (midY / iAxialSize));
                        set(uiSliderSagPtr('get'), 'Value', dSliceNb / iSagittalSize);

                        sliceNumber('set', 'coronal' , midX);
                        sliceNumber('set', 'axial'   , midY);
                        sliceNumber('set', 'sagittal', dSliceNb);

                        refreshImages();

                        if bIsZoomed == true

                            xx = tRoi.Object.Parent.XLim;
                            yy = tRoi.Object.Parent.YLim;

                            xOffset = diff(xx)/2;
                            yOffset = diff(yy)/2;

                            Xlimit = [midX-xOffset midX+xOffset];
                            tRoi.Object.Parent.XLim = Xlimit;



                            Ylimit = [midY-yOffset midY+yOffset];
                            tRoi.Object.Parent.YLim = Ylimit;

                        end
                    end

                case 'axes3'

                    if ( (midX <= iSagittalSize) && ...
                         (midY <= iCoronalSize) )

                        set(uiSliderSagPtr('get'), 'Value', midX / iSagittalSize);
                        set(uiSliderCorPtr('get'), 'Value', midY / iCoronalSize);
                        set(uiSliderTraPtr('get'), 'Value', 1 - (dSliceNb / iAxialSize));

                        sliceNumber('set', 'sagittal', midX);
                        sliceNumber('set', 'coronal' , midY);
                        sliceNumber('set', 'axial'   , dSliceNb);

                        refreshImages();

                        if bIsZoomed == true

                            xx = tRoi.Object.Parent.XLim;
                            yy = tRoi.Object.Parent.YLim;

                            xOffset = diff(xx)/2;
                            yOffset = diff(yy)/2;

                            Xlimit = [midX-xOffset midX+xOffset];
                            tRoi.Object.Parent.XLim = Xlimit;

                            Ylimit = [midY-yOffset midY+yOffset];
                            tRoi.Object.Parent.YLim = Ylimit;

                        end

                    end
                otherwise
            end
       end

    else % 2D
    end

end
