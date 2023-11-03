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

    tInput = inputTemplate('get');
    
    dFuseOffset = get(uiFusedSeriesPtr('get'), 'Value');
    if dFuseOffset > numel(tInput)
        return;
    end
    
    dOffset = get(uiSeriesPtr('get'), 'Value');
    if dOffset > numel(tInput)
        return;
    end
        
    c = uicontextmenu(fiMainWindowPtr('get'));
    set(c, 'tag', get(hObject, 'Tag'));

    hObject.UIContextMenu = c;
    
    if strcmpi(get(hObject, 'Tag'), 'Fusion Colorbar') && isVsplash('get') == false
        
        d = uimenu(c,'Label','Tools');
        set(d, 'tag', get(hObject, 'Tag'));  
        if isCombineMultipleFusion('get') == true
            set(d, 'Enable', 'off');
        else
            set(d, 'Enable', 'on');
        end
        
        mEdge = uimenu(d,'Label','Edge Detection', 'Callback',@setColorbarEdgeDetection);   
        
        mManualSync = uimenu(d,'Label','Manual Alignment');
        
        mMoveImage         = uimenu(mManualSync,'Label','Move Image'               , 'Callback',@setMoveImageCallback);       
        mMoveAssociated    = uimenu(mManualSync,'Label','Move Associated Series'   , 'Callback',@setMoveAssociatedSeriesCallback);
        mUpdateDescription = uimenu(mManualSync,'Label','Update Series Description', 'Callback',@setMoveUpdateSeriesDescriptionCallback);
        
        if associateRegistrationModality('get') == true
            set(mMoveAssociated, 'Checked', true);
        else
            set(mMoveAssociated, 'Checked', false);            
        end
        
        if updateDescription('get') == true
            set(mUpdateDescription, 'Checked', true);
        else
            set(mUpdateDescription, 'Checked', false);            
        end
        
        if isMoveImageActivated('get') == true
            set(mEdge             , 'Enable' , 'off');
            set(mMoveImage        , 'Checked', true);
            set(mMoveAssociated   , 'Enable' , 'on');
            set(mUpdateDescription, 'Enable' , 'on');
        else
            set(mEdge             , 'Enable' , 'on');
            set(mMoveImage        , 'Checked', false);
            set(mMoveAssociated   , 'Enable' , 'off');
            set(mUpdateDescription, 'Enable' , 'off');
        end                
        
        sModality = tInput(dFuseOffset).atDicomInfo{1}.Modality;       
%        if ~strcmpi(sModality, 'CT')

            mPlot = uimenu(d,'Label','Plot Contours');
      %      set(mPlot, 'tag', get(hObject, 'Tag'));

            mPlotContours = uimenu(mPlot,'Label','Show Contours', 'Callback', @setPlotContoursCallback);
            if isPlotContours('get') == true
                set(mPlotContours, 'Checked', true);
            else
                set(mPlotContours, 'Checked', false);
            end        

            mPlotFace = uimenu(mPlot,'Label','Show Face Alpha', 'Callback', @setShowFaceAlphContoursCallback);
            if isShowFaceAlphaContours('get') == true
                set(mPlotFace, 'Checked', true);           
            else
                set(mPlotFace, 'Checked', false);
            end 

            mLevelList = uimenu(mPlot,'Label','Set Level List', 'Callback', @setLevelListContoursCallback);
            set(mLevelList, 'Checked', false);

            mLevelStep = uimenu(mPlot,'Label','Set Level Step', 'Callback', @setLevelStepContoursCallback);
            set(mLevelStep, 'Checked', false);

            mLineWidth = uimenu(mPlot,'Label','Set Line Width', 'Callback', @setLineWidthContoursCallback);
            set(mLineWidth, 'Checked', false);

            mPlotText = uimenu(mPlot,'Label','Show Text', 'Callback', @setShowTextContoursCallback);
            if size(dicomBuffer('get'), 3) == 1 % 2D Image
                if isShowTextContours('get', 'axe') == true
                    set(mPlotText, 'Checked', true);           
                else
                    set(mPlotText, 'Checked', false);
                end  
            else
                set(mPlotText, 'Checked', false);
            end

            mTextList = uimenu(mPlot,'Label','Set Text List', 'Callback', @setTextListContoursCallback);
            set(mTextList, 'Checked', false);

            if isPlotContours('get') == true
                set(mPlotText , 'Enable', 'on');           
                set(mPlotFace , 'Enable', 'on');           
                set(mLevelList, 'Enable', 'on');           
                set(mLevelStep, 'Enable', 'on');
                set(mLineWidth, 'Enable', 'on');   
                if size(dicomBuffer('get'), 3) == 1 % 2D Image                
                    if isShowTextContours('get', 'axe') == true
                        set(mTextList , 'Enable', 'on');           
                    else
                        set(mTextList , 'Enable', 'off');           
                    end
                else
                    if isShowTextContours('get', 'coronal')  == true || ...
                       isShowTextContours('get', 'sagittal') == true || ...
                       isShowTextContours('get', 'axial')    == true || ...
                       isShowTextContours('get', 'mip')      == true 
                        set(mTextList , 'Enable', 'on');           
                    else
                        set(mTextList , 'Enable', 'off');           
                    end
                end
            else
                set(mPlotText , 'Enable', 'off');           
                set(mPlotFace , 'Enable', 'off');  
                set(mLevelList, 'Enable', 'off');           
                set(mLevelStep, 'Enable', 'off');           
                set(mLineWidth, 'Enable', 'off');           
                set(mTextList , 'Enable', 'off');            
            end
     %   end    
    end

    if strcmpi(get(hObject, 'Tag'), 'Fusion Colorbar')
        if numel(tInput) == 1
            if tInput(dFuseOffset).bFusedEdgeDetection == true
                set(findall(d, 'Label', 'Edge Detection'), 'Checked', 'on');
            end   
        else
            if tInput(dFuseOffset).bEdgeDetection == true
                set(findall(d, 'Label', 'Edge Detection'), 'Checked', 'on');
            end
        end
        sModality = tInput(dFuseOffset).atDicomInfo{1}.Modality;
        
    else
%        if tInput(dOffset).bEdgeDetection == true
%            set(findall(d, 'Label', 'Edge Detection'), 'Checked', 'on');
%        end
        
        sModality = tInput(dOffset).atDicomInfo{1}.Modality; 
    end
    
    e = uimenu(c,'Label','Window');
    set(e, 'tag', get(hObject, 'Tag'));
    
    if isCombineMultipleFusion('get') == true && strcmpi(get(hObject, 'Tag'), 'Fusion Colorbar')
        set(e, 'Enable', 'off');
    else
        set(e, 'Enable', 'on');
    end
    
    uimenu(e,'Label','Manual Input', 'Callback',@setColorbarWindowLevel);
 
    if strcmpi(get(hObject, 'Tag'), 'Fusion Colorbar')
        
        i = uimenu(c,'Label','Multi-Fusion');
        set(i, 'tag', get(hObject, 'Tag'));        
        
        mCombineRGB = uimenu(i,'Label','Combine RGB', 'Callback',@setFusionCombineRGB); 
        if isCombineMultipleFusion('get') == true
            set(mCombineRGB, 'Checked', true);
        else
            set(mCombineRGB, 'Checked', false);
        end       
        set(mCombineRGB, 'Enable', 'on'); 
        
        mNormalizeToLiver = uimenu(i,'Label','Normalize to Liver', 'Callback',@setFusionNormalizeToLiverCallback); 
        set(mNormalizeToLiver, 'Checked', false);
        if isCombineMultipleFusion('get') == true && ...
           isVsplash('get') == false
            if isRGBFusionNormalizeToLiver('get') == false
                set(mNormalizeToLiver, 'Enable', 'on');       
            else
                set(mNormalizeToLiver, 'Enable', 'off');       
            end
        else
            set(mNormalizeToLiver, 'Enable', 'off');        
        end          
        
        mIntensity = uimenu(i,'Label','Intensity & Min\Max', 'Callback',@setFusionImagesIntensity); 
        set(mIntensity, 'Checked', false);
        if isCombineMultipleFusion('get') == true
            set(mIntensity, 'Enable', 'on');        
        else
            set(mIntensity, 'Enable', 'off');        
        end  
        
        mShowRGBColormap = uimenu(i,'Label','Show RGB Colormap', 'Separator','on','Callback',@showRGBColormapImageCallback); 
        if size(dicomBuffer('get'), 3) == 1 || ...
           isVsplash('get') == true
            set(mShowRGBColormap , 'Enable', 'off');   
        else
            set(mShowRGBColormap , 'Enable', 'on');   
        end
       
        axeRGBImage = axeRGBImagePtr('get');    
        if ~isempty(axeRGBImage)           
            set(mShowRGBColormap, 'Checked', true);
        else
            set(mShowRGBColormap, 'Checked', false);
        end                         
           
        mRGBplus  = uimenu(i,'Label','RGB plus' , 'Callback', @changeRGBColormapImageCallback);
        mRGBblock = uimenu(i,'Label','RGB block', 'Callback', @changeRGBColormapImageCallback);
        mRGBwheel = uimenu(i,'Label','RGB wheel', 'Callback', @changeRGBColormapImageCallback);
        mRGBcube  = uimenu(i,'Label','RGB cube' , 'Callback', @changeRGBColormapImageCallback);
        
        if ~isempty(axeRGBImage) && ...
           size(dicomBuffer('get'), 3) ~= 1 && ...   
           isVsplash('get') == false
            set(mRGBplus , 'Enable', 'on');        
            set(mRGBblock, 'Enable', 'on');        
            set(mRGBwheel, 'Enable', 'on');        
            set(mRGBcube , 'Enable', 'on');        
        else
            set(mRGBplus , 'Enable', 'off');        
            set(mRGBblock, 'Enable', 'off');        
            set(mRGBwheel, 'Enable', 'off');        
            set(mRGBcube , 'Enable', 'off');        
        end
        
        sImageName = getRGBColormapImage('get');
        
        if    strcmpi(sImageName, 'rgb-plus.png')
            set(mRGBplus, 'Checked', 'on');
        elseif strcmpi(sImageName, 'rgb-block.png')
            set(mRGBblock, 'Checked', 'on');
        elseif strcmpi(sImageName, 'rgb-wheel.png')
            set(mRGBwheel, 'Checked', 'on');            
        elseif strcmpi(sImageName, 'rgb-cube.png')
            set(mRGBcube, 'Checked', 'on');        
        else
        end       
    end
    
    if strcmpi(sModality, 'CT')
        
        mF1 = uimenu(e,'Label','(F1) Lung'          , 'Callback',@setCTColorbarWindowLevel);
        mF2 = uimenu(e,'Label','(F2) Soft Tissue'   , 'Callback',@setCTColorbarWindowLevel);
        mF3 = uimenu(e,'Label','(F3) Bone'          , 'Callback',@setCTColorbarWindowLevel);
        mF4 = uimenu(e,'Label','(F4) Liver'         , 'Callback',@setCTColorbarWindowLevel);
        mF5 = uimenu(e,'Label','(F5) Brain'         , 'Callback',@setCTColorbarWindowLevel);
        mF6 = uimenu(e,'Label','(F6) Head and Neck' , 'Callback',@setCTColorbarWindowLevel);
        mF7 = uimenu(e,'Label','(F7) Enchanced Lung', 'Callback',@setCTColorbarWindowLevel);
        mF8 = uimenu(e,'Label','(F8) Mediastinum'   , 'Callback',@setCTColorbarWindowLevel);
        mF91 = uimenu(e,'Label','(F9) Temporal Bone', 'Callback',@setCTColorbarWindowLevel);
        mF92 = uimenu(e,'Label','(F9) Vertebra'     , 'Callback',@setCTColorbarWindowLevel);
%         mF93 = uimenu(e,'Label','(F9) Scout CT'     , 'Callback',@setCTColorbarWindowLevel);
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

            case 'lung'
                set(mF1, 'Checked', 'on');

            case 'soft tissue'
                set(mF2, 'Checked', 'on');

            case 'bone'
                set(mF3, 'Checked', 'on');

            case 'liver'
                set(mF4, 'Checked', 'on');

            case 'brain'
                set(mF5, 'Checked', 'on');

            case 'head and neck'
                set(mF6, 'Checked', 'on');

            case 'enhanced lung'
                set(mF7, 'Checked', 'on');

            case 'mediastinum'
                set(mF8, 'Checked', 'on');

            case 'temporal bone'
                set(mF91, 'Checked', 'on');

            case 'vertebra'
                set(mF92, 'Checked', 'on');

            case 'all'
                set(mF34, 'Checked', 'on');

            otherwise
                set(mCtm, 'Checked', 'on');
        end       
        
    end
    
    uimenu(c,'Label','Parula'       ,'Callback',@setColorOffset);
    uimenu(c,'Label','Jet'          ,'Callback',@setColorOffset);
    uimenu(c,'Label','HSV'          ,'Callback',@setColorOffset);
    uimenu(c,'Label','Hot'          ,'Callback',@setColorOffset);
    uimenu(c,'Label','Cool'         ,'Callback',@setColorOffset);
    uimenu(c,'Label','Spring'       ,'Callback',@setColorOffset);
    uimenu(c,'Label','Summer'       ,'Callback',@setColorOffset);
    uimenu(c,'Label','Autumn'       ,'Callback',@setColorOffset);
    uimenu(c,'Label','Winter'       ,'Callback',@setColorOffset);
    uimenu(c,'Label','Gray'         ,'Callback',@setColorOffset);
    uimenu(c,'Label','Invert Linear','Callback',@setColorOffset);
    uimenu(c,'Label','Bone'         ,'Callback',@setColorOffset);
    uimenu(c,'Label','Copper'       ,'Callback',@setColorOffset);
    uimenu(c,'Label','Pink'         ,'Callback',@setColorOffset);
    uimenu(c,'Label','Lines'        ,'Callback',@setColorOffset);
    uimenu(c,'Label','Colorcube'    ,'Callback',@setColorOffset);
    uimenu(c,'Label','Prism'        ,'Callback',@setColorOffset);
    uimenu(c,'Label','Flag'         ,'Callback',@setColorOffset);
    uimenu(c,'Label','PET'          ,'Callback',@setColorOffset);
    uimenu(c,'Label','Hot Metal'    ,'Callback',@setColorOffset);
    uimenu(c,'Label','Angio'        ,'Callback',@setColorOffset);
    uimenu(c,'Label','Yellow'       ,'Callback',@setColorOffset);
    uimenu(c,'Label','Magenta'      ,'Callback',@setColorOffset);
    uimenu(c,'Label','Cyan'         ,'Callback',@setColorOffset);
    uimenu(c,'Label','Red'          ,'Callback',@setColorOffset);
    uimenu(c,'Label','Green'        ,'Callback',@setColorOffset);
    uimenu(c,'Label','Blue'         ,'Callback',@setColorOffset);
    
    if strcmpi(get(hObject, 'Tag'), 'Fusion Colorbar')
        dOffset = fusionColorMapOffset('get');
    else
        dOffset = colorMapOffset('get');
    end

    switch dOffset
        case 1
            set(findall(c,'Label','Parula'), 'Checked', 'on');
        case 2
            set(findall(c,'Label','Jet'), 'Checked', 'on');
        case 3
            set(findall(c,'Label','HSV'), 'Checked', 'on');
        case 4
            set(findall(c,'Label','Hot'), 'Checked', 'on');
        case 5
            set(findall(c,'Label','Cool'), 'Checked', 'on');
        case 6
            set(findall(c,'Label','Spring'), 'Checked', 'on');
        case 7
            set(findall(c,'Label','Summer'), 'Checked', 'on');
        case 8
            set(findall(c,'Label','Autumn'), 'Checked', 'on');
        case 9
            set(findall(c,'Label','Winter'), 'Checked', 'on');
        case 10
            set(findall(c,'Label','Gray'), 'Checked', 'on');
        case 11
            set(findall(c,'Label','Invert Linear'), 'Checked', 'on');
        case 12
            set(findall(c,'Label','Bone'), 'Checked', 'on');
        case 13
            set(findall(c,'Label','Copper'), 'Checked', 'on');
        case 14
            set(findall(c,'Label','Pink'), 'Checked', 'on');
        case 15
            set(findall(c,'Label','Lines'), 'Checked', 'on');
        case 16
            set(findall(c,'Label','Colorcube'), 'Checked', 'on');
        case 17
            set(findall(c,'Label','Prism'), 'Checked', 'on');
        case 18
            set(findall(c,'Label','Flag'), 'Checked', 'on');
        case 19
            set(findall(c,'Label','PET'), 'Checked', 'on');
        case 20
            set(findall(c,'Label','Hot Metal'), 'Checked', 'on');
        case 21
            set(findall(c,'Label','Angio'), 'Checked', 'on');
        case 22
            set(findall(c,'Label','Yellow'), 'Checked', 'on');
        case 23
            set(findall(c,'Label','Magenta'), 'Checked', 'on');
        case 24
            set(findall(c,'Label','Cyan'), 'Checked', 'on');
        case 25
            set(findall(c,'Label','Red'), 'Checked', 'on');
        case 26
            set(findall(c,'Label','Green'), 'Checked', 'on');
        case 27
            set(findall(c,'Label','Blue'), 'Checked', 'on');                                                
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
        aInput = inputBuffer('get');

        iSeriesOffset = get(uiSeriesPtr('get'), 'Value');
        if iSeriesOffset > numel(tInput)
            return;
        end

        if strcmpi(get(get(hObject, 'Parent'), 'Tag'), 'Fusion Colorbar')

            iFusionOffset   = get(uiFusedSeriesPtr('get'), 'Value');            
            if iFusionOffset > numel(tInput)
                return;
            end
            
            if numel(tInput) == 1
                bEdge = tInput(iFusionOffset).bFusedEdgeDetection;
            else
                bEdge = tInput(iFusionOffset).bEdgeDetection;
            end
            
            if bEdge == true
                
                aBufferImage = dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value'));
                
                tMetaData  = dicomMetaData('get', [], get(uiSeriesPtr('get'), 'Value'));
                if isempty(tMetaData)
                    tMetaData = tInput(iSeriesOffset).atDicomInfo;
                end
                    
                if numel(tInput) == 1
                    tInput(iFusionOffset).bFusedEdgeDetection = false;
                else
                    tInput(iFusionOffset).bEdgeDetection = false;
                end
                
                set(uiSeriesPtr('get'), 'Value', iFusionOffset);
                aFuseImage = dicomBuffer('get');
                if isempty(aFuseImage)
                    aFuseImage = aInput{iFusionOffset};
                end
                
                tFuseMetaData = dicomMetaData('get');
                if isempty(tFuseMetaData)
                    tFuseMetaData = tInput(iFusionOffset).atDicomInfo;
                end
        
                if size(aFuseImage, 3) == 1
                
                    if iSeriesOffset ~= iFusionOffset
                        if tInput(iSeriesOffset).bFlipLeftRight == true
                            aFuseImage=aFuseImage(:,end:-1:1);
                        end

                        if tInput(iSeriesOffset).bFlipAntPost == true
                            aFuseImage=aFuseImage(end:-1:1,:);
                        end
                    end                
                    
                    [x1,y1,~] = size(aBufferImage);
                    aFuseImage = imresize(aFuseImage, [x1 y1]);
                    
                else
                                                            
                    if iSeriesOffset ~= iFusionOffset                
                        if tInput(iSeriesOffset).bFlipLeftRight == true
                            aFuseImage=aFuseImage(:,end:-1:1,:);
                        end

                        if tInput(iSeriesOffset).bFlipAntPost == true
                            aFuseImage=aFuseImage(end:-1:1,:,:);
                        end

                        if tInput(iSeriesOffset).bFlipHeadFeet == true
                            aFuseImage=aFuseImage(:,:,end:-1:1);
                        end
                    end
                                        
                    if strcmpi(imageOrientation('get'), 'coronal')
                        aFuseImage = permute(aFuseImage, [3 2 1]);
                    elseif strcmpi(imageOrientation('get'), 'sagittal')
                        aFuseImage = permute(aFuseImage, [2 3 1]);
                    else
                        aFuseImage = permute(aFuseImage, [1 2 3]);
                    end  
                    
                    
%                    if ( ( tMetaData{1}.ReconstructionDiameter ~= 700 && ...
%                           strcmpi(tMetaData{1}.Modality, 'ct') ) || ...
%                       ( tFuseMetaData{1}.ReconstructionDiameter ~= 700 && ...
%                         strcmpi(tFuseMetaData{1}.Modality, 'ct') ) ) && ...
%                       numel(tMetaData) ~= 1 && ...
%                       numel(tFuseMetaData) ~= 1
                 
                    if numel(aFuseImage) ~= numel(aBufferImage) % Resample image       

                        [aFuseImage, ~] = ...
                            resampleImageTransformMatrix(aFuseImage, ...
                                                         tFuseMetaData, ...
                                                         aBufferImage, ...
                                                         tMetaData, ...
                                                         'linear', ...
                                                         false ...
                                                         );

                    end

%                    else

%                        [aFuseImage, ~] = ...
%                            resampleImage(aFuseImage, ...
%                                          tFuseMetaData, ...
%                                          aBufferImage, ...
%                                          tMetaData, ...
%                                          'linear', ...
%                                          false ...
%                                          );

%                    end
                
              
                end

                set(uiSeriesPtr('get'), 'Value', iSeriesOffset);

                fusionBuffer('set', aFuseImage, get(uiFusedSeriesPtr('get'), 'Value'));           
                        
            else
                
                if numel(tInput) == 1
                    tInput(iFusionOffset).bFusedEdgeDetection = true;
                else
                    tInput(iFusionOffset).bEdgeDetection = true;
                end

                dFudgeFactor = fudgeFactorSegValue('get');
                sMethod = edgeSegMethod('get');

                imf = fusionBuffer('get', [], get(uiFusedSeriesPtr('get'), 'Value'));

                imEdge = getEdgeDetection(imf, sMethod, dFudgeFactor);

                fusionBuffer('set', imEdge, get(uiFusedSeriesPtr('get'), 'Value'));
                
            end
                        
            inputTemplate('set', tInput);

            setFusionColorbarLabel();         
            
            refreshImages();

        end
    end

    function setColorbarWindowLevel(hObject,~)


        tInput = inputTemplate('get');                

        if strcmpi(get(get(hObject, 'Parent'), 'Tag'), 'Fusion Colorbar')

             dColorbarScale = fusionColorbarScale('get');
           
            dMax = fusionWindowLevel('get', 'max');
            dMin = fusionWindowLevel('get', 'min');
            
            dOffset = get(uiFusedSeriesPtr('get'), 'Value');
        
            sUnitDisplay = getSerieUnitValue(dOffset);            

            bDefaultUnit = isFusionColorbarDefaultUnit('get');

        else        

            dColorbarScale = colorbarScale('get');

            dMax = windowLevel('get', 'max');
            dMin = windowLevel('get', 'min');
            
            dOffset = get(uiSeriesPtr('get'), 'Value');
        
            sUnitDisplay = getSerieUnitValue(dOffset);  

            bDefaultUnit = isColorbarDefaultUnit('get');           
        end        
                       
        dlgWindowLevel = ...
            dialog('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-380/2) ...
                                (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-165/2) ...
                                380 ...
                                205 ...
                                ],...
                  'Color', viewerBackgroundColor('get'), ...
                  'Name', 'Lookup Table'...
                   );      

        edtColorbarScale = ...
          uicontrol(dlgWindowLevel,...
                    'style'     , 'edit',...
                    'Background', 'white',...
                    'string'    , num2str(dColorbarScale),...
                    'BackgroundColor', viewerBackgroundColor('get'), ...
                    'ForegroundColor', viewerForegroundColor('get'), ...                 
                    'Callback', @edtColorbarScaleCallback, ...
                    'position'  , [200 165 150 20] ...
                    );

         uicontrol(dlgWindowLevel,...
                  'style'   , 'text',...
                  'string'  , 'Colorbar Scale (%)',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'position', [20 162 150 20]...
                  );

        if strcmpi(sUnitDisplay, 'SUV') || strcmpi(sUnitDisplay, 'HU') 
            if strcmpi(sUnitDisplay, 'HU') 
                if bDefaultUnit == true
                    sUnitDisplay = 'Window Level';            
    
                    [dWindow, dLevel] = computeWindowMinMax(dMax, dMin);
                else
                    sUnitDisplay = 'HU';            
                    
                end
            else
                if bDefaultUnit == true
                    dMax = dMax*tInput(dOffset).tQuant.tSUV.dScale;
                    dMin = dMin*tInput(dOffset).tQuant.tSUV.dScale;
                end
            end
            bUnitEnable = 'on';
        else
            bUnitEnable = 'off';
        end

        if strcmpi(sUnitDisplay, 'SUV') 
            if bDefaultUnit == true
                sSUVtype = viewerSUVtype('get');
                sUnitType = sprintf('Unit in SUV/%s', sSUVtype);
            else
               sUnitType = 'Unit in BQML';
            end
        else
            sUnitType = sprintf('Unit in %s', sUnitDisplay);
        end
    
        chkUnitType = ...
            uicontrol(dlgWindowLevel,...
                      'style'   , 'checkbox',...
                      'enable'  , bUnitEnable,...
                      'value'   , bDefaultUnit,...
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
                    'position'  , [200 90 150 20] ...
                    );
      set(edtMaxValue, 'KeyPressFcn', @checkKeyPress);

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
                    'position'  , [200 65 150 20] ...
                    );
     set(edtMinValue, 'KeyPressFcn', @checkKeyPress);
          
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
               
        function checkKeyPress(~, event)
            if strcmp(event.Key, 'return')
                drawnow;
                proceedWindowLCallback();
            end
        end      
        
        function edtColorbarScaleCallback(hObject, ~)

            if str2double(get(hObject, 'String')) < 0
                set(hObject, 'String', '100');
            end
        end

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
                if contains(lower(get(hChkObject, 'String')), 'suv') 
                    sUnitDisplay = 'BQML';
                else
                    sUnitDisplay = 'HU';
                end            
            else
                if contains(lower(get(hChkObject, 'String')), 'bqml') 
                    sUnitDisplay = 'SUV';
                else
                    sUnitDisplay = 'Window Level';
                end             
            end
            
            if strcmpi(sUnitDisplay, 'SUV')
                sSUVtype  = viewerSUVtype('get');
                sUnitType = sprintf('Unit in SUV/%s', sSUVtype);
            else
                sUnitType = sprintf('Unit in %s', sUnitDisplay);
            end
                                            
            set(txtUnitType, 'String', sUnitType);            
            
            if strcmpi(get(get(hObject, 'Parent'), 'Tag'), 'Fusion Colorbar')

                isFusionColorbarDefaultUnit('set', get(chkUnitType, 'Value'));

                dMaxValue = fusionWindowLevel('get', 'max');
                dMinValue = fusionWindowLevel('get', 'min');  
            else
                isColorbarDefaultUnit('set', get(chkUnitType, 'Value'));

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
                     
            dColorbarScale = str2double(get(edtColorbarScale, 'String'));

            if dColorbarScale < 0
                dColorbarScale = 100;
            end

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

                fusionColorbarScale('set', dColorbarScale);
               
                fusionWindowLevel('set', 'max', lMax);
                fusionWindowLevel('set', 'min' ,lMin);

                getFusionInitWindowMinMax('set', lMax, lMin);

%                 set(uiFusionSliderWindowPtr('get'), 'value', 0.5);
%                 set(uiFusionSliderLevelPtr('get') , 'value', 0.5);

                if switchTo3DMode('get')     == false && ...
                   switchToIsoSurface('get') == false && ...
                   switchToMIPMode('get')    == false

%                     if size(dicomBuffer('get'), 3) == 1            
%                         set(axefPtr('get'), 'CLim', [lMin lMax]);                      
%                     else
%                         set(axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))  , 'CLim', [lMin lMax]);
%                         set(axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))  , 'CLim', [lMin lMax]);
%                         set(axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))  , 'CLim', [lMin lMax]);                        
%                         if link2DMip('get') == true && isVsplash('get') == false
%                             set(axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'CLim', [lMin lMax]);
%                         end                                                                        
%                     end


                    % Compute colorbar line y offset
            
                    dYOffsetMax = computeLineFusionColorbarIntensityMaxYOffset(get(uiFusedSeriesPtr('get'), 'Value'));
                    dYOffsetMin = computeLineFusionColorbarIntensityMinYOffset(get(uiFusedSeriesPtr('get'), 'Value'));

                    % Ajust the intensity 

                    set(lineFusionColorbarIntensityMaxPtr('get'), 'YData', [0.1 0.1]);
                    set(lineFusionColorbarIntensityMinPtr('get'), 'YData', [0.9 0.9]);

                    setFusionColorbarIntensityMaxScaleValue(dYOffsetMax, ...
                                                            fusionColorbarScale('get'), ...
                                                            isFusionColorbarDefaultUnit('get'),...
                                                            get(uiFusedSeriesPtr('get'), 'Value')...
                                                           );
                                                        
                    setFusionColorbarIntensityMinScaleValue(dYOffsetMin, ...
                                                            fusionColorbarScale('get'), ...
                                                            isFusionColorbarDefaultUnit('get'),...
                                                            get(uiFusedSeriesPtr('get'), 'Value')...
                                                            );

                    setFusionAxesIntensity(get(uiFusedSeriesPtr('get'), 'Value'));

                    refreshImages();
                end                 
            else    
                colorbarScale('set', dColorbarScale);
                  
                windowLevel('set', 'max', lMax);
                windowLevel('set', 'min' ,lMin);

                getInitWindowMinMax('set', lMax, lMin);

%                 set(uiSliderWindowPtr('get'), 'value', 0.5);
%                 set(uiSliderLevelPtr('get') , 'value', 0.5);

                if switchTo3DMode('get')     == false && ...
                   switchToIsoSurface('get') == false && ...
                   switchToMIPMode('get')    == false

%                     if size(dicomBuffer('get'), 3) == 1            
%                         set(axePtr('get', [], get(uiSeriesPtr('get'), 'Value')), 'CLim', [lMin lMax]);
%                     else
%                         set(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'CLim', [lMin lMax]);
%                         set(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'CLim', [lMin lMax]);
%                         set(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'CLim', [lMin lMax]);
%                         if link2DMip('get') == true && isVsplash('get') == false
%                             set(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), 'CLim', [lMin lMax]);                  
%                         end 
%                     end

                    % Compute colorbar line y offset
                
                    dYOffsetMax = computeLineColorbarIntensityMaxYOffset(get(uiSeriesPtr('get'), 'Value'));
                    dYOffsetMin = computeLineColorbarIntensityMinYOffset(get(uiSeriesPtr('get'), 'Value'));

                    % Ajust the intensity 

                    set(lineColorbarIntensityMaxPtr('get'), 'YData', [0.1 0.1]);
                    set(lineColorbarIntensityMinPtr('get'), 'YData', [0.9 0.9]);

                    setColorbarIntensityMaxScaleValue(dYOffsetMax, ...
                                                      colorbarScale('get'), ...
                                                      isColorbarDefaultUnit('get'), ...
                                                      get(uiSeriesPtr('get'), 'Value')...
                                                      );

                    setColorbarIntensityMinScaleValue(dYOffsetMin, ...
                                                      colorbarScale('get'), ...
                                                      isColorbarDefaultUnit('get'), ...
                                                      get(uiSeriesPtr('get'), 'Value')...
                                                      );

                    setAxesIntensity(get(uiSeriesPtr('get'), 'Value'));

                    refreshImages();
                end              
            end
            
            delete(dlgWindowLevel)
        end
        
    end

    function setCTColorbarWindowLevel(hObject, ~)
        
        switch lower(get(hObject, 'Label'))

            case '(f1) lung'
                [lMax, lMin] = computeWindowLevel(1200, -500);

            case '(f2) soft tissue'
                [lMax, lMin] = computeWindowLevel(500, 50);

            case '(f3) bone'
                [lMax, lMin] = computeWindowLevel(500, 200);

            case '(f4) liver'
                [lMax, lMin] = computeWindowLevel(240, 40);

            case '(f5) brain'
                [lMax, lMin] = computeWindowLevel(80, 40);

            case '(f6) head and neck'
                [lMax, lMin] = computeWindowLevel(350, 90);

            case '(f7) enchanced lung'
                [lMax, lMin] = computeWindowLevel(2000, -600);

            case '(f8) mediastinum'
                [lMax, lMin] = computeWindowLevel(350, 50);

            case '(f9) temporal bone'
                [lMax, lMin] = computeWindowLevel(1000, 350);

            case '(f9) vertebra'
                [lMax, lMin] = computeWindowLevel(2500, 415);

%             case lower('(F9) Scout CT')
%                 [lMax, lMin] = computeWindowLevel(350, 50);
            case '(f9) all'
                [lMax, lMin] = computeWindowLevel(2000, 0);
            otherwise
                % to do
        end        
             
        if strcmpi(get(get(hObject, 'Parent'), 'Tag'), 'Fusion Colorbar')
            
            fusionWindowLevel('set', 'max', lMax);
            fusionWindowLevel('set', 'min' ,lMin);
                
%             if size(fusionBuffer('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 3) == 1            
%                 set(axefPtr('get'), 'CLim', [lMin lMax]);
%             else
%                 set(axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'CLim', [lMin lMax]);
%                 set(axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'CLim', [lMin lMax]);
%                 set(axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'CLim', [lMin lMax]);                
%                 if link2DMip('get') == true && isVsplash('get') == false
%                     set(axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'CLim', [lMin lMax]);
%                 end                
%             end  

            % Compute colorbar line y offset
    
            dYOffsetMax = computeLineFusionColorbarIntensityMaxYOffset(get(uiFusedSeriesPtr('get'), 'Value'));
            dYOffsetMin = computeLineFusionColorbarIntensityMinYOffset(get(uiFusedSeriesPtr('get'), 'Value'));
            
            % Ajust the intensity 

            set(lineFusionColorbarIntensityMaxPtr('get'), 'YData', [0.1 0.1]);
            set(lineFusionColorbarIntensityMinPtr('get'), 'YData', [0.9 0.9]);

            setFusionColorbarIntensityMaxScaleValue(dYOffsetMax, ...
                                                    fusionColorbarScale('get'), ...
                                                    isFusionColorbarDefaultUnit('get'),...
                                                    get(uiFusedSeriesPtr('get'), 'Value')...
                                                   );
                                                
            setFusionColorbarIntensityMinScaleValue(dYOffsetMin, ...
                                                    fusionColorbarScale('get'), ...
                                                    isFusionColorbarDefaultUnit('get'),...
                                                    get(uiFusedSeriesPtr('get'), 'Value')...
                                                    );

            setFusionAxesIntensity(get(uiFusedSeriesPtr('get'), 'Value'));
        else    
            windowLevel('set', 'max', lMax);
            windowLevel('set', 'min' ,lMin);
            
%             if size(dicomBuffer('get'), 3) == 1            
%                 set(axePtr('get', [], get(uiSeriesPtr('get'), 'Value')), 'CLim', [lMin lMax]);
%             else
%                 set(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'CLim', [lMin lMax]);
%                 set(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'CLim', [lMin lMax]);
%                 set(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'CLim', [lMin lMax]);
%                 if link2DMip('get') == true && isVsplash('get') == false
%                     set(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), 'CLim', [lMin lMax]);                   
%                 end 
%             end

            % Ajust the intensity 

            % Compute colorbar line y offset

            dYOffsetMax = computeLineColorbarIntensityMaxYOffset(get(uiSeriesPtr('get'), 'Value'));
            dYOffsetMin = computeLineColorbarIntensityMinYOffset(get(uiSeriesPtr('get'), 'Value'));

            % Ajust the intensity 

            set(lineColorbarIntensityMaxPtr('get'), 'YData', [0.1 0.1]);
            set(lineColorbarIntensityMinPtr('get'), 'YData', [0.9 0.9]);

            setColorbarIntensityMaxScaleValue(dYOffsetMax, ...
                                              colorbarScale('get'), ...
                                              isColorbarDefaultUnit('get'), ...
                                              get(uiSeriesPtr('get'), 'Value')...
                                              );

            setColorbarIntensityMinScaleValue(dYOffsetMin, ...
                                              colorbarScale('get'), ...
                                              isColorbarDefaultUnit('get'), ...
                                              get(uiSeriesPtr('get'), 'Value')...
                                              );

            setAxesIntensity(get(uiSeriesPtr('get'), 'Value'));
           
        end              
        
    end

    function setMoveAssociatedSeriesCallback(hObject, ~)
        
        bMoveAssociatedSeries = get(hObject, 'Checked');
        
        if bMoveAssociatedSeries == true
            associateRegistrationModality('set', false);
        else
            associateRegistrationModality('set', true);
        end        
    end

    function setMoveUpdateSeriesDescriptionCallback(hObject, ~)
        
        bUpdateSeriesDescription = get(hObject, 'Checked');
        
        if bUpdateSeriesDescription == true
            updateDescription('set', false);
        else
            updateDescription('set', true);
        end        
    end

end
