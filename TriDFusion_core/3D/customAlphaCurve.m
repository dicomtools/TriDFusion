function ic = customAlphaCurve(objEditorAxe, surfObj, sType)
%function ic = customAlphaCurve(objEditorAxe, surfObj, sType)
%Create a custom 3D Interactive Plot Alpha Curve.
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

    cla(objEditorAxe, 'reset');
    objEditorAxe.Interactions = [zoomInteraction regionZoomInteraction rulerPanInteraction];
    objEditorAxe.Toolbar.Visible = 'off';
    disableDefaultInteractivity(objEditorAxe);

    if      strcmpi(sType, 'mip')
        ic = mipICObject('get');
    elseif strcmpi(sType, 'mipfusion')
        ic = mipICFusionObject('get');
    elseif strcmpi(sType, 'vol')
        ic = volICObject('get');
    elseif strcmpi(sType, 'volfusion')
        ic = volICFusionObject('get');
    else
        ic = '';
        return;
    end

    aAlphamap = linspace(0, 1, 256)';
    xMarkers  = 1:size(aAlphamap,1);

    yMarkers = zeros(1,size(aAlphamap,1));
    yMarkers(1,:) = aAlphamap(:,1);

    objEditorAxe.Color  = viewerAxesColor('get');
    objEditorAxe.XColor = viewerForegroundColor('get');
    objEditorAxe.YColor = viewerForegroundColor('get');
    objEditorAxe.ZColor = viewerForegroundColor('get');
    objEditorAxe.XLim = [0 size(xMarkers,2)];
    objEditorAxe.YLim = [0 1];

    axis(objEditorAxe, 'manual');

    if ~isempty(ic)
        dNbOfMarkers = ic.numberOfMarkers;
        aX = ic.x;
        aY = ic.y;

        deleteAlphaCurve(sType);

        ic = interactive_curve(fiMainWindowPtr('get'), objEditorAxe, xMarkers, yMarkers);
        ic.setBoundary(1);

        ic.surfObj = surfObj;

        deleteMarkerByHandle(ic, ic.markersHandles);

        for jj=1:dNbOfMarkers
            addMarker(ic,aX(jj), aY(jj));
        end

    else

        ic = interactive_curve(fiMainWindowPtr('get'), objEditorAxe, xMarkers, yMarkers);
        ic.setBoundary(1);

        ic.surfObj = surfObj;

        deleteMarkerByHandle(ic, ic.markersHandles);
    %    addMarker(ic,0,0);
        if strcmpi(sType, 'mip')
            addMarker(ic,60,1);
    %                addMarker(ic,200,1);
        else
            addMarker(ic,size(aAlphamap,1),1);
        end
    end

    guidata(fiMainWindowPtr('get'), objEditorAxe);

end
