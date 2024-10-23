function adjBrush2D(pRoiPtr, dInitCoord)
%function adjBrush2D(pRoiPtr, dInitCoord)
%Ajust 2D brush size.
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

    persistent pdInitialCoord;
    persistent pdInitialDiameter;

    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

    % pAxe = gca(fiMainWindowPtr('get'));

    % if isempty(pAxe)
    %     return;
    % end

    if exist('dInitCoord', 'var')
        pdInitialCoord = dInitCoord;
        pdInitialDiameter = brush2dDefaultDiameter('get'); % in mm
        return;
    end

    aPosDiff = pRoiPtr.Parent.CurrentPoint(1, 1:2) - pdInitialCoord;
 
    atMetaData = dicomMetaData('get', [], dSeriesOffset);
    
    switch(pRoiPtr.Parent)
        
        case axes1Ptr('get', [], dSeriesOffset) % Coronal                    
            xPixel = atMetaData{1}.PixelSpacing(1);
            yPixel = computeSliceSpacing(atMetaData);                                       
            
        case axes2Ptr('get', [], dSeriesOffset) % Sagittal
            xPixel = atMetaData{1}.PixelSpacing(2);
            yPixel = computeSliceSpacing(atMetaData);
            
        otherwise % Axial
            xPixel = atMetaData{1}.PixelSpacing(1);
            yPixel = atMetaData{1}.PixelSpacing(2);
    end
    
    if xPixel == 0
        xPixel = 1;
    end
    
    if yPixel == 0
        yPixel = 1;
    end

    dWLAdjCoe = 1/xPixel;

    dSphereDiameter = pdInitialDiameter-aPosDiff(2) / dWLAdjCoe;
    
    if dSphereDiameter > 0
    %     if dSphereDiameter < 5
    %         dSphereDiameter = 5;
    %     end
    
        dSemiAxesX = dSphereDiameter/xPixel/2; % In pixel
        dSemiAxesY = dSphereDiameter/yPixel/2; % In pixel
    
        newPosition = pRoiPtr.Parent.CurrentPoint(1, 1:2);
    
        pRoiPtr.Position = newPosition;
        pRoiPtr.SemiAxes = [dSemiAxesX dSemiAxesY];
    
      %  set(pRoiPtr, 'SemiAxes', [dSemiAxesX dSemiAxesY]);
    
        brush2dDefaultDiameter('set', dSphereDiameter);  
        
    end
    % 
    % windowButton('set', 'down');  
    % 
    % rightClickMenu('off');
   % pdInitialCoord = get(0,'PointerLocation');

%    refreshImages();
end
