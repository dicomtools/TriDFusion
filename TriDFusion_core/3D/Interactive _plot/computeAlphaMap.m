function aAlphamap = computeAlphaMap(ic)
%function aAlphamap = computeAlphaMap(ic)  
%Compute Interactive Plot Alphamap. 
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

    aAlphamap = [];

    if numel(ic.y) == 1
        a = linspace(0, ic.y(1), round(ic.x(1)) )';
        aAlphamap = [a; linspace(ic.y(1), 0, 256-round(ic.x(1)) )'];
    else             
        for ii=1:numel(ic.y)-1

            if ic.y(ii) < 0
                y1 = 0;
            elseif ic.y(ii) > 1
                y1 = 1;
            else
                y1 = ic.y(ii);
            end

            if ic.y(ii+1) < 0
                y2 = 0;
            elseif ic.y(ii+1) > 1
                y2 = 1;
            else
                y2 = ic.y(ii+1);
            end    

            if ii == 1 && ic.x(1) > 0
                a = linspace(0, y1, round(ic.x(ii)) )';
                a = [a;linspace(y1, y2, (round(ic.x(ii+1))-round(ic.x(ii))) )'];

            else                
                a = linspace(y1, y2, (round(ic.x(ii+1))-round(ic.x(ii))) )';
            end

            if ii==1
                aAlphamap = a;
            else
                aAlphamap = [aAlphamap;a];
            end
        end

        if ic.x(ii+1) < 256
            a = linspace(y2, 0, 256-round(ic.x(ii+1)) )';
            aAlphamap = [aAlphamap;a];
        end
    end

 end