function processMachineLearningSegmentation(sProtocolName)
%function processMachineLearningSegmentation(sProtocolName)
%Process a Machine Learning segmentation base on a protocol name.
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

    atInput = inputTemplate('get');
    
    % Modality validation    
       
    dCTSerieOffset = [];
    for tt=1:numel(atInput)
        if strcmpi(atInput(tt).atDicomInfo{1}.Modality, 'ct')
            dCTSerieOffset = tt;
            break;
        end
    end

    if ~isempty(dCTSerieOffset)
    
        if get(uiSeriesPtr('get'), 'Value') ~= dCTSerieOffset

            set(uiSeriesPtr('get'), 'Value', dCTSerieOffset);
    
            setSeriesCallback();
        end

        [sSegmentatorScript, sSegmentatorCombineMasks] = validateSegmentatorInstallation();
        
        if ~isempty(sSegmentatorScript) && ... % External Segmentor is installed
           ~isempty(sSegmentatorCombineMasks)
    
            [loadProtocol, proceedMachineLearning] = machineLearningSegmentationDialog(sSegmentatorScript, sSegmentatorCombineMasks);
    
            loadProtocol(sProtocolName);
    
            proceedMachineLearning();

        end
    end
end