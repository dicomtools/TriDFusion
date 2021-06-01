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

    asList = '';
    
    tRoiInput = roiTemplate('get');
    tVoiInput = voiTemplate('get');
        
    uiSegActRoiPanel = uiSegActRoiPanelObject('get');
    uiRoiVoiRoiPanel = uiRoiVoiRoiPanelObject('get');
    
    uiSegActKernelPanel = uiSegActKernelPanelObject('get');
    uiRoiVoiKernelPanel = uiRoiVoiKernelPanelObject('get');       

    uiSegAction = voiRoiActObject('get');
    uiRoiVoiSeg = voiRoiSegObject('get');  

    uiChkSubtractImageVoiRoi         = chkImageVoiRoiSubstractObject('get');            
    uiEditImageVoiRoiUpperTreshold   = editImageVoiRoiUpperTresholdObject('get');
    uiSliderImageVoiRoiUpperTreshold = sliderImageVoiRoiUpperTresholdObject('get');
    uiTxtImageVoiRoiUpperTreshold    = txtImageVoiRoiUpperTresholdObject('get');
    
    if strcmpi(uiSegActRoiPanel.String{uiSegActRoiPanel.Value}, 'Entire Image') 
        set(uiRoiVoiRoiPanel, 'Value' , 1);
        set(uiRoiVoiRoiPanel, 'Enable', 'off');                        
        set(uiRoiVoiRoiPanel, 'String', ' ');                         
    else
        
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
        %    set(uiChkSubtractImageVoiRoi, 'Enable', 'on');     

            set(uiRoiVoiRoiPanel, 'Enable', 'on');
            set(uiRoiVoiRoiPanel, 'String', asList);                      
        else
            set(uiSegActRoiPanel, 'Value' , 1);
            set(uiRoiVoiRoiPanel, 'Enable', 'off');
            set(uiRoiVoiRoiPanel, 'String', ' ');                                    
        end                            
    end
    
    if strcmpi(uiSegActKernelPanel.String{uiSegActKernelPanel.Value}, 'Entire Image') 
        set(uiRoiVoiKernelPanel, 'Value' , 1);
        set(uiRoiVoiKernelPanel, 'Enable', 'off');                        
        set(uiRoiVoiKernelPanel, 'String', ' ');                         
    else
        
        if isempty(asList)
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
        end
        
        if numel(asList) ~= 0
        %    set(uiTxtSubtractVoiRoi, 'Enable', 'inactive');                        
        %    set(uiChkSubtractImageVoiRoi, 'Enable', 'on');     

            set(uiRoiVoiKernelPanel, 'Enable', 'on');
            set(uiRoiVoiKernelPanel, 'String', asList);                      
        else
            set(uiSegActKernelPanel, 'Value' , 1);
            set(uiRoiVoiKernelPanel, 'Enable', 'off');
            set(uiRoiVoiKernelPanel, 'String', ' ');                                    
        end                            
    end
    
    if strcmpi(uiSegAction.String{uiSegAction.Value}, 'Entire Image') 

        set(uiRoiVoiSeg, 'Value' , 1);
        set(uiRoiVoiSeg, 'Enable', 'off');                        
        set(uiRoiVoiSeg, 'String', ' ');

   %     set(uiTxtSubtractVoiRoi, 'Enable', 'off');                        
   %     set(uiChkSubtractImageVoiRoi, 'Enable', 'off');     

        if get(uiChkSubtractImageVoiRoi, 'Value') == false
            set(uiEditImageVoiRoiUpperTreshold  , 'Enable', 'on');  
            set(uiSliderImageVoiRoiUpperTreshold, 'Enable', 'on'); 
            set(uiTxtImageVoiRoiUpperTreshold   , 'Enable', 'on');                                                 
        end

   %     set(uiProceedImageSeg, 'String', 'Segment');                                       

    else

        if isempty(asList)

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
        end
        
        if numel(asList) ~= 0
        %    set(uiTxtSubtractVoiRoi, 'Enable', 'inactive');                        
        %    set(uiChkSubtractImageVoiRoi, 'Enable', 'on');     

            set(uiRoiVoiSeg, 'Enable', 'on');
            set(uiRoiVoiSeg, 'String', asList);

            if get(uiChkSubtractImageVoiRoi, 'Value') == true
                set(uiEditImageVoiRoiUpperTreshold  , 'Enable', 'off');  
                set(uiSliderImageVoiRoiUpperTreshold, 'Enable', 'off'); 
                set(uiTxtImageVoiRoiUpperTreshold   , 'Enable', 'off');  
  %              set(uiProceedImageSeg, 'String', 'Subtract');                                                               
            end
        else
            set(uiSegAction, 'Value' , 1);
            set(uiRoiVoiSeg, 'Enable', 'off');
            set(uiRoiVoiSeg, 'String', ' ');

     %       set(uiTxtSubtractVoiRoi, 'Enable', 'off');                        
     %       set(uiChkSubtractImageVoiRoi, 'Enable', 'off');   

            if get(uiChkSubtractImageVoiRoi, 'Value') == false
                set(uiEditImageVoiRoiUpperTreshold  , 'Enable', 'on');  
                set(uiSliderImageVoiRoiUpperTreshold, 'Enable', 'on'); 
                set(uiTxtImageVoiRoiUpperTreshold   , 'Enable', 'on'); 
            end

  %          set(uiProceedImageSeg, 'String', 'Segment');                                       

        end
    end
end
