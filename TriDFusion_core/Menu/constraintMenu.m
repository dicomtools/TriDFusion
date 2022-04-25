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
        
        set(mConstraintInsideObject , 'Checked', 'off');                    
        
        if size(dicomBuffer('get'), 3) ~= 1 % 2D Image       
            set(mConstraintInsideEverySlice , 'Checked', 'off');                    
        end
        
        [asConstraintTagList, asConstraintTypeList] = roiConstraintList('get', get(uiSeriesPtr('get'), 'Value') );
        
        for tt=1:numel(asConstraintTagList)
            if strcmp(asConstraintTagList{tt}, sConstraintTag)
                if     strcmpi(asConstraintTypeList{tt}, 'Inside This Contour')
                    set(mConstraintInsideObject, 'Checked', 'on');                                     
                elseif strcmpi(asConstraintTypeList{tt}, 'Inside Every Slice')
                    set(mConstraintInsideEverySlice, 'Checked', 'on');                                      
                end
            end
        end 
    end

    function setRoiConstraintCallback(hObject, ~)
        
        sConstraintType  = get(hObject, 'Label');
        ptrConstraintRoi = get(hObject, 'UserData'); 
        
        sConstraintTag = get(ptrConstraintRoi, 'Tag');

        roiConstraintList('set', get(uiSeriesPtr('get'), 'Value'), sConstraintTag, sConstraintType);
        
    end   

end    