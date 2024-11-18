function resampleAxes(refImage, atRefMetaData)
%function resampleAxes(refImage, atRefMetaData)
%Resample TCS and 2D Axes to a reference.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Note: option settings must fit on one line and can contain one semicolon at most.
%Options can be strings, cell arrays of strings, or numerical arrays.
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
        
    
    if size(refImage, 3) == 1 % To do 2D
                            
        if atRefMetaData{1}.PixelSpacing(1) == 0 && ...
           atRefMetaData{1}.PixelSpacing(2) == 0 
            for jj=1:numel(atRefMetaData)
                atRefMetaData{1}.PixelSpacing(1) =1;
                atRefMetaData{1}.PixelSpacing(2) =1;
            end       
        end

        Rdcm  = imref2d(size(refImage), atRefMetaData{1}.PixelSpacing(2), atRefMetaData{1}.PixelSpacing(1));
                
        axe = axePtr('get', [], get(uiSeriesPtr('get'), 'Value'));
                
        set(axe, 'XLim', Rdcm.XIntrinsicLimits);
        set(axe, 'YLim', Rdcm.YIntrinsicLimits);
        
        if isFusion('get')
            axeF = axefPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));

            set(axeF, 'XLim', Rdcm.XIntrinsicLimits);
            set(axeF, 'YLim', Rdcm.YIntrinsicLimits);            
        end           
        
    else
        refSliceThickness = computeSliceSpacing(atRefMetaData);
      
        if refSliceThickness == 0  
            refSliceThickness = 1;
        end
      
        if atRefMetaData{1}.PixelSpacing(1) == 0 && ...
           atRefMetaData{1}.PixelSpacing(2) == 0 
            for jj=1:numel(atRefMetaData)
                atRefMetaData{1}.PixelSpacing(1) =1;
                atRefMetaData{1}.PixelSpacing(2) =1;
            end       
        end

        Rdcm  = imref3d(size(refImage), atRefMetaData{1}.PixelSpacing(2), atRefMetaData{1}.PixelSpacing(1), refSliceThickness);
                
        axes1 = axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value'));
        axes2 = axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value'));
        axes3 = axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value'));        
        
        if ~isempty(axes1)    
            set(axes1, 'XLim', Rdcm.XIntrinsicLimits);
            set(axes1, 'YLim', Rdcm.ZIntrinsicLimits);
        end
        
        if ~isempty(axes2)    
            set(axes2, 'XLim', Rdcm.YIntrinsicLimits);
            set(axes2, 'YLim', Rdcm.ZIntrinsicLimits);
        end
        
        if ~isempty(axes3)    
            set(axes3, 'XLim', Rdcm.XIntrinsicLimits);
            set(axes3, 'YLim', Rdcm.YIntrinsicLimits);
        end
        
        if isVsplash('get') == false                    
            axesMip = axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value'));        
            if ~isempty(axesMip)    
                set(axesMip, 'XLim', Rdcm.XIntrinsicLimits);
                set(axesMip, 'YLim', Rdcm.ZIntrinsicLimits);        
            end
        end
        
        if isFusion('get')
            
            axes1F = axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));
            axes2F = axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));
            axes3F = axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));

            if ~isempty(axes1F)    
                set(axes1F, 'XLim', Rdcm.XIntrinsicLimits);
                set(axes1F, 'YLim', Rdcm.ZIntrinsicLimits);
            end

            if ~isempty(axes2F)    
                set(axes2F, 'XLim', Rdcm.YIntrinsicLimits);
                set(axes2F, 'YLim', Rdcm.ZIntrinsicLimits);
            end

            if ~isempty(axes3F)    
                set(axes3F, 'XLim', Rdcm.XIntrinsicLimits);
                set(axes3F, 'YLim', Rdcm.YIntrinsicLimits);
            end
            
            if isVsplash('get') == false                    
            
                axesMipF = axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));
                if ~isempty(axesMipF)    
                    set(axesMipF, 'XLim', Rdcm.XIntrinsicLimits);
                    set(axesMipF, 'YLim', Rdcm.ZIntrinsicLimits);
                end
            end
        end   

        if isPlotContours('get')
            
            axes1Fc = axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));
            axes2Fc = axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));
            axes3Fc = axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));

            if ~isempty(axes1Fc)    
                set(axes1Fc, 'XLim', Rdcm.XIntrinsicLimits);
                set(axes1Fc, 'YLim', Rdcm.ZIntrinsicLimits);
            end

            if ~isempty(axes2Fc)    
                set(axes2Fc, 'XLim', Rdcm.YIntrinsicLimits);
                set(axes2Fc, 'YLim', Rdcm.ZIntrinsicLimits);
            end

            if ~isempty(axes3Fc)    
                set(axes3Fc, 'XLim', Rdcm.XIntrinsicLimits);
                set(axes3Fc, 'YLim', Rdcm.YIntrinsicLimits);
            end
            
            if isVsplash('get') == false                    
            
                axesMipFc = axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'));
                if ~isempty(axesMipFc)    
                    set(axesMipFc, 'XLim', Rdcm.XIntrinsicLimits);
                    set(axesMipFc, 'YLim', Rdcm.ZIntrinsicLimits);
                end
            end
         end       

    end 
end  

