function [dOffset1, dOffset2] = findDicomMatchingSeries(atInput, sModality1, sModality2)
%function [dOffset1, dOffset2] = findDicomMatchingSeries(atInput, sModality1, sModality2)
%findMatchingSeries finds the first occurrence of two modalities in the input series.
%
%   Inputs:
%       sModality1 - A string specifying the first modality (e.g., 'ct').
%       sModality2 - A string specifying the second modality (e.g., 'nm').
%
%   Outputs:
%       dOffset1 - The index of the series matching sModality1.
%       dOffset2 - The index of the series matching sModality2.
%
%   The function retrieves the series data using inputTemplate('get') and
%   iterates over the series to find the first occurrence of each specified modality.
%
%   If a series for one or both modalities is not found, an error is thrown.
%
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2025, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    % Initialize offsets
    dOffset1 = [];
    dOffset2 = [];

    % Iterate over all series to find a pair with matching modalities and FrameOfReferenceUID
    for tt1 = 1:numel(atInput)

        atDicomInfo1 = atInput(tt1).atDicomInfo{1};
        if strcmpi(atDicomInfo1.Modality, sModality1)
            % Check against each other series
            for tt2 = 1:numel(atInput)
                % Skip the same series
                if tt1 == tt2
                    continue;
                end

                atDicomInfo2 = atInput(tt2).atDicomInfo{1};

                if strcmpi(atDicomInfo2.Modality, sModality2)

                    % Check if the FrameOfReferenceUID matches

                    if strcmp(atDicomInfo1.FrameOfReferenceUID, atDicomInfo2.FrameOfReferenceUID)
                        dOffset1 = tt1;
                        dOffset2 = tt2;
                        return;
                    end
                end
            end
        end
    end

end