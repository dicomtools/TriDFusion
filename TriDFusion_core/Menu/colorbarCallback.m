function colorbarCallback(hObject, ~)
%function colorbarCallback(~, ~)
%Display 2D Colorbar Menu.
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

    tEdgeInput = inputTemplate('get');
    
    dEdgeFuseOffset = get(uiFusedSeriesPtr('get'), 'Value');
    if dEdgeFuseOffset > numel(tEdgeInput)
        return;
    end
    
    dEdgeOffset = get(uiSeriesPtr('get'), 'Value');
    if dEdgeOffset > numel(tEdgeInput)
        return;
    end
        
    c = uicontextmenu(fiMainWindowPtr('get'));
    set(c, 'tag', get(hObject, 'Tag'));

    hObject.UIContextMenu = c;

    d = uimenu(c,'Label','Tools');
    set(d, 'tag', get(hObject, 'Tag'));

    uimenu(d,'Label','Edge Detection', 'Callback',@setColorbarEdgeDetection);

    if strcmpi(get(hObject, 'Tag'), 'Fusion Colorbar')
        
        if tEdgeInput(dEdgeFuseOffset).bEdgeDetection == true
            set(findall(d, 'Label', 'Edge Detection'), 'Checked', 'on');
        end        
    else

        if tEdgeInput(dEdgeOffset).bEdgeDetection == true
            set(findall(d, 'Label', 'Edge Detection'), 'Checked', 'on');
        end
    end

    uimenu(c,'Label','parula'       ,'Callback',@setColorOffset);
    uimenu(c,'Label','jet'          ,'Callback',@setColorOffset);
    uimenu(c,'Label','hsv'          ,'Callback',@setColorOffset);
    uimenu(c,'Label','hot'          ,'Callback',@setColorOffset);
    uimenu(c,'Label','cool'         ,'Callback',@setColorOffset);
    uimenu(c,'Label','spring'       ,'Callback',@setColorOffset);
    uimenu(c,'Label','summer'       ,'Callback',@setColorOffset);
    uimenu(c,'Label','autumn'       ,'Callback',@setColorOffset);
    uimenu(c,'Label','winter'       ,'Callback',@setColorOffset);
    uimenu(c,'Label','gray'         ,'Callback',@setColorOffset);
    uimenu(c,'Label','invert linear','Callback',@setColorOffset);
    uimenu(c,'Label','bone'         ,'Callback',@setColorOffset);
    uimenu(c,'Label','copper'       ,'Callback',@setColorOffset);
    uimenu(c,'Label','pink'         ,'Callback',@setColorOffset);
    uimenu(c,'Label','lines'        ,'Callback',@setColorOffset);
    uimenu(c,'Label','colorcube'    ,'Callback',@setColorOffset);
    uimenu(c,'Label','prism'        ,'Callback',@setColorOffset);
    uimenu(c,'Label','flag'         ,'Callback',@setColorOffset);
    uimenu(c,'Label','pet'          ,'Callback',@setColorOffset);
    uimenu(c,'Label','hot metal'    ,'Callback',@setColorOffset);
    uimenu(c,'Label','angio'        ,'Callback',@setColorOffset);

    if strcmpi(get(hObject, 'Tag'), 'Fusion Colorbar')
        dOffset = fusionColorMapOffset('get');
    else
        dOffset = colorMapOffset('get');
    end

    switch dOffset
        case 1
            set(findall(c,'Label','parula'), 'Checked', 'on');
        case 2
            set(findall(c,'Label','jet'), 'Checked', 'on');
        case 3
            set(findall(c,'Label','hsv'), 'Checked', 'on');
        case 4
            set(findall(c,'Label','hot'), 'Checked', 'on');
        case 5
            set(findall(c,'Label','cool'), 'Checked', 'on');
        case 6
            set(findall(c,'Label','spring'), 'Checked', 'on');
        case 7
            set(findall(c,'Label','summer'), 'Checked', 'on');
        case 8
            set(findall(c,'Label','autumn'), 'Checked', 'on');
        case 9
            set(findall(c,'Label','winter'), 'Checked', 'on');
        case 10
            set(findall(c,'Label','gray'), 'Checked', 'on');
        case 11
            set(findall(c,'Label','invert linear'), 'Checked', 'on');
        case 12
            set(findall(c,'Label','bone'), 'Checked', 'on');
        case 13
            set(findall(c,'Label','copper'), 'Checked', 'on');
        case 14
            set(findall(c,'Label','pink'), 'Checked', 'on');
        case 15
            set(findall(c,'Label','lines'), 'Checked', 'on');
        case 16
            set(findall(c,'Label','colorcube'), 'Checked', 'on');
        case 17
            set(findall(c,'Label','prism'), 'Checked', 'on');
        case 18
            set(findall(c,'Label','flag'), 'Checked', 'on');
        case 19
            set(findall(c,'Label','pet'), 'Checked', 'on');
        case 20
            set(findall(c,'Label','hot metal'), 'Checked', 'on');
        case 21
            set(findall(c,'Label','angio'), 'Checked', 'on');
    end

    function setColorOffset(hObject, ~)

        if strcmpi(get(get(hObject, 'Parent'), 'Tag'), 'Fusion Colorbar')
            iOffset = getColorMapOffset(get(hObject, 'Label'));
            fusionColorMapOffset('set', iOffset);
        else
            iOffset = getColorMapOffset(get(hObject, 'Label'));
            colorMapOffset('set', iOffset);
        end

        refreshColorMap();

    end

    function setColorbarEdgeDetection(hObject, ~)

        tInput = inputTemplate('get');

        dSerieOffset = get(uiSeriesPtr('get'), 'Value');
        if dSerieOffset > numel(tInput)
            return;
        end

        persistent imBak;

        if strcmpi(get(get(hObject, 'Parent'), 'Tag'), 'Fusion Colorbar')

            dFuseOffset = get(uiFusedSeriesPtr('get'), 'Value');
            if dFuseOffset > numel(tInput)
                return;
            end

            if tInput(dFuseOffset).bEdgeDetection == true

                tInput(dFuseOffset).bEdgeDetection = false;

                if size(imBak{dFuseOffset}, 3) == 1 % 2D planar Image

                    if tInput(dSerieOffset).bFlipLeftRight == true
                        imBak{dFuseOffset}=imBak{dFuseOffset}(:,end:-1:1);
                    end

                    if tInput(dSerieOffset).bFlipAntPost == true
                        imBak{dFuseOffset}=imBak{dFuseOffset}(end:-1:1,:);
                    end
                else % 3D Volume

                    if tInput(dSerieOffset).bFlipLeftRight == true
                        imBak{dFuseOffset}=imBak{dFuseOffset}(:,end:-1:1,:);
                    end

                    if tInput(dSerieOffset).bFlipAntPost == true
                        imBak{dFuseOffset}=imBak{dFuseOffset}(end:-1:1,:,:);
                    end

                    if tInput(dSerieOffset).bFlipHeadFeet == true
                        imBak{dFuseOffset}=imBak{dFuseOffset}(:,:,end:-1:1);
                    end
                end

                fusionBuffer('set', imBak{dFuseOffset});
            else
                tInput(dFuseOffset).bEdgeDetection = true;

                dFudgeFactor = fudgeFactorSegValue('get');
                sMethod = edgeSegMethod('get');

                imf = fusionBuffer('get');
                imBak{dFuseOffset} =imf;

                imEdge = getEdgeDetection(imf, sMethod, dFudgeFactor);

                fusionBuffer('set', imEdge);

            end

            inputTemplate('set', tInput);

            refreshImages();

        else

            if tInput(dSerieOffset).bEdgeDetection == true

                tInput(dSerieOffset).bEdgeDetection = false;

                if size(imBak{dSerieOffset}, 3) == 1

                    if tInput(dSerieOffset).bFlipLeftRight == true
                        imBak{dSerieOffset}=imBak{dSerieOffset}(:,end:-1:1);
                    end

                    if tInput(dSerieOffset).bFlipAntPost == true
                        imBak{dSerieOffset}=imBak{dSerieOffset}(end:-1:1,:);
                    end
                else
                    if tInput(dSerieOffset).bFlipLeftRight == true
                        imBak{dSerieOffset}=imBak{dSerieOffset}(:,end:-1:1,:);
                    end

                    if tInput(dSerieOffset).bFlipAntPost == true
                        imBak{dSerieOffset}=imBak{dSerieOffset}(end:-1:1,:,:);
                    end

                    if tInput(dSerieOffset).bFlipHeadFeet == true
                        imBak{dSerieOffset}=imBak{dSerieOffset}(:,:,end:-1:1);
                    end
                end
                dicomBuffer('set', imBak{dSerieOffset});
            else
                tInput(dSerieOffset).bEdgeDetection = true;

                dFudgeFactor = fudgeFactorSegValue('get');
                sMethod = edgeSegMethod('get');

                im = dicomBuffer('get');
                imBak{dSerieOffset}=im;

                imEdge = getEdgeDetection(im, sMethod, dFudgeFactor);

                dicomBuffer('set', imEdge);
            end

            inputTemplate('set', tInput);

            refreshImages();

        end
    end
end
