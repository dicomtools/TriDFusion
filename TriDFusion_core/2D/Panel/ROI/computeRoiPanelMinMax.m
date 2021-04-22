function [dMin, dMax] = computeRoiPanelMinMax()
%function  [dMin, dMax] = computeRoiPanelMinMax()
%Get Min Max Value from a ROI or VOI.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Note: option settings must fit on one line and can contain one semicolon at most.
%Options can be strings, cell arrays of strings, or numerical arrays.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2021, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    uiSegActRoiPanelObj = uiSegActRoiPanelObject('get');
    uiRoiVoiRoiPanel = uiRoiVoiRoiPanelObject('get');

    aActionType = get(uiSegActRoiPanelObj, 'String');
    dActionType = get(uiSegActRoiPanelObj, 'Value' );
    sActionType = aActionType{dActionType};      

    aBuffer = dicomBuffer('get');

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

    if numel(aobjList) == 0
        dMin = [];
        dMax = [];

        return;
    end             

    if strcmpi(aobjList{get(uiRoiVoiRoiPanel, 'Value')}.ObjectType, 'voi')
                
        dNbRois = numel(aobjList{get(uiRoiVoiRoiPanel, 'Value')}.RoisTag);
        
        if strcmpi(sActionType, 'Inside ROI\VOI') || ...  
           strcmpi(sActionType, 'Outside ROI\VOI')
            adSliceMin = zeros(dNbRois,1);
            adSliceMax = zeros(dNbRois,1);                
        end
        
        bInitMinMax = true;

        for bb=1:dNbRois

            for cc=1:numel(tRoiInput)
                if isvalid(tRoiInput{cc}.Object) && ...
                    strcmpi(tRoiInput{cc}.Tag, aobjList{get(uiRoiVoiRoiPanel, 'Value')}.RoisTag{bb})
                    objRoi   = tRoiInput{cc}.Object;
                    dSliceNb = tRoiInput{cc}.SliceNb;

                    switch objRoi.Parent
                        case axePtr('get')
                            
                            aSlice = aBuffer(:,:); 
                            roiMask = createMask(objRoi, aSlice); 
                            
                            if strcmpi(sActionType, 'Outside ROI\VOI')     
                                roiMask = ~roiMask;                              
                            end

                            aSlice(roiMask == 0) = roiMask(roiMask == 0); 

                            adSliceMin(bb) = min(aSlice,[], 'all');
                            adSliceMax(bb) = max(aSlice,[], 'all'); 
                            
                        case axes1Ptr('get')
                                
                            if strcmpi(sActionType, 'Inside all slices ROI\VOI') || ...    
                               strcmpi(sActionType, 'Outside all slices ROI\VOI')
                           
                                if bInitMinMax == true
                                    bInitMinMax = false;
                                    adSliceMin = zeros(size(aBuffer, 1), 1);
                                    adSliceMax = zeros(size(aBuffer, 1), 1);
                               end
                           
                                for jj=1:size(aBuffer, 1)
                                    aSlice = permute(aBuffer(jj,:,:), [3 2 1]);
                                    roiMask = createMask(objRoi, aSlice);                                   
                                    if strcmpi(sActionType, 'Outside all slices ROI\VOI')     
                                        roiMask = ~roiMask;                              
                                    end   
                                    
                                    aSlice(roiMask == 0) = roiMask(roiMask == 0); 

                                    adSliceMin(jj) = min(aSlice,[], 'all');
                                    adSliceMax(jj) = max(aSlice,[], 'all');                                     
                                end
                            else
                                aSlice = permute(aBuffer(dSliceNb,:,:), [3 2 1]);
                                roiMask = createMask(objRoi, aSlice);  
                                
                                if strcmpi(sActionType, 'Outside ROI\VOI')     
                                    roiMask = ~roiMask;                              
                                end

                                aSlice(roiMask == 0) = roiMask(roiMask == 0); 

                                adSliceMin(bb) = min(aSlice,[], 'all');
                                adSliceMax(bb) = max(aSlice,[], 'all');                                   
                            end
                            
                        case axes2Ptr('get')
                            if strcmpi(sActionType, 'Inside all slices ROI\VOI') || ...    
                               strcmpi(sActionType, 'Outside all slices ROI\VOI')
                           
                                if bInitMinMax == true
                                    bInitMinMax = false;
                                    adSliceMin = zeros(size(aBuffer, 1), 2);
                                    adSliceMax = zeros(size(aBuffer, 1), 2);
                                end    
                                
                                for jj=1:size(aBuffer, 2)
                                    aSlice = permute(aBuffer(:,jj,:), [3 1 2]);
                                    roiMask = createMask(objRoi, aSlice);                                   
                                    if strcmpi(sActionType, 'Outside all slices ROI\VOI')     
                                        roiMask = ~roiMask;                              
                                    end   
                                    
                                    aSlice(roiMask == 0) = roiMask(roiMask == 0); 

                                    adSliceMin(jj) = min(aSlice,[], 'all');
                                    adSliceMax(jj) = max(aSlice,[], 'all');                                     
                                end                               
                                
                            else
                                aSlice = permute(aBuffer(:,dSliceNb,:), [3 1 2]);
                                roiMask = createMask(objRoi, aSlice);  

                                if strcmpi(sActionType, 'Outside ROI\VOI')     
                                    roiMask = ~roiMask;                              
                                end

                                aSlice(roiMask == 0) = roiMask(roiMask == 0); 

                                adSliceMin(bb) = min(aSlice,[], 'all');
                                adSliceMax(bb) = max(aSlice,[], 'all'); 
                            end
                            
                        case axes3Ptr('get')
                            if strcmpi(sActionType, 'Inside all slices ROI\VOI') || ...    
                               strcmpi(sActionType, 'Outside all slices ROI\VOI')
                           
                                if bInitMinMax == true
                                    bInitMinMax = false;
                                    adSliceMin = zeros(size(aBuffer, 1), 3);
                                    adSliceMax = zeros(size(aBuffer, 1), 3);
                                end    
                                
                                for jj=1:size(aBuffer, 3)                                    
                                    aSlice = aBuffer(:,:,jj); 
                                    roiMask = createMask(objRoi, aSlice);                                   
                                    if strcmpi(sActionType, 'Outside all slices ROI\VOI')     
                                        roiMask = ~roiMask;                              
                                    end   
                                    
                                    aSlice(roiMask == 0) = roiMask(roiMask == 0); 

                                    adSliceMin(jj) = min(aSlice,[], 'all');
                                    adSliceMax(jj) = max(aSlice,[], 'all');                                     
                                end                               
                                
                            else                            
                                aSlice = aBuffer(:,:,dSliceNb); 
                                roiMask = createMask(objRoi, aSlice);  

                                if strcmpi(sActionType, 'Outside ROI\VOI')     
                                    roiMask = ~roiMask;                              
                                end

                                aSlice(roiMask == 0) = roiMask(roiMask == 0); 

                                adSliceMin(bb) = min(aSlice,[], 'all');
                                adSliceMax(bb) = max(aSlice,[], 'all');      
                            end
                    end                             

                    break; 
                 end
            end
        end

        dMin = min(adSliceMin,[], 'all');
        dMax = max(adSliceMax,[], 'all');    

    else
        objRoi   = aobjList{uiRoiVoiRoiPanel.Value}.Object;
        dSliceNb = aobjList{uiRoiVoiRoiPanel.Value}.SliceNb;

        switch objRoi.Parent
            
            case axePtr('get')
                
                aSlice = aBuffer(:,:); 
                roiMask = createMask(objRoi, aSlice);     

                if strcmpi(sActionType, 'Outside ROI\VOI')                            
                    roiMask = ~roiMask;                              
                end

                aSlice(roiMask == 0) = roiMask(roiMask == 0); 

                adSliceMin = min(aSlice,[], 'all');
                adSliceMax = max(aSlice,[], 'all');                     

            case axes1Ptr('get')
                
                if strcmpi(sActionType, 'Inside ROI\VOI') || ...
                   strcmpi(sActionType, 'Outside ROI\VOI')     

                    aSlice = permute(aBuffer(dSliceNb,:,:), [3 2 1]);
                    roiMask = createMask(objRoi, aSlice);    

                    if strcmpi(sActionType, 'Outside ROI\VOI')                            
                        roiMask = ~roiMask;                              
                    end

                    aSlice(roiMask == 0) = roiMask(roiMask == 0); 

                    adSliceMin = min(aSlice,[], 'all');
                    adSliceMax = max(aSlice,[], 'all');  
                else
                    adSliceMin = zeros(size(aBuffer, 1),1);
                    adSliceMax = zeros(size(aBuffer, 1),1);

                    for cc=1:size(aBuffer, 1)
                        aSlice = permute(aBuffer(cc,:,:), [3 2 1]);
                        roiMask = createMask(objRoi, aSlice);    

                        if strcmpi(sActionType, 'Outside all slices ROI\VOI')                            
                            roiMask = ~roiMask;                              
                        end

                        aSlice(roiMask == 0) = roiMask(roiMask == 0); 

                        dSliceMin = min(aSlice,[], 'all');
                        dSliceMax = max(aSlice,[], 'all');  

                        adSliceMin(cc) = dSliceMin;
                        adSliceMax(cc) = dSliceMax;
                    end
                end
            case axes2Ptr('get')
                
                if strcmpi(sActionType, 'Inside ROI\VOI') || ...
                   strcmpi(sActionType, 'Outside ROI\VOI')     

                    aSlice = permute(aBuffer(:,dSliceNb,:), [3 1 2]);
                    roiMask = createMask(objRoi, aSlice);        

                    if strcmpi(sActionType, 'Outside ROI\VOI')                            
                        roiMask = ~roiMask;                              
                    end

                    aSlice(roiMask == 0) = roiMask(roiMask == 0); 

                    adSliceMin = min(aSlice,[], 'all');
                    adSliceMax = max(aSlice,[], 'all');  

                else
                    adSliceMin = zeros(size(aBuffer, 2),1);
                    adSliceMax = zeros(size(aBuffer, 2),1);

                    for ss=1:size(aBuffer, 2)
                        aSlice = permute(aBuffer(:,ss,:), [3 1 2]);
                        roiMask = createMask(objRoi, aSlice);        

                        if strcmpi(sActionType, 'Outside all slices ROI\VOI')                            
                            roiMask = ~roiMask;                              
                        end

                        aSlice(roiMask == 0) = roiMask(roiMask == 0); 

                        dSliceMin = min(aSlice,[], 'all');
                        dSliceMax = max(aSlice,[], 'all');  

                        adSliceMin(ss) = dSliceMin;
                        adSliceMax(ss) = dSliceMax;
                    end
                end

            case axes3Ptr('get')
                
                if strcmpi(sActionType, 'Inside ROI\VOI') || ...
                   strcmpi(sActionType, 'Outside ROI\VOI')     

                    aSlice = aBuffer(:,:,dSliceNb); 
                    roiMask = createMask(objRoi, aSlice);  

                    if strcmpi(sActionType, 'Outside ROI\VOI')                            
                        roiMask = ~roiMask;                              
                    end

                    aSlice(roiMask == 0) = roiMask(roiMask == 0); 

                    adSliceMin = min(aSlice,[], 'all');
                    adSliceMax = max(aSlice,[], 'all');  

                else
                    adSliceMin = zeros(size(aBuffer, 3),1);
                    adSliceMax = zeros(size(aBuffer, 3),1); 

                    for aa=1:size(aBuffer, 3)
                        aSlice = aBuffer(:,:,aa); 
                        roiMask = createMask(objRoi, aSlice);  

                        if strcmpi(sActionType, 'Outside all slices ROI\VOI')                            
                            roiMask = ~roiMask;                              
                        end

                        aSlice(roiMask == 0) = roiMask(roiMask == 0); 

                        dSliceMin = min(aSlice,[], 'all');
                        dSliceMax = max(aSlice,[], 'all');  

                        adSliceMin(aa) = dSliceMin;
                        adSliceMax(aa) = dSliceMax;
                    end  
                end
        end                    

        dMin = min(adSliceMin,[], 'all');
        dMax = max(adSliceMax,[], 'all');                   

    end      
end
