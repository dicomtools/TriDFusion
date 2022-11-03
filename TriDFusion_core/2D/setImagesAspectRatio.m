function setImagesAspectRatio()
%function setImagesAspectRatio()
%Set Images aspect ratio.
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

    if size(dicomBuffer('get'), 3) == 1 

        if aspectRatio('get') == true      

            x = computeAspectRatio('x', atMetaData);
            y = computeAspectRatio('y',atMetaData);
            z = 1;

            daspect(axefPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [x y z]); 
            daspect(axePtr('get', [], get(uiSeriesPtr('get'), 'Value')) , [x y z]); 
        else
            x =1;
            y =1;
            z =1;

            daspect(axefPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [x y z]);  
            daspect(axePtr('get', [], get(uiSeriesPtr('get'), 'Value')) , [x y z]);  

            axis(axefPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'normal');                    
            axis(axePtr('get', [], get(uiSeriesPtr('get'), 'Value')) , 'normal');                    
        end

        aspectRatioValue('set', 'x', x);
        aspectRatioValue('set', 'y', y);
        aspectRatioValue('set', 'z', z);

        set(axePtr('get', [], get(uiSeriesPtr('get'), 'Value')), 'CLim', [lMin lMax]);
        
        if isFusion('get') == true

            lFusionMin = fusionWindowLevel('get', 'min');   
            lFusionMax = fusionWindowLevel('get', 'max'); 

            set(axefPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'CLim', [lFusionMin lFusionMax]);
        end  
        
        if isPlotContours('get') == true

            lFusionMin = fusionWindowLevel('get', 'min');   
            lFusionMax = fusionWindowLevel('get', 'max'); 

            set(axefcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'CLim', [lFusionMin lFusionMax]);
        end  
    else
        if aspectRatio('get') == true

            atCoreMetaData = dicomMetaData('get');         

            if ~isempty(atCoreMetaData{1}.PixelSpacing)
                
                x = atCoreMetaData{1}.PixelSpacing(1);
                y = atCoreMetaData{1}.PixelSpacing(2);                                                   
                z = computeSliceSpacing(atCoreMetaData);                   

                if x == 0
                    x = 1;
                end

                if y == 0
                    y = 1;
                end                    

                if z == 0
                    z = x;
                end
            else

                x = computeAspectRatio('x', atCoreMetaData);
                y = computeAspectRatio('y', atCoreMetaData);
                z = 1;                      
            end
            
            daspect(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [z y x]);
            daspect(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [z x y]);
            daspect(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [x y z]);

            if isVsplash('get') == false                                    
                daspect(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), [z y x]);
            end
                
%           if strcmpi(imageOrientation('get'), 'axial') 

%                daspect(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [z x y]); 
%                daspect(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [z y x]); 
%                daspect(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [x y z]); 
                
%                if isVsplash('get') == false                    
%                    daspect(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), [z x y]); 
%                end
               
%            elseif strcmpi(imageOrientation('get'), 'coronal') 

%                daspect(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [x y z]); 
%                daspect(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [y z x]); 
%                daspect(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [z x y]);       
                
%                if isVsplash('get') == false                                    
%                    daspect(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), [x y z]);  
%                end
                
%            elseif strcmpi(imageOrientation('get'), 'sagittal')  
  
%                daspect(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [y x z]); 
%                daspect(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [x z y]); 
%                daspect(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [z x y]);
                
%                if isVsplash('get') == false                                    
%                    daspect(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), [x z y]);  
%                end
%           end

           if isFusion('get') == true

               xf = fusionAspectRatioValue('get', 'x');
               yf = fusionAspectRatioValue('get', 'y');
               zf = fusionAspectRatioValue('get', 'z');
               
                daspect(axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [zf yf xf]);
                daspect(axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [zf xf yf]);
                daspect(axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [xf yf zf]);

                if isVsplash('get') == false                                    
                    daspect(axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [zf yf xf]);
                end
            
%               if strcmpi(imageOrientation('get'), 'axial')                    

%                    daspect(axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))  , [zf xf yf]); 
%                    daspect(axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))  , [zf yf xf]);                         
%                    daspect(axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))  , [xf yf zf]); 
                    
%                    if isVsplash('get') == false                    
%                        daspect(axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [zf yf xf]); 
%                    end
                    
%               elseif strcmpi(imageOrientation('get'), 'coronal') 
%
%                    daspect(axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [xf yf zf]); 
%                    daspect(axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [yf zf xf]); 
%                    daspect(axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [zf xf yf]); 
                    
%                    if isVsplash('get') == false                    
%                        daspect(axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [yf zf xf]);                          
%                    end

%                elseif strcmpi(imageOrientation('get'), 'sagittal')  

%                    daspect(axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [yf xf zf]);                     
%                    daspect(axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [xf zf yf]); 
%                    daspect(axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [zf xf yf]);  
                    
%                    if isVsplash('get') == false                    
%                        daspect(axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [xf zf yf]);                                                                                            
%                    end
%               end 
           end
            
           if isPlotContours('get') == true

               xf = fusionAspectRatioValue('get', 'x');
               yf = fusionAspectRatioValue('get', 'y');
               zf = fusionAspectRatioValue('get', 'z');
               
               daspect(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [zf yf xf]);
               daspect(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [zf xf yf]);
               daspect(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [xf yf zf]);

               if isVsplash('get') == false                                    
                   daspect(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [zf yf xf]);
               end
                
%               if strcmpi(imageOrientation('get'), 'axial')                    

%                    daspect(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))  , [zf xf yf]); 
%                    daspect(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))  , [zf yf xf]);                         
%                    daspect(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value'))  , [xf yf zf]); 
                    
%                    if isVsplash('get') == false                    
%                        daspect(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [zf yf xf]); 
%                    end
                    
%               elseif strcmpi(imageOrientation('get'), 'coronal') 

%                    daspect(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [xf yf zf]); 
%                    daspect(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [yf zf xf]); 
%                    daspect(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [zf xf yf]);       
                    
%                    if isVsplash('get') == false                                        
%                        daspect(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [yf zf xf]);                          
%                    end

%                elseif strcmpi(imageOrientation('get'), 'sagittal')  

%                    daspect(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [yf xf zf]);                     
%                    daspect(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [xf zf yf]); 
%                    daspect(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [zf xf yf]);                                                                        
                    
%                    if isVsplash('get') == false                    
%                        daspect(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [xf zf yf]);                                                                                            
%                    end
%               end 
            end           
           
        else
            x =1;
            y =1;
            z =1;            
            
            daspect(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [z x y]); 
            daspect(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [z y x]); 
            daspect(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), [x y z]);                    
            
            if isVsplash('get') == false                    
                daspect(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), [z y x]);                    
            end

            axis(axes1Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'normal');
            axis(axes2Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'normal');                    
            axis(axes3Ptr('get', [], get(uiSeriesPtr('get'), 'Value')), 'normal');   
            
            if isVsplash('get') == false                    
                axis(axesMipPtr('get', [], get(uiSeriesPtr('get'), 'Value')), 'normal');   
            end

            if isFusion('get') ==true
                
                daspect(axes1fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [z x y]); 
                daspect(axes2fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [z y x]); 
                daspect(axes3fPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [x y z]);                    
                
                if isVsplash('get') == false                    
                    daspect(axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [z y x]);                    
                end

                axis(axes1fPtr  ('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'normal');
                axis(axes2fPtr  ('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'normal');                    
                axis(axes3fPtr  ('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'normal');                        
                
                if isVsplash('get') == false                    
                    axis(axesMipfPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'normal');                        
                end
            end
            
            if isPlotContours('get') == true
                
                daspect(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [z x y]); 
                daspect(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [z y x]); 
                daspect(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [x y z]); 
                
                if isVsplash('get') == false                    
                    daspect(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), [z y x]);                    
                end

                axis(axes1fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'normal');
                axis(axes2fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'normal');                    
                axis(axes3fcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'normal');                        
                
                if isVsplash('get') == false                    
                    axis(axesMipfcPtr('get', [], get(uiFusedSeriesPtr('get'), 'Value')), 'normal');                        
                end
            end            
            
        end

        aspectRatioValue('set', 'x', x);
        aspectRatioValue('set', 'y', y);
        aspectRatioValue('set', 'z', z); 
    end
end