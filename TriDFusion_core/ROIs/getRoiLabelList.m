function aList = getRoiLabelList()
%function getRoiLabelList()
%Return ROIs Predefine Label List.
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

    aList{1}='Heart';
    aList{numel(aList)+1}='Water';
    aList{numel(aList)+1}='Bone';
    aList{numel(aList)+1}='Liver';
    aList{numel(aList)+1}='Lung';
    aList{numel(aList)+1}='Left Lung';
    aList{numel(aList)+1}='Right Lung';
    aList{numel(aList)+1}='Left Kidney';
    aList{numel(aList)+1}='Right Kidney';
    aList{numel(aList)+1}='Urinary Bladder Content';
    aList{numel(aList)+1}='Remainder Tissues';
    aList{numel(aList)+1}='Soft Tissue';
    aList{numel(aList)+1}='Calibration Source';
    aList{numel(aList)+1}='Tumor';
    aList{numel(aList)+1}='Tumor 1';
    aList{numel(aList)+1}='Tumor 2';
    aList{numel(aList)+1}='Tumor 3';
    aList{numel(aList)+1}='Tumor 4';
    aList{numel(aList)+1}='Tumor 5';            
end