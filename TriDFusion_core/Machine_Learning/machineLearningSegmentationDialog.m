function machineLearningSegmentationDialog(sSegmentatorPath)
%function machineLearningSegmentationDialog(sSegmentatorPath)
%Run machine learning segmentation.
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

    DLG_COLUMN_SIZE = 260;

    DLG_MACHINE_SEGMENTATION_X = 40+5*DLG_COLUMN_SIZE;
    DLG_MACHINE_SEGMENTATION_Y = 660;

    if getMainWindowSize('xsize') < DLG_MACHINE_SEGMENTATION_X
        DLG_MACHINE_SEGMENTATION_X = getMainWindowSize('xsize');
    end

    if getMainWindowSize('ysize') < DLG_MACHINE_SEGMENTATION_Y
        DLG_MACHINE_SEGMENTATION_Y = getMainWindowSize('ysize');
    end


    asSkeletonName = ...
        {'Clavicula Left', ...
         'Clavicula Right', ...
         'Humerus Left', ...
         'Humerus Right', ...
         'Scapula Left', ...
         'Scapula Right', ...
         'Ribs', ...
         'Rib Left [1-12]', ...
         'Rib Right [1-12]', ...
         'Vertebrae', ...
         'Vertebrae C[1-7]', ...
         'Vertebrae T[1-12]', ...
         'Vertebrae L[1-5]', ...
         'Vertebrae Ribs', ...
         'Hip Left', ...
         'Hip Right', ...
         'Sacrum Left', ...
         'Sacrum Right', ...      
         'Femur Left', ...
         'Femur Right' ...                     
         };      
                
    asCardiovascularName = ...
        {'Heart', ...
         'Aorta', ...
         'Pulmonary Artery', ...
         'Ventricle Left', ...
         'Ventricle Right', ...
         'Atrium Left', ...
         'Atrium Right', ...
         'Myocardium', ...
         'Portal & Splenic Vein', ...
         'Inferior Vena Cava', ...
         'Iliac Artery Left', ...
         'Iliac Artery Right', ...
         'Iliac Vena Left', ...
         'Iliac Vena Right' ...
         };
     
     asOtherOrgansName = ...
        {'Brain', ...
         'Face', ...        
         'Trachea', ...        
         'Lungs', ...        
         'Lung Left', ...        
         'Lung Right', ...        
         'Lung Upper Lobe Left', ...        
         'Lung Upper Lobe Right', ...   
         'Lung Middle Lobe Right', ...        
         'Lung Lower Lobe Left', ...        
         'Lung Lower Lobe Right', ...           
         'Adrenal Gland Left', ...        
         'Adrenal Gland Right', ...        
         'Spleen', ...        
         'Liver', ...        
         'Gallbladder', ...        
         'Pancreas', ...        
         'Kidney Left', ...        
         'Kidney Right' ...        
         };
     
     asGastrointestinalTractName = ...
        {'Esophagus', ...
         'Stomach', ...    
         'Duodenum', ...
         'Small Bowel', ...
         'Colon', ...
         'Urinary Bladder' ...
         };
     
     asMusclesName = ...
        {'Autochthon Left', ...
         'Autochthon Right', ...    
         'Iliopsoas Left', ...
         'Iliopsoas Right', ...
         'Gluteus Minimus Left', ...
         'Gluteus Minimus Right', ...
         'Gluteus Medius Left', ...
         'Gluteus Medius Right', ...
         'Gluteus Maximus Left', ...
         'Gluteus Maximus Right' ...         
         };
     
    dlgMachineSegmentation = ...
        dialog('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-DLG_MACHINE_SEGMENTATION_X/2) ...
                            (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-DLG_MACHINE_SEGMENTATION_Y/2) ...
                            DLG_MACHINE_SEGMENTATION_X ...
                            DLG_MACHINE_SEGMENTATION_Y ...
                            ],...
               'MenuBar'    , 'none',...
               'Resize'     , 'on', ...    
               'NumberTitle', 'off',...
               'MenuBar'    , 'none',...
               'Color'      , viewerBackgroundColor('get'), ...
               'Name'       , 'Machine Learning Segmentation',...
               'Toolbar'    , 'none'...               
               );           

        axes(dlgMachineSegmentation, ...
             'Units'   , 'normalized', ...
             'Position', [0 0 1 1], ...
             'Color'   , viewerBackgroundColor('get'),...
             'XColor'  , viewerForegroundColor('get'),...
             'YColor'  , viewerForegroundColor('get'),...
             'ZColor'  , viewerForegroundColor('get'),...             
             'Visible' , 'off'...             
             );

      uiMachineSegmentation = ...
         uipanel(dlgMachineSegmentation,...
                 'Units'   , 'normalized',...
                 'Position', [0 0 1 1], ...
                 'Visible' , 'on', ...
                 'BackgroundColor', viewerBackgroundColor('get'), ...
                 'ForegroundColor', viewerForegroundColor('get') ... 
                 );

    uiMachineSegmentationSlider = ...
        uicontrol('Style'   , 'Slider', ...
                  'Parent'  , dlgMachineSegmentation,...
                  'Units'   , 'normalized',...
                  'position', [0.99 ...
                               0 ...
                               0.01 ...
                               1 ...
                               ],...
                  'Value', 1, ...
                  'Callback',@uiMachineSegmentationSliderCallback, ...
                  'BackgroundColor', 'white', ...
                  'ForegroundColor', 'black' ...
                  );
    addlistener(uiMachineSegmentationSlider, 'Value', 'PreSet', @uiMachineSegmentationSliderCallback);

    % Skeleton
    
    chkMachineSegmentationSkeletonAll = ...
        uicontrol(uiMachineSegmentation,...Radiomics
                  'style'   , 'checkbox',...
                  'Units'   , 'normalized',...
                  'enable'  , 'on',...
                  'value'   , 0,...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [0.01 ...
                               0.95 ...
                               0.02 ...
                               0.02], ...                     
                  'Callback', @chkMachineSegmentationSkeletonAllCallback...
                  );

         uicontrol(uiMachineSegmentation,...
                  'style'     , 'text',...
                  'Units'     , 'normalized',...
                  'enable'    , 'Inactive',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 12,...
                  'FontName'  , 'MS Sans Serif', ...                      
                  'string'    , 'Skeleton',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'position', [0.01+0.013 ...
                               0.925 ...
                               0.2 ...
                               0.05], ...   
                  'ButtonDownFcn', @chkMachineSegmentationSkeletonAllCallback...
                  );
          
    chkMachineSegmentationSkeleton = cell(1, numel(asSkeletonName));     
    edtMachineSegmentationSkeleton = cell(1, numel(asSkeletonName));     
          
    for sk=1:numel(asSkeletonName)
        
        chkMachineSegmentationSkeleton{sk} = ...
            uicontrol(uiMachineSegmentation,...
                      'style'   , 'checkbox',...
                      'Units'   , 'normalized',...
                      'enable'  , 'on',...
                      'value'   , 0,...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...
                      'position', [0.01+0.013 ...
                                   0.935-(sk*0.038)...
                                   0.02 ...
                                   0.02], ...                           
                      'UserData', sk, ...             
                      'Callback', @chkMachineSegmentationSkeletonCallback...
                      );

            uicontrol(uiMachineSegmentation,...
                  'style'     , 'text',...
                  'Units'     , 'normalized',...
                  'enable'    , 'inactive',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...                      
                  'string'    , asSkeletonName{sk},...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                      'position', [0.01+0.013+0.013 ...
                                   0.928-(sk*0.038)...
                                   0.1 ...
                                   0.03], ...    
                  'UserData', sk, ...             
                  'ButtonDownFcn', @chkMachineSegmentationSkeletonCallback...
                  );       

        sEdtString = extractBetween(asSkeletonName{sk},'[',']');
        
        if ~isempty(sEdtString)
            
            if get(chkMachineSegmentationSkeleton{sk}, 'Value') == true
                sEdtSkeletonEnable = 'on';
            else
                sEdtSkeletonEnable = 'off';
            end
            
            edtMachineSegmentationSkeleton{sk} = ...
               uicontrol(uiMachineSegmentation,...
                         'style'     , 'edit',...
                         'Units'     , 'normalized',...
                         'enable'    , sEdtSkeletonEnable,...
                         'Background', 'white',...
                         'string'    , sEdtString,...
                         'BackgroundColor', viewerBackgroundColor('get'), ...
                         'ForegroundColor', viewerForegroundColor('get'), ...                   
                         'position', [0.01+0.013+0.115 ...
                                      0.928-(sk*0.038)...
                                      0.04 ...
                                      0.03], ...                 
                         'UserData', sk, ...             
                         'Callback', @edtMachineSegmentationSkeletonCallback...
                         );              
        end
    end
    
    % Cardiovascular System
    
    chkMachineSegmentationCardiovascularAll = ...
        uicontrol(uiMachineSegmentation,...
                  'style'   , 'checkbox',...
                  'Units'   , 'normalized',...
                  'enable'  , 'on',...
                  'value'   , 0,...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [0.21 ...
                               0.95 ...
                               0.02 ...
                               0.02], ...                     
                  'Callback', @chkMachineSegmentationCardiovascularAllCallback...
                  );

         uicontrol(uiMachineSegmentation,...
                  'style'     , 'text',...
                  'Units'     , 'normalized',...
                  'enable'    , 'Inactive',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 12,...
                  'FontName'  , 'MS Sans Serif', ...                      
                  'string'    , 'Cardiovascular',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'position', [0.21+0.013 ...
                               0.925 ...
                               0.2 ...
                               0.05], ...   
                  'ButtonDownFcn', @chkMachineSegmentationCardiovascularAllCallback...
                  );
          
    chkMachineSegmentationCardiovascular = cell(1, numel(asCardiovascularName));     
          
    for cd=1:numel(asCardiovascularName)
        
        chkMachineSegmentationCardiovascular{cd} = ...
            uicontrol(uiMachineSegmentation,...
                      'style'   , 'checkbox',...
                      'Units'   , 'normalized',...
                      'enable'  , 'on',...
                      'value'   , 0,...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...
                      'position', [0.21+0.013 ...
                                   0.935-(cd*0.038)...
                                   0.02 ...
                                   0.02], ...                          
                      'UserData', cd, ...             
                      'Callback', @chkMachineSegmentationCardiovascularCallback...
                      );

            uicontrol(uiMachineSegmentation,...
                  'style'     , 'text',...
                  'Units'     , 'normalized',...
                  'enable'    , 'inactive',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...                      
                  'string'    , asCardiovascularName{cd},...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'position', [0.21+0.013+0.013 ...
                               0.928-(cd*0.038)...
                               0.1 ...
                               0.03], ...   
                  'UserData', cd, ...             
                  'ButtonDownFcn', @chkMachineSegmentationCardiovascularCallback...
                  );    
    end
    
    % Other Organs
    
    chkMachineSegmentationOtherOrgansAll = ...
        uicontrol(uiMachineSegmentation,...
                  'style'   , 'checkbox',...
                  'Units'   , 'normalized',...
                  'enable'  , 'on',...
                  'value'   , 0,...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [0.405 ...
                               0.95 ...
                               0.02 ...
                               0.02], ...                       
                  'Callback', @chkMachineSegmentationOtherOrgansAllCallback...
                  );

         uicontrol(uiMachineSegmentation,...
                  'style'     , 'text',...
                  'Units'     , 'normalized',...
                  'enable'    , 'Inactive',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 12,...
                  'FontName'  , 'MS Sans Serif', ...                      
                  'string'    , 'Other Organs',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'position', [0.405+0.013 ...
                               0.925 ...
                               0.2 ...
                               0.05], ...   
                  'ButtonDownFcn', @chkMachineSegmentationOtherOrgansAllCallback...
                  );
          
    chkMachineSegmentationOtherOrgans = cell(1, numel(asOtherOrgansName));     
          
    for oo=1:numel(asOtherOrgansName)
        
        chkMachineSegmentationOtherOrgans{oo} = ...
            uicontrol(uiMachineSegmentation,...
                      'style'   , 'checkbox',...
                      'Units'   , 'normalized',...
                      'enable'  , 'on',...
                      'value'   , 0,...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...
                      'position', [0.405+0.013 ...
                                   0.935-(oo*0.038)...
                                   0.02 ...
                                   0.02], ...                              
                      'UserData', oo, ...             
                      'Callback', @chkMachineSegmentationOtherOrgansCallback...
                      );

            uicontrol(uiMachineSegmentation,...
                  'style'     , 'text',...
                  'Units'     , 'normalized',...
                  'enable'    , 'inactive',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...                      
                  'string'    , asOtherOrgansName{oo},...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'position', [0.405+0.013+0.013 ...
                               0.928-(oo*0.038)...
                               0.1 ...
                               0.03], ...   
                  'UserData', oo, ...             
                  'ButtonDownFcn', @chkMachineSegmentationOtherOrgansCallback...
                  );    
    end
    
    % Gastrointestinal Tract
    
    chkMachineSegmentationGastrointestinalTractAll = ...
        uicontrol(uiMachineSegmentation,...
                  'style'   , 'checkbox',...
                  'Units'   , 'normalized',...
                  'enable'  , 'on',...
                  'value'   , 0,...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [0.6 ...
                               0.95 ...
                               0.02 ...
                               0.02], ...                      
                  'Callback', @chkMachineSegmentationGastrointestinalTractAllCallback...
                  );

         uicontrol(uiMachineSegmentation,...
                  'style'     , 'text',...
                  'Units'     , 'normalized',...
                  'enable'    , 'Inactive',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 12,...
                  'FontName'  , 'MS Sans Serif', ...                      
                  'string'    , 'Gastrointestinal Tract',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'position', [0.6+0.013 ...
                               0.925 ...
                               0.2 ...
                               0.05], ... 
                  'ButtonDownFcn', @chkMachineSegmentationGastrointestinalTractAllCallback...
                  );
          
    chkMachineSegmentationGastrointestinalTract = cell(1, numel(asGastrointestinalTractName));     
          
    for gt=1:numel(asGastrointestinalTractName)
        
        chkMachineSegmentationGastrointestinalTract{gt} = ...
            uicontrol(uiMachineSegmentation,...
                      'style'   , 'checkbox',...
                      'Units'   , 'normalized',...
                      'enable'  , 'on',...
                      'value'   , 0,...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...
                      'position', [0.6+0.013 ...
                                   0.935-(gt*0.038)...
                                   0.02 ...
                                   0.02], ...                           
                      'UserData', gt, ...             
                      'Callback', @chkMachineSegmentationGastrointestinalTractCallback...
                      );

            uicontrol(uiMachineSegmentation,...
                  'style'     , 'text',...
                  'Units'     , 'normalized',...
                  'enable'    , 'inactive',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...                      
                  'string'    , asGastrointestinalTractName{gt},...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'position', [0.6+0.013+0.013 ...
                               0.928-(gt*0.038)...
                               0.1 ...
                               0.03], ...   
                  'UserData', gt, ...             
                  'ButtonDownFcn', @chkMachineSegmentationGastrointestinalTractCallback...
                  );    
    end
    
    % Muscles
    
    chkMachineSegmentationMusclesAll = ...
        uicontrol(uiMachineSegmentation,...
                  'style'   , 'checkbox',...
                  'Units'   , 'normalized',...
                  'enable'  , 'on',...
                  'value'   , 0,...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [0.795 ...
                               0.95 ...
                               0.02 ...
                               0.02], ...                      
                  'Callback', @chkMachineSegmentationMusclesAllCallback...
                  );

         uicontrol(uiMachineSegmentation,...
                  'style'     , 'text',...
                  'Units'     , 'normalized',...
                  'enable'    , 'Inactive',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 12,...
                  'FontName'  , 'MS Sans Serif', ...                      
                  'string'    , 'Muscles',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'position', [0.795+0.013 ...
                               0.925 ...
                               0.2 ...
                               0.05], ... 
                  'ButtonDownFcn', @chkMachineSegmentationMusclesAllCallback...
                  );
     
     chkMachineSegmentationMuscles = cell(1,numel(asMusclesName));     
     
     for mu=1:numel(asMusclesName)
         
        chkMachineSegmentationMuscles{mu} = ...
            uicontrol(uiMachineSegmentation,...
                      'style'   , 'checkbox',...
                      'Units'   , 'normalized',...
                      'enable'  , 'on',...
                      'value'   , 0,...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...
                      'position', [0.795+0.013 ...
                                   0.935-(mu*0.038)...
                                   0.02 ...
                                   0.02], ...                           
                      'UserData', mu, ...             
                      'Callback', @chkMachineSegmentationMusclesCallback...
                      );

            uicontrol(uiMachineSegmentation,...
                  'style'     , 'text',...
                  'Units'     , 'normalized',...
                  'enable'    , 'inactive',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...                      
                  'string'    , asMusclesName{mu},...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'position', [0.795+0.013+0.013 ...
                               0.928-(mu*0.038)...
                               0.11 ...
                               0.03], ...   
                  'UserData', mu, ...             
                  'ButtonDownFcn', @chkMachineSegmentationMusclesCallback...
                  );    
     end
     
         uicontrol(uiMachineSegmentation,...
                  'style'     , 'text',...
                  'Units'     , 'normalized',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...                      
                  'string'    , 'Preset protocol',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'position', [0.640 ...
                               0.300 ...
                               0.1 ...
                               0.03], ...
                  'ButtonDownFcn', @chkMachineSegmentationMusclesAllCallback...
                  );
                  
    popMachineSegmentationProtocol = ...
        uicontrol(uiMachineSegmentation, ...
                  'enable'  , 'on',...
                  'Units'   , 'normalized',...
                  'Style'   , 'popup', ...
                  'position', [0.785 ...
                               0.300 ...
                               0.202 ...
                               0.03], ...
                  'String'  , getMchineLearningProtocolName(), ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                    
                  'Value'   , 1 ...
                  );
              
        uicontrol(uiMachineSegmentation,...
                  'style'   , 'pushbutton',...
                  'Units'   , 'normalized',...
                  'String'  , 'Load',...
                  'position', [0.640 ...
                               0.240 ...
                               0.08 ...
                               0.04], ...
                  'Enable'  , 'on', ...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @loadMachineSegmentationProtocolCallback...
                  );
              
        uicontrol(uiMachineSegmentation,...
                  'style'   , 'pushbutton',...
                  'Units'   , 'normalized',...
                  'String'  , 'Save',...
                  'position', [0.822 ...
                               0.240 ...
                               0.08 ...
                               0.04], ...
                  'Enable'  , 'on', ...
                  'BackgroundColor', [0.5300 0.6300 0.4000], ...
                  'ForegroundColor', [0.1 0.1 0.1], ...
                  'Callback', @saveMachineSegmentationProtocolCallback...
                  ); 
              
        uicontrol(uiMachineSegmentation, ...
                  'style'   , 'pushbutton',...
                  'Units'   , 'normalized',...
                  'String'  , 'Delete',...
                  'position', [0.907 ...
                               0.240 ...
                               0.08 ...
                               0.04], ...
                  'Enable'  , 'on', ...
                  'BackgroundColor', [0.2 0.039 0.027], ...
                  'ForegroundColor', [0.94 0.94 0.94], ...
                  'Callback', @deleteMachineSegmentationProtocolCallback...
                  );

         uicontrol(uiMachineSegmentation,...
                  'style'     , 'text',...
                  'Units'     , 'normalized',...
                  'FontWeight', 'bold',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...                      
                  'string'    , 'Options',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'position', [0.640 ...
                               0.180 ...
                               0.1 ...
                               0.03], ...
                  'ButtonDownFcn', @chkMachineSegmentationMusclesAllCallback...
                  );
    % Options

    chkMachineSegmentationFast = ...
        uicontrol(uiMachineSegmentation,...
                  'style'   , 'checkbox',...
                  'Units'   , 'normalized',...
                  'enable'  , 'on',...
                  'value'   , fastMachineLearningDialog('get'),...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [0.640 ...
                               0.145 ...
                               0.02 ...
                               0.02], ...                   
                  'Callback', @chkMachineSegmentationFastCallback...
                  );

         uicontrol(uiMachineSegmentation,...
                  'style'     , 'text',...
                  'Units'     , 'normalized',...
                  'enable'    , 'Inactive',...
                  'FontWeight', 'normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...                      
                  'string'    , 'Fast Segmentation',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'position', [0.640+0.013 ...
                               0.145-.008 ...
                               0.1 ...
                               0.03], ... 
                  'ButtonDownFcn', @chkMachineSegmentationFastCallback...
                  );

    chkMachineSegmentationForceSplit = ...
        uicontrol(uiMachineSegmentation,...
                  'style'   , 'checkbox',...
                  'Units'   , 'normalized',...
                  'enable'  , 'on',...
                  'value'   , forceSplitMachineLearningDialog('get'),...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [0.640 ...
                               0.145-0.038 ...
                               0.02 ...
                               0.02], ...                   
                  'Callback', @chkMachineSegmentationForceSplitCallback...
                  );

         uicontrol(uiMachineSegmentation,...
                  'style'     , 'text',...
                  'Units'     , 'normalized',...
                  'enable'    , 'Inactive',...
                  'FontWeight', 'normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...                      
                  'string'    , 'Split in part',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'position', [0.640+0.013 ...
                               0.145-0.038-0.008 ...
                               0.1 ...
                               0.03], ...    
                  'ButtonDownFcn', @chkMachineSegmentationForceSplitCallback...
                  );

    chkMachineSegmentationBodySeg = ...
        uicontrol(uiMachineSegmentation,...
                  'style'   , 'checkbox',...
                  'Units'   , 'normalized',...
                  'enable'  , 'on',...
                  'value'   , bodySegMachineLearningDialog('get'),...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [0.640 ...
                               0.145-0.076 ...
                               0.02 ...
                               0.02], ...                   
                  'Callback', @chkMachineSegmentationBodySegCallback...
                  );

         uicontrol(uiMachineSegmentation,...
                  'style'     , 'text',...
                  'Units'     , 'normalized',...
                  'enable'    , 'Inactive',...
                  'FontWeight', 'normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...                      
                  'string'    , 'Pre-processing crop',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'position', [0.640+0.013 ...
                               0.145-0.076-0.008 ...
                               0.1 ...
                               0.03], ...    
                  'ButtonDownFcn', @chkMachineSegmentationBodySegCallback...
                  );


    chkMachineSegmentationPixelEdge = ...
        uicontrol(uiMachineSegmentation,...
                  'style'   , 'checkbox',...
                  'Units'   , 'normalized',...
                  'enable'  , 'on',...
                  'value'   , pixelEdge('get'),...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position', [0.640 ...
                               0.145-0.114 ...
                               0.02 ...
                               0.02], ...                   
                  'Callback', @chkMachineSegmentationPixelEdgeCallback...
                  );

         uicontrol(uiMachineSegmentation,...
                  'style'     , 'text',...
                  'Units'     , 'normalized',...
                  'enable'    , 'Inactive',...
                  'FontWeight', 'normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...                      
                  'string'    , 'Pixel Edge',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...                   
                  'position', [0.640+0.013 ...
                               0.145-0.114-0.008 ...
                               0.1 ...
                               0.03], ...    
                  'ButtonDownFcn', @chkMachineSegmentationPixelEdgeCallback...
                  );

     % Cancel or Proceed

     uicontrol(uiMachineSegmentation,...
               'String'  , 'Cancel',...
               'Units'   , 'normalized',...
               'position', [0.907 ...
                            0.01 ...
                            0.08 ...
                            0.04], ...
               'BackgroundColor', viewerBackgroundColor('get'), ...
               'ForegroundColor', viewerForegroundColor('get'), ...                
               'Callback', @cancelMachineSegmentationCallback...
               );

     uicontrol(uiMachineSegmentation,...
              'String'    , 'Segment',...
              'Units'     , 'normalized',...
              'FontWeight', 'bold',...
              'position', [0.822 ...
                           0.01 ...
                           0.08 ...
                           0.04], ...
              'BackgroundColor', [0.6300 0.6300 0.4000], ...
              'ForegroundColor', [0.1 0.1 0.1], ...               
              'Callback', @proceedMachineSegmentationCallback...
              );  
        
         uicontrol(uiMachineSegmentation,...
                  'style'     , 'text',...
                  'enable'    , 'Inactive',...
                  'FontWeight', 'normal',...
                  'FontSize'  , 10,...
                  'FontName'  , 'MS Sans Serif', ...                      
                  'string'    , 'Module documentation: https://github.com/wasserth/TotalSegmentator',...
                  'horizontalalignment', 'left',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', 'white', ...                   
                  'position', [10 ...
                               10 ...
                               800 ...
                               20], ...
                  'ButtonDownFcn', @visitTotalSegmentator...
                  );
         
    function visitTotalSegmentator(~, ~)
        web('https://github.com/wasserth/TotalSegmentator');
    end

    % Options
        
    function chkMachineSegmentationFastCallback(hObject, ~)      
               
        bObjectValue = get(chkMachineSegmentationFast, 'Value');
        
        if strcmpi(get(hObject, 'Style'), 'text')
            
            set(chkMachineSegmentationFast, 'Value', ~bObjectValue);
        end
        

        fastMachineLearningDialog('set', get(chkMachineSegmentationFast, 'Value'));
        
    end

    function chkMachineSegmentationForceSplitCallback(hObject, ~)      
               
        bObjectValue = get(chkMachineSegmentationForceSplit, 'Value');
        
        if strcmpi(get(hObject, 'Style'), 'text')
            
            set(chkMachineSegmentationForceSplit, 'Value', ~bObjectValue);
        end
        

        forceSplitMachineLearningDialog('set', get(chkMachineSegmentationForceSplit, 'Value'));

    end

    function chkMachineSegmentationBodySegCallback(hObject, ~)      
               
        bObjectValue = get(chkMachineSegmentationBodySeg, 'Value');
        
        if strcmpi(get(hObject, 'Style'), 'text')
            
            set(chkMachineSegmentationBodySeg, 'Value', ~bObjectValue);
        end
        

        bodySegMachineLearningDialog('set', get(chkMachineSegmentationBodySeg, 'Value'));
    end

    function chkMachineSegmentationPixelEdgeCallback(hObject, ~)      
               
        bObjectValue = get(chkMachineSegmentationPixelEdge, 'Value');
        
        if strcmpi(get(hObject, 'Style'), 'text')
            
            set(chkMachineSegmentationPixelEdge, 'Value', ~bObjectValue);
        end
        
        pixelEdge('set', get(chkMachineSegmentationPixelEdge, 'Value'));

        % Set contour panel checkbox
        set(chkPixelEdgePtr('get'), 'Value', pixelEdge('get'));

    end

    % Skeleton
          
    function chkMachineSegmentationSkeletonAllCallback(hObject, ~)  
                
        bObjectValue = get(chkMachineSegmentationSkeletonAll, 'Value');
        
        if strcmpi(get(hObject, 'Style'), 'text')
            
            set(chkMachineSegmentationSkeletonAll, 'Value', ~bObjectValue);
        end        
        
        bObjectValue = get(chkMachineSegmentationSkeletonAll, 'Value');
        
        for aa=1:numel(chkMachineSegmentationSkeleton) 
            
            set(chkMachineSegmentationSkeleton{aa}, 'Value', bObjectValue);
            
            if ~isempty(edtMachineSegmentationSkeleton{aa}) % Set Edit Box on\off
                
                if get(chkMachineSegmentationSkeleton{aa}, 'Value') == true

                    set(edtMachineSegmentationSkeleton{aa}, 'enable', 'on');
                else
                    set(edtMachineSegmentationSkeleton{aa}, 'enable', 'off');
                end                
            end
        end
    end

    function chkMachineSegmentationSkeletonCallback(hObject, ~)      
       
        dObjectOffset = get(hObject, 'UserData');
        
        bObjectValue = get(chkMachineSegmentationSkeleton{dObjectOffset}, 'Value');
        
        if strcmpi(get(hObject, 'Style'), 'text')
            
            set(chkMachineSegmentationSkeleton{dObjectOffset}, 'Value', ~bObjectValue);
        end
        
        bObjectValue = get(chkMachineSegmentationSkeleton{dObjectOffset}, 'Value');
        
        if ~isempty(edtMachineSegmentationSkeleton{dObjectOffset}) % Set Edit Box on\off
            
            if bObjectValue == true
                
                set(edtMachineSegmentationSkeleton{dObjectOffset}, 'enable', 'on');
            else
                set(edtMachineSegmentationSkeleton{dObjectOffset}, 'enable', 'off');
            end
        end
        
        % Verify if at least 1 object is active
        
        adOffset = find(cellfun( @(chkMachineSegmentationSkeleton) chkMachineSegmentationSkeleton.Value, chkMachineSegmentationSkeleton, 'uni', true ), true);
        
        if isempty(adOffset)
            set(chkMachineSegmentationSkeletonAll, 'Value', false);
        else
            set(chkMachineSegmentationSkeletonAll, 'Value', true);
        end
        
    end

    function edtMachineSegmentationSkeletonCallback(hObject, ~) 
        
        dObjectOffset = get(hObject, 'UserData');
        
        % Extract asSkeletonName permited from to
        
        csEdtString = extractBetween(asSkeletonName{dObjectOffset},'[',']');
        
        dSkeletonObjectFrom = str2double(extractBefore(csEdtString,'-'));
        dSkeletonObjectTo   = str2double(extractAfter (csEdtString,'-'));
        
        csEditValue   = get(hObject, 'String');
        
        dCurrentObjectFrom = str2double(extractBefore(csEditValue,'-'));
        dCurrentObjectTo   = str2double(extractAfter (csEditValue,'-'));        
        
        if isnan(dCurrentObjectFrom) && ... % Didn't find - 
           isnan(dCurrentObjectTo)
       
            dCurrentObjectValue = str2double(csEditValue);      
            if dCurrentObjectValue > dSkeletonObjectTo
                dCurrentObjectValue = dSkeletonObjectTo;
            end
            
            if dCurrentObjectValue < dSkeletonObjectFrom
                dCurrentObjectValue = dSkeletonObjectFrom;
            end
            
            if isnan(dCurrentObjectValue) 
                sNewValue = sprintf('%d-%d', dSkeletonObjectFrom, dSkeletonObjectTo);
           else
                sNewValue = sprintf('%d-%d', dCurrentObjectValue, dCurrentObjectValue);
            end            
            
            set(edtMachineSegmentationSkeleton{dObjectOffset}, 'String', sNewValue);
        else
            
            % Set from limit
            
            if isnan(dCurrentObjectFrom) 
                dCurrentObjectFrom = dSkeletonObjectFrom;
            end
            
            if dCurrentObjectFrom > dCurrentObjectTo
                dCurrentObjectFrom = dCurrentObjectTo;
            end
                
            if dCurrentObjectFrom < dSkeletonObjectFrom 
                dCurrentObjectFrom = dSkeletonObjectFrom;
            end
            
            if dCurrentObjectFrom > dSkeletonObjectTo
                dCurrentObjectFrom = dSkeletonObjectTo;
            end
                        
            % Set to limit
            
            if isnan(dCurrentObjectTo) 
                dCurrentObjectTo = dSkeletonObjectTo;
            end
            
            if dCurrentObjectTo < dCurrentObjectFrom
                dCurrentObjectTo = dCurrentObjectFrom;
            end
            
            if dCurrentObjectTo > dSkeletonObjectTo 
                dCurrentObjectTo = dSkeletonObjectTo;
            end
            
            if dCurrentObjectTo < dSkeletonObjectFrom
                dCurrentObjectTo = dSkeletonObjectFrom;
            end
            
            sNewValue = sprintf('%d-%d', dCurrentObjectFrom, dCurrentObjectTo);
            set(edtMachineSegmentationSkeleton{dObjectOffset}, 'String', sNewValue);
           
        end

    end

    % Cardiovascular System

    function chkMachineSegmentationCardiovascularAllCallback(hObject, ~)      
               
        bObjectValue = get(chkMachineSegmentationCardiovascularAll, 'Value');
        
        if strcmpi(get(hObject, 'Style'), 'text')
            
            set(chkMachineSegmentationCardiovascularAll, 'Value', ~bObjectValue);
        end
        
        bObjectValue = get(chkMachineSegmentationCardiovascularAll, 'Value');
        
        for aa=1:numel(chkMachineSegmentationCardiovascular)
            
            set(chkMachineSegmentationCardiovascular{aa}, 'Value', bObjectValue);
        end
    end

    function chkMachineSegmentationCardiovascularCallback(hObject, ~)      
       
        dObjectOffset = get(hObject, 'UserData');
        
        bObjectValue = get(chkMachineSegmentationCardiovascular{dObjectOffset}, 'Value');
        
        if strcmpi(get(hObject, 'Style'), 'text')
            
            set(chkMachineSegmentationCardiovascular{dObjectOffset}, 'Value', ~bObjectValue);
        end
        
        % Verify if at least 1 object is active
        
        adOffset = find(cellfun( @(chkMachineSegmentationCardiovascular) chkMachineSegmentationCardiovascular.Value, chkMachineSegmentationCardiovascular, 'uni', true ), true);
        
        if isempty(adOffset)
            set(chkMachineSegmentationCardiovascularAll, 'Value', false);
        else
            set(chkMachineSegmentationCardiovascularAll, 'Value', true);
        end        
    end

    % Other Organs

    function chkMachineSegmentationOtherOrgansAllCallback(hObject, ~)      
               
        bObjectValue = get(chkMachineSegmentationOtherOrgansAll, 'Value');
        
        if strcmpi(get(hObject, 'Style'), 'text')
            
            set(chkMachineSegmentationOtherOrgansAll, 'Value', ~bObjectValue);
        end
        
        bObjectValue = get(chkMachineSegmentationOtherOrgansAll, 'Value');
        
        for aa=1:numel(chkMachineSegmentationOtherOrgans)
            
            set(chkMachineSegmentationOtherOrgans{aa}, 'Value', bObjectValue);
        end
    end

    function chkMachineSegmentationOtherOrgansCallback(hObject, ~)      
       
        dObjectOffset = get(hObject, 'UserData');
        
        bObjectValue = get(chkMachineSegmentationOtherOrgans{dObjectOffset}, 'Value');
        
        if strcmpi(get(hObject, 'Style'), 'text')
            
            set(chkMachineSegmentationOtherOrgans{dObjectOffset}, 'Value', ~bObjectValue);
        end
        
        % Verify if at least 1 object is active
        
        adOffset = find(cellfun( @(chkMachineSegmentationOtherOrgans) chkMachineSegmentationOtherOrgans.Value, chkMachineSegmentationOtherOrgans, 'uni', true ), true);
        
        if isempty(adOffset)
            set(chkMachineSegmentationOtherOrgansAll, 'Value', false);
        else
            set(chkMachineSegmentationOtherOrgansAll, 'Value', true);
        end         
    end

    % Gastrointestinal Tract
    
    function chkMachineSegmentationGastrointestinalTractAllCallback(hObject, ~)      
               
        bObjectValue = get(chkMachineSegmentationGastrointestinalTractAll, 'Value');
        
        if strcmpi(get(hObject, 'Style'), 'text')
            
            set(chkMachineSegmentationGastrointestinalTractAll, 'Value', ~bObjectValue);
        end
        
        bObjectValue = get(chkMachineSegmentationGastrointestinalTractAll, 'Value');
        
        for aa=1:numel(chkMachineSegmentationGastrointestinalTract)
            
            set(chkMachineSegmentationGastrointestinalTract{aa}, 'Value', bObjectValue);
        end
    end

    function chkMachineSegmentationGastrointestinalTractCallback(hObject, ~)      
       
        dObjectOffset = get(hObject, 'UserData');
        
        bObjectValue = get(chkMachineSegmentationGastrointestinalTract{dObjectOffset}, 'Value');
        
        if strcmpi(get(hObject, 'Style'), 'text')
            
            set(chkMachineSegmentationGastrointestinalTract{dObjectOffset}, 'Value', ~bObjectValue);
        end
        
        % Verify if at least 1 object is active
        
        adOffset = find(cellfun( @(chkMachineSegmentationGastrointestinalTract) chkMachineSegmentationGastrointestinalTract.Value, chkMachineSegmentationGastrointestinalTract, 'uni', true ), true);
        
        if isempty(adOffset)
            set(chkMachineSegmentationGastrointestinalTractAll, 'Value', false);
        else
            set(chkMachineSegmentationGastrointestinalTractAll, 'Value', true);
        end         
    end

    % Muscles
    
    function chkMachineSegmentationMusclesAllCallback(hObject, ~)      
               
        bObjectValue = get(chkMachineSegmentationMusclesAll, 'Value');
        
        if strcmpi(get(hObject, 'Style'), 'text')
            
            set(chkMachineSegmentationMusclesAll, 'Value', ~bObjectValue);
        end
        
        bObjectValue = get(chkMachineSegmentationMusclesAll, 'Value');
        
        for aa=1:numel(chkMachineSegmentationMuscles)
            
            set(chkMachineSegmentationMuscles{aa}, 'Value', bObjectValue);
        end
    end

    function chkMachineSegmentationMusclesCallback(hObject, ~)      
       
        dObjectOffset = get(hObject, 'UserData');
        
        bObjectValue = get(chkMachineSegmentationMuscles{dObjectOffset}, 'Value');
        
        if strcmpi(get(hObject, 'Style'), 'text')
            
            set(chkMachineSegmentationMuscles{dObjectOffset}, 'Value', ~bObjectValue);
        end
        
        % Verify if at least 1 object is active
        
        adOffset = find(cellfun( @(chkMachineSegmentationMuscles) chkMachineSegmentationMuscles.Value, chkMachineSegmentationMuscles, 'uni', true ), true);
        
        if isempty(adOffset)
            set(chkMachineSegmentationMusclesAll, 'Value', false);
        else
            set(chkMachineSegmentationMusclesAll, 'Value', true);
        end           
    end          

    % Delete

    function deleteMachineSegmentationProtocolCallback(~, ~)
        
        sRootPath = viewerRootPath('get');
        sProtocolPath = sprintf('%s/protocol/', sRootPath);

        f = java.io.File(char(sProtocolPath));
        asListing = f.listFiles();

        sXmlProtocolFileName = '';

        for kk=1:numel(asListing) % If file exist
            if contains(char(asListing(kk)), 'machineLearning.xml')
                sXmlProtocolFileName = char(asListing(kk));
                break;
            end
        end

        asProtocolList  = get(popMachineSegmentationProtocol, 'String');
        dProtocolOffset = get(popMachineSegmentationProtocol, 'Value');
                
        sProtocolName = strtrim(asProtocolList{dProtocolOffset});
        
        if ~isempty(sXmlProtocolFileName) && ...  % Protocol file exist 
           ~isempty(sProtocolName)
       
            st = xml2struct(sXmlProtocolFileName);
            if isfield (st.machineLearning, 'protocol')       
                                
                dNbProtocol = numel(st.machineLearning.protocol);
                if dNbProtocol > 1
                    for pp=1:dNbProtocol
                        if strcmpi(st.machineLearning.protocol{1,pp}.protocolName.Text, sProtocolName)
                            st.machineLearning.protocol{1,pp}=[];
                            st.machineLearning.protocol(cellfun(@isempty, st.machineLearning.protocol)) = [];
                            break;
                        end
                    end
                else
                    if strcmpi(st.machineLearning.protocol.protocolName.Text, sProtocolName)
                        st.machineLearning.protocol=[];
                        st.machineLearning = rmfield(st.machineLearning, 'protocol');                        
                    end                    
                end        
            end
            
            struct2xml(st, sXmlProtocolFileName);
            
            set(popMachineSegmentationProtocol, 'Value', 1);            
            set(popMachineSegmentationProtocol, 'String', getMchineLearningProtocolName());            
        end
            
    end

    % Load

    function loadMachineSegmentationProtocolCallback(~, ~)  

        % Refer saveMachineSegmentationProtocol() for the saved element list
     
        sRootPath = viewerRootPath('get');
        sProtocolPath = sprintf('%s/protocol/', sRootPath);

        f = java.io.File(char(sProtocolPath));
        asListing = f.listFiles();

        sXmlProtocolFileName = '';

        for kk=1:numel(asListing) % If file exist
            if contains(char(asListing(kk)), 'machineLearning.xml')
                sXmlProtocolFileName = char(asListing(kk));
                break;
            end
        end

        asProtocolList  = get(popMachineSegmentationProtocol, 'String');
        dProtocolOffset = get(popMachineSegmentationProtocol, 'Value');
                
        sProtocolName = asProtocolList{dProtocolOffset};
        
        if ~isempty(sXmlProtocolFileName)  % Protocol file exist 
                   
            st = xml2struct(sXmlProtocolFileName);
            if isfield (st.machineLearning, 'protocol')       
                
                stMachineLearning = [];
                
                dNbProtocol = numel(st.machineLearning.protocol);
                if dNbProtocol > 1
                    for pp=1:dNbProtocol
                        if strcmpi(st.machineLearning.protocol{1,pp}.protocolName.Text, sProtocolName)
                            stMachineLearning = st.machineLearning.protocol{1,pp};                                                        
                        end
                    end
                else
                    if strcmpi(st.machineLearning.protocol.protocolName.Text, sProtocolName)
                        stMachineLearning = st.machineLearning.protocol;                          
                    end                    
                end                
                
                if ~isempty(stMachineLearning)
                    
                    % Skelton 
                    
                    for aa=1:numel(stMachineLearning.skelton.field)
                        
                        dOffset = find(strcmpi(asSkeletonName, stMachineLearning.skelton.field{1, aa}.fieldName.Text), 1);
                        
                        if ~isempty(dOffset)
                            
                            set(chkMachineSegmentationSkeleton{dOffset}, 'Value', str2double(stMachineLearning.skelton.field{1, aa}.fieldValue.Text));  
                            
                            if ~isempty(edtMachineSegmentationSkeleton{aa}) % Set Edit Box 
                                
                                if isfield( stMachineLearning.skelton.field{1,aa}, 'field')
                                    
                                    set(edtMachineSegmentationSkeleton{dOffset}, 'String', stMachineLearning.skelton.field{1,aa}.field.fieldValue.Text)  
                                    
                                    if get(chkMachineSegmentationSkeleton{aa}, 'Value') == true
                                        set(edtMachineSegmentationSkeleton{dOffset}, 'Enable', 'on');
                                    else
                                        set(edtMachineSegmentationSkeleton{dOffset}, 'Enable', 'off');
                                    end                                    
                                end
                            end                            
                        end
                    end   
                    
                    % Verify if at least 1 object is active

                    adOffset = find(cellfun( @(chkMachineSegmentationSkeleton) chkMachineSegmentationSkeleton.Value, chkMachineSegmentationSkeleton, 'uni', true ), true);

                    if isempty(adOffset)
                        set(chkMachineSegmentationSkeletonAll, 'Value', false);
                    else
                        set(chkMachineSegmentationSkeletonAll, 'Value', true);
                    end
                    
                    % Cardiovascular System
                    
                    for bb=1:numel(stMachineLearning.cardiovascular.field)
                        
                        dOffset = find(strcmpi(asCardiovascularName, stMachineLearning.cardiovascular.field{1, bb}.fieldName.Text), 1);
                        
                        if ~isempty(dOffset)                            
                            set(chkMachineSegmentationCardiovascular{dOffset}, 'Value', str2double(stMachineLearning.cardiovascular.field{1, bb}.fieldValue.Text));                                                        
                        end
                    end   
                    
                    % Verify if at least 1 object is active

                    adOffset = find(cellfun( @(chkMachineSegmentationCardiovascular) chkMachineSegmentationCardiovascular.Value, chkMachineSegmentationCardiovascular, 'uni', true ), true);

                    if isempty(adOffset)
                        set(chkMachineSegmentationCardiovascularAll, 'Value', false);
                    else
                        set(chkMachineSegmentationCardiovascularAll, 'Value', true);
                    end
                    
                    % Other Organs
                    
                    for cc=1:numel(stMachineLearning.otherOrgans.field)
                        
                        dOffset = find(strcmpi(asOtherOrgansName, stMachineLearning.otherOrgans.field{1, cc}.fieldName.Text), 1);
                        
                        if ~isempty(dOffset)                            
                            set(chkMachineSegmentationOtherOrgans{dOffset}, 'Value', str2double(stMachineLearning.otherOrgans.field{1, cc}.fieldValue.Text));                                                         
                        end
                    end   
                    
                    % Verify if at least 1 object is active

                    adOffset = find(cellfun( @(chkMachineSegmentationOtherOrgans) chkMachineSegmentationOtherOrgans.Value, chkMachineSegmentationOtherOrgans, 'uni', true ), true);

                    if isempty(adOffset)
                        set(chkMachineSegmentationOtherOrgansAll, 'Value', false);
                    else
                        set(chkMachineSegmentationOtherOrgansAll, 'Value', true);
                    end
                    
                    % Gastrointestinal Tract
            
                    for dd=1:numel(stMachineLearning.gastrointestinal.field)
                        
                        dOffset = find(strcmpi(asGastrointestinalTractName, stMachineLearning.gastrointestinal.field{1, dd}.fieldName.Text), 1);
                        
                        if ~isempty(dOffset)                            
                            set(chkMachineSegmentationGastrointestinalTract{dOffset}, 'Value', str2double(stMachineLearning.gastrointestinal.field{1, dd}.fieldValue.Text));                                                         
                        end
                    end   
                    
                    % Verify if at least 1 object is active

                    adOffset = find(cellfun( @(chkMachineSegmentationGastrointestinalTract) chkMachineSegmentationGastrointestinalTract.Value, chkMachineSegmentationGastrointestinalTract, 'uni', true ), true);

                    if isempty(adOffset)
                        set(chkMachineSegmentationGastrointestinalTractAll, 'Value', false);
                    else
                        set(chkMachineSegmentationGastrointestinalTractAll, 'Value', true);
                    end
                    
                    % Muscles
            
                    for ee=1:numel(stMachineLearning.muscles.field)
                        
                        dOffset = find(strcmpi(asMusclesName, stMachineLearning.muscles.field{1, ee}.fieldName.Text), 1);
                        
                        if ~isempty(dOffset)                            
                            set(chkMachineSegmentationMuscles{dOffset}, 'Value', str2double(stMachineLearning.muscles.field{1, ee}.fieldValue.Text));                                                         
                        end
                    end   
                    
                    % Verify if at least 1 object is active

                    adOffset = find(cellfun( @(chkMachineSegmentationMuscles) chkMachineSegmentationMuscles.Value, chkMachineSegmentationMuscles, 'uni', true ), true);

                    if isempty(adOffset)
                        set(chkMachineSegmentationMusclesAll, 'Value', false);
                    else
                        set(chkMachineSegmentationMusclesAll, 'Value', true);
                    end
                end
            end                      
        end                            
    end

    % Save

    function saveMachineSegmentationProtocolCallback(~, ~)
        
        
        DLG_PROTOCOL_NAME_X = 380;
        DLG_PROTOCOL_NAME_Y = 100;

        dlgProtocolName = ...
            dialog('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-DLG_PROTOCOL_NAME_X/2) ...
                                (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-DLG_PROTOCOL_NAME_Y/2) ...
                                DLG_PROTOCOL_NAME_X ...
                                DLG_PROTOCOL_NAME_Y ...
                                ],...
                   'MenuBar', 'none',...
                   'Resize', 'off', ...    
                   'NumberTitle','off',...
                   'MenuBar', 'none',...
                   'Color', viewerBackgroundColor('get'), ...
                   'Name', 'Protocol Name',...
                   'Toolbar','none'...               
                   );           

            axes(dlgProtocolName, ...
                 'Units'   , 'pixels', ...
                 'Position', [0 0 DLG_PROTOCOL_NAME_X DLG_PROTOCOL_NAME_Y], ...
                 'Color'   , viewerBackgroundColor('get'),...
                 'XColor'  , viewerForegroundColor('get'),...
                 'YColor'  , viewerForegroundColor('get'),...
                 'ZColor'  , viewerForegroundColor('get'),...             
                 'Visible' , 'off'...             
                 );
             
            uicontrol(dlgProtocolName,...
                      'style'   , 'text',...
                      'string'  , 'Protocol Name',...
                      'horizontalalignment', 'left',...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...                   
                      'position', [20 55 150 20]...
                      );
                  
        edtProtocolName = ...
            uicontrol(dlgProtocolName,...
                      'style'   , 'edit',...
                      'string'  , ' ',...
                      'horizontalalignment', 'left',...
                      'BackgroundColor', viewerBackgroundColor('get'), ...
                      'ForegroundColor', viewerForegroundColor('get'), ...                   
                      'position', [170 55 190 20]...
                      );
                  
         % Cancel or Proceed

         uicontrol(dlgProtocolName,...
                   'String','Cancel',...
                   'Position',[285 7 75 25],...
                   'BackgroundColor', viewerBackgroundColor('get'), ...
                   'ForegroundColor', viewerForegroundColor('get'), ...                
                   'Callback', @cancelSaveMachineSegmentationProtocol...
                   );

         uicontrol(dlgProtocolName,...
                  'String','Save',...
                  'Position',[200 7 75 25],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...               
                  'Callback', @saveMachineSegmentationProtocol...
                  );
              
        function cancelSaveMachineSegmentationProtocol(~, ~)
            
            delete(dlgProtocolName);
        end        
        
        function saveMachineSegmentationProtocol(~, ~)   
            
            asProtocolList = strtrim(get(popMachineSegmentationProtocol, 'String'));
        
            for nn=1:numel(asProtocolList)
                if strcmpi(asProtocolList{nn}, strtrim(get(edtProtocolName, 'String')))
                    
                    progressBar('Error: Protocol name invalid or exist, please use a valid name!');
                    errordlg('Protocol name invalid or exist, please use a valid name!', 'Protocol Name Validation');  
                    return;
                end
            end
                        
            st.machineLearning.guiName.Text = 'Machine Learning';
            st.machineLearning.defaultProtocol.Text = '1'; 
            st.machineLearning.Attributes.version = '1.0';
            
            sRootPath = viewerRootPath('get');
            sProtocolPath = sprintf('%s/protocol/', sRootPath);
            
            f = java.io.File(char(sProtocolPath));
            asListing = f.listFiles();

            sXmlProtocolFileName = '';
            
            for kk=1:numel(asListing) % If file exist
                if contains(char(asListing(kk)), 'machineLearning.xml')
                    sXmlProtocolFileName = char(asListing(kk));
                    break;
                end
            end
            
            if isempty(sXmlProtocolFileName)                
                dNbProtocol = 0;        
                sXmlProtocolFileName = sprintf('%s/protocol/machineLearning.xml', sRootPath);
            else    
                stOld = xml2struct(sXmlProtocolFileName);

                if isfield (stOld.machineLearning, 'protocol')                                
                    
                    dNbProtocol = numel(stOld.machineLearning.protocol);
                    
                    st.machineLearning.protocol = cell(1, dNbProtocol+1);
                    
                    if dNbProtocol > 1
                        for pp=1:dNbProtocol
                            st.machineLearning.protocol{1,pp} = stOld.machineLearning.protocol{1,pp};
                        end
                    else
                        st.machineLearning.protocol{1,1} = stOld.machineLearning.protocol;            
                    end                
                else
                    dNbProtocol = 0;
                end
            end
            
            dProtocolOffset = dNbProtocol+1;

            st.machineLearning.protocol{1,dProtocolOffset}.protocolName.Text = strtrim(get(edtProtocolName, 'String'));
            
            delete(dlgProtocolName);

            % Skeleton

            for aa=1:numel(asSkeletonName)
                st.machineLearning.protocol{1,dProtocolOffset}.skelton.field{1, aa}.fieldName.Text  = asSkeletonName{aa};
                st.machineLearning.protocol{1,dProtocolOffset}.skelton.field{1, aa}.fieldType.Text  = get(chkMachineSegmentationSkeleton{aa}, 'Style');
                st.machineLearning.protocol{1,dProtocolOffset}.skelton.field{1, aa}.fieldValue.Text = get(chkMachineSegmentationSkeleton{aa}, 'Value');
                if ~isempty(edtMachineSegmentationSkeleton{aa}) % Set Edit Box 
                    asEdtStrValue = get(edtMachineSegmentationSkeleton{aa}, 'String');
                    st.machineLearning.protocol{1,dProtocolOffset}.skelton.field{1,aa}.field.fieldType.Text  = get(edtMachineSegmentationSkeleton{aa}, 'Style');               
                    st.machineLearning.protocol{1,dProtocolOffset}.skelton.field{1,aa}.field.fieldValue.Text = char(asEdtStrValue);  
                end
            end

            % Cardiovascular System

            for bb=1:numel(asCardiovascularName)
                st.machineLearning.protocol{1,dProtocolOffset}.cardiovascular.field{1, bb}.fieldName.Text  = asCardiovascularName{bb};
                st.machineLearning.protocol{1,dProtocolOffset}.cardiovascular.field{1, bb}.fieldType.Text  = get(chkMachineSegmentationCardiovascular{bb}, 'Style');
                st.machineLearning.protocol{1,dProtocolOffset}.cardiovascular.field{1, bb}.fieldValue.Text = get(chkMachineSegmentationCardiovascular{bb}, 'Value');
            end

            % Other Organs

            for cc=1:numel(asOtherOrgansName)
                st.machineLearning.protocol{1,dProtocolOffset}.otherOrgans.field{1, cc}.fieldName.Text  = asOtherOrgansName{cc};
                st.machineLearning.protocol{1,dProtocolOffset}.otherOrgans.field{1, cc}.fieldType.Text  = get(chkMachineSegmentationOtherOrgans{cc}, 'Style');
                st.machineLearning.protocol{1,dProtocolOffset}.otherOrgans.field{1, cc}.fieldValue.Text = get(chkMachineSegmentationOtherOrgans{cc}, 'Value');
            end     

            % Gastrointestinal Tract

            for dd=1:numel(asGastrointestinalTractName)
                st.machineLearning.protocol{1,dProtocolOffset}.gastrointestinal.field{1, dd}.fieldName.Text  = asGastrointestinalTractName{dd};
                st.machineLearning.protocol{1,dProtocolOffset}.gastrointestinal.field{1, dd}.fieldType.Text  = get(chkMachineSegmentationGastrointestinalTract{dd}, 'Style');
                st.machineLearning.protocol{1,dProtocolOffset}.gastrointestinal.field{1, dd}.fieldValue.Text = get(chkMachineSegmentationGastrointestinalTract{dd}, 'Value');
            end 

            % Muscles

            for ee=1:numel(asMusclesName)
                st.machineLearning.protocol{1,dProtocolOffset}.muscles.field{1, ee}.fieldName.Text  = asMusclesName{ee};
                st.machineLearning.protocol{1,dProtocolOffset}.muscles.field{1, ee}.fieldType.Text  = get(chkMachineSegmentationMuscles{ee}, 'Style');
                st.machineLearning.protocol{1,dProtocolOffset}.muscles.field{1, ee}.fieldValue.Text = get(chkMachineSegmentationMuscles{ee}, 'Value');
            end     

            struct2xml(st, sXmlProtocolFileName);
            
            set(popMachineSegmentationProtocol, 'String', getMchineLearningProtocolName());
        end
    end
    
    function asMachineSegmentationProtocol = getMchineLearningProtocolName()
        
        sRootPath = viewerRootPath('get');
        sProtocolPath = sprintf('%s/protocol/', sRootPath);

        f = java.io.File(char(sProtocolPath));
        asListing = f.listFiles();

        sXmlProtocolFileName = '';

        for yy=1:numel(asListing) % If file exist
            if contains(char(asListing(yy)), 'machineLearning.xml')
                sXmlProtocolFileName = char(asListing(yy));
            end
        end

        if isempty(sXmlProtocolFileName)   
            asMachineSegmentationProtocol{1} = ' ';
        else
            stXml = xml2struct(sXmlProtocolFileName);

            if isfield (stXml.machineLearning, 'protocol') 
                dNbXmlProtocol = numel(stXml.machineLearning.protocol);
                if dNbXmlProtocol
                    if dNbXmlProtocol >1
                        
                        asMachineSegmentationProtocol = cell(1, dNbXmlProtocol);
                        for zz=1:dNbXmlProtocol
                            asMachineSegmentationProtocol{zz}=stXml.machineLearning.protocol{1, zz}.protocolName.Text;    
                        end
                    else
                        asMachineSegmentationProtocol{1} = stXml.machineLearning.protocol.protocolName.Text;
                    end
                else
                    asMachineSegmentationProtocol{1} = ' ';
                end
            else
                asMachineSegmentationProtocol{1} = ' ';
            end
        end
    end

    % Cancel
          
    function cancelMachineSegmentationCallback(~, ~)
        
        delete(dlgMachineSegmentation);
    end

    % Proceed
         
    function proceedMachineSegmentationCallback(~, ~)
    
        try


        set(dlgMachineSegmentation, 'Pointer', 'watch');
        drawnow;         

        dSerieOffset = get(uiSeriesPtr('get'), 'Value');
                
        tInput = inputTemplate('get');
        
        % Modality validation    
               
        if ~strcmpi(tInput(dSerieOffset).atDicomInfo{1}.Modality, 'ct')
            
            progressBar(1, 'Error: Segmentation of classes require a CT image!');
            errordlg('Segmentation of classes require a CT image!', 'Modality Validation');  
            return;            
        end
                    
        % Get DICOM directory directory    
        
        [sFilePath, ~, ~] = fileparts(char(tInput(dSerieOffset).asFilesList{1}));
        
        % Create an empty directory    

        sNiiTmpDir = sprintf('%stemp_nii_%s/', viewerTempDirectory('get'), datetime('now','Format','MMMM-d-y-hhmmss'));
        if exist(char(sNiiTmpDir), 'dir')
            rmdir(char(sNiiTmpDir), 's');
        end
        mkdir(char(sNiiTmpDir));    
        
        % Convert dicom to .nii     
        
        progressBar(1/4, 'Convertion dicom to nii, please wait.');

        dicm2nii(sFilePath, sNiiTmpDir, 1);
        
        sNiiFullFileName = '';
        
        f = java.io.File(char(sNiiTmpDir)); % Get .nii file name
        dinfo = f.listFiles();                   
        for K = 1 : 1 : numel(dinfo)
            if ~(dinfo(K).isDirectory)
                if contains(sprintf('%s%s', sNiiTmpDir, dinfo(K).getName()), '.nii.gz')
                    sNiiFullFileName = sprintf('%s%s', sNiiTmpDir, dinfo(K).getName());
                    break;
                end
            end
        end 
    
        if isempty(sNiiFullFileName)
            
            progressBar(1, 'Error: nii file mot found!');
            errordlg('nii file mot found!!', '.nii file Validation'); 
        else
            progressBar(2/4, 'Segmentation in progress, this might take several minutes, please be patient.');
           
            sSegmentationFolderName = sprintf('%stemp_seg_%s/', viewerTempDirectory('get'), datetime('now','Format','MMMM-d-y-hhmmss'));
            if exist(char(sSegmentationFolderName), 'dir')
                rmdir(char(sSegmentationFolderName), 's');
            end
            mkdir(char(sSegmentationFolderName)); 
        
            if ispc % Windows
                
                %set path=%path:C:\Program Files\MATLAB\R2020a\bin\win64;=% &
                sOption = '';
                if fastMachineLearningDialog('get') == true
                    sOption = sprintf('%s --fast', sOption);
                end

                if forceSplitMachineLearningDialog('get') == true
                    sOption = sprintf('%s --force_split', sOption);
                end

                if bodySegMachineLearningDialog('get') == true
                    sOption = sprintf('%s --body_seg', sOption);
                end


     %           if fastMachineLearningDialog('get') == true
                    sCommandLine = sprintf('cmd.exe /c python.exe %sTotalSegmentator -i %s -o %s %s', sSegmentatorPath, sNiiFullFileName, sSegmentationFolderName, sOption);    
     %           else
     %               sCommandLine = sprintf('cmd.exe /c python.exe %sTotalSegmentator -i %s -o %s --force_split --body_seg', sSegmentatorPath, sNiiFullFileName, sSegmentationFolderName);    
     %           end
            
                [bStatus, sCmdout] = system(sCommandLine);
                
                if bStatus 
                    progressBar( 1, 'Error: An error occur during machine learning segmentation!');
                    errordlg(sprintf('An error occur during machine learning segmentation: %s', sCmdout), 'Segmentation Error');  
                else % Process succeed

                    progressBar(3/4, 'Importing mask, please wait.');
                    
                    nii2voiMask(sSegmentationFolderName);

                end


            elseif isunix % Linux is not yet supported

                progressBar( 1, 'Error: Machine Learning under Linux is not supported');
                errordlg('Machine Learning under Linux is not supported', 'Machine Learning Validation');

            else % Mac is not yet supported

                progressBar( 1, 'Error: Machine Learning under Mac is not supported');
                errordlg('Machine Learning under Mac is not supported', 'Machine Learning Validation');
            end
    
        end
        
        % Delete .nii folder    
        
        if exist(char(sNiiTmpDir), 'dir')
            rmdir(char(sNiiTmpDir), 's');
        end        

        progressBar(1, 'Ready');

        catch

            progressBar(1, 'Error: proceedMachineSegmentationCallback()!');

        end

        delete(dlgMachineSegmentation);        

    %    set(dlgMachineSegmentation, 'Pointer', 'default');
        drawnow;      
       
        refreshImages();

    end

    function nii2voiMask(sSegmentationFolderName)

        dSerieOffset = get(uiSeriesPtr('get'), 'Value');

        % Skeleton

        progressBar(3.2/4, 'Scanning skeletonardiovascular masks');

        adOffset = cellfun( @(chkMachineSegmentationSkeleton) chkMachineSegmentationSkeleton.Value, chkMachineSegmentationSkeleton, 'uni', true );
        
        if ~isempty(find(adOffset, true))

            for aa=1:numel(adOffset)    

                if adOffset(aa) == true

                    progressBar(aa/(numel(adOffset)-0.009), sprintf('Importing skeleton mask %d/%d', aa, numel(adOffset) ));

                    sObjectName = lower(asSkeletonName{aa});

                    switch lower(sObjectName)

                        case 'rib left [1-12]' 

                            csEditValue = get(edtMachineSegmentationSkeleton{aa}, 'string');
                            
                            dObjectFrom = str2double(extractBefore(csEditValue,'-'));
                            dObjectTo   = str2double(extractAfter (csEditValue,'-'));

                            for jj=dObjectFrom:dObjectTo

                                progressBar(jj/dObjectTo-0.009, sprintf('Importing rib left %d/%d', jj, dObjectTo ));

                             
                                sNiiFileName = sprintf('rib_left_%d', jj);
                                sNiiFileName = sprintf('%s%s.nii.gz', sSegmentationFolderName, sNiiFileName);
        
                                if exist(sNiiFileName, 'file')

                                    xmin=0.5;
                                    xmax=1;
                                    aColor=xmin+rand(1,3)*(xmax-xmin);

                                    nii = nii_tool('load', sNiiFileName);
                                    aMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');
                                    aMask = aMask(:,:,end:-1:1);

                                    maskToVoi(aMask, sprintf('Rib Left %d', jj), 'Bone', aColor, 'axial', dSerieOffset, pixelEdge('get'));
                                end                                
                            end

                        case 'rib right [1-12]'

                            csEditValue = get(edtMachineSegmentationSkeleton{aa}, 'string');
                            
                            dObjectFrom = str2double(extractBefore(csEditValue,'-'));
                            dObjectTo   = str2double(extractAfter (csEditValue,'-'));

                            for jj=dObjectFrom:dObjectTo

                                progressBar(jj/dObjectTo-0.009, sprintf('Importing rib right %d/%d', jj, dObjectTo ));
                   
                                sNiiFileName = sprintf('rib_right_%d', jj);
                                sNiiFileName = sprintf('%s%s.nii.gz', sSegmentationFolderName, sNiiFileName);
        
                                if exist(sNiiFileName, 'file')

                                    xmin=0.5;
                                    xmax=1;
                                    aColor=xmin+rand(1,3)*(xmax-xmin);

                                    nii = nii_tool('load', sNiiFileName);
                                    aMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');
                                    aMask = aMask(:,:,end:-1:1);

                                    maskToVoi(aMask, sprintf('Rib Right %d', jj), 'Bone', aColor, 'axial', dSerieOffset, pixelEdge('get'));
                                end                                
                            end

                        case 'vertebrae c[1-7]' 

                            csEditValue = get(edtMachineSegmentationSkeleton{aa}, 'string');
                            
                            dObjectFrom = str2double(extractBefore(csEditValue,'-'));
                            dObjectTo   = str2double(extractAfter (csEditValue,'-'));

                            for jj=dObjectFrom:dObjectTo

                                progressBar(jj/dObjectTo-0.009, sprintf('Importing vertebrae C %d/%d', jj, dObjectTo ));
                          
                                sNiiFileName = sprintf('vertebrae_C%d', jj);
                                sNiiFileName = sprintf('%s%s.nii.gz', sSegmentationFolderName, sNiiFileName);
        
                                if exist(sNiiFileName, 'file')

                                    xmin=0.5;
                                    xmax=1;
                                    aColor=xmin+rand(1,3)*(xmax-xmin);

                                    nii = nii_tool('load', sNiiFileName);
                                    aMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');
                                    aMask = aMask(:,:,end:-1:1);

                                    maskToVoi(aMask, sprintf('Vertebrae C%d', jj), 'Bone', aColor, 'axial', dSerieOffset, pixelEdge('get'));
                                end                                
                            end

                        case 'vertebrae t[1-12]' 

                            csEditValue = get(edtMachineSegmentationSkeleton{aa}, 'string');
                            
                            dObjectFrom = str2double(extractBefore(csEditValue,'-'));
                            dObjectTo   = str2double(extractAfter (csEditValue,'-'));

                            for jj=dObjectFrom:dObjectTo

                                progressBar(jj/dObjectTo-0.009, sprintf('Importing vertebrae T %d/%d', jj, dObjectTo ));
                    
                                sNiiFileName = sprintf('vertebrae_T%d', jj);
                                sNiiFileName = sprintf('%s%s.nii.gz', sSegmentationFolderName, sNiiFileName);
        
                                if exist(sNiiFileName, 'file')

                                    xmin=0.5;
                                    xmax=1;
                                    aColor=xmin+rand(1,3)*(xmax-xmin);

                                    nii = nii_tool('load', sNiiFileName);
                                    aMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');
                                    aMask = aMask(:,:,end:-1:1);

                                    maskToVoi(aMask, sprintf('Vertebrae T%d', jj), 'Bone', aColor, 'axial', dSerieOffset, pixelEdge('get'));
                                end                                
                            end

                        case 'vertebrae l[1-5]' 

                            csEditValue = get(edtMachineSegmentationSkeleton{aa}, 'string');
                            
                            dObjectFrom = str2double(extractBefore(csEditValue,'-'));
                            dObjectTo   = str2double(extractAfter (csEditValue,'-'));

                            for jj=dObjectFrom:dObjectTo

                                progressBar(jj/dObjectTo-0.009, sprintf('Importing vertebrae L %d/%d', jj, dObjectTo ));
                              
                                sNiiFileName = sprintf('vertebrae_L%d', jj);
                                sNiiFileName = sprintf('%s%s.nii.gz', sSegmentationFolderName, sNiiFileName);
        
                                if exist(sNiiFileName, 'file')

                                    xmin=0.5;
                                    xmax=1;
                                    aColor=xmin+rand(1,3)*(xmax-xmin);

                                    nii = nii_tool('load', sNiiFileName);
                                    aMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');
                                    aMask = aMask(:,:,end:-1:1);

                                    maskToVoi(aMask, sprintf('Vertebrae L%d', jj), 'Bone', aColor, 'axial', dSerieOffset, pixelEdge('get'));
                                end                                
                            end

                        case 'ribs' % ribs need to be combined

                            xmin=0.5;
                            xmax=1;
                            aColor=xmin+rand(1,3)*(xmax-xmin);

                            sNiiFileName = 'combined_ribs.nii.gz';
    
                            sCommandLine = sprintf('cmd.exe /c python.exe %stotalseg_combine_masks -i %s -o %s%s -m ribs', sSegmentatorPath, sSegmentationFolderName, sSegmentationFolderName, sNiiFileName);    
                
                            [bStatus, sCmdout] = system(sCommandLine);
    
                            if bStatus 
                                progressBar( 1, 'Error: An error occur during ribs combine mask!');
                                errordlg(sprintf('An error occur during ribs combine mask: %s', sCmdout), 'Segmentation Error');  
                            else % Process succeed
    
                                sNiiFileName = sprintf('%s%s', sSegmentationFolderName, sNiiFileName);
                                
                                if exist(sNiiFileName, 'file')
                                    nii = nii_tool('load', sNiiFileName);
                                    aMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');
                                    aMask = aMask(:,:,end:-1:1);

                                    maskToVoi(aMask, asSkeletonName{aa}, 'Bone', aColor, 'axial', dSerieOffset, pixelEdge('get'));
                               end
            
                            end

                        case 'vertebrae' % vertebrae need to be combined

                            xmin=0.5;
                            xmax=1;
                            aColor=xmin+rand(1,3)*(xmax-xmin);

                            sNiiFileName = 'combined_vertebrae.nii.gz';
    
                            sCommandLine = sprintf('cmd.exe /c python.exe %stotalseg_combine_masks -i %s -o %s%s -m vertebrae', sSegmentatorPath, sSegmentationFolderName, sSegmentationFolderName, sNiiFileName);    
                
                            [bStatus, sCmdout] = system(sCommandLine);
    
                            if bStatus 
                                progressBar( 1, 'Error: An error occur during vertebrae combine mask!');
                                errordlg(sprintf('An error occur during vertebrae combine mask: %s', sCmdout), 'Segmentation Error');  
                            else % Process succeed
    
                                sNiiFileName = sprintf('%s%s', sSegmentationFolderName, sNiiFileName);
                                
                                if exist(sNiiFileName, 'file')
                                    nii = nii_tool('load', sNiiFileName);
                                    aMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');
                                    aMask = aMask(:,:,end:-1:1);
                                    
                                    maskToVoi(aMask, asSkeletonName{aa}, 'Bone', aColor, 'axial', dSerieOffset, pixelEdge('get'));
                               end
            
                            end

                        case 'vertebrae ribs' % vertebrae need to be combined

                            xmin=0.5;
                            xmax=1;
                            aColor=xmin+rand(1,3)*(xmax-xmin);

                            sNiiFileName = 'combined_vertebrae.nii.gz';
    
                            sCommandLine = sprintf('cmd.exe /c python.exe %stotalseg_combine_masks -i %s -o %s%s -m vertebrae_ribs', sSegmentatorPath, sSegmentationFolderName, sSegmentationFolderName, sNiiFileName);    
                
                            [bStatus, sCmdout] = system(sCommandLine);
    
                            if bStatus 
                                progressBar( 1, 'Error: An error occur during vertebrae ribs combine mask!');
                                errordlg(sprintf('An error occur during vertebrae ribs combine mask: %s', sCmdout), 'Segmentation Error');  
                            else % Process succeed
    
                                sNiiFileName = sprintf('%s%s', sSegmentationFolderName, sNiiFileName);
                                
                                if exist(sNiiFileName, 'file')
                                    nii = nii_tool('load', sNiiFileName);
                                    aMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');
                                    aMask = aMask(:,:,end:-1:1);

                                    maskToVoi(aMask, asSkeletonName{aa}, 'Bone', aColor, 'axial', dSerieOffset, pixelEdge('get'));
                               end
            
                            end

                        otherwise

                            xmin=0.5;
                            xmax=1;
                            aColor=xmin+rand(1,3)*(xmax-xmin);

                            sNiiFileName = replace(lower(sObjectName), ' ', '_');
                            sNiiFileName = sprintf('%s%s.nii.gz', sSegmentationFolderName, sNiiFileName);
    
                            if exist(sNiiFileName, 'file')
    
                                nii = nii_tool('load', sNiiFileName);
                                aMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');
                                aMask = aMask(:,:,end:-1:1);

                                maskToVoi(aMask, asSkeletonName{aa}, 'Bone', aColor, 'axial', dSerieOffset, pixelEdge('get'));
                            end
                    end

                end
            end
            
            if exist('aMask', 'var')
                clear aMask;
            end    
        end  

        % Cardiovascular System

        progressBar(3.4/4, 'Scanning cardiovascular system masks');

        adOffset = cellfun( @(chkMachineSegmentationCardiovascular) chkMachineSegmentationCardiovascular.Value, chkMachineSegmentationCardiovascular, 'uni', true );
        
        if ~isempty(find(adOffset, true))

            for bb=1:numel(adOffset)    

                if adOffset(bb) == true

                    progressBar(bb/(numel(adOffset)-0.009), sprintf('Importing cardiovascular system mask %d/%d', bb, numel(adOffset) ));

                    sObjectName = lower(asCardiovascularName{bb});

                    switch lower(sObjectName)

                        case 'heart' % heart need to be combined

                            xmin=0.5;
                            xmax=1;
                            aColor=xmin+rand(1,3)*(xmax-xmin);

                            sNiiFileName = 'combined_heart.nii.gz';
    
                            sCommandLine = sprintf('cmd.exe /c python.exe %stotalseg_combine_masks -i %s -o %s%s -m heart', sSegmentatorPath, sSegmentationFolderName, sSegmentationFolderName, sNiiFileName);    
                
                            [bStatus, sCmdout] = system(sCommandLine);
    
                            if bStatus 
                                progressBar( 1, 'Error: An error occur during heart combine mask!');
                                errordlg(sprintf('An error occur during heart combine mask: %s', sCmdout), 'Segmentation Error');  
                            else % Process succeed
    
                                sNiiFileName = sprintf('%s%s', sSegmentationFolderName, sNiiFileName);
                                
                                if exist(sNiiFileName, 'file')
                                    nii = nii_tool('load', sNiiFileName);
                                    aMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');
                                    aMask = aMask(:,:,end:-1:1);

                                    maskToVoi(aMask, asCardiovascularName{bb}, 'Unspecified', aColor, 'axial', dSerieOffset, pixelEdge('get'));
                               end
            
                            end

                        otherwise

                            xmin=0.5;
                            xmax=1;
                            aColor=xmin+rand(1,3)*(xmax-xmin);

                            switch lower(sObjectName)
                                case 'atrium left' % heart need to be added
                                    sNiiFileName = replace(lower(sObjectName), ' ', '_');
                                    sNiiFileName = sprintf('%sheart_%s.nii.gz', sSegmentationFolderName, sNiiFileName);   

                                case 'atrium right' % heart need to be added
                                    sNiiFileName = replace(lower(sObjectName), ' ', '_');
                                    sNiiFileName = sprintf('%sheart_%s.nii.gz', sSegmentationFolderName, sNiiFileName);   

                                case 'myocardium' % heart need to be added
                                    sNiiFileName = replace(lower(sObjectName), ' ', '_');
                                    sNiiFileName = sprintf('%sheart_%s.nii.gz', sSegmentationFolderName, sNiiFileName);   

                                case 'ventricle left' % heart need to be added
                                    sNiiFileName = replace(lower(sObjectName), ' ', '_');
                                    sNiiFileName = sprintf('%sheart_%s.nii.gz', sSegmentationFolderName, sNiiFileName);   

                                case 'ventricle right' % heart need to be added
                                    sNiiFileName = replace(lower(sObjectName), ' ', '_');
                                    sNiiFileName = sprintf('%sheart_%s.nii.gz', sSegmentationFolderName, sNiiFileName); 

                                case 'portal & splenic vein'
                                    sNiiFileName = sprintf('%sportal_vein_and_splenic_vein.nii.gz', sSegmentationFolderName); 
                                   
                                otherwise
                                    sNiiFileName = replace(lower(sObjectName), ' ', '_');
                                    sNiiFileName = sprintf('%s%s.nii.gz', sSegmentationFolderName, sNiiFileName);
                            end
    
                            if exist(sNiiFileName, 'file')
    
                                nii = nii_tool('load', sNiiFileName);
                                aMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');
                                aMask = aMask(:,:,end:-1:1);

                                maskToVoi(aMask, asCardiovascularName{bb}, 'Unspecified', aColor, 'axial', dSerieOffset, pixelEdge('get'));
                            end
                    end

                end
            end
            
            if exist('aMask', 'var')
                clear aMask;
            end    
        end  

        % OtherOrgans

        progressBar(3.6/4, 'Scanning other organs masks');

        adOffset = cellfun( @(chkMachineSegmentationOtherOrgans) chkMachineSegmentationOtherOrgans.Value, chkMachineSegmentationOtherOrgans, 'uni', true );
        
        if ~isempty(find(adOffset, true))

            for cc=1:numel(adOffset)    

                if adOffset(cc) == true

                    progressBar(cc/(numel(adOffset)-0.009), sprintf('Importing other organ mask %d/%d', cc, numel(adOffset) ));

                    sObjectName = lower(asOtherOrgansName{cc});

                    switch lower(sObjectName)

                        case 'lungs' % Lung need to be combined

                            aColor=[1 0.5 1]; % Pink

                            sNiiFileName = 'combined_lungs.nii.gz';
    
                            sCommandLine = sprintf('cmd.exe /c python.exe %stotalseg_combine_masks -i %s -o %s%s -m lung', sSegmentatorPath, sSegmentationFolderName, sSegmentationFolderName, sNiiFileName);    
                
                            [bStatus, sCmdout] = system(sCommandLine);
    
                            if bStatus 
                                progressBar( 1, 'Error: An error occur during lung combine mask!');
                                errordlg(sprintf('An error occur during lung combine mask: %s', sCmdout), 'Segmentation Error');  
                            else % Process succeed
    
                                sNiiFileName = sprintf('%s%s', sSegmentationFolderName, sNiiFileName);
                                
                                if exist(sNiiFileName, 'file')
                                    nii = nii_tool('load', sNiiFileName);
                                    aMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');
                                    aMask = aMask(:,:,end:-1:1);

                                    maskToVoi(aMask, asOtherOrgansName{cc}, 'Lung', aColor, 'axial', dSerieOffset, pixelEdge('get'));
                               end
            
                            end

                        case 'lung left' % Lung left need to be combined

                            aColor=[0.7 1 0.7]; % Lght green

                            sNiiFileName = 'combined_lung_left.nii.gz';
    
                            sCommandLine = sprintf('cmd.exe /c python.exe %stotalseg_combine_masks -i %s -o %s%s -m lung_left', sSegmentatorPath, sSegmentationFolderName, sSegmentationFolderName, sNiiFileName);    
                
                            [bStatus, sCmdout] = system(sCommandLine);
    
                            if bStatus 
                                progressBar( 1, 'Error: An error occur during lung left combine mask!');
                                errordlg(sprintf('An error occur during lung left combine mask: %s', sCmdout), 'Segmentation Error');  
                            else % Process succeed
    
                                sNiiFileName = sprintf('%s%s', sSegmentationFolderName, sNiiFileName);
                                
                                if exist(sNiiFileName, 'file')
                                    nii = nii_tool('load', sNiiFileName);
                                    aMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');
                                    aMask = aMask(:,:,end:-1:1);

                                    maskToVoi(aMask, asOtherOrgansName{cc}, 'Lung', aColor, 'axial', dSerieOffset, pixelEdge('get'));
                               end
            
                            end

                        case 'lung right' % Lung right need to be combined

                            aColor=[0.67 0 1]; % Violet

                            sNiiFileName = 'combined_lung_right.nii.gz';
    
                            sCommandLine = sprintf('cmd.exe /c python.exe %stotalseg_combine_masks -i %s -o %s%s -m lung_right', sSegmentatorPath, sSegmentationFolderName, sSegmentationFolderName, sNiiFileName);    
                
                            [bStatus, sCmdout] = system(sCommandLine);
    
                            if bStatus 
                                progressBar( 1, 'Error: An error occur during lung right combine mask!');
                                errordlg(sprintf('An error occur during lung right combine mask: %s', sCmdout), 'Segmentation Error');  
                            else % Process succeed
    
                                sNiiFileName = sprintf('%s%s', sSegmentationFolderName, sNiiFileName);
                                
                                if exist(sNiiFileName, 'file')
                                    nii = nii_tool('load', sNiiFileName);
                                    aMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');
                                    aMask = aMask(:,:,end:-1:1);

                                    maskToVoi(aMask, asOtherOrgansName{cc}, 'Lung', aColor, 'axial', dSerieOffset, pixelEdge('get'));
                               end
            
                            end

                        otherwise

                            switch lower(sObjectName)

                                case 'liver'
                                    aColor=[1 0.41 0.16]; % Orange
                                    sLesionType = 'Liver';

                                case 'lung upper lobe left'
                                    aColor=[0 1 1]; % Cyan
                                    sLesionType = 'Lung';

                                case 'lung upper lobe right'
                                    aColor=[0 1 0]; % Green
                                    sLesionType = 'Lung';

                                case 'lung middle lobe right'
                                    aColor=[1 1 0]; % Yellow
                                    sLesionType = 'Lung';

                                case 'lung lower lobe left'
                                    aColor=[1 0 0]; % Red
                                    sLesionType = 'Lung';

                                case 'lung lower lobe right'
                                    aColor=[0 0.5 1]; % Blue
                                    sLesionType = 'Lung';

                                otherwise % Random
                                    xmin=0.5;
                                    xmax=1;
                                    aColor=xmin+rand(1,3)*(xmax-xmin);
                                    sLesionType = 'Unspecified';
                            end
 
                            sNiiFileName = replace(lower(sObjectName), ' ', '_');
                            sNiiFileName = sprintf('%s%s.nii.gz', sSegmentationFolderName, sNiiFileName);
    
                            if exist(sNiiFileName, 'file')
    
                                nii = nii_tool('load', sNiiFileName);
                                aMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');
                                aMask = aMask(:,:,end:-1:1);

                                maskToVoi(aMask, asOtherOrgansName{cc}, sLesionType, aColor, 'axial', dSerieOffset, pixelEdge('get'));
                            end
                    end

                end
            end
            
            if exist('aMask', 'var')
                clear aMask;
            end    
        end  

        % Gastrointestinal Tract

        progressBar(3.8/4, 'Scanning gastrointestinal tract masks');

        adOffset = cellfun( @(chkMachineSegmentationGastrointestinalTract) chkMachineSegmentationGastrointestinalTract.Value, chkMachineSegmentationGastrointestinalTract, 'uni', true );
        
        if ~isempty(find(adOffset, true))

            for dd=1:numel(adOffset)    

                if adOffset(dd) == true

                    progressBar(dd/(numel(adOffset)-0.009), sprintf('Importing gastrointestinal tract mask %d/%d', dd, numel(adOffset) ));

                    sObjectName = lower(asGastrointestinalTractName{dd});

                    xmin=0.5;
                    xmax=1;
                    aColor=xmin+rand(1,3)*(xmax-xmin);

                    sNiiFileName = replace(lower(sObjectName), ' ', '_');
                    sNiiFileName = sprintf('%s%s.nii.gz', sSegmentationFolderName, sNiiFileName);

                    if exist(sNiiFileName, 'file')

                        nii = nii_tool('load', sNiiFileName);
                        aMask = imrotate3(nii.img, 90, [0 0 1], 'nearest');
                        aMask = aMask(:,:,end:-1:1);

                        maskToVoi(aMask, asGastrointestinalTractName{dd}, 'Unspecified', aColor, 'axial', dSerieOffset, pixelEdge('get'));
                    end

                end
            end
            
            if exist('aMask', 'var')
                clear aMask;
            end    
        end  

        % Muscles

        progressBar(3.9/4, 'Scanning muscles masks');

        adOffset = cellfun( @(chkMachineSegmentationMuscles) chkMachineSegmentationMuscles.Value, chkMachineSegmentationMuscles, 'uni', true );
        
        if ~isempty(find(adOffset, true))

            for ee=1:numel(adOffset)    

                if adOffset(ee) == true

                    progressBar(ee/(numel(adOffset)-0.009), sprintf('Importing muscles mask %d/%d', ee, numel(adOffset) ));

                    sObjectName = lower(asMusclesName{ee});

                    xmin=0.5;
                    xmax=1;
                    aColor=xmin+rand(1,3)*(xmax-xmin);

                    sNiiFileName = replace(lower(sObjectName), ' ', '_');
                    sNiiFileName = sprintf('%s%s.nii.gz', sSegmentationFolderName, sNiiFileName);

                    if exist(sNiiFileName, 'file')

                        nii = nii_tool('load', sNiiFileName);
                        aMask = imrotate3(nii.img, 90, [0 0 1],'nearest');
                        aMask = aMask(:,:,end:-1:1);

                        maskToVoi(aMask, asMusclesName{ee}, 'Unspecified', aColor, 'axial', dSerieOffset, pixelEdge('get'));
                    end

                end
            end
            
            if exist('aMask', 'var')
                clear aMask;
            end    
        end  

    end

    function uiMachineSegmentationSliderCallback(~, ~)

        val = get(uiMachineSegmentationSlider, 'Value');
    
        aPosition = get(uiMachineSegmentation, 'Position');
    
        dPanelOffset = -((1-val) * aPosition(4));
    
        set(uiMachineSegmentation, ...
            'Position', [aPosition(1) ...
                         0-dPanelOffset ...
                         aPosition(3) ...
                         aPosition(4) ...
                         ] ...
            );
    end
end