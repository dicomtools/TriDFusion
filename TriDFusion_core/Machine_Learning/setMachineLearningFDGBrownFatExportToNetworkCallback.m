function setMachineLearningFDGBrownFatExportToNetworkCallback(~, ~)
%function setMachineLearningFDGBrownFatExportToNetworkCallback()
%Run FDG SUV Brown Fat Segmentation, The tool is called from the main menu.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2023, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    machineLearningFDGBrownFatSUVNormalization('set', false);

    machineLearningFDGBrownFatSUVScaled('set', false);

    % Export task 96
    setMachineLearningFDGBrownFatExportToPETNetworkCallback(false);

    % Export task 97
    setMachineLearningFDGBrownFatExportToPETCTNetworkCallback(false);

    machineLearningFDGBrownFatSUVScaled('set', true);

    % Export task 98
    setMachineLearningFDGBrownFatExportToPETNetworkCallback(false);

    % Export task 99
    setMachineLearningFDGBrownFatExportToPETCTNetworkCallback(false);

    machineLearningFDGBrownFatSUVNormalization('set', true);

    % Export task 100
    setMachineLearningFDGBrownFatExportToPETNetworkCallback(false);

    % Export task 101
    setMachineLearningFDGBrownFatExportToPETCTNetworkCallback(false);

    % Exit the compiled executable
    close(fiMainWindowPtr('get'));     

end