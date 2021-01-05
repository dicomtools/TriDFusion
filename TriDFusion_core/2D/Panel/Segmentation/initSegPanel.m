function initSegPanel()
%function initSegPanel()
%Segmentation Panel Main Function.
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

    if isempty(dicomBuffer('get'))
         sEnable = 'on';
    else   
        if size(dicomBuffer('get'), 3) == 1
            sEnable = 'off';
        else
            sEnable = 'on';
        end
    end

    % Reset or Proceed

    uicontrol(uiSegPanelPtr('get'),...
              'String','Reset',...
              'Position',[15 470 100 25],...
              'Callback', @resetSegmentationCallback...
              ); 

    % Image segmentation

    uicontrol(uiSegPanelPtr('get'),...
              'style'   , 'text',...
              'FontWeight', 'bold',...
              'string'  , 'Image Segmentation',...
              'horizontalalignment', 'left',...
              'position', [15 420 200 20]...
              );  

    chkClipVoiRoi = ...
        uicontrol(uiSegPanelPtr('get'),...
                  'style'   , 'checkbox',...
                  'enable'  , 'off',...
                  'value'   , 0,...
                  'position', [240 395 20 20],...
                  'Callback', @chkClipVoiRoiCallback...                             
                  );                       

    txtClipVoiRoi = ...                      
        uicontrol(uiSegPanelPtr('get'),...
                  'style'   , 'text',...
                  'enable'  , 'off',...
                  'string'  , 'Crop Under Crop to Value',...
                  'horizontalalignment', 'left',...
                  'position', [15 392 225 20],...
                  'ButtonDownFcn', @chkClipVoiRoiCallback...  
                  );                       

    chkSegmentVoiRoi = ...
        uicontrol(uiSegPanelPtr('get'),...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , 0,...
                  'position', [240 370 20 20],...
                  'Callback', @chkSegmentVoiRoiCallback...                             
                  );                       
    chkVoiRoiSubstractObject('set', chkSegmentVoiRoi);

    txtSegmentVoiRoi = ...                      
        uicontrol(uiSegPanelPtr('get'),...
                  'style'   , 'text',...
                  'enable'  , 'off',...
                  'string'  , 'Lower Treshold Value',...
                  'horizontalalignment', 'left',...
                  'position', [95 367 125 20],...
                  'ButtonDownFcn', @chkSegmentVoiRoiCallback...  
                  );                       

    asSegOperation = {'Subtract', 'Add', 'Multiply', 'Divide'};           
    uiSegOperation = ...
        uicontrol(uiSegPanelPtr('get'), ...
                  'Style'   , 'popup', ...
                  'position'  , [15 370 75 20],...
                  'String'  , asSegOperation, ...
                  'Value'   , 1,...
                  'Enable'  , 'off', ...
                  'Callback', @uiSegmentOperationCallback...                             
                  );                       

     uiRoiVoiSeg = ...
        uicontrol(uiSegPanelPtr('get'), ...
                  'Style'   , 'popup', ...
                  'position'  , [95 340 160 20],...
                  'String'  , ' ', ...
                  'Value'   , 1,...
                  'Enable'  , 'off' ...
                  );                        
     voiRoiSegObject('set', uiRoiVoiSeg);

     imSeg = dicomBuffer('get');              
     if size(imSeg, 3) == 1 
         asSegOptions = {'Entire Image', 'Inside ROI\VOI', 'Outside ROI\VOI'};
     else
         asSegOptions = {'Entire Image', 'Inside ROI\VOI', 'Outside ROI\VOI', 'Inside all slices ROI\VOI', 'Outside all slices ROI\VOI'};
     end

     uiSegAction = ...
        uicontrol(uiSegPanelPtr('get'), ...
                  'Style'   , 'popup', ...
                  'position'  , [15 340 75 20],...
                  'String'  , asSegOptions, ...
                  'Value'   , 1,...
                  'Enable'  , 'on', ...
                  'Callback', @segActionCallback...
                  );                          
     voiRoiActObject('set', uiSegAction);

    uiTxtUpperTreshold = ...
         uicontrol(uiSegPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'Upper Treshold Preview',...
                  'horizontalalignment', 'left',...
                  'position', [15 305 200 20]...
                  );  
     txtVoiRoiUpperTresholdObject('set', uiTxtUpperTreshold);

    uiSliderImageUpperTreshold = ...                  
        uicontrol(uiSegPanelPtr('get'), ...
                  'Style'   , 'Slider', ...
                  'Position', [15 290 175 14], ...
                  'Value'   , imageSegTreshValue('get', 'upper'), ...
                  'Enable'  , 'on', ...
                  'CallBack', @sliderImageUpperTreshCallback ...
                  );
    addlistener(uiSliderImageUpperTreshold,'Value','PreSet',@sliderImageUpperTreshCallback);                 
    sliderVoiRoiUpperTresholdObject('set', uiSliderImageUpperTreshold);

    uiEditImageUpperTreshold = ...
        uicontrol(uiSegPanelPtr('get'), ...
                  'Style'   , 'Edit', ...
                  'Position', [195 290 65 20], ...
                  'String'  , imageSegEditValue('get', 'upper'), ...
                  'Enable'  , 'on', ...
                  'CallBack', @editImageUpperTreshCallback ...
                  );    
    editVoiRoiUpperTresholdObject('set', uiEditImageUpperTreshold);

    if useCropEditValue('get', 'upper') == true
        sCropEditUpperEnable = 'on';
    else
        sCropEditUpperEnable = 'off';
    end

    uiUpperCropValue = ...
        uicontrol(uiSegPanelPtr('get'), ...
                  'Style'   , 'Edit', ...
                  'Position', [195 265 65 20], ...
                  'String'  , num2str(imageCropEditValue('get', 'upper')), ...
                  'Enable'  , sCropEditUpperEnable, ...
                  'Callback', @uiUpperCropValueCallback...                             
                  );  

    txtUpperCropValue = ...
       uicontrol(uiSegPanelPtr('get'),...
                  'style'   , 'text',...
                  'Enable'  , 'inactive', ...
                  'string'  , 'Use Crop Value',...
                  'horizontalalignment', 'left',...
                  'position', [35 262 100 20],...
                  'ButtonDownFcn', @chkUpperTreshUseCropCallback...                             
                  );

    chkUpperTreshUseCrop = ...
        uicontrol(uiSegPanelPtr('get'),...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , ~useCropEditValue('get', 'upper'), ...
                  'position', [15 265 20 20],...
                  'Callback', @chkUpperTreshUseCropCallback...                             
                  );     

        uicontrol(uiSegPanelPtr('get'),...
                  'style'   , 'text',...
                  'Enable'  , 'on', ...
                  'string'  , 'Lower Treshold Preview',...
                  'horizontalalignment', 'left',...
                  'position', [15 230 200 20]...
                  );  

    uiSliderImageLowerTreshold = ...                                  
        uicontrol(uiSegPanelPtr('get'), ...
                  'Style'   , 'Slider', ...
                  'Position', [15 215 175 14], ...
                  'Value'   , imageSegTreshValue('get', 'lower'), ...
                  'Enable'  , 'on', ...
                  'CallBack', @sliderImageLowerTreshCallback ...
                  );
    addlistener(uiSliderImageLowerTreshold,'Value','PreSet',@sliderImageLowerTreshCallback);                 

    uiEditImageLowerTreshold = ...
        uicontrol(uiSegPanelPtr('get'), ...
                  'Style'   , 'Edit', ...
                  'Position', [195 215 65 20], ...
                  'String'  , imageSegEditValue('get', 'lower'), ...
                  'Enable'  , 'on', ...
                  'CallBack', @editImageLowerTreshCallback ...
                  );  

    if useCropEditValue('get', 'lower') == true
        sCropEditLowerEnable = 'on';
    else
        sCropEditLowerEnable = 'off';
    end

    uiLowerCropValue = ...
        uicontrol(uiSegPanelPtr('get'), ...
                  'Style'   , 'Edit', ...
                  'Position', [195 190 65 20], ...
                  'String'  , num2str(imageCropEditValue('get', 'lower')), ...
                  'Enable'  , sCropEditLowerEnable, ...
                  'Callback', @uiLowerCropValueCallback...                             
                  );  

        uicontrol(uiSegPanelPtr('get'),...
                  'style'   , 'text',...
                  'Enable'  , 'Inactive', ...
                  'string'  , 'Use Crop Value',...
                  'horizontalalignment', 'left',...
                  'position', [35 187 100 20],...
                  'ButtonDownFcn', @chkLowerTreshUseCropCallback...                             
                  );

    chkLowerTreshUseCrop = ...
        uicontrol(uiSegPanelPtr('get'),...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , ~useCropEditValue('get', 'lower'), ...
                  'position', [15 190 20 20],...
                  'Callback', @chkLowerTreshUseCropCallback...                             
                  );                       

    btnProceedImageSeg = ...      
        uicontrol(uiSegPanelPtr('get'),...
                  'String','Segment',...
                  'Position',[160 155 100 25],...
                  'Callback', @proceedImageSegCallback...
                  );            

    edtCoefficient = ...
        uicontrol(uiSegPanelPtr('get'),...
                 'enable'    , 'on',...
                 'style'     , 'edit',...
                 'Background', 'white',...
                 'String'    , '1',...
                 'position'  , [115 157 40 20]...
                 );

    uicontrol(uiSegPanelPtr('get'),...
              'style'   , 'text',...
              'string'  , 'Treshold Sensitivity',...
              'horizontalalignment', 'left',...
              'position', [15 155 100 20]...
              ); 

    % CT segmentation

    uicontrol(uiSegPanelPtr('get'),...
              'style'   , 'text',...
              'FontWeight', 'bold',...
              'string'  , 'CT Lung Segmentation',...
              'horizontalalignment', 'left',...
              'position', [15 105 200 20]...
              );  

    uicontrol(uiSegPanelPtr('get'),...
              'style'   , 'text',...
              'string'  , 'Treshold Preview',...
              'horizontalalignment', 'left',...
              'position', [15 80 200 20]...
              );  

    uiSliderLungTreshold = ...
        uicontrol(uiSegPanelPtr('get'), ...
                  'Style'   , 'Slider', ...
                  'Position', [15 65 175 14], ...
                  'Value'   , lungSegTreshValue('get'), ...
                  'Enable'  , sEnable, ...
                  'CallBack', @sliderLungTreshCallback ...
                  );
%      addlistener(uiSliderLungTreshold,'Value','PreSet',@sliderLungTreshCallback);                 

    uiEditLungTreshold = ...
        uicontrol(uiSegPanelPtr('get'), ...
                  'Style'   , 'Edit', ...
                  'Position', [195 65 65 20], ...
                  'String'  , lungSegTreshValue('get'), ...
                  'Enable'  , sEnable, ...
                  'CallBack', @editLungTreshCallback ...
                  ); 

        uicontrol(uiSegPanelPtr('get'),...
                  'String','Segment',...
                  'Position',[160 30 100 25],...
                  'Enable'  , sEnable, ...
                  'Callback', @proceedLungSegCallback...
                  );  
     uiLungPlane = ...
        uicontrol(uiSegPanelPtr('get'), ...
                  'Style'   , 'popup', ...
                  'position'  , [50 33 75 20],...
                  'String'  , {'axial', 'coronal', 'sagittal', 'all'}, ...
                  'Value'   , 4,...
                  'Enable'  , 'on' ...
                  );  

        uicontrol(uiSegPanelPtr('get'),...
                  'style'   , 'text',...
                  'string'  , 'Plane',...
                  'horizontalalignment', 'left',...
                  'position', [15 30 35 20]...
                  ); 

    function uiUpperCropValueCallback(hObject, ~)
        dValue = str2double(get(hObject, 'string'));
        imageCropEditValue('set', 'upper', dValue);    
    end

    function chkUpperTreshUseCropCallback(hObject, ~) 

        if get(chkSegmentVoiRoi, 'Value') == false
            if get(chkUpperTreshUseCrop, 'Value') == true
                if strcmpi(hObject.Style, 'checkbox') 
                    set(chkUpperTreshUseCrop, 'Value', true);
                    set(uiUpperCropValue, 'Enable', 'off');
                    useCropEditValue('set', 'upper', false);
               else
                    set(chkUpperTreshUseCrop, 'Value', false);
                    set(uiUpperCropValue, 'Enable', 'on');
                    useCropEditValue('set', 'upper', true);
               end
            else
                if strcmpi(hObject.Style, 'checkbox') 
                    set(chkUpperTreshUseCrop, 'Value', false);
                    set(uiUpperCropValue, 'Enable', 'on');
                    useCropEditValue('set', 'upper', true);
              else
                    set(chkUpperTreshUseCrop, 'Value', true);
                    set(uiUpperCropValue, 'Enable', 'off');
                    useCropEditValue('set', 'upper', false);
               end
            end   
        end
    end

    function uiLowerCropValueCallback(hObject, ~)
        dValue = str2double(get(hObject, 'string'));
        imageCropEditValue('set', 'lower', dValue);    
    end

    function chkLowerTreshUseCropCallback(hObject, ~) 

        if get(chkLowerTreshUseCrop, 'Value') == true
            if strcmpi(hObject.Style, 'checkbox') 
                set(chkLowerTreshUseCrop, 'Value', true);
                set(uiLowerCropValue, 'Enable', 'off');
                useCropEditValue('set', 'lower', false);
            else
                set(chkLowerTreshUseCrop, 'Value', false);
                set(uiLowerCropValue, 'Enable', 'on');
                useCropEditValue('set', 'lower', true);
            end
        else
            if strcmpi(hObject.Style, 'checkbox') 
                set(chkLowerTreshUseCrop, 'Value', false);
                set(uiLowerCropValue, 'Enable', 'on');
                useCropEditValue('set', 'lower', true);
           else
                set(chkLowerTreshUseCrop, 'Value', true);
                set(uiLowerCropValue, 'Enable', 'off');
                useCropEditValue('set', 'lower', false);
           end
        end                 
    end

    function chkClipVoiRoiCallback(hObject, ~) 

        if get(chkSegmentVoiRoi, 'Value') == true
            if get(chkClipVoiRoi, 'Value') == true
                if strcmpi(hObject.Style, 'checkbox') 
                    set(chkClipVoiRoi, 'Value', true);
                else
                    set(chkClipVoiRoi, 'Value', false);
                end
            else
                if strcmpi(hObject.Style, 'checkbox') 
                    set(chkClipVoiRoi, 'Value', false);
                else
                    set(chkClipVoiRoi, 'Value', true);
                end
            end                 
        end
    end

    function chkSegmentVoiRoiCallback(hObject, ~)                                  

        if get(chkSegmentVoiRoi, 'Value') == true

            if strcmpi(hObject.Style, 'checkbox') 
                set(chkSegmentVoiRoi, 'Value', true);
            else
                set(chkSegmentVoiRoi, 'Value', false);
            end
        else
            if strcmpi(hObject.Style, 'checkbox') 
                set(chkSegmentVoiRoi, 'Value', false);
            else
                set(chkSegmentVoiRoi, 'Value', true);
            end
        end    

        if get(chkSegmentVoiRoi, 'Value') == true

            set(uiSliderImageUpperTreshold, 'Enable', 'off');
            set(uiEditImageUpperTreshold  , 'Enable', 'off');
            set(uiTxtUpperTreshold        , 'Enable', 'off');
            set(btnProceedImageSeg        , 'String', ...
                uiSegOperation.String(get(uiSegOperation, 'Value')));
            set(txtSegmentVoiRoi          , 'Enable', 'inactive');
            set(uiSegOperation            , 'Enable', 'on');                    
            set(chkClipVoiRoi             , 'Enable', 'on');
            set(txtClipVoiRoi             , 'Enable', 'inactive');

            set(uiUpperCropValue    , 'Enable', 'off');
            set(txtUpperCropValue   , 'Enable', 'off');
            set(chkUpperTreshUseCrop, 'Enable', 'off');
        else
            set(uiSliderImageUpperTreshold, 'Enable', 'on');
            set(uiEditImageUpperTreshold  , 'Enable', 'on');
            set(uiTxtUpperTreshold        , 'Enable', 'on');                    
            set(btnProceedImageSeg        , 'String', 'Segment');
            set(txtSegmentVoiRoi          , 'Enable', 'off');
            set(uiSegOperation            , 'Enable', 'off');
            set(chkClipVoiRoi             , 'Enable', 'off');
            set(txtClipVoiRoi             , 'Enable', 'off'); 

            set(txtUpperCropValue   , 'Enable', 'inactive');                    
            set(chkUpperTreshUseCrop, 'Enable', 'on');

            if useCropEditValue('get', 'upper') == true
                set(uiUpperCropValue    , 'Enable', 'on');
            else
                set(uiUpperCropValue    , 'Enable', 'off');
            end

       end

    end

    function uiSegmentOperationCallback(hObject, ~)

        set(btnProceedImageSeg, 'String', ...
            hObject.String(get(hObject, 'Value')));                                
    end

    function segActionCallback(~, ~)

        setVoiRoiSegPopup();

    end

    function sliderImageUpperTreshCallback(~, ~)

        tQuant = quantificationTemplate('get');
        if isempty(tQuant)
            return;
        end    
        
%        dMin = tQuant.tCount.dMin;
%        dMax = tQuant.tCount.dMax;
        
        dMin = imageSegEditValue('get', 'lower');
        dMax = imageSegEditValue('get', 'upper');
        
        dQuantDifference = dMax - dMin;
        dWindow = dQuantDifference /2;

        dUpper = dMax - ((dWindow - (dWindow * get(uiSliderImageUpperTreshold, 'Value'))) / str2double(get(edtCoefficient, 'String')));

        set(uiEditImageUpperTreshold, 'String', num2str(dUpper));

        editImageTreshold();

    end

    function sliderImageLowerTreshCallback(~, ~)

        tQuant = quantificationTemplate('get');
        if isempty(tQuant)
            return;
        end     
                
%        dMin = tQuant.tCount.dMin;
%        dMax = tQuant.tCount.dMax;
        
        dMin = imageSegEditValue('get', 'lower');
        dMax = imageSegEditValue('get', 'upper');

        dQuantDifference = dMax - dMin;
        dWindow = dQuantDifference /2;

        dLower = dMin + ((dWindow * get(uiSliderImageLowerTreshold, 'Value') ) / str2double(get(edtCoefficient, 'String')));

        set(uiEditImageLowerTreshold, 'String', num2str(dLower));

        editImageTreshold();
    end

    function editImageUpperTreshCallback(hObject, ~)
        
        editImageTreshold();
        
        imageSegEditValue('set', 'upper', str2double(get(hObject, 'String')));

    end

    function editImageLowerTreshCallback(hObject, ~)
        
        editImageTreshold();
        
        imageSegEditValue('set', 'lower', str2double(get(hObject, 'String')));

    end

    function editImageTreshold()

        im = dicomBuffer('get');              
        if isempty(im)
            return;
        end

        aobjList = '';

        tRoiInput = roiTemplate('get');
        tVoiInput = voiTemplate('get');

        if ~isempty(tVoiInput) 
            for aa=1:numel(tVoiInput)
                aobjList{numel(aobjList)+1} = tVoiInput{aa};
            end                        
        end

        if ~isempty(tRoiInput)                            
            for cc=1:numel(tRoiInput)
                if isvalid(tRoiInput{cc}.Object)
                    aobjList{numel(aobjList)+1} = tRoiInput{cc};
                end
            end                        
        end 

        if size(im, 3) == 1 

            imAxe = imAxePtr('get');

            if strcmpi(uiSegAction.String{uiSegAction.Value}, 'Entire Image')

                if useCropEditValue('get', 'upper') == true                            
                    im(im  > str2double(get(uiEditImageUpperTreshold, 'String'))) = imageCropEditValue('get', 'upper');
                else
                    im(im  > str2double(get(uiEditImageUpperTreshold, 'String'))) = cropValue('get');
                end

                if useCropEditValue('get', 'lower') == true
                    im(im  < str2double(get(uiEditImageLowerTreshold, 'String'))) = imageCropEditValue('get', 'lower');  
               else
                    im(im  < str2double(get(uiEditImageLowerTreshold, 'String'))) = cropValue('get');  
               end                        

            else

                objRoi = aobjList{uiRoiVoiSeg.Value}.Object;                        

                roiMask = createMask(objRoi, im);
                if strcmpi(uiSegAction.String{uiSegAction.Value}, 'Inside ROI\VOI')
                    roiMask = ~roiMask; 
                end

                aTreshold = im;
                if useCropEditValue('get', 'upper') == true                            
                    aTreshold(aTreshold > str2double(get(uiEditImageUpperTreshold, 'String')) ) = imageCropEditValue('get', 'upper');
                else
                    aTreshold(aTreshold > str2double(get(uiEditImageUpperTreshold, 'String')) ) = cropValue('get');
                end

                if useCropEditValue('get', 'lower') == true
                    aTreshold(aTreshold < str2double(get(uiEditImageLowerTreshold, 'String')) ) = imageCropEditValue('get', 'lower');       
                else
                    aTreshold(aTreshold < str2double(get(uiEditImageLowerTreshold, 'String')) ) = cropValue('get');       
                end                        

                im(roiMask == 0 ) = aTreshold(roiMask == 0);

            end

            imAxe.CData = im;

        else
            imCoronal  = imCoronalPtr ('get');
            imSagittal = imSagittalPtr('get');
            imAxial    = imAxialPtr   ('get');

            iCoronal  = sliceNumber('get', 'coronal' );
            iSagittal = sliceNumber('get', 'sagittal');
            iAxial    = sliceNumber('get', 'axial'   );                   

            if strcmpi(uiSegAction.String{uiSegAction.Value}, 'Entire Image')                    

                if isVsplash('get') == true  

                    imVsplash = im;
                    if useCropEditValue('get', 'upper') == true                            
                        imVsplash(imVsplash > str2double(get(uiEditImageUpperTreshold, 'String')) ) = imageCropEditValue('get', 'upper');
                    else
                        imVsplash(imVsplash > str2double(get(uiEditImageUpperTreshold, 'String')) ) = cropValue('get');
                    end

                    if useCropEditValue('get', 'lower') == true
                        imVsplash(imVsplash < str2double(get(uiEditImageLowerTreshold, 'String')) ) = imageCropEditValue('get', 'lower');       
                    else
                        imVsplash(imVsplash < str2double(get(uiEditImageLowerTreshold, 'String')) ) = cropValue('get');       
                    end 

                    imComputed = computeMontage(imVsplash, 'coronal', iCoronal);

                    imAxSize = size(imCoronal.CData);
                    imComputed = imresize(imComputed, [imAxSize(1) imAxSize(2)]);    

                    imCoronal.CData = imComputed;  

                    imComputed = computeMontage(imVsplash, 'sagittal', iSagittal);

                    imAxSize = size(imSagittal.CData);
                    imComputed = imresize(imComputed, [imAxSize(1) imAxSize(2)]);    

                    imSagittal.CData = imComputed;                             

                    imComputed = computeMontage(imVsplash(:,:,end:-1:1), 'axial', size(dicomBuffer('get'), 3)-sliceNumber('get', 'axial')+1);

                    imAxSize = size(imAxial.CData);
                    imComputed = imresize(imComputed, [imAxSize(1) imAxSize(2)]);    

                    imAxial.CData = imComputed;                                                          

                else
                    aCoronal  = permute(im(iCoronal,:,:), [3 2 1]);
                    aSagittal = permute(im(:,iSagittal,:), [3 1 2]);
                    aAxial    = im(:,:,iAxial); 

                    if useCropEditValue('get', 'upper') == true                            
                        aCoronal(aCoronal > str2double(get(uiEditImageUpperTreshold, 'String')) )   = imageCropEditValue('get', 'upper');
                        aSagittal(aSagittal > str2double(get(uiEditImageUpperTreshold, 'String')) ) = imageCropEditValue('get', 'upper');
                        aAxial(aAxial > str2double(get(uiEditImageUpperTreshold, 'String')) )       = imageCropEditValue('get', 'upper');                                
                    else
                        aCoronal(aCoronal > str2double(get(uiEditImageUpperTreshold, 'String')) )   = cropValue('get');
                        aSagittal(aSagittal > str2double(get(uiEditImageUpperTreshold, 'String')) ) = cropValue('get');
                        aAxial(aAxial > str2double(get(uiEditImageUpperTreshold, 'String')) )       = cropValue('get');
                    end

                    if useCropEditValue('get', 'lower') == true
                        aCoronal(aCoronal < str2double(get(uiEditImageLowerTreshold, 'String')) )   = imageCropEditValue('get', 'lower');       
                        aSagittal(aSagittal < str2double(get(uiEditImageLowerTreshold, 'String')) ) = imageCropEditValue('get', 'lower');
                        aAxial(aAxial < str2double(get(uiEditImageLowerTreshold, 'String')) )       = imageCropEditValue('get', 'lower');                                
                    else
                        aCoronal(aCoronal < str2double(get(uiEditImageLowerTreshold, 'String')) )   = cropValue('get');       
                        aSagittal(aSagittal < str2double(get(uiEditImageLowerTreshold, 'String')) ) = cropValue('get');
                        aAxial(aAxial < str2double(get(uiEditImageLowerTreshold, 'String')) )       = cropValue('get');
                    end                             

                    imCoronal.CData  = aCoronal;
                    imSagittal.CData = aSagittal;
                    imAxial.CData    = aAxial;
                end

            else

                if strcmpi(aobjList{uiRoiVoiSeg.Value}.ObjectType, 'voi')
                    for bb=1:numel(aobjList{uiRoiVoiSeg.Value}.RoisTag)
                        for cc=1:numel(tRoiInput)
                            if isvalid(tRoiInput{cc}.Object) && ...
                               strcmpi(tRoiInput{cc}.Tag, aobjList{uiRoiVoiSeg.Value}.RoisTag{bb}) 
                                objRoi   = tRoiInput{cc}.Object;                        
                                dSliceNb = tRoiInput{cc}.SliceNb;   

                                if objRoi.Parent  == axes1Ptr('get') && ...
                                   iCoronal == dSliceNb                                        
                                    tresholdVoiRoi(im, objRoi, dSliceNb, false, false);                                         
                                    return;
                                end    
                                if objRoi.Parent  == axes2Ptr('get') && ...
                                   iSagittal == dSliceNb                                        
                                    tresholdVoiRoi(im, objRoi, dSliceNb, false, false);                                         
                                    return;
                                end
                                if objRoi.Parent  == axes3Ptr('get') && ...
                                   iAxial == dSliceNb                                        
                                    tresholdVoiRoi(im, objRoi, dSliceNb, false, false);                                         
                                    return;
                                end                                                                                
                            end
                        end
                    end
                else
                    objRoi   = aobjList{uiRoiVoiSeg.Value}.Object;                        
                    dSliceNb = aobjList{uiRoiVoiSeg.Value}.SliceNb;

                    tresholdVoiRoi(im, objRoi, dSliceNb, false, true);
                end

            end                    

        end                       
    end

    function im = tresholdVoiRoi(im, objRoi, dSliceNb, bMathOperation, bUpdateScreen)                

        if isempty(axes1Ptr('get')) && ...
           isempty(axes2Ptr('get')) && ...
           isempty(axes3Ptr('get')) 

            roiMask = createMask(objRoi, im);

            if bMathOperation == true
                if strcmpi(uiSegAction.String{get(uiSegAction, 'Value')}, 'Outside ROI\VOI') 
                    roiMask = ~roiMask; 
                end

                switch uiSegOperation.String{get(uiSegOperation, 'Value')}
                    case 'Subtract'

                       im(roiMask) = im(roiMask) - str2double(get(uiEditImageLowerTreshold, 'String'));

                    case 'Add'
                        im(roiMask) = im(roiMask) + str2double(get(uiEditImageLowerTreshold, 'String'));

                    case 'Multiply'
                        im(roiMask) = im(roiMask) * str2double(get(uiEditImageLowerTreshold, 'String'));

                    case 'Divide'

                        im(roiMask) = im(roiMask) / str2double(get(uiEditImageLowerTreshold, 'String'));

                    otherwise    
                end

                aTreshold = im;                                
                if get(chkClipVoiRoi, 'value') == true % Clip under crop value
                    aTreshold(aTreshold < cropValue('get') ) = cropValue('get');
                end
                im(roiMask) = aTreshold(roiMask);                       
            end

        else
            imCoronal  = imCoronalPtr ('get');
            imSagittal = imSagittalPtr('get');
            imAxial    = imAxialPtr   ('get');

            if objRoi.Parent == axes1Ptr('get')

                if dSliceNb == 0 % all slices

                    dBufferSize = size(im);   
                    for iCoronal=1:dBufferSize(1)
                        aCoronal = permute(im(iCoronal,:,:), [3 2 1]);

                        roiMask = createMask(objRoi, aCoronal);

                        if bMathOperation == true
                            if strcmpi(uiSegAction.String{get(uiSegAction, 'Value')}, 'Outside all slices ROI\VOI') 
                                roiMask = ~roiMask; 
                            end

                            switch uiSegOperation.String{get(uiSegOperation, 'Value')}
                                case 'Subtract'
                                    aCoronal(roiMask) = aCoronal(roiMask) - str2double(get(uiEditImageLowerTreshold, 'String')); 

                                case 'Add'
                                    aCoronal(roiMask) = aCoronal(roiMask) + str2double(get(uiEditImageLowerTreshold, 'String'));

                                case 'Multiply'
                                    aCoronal(roiMask) = aCoronal(roiMask) * str2double(get(uiEditImageLowerTreshold, 'String'));

                                case 'Divide'
                                    aCoronal(roiMask) = aCoronal(roiMask) / str2double(get(uiEditImageLowerTreshold, 'String'));

                                otherwise    
                            end                                  

                            aTreshold = aCoronal;                                            
                            if get(chkClipVoiRoi, 'value')  == true % Clip under crop value                                          
                                aTreshold(aTreshold < cropValue('get') ) = cropValue('get'); 
                            end                                            
                            aCoronal(roiMask) = aTreshold(roiMask);

                        else
                            if strcmpi(uiSegAction.String{get(uiSegAction, 'Value')}, 'Inside all slices ROI\VOI') 
                                roiMask = ~roiMask; 
                            end        

                            aTreshold = aCoronal;

                            if useCropEditValue('get', 'upper') == true
                                aTreshold(aTreshold > str2double(get(uiEditImageUpperTreshold, 'String')) ) = imageCropEditValue('get', 'upper');
                            else
                                aTreshold(aTreshold > str2double(get(uiEditImageUpperTreshold, 'String')) ) = cropValue('get');
                            end

                            if useCropEditValue('get', 'lower') == true
                                aTreshold(aTreshold < str2double(get(uiEditImageLowerTreshold, 'String')) ) = imageCropEditValue('get', 'lower');      
                            else
                                aTreshold(aTreshold < str2double(get(uiEditImageLowerTreshold, 'String')) ) = cropValue('get');      
                            end

                            aCoronal(roiMask == 0) = aTreshold(roiMask == 0); 
                        end

                        im(iCoronal,:,:) = permuteBuffer(aCoronal, 'coronal');     
                    end    
                else % Image preview and one slice
                    sliceNumber('set', 'coronal', dSliceNb);
                    if bUpdateScreen == true
                        refreshImages();   
                    end

                    iCoronal = dSliceNb;
                    aCoronal = permute(im(iCoronal,:,:), [3 2 1]);

                    roiMask = createMask(objRoi, aCoronal);

                    if bMathOperation == true
                        if strcmpi(uiSegAction.String{get(uiSegAction, 'Value')}, 'Outside ROI\VOI') ||...
                           strcmpi(uiSegAction.String{get(uiSegAction, 'Value')}, 'Outside all slices ROI\VOI') 
                            roiMask = ~roiMask; 
                        end    

                        switch uiSegOperation.String{get(uiSegOperation, 'Value')}
                            case 'Subtract'
                                aCoronal(roiMask) = aCoronal(roiMask) - str2double(get(uiEditImageLowerTreshold, 'String'));

                            case 'Add'
                                aCoronal(roiMask) = aCoronal(roiMask) + str2double(get(uiEditImageLowerTreshold, 'String'));

                           case 'Multiply'
                                aCoronal(roiMask) = aCoronal(roiMask) * str2double(get(uiEditImageLowerTreshold, 'String'));

                            case 'Divide'
                                aCoronal(roiMask) = aCoronal(roiMask) / str2double(get(uiEditImageLowerTreshold, 'String'));

                            otherwise    
                        end

                        aTreshold = aCoronal;

                        if get(chkClipVoiRoi, 'value') == true % Clip under crop value                                            
                            aTreshold(aTreshold < cropValue('get') ) = cropValue('get');
                        end

                        aCoronal(roiMask) = aTreshold(roiMask);

                    else
                        if strcmpi(uiSegAction.String{get(uiSegAction, 'Value')}, 'Inside ROI\VOI') || ...
                           strcmpi(uiSegAction.String{get(uiSegAction, 'Value')}, 'Inside all slices ROI\VOI') 
                            roiMask = ~roiMask; 
                        end

                        aTreshold = aCoronal;
                        if useCropEditValue('get', 'upper') == true
                            aTreshold(aTreshold > str2double(get(uiEditImageUpperTreshold, 'String')) ) = imageCropEditValue('get', 'upper');
                        else
                            aTreshold(aTreshold > str2double(get(uiEditImageUpperTreshold, 'String')) ) = cropValue('get');
                        end

                        if useCropEditValue('get', 'lower') == true
                            aTreshold(aTreshold < str2double(get(uiEditImageLowerTreshold, 'String')) ) = imageCropEditValue('get', 'lower');       
                        else
                            aTreshold(aTreshold < str2double(get(uiEditImageLowerTreshold, 'String')) ) = cropValue('get');       
                        end

                        aCoronal(roiMask == 0) = aTreshold(roiMask == 0);
                    end

                    im(iCoronal,:,:) = permuteBuffer(aCoronal , 'coronal');

                    if isVsplash('get') == true    
                        imComputed = computeMontage(im, 'coronal', iCoronal);

                        imAxSize = size(imCoronal.CData);
                        imComputed = imresize(imComputed, [imAxSize(1) imAxSize(2)]);    

                        imCoronal.CData = imComputed;                                 
                    else
                        imCoronal.CData = aCoronal;
                    end

                end

            end 

            if objRoi.Parent == axes2Ptr('get')

                if dSliceNb == 0 % all slices
                    dBufferSize = size(im);   
                    for iSagittal=1:dBufferSize(2)
                        aSagittal = permute(im(:,iSagittal,:), [3 1 2]);

                        roiMask = createMask(objRoi, aSagittal);

                        if bMathOperation == true
                            if strcmpi(uiSegAction.String{get(uiSegAction, 'Value')}, 'Outside all slices ROI\VOI') 
                                roiMask = ~roiMask; 
                            end

                            switch uiSegOperation.String{get(uiSegOperation, 'Value')}
                                case 'Subtract'
                                    aSagittal(roiMask) = aSagittal(roiMask) - str2double(get(uiEditImageLowerTreshold, 'String'));

                                case 'Add'
                                    aSagittal(roiMask) = aSagittal(roiMask) + str2double(get(uiEditImageLowerTreshold, 'String'));

                               case 'Multiply'
                                    aSagittal(roiMask) = aSagittal(roiMask) * str2double(get(uiEditImageLowerTreshold, 'String'));

                                case 'Divide'
                                    aSagittal(roiMask) = aSagittal(roiMask) / str2double(get(uiEditImageLowerTreshold, 'String'));

                                otherwise    
                            end

                            aTreshold = aSagittal;

                            if get(chkClipVoiRoi, 'value') == true % Clip under crop value                                            
                                aTreshold(aTreshold < cropValue('get') ) = cropValue('get');
                            end

                            aSagittal(roiMask) = aTreshold(roiMask);

                        else
                            if strcmpi(uiSegAction.String{get(uiSegAction, 'Value')}, 'Inside all slices ROI\VOI') 
                                roiMask = ~roiMask; 
                            end

                            aTreshold = aSagittal;
                            if useCropEditValue('get', 'upper') == true
                                aTreshold(aTreshold > str2double(get(uiEditImageUpperTreshold, 'String')) ) = imageCropEditValue('get', 'upper');
                            else
                                aTreshold(aTreshold > str2double(get(uiEditImageUpperTreshold, 'String')) ) = cropValue('get');
                            end

                            if useCropEditValue('get', 'lower') == true
                                aTreshold(aTreshold < str2double(get(uiEditImageLowerTreshold, 'String')) ) = imageCropEditValue('get', 'lower');      
                            else
                                aTreshold(aTreshold < str2double(get(uiEditImageLowerTreshold, 'String')) ) = cropValue('get');      
                            end

                            aSagittal(roiMask == 0) = aTreshold(roiMask == 0);      
                        end
                        im(:,iSagittal,:) = permuteBuffer(aSagittal, 'sagittal');     
                    end                         
                else % Image preview and one slice
                    sliceNumber('set', 'sagittal', dSliceNb);
                    if bUpdateScreen == true
                        refreshImages();   
                    end

                    iSagittal = dSliceNb;                           
                    aSagittal = permute(im(:,iSagittal,:), [3 1 2]);

                    roiMask = createMask(objRoi, aSagittal);

                    if bMathOperation == true

                        if strcmpi(uiSegAction.String{get(uiSegAction, 'Value')}, 'Outside ROI\VOI') ||...
                           strcmpi(uiSegAction.String{get(uiSegAction, 'Value')}, 'Outside all slices ROI\VOI') 
                            roiMask = ~roiMask; 
                        end  

                        switch uiSegOperation.String{get(uiSegOperation, 'Value')}

                            case 'Subtract'
                                aSagittal(roiMask) = aSagittal(roiMask) - str2double(get(uiEditImageLowerTreshold, 'String'));

                            case 'Add'
                                aSagittal(roiMask) = aSagittal(roiMask) + str2double(get(uiEditImageLowerTreshold, 'String'));

                           case 'Multiply'
                                aSagittal(roiMask) = aSagittal(roiMask) * str2double(get(uiEditImageLowerTreshold, 'String'));

                            case 'Divide'
                                aSagittal(roiMask) = aSagittal(roiMask) / str2double(get(uiEditImageLowerTreshold, 'String'));

                            otherwise    
                        end

                        aTreshold = aSagittal;

                        if get(chkClipVoiRoi, 'value')  == true % Clip under crop value                                            
                            aTreshold(aTreshold < cropValue('get') ) = cropValue('get');
                        end

                        aSagittal(roiMask) = aTreshold(roiMask);

                    else
                        if strcmpi(uiSegAction.String{get(uiSegAction, 'Value')}, 'Inside ROI\VOI') || ...
                           strcmpi(uiSegAction.String{get(uiSegAction, 'Value')}, 'Inside all slices ROI\VOI')  
                            roiMask = ~roiMask; 
                        end

                        aTreshold = aSagittal;
                        if useCropEditValue('get', 'upper') == true
                            aTreshold(aTreshold > str2double(get(uiEditImageUpperTreshold, 'String')) ) = imageCropEditValue('get', 'upper');
                        else
                            aTreshold(aTreshold > str2double(get(uiEditImageUpperTreshold, 'String')) ) = cropValue('get');
                        end

                        if useCropEditValue('get', 'lower') == true
                            aTreshold(aTreshold < str2double(get(uiEditImageLowerTreshold, 'String')) ) = imageCropEditValue('get', 'lower');       
                        else
                            aTreshold(aTreshold < str2double(get(uiEditImageLowerTreshold, 'String')) ) = cropValue('get');       
                        end                                

                        aSagittal(roiMask == 0) = aTreshold(roiMask == 0);
                    end     

                    im(:,iSagittal,:) = permuteBuffer(aSagittal, 'sagittal');

                    if isVsplash('get') == true     
                        imComputed = computeMontage(im, 'sagittal', iSagittal);

                        imAxSize = size(imSagittal.CData);
                        imComputed = imresize(imComputed, [imAxSize(1) imAxSize(2)]);    

                        imSagittal.CData = imComputed;
                    else
                        imSagittal.CData = aSagittal;
                    end                            

                end
            end                        

            if objRoi.Parent == axes3Ptr('get')
                if dSliceNb == 0 % all slices
                    dBufferSize = size(im);   
                    for iAxial=1:dBufferSize(3)
                        aAxial = im(:,:,iAxial);

                        roiMask = createMask(objRoi, aAxial);

                        if bMathOperation == true
                            if strcmpi(uiSegAction.String{get(uiSegAction, 'Value')}, 'Outside all slices ROI\VOI') 
                                roiMask = ~roiMask; 
                            end
                            switch uiSegOperation.String{get(uiSegOperation, 'Value')}
                                case 'Subtract'
                                    aAxial(roiMask) = aAxial(roiMask) - str2double(get(uiEditImageLowerTreshold, 'String'));

                                case 'Add'
                                    aAxial(roiMask) = aAxial(roiMask) + str2double(get(uiEditImageLowerTreshold, 'String'));

                               case 'Multiply'
                                    aAxial(roiMask) = aAxial(roiMask) * str2double(get(uiEditImageLowerTreshold, 'String'));

                                case 'Divide'
                                    aAxial(roiMask) = aAxial(roiMask) / str2double(get(uiEditImageLowerTreshold, 'String'));

                                otherwise    
                            end

                            aTreshold = aAxial;

                            if get(chkClipVoiRoi, 'value') == true % Clip under crop value                                            
                                aTreshold(aTreshold < cropValue('get') ) = cropValue('get');
                            end

                            aAxial(roiMask) = aTreshold(roiMask);  

                        else
                            if strcmpi(uiSegAction.String{get(uiSegAction, 'Value')}, 'Inside all slices ROI\VOI') 
                                roiMask = ~roiMask; 
                            end

                            aTreshold = aAxial;
                            if useCropEditValue('get', 'upper') == true
                                aTreshold(aTreshold > str2double(get(uiEditImageUpperTreshold, 'String')) ) = imageCropEditValue('get', 'upper');
                            else
                                aTreshold(aTreshold > str2double(get(uiEditImageUpperTreshold, 'String')) ) = cropValue('get');
                            end

                            if useCropEditValue('get', 'lower') == true
                                aTreshold(aTreshold < str2double(get(uiEditImageLowerTreshold, 'String')) ) = imageCropEditValue('get', 'lower');      
                            else
                                aTreshold(aTreshold < str2double(get(uiEditImageLowerTreshold, 'String')) ) = cropValue('get');      
                            end    

                            aAxial(roiMask == 0) = aTreshold(roiMask == 0);     
                        end

                        im(:,:,iAxial) = aAxial;     
                    end                           
                else % Image preview and one slice                    
                    sliceNumber('set', 'axial', dSliceNb);
                    if bUpdateScreen == true
                        refreshImages();   
                    end

                    iAxial = dSliceNb;
                    aAxial = im(:,:,iAxial);

                    roiMask = createMask(objRoi, aAxial);

                    if bMathOperation == true

                        if strcmpi(uiSegAction.String{get(uiSegAction, 'Value')}, 'Outside ROI\VOI') ||...
                           strcmpi(uiSegAction.String{get(uiSegAction, 'Value')}, 'Outside all slices ROI\VOI') 
                            roiMask = ~roiMask; 
                        end              

                        switch uiSegOperation.String{get(uiSegOperation, 'Value')}

                            case 'Subtract'
                                aAxial(roiMask) = aAxial(roiMask) - str2double(get(uiEditImageLowerTreshold, 'String'));

                            case 'Add'
                                aAxial(roiMask) = aAxial(roiMask) + str2double(get(uiEditImageLowerTreshold, 'String'));

                           case 'Multiply'
                                aAxial(roiMask) = aAxial(roiMask) * str2double(get(uiEditImageLowerTreshold, 'String'));

                            case 'Divide'
                                aAxial(roiMask) = aAxial(roiMask) / str2double(get(uiEditImageLowerTreshold, 'String'));

                            otherwise    
                        end

                        aTreshold = aAxial;

                        if get(chkClipVoiRoi, 'value') == true % Clip under crop value                                           
                            aTreshold(aTreshold < cropValue('get') ) = cropValue('get');
                        end

                        aAxial(roiMask) = aTreshold(roiMask); 

                    else
                        if strcmpi(uiSegAction.String{get(uiSegAction, 'Value')}, 'Inside ROI\VOI') || ...
                           strcmpi(uiSegAction.String{get(uiSegAction, 'Value')}, 'Inside all slices ROI\VOI')  
                            roiMask = ~roiMask; 
                        end

                        aTreshold = aAxial;
                        if useCropEditValue('get', 'upper') == true
                            aTreshold(aTreshold > str2double(get(uiEditImageUpperTreshold, 'String')) ) = imageCropEditValue('get', 'upper');
                        else
                            aTreshold(aTreshold > str2double(get(uiEditImageUpperTreshold, 'String')) ) = cropValue('get');
                        end

                        if useCropEditValue('get', 'lower') == true
                            aTreshold(aTreshold < str2double(get(uiEditImageLowerTreshold, 'String')) ) = imageCropEditValue('get', 'lower');       
                        else
                            aTreshold(aTreshold < str2double(get(uiEditImageLowerTreshold, 'String')) ) = cropValue('get');       
                        end                                   

                        aAxial(roiMask == 0) = aTreshold(roiMask == 0);
                    end

                    im(:,:,iAxial) = aAxial;

                    if isVsplash('get') == true     
                        imComputed = computeMontage(im(:,:,end:-1:1), 'axial', size(dicomBuffer('get'), 3)-sliceNumber('get', 'axial')+1);

                        imAxSize = size(imAxial.CData);
                        imComputed = imresize(imComputed, [imAxSize(1) imAxSize(2)]);

                        imAxial.CData = imComputed;  
                    else
                        imAxial.CData  = aAxial;
                    end

                end
            end
        end                         
    end

    function proceedImageSegCallback(~, ~)

        im = dicomBuffer('get');
        if isempty(im)
            return;
        end

        aobjList = '';

        tRoiInput = roiTemplate('get');
        tVoiInput = voiTemplate('get');

        if ~isempty(tVoiInput) 
            for aa=1:numel(tVoiInput)
                aobjList{numel(aobjList)+1} = tVoiInput{aa};
            end                        
        end

        if ~isempty(tRoiInput)                            
            for cc=1:numel(tRoiInput)
                if isvalid(tRoiInput{cc}.Object)
                    aobjList{numel(aobjList)+1} = tRoiInput{cc};
                end
            end                        
        end 

        if strcmpi(uiSegAction.String{uiSegAction.Value}, 'Entire Image')
            if get(chkSegmentVoiRoi, 'Value') == true

                switch uiSegOperation.String{get(uiSegOperation, 'Value')}
                    case 'Subtract'
                        im = im - str2double(get(uiEditImageLowerTreshold, 'String'));                             

                    case 'Add'
                        im = im + str2double(get(uiEditImageLowerTreshold, 'String'));

                    case 'Multiply'
                        im = im * str2double(get(uiEditImageLowerTreshold, 'String'));

                    case 'Divide'
                        im = im / str2double(get(uiEditImageLowerTreshold, 'String'));

                    otherwise    
                end

                aTreshold = im;

                if get(chkClipVoiRoi, 'value') == true % Clip under crop value                                         
                    aTreshold(aTreshold < cropValue('get') ) = cropValue('get'); 
                end

                im = aTreshold;   

            else
                if useCropEditValue('get', 'upper') == true
                    im(im  > str2double(get(uiEditImageUpperTreshold, 'String'))) = imageCropEditValue('get', 'upper');
                else
                    im(im  > str2double(get(uiEditImageUpperTreshold, 'String'))) = cropValue('get');
                end

                if useCropEditValue('get', 'lower') == true
                    im(im  < str2double(get(uiEditImageLowerTreshold, 'String'))) = imageCropEditValue('get', 'lower');
                else
                    im(im  < str2double(get(uiEditImageLowerTreshold, 'String'))) = cropValue('get');
                end                          
            end
        else
            if strcmpi(aobjList{uiRoiVoiSeg.Value}.ObjectType, 'voi')
                for bb=1:numel(aobjList{get(uiRoiVoiSeg, 'Value')}.RoisTag)
                    for cc=1:numel(tRoiInput)
                        if isvalid(tRoiInput{cc}.Object) && ...
                            strcmpi(tRoiInput{cc}.Tag, aobjList{get(uiRoiVoiSeg, 'Value')}.RoisTag{bb}) 
                            objRoi   = tRoiInput{cc}.Object;                        
                            dSliceNb = tRoiInput{cc}.SliceNb;   

                            if strcmpi(uiSegAction.String{get(uiSegAction, 'Value')}, 'Inside ROI\VOI') || ...
                               strcmpi(uiSegAction.String{get(uiSegAction, 'Value')}, 'Outside ROI\VOI')                       
                                im = tresholdVoiRoi(im, objRoi, dSliceNb, get(chkSegmentVoiRoi, 'Value'), false);                                         
                            else
                                im = tresholdVoiRoi(im, objRoi, 0, get(chkSegmentVoiRoi, 'Value'), false);                                         
                            end
                         end
                    end
                end
            else
                objRoi   = aobjList{uiRoiVoiSeg.Value}.Object;                        
                dSliceNb = aobjList{uiRoiVoiSeg.Value}.SliceNb;                       

                if strcmpi(uiSegAction.String{get(uiSegAction, 'Value')}, 'Inside ROI\VOI') || ...
                   strcmpi(uiSegAction.String{get(uiSegAction, 'Value')}, 'Outside ROI\VOI') 
                    im = tresholdVoiRoi(im, objRoi, dSliceNb, get(chkSegmentVoiRoi, 'Value'), false);
                else
                    im = tresholdVoiRoi(im, objRoi, 0, get(chkSegmentVoiRoi, 'Value'), false);
               end
            end                    
        end

        dicomBuffer('set', im);

        iOffset = get(uiSeriesPtr('get'), 'Value');
        
        setQuantification(iOffset);

        refreshImages();

    end

    function sliderLungTreshCallback(hObject, ~)     

   %     resetSegmentationCallback();

        lungSegmentationPreview(hObject.Value)

        set(uiEditLungTreshold, 'String', num2str(hObject.Value) );

    end

    function editLungTreshCallback(hObject, ~)

        if str2double(hObject.String) < 0
            hObject.String = '0';
        end

  %      resetSegmentationCallback();

        lungSegmentationPreview(str2double(hObject.String));  

        if str2double(hObject.String) > 1
            set(uiSliderLungTreshold, 'Value', 1);
        else
            set(uiSliderLungTreshold, 'Value', str2double(hObject.String) ); 
        end
    end

    function resetSegmentationCallback(~, ~) 

        tInitInput = inputTemplate('get');        
        iOffset = get(uiSeriesPtr('get'), 'Value');
        if iOffset > numel(tInitInput)  
            return;
        end

        aInput = inputBuffer('get');

        if ~strcmp(imageOrientation('get'), 'axial')                                            
            imageOrientation('set', 'axial');            
        end

        if     strcmp(imageOrientation('get'), 'axial')
            aBuffer = permute(aInput{iOffset}, [1 2 3]);
        elseif strcmp(imageOrientation('get'), 'coronal') 
            aBuffer = permute(aInput{iOffset}, [3 2 1]);    
        elseif strcmp(imageOrientation('get'), 'sagittal')
            aBuffer = permute(aInput{iOffset}, [3 1 2]);
        end   
if 0
        if numel(tInitInput(iOffset).asFilesList) ~= 1

            if ~isempty(tInitInput(iOffset).atDicomInfo{1}.ImagePositionPatient)

                if tInitInput(iOffset).atDicomInfo{2}.ImagePositionPatient(3) - ...
                   tInitInput(iOffset).atDicomInfo{1}.ImagePositionPatient(3) > 0
                    aBuffer = aBuffer(:,:,end:-1:1);                   

                end
            end            
        else
            if strcmpi(tInitInput(iOffset).atDicomInfo{1}.PatientPosition, 'FFS')
                aBuffer = aBuffer(:,:,end:-1:1);                   
            end
        end  
end                                                                                                                                  
        dicomBuffer('set',aBuffer);    

        dicomMetaData('set', tInitInput(iOffset).atDicomInfo);

        setQuantification(iOffset);

        fusionBuffer('reset');
        isFusion('set', false);
        set(btnFusionPtr('get'), 'BackgroundColor', 'default');

        clearDisplay();                       
        initDisplay(3); 

        initWindowLevel('set', true);
        quantificationTemplate('set', tInitInput(iOffset).tQuant);

        dicomViewerCore();     

        triangulateCallback();     

%         aInput = inputBuffer('get');  
%         dicomBuffer('set', aInput{iOffset});                                                           

%         setQuantification(iOffset);


        refreshImages();

    end

    function proceedLungSegCallback(~, ~) 

        lungSegmentation(uiLungPlane.String{get(uiLungPlane, 'Value')}, str2double(get(uiEditLungTreshold, 'String')));
        lungSegTreshValue('set', str2double(get(uiEditLungTreshold, 'String')));                

    end
end
