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

    windowButton('set', 'up'); % Fix for Linux

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
    if strcmpi(get(hObject, 'Tag'), 'Fusion Colorbar') && isVsplash('get') == false
        mMove = uimenu(d,'Label','Move Image', 'Callback',@setColorbarMoveImage);
        if isMoveImageActivated('get') == true
            set(mMove, 'Checked', true);
        else
            set(mMove, 'Checked', false);
        end
    end

    if strcmpi(get(hObject, 'Tag'), 'Fusion Colorbar')
        if numel(tEdgeInput) == 1
            if tEdgeInput(dEdgeFuseOffset).bFusedEdgeDetection == true
                set(findall(d, 'Label', 'Edge Detection'), 'Checked', 'on');
            end   
        else
            if tEdgeInput(dEdgeFuseOffset).bEdgeDetection == true
                set(findall(d, 'Label', 'Edge Detection'), 'Checked', 'on');
            end
        end
        sModality = tEdgeInput(dEdgeFuseOffset).atDicomInfo{1}.Modality;
        
    else
        if tEdgeInput(dEdgeOffset).bEdgeDetection == true
            set(findall(d, 'Label', 'Edge Detection'), 'Checked', 'on');
        end
        
        sModality = tEdgeInput(dEdgeOffset).atDicomInfo{1}.Modality;
 
    end
    
    e = uimenu(c,'Label','Window');
    set(e, 'tag', get(hObject, 'Tag'));
    mSetWindow = uimenu(e,'Label','Manual Input', 'Callback',@setColorbarWindowLevel);
        
    if strcmpi(sModality, 'CT')
        
        mF1 = uimenu(e,'Label','(F1) Lung'          , 'Callback',@setCTColorbarWindowLevel);
        mF2 = uimenu(e,'Label','(F2) Soft'          , 'Callback',@setCTColorbarWindowLevel);
        mF3 = uimenu(e,'Label','(F3) Bone'          , 'Callback',@setCTColorbarWindowLevel);
        mF4 = uimenu(e,'Label','(F4) Liver'         , 'Callback',@setCTColorbarWindowLevel);
        mF5 = uimenu(e,'Label','(F5) Brain'         , 'Callback',@setCTColorbarWindowLevel);
        mF6 = uimenu(e,'Label','(F6) Head and Neck' , 'Callback',@setCTColorbarWindowLevel);
        mF7 = uimenu(e,'Label','(F7) Enchanced Lung', 'Callback',@setCTColorbarWindowLevel);
        mF8 = uimenu(e,'Label','(F8) Mediastinum'   , 'Callback',@setCTColorbarWindowLevel);
        mF91 = uimenu(e,'Label','(F9) Temporal Bone', 'Callback',@setCTColorbarWindowLevel);
        mF92 = uimenu(e,'Label','(F9) Vertebra'     , 'Callback',@setCTColorbarWindowLevel);
        mF93 = uimenu(e,'Label','(F9) Scout CT'     , 'Callback',@setCTColorbarWindowLevel);
        mF34 = uimenu(e,'Label','(F9) All'          , 'Callback',@setCTColorbarWindowLevel);
        mCtm = uimenu(e,'Label','Custom'            , 'Enable', 'off','Callback',@setCTColorbarWindowLevel);
        
        if strcmpi(get(hObject, 'Tag'), 'Fusion Colorbar')
            dMax = fusionWindowLevel('get', 'max');
            dMin = fusionWindowLevel('get', 'min');            
        else     
            dMax = windowLevel('get', 'max');
            dMin = windowLevel('get', 'min');
        end
        
        [dWindow, dLevel] = computeWindowMinMax(dMax, dMin);
        sWindowName = getWindowName(dWindow, dLevel);
        
        switch lower(sWindowName)
            case lower('Lung')
                set(mF1, 'Checked', 'on');
            case lower('Soft')
                set(mF2, 'Checked', 'on');
            case lower('Bone')
                set(mF3, 'Checked', 'on');
            case lower('Liver')
                set(mF4, 'Checked', 'on');
            case lower('Brain')
                set(mF5, 'Checked', 'on');
            case lower('Head and Neck')
                set(mF6, 'Checked', 'on');
            case lower('Enchanced Lung')
                set(mF7, 'Checked', 'on');
            case lower('Mediastinum')
                set(mF8, 'Checked', 'on');
            case lower('Temporal Bone')
                set(mF91, 'Checked', 'on');
            case lower('Vertebra')
                set(mF92, 'Checked', 'on');
            case lower('Scout CT')
                set(mF93, 'Checked', 'on');
            case lower('All')
                set(mF34, 'Checked', 'on');
            otherwise
                set(mCtm, 'Checked', 'on');
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
            
            if numel(tInput) == 1
                bEdge = tInput(dFuseOffset).bFusedEdgeDetection;
            else
                bEdge = tInput(dFuseOffset).bEdgeDetection;
            end
            
            if bEdge == true
                if numel(tInput) == 1
                    tInput(dFuseOffset).bFusedEdgeDetection = false;
                else
                    tInput(dFuseOffset).bEdgeDetection = false;
                end

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
                if numel(tInput) == 1
                    tInput(dFuseOffset).bFusedEdgeDetection = true;
                else
                    tInput(dFuseOffset).bEdgeDetection = true;
                end

                dFudgeFactor = fudgeFactorSegValue('get');
                sMethod = edgeSegMethod('get');

                imf = fusionBuffer('get');
                imBak{dFuseOffset} = imf;

                imEdge = getEdgeDetection(imf, sMethod, dFudgeFactor);

                fusionBuffer('set', imEdge);
                
            end
                        
            inputTemplate('set', tInput);

            refreshImages();

        else

            if tInput(dSerieOffset).bEdgeDetection == true
                if numel(tInput) == 1 && isFusion('get') == false
                    tInput(dSerieOffset).bFusedEdgeDetection = false;
                end
                
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
                if numel(tInput) == 1 && isFusion('get') == false
                    tInput(dSerieOffset).bFusedEdgeDetection = true;
                end
                
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

    function setColorbarWindowLevel(hObject,~)
        
        tInput = inputTemplate('get');                

        if strcmpi(get(get(hObject, 'Parent'), 'Tag'), 'Fusion Colorbar')
            dMax = fusionWindowLevel('get', 'max');
            dMin = fusionWindowLevel('get', 'min');
            
            dOffset = get(uiFusedSeriesPtr('get'), 'Value');
        
            sUnitDisplay = getSerieUnitValue(dOffset);            
        else        
            dMax = windowLevel('get', 'max');
            dMin = windowLevel('get', 'min');
            
            dOffset = get(uiSeriesPtr('get'), 'Value');
        
            sUnitDisplay = getSerieUnitValue(dOffset);                        
        end
        
                       
        dlgWindowLevel = ...
            dialog('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-380/2) ...
                                (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-165/2) ...
                                380 ...
                                165 ...
                                ],...
                  'Color', viewerBackgroundColor('get'), ...
                  'Name', 'Set Window Level'...
                   );      
               
    if strcmpi(sUnitDisplay, 'SUV') ||  strcmpi(sUnitDisplay, 'HU') 
        if strcmpi(sUnitDisplay, 'HU') 
            sUnitDisplay = 'Window Level';            
            
            [dWindow, dLevel] = computeWindowMinMax(dMax, dMin);
        else
            dMax = dMax*tInput(dOffset).tQuant.tSUV.dScale;
            dMin = dMin*tInput(dOffset).tQuant.tSUV.dScale;
                       
        end
        bUnitEnable = 'on';
    else
        bUnitEnable = 'off';
    end
    
    sUnitType = sprintf('Unit in %s', sUnitDisplay);
    
    chkUnitType = ...
        uicontrol(dlgWindowLevel,...
                  'style'   , 'checkbox',...
                  'enable'  , bUnitEnable,...
                  'value'   , 1,...
                  'position', [20 115 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                    
                  'Callback', @chkUnitTypeCallback...
                  );

    txtUnitType = ...
         uicontrol(dlgWindowLevel,...
                  'style'   , 'text',...
                  'string'  , sUnitType,...
                  'horizontalalignment', 'left',...
                  'position', [40 112 200 20],...
                  'Enable', 'Inactive',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                    
                  'ButtonDownFcn', @chkUnitTypeCallback...
                  );
                                
  if strcmpi(sUnitDisplay, 'Window Level')
      sMaxDisplay = 'Window Value';
      sMaxValue = num2str(dWindow);
  else
      sMaxDisplay = 'Max Value';
      sMaxValue = num2str(dMax);
  end
  
         uicontrol(dlgWindowLevel,...
                  'style'   , 'text',...
                  'string'  , sMaxDisplay,...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'position', [20 87 150 20]...
                  );
              
  edtMaxValue = ...
      uicontrol(dlgWindowLevel,...
                'style'     , 'edit',...
                'Background', 'white',...
                'string'    , sMaxValue,...
                'BackgroundColor', viewerBackgroundColor('get'), ...
                'ForegroundColor', viewerForegroundColor('get'), ...                 
                'position'  , [200 90 150 20]...
                );
            
  if strcmpi(sUnitDisplay, 'Window Level')
      sMinDisplay = 'Level Value';
      sMinValue = num2str(dLevel);
  else
      sMinDisplay = 'Min Value';
      sMinValue = num2str(dMin);
  end            
         uicontrol(dlgWindowLevel,...
                  'style'   , 'text',...
                  'string'  , sMinDisplay,...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'position', [20 62 150 20]...
                  );

  edtMinValue = ...
      uicontrol(dlgWindowLevel,...
                'style'     , 'edit',...
                'Background', 'white',...
                'string'    , sMinValue,...
                'BackgroundColor', viewerBackgroundColor('get'), ...
                'ForegroundColor', viewerForegroundColor('get'), ...                 
                'position'  , [200 65 150 20]...
                );
            
     % Cancel or Proceed

     uicontrol(dlgWindowLevel,...
               'String','Cancel',...
               'Position',[285 7 75 25],...
               'BackgroundColor', viewerBackgroundColor('get'), ...
               'ForegroundColor', viewerForegroundColor('get'), ...                
               'Callback', @cancelWindowLCallback...
               );

     uicontrol(dlgWindowLevel,...
              'String','Proceed',...
              'Position',[200 7 75 25],...
              'BackgroundColor', viewerBackgroundColor('get'), ...
              'ForegroundColor', viewerForegroundColor('get'), ...               
              'Callback', @proceedWindowLCallback...
              );               
               
          
        function chkUnitTypeCallback(hChkObject, ~)            
            
            if strcmpi(get(chkUnitType, 'Enable'), 'off')
                return;
            end
            
            if strcmpi(get(hChkObject, 'Style'), 'text')
                if get(chkUnitType, 'Value') == true

                    set(chkUnitType, 'Value', false);
                    
                else
                    set(chkUnitType, 'Value', true);                  
                end
            end 
            
            if  get(chkUnitType, 'Value') == false               
                if strcmpi(sUnitDisplay, 'SUV')
                    sUnitDisplay = 'BQML';
                else
                    sUnitDisplay = 'HU';
                end            
            else
                if strcmpi(sUnitDisplay, 'BQML')
                    sUnitDisplay = 'SUV';
                else
                    sUnitDisplay = 'Window Level';
                end             
            end
            
            sUnitType = sprintf('Unit in %s', sUnitDisplay);
                                            
            set(txtUnitType, 'String', sUnitType);            
            
            if strcmpi(get(get(hObject, 'Parent'), 'Tag'), 'Fusion Colorbar')
                dMaxValue = fusionWindowLevel('get', 'max');
                dMinValue = fusionWindowLevel('get', 'min');  
            else
                dMaxValue = windowLevel('get', 'max');
                dMinValue = windowLevel('get', 'min');                  
            end
            
            switch (sUnitDisplay)
                case 'Window Level'
                    
                    [dWindow, dLevel] = computeWindowMinMax(dMaxValue, dMinValue);
                    
                    sMinValue = num2str(dLevel);
                    sMaxValue = num2str(dWindow);
                    
                case 'HU'
                                        
                    sMinValue = num2str(dMinValue);
                    sMaxValue = num2str(dMaxValue);                  
                    
                case 'SUV'
                    sMinValue = dMinValue*tInput(dOffset).tQuant.tSUV.dScale;
                    sMaxValue = dMaxValue*tInput(dOffset).tQuant.tSUV.dScale;
                    
                case 'BQML'
                    sMinValue = num2str(dMinValue);
                    sMaxValue = num2str(dMaxValue);                     
            end
            
            set(edtMinValue, 'String', sMinValue);           
            set(edtMaxValue, 'String', sMaxValue);           
                        
        end
            
        function cancelWindowLCallback(~, ~)               
            delete(dlgWindowLevel)
        end
        
        function proceedWindowLCallback(~, ~)     
            
            lMax = str2double(get(edtMaxValue, 'String'));
            lMin = str2double(get(edtMinValue, 'String'));
            
            if strcmpi(sUnitDisplay, 'SUV') 
                lMin = lMin/tInput(dOffset).tQuant.tSUV.dScale;
                lMax = lMax/tInput(dOffset).tQuant.tSUV.dScale;
            end
                
            if strcmpi(sUnitDisplay, 'Window Level') 
                [lMax, lMin] = computeWindowLevel(lMax, lMin);
            end
                    
            if strcmpi(get(get(hObject, 'Parent'), 'Tag'), 'Fusion Colorbar')
                
                fusionWindowLevel('set', 'max', lMax);
                fusionWindowLevel('set', 'min' ,lMin);

                set(uiFusionSliderWindowPtr('get'), 'value', 0.5);
                set(uiFusionSliderLevelPtr('get') , 'value', 0.5);

                if switchTo3DMode('get')     == false && ...
                   switchToIsoSurface('get') == false && ...
                   switchToMIPMode('get')    == false

                    if size(dicomBuffer('get'), 3) == 1            
                        set(axefPtr('get'), 'CLim', [lMin lMax]);
                    else
                        set(axes1fPtr('get'), 'CLim', [lMin lMax]);
                        set(axes2fPtr('get'), 'CLim', [lMin lMax]);
                        set(axes3fPtr('get'), 'CLim', [lMin lMax]);
                    end

                    refreshImages();
                end                 
            else    
                    
                windowLevel('set', 'max', lMax);
                windowLevel('set', 'min' ,lMin);

                set(uiSliderWindowPtr('get'), 'value', 0.5);
                set(uiSliderLevelPtr('get') , 'value', 0.5);

                if switchTo3DMode('get')     == false && ...
                   switchToIsoSurface('get') == false && ...
                   switchToMIPMode('get')    == false

                    if size(dicomBuffer('get'), 3) == 1            
                        set(axePtr('get'), 'CLim', [lMin lMax]);
                    else
                        set(axes1Ptr('get'), 'CLim', [lMin lMax]);
                        set(axes2Ptr('get'), 'CLim', [lMin lMax]);
                        set(axes3Ptr('get'), 'CLim', [lMin lMax]);
                    end

                    refreshImages();
                end              
            end
            
            delete(dlgWindowLevel)
        end
        
    end

    function setCTColorbarWindowLevel(hObject, ~)
        
        switch lower(get(hObject, 'Label'))
            case lower('(F1) Lung')
                [lMax, lMin] = computeWindowLevel(1200, -500);
            case lower('(F2) Soft')
                [lMax, lMin] = computeWindowLevel(500, 50);
            case lower('(F3) Bone')
                [lMax, lMin] = computeWindowLevel(500, 200);
            case lower('(F4) Liver')
                [lMax, lMin] = computeWindowLevel(240, 40);
            case lower('(F5) Brain')
                [lMax, lMin] = computeWindowLevel(80, 40);
            case lower('(F6) Head and Neck')
                [lMax, lMin] = computeWindowLevel(350, 90);
            case lower('(F7) Enchanced Lung')
                [lMax, lMin] = computeWindowLevel(2000, -600);
            case lower('(F8) Mediastinum')
                [lMax, lMin] = computeWindowLevel(350, 50);
            case lower('(F9) Temporal Bone')
                [lMax, lMin] = computeWindowLevel(2000, 0);
            case lower('(F9) Vertebra')
                [lMax, lMin] = computeWindowLevel(2500, 415);
            case lower('(F9) Scout CT')
                [lMax, lMin] = computeWindowLevel(350, 50);
            case lower('(F9) All')
                [lMax, lMin] = computeWindowLevel(1000, 350);
            otherwise
                % to do
        end        
             
        if strcmpi(get(get(hObject, 'Parent'), 'Tag'), 'Fusion Colorbar')
            
            fusionWindowLevel('set', 'max', lMax);
            fusionWindowLevel('set', 'min' ,lMin);
                
            if size(fusionBuffer('get'), 3) == 1            
                set(axefPtr('get'), 'CLim', [lMin lMax]);
            else
                set(axes1fPtr('get'), 'CLim', [lMin lMax]);
                set(axes2fPtr('get'), 'CLim', [lMin lMax]);
                set(axes3fPtr('get'), 'CLim', [lMin lMax]);
            end            
        else    
            windowLevel('set', 'max', lMax);
            windowLevel('set', 'min' ,lMin);
            
            if size(dicomBuffer('get'), 3) == 1            
                set(axePtr('get'), 'CLim', [lMin lMax]);
            else
                set(axes1Ptr('get'), 'CLim', [lMin lMax]);
                set(axes2Ptr('get'), 'CLim', [lMin lMax]);
                set(axes3Ptr('get'), 'CLim', [lMin lMax]);
            end
        end              
        
    end

    function setColorbarMoveImage(~, ~)
        
        if isMoveImageActivated('get') == false
                        
            set(fiMainWindowPtr('get'), 'Pointer', 'fleur');           
            
            isMoveImageActivated('set', true);
            
            fusedImageRotationValues('set', false);
            fusedImageMovementValues('set', false);      
            
            tInput = inputTemplate('get');
            aInput = inputBuffer('get');
            
            iSeriesOffset = get(uiSeriesPtr('get'), 'Value');
            iFuseOffset   = get(uiFusedSeriesPtr('get'), 'Value');
                        
            set(uiSeriesPtr('get'), 'Value', iFuseOffset);
            aMoveImage = dicomBuffer('get');
            if isempty(aMoveImage)
                aMoveImage = aInput{iFuseOffset};
            end
            
            if size(aMoveImage, 3) == 1
                if iSeriesOffset ~= iFuseOffset
                    if tInput(iSeriesOffset).bFlipLeftRight == true
                        aMoveImage=aMoveImage(:,end:-1:1);
                    end

                    if tInput(iSeriesOffset).bFlipAntPost == true
                        aMoveImage=aMoveImage(end:-1:1,:);
                    end
                end                
            else
                if iSeriesOffset ~= iFuseOffset                
                    if tInput(iSeriesOffset).bFlipLeftRight == true
                        aMoveImage=aMoveImage(:,end:-1:1,:);
                    end

                    if tInput(iSeriesOffset).bFlipAntPost == true
                        aMoveImage=aMoveImage(end:-1:1,:,:);
                    end

                    if tInput(iSeriesOffset).bFlipHeadFeet == true
                        aMoveImage=aMoveImage(:,:,end:-1:1);
                    end
                end
                
                if strcmp(imageOrientation('get'), 'coronal')
                    aMoveImage = permute(aMoveImage, [3 2 1]);
                elseif strcmp(imageOrientation('get'), 'sagittal')
                    aMoveImage = permute(aMoveImage, [2 3 1]);
                else
                    aMoveImage = permute(aMoveImage, [1 2 3]);
                end                
            end
            
            set(uiSeriesPtr('get'), 'Value', iSeriesOffset);
            
            moveImageBuffer('set', aMoveImage);

        else
         
            set(fiMainWindowPtr('get'), 'Pointer', 'default');   
            
            isMoveImageActivated('set', false);
            
            iSeriesOffset = get(uiSeriesPtr('get'), 'Value');
            iFuseOffset   = get(uiFusedSeriesPtr('get'), 'Value');
            
            set(uiSeriesPtr('get'), 'Value', iFuseOffset);
            dicomBuffer('set', moveImageBuffer('get'));
            set(uiSeriesPtr('get'), 'Value', iSeriesOffset);
            
            moveImageBuffer('reset');
          
        end
             
    end


end
