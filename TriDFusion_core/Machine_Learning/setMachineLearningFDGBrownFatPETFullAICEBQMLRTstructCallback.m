function setMachineLearningFDGBrownFatPETFullAICEBQMLRTstructCallback(~, ~)
%function setMachineLearningFDGBrownFatPETFullAICEBQMLRTstructCallback()
%Run FDG Brown Fat CE Loss PET BQML Segmentation, The tool is called from the main menu.
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

    machineLearningFDGBrownFatCELoss('set', true);

    machineLearningFDGBrownFatSUVScaled('set', false);

    machineLearningFDGBrownFatSUVNormalization('set', false);

    % Segment Series
    
    % setMachineLearningFDGBrownFatFullAICallback();
    setMachineLearningFDGBrownFatPETFullAICallback();

if 1
    writeBrownFatRTStruct('PET');
else
    % Export RT-structure
    writeRTStructCallback();
end
    writeBrownFatRoisToDicomMask('PET');

    % Exit the compiled executable
    close(fiMainWindowPtr('get'));     

end