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

    dSeriesOffset      =  get(uiSeriesPtr('get'), 'Value');
    dFusedSeriesOffset =  get(uiFusedSeriesPtr('get'), 'Value');

    if size(dicomBuffer('get', [], dSeriesOffset), 3) == 1 

        atMetaData = dicomMetaData('get', [], dSeriesOffset);         

        if aspectRatio('get') == true      

            x = computeAspectRatio('x', atMetaData);
            y = computeAspectRatio('y', atMetaData);
            z = 1;

            daspect(axePtr('get', [], dSeriesOffset) , [x y z]); 

            if isFusion('get') == true

                xf = fusionAspectRatioValue('get', 'x');
                yf = fusionAspectRatioValue('get', 'y');
                zf = fusionAspectRatioValue('get', 'z');

                daspect(axefPtr('get', [], dFusedSeriesOffset), [zf yf xf]);
            end

            if isPlotContours('get') == true

               xf = fusionAspectRatioValue('get', 'x');
               yf = fusionAspectRatioValue('get', 'y');
               zf = fusionAspectRatioValue('get', 'z');
               
               daspect(axefcPtr('get', [], dFusedSeriesOffset), [zf yf xf]);
            end            

        else
            x =1;
            y =1;
            z =1;

            daspect(axePtr('get', [], dSeriesOffset) , [x y z]);  
            axis(axePtr('get', [], dSeriesOffset) , 'normal');                    

            if isFusion('get') == true

                xf = 1;
                yf = 1;
                zf = 1;

                daspect(axefPtr('get', [], dFusedSeriesOffset), [zf yf xf]);
                axis(axefPtr('get', [], dFusedSeriesOffset) , 'normal');                    
            end

            if isPlotContours('get') == true

               xf = 1;
               yf = 1;
               zf = 1;
               
               daspect(axefcPtr('get', [], dFusedSeriesOffset), [zf yf xf]);
               axis(axefcPtr('get', [], dFusedSeriesOffset) , 'normal');                    
           end              
        end

        aspectRatioValue('set', 'x', x);
        aspectRatioValue('set', 'y', y);
        aspectRatioValue('set', 'z', z);

    else
        if aspectRatio('get') == true

            atMetaData = dicomMetaData('get');         

            if ~isempty(atMetaData{1}.PixelSpacing)
                
                x = atMetaData{1}.PixelSpacing(1);
                y = atMetaData{1}.PixelSpacing(2);                                                   
                z = computeSliceSpacing(atMetaData);                   

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

                x = computeAspectRatio('x', atMetaData);
                y = computeAspectRatio('y', atMetaData);
                z = 1;                      
            end
            
            daspect(axes1Ptr('get', [], dSeriesOffset), [z y x]);
            daspect(axes2Ptr('get', [], dSeriesOffset), [z x y]);
            daspect(axes3Ptr('get', [], dSeriesOffset), [x y z]);

            if isVsplash('get') == false                                    
                daspect(axesMipPtr('get', [], dSeriesOffset), [z y x]);
            end
                
%           if strcmpi(imageOrientation('get'), 'axial') 

%                daspect(axes1Ptr('get', [], dSeriesOffset), [z x y]); 
%                daspect(axes2Ptr('get', [], dSeriesOffset), [z y x]); 
%                daspect(axes3Ptr('get', [], dSeriesOffset), [x y z]); 
                
%                if isVsplash('get') == false                    
%                    daspect(axesMipPtr('get', [], dSeriesOffset), [z x y]); 
%                end
               
%            elseif strcmpi(imageOrientation('get'), 'coronal') 

%                daspect(axes1Ptr('get', [], dSeriesOffset), [x y z]); 
%                daspect(axes2Ptr('get', [], dSeriesOffset), [y z x]); 
%                daspect(axes3Ptr('get', [], dSeriesOffset), [z x y]);       
                
%                if isVsplash('get') == false                                    
%                    daspect(axesMipPtr('get', [], dSeriesOffset), [x y z]);  
%                end
                
%            elseif strcmpi(imageOrientation('get'), 'sagittal')  
  
%                daspect(axes1Ptr('get', [], dSeriesOffset), [y x z]); 
%                daspect(axes2Ptr('get', [], dSeriesOffset), [x z y]); 
%                daspect(axes3Ptr('get', [], dSeriesOffset), [z x y]);
                
%                if isVsplash('get') == false                                    
%                    daspect(axesMipPtr('get', [], dSeriesOffset), [x z y]);  
%                end
%           end

           if isFusion('get') == true

               xf = fusionAspectRatioValue('get', 'x');
               yf = fusionAspectRatioValue('get', 'y');
               zf = fusionAspectRatioValue('get', 'z');
               
                daspect(axes1fPtr('get', [], dFusedSeriesOffset), [zf yf xf]);
                daspect(axes2fPtr('get', [], dFusedSeriesOffset), [zf xf yf]);
                daspect(axes3fPtr('get', [], dFusedSeriesOffset), [xf yf zf]);

                if isVsplash('get') == false                                    
                    daspect(axesMipfPtr('get', [], dFusedSeriesOffset), [zf yf xf]);
                end
            
%               if strcmpi(imageOrientation('get'), 'axial')                    

%                    daspect(axes1fPtr('get', [], dFusedSeriesOffset)  , [zf xf yf]); 
%                    daspect(axes2fPtr('get', [], dFusedSeriesOffset)  , [zf yf xf]);                         
%                    daspect(axes3fPtr('get', [], dFusedSeriesOffset)  , [xf yf zf]); 
                    
%                    if isVsplash('get') == false                    
%                        daspect(axesMipfPtr('get', [], dFusedSeriesOffset), [zf yf xf]); 
%                    end
                    
%               elseif strcmpi(imageOrientation('get'), 'coronal') 
%
%                    daspect(axes1fPtr('get', [], dFusedSeriesOffset), [xf yf zf]); 
%                    daspect(axes2fPtr('get', [], dFusedSeriesOffset), [yf zf xf]); 
%                    daspect(axes3fPtr('get', [], dFusedSeriesOffset), [zf xf yf]); 
                    
%                    if isVsplash('get') == false                    
%                        daspect(axesMipfPtr('get', [], dFusedSeriesOffset), [yf zf xf]);                          
%                    end

%                elseif strcmpi(imageOrientation('get'), 'sagittal')  

%                    daspect(axes1fPtr('get', [], dFusedSeriesOffset), [yf xf zf]);                     
%                    daspect(axes2fPtr('get', [], dFusedSeriesOffset), [xf zf yf]); 
%                    daspect(axes3fPtr('get', [], dFusedSeriesOffset), [zf xf yf]);  
                    
%                    if isVsplash('get') == false                    
%                        daspect(axesMipfPtr('get', [], dFusedSeriesOffset), [xf zf yf]);                                                                                            
%                    end
%               end 
           end
            
           if isPlotContours('get') == true

               xf = fusionAspectRatioValue('get', 'x');
               yf = fusionAspectRatioValue('get', 'y');
               zf = fusionAspectRatioValue('get', 'z');
               
               daspect(axes1fcPtr('get', [], dFusedSeriesOffset), [zf yf xf]);
               daspect(axes2fcPtr('get', [], dFusedSeriesOffset), [zf xf yf]);
               daspect(axes3fcPtr('get', [], dFusedSeriesOffset), [xf yf zf]);

               if isVsplash('get') == false                                    
                   daspect(axesMipfcPtr('get', [], dFusedSeriesOffset), [zf yf xf]);
               end
                
%               if strcmpi(imageOrientation('get'), 'axial')                    

%                    daspect(axes1fcPtr('get', [], dFusedSeriesOffset)  , [zf xf yf]); 
%                    daspect(axes2fcPtr('get', [], dFusedSeriesOffset)  , [zf yf xf]);                         
%                    daspect(axes3fcPtr('get', [], dFusedSeriesOffset)  , [xf yf zf]); 
                    
%                    if isVsplash('get') == false                    
%                        daspect(axesMipfcPtr('get', [], dFusedSeriesOffset), [zf yf xf]); 
%                    end
                    
%               elseif strcmpi(imageOrientation('get'), 'coronal') 

%                    daspect(axes1fcPtr('get', [], dFusedSeriesOffset), [xf yf zf]); 
%                    daspect(axes2fcPtr('get', [], dFusedSeriesOffset), [yf zf xf]); 
%                    daspect(axes3fcPtr('get', [], dFusedSeriesOffset), [zf xf yf]);       
                    
%                    if isVsplash('get') == false                                        
%                        daspect(axesMipfcPtr('get', [], dFusedSeriesOffset), [yf zf xf]);                          
%                    end

%                elseif strcmpi(imageOrientation('get'), 'sagittal')  

%                    daspect(axes1fcPtr('get', [], dFusedSeriesOffset), [yf xf zf]);                     
%                    daspect(axes2fcPtr('get', [], dFusedSeriesOffset), [xf zf yf]); 
%                    daspect(axes3fcPtr('get', [], dFusedSeriesOffset), [zf xf yf]);                                                                        
                    
%                    if isVsplash('get') == false                    
%                        daspect(axesMipfcPtr('get', [], dFusedSeriesOffset), [xf zf yf]);                                                                                            
%                    end
%               end 
            end           
           
        else
            x =1;
            y =1;
            z =1;            
            
            daspect(axes1Ptr('get', [], dSeriesOffset), [z x y]); 
            daspect(axes2Ptr('get', [], dSeriesOffset), [z y x]); 
            daspect(axes3Ptr('get', [], dSeriesOffset), [x y z]);                    
            
            if isVsplash('get') == false                    
                daspect(axesMipPtr('get', [], dSeriesOffset), [z y x]);                    
            end

            axis(axes1Ptr('get', [], dSeriesOffset), 'normal');
            axis(axes2Ptr('get', [], dSeriesOffset), 'normal');                    
            axis(axes3Ptr('get', [], dSeriesOffset), 'normal');   
            
            if isVsplash('get') == false                    
                axis(axesMipPtr('get', [], dSeriesOffset), 'normal');   
            end

            if isFusion('get') ==true
                
                daspect(axes1fPtr('get', [], dFusedSeriesOffset), [z x y]); 
                daspect(axes2fPtr('get', [], dFusedSeriesOffset), [z y x]); 
                daspect(axes3fPtr('get', [], dFusedSeriesOffset), [x y z]);                    
                
                if isVsplash('get') == false                    
                    daspect(axesMipfPtr('get', [], dFusedSeriesOffset), [z y x]);                    
                end

                axis(axes1fPtr  ('get', [], dFusedSeriesOffset), 'normal');
                axis(axes2fPtr  ('get', [], dFusedSeriesOffset), 'normal');                    
                axis(axes3fPtr  ('get', [], dFusedSeriesOffset), 'normal');                        
                
                if isVsplash('get') == false                    
                    axis(axesMipfPtr('get', [], dFusedSeriesOffset), 'normal');                        
                end
            end
            
            if isPlotContours('get') == true
                
                daspect(axes1fcPtr('get', [], dFusedSeriesOffset), [z x y]); 
                daspect(axes2fcPtr('get', [], dFusedSeriesOffset), [z y x]); 
                daspect(axes3fcPtr('get', [], dFusedSeriesOffset), [x y z]); 
                
                if isVsplash('get') == false                    
                    daspect(axesMipfcPtr('get', [], dFusedSeriesOffset), [z y x]);                    
                end

                axis(axes1fcPtr('get', [], dFusedSeriesOffset), 'normal');
                axis(axes2fcPtr('get', [], dFusedSeriesOffset), 'normal');                    
                axis(axes3fcPtr('get', [], dFusedSeriesOffset), 'normal');                        
                
                if isVsplash('get') == false                    
                    axis(axesMipfcPtr('get', [], dFusedSeriesOffset), 'normal');                        
                end
            end            
            
        end

        aspectRatioValue('set', 'x', x);
        aspectRatioValue('set', 'y', y);
        aspectRatioValue('set', 'z', z); 
    end
end