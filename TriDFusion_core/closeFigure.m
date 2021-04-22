function closeFigure(~, ~)
%function closeFigure(~, ~)
%Delete objets of the main figures.
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

    try
        multiFramePlayback('set', false);
        multiFrame3DPlayback('set', false);

        releaseRoiWait();

        deleteObject(volObject('get'));
        deleteObject(isoObject('get'));
        deleteObject(mipObject('get'));

        deleteObject(viewRoiObject            ('get'));
        deleteObject(viewSegPanelMenuObject   ('get'));
        deleteObject(viewKernelPanelMenuObject('get'));
        deleteObject(viewRoiPanelMenuObject   ('get'));
        deleteObject(view3DPanelMenuObject    ('get'));
        deleteObject(playIconMenuObject       ('get'));
        deleteObject(recordIconMenuObject     ('get'));
        deleteObject(gateIconMenuObject       ('get'));
        deleteObject(viewPlaybackObject       ('get'));
        deleteObject(playbackMenuObject       ('get'));
        deleteObject(roiMenuObject            ('get'));

        deleteObject(volICObject('get'));
        deleteObject(mipICObject('get'));

        deleteObject(mipColorObject('get'));
        deleteObject(volColorObject('get'));

        axe = axePtr('get');
        if ~isempty(axe)
            delete(axe);
        end

        axef = axefPtr('get');
        if ~isempty(axef)
            delete(axef);
        end

        axes1 = axes1Ptr('get');
        if ~isempty(axes1)
            delete(axes1);
        end

        axes2 = axes2Ptr('get');
        if ~isempty(axes2)
            delete(axes2);
        end

        axes3 = axes3Ptr('get');
        if ~isempty(axes3)
            delete(axes3);
        end

        axes1f = axes1fPtr('get');
        if ~isempty(axes1f)
            delete(axes1f);
        end

        axes2f = axes2fPtr('get');
        if ~isempty(axes2f)
            delete(axes2f);
        end

        axes3f = axes3fPtr('get');
        if ~isempty(axes3f)
            delete(axes3f);
        end

        delete(uiSegPanelPtr       ('get'));
        delete(uiSegMainPanelPtr   ('get'));
        delete(uiKernelPanelPtr    ('get'));
        delete(uiKernelMainPanelPtr('get'));
        delete(uiRoiPanelPtr       ('get'));
        delete(uiRoiMainPanelPtr   ('get'));
        delete(fiMainWindowPtr     ('get'));
    catch
    end
end
