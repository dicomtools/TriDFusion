function selectVoiFromMouseOverForContourReview(dSeriesOffset)
%function selectVoiFromMouseOverForContourReview(dSeriesOffset)
%Set the contour reviwew contour panel from a mouse over a ROI.
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

    atRoiInput = roiTemplate('get', dSeriesOffset);
    atVoiInput = voiTemplate('get', dSeriesOffset);
 
    try

    set(fiMainWindowPtr('get'), 'Pointer', 'watch');
    drawnow;

    if ~isempty(atRoiInput) && ...
       ~isempty(atVoiInput)

        dNbRois = numel(atRoiInput);
        
        bFoundRoi = false;

        for rr=1:dNbRois

            if strcmpi(atRoiInput{rr}.Object.Visible, 'on')

                if isMouseOverROI(atRoiInput{rr}.Object, dSeriesOffset)

                    for vo=1:numel(atVoiInput)

                        dVoiTagOffset = find(contains(atVoiInput{vo}.RoisTag, atRoiInput{rr}.Tag), 1);

                        if ~isempty(dVoiTagOffset)

                            seletVoiRoiPanelCallback = uiSelectVoiRoiPanelObject('get');
            
                            if ~isempty(seletVoiRoiPanelCallback)
                    
                                callbackFunction = get(seletVoiRoiPanelCallback, 'Callback');  
                                
                                callbackFunction(atRoiInput{rr}.Object, vo);

                                bFoundRoi = true;
                                break;

                            end                

                        end
                    end
                    
                    if bFoundRoi == true
                        
                        break;
                    end
                end
            end
        end
    end

    catch
        progressBar(1, 'Error:selectMouseOverForContourReview()');
    end

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow;

end
