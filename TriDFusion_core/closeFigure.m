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

        % Delete temp directory

        if exist(viewerTempDirectory('get'), 'dir')
            rmdir(viewerTempDirectory('get'), 's');
        end

        multiFramePlayback('set', false);
        multiFrame3DPlayback('set', false);

        % releaseRoiWait();

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

        imAxePtr  ('reset');
        imAxeFcPtr('reset');
        imAxeFPtr ('reset');

        axePtr  ('reset');
        axefcPtr('reset');
        axefPtr ('reset');

        uiOneWindow = uiOneWindowPtr('get');
        if ~isempty(uiOneWindow)
           delete(uiOneWindow);
        end

        imCoronalPtr ('reset');
        imSagittalPtr('reset');
        imAxialPtr   ('reset');
        imMipPtr     ('reset');

        axes1Ptr  ('reset');
        axes2Ptr  ('reset');
        axes3Ptr  ('reset');
        axesMipPtr('reset');

        imCoronalFPtr ('reset');
        imSagittalFPtr('reset');
        imAxialFPtr   ('reset');
        imMipFPtr     ('reset');

        axes1fPtr  ('reset');
        axes2fPtr  ('reset');
        axes3fPtr  ('reset');
        axesMipfPtr('reset');

        imCoronalFcPtr ('reset');
        imSagittalFcPtr('reset');
        imAxialFcPtr   ('reset');
        imMipFcPtr     ('reset');

        axes1fcPtr  ('reset');
        axes2fcPtr  ('reset');
        axes3fcPtr  ('reset');
        axesMipfcPtr('reset');

        uiCorWindow = uiCorWindowPtr('get');
        if ~isempty(uiCorWindow)
            delete(uiCorWindow);
        end

        uiSagWindow = uiSagWindowPtr('get');
        if ~isempty(uiSagWindow)
            delete(uiSagWindow);
        end

        uiTraWindow = uiTraWindowPtr('get');
        if ~isempty(uiTraWindow)
            delete(uiTraWindow);
        end

        uiMipWindow = uiMipWindowPtr('get');
        if ~isempty(uiMipWindow)
            delete(uiMipWindow);
        end

        delete(uiSegPanelPtr       ('get'));
        delete(uiSegMainPanelPtr   ('get'));
        delete(uiKernelPanelPtr    ('get'));
        delete(uiKernelMainPanelPtr('get'));
        delete(uiRoiPanelPtr       ('get'));
        delete(uiRoiMainPanelPtr   ('get'));
        delete(fiMainWindowPtr     ('get'));
        
        quantificationTemplate('reset');

        dicomMetaData('reset');
        dicomBuffer  ('reset');
        fusionBuffer ('reset');
        inputBuffer  ('set', '');

        mipBuffer      ('reset');
        mipFusionBuffer('reset');

%        clear('all');

    catch
        delete(gcf);
    end

end
