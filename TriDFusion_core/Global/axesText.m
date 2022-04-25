function pText = axesText(sAction, sAxes, pValue)
%function pText = axesText(sAction, sAxes, pValue)
%Get/Set 2D axes text.
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

    persistent pAxeText;
    persistent pAxes1Text;
    persistent pAxes2Text;
    persistent pAxes3Text;
    persistent pAxesMipText;
    
    persistent pAxefText;
    persistent pAxes1fText;
    persistent pAxes2fText;
    persistent pAxes3fText;    
    persistent pAxesMipfText;
    
    persistent pAxeViewText;
    persistent pAxes1ViewText;
    persistent pAxes2ViewText;
    persistent pAxes3ViewText;    
    persistent pAxesMipViewText;

    if strcmpi('set', sAction)
        
        if strcmpi('axe', sAxes)
            pAxeText = pValue;
        elseif strcmpi('axes1', sAxes)
            pAxes1Text = pValue;
        elseif strcmpi('axes2', sAxes)
            pAxes2Text = pValue;
        elseif strcmpi('axes3', sAxes)
            pAxes3Text = pValue;
        elseif strcmpi('axesMip', sAxes)
            pAxesMipText = pValue;    
            
        elseif strcmpi('axef', sAxes)
            pAxefText = pValue;
        elseif strcmpi('axes1f', sAxes)
            pAxes1fText = pValue;
        elseif strcmpi('axes2f', sAxes)
            pAxes2fText = pValue;
        elseif strcmpi('axes3f', sAxes)
            pAxes3fText = pValue;    
        elseif strcmpi('axesMipf', sAxes)
            pAxesMipfText = pValue;  
            
        elseif strcmpi('axeView', sAxes)
            pAxeViewText = pValue;            
        elseif strcmpi('axes1View', sAxes)
            pAxes1ViewText = pValue;
        elseif strcmpi('axes2View', sAxes)
            pAxes2ViewText = pValue;
        elseif strcmpi('axes3View', sAxes)
            pAxes3ViewText = pValue;                     
        elseif strcmpi('axesMipView', sAxes)
            pAxesMipViewText = pValue;             
        else
        end
    elseif strcmpi('reset', sAction)
        
        if strcmpi('axe', sAxes)
            if ~isempty(pAxeText)
                delete(pAxeText);
                clear pAxeText;
                pAxeText = '';
            end              
        elseif strcmpi('axes1', sAxes)
            if ~isempty(pAxes1Text)
                delete(pAxes1Text);
                clear pAxes1Text;
                pAxes1Text = '';
            end             
        elseif strcmpi('axes2', sAxes)
            if ~isempty(pAxes2Text)
                delete(pAxes2Text);
                clear pAxes2Text;
                pAxes2Text = '';
            end              
        elseif strcmpi('axes3', sAxes)
            if ~isempty(pAxes3Text)
                delete(pAxes3Text);
                clear pAxes3Text;
                pAxes3Text = '';
            end 
        elseif strcmpi('axesMip', sAxes)
            if ~isempty(pAxesMipText)
                delete(pAxesMipText);
                clear pAxesMipText;
                pAxesMipText = '';
            end  
            
        elseif strcmpi('axef', sAxes)
            if ~isempty(pAxefText)
                delete(pAxefText);
                clear pAxefText;
                pAxefText = '';
            end              
        elseif strcmpi('axes1f', sAxes)
            if ~isempty(pAxes1fText)
                delete(pAxes1fText);
                clear pAxes1fText;
                pAxes1fText = '';
            end             
        elseif strcmpi('axes2f', sAxes)
            if ~isempty(pAxes2fText)
                delete(pAxes2fText);
                clear pAxes2fText;
                pAxes2fText = '';
            end              
        elseif strcmpi('axes3f', sAxes)
            if ~isempty(pAxes3fText)
                delete(pAxes3fText);
                clear pAxes3fText;
                pAxes3fText = '';
            end
        elseif strcmpi('axesMipf', sAxes)
            if ~isempty(pAxesMipfText)
                delete(pAxesMipfText);
                clear pAxesMipfText;
                pAxesMipfText = '';
            end  
            
        elseif strcmpi('axeView', sAxes)
            if ~isempty(pAxeViewText)
                
                if numel(pAxeViewText) > 1
                    for jj=1:numel(pAxeViewText)
                        delete(pAxeViewText{jj});
                    end
                else
                    delete(pAxeViewText);
                end
                clear pAxeViewText;
                pAxeViewText = '';
            end               
        elseif strcmpi('axes1View', sAxes)
            if ~isempty(pAxes1ViewText)
                
                if numel(pAxes1ViewText) > 1                
                    for jj=1:numel(pAxes1ViewText)
                        delete(pAxes1ViewText{jj});
                    end
                else
                    delete(pAxes1ViewText);
                end
                
                clear pAxes1ViewText;
                pAxes1ViewText = '';
            end              
        elseif strcmpi('axes2View', sAxes)
            if ~isempty(pAxes2ViewText)
                
                if numel(pAxes2ViewText) > 1                
                    for jj=1:numel(pAxes2ViewText)
                        delete(pAxes2ViewText{jj});
                    end
                else
                    delete(pAxes2ViewText);
                end
                
                clear pAxes2ViewText;
                pAxes2ViewText = '';
            end              
        elseif strcmpi('axes3View', sAxes)
            if ~isempty(pAxes3ViewText)
                
                if numel(pAxes3ViewText) > 1                
                    for jj=1:numel(pAxes3ViewText)
                        delete(pAxes3ViewText{jj});
                    end
                else
                    delete(pAxes3ViewText);
                end
                
                clear pAxes3ViewText;
                pAxes3ViewText = '';                
            end                          
        elseif strcmpi('axesMipView', sAxes)
            if ~isempty(pAxesMipViewText)
                
                if numel(pAxesMipViewText) > 1                
                    for jj=1:numel(pAxesMipViewText)
                        delete(pAxesMipViewText{jj});
                    end
                else
                    delete(pAxesMipViewText);
                end
                
                clear pAxesMipViewText;
                pAxesMipViewText = '';
            end               
        else
        end        
    else
        if strcmpi('axe', sAxes)
            pText = pAxeText;           
        elseif strcmpi('axes1', sAxes)
            pText = pAxes1Text;
        elseif strcmpi('axes2', sAxes)
            pText = pAxes2Text;
        elseif strcmpi('axes3', sAxes)
            pText = pAxes3Text;            
        elseif strcmpi('axesMip', sAxes)
            pText = pAxesMipText;
            
        elseif strcmpi('axef', sAxes)
            pText = pAxefText;           
        elseif strcmpi('axes1f', sAxes)
            pText = pAxes1fText;
        elseif strcmpi('axes2f', sAxes)
            pText = pAxes2fText;
        elseif strcmpi('axes3f', sAxes)
            pText = pAxes3fText;            
        elseif strcmpi('axesMipf', sAxes)
            pText = pAxesMipfText;
            
        elseif strcmpi('axeView', sAxes)
            pText = pAxeViewText;              
        elseif strcmpi('axes1View', sAxes)
            pText = pAxes1ViewText;             
        elseif strcmpi('axes2View', sAxes)
            pText = pAxes2ViewText;  
        elseif strcmpi('axes3View', sAxes)
            pText = pAxes3ViewText;                
        elseif strcmpi('axesMipView', sAxes)
            pText = pAxesMipViewText;             
        else
        end
    end                                  
end