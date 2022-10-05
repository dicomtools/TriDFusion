function [asConstraintTagList, asConstraintTypeList] = roiConstraintList(sAction, dSeriesOffset, sConstraintTag, sConstraintType, bIsActive)
%function [asConstraintTagList, asConstraintTypeList] = roiConstraintList(sAction, dSeriesOffset, sConstraintTag, sConstraintType, bIsActive)
%Get\Set Axe1 Fusion Pointer.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Note: option settings must fit on one line and can contain one semicolon at most.
%Options can be strings, cell arrays of strings, or numerical arrays.
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
% along with TriDFusion.  If not, see <http://www.gnu.org/licenses/>.    persistent paObject; 

    persistent ptConstraint; 
    
    asConstraintTagList  = [];
    asConstraintTypeList = [];  
             
    if strcmpi('set', sAction)
        if exist('bIsActive', 'var') % Use for VOI
            if numel(ptConstraint) >= dSeriesOffset
                if isfield(ptConstraint{dSeriesOffset}, 'asConstraintTag')

                    bTagExist = false;

                    dNbConstraint = numel(ptConstraint{dSeriesOffset}.asConstraintTag);
                    
                    asConstraintTagList = ptConstraint{dSeriesOffset}.asConstraintTag;
                    
                    aTagOffset = strcmp( cellfun( @(asConstraintTagList) asConstraintTagList, asConstraintTagList, 'uni', false ), sConstraintTag);
                    dTagOffset = find(aTagOffset, 1);   

                    if ~isempty(dTagOffset)
                                        
%                    for pp=1:dNbConstraint % Search for existing Constraint
%                        if strcmp(ptConstraint{dSeriesOffset}.asConstraintTag{pp}, sConstraintTag)

                            % If the same is set, clear the Constraint
                            if bIsActive == false % Deactivate the tag

                                ptConstraint{dSeriesOffset}.asConstraintTag{dTagOffset}  = [];
                                ptConstraint{dSeriesOffset}.asConstraintType{dTagOffset} = [];     

                                ptConstraint{dSeriesOffset}.asConstraintTag (cellfun(@isempty,  ptConstraint{dSeriesOffset}.asConstraintTag )) = [];                           
                                ptConstraint{dSeriesOffset}.asConstraintType(cellfun(@isempty,  ptConstraint{dSeriesOffset}.asConstraintType)) = [];   
                            else                            
                                if ~strcmpi(ptConstraint{dSeriesOffset}.asConstraintType{dTagOffset}, sConstraintType) % If constraint is not the same type                                 
                                    ptConstraint{dSeriesOffset}.asConstraintType{dTagOffset} = sConstraintType;                        
                                end
                            end

                            bTagExist = true;
%                            break;
%                        end
                    end
                    
                    if bTagExist == false % New tag
                        
                        ptConstraint{dSeriesOffset}.asConstraintTag{dNbConstraint+1}  = sConstraintTag;
                        ptConstraint{dSeriesOffset}.asConstraintType{dNbConstraint+1} = sConstraintType;                       
                                                
                    end
                end
            end
        else   % Use for ROI         
            if numel(ptConstraint) >= dSeriesOffset
                if isfield(ptConstraint{dSeriesOffset}, 'asConstraintTag')

                    bTagExist = false;

                    dNbConstraint = numel(ptConstraint{dSeriesOffset}.asConstraintTag);
                    
                    asConstraintTagList = ptConstraint{dSeriesOffset}.asConstraintTag;
                    
                    aTagOffset = strcmp( cellfun( @(asConstraintTagList) asConstraintTagList, asConstraintTagList, 'uni', false ), sConstraintTag);
                    dTagOffset = find(aTagOffset, 1);   

                    if ~isempty(dTagOffset)
                    
%                    for pp=1:dNbConstraint % Search for existing Constraint
%                        if strcmp(ptConstraint{dSeriesOffset}.asConstraintTag{pp}, sConstraintTag)

                            % If the same is set, clear the Constraint
                            if strcmpi(ptConstraint{dSeriesOffset}.asConstraintType{dTagOffset}, sConstraintType)  

                                ptConstraint{dSeriesOffset}.asConstraintTag{dTagOffset}  = [];
                                ptConstraint{dSeriesOffset}.asConstraintType{dTagOffset} = [];     

                                ptConstraint{dSeriesOffset}.asConstraintTag (cellfun(@isempty,  ptConstraint{dSeriesOffset}.asConstraintTag )) = [];                           
                                ptConstraint{dSeriesOffset}.asConstraintType(cellfun(@isempty,  ptConstraint{dSeriesOffset}.asConstraintType)) = [];   
                            else                            
                                ptConstraint{dSeriesOffset}.asConstraintTag{dTagOffset}  = sConstraintTag;
                                ptConstraint{dSeriesOffset}.asConstraintType{dTagOffset} = sConstraintType;                        
                            end

                            bTagExist = true;
%                            break;
%                        end
                    end

                    if bTagExist == false

                        ptConstraint{dSeriesOffset}.asConstraintTag{dNbConstraint+1}  = sConstraintTag;
                        ptConstraint{dSeriesOffset}.asConstraintType{dNbConstraint+1} = sConstraintType;             
                    end
                else
                    ptConstraint{dSeriesOffset}.asConstraintTag{1}  = sConstraintTag;
                    ptConstraint{dSeriesOffset}.asConstraintType{1} = sConstraintType;        
                end
            else
                ptConstraint{dSeriesOffset}.asConstraintTag{1}  = sConstraintTag;
                ptConstraint{dSeriesOffset}.asConstraintType{1} = sConstraintType;                
            end
        end
        
    elseif strcmpi('reset', sAction)    
        
        if exist('dSeriesOffset', 'var') % Clear one series
            ptConstraint{dSeriesOffset} = [];
        else
            ptConstraint = [];
        end
        
    else
        if numel(ptConstraint) >= dSeriesOffset
            if isfield(ptConstraint{dSeriesOffset}, 'asConstraintTag')
                asConstraintTagList  = ptConstraint{dSeriesOffset}.asConstraintTag;
                asConstraintTypeList = ptConstraint{dSeriesOffset}.asConstraintType;            
            end
        end
    end 
end