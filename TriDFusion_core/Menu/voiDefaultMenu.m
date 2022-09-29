function voiDefaultMenu(ptrRoi, sTag)
%function voiDefaultMenu(ptrRoi, sTag)
%Add VOI default right click menu.
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
    
    if ~exist('sTag', 'var') % Add menu
            mVoiFolder = ...
            uimenu(ptrRoi.UIContextMenu, ...
                   'Label'    , 'Volume-of-interest' , ...
                   'UserData' , ptrRoi, ...
                   'Visible'  , 'off', ...
                   'Separator', 'on' ...
                   ); 

        mVoiConstraint = ...   
            uimenu(mVoiFolder, ...
                   'Label'    , 'Constraint' , ...
                   'UserData' , ptrRoi, ...
                   'Visible'  , 'off', ...
                   'Callback' , @setMenuConstraintCheckedCallback ...
                   ); 
               
            uimenu(mVoiConstraint, ...
                   'Label'    , 'Inside This Contour' , ...
                   'UserData' , ptrRoi.Tag, ...
                   'Callback' , @constraintContourFromMenuCallback ...
                  ); 

            uimenu(mVoiConstraint, ...
                   'Label'   , 'Invert Constraint' , ...
                   'Checked' , invertConstraint('get'), ...
                   'Callback', @invertConstraintFromMenuCallback ...
                  );
                      
        mVoiMask = ...   
            uimenu(mVoiFolder, ...
                   'Label'    , 'Mask' , ...
                   'UserData' , ptrRoi, ...
                   'Visible'  , 'off', ...
                   'Separator', 'on' ...
                   ); 
               
            uimenu(mVoiMask, ...
                   'Label'    , 'Inside This Contour' , ...
                   'UserData' , ptrRoi.Tag, ...
                   'Visible'  , 'off', ...
                   'Callback' , @maskContourFromMenuCallback ...
                  ); 

            uimenu(mVoiMask, ...
                   'Label'    , 'Outside This Contour' , ...
                   'UserData' , ptrRoi.Tag, ...
                   'Visible'  , 'off', ...
                   'Callback' , @maskContourFromMenuCallback ...
                  ); 

                
    else % Make menu visible (when creating a VOI)
             
        if ~isstruct(ptrRoi)
            for mc=1:numel(ptrRoi.ContextMenu.Children)
                if strcmpi(ptrRoi.ContextMenu.Children(mc).Label, 'Volume-of-interest')

                    set(ptrRoi.ContextMenu.Children(mc),          'Visible', 'on');   % Activate mVoiFolder
                    set(ptrRoi.ContextMenu.Children(mc).Children, 'Visible', 'on');   % Activate mVoiConstraint & mVoiMaskt

                    set(ptrRoi.ContextMenu.Children(mc),          'UserData', sTag);   % Set VOI tag mVoiFoldert
                    set(ptrRoi.ContextMenu.Children(mc).Children, 'UserData', sTag);   % Set VOI tag mVoiConstraint & mVoiMaskt

                    for cc=1:numel(ptrRoi.ContextMenu.Children(mc).Children) % Set both Mask and Constraint sub menu
                        set(ptrRoi.ContextMenu.Children(mc).Children(cc).Children, 'Visible' , 'on');
                        set(ptrRoi.ContextMenu.Children(mc).Children(cc).Children, 'UserData', sTag);
                    end

                    break;
                end
            end
        end
    end
    
    function setMenuConstraintCheckedCallback(hObject, ~)
        
        if isprop(ptrRoi, 'ContextMenu')
               
            for mcc=1:numel(hObject.Children)
                
                if strcmpi(hObject.Children(mcc).Label, 'Invert Constraint')

                    if invertConstraint('get') == true
                        set(hObject.Children(mcc), 'Checked', 'on');
                    else
                        set(hObject.Children(mcc), 'Checked', 'off');
                    end                
                else
                    sConstraintTag = get(hObject, 'UserData'); 

                    [asConstraintTagList, asConstraintTypeList] = roiConstraintList('get', get(uiSeriesPtr('get'), 'Value') );
                    if isempty(asConstraintTagList)
                        set(hObject.Children(mcc), 'Checked', 'off');                    
                    else
                        aTagOffset = strcmp( cellfun( @(asConstraintTagList) asConstraintTagList, asConstraintTagList, 'uni', false ), sConstraintTag);
                        dVoiTagOffset = find(aTagOffset, 1);  

                        if ~isempty(dVoiTagOffset) % tag is active
                            if     strcmpi(asConstraintTypeList{dVoiTagOffset}, 'Inside This Contour')
                                set(hObject.Children(mcc), 'Checked', 'on');                                     
                            elseif strcmpi(asConstraintTypeList{dVoiTagOffset}, 'Inside Every Slice')
                                set(hObject.Children(mcc), 'Checked', 'on');                                      
                            else
                                set(hObject.Children(mcc), 'Checked', 'off');                    
                            end
                        else
                            set(hObject.Children(mcc), 'Checked', 'off');                    
                        end
                    end
                end
            end        
        end
    end           
       
end