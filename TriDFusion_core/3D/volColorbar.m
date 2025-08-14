function uivolColorbar = volColorbar(uiWindow, aColorMap)  
%function uivolColorbar = volColorbar(uiWindow, aColorMap)  
%Display 3D Volome Colorbar.
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

    mipColorObj = mipColorObject('get');
    if isempty(mipColorObj)
        xOffset = 20;
    else
        if mipColorObj.Position(1) == 280
            xOffset = 20;
        else    
            xOffset = 280;                
        end
    end

    uivolColorbar = ...
        axes(uiWindow,...
             'Units'   , 'pixels',...
             'position', [xOffset 40 250 100]...
            ); 
    uivolColorbar.Interactions = [];
    deleteAxesToolbar(uivolColorbar);
    % uivolColorbar.Toolbar = [];

    x = 1:size(aColorMap,1);

%            aColorMap = flipud(aColorMap); % patch

    plot(uivolColorbar, x,aColorMap(:,1),'r-',x,aColorMap(:,2),'g-',x,aColorMap(:,3),'b-');

    uivolColorbar.XLim = [0 size(x,2)];
    uivolColorbar.YLim = [0 1]; 

    colormap(uivolColorbar, aColorMap);

    c = colorbar(uivolColorbar, 'Ticks',[]);
    c.Label.String = 'Volume';
    c.UIContextMenu = '';           

%       l = legend(uivolColorbar, '\color{red} red','\color{green} green','\color{blue} blue','\color{cyan} alpha');
    if strcmp(surfaceColor('get', background3DOffset('get')), 'black')||...
       strcmp(surfaceColor('get', background3DOffset('get')), 'blue' )
        c.Label.Color = [0.8500 0.8500 0.8500];
        uivolColorbar.XColor = [0.8500 0.8500 0.8500];
        uivolColorbar.YColor = [0.8500 0.8500 0.8500];

        uivolColorbar.XAxis.Color = [0.8500 0.8500 0.8500];
        uivolColorbar.YAxis.Color = [0.8500 0.8500 0.8500];

        if strcmp(surfaceColor('get', background3DOffset('get')), 'black')
            uivolColorbar.Color = [0.1 0.1 0.1];
        else
            uivolColorbar.Color = [0 0 0.9];
        end
    else
        c.Label.Color = [0.1500 0.1500 0.1500];
        uivolColorbar.XColor = [0.1500 0.1500 0.1500];
        uivolColorbar.YColor = [0.1500 0.1500 0.1500];

        uivolColorbar.XAxis.Color = [0.1500 0.1500 0.1500];
        uivolColorbar.YAxis.Color = [0.1500 0.1500 0.1500];

        uivolColorbar.Color = [0.99 0.99 0.99];

    end

end  