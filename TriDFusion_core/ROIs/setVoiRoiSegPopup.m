function setVoiRoiSegPopup()
%function setVoiRoiSegPopup()
%Init Segmentation ROI VOI Popup Menu .
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


    uiSegActRoiPanel = uiSegActRoiPanelObject('get');
    uiRoiVoiRoiPanel = uiRoiVoiRoiPanelObject('get');

    uiSegAction = voiRoiActObject('get');
    uiRoiVoiSeg = voiRoiSegObject('get');  

    uiChkSubtractVoiRoi         = chkVoiRoiSubstractObject('get');            
    uiEditVoiRoiUpperTreshold   = editVoiRoiUpperTresholdObject('get');
    uiSliderVoiRoiUpperTreshold = sliderVoiRoiUpperTresholdObject('get');
    uiTxtVoiRoiUpperTreshold    = txtVoiRoiUpperTresholdObject('get');
    
    if strcmpi(uiSegActRoiPanel.String{uiSegActRoiPanel.Value}, 'Entire Image') 
        set(uiRoiVoiRoiPanel, 'Value' , 1);
        set(uiRoiVoiRoiPanel, 'Enable', 'off');                        
        set(uiRoiVoiRoiPanel, 'String', ' ');    
  
        roiPanelMinValue('set', min(double(dicomBuffer('get')),[], 'all'));
        roiPanelMaxValue('set', max(double(dicomBuffer('get')),[], 'all'));         
        
        
    else
         asList = '';

        tRoiInput = roiTemplate('get');
        tVoiInput = voiTemplate('get');

        if ~isempty(tVoiInput) 
            for aa=1:numel(tVoiInput)
                asList{numel(asList)+1} = tVoiInput{aa}.Label;
            end                        
        end

        if ~isempty(tRoiInput) 

            for cc=1:numel(tRoiInput)
               if isvalid(tRoiInput{cc}.Object)
                    asList{numel(asList)+1} = tRoiInput{cc}.Label;
                end
            end                        
        end 

        if numel(asList) ~= 0
        %    set(uiTxtSubtractVoiRoi, 'Enable', 'inactive');                        
        %    set(uiChkSubtractVoiRoi, 'Enable', 'on');     

            set(uiRoiVoiRoiPanel, 'Enable', 'on');
            set(uiRoiVoiRoiPanel, 'String', asList);
            
           [dComputedMin, dComputedMax] = computeRoiPanelMinMax();
           
            roiPanelMinValue('set', dComputedMin);
            roiPanelMaxValue('set', dComputedMax);            

        else
            set(uiSegActRoiPanel, 'Value' , 1);
            set(uiRoiVoiRoiPanel, 'Enable', 'off');
            set(uiRoiVoiRoiPanel, 'String', ' ');  
            
            roiPanelMinValue('set', min(double(dicomBuffer('get')),[], 'all'));
            roiPanelMaxValue('set', max(double(dicomBuffer('get')),[], 'all'));                          
        end       
                     
    end
    
    
    if strcmpi(uiSegAction.String{uiSegAction.Value}, 'Entire Image') 

        set(uiRoiVoiSeg, 'Value' , 1);
        set(uiRoiVoiSeg, 'Enable', 'off');                        
        set(uiRoiVoiSeg, 'String', ' ');

   %     set(uiTxtSubtractVoiRoi, 'Enable', 'off');                        
   %     set(uiChkSubtractVoiRoi, 'Enable', 'off');     

        if get(uiChkSubtractVoiRoi, 'Value') == false
            set(uiEditVoiRoiUpperTreshold  , 'Enable', 'on');  
            set(uiSliderVoiRoiUpperTreshold, 'Enable', 'on'); 
            set(uiTxtVoiRoiUpperTreshold   , 'Enable', 'on');                                                 
        end

   %     set(uiProceedImageSeg, 'String', 'Segment');                                       

    else

        asList = '';

        tRoiInput = roiTemplate('get');
        tVoiInput = voiTemplate('get');

        if ~isempty(tVoiInput) 
            for aa=1:numel(tVoiInput)
                asList{numel(asList)+1} = tVoiInput{aa}.Label;
            end                        
        end

        if ~isempty(tRoiInput) 

            for cc=1:numel(tRoiInput)
               if isvalid(tRoiInput{cc}.Object)
                    asList{numel(asList)+1} = tRoiInput{cc}.Label;
                end
            end                        
        end 

        if numel(asList) ~= 0
        %    set(uiTxtSubtractVoiRoi, 'Enable', 'inactive');                        
        %    set(uiChkSubtractVoiRoi, 'Enable', 'on');     

            set(uiRoiVoiSeg, 'Enable', 'on');
            set(uiRoiVoiSeg, 'String', asList);

            if get(uiChkSubtractVoiRoi, 'Value') == true
                set(uiEditVoiRoiUpperTreshold  , 'Enable', 'off');  
                set(uiSliderVoiRoiUpperTreshold, 'Enable', 'off'); 
                set(uiTxtVoiRoiUpperTreshold   , 'Enable', 'off');  
  %              set(uiProceedImageSeg, 'String', 'Subtract');                                                               
            end
        else
            set(uiSegAction, 'Value' , 1);
            set(uiRoiVoiSeg, 'Enable', 'off');
            set(uiRoiVoiSeg, 'String', ' ');

     %       set(uiTxtSubtractVoiRoi, 'Enable', 'off');                        
     %       set(uiChkSubtractVoiRoi, 'Enable', 'off');   

            if get(uiChkSubtractVoiRoi, 'Value') == false
                set(uiEditVoiRoiUpperTreshold  , 'Enable', 'on');  
                set(uiSliderVoiRoiUpperTreshold, 'Enable', 'on'); 
                set(uiTxtVoiRoiUpperTreshold   , 'Enable', 'on'); 
            end

  %          set(uiProceedImageSeg, 'String', 'Segment');                                       

        end
    end
end
