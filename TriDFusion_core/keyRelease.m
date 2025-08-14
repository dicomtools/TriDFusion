function keyRelease(~,evnt)
%function keyRelease(~,evnt)
%Catch\Execute Keyboard Key release.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2024, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    if is2DBrush('get')== true
        
        windowButton('set', 'up');  
    end

    if  strcmpi(get(fiMainWindowPtr('get'), 'Pointer'), 'bottom')

        if is2DBrush('get')            == false && ...
           isMoveImageActivated('get') == false && ...
           switchTo3DMode('get')       == false && ...
           switchToIsoSurface('get')   == false && ...
           switchToMIPMode('get')      == false

            if size(dicomBuffer('get', [], get(uiSeriesPtr('get'), 'Value')), 3) ~= 1

                % atRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));
                % 
                % if ~isempty(atRoiInput)
                %     for rr=1:numel(atRoiInput)
                %         set(atRoiInput{rr}.Object, 'InteractionsAllowed', 'all');
                %     end               
                % end 

                setCrossVisibility(true);
                
                set(fiMainWindowPtr('get'), 'Pointer', 'default');
            end

        end

        % if is2DBrush('get')== true
        % 
        %     pRoiPtr = brush2Dptr('get');
        % 
        %     if ~isempty(pRoiPtr) 
        %         pRoiPtr.Visible = 'on';
        %     end
        % end

    
    end
            
end