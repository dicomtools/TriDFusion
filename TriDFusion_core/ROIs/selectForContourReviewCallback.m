function selectForContourReviewCallback(hObject, ~)
%function selectForContourReviewCallback(hObject, ~)
%Edit VOI and assiciated ROIs Label.
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
    
    atVoiInput = voiTemplate('get', get(uiSeriesPtr('get'), 'Value')); 

    dVoiTagOffset = find(strcmp( cellfun( @(atVoiInput) atVoiInput.Tag, atVoiInput, 'uni', false ), hObject.UserData ) );       

    if ~isempty(dVoiTagOffset)

        if isMoveImageActivated('get') == false && ...
           switchTo3DMode('get')       == false && ...
           switchToIsoSurface('get')   == false && ...
           switchToMIPMode('get')      == false

            seletVoiRoiPanelCallback = uiSelectVoiRoiPanelObject('get');

            if ~isempty(seletVoiRoiPanelCallback)

                try

                set(fiMainWindowPtr('get'), 'Pointer', 'watch');
                drawnow;

                callbackFunction = get(seletVoiRoiPanelCallback, 'Callback');                  

                callbackFunction(hObject.Parent.UserData, dVoiTagOffset);

                catch
                    progressBar(1, 'Error:selectForContourReviewCallback()');
                end

                set(fiMainWindowPtr('get'), 'Pointer', 'default');
                drawnow;

            end


        end
    end

    % dSeriesOffset = get(uiSeriesPtr('get'), 'Value');
    % 
    % if ~isempty(voiTemplate('get', dSeriesOffset))
    % 
    %     selectVoiFromMouseOverForContourReview(dSeriesOffset);
    % end

end
