function initTemplates()
%function initTemplates()
%Init All Global Templates.
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

    asMainDirectory = mainDir('get');

    try

    set(fiMainWindowPtr('get'), 'Pointer', 'watch');
    drawnow limitrate;

    if(numel(asMainDirectory))

        % asMainDirectory

        [asFilesList, atDicomInfo, aDicomBuffer] = readDicomFolder(asMainDirectory);

        if ~isempty(asFilesList) && ...
           ~isempty(atDicomInfo) && ...
           ~isempty(aDicomBuffer)

            % Preallocate atInput structure array

            [atInput, asSeriesDescription] = initInputTemplate(asFilesList, atDicomInfo, aDicomBuffer);

            inputTemplate('set', atInput);

            seriesDescription('set', asSeriesDescription);

            setInputOrientation([]);

            setDisplayBuffer([]);

            if numel(inputTemplate('get')) ~= 0

                for dTemplateLoop = 1 : numel(inputTemplate('get'))

                    setQuantification(dTemplateLoop);
                end
            end

            atInput = inputTemplate('get');

            dicomMetaData('set', atInput(1).atDicomInfo);

            aInputBuffer = inputBuffer('get');

            dicomBuffer('set', aInputBuffer{1});

            for mm=1:numel(aInputBuffer)

                if size(aInputBuffer{mm}, 3) ~= 1

                    mipBuffer('set', atInput(mm).aMip, mm);
                end
            end

            clear aInputBuffer;

            cropValue('set', min(dicomBuffer('get'), [], 'all'));

        else
            set(fiMainWindowPtr('get'), 'Pointer', 'default');
            drawnow limitrate;

            progressBar(1 , 'Error: TriDFusion: no volumes detected!');
            h = msgbox('Error: TriDFusion(): no volumes detected!', 'Error');
%            if integrateToBrowser('get') == true
%                sLogo = './TriDFusion/logo.png';
%            else
%                sLogo = './logo.png';
%            end

%            javaFrame = get(h, 'JavaFrame');
%            javaFrame.setFigureIcon(javax.swing.ImageIcon(sLogo));
            return;
        end

    end

    catch ME
        logErrorToFile(ME);  
        progressBar(1, 'Error:initTemplates()');
    end

    set(fiMainWindowPtr('get'), 'Pointer', 'default');
    drawnow limitrate;

end
