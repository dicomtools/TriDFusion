function setPatientDoseCallback(~, ~)
%function setPatientDoseCallback(~, ~)
%Get\Set Patient Dose Information.
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

    atDoseMetaData = dicomMetaData('get');
    
    if isfield(atDoseMetaData{1}, 'RadiopharmaceuticalInformationSequence') 

        dlgPatientDose = ...
            dialog('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-480/2) ...
                                (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-390/2) ...
                                480 ...
                                390 ...
                                ],...
                  'Color', viewerBackgroundColor('get'), ...
                  'Name', 'Dose Properties'...
                   );
               
        patWeight   = atDoseMetaData{1}.PatientWeight;
        patSize     = atDoseMetaData{1}.PatientSize;   
        acqDate     = atDoseMetaData{1}.SeriesDate;        
        acqTime     = atDoseMetaData{1}.SeriesTime;
        injDose     = atDoseMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideTotalDose;
        injDateTime = atDoseMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartDateTime;      
        halfLife    = atDoseMetaData{1}.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideHalfLife;               
        
             uicontrol(dlgPatientDose,...
                     'style'   , 'text',...
                     'string'  , 'Warning: Proceed with modification will affect SUV values',...
                     'horizontalalignment', 'left',...
                     'BackgroundColor', viewerBackgroundColor('get'), ...
                     'ForegroundColor', 'red', ...                   
                     'position', [20 340 440 20]...
                     );
                 
            uicontrol(dlgPatientDose,...
                     'style'   , 'text',...
                     'string'  , 'Patient Weight (kilograms)',...
                     'horizontalalignment', 'left',...
                     'BackgroundColor', viewerBackgroundColor('get'), ...
                     'ForegroundColor', viewerForegroundColor('get'), ...                   
                     'position', [20 287 280 20]...
                     );

      edtPatWeight = ...
          uicontrol(dlgPatientDose,...
                    'style'     , 'edit',...
                    'Background', 'white',...
                    'string'    , patWeight,...
                    'BackgroundColor', viewerBackgroundColor('get'), ...
                    'ForegroundColor', viewerForegroundColor('get'), ...                 
                    'position'  , [300 290 160 20]...
                    );  

            uicontrol(dlgPatientDose,...
                     'style'   , 'text',...
                     'string'  , 'Patient Size (meters)',...
                     'horizontalalignment', 'left',...
                     'BackgroundColor', viewerBackgroundColor('get'), ...
                     'ForegroundColor', viewerForegroundColor('get'), ...                   
                     'position', [20 262 280 20]...
                     );

      edtPatSize = ...
          uicontrol(dlgPatientDose,...
                    'style'     , 'edit',...
                    'Background', 'white',...
                    'string'    , patSize,...
                    'BackgroundColor', viewerBackgroundColor('get'), ...
                    'ForegroundColor', viewerForegroundColor('get'), ...                 
                    'position'  , [300 265 160 20]...
                    );  

        % Series Date

            uicontrol(dlgPatientDose,...
                     'style'   , 'text',...
                     'string'  , 'Series Date',...
                     'horizontalalignment', 'left',...
                     'BackgroundColor', viewerBackgroundColor('get'), ...
                     'ForegroundColor', viewerForegroundColor('get'), ...                   
                     'position', [20 237 280 20]...
                     );

           uicontrol(dlgPatientDose,...
                     'style'   , 'text',...
                     'string'  , 'Format (yyyyMMdd)',...
                     'horizontalalignment', 'left',...
                     'BackgroundColor', viewerBackgroundColor('get'), ...
                     'ForegroundColor', viewerForegroundColor('get'), ...                   
                     'position', [20 212 280 20]...
                     );

      edtAcqDate = ...
          uicontrol(dlgPatientDose,...
                    'style'     , 'edit',...
                    'Background', 'white',...
                    'string'    , acqDate,...
                    'BackgroundColor', viewerBackgroundColor('get'), ...
                    'ForegroundColor', viewerForegroundColor('get'), ...                 
                    'position'  , [300 215 160 20]...
                    );  

        % Series Time     

           uicontrol(dlgPatientDose,...
                     'style'   , 'text',...
                     'string'  , 'Series Time',...
                     'horizontalalignment', 'left',...
                     'BackgroundColor', viewerBackgroundColor('get'), ...
                     'ForegroundColor', viewerForegroundColor('get'), ...                   
                     'position', [20 187 280 20]...
                     );

           uicontrol(dlgPatientDose,...
                     'style'   , 'text',...
                     'string'  , 'Format (HHmmss)',...
                     'horizontalalignment', 'left',...
                     'BackgroundColor', viewerBackgroundColor('get'), ...
                     'ForegroundColor', viewerForegroundColor('get'), ...                   
                     'position', [20 162 280 20]...
                     );

      edtAcqTime = ...
          uicontrol(dlgPatientDose,...
                    'style'     , 'edit',...
                    'Background', 'white',...
                    'string'    , acqTime,...
                    'BackgroundColor', viewerBackgroundColor('get'), ...
                    'ForegroundColor', viewerForegroundColor('get'), ...                 
                    'position'  , [300 165 160 20]...
                    );  

        % Radionuclide Total Dose    

           uicontrol(dlgPatientDose,...
                     'style'   , 'text',...
                     'string'  , 'Radionuclide Total Dose (Mbq)',...
                     'horizontalalignment', 'left',...
                     'BackgroundColor', viewerBackgroundColor('get'), ...
                     'ForegroundColor', viewerForegroundColor('get'), ...                   
                     'position', [20 137 280 20]...
                     );

      edtInjDose = ...
          uicontrol(dlgPatientDose,...
                    'style'     , 'edit',...
                    'Background', 'white',...
                    'string'    , injDose,...
                    'BackgroundColor', viewerBackgroundColor('get'), ...
                    'ForegroundColor', viewerForegroundColor('get'), ...                 
                    'position'  , [300 140 160 20]...
                    );          

        % Radiopharmaceutical Start Date Time     

           uicontrol(dlgPatientDose,...
                     'style'   , 'text',...
                     'string'  , 'Radiopharmaceutical Start Date Time',...
                     'horizontalalignment', 'left',...
                     'BackgroundColor', viewerBackgroundColor('get'), ...
                     'ForegroundColor', viewerForegroundColor('get'), ...                   
                     'position', [20 112 280 20]...
                     );

           uicontrol(dlgPatientDose,...
                     'style'   , 'text',...
                     'string'  , 'Format (yyyyMMddHHmmss.SS)',...
                     'horizontalalignment', 'left',...
                     'BackgroundColor', viewerBackgroundColor('get'), ...
                     'ForegroundColor', viewerForegroundColor('get'), ...                   
                     'position', [20 87 280 20]...
                     );

      edtInjDateTime = ...
          uicontrol(dlgPatientDose,...
                    'style'     , 'edit',...
                    'Background', 'white',...
                    'string'    , injDateTime,...
                    'BackgroundColor', viewerBackgroundColor('get'), ...
                    'ForegroundColor', viewerForegroundColor('get'), ...                 
                    'position'  , [300 90 160 20]...
                    );  

        % Radiopharmaceutical Half Life     

           uicontrol(dlgPatientDose,...
                     'style'   , 'text',...
                     'string'  , 'Radionuclide Half Life',...
                     'horizontalalignment', 'left',...
                     'BackgroundColor', viewerBackgroundColor('get'), ...
                     'ForegroundColor', viewerForegroundColor('get'), ...                   
                     'position', [20 62 280 20]...
                     );

      edtHalfLife = ...
          uicontrol(dlgPatientDose,...
                    'style'     , 'edit',...
                    'Background', 'white',...
                    'string'    , halfLife,...
                    'BackgroundColor', viewerBackgroundColor('get'), ...
                    'ForegroundColor', viewerForegroundColor('get'), ...                 
                    'position'  , [300 65 160 20]...
                    );        

         % Cancel or Proceed

         uicontrol(dlgPatientDose,...
                   'String','Cancel',...
                   'Position',[385 7 75 25],...
                   'BackgroundColor', viewerBackgroundColor('get'), ...
                   'ForegroundColor', viewerForegroundColor('get'), ...                
                   'Callback', @cancelPatientDoseCallback...
                   );

         uicontrol(dlgPatientDose,...
                  'String','Proceed',...
                  'Position',[300 7 75 25],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...               
                  'Callback', @proceedPatientDoseCallback...
                  );        
               
    end
                 
    function cancelPatientDoseCallback(~, ~)
        delete(dlgPatientDose);
    end

    function proceedPatientDoseCallback(~, ~)
        
        atDoseMetaData = dicomMetaData('get');
      
        patWeight   = get(edtPatWeight  , 'String');
        patSize     = get(edtPatSize    , 'String');   
        acqDate     = get(edtAcqDate    , 'String');        
        acqTime     = get(edtAcqTime    , 'String');
        injDose     = get(edtInjDose    , 'String');
        injDateTime = get(edtInjDateTime, 'String');      
        halfLife    = get(edtHalfLife   , 'String');  
        
        for hh=1:numel(atDoseMetaData)
        
            atDoseMetaData{hh}.PatientWeight = patWeight;
            atDoseMetaData{hh}.PatientSize = patSize;   
            atDoseMetaData{hh}.SeriesDate = acqDate;        
            atDoseMetaData{hh}.SeriesTime = acqTime;
            atDoseMetaData{hh}.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideTotalDose = injDose;
            atDoseMetaData{hh}.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartDateTime = injDateTime;      
            atDoseMetaData{hh}.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideHalfLife = halfLife;          
        end
        
        dicomMetaData('set', atDoseMetaData);
        
        setQuantification(get(uiSeriesPtr('get'), 'Value'));
        
         sUnitDisplay = getSerieUnitValue(get(uiSeriesPtr('get'), 'Value'));                        
         if strcmpi(sUnitDisplay, 'SUV')
             tQuant = quantificationTemplate('get');                                
             if tQuant.tSUV.dScale                
                lMin = suvWindowLevel('get', 'min')/tQuant.tSUV.dScale;  
                lMax = suvWindowLevel('get', 'max')/tQuant.tSUV.dScale;                        
                
                windowLevel('set', 'min', lMin); 
                windowLevel('set', 'max', lMax);

                getInitWindowMinMax('set', lMax, lMin);

                sliderWindowLevelValue('set', 'min', 0.5);
                sliderWindowLevelValue('set', 'max', 0.5);  
                
                if switchTo3DMode('get')     == false && ...
                   switchToIsoSurface('get') == false && ...
                   switchToMIPMode('get')    == false

                    if size(dicomBuffer('get'), 3) == 1            
                        set(axePtr('get'), 'CLim', [lMin lMax]);
                    else
                        set(axes1Ptr('get'), 'CLim', [lMin lMax]);
                        set(axes2Ptr('get'), 'CLim', [lMin lMax]);
                        set(axes3Ptr('get'), 'CLim', [lMin lMax]);
                    end
                end                                
             end             
         end                
        
        refreshImages();
        
        delete(dlgPatientDose);                 
    end
    
end