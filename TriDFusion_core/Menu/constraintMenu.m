function constraintMenu(ptrRoi)
%function constraintMenu(ptrRoi)
%Add Constraint to ROI.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2022, Daniel Lafontaine, on behalf of the TriDFusion development team.
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
            
    mConstraint = ...
        uimenu(ptrRoi.UIContextMenu, ...
               'Label'    , 'Constraint' , ...
               'UserData' , ptrRoi, ...
               'Callback' , @setRoiConstraintCheckedCallback, ...
               'Separator', 'on' ...
              ); 
       
    mConstraintInsideObject = ...
        uimenu(mConstraint, ...
               'Label'    , 'Inside This Contour' , ...
               'UserData' , ptrRoi, ...
               'Callback' , @setRoiConstraintCallback ...
              ); 
       
    if size(dicomBuffer('get'), 3) ~= 1 % 2D Image
       
        mConstraintInsideEverySlice = ...
            uimenu(mConstraint, ...
                   'Label'    , 'Inside Every Slice' , ...
                   'UserData' , ptrRoi, ...
                   'Callback' , @setRoiConstraintCallback ...
                  );

    end
    
    mConstraintInvert = ...
        uimenu(mConstraint, ...
               'Label'   , 'Invert Constraint' , ...
               'Checked' , invertConstraint('get'), ...
               'Callback', @invertConstraintFromMenuCallback ...
              ); 
                    
    function setRoiConstraintCheckedCallback(hObject, ~)
        
        bInvert = invertConstraint('get');
        
        if bInvert == true
            set(mConstraintInvert, 'Checked', 'on');
        else
            set(mConstraintInvert, 'Checked', 'off');
        end
        
        ptrConstraintRoi = get(hObject, 'UserData'); 
        sConstraintTag   = get(ptrConstraintRoi, 'Tag');
                
        if size(dicomBuffer('get'), 3) == 1 % 2D Image       
            set(mConstraintInsideEverySlice , 'Checked', 'off');                    
        end
        
        [asConstraintTagList, asConstraintTypeList] = roiConstraintList('get', get(uiSeriesPtr('get'), 'Value') );
        
        if isempty(asConstraintTagList)
            set(mConstraintInsideObject , 'Checked', 'off');                    
        else
            aTagOffset = strcmp( cellfun( @(asConstraintTagList) asConstraintTagList, asConstraintTagList, 'uni', false ), sConstraintTag);
            dVoiTagOffset = find(aTagOffset, 1);   

            if ~isempty(dVoiTagOffset) % tag is active
                if     strcmpi(asConstraintTypeList{dVoiTagOffset}, 'Inside This Contour')
                    set(mConstraintInsideObject, 'Checked', 'on');                                     
                elseif strcmpi(asConstraintTypeList{dVoiTagOffset}, 'Inside Every Slice')
                    set(mConstraintInsideEverySlice, 'Checked', 'on');                                      
                else
                    set(mConstraintInsideObject , 'Checked', 'off');                    
                end
            else
                set(mConstraintInsideObject , 'Checked', 'off');                    
            end
        end
    end

    function setRoiConstraintCallback(hObject, ~)
        
        sConstraintType  = get(hObject, 'Label');
        ptrConstraintRoi = get(hObject, 'UserData'); 
        
        sConstraintTag = get(ptrConstraintRoi, 'Tag');

        atVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

        roiConstraintList('set', get(uiSeriesPtr('get'), 'Value'), sConstraintTag, sConstraintType);

        aTagOffset = strcmp( cellfun( @(atVoiInput) atVoiInput.Tag, atVoiInput, 'uni', false ), sConstraintTag);
        dRoiVoiTagOffset = find(aTagOffset, 1);   

        if ~isempty(dRoiVoiTagOffset) % tag is a voi

            [asConstraintTagList, ~] = roiConstraintList('get', get(uiSeriesPtr('get'), 'Value') );

            bIsVoiActive = false;

            aTagOffset = strcmp( cellfun( @(asConstraintTagList) asConstraintTagList, asConstraintTagList, 'uni', false ), sConstraintTag);
            dVoiTagOffset = find(aTagOffset, 1);   

            if ~isempty(dVoiTagOffset) % tag is active
                bIsVoiActive = true;
            end        

            for tt=1:numel(atVoiInput{dRoiVoiTagOffset}.RoisTag)
                sConstraintTag = atVoiInput{dRoiVoiTagOffset}.RoisTag{tt};
                roiConstraintList('set', get(uiSeriesPtr('get'), 'Value'), sConstraintTag, sConstraintType, bIsVoiActive);
            end
        end 
        
    end   

end    