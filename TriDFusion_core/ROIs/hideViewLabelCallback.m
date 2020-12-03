function hideViewLabelCallback(hObject,~) 
%function hideViewLabelCallback(hObject,~)  
%Set ROIs Hide/View Label.
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

    if strcmpi(hObject.UserData.LabelVisible, 'on')
        hObject.UserData.LabelVisible = 'off';
    else
        hObject.UserData.LabelVisible = 'on';
    end

    tLabelVisibleInput = inputTemplate('get');        
    iOffset = get(uiSeriesPtr('get'), 'Value');
    if iOffset > numel(tLabelVisibleInput)  
        return;
    end

    for bb=1:numel(tLabelVisibleInput(iOffset).tRoi)
        if strcmpi(hObject.UserData.Tag, tLabelVisibleInput(iOffset).tRoi{bb}.Tag)
            tLabelVisibleInput(iOffset).tRoi{bb}.LabelVisible = hObject.UserData.LabelVisible;
            inputTemplate('set', tLabelVisibleInput);
            roiTemplate('set', tLabelVisibleInput(iOffset).tRoi);
            break;
        end
    end                
end