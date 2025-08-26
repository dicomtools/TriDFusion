function processWorkflow(sWorkflowName)
%function processWorkflow(sWorkflowName)
%Process a workflow base on it file.m name.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2024, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    switch lower(sWorkflowName)

        case 'setviewerfusioncallback' % setViewerFusionCallback.m

            setViewerFusionCallback();
            

        case 'setpetctanalcancerfusioncallback' % setPETCTAnalCancerFusionCallback.m

            setPETCTAnalCancerFusionCallback();
    

        case 'setpetctfdgfusioncallback'  % setPETCTFDGFusionCallback.m

            setPETCTFDGFusionCallback();

        case 'setpetctbrownfatfusioncallback'  % setPETCTBrownFatFusionCallback.m

            setPETCTBrownFatFusionCallback();

        case 'setpetctfdhtfusioncallback' % setPETCTFDHTFusionCallback.m
            
            setPETCTFDHTFusionCallback();


        case 'setpetctga68dotatatefusioncallback' % setPETCTGa68DOTATATEFusionCallback.m           

            setPETCTGa68DOTATATEFusionCallback();


        case 'setpetctlu177fusioncallback' % setPETCTLu177FusionCallback.m

            setPETCTLu177FusionCallback();


        case 'setpetctpsmafusioncallback' % setPETCTPSMAFusionCallback.mm

            setPETCTPSMAFusionCallback();


        case 'setsegmentationfdgpercentcallback' % setSegmentationFDGPercentCallback.m    
    
            setSegmentationFDGPercentCallback();


        case 'setsegmentationfdgsuvcallback' % setSegmentationFDGSUVCallback.m
            
            setSegmentationFDGSUVCallback();

            
        case 'setsegmentationfdhtcallback' % setSegmentationFDHTCallback.m

            setSegmentationFDHTCallback();


        case 'setsegmentationlu177callback' % setSegmentationLu177Callback.m

            setSegmentationLu177Callback();


        case 'setsegmentationpsmacallback' % setSegmentationPSMACallback.m

            setSegmentationPSMACallback();
        
        case 'setsegmentationmrtorganscallback' % setSegmentationMRTOrgansCallback.m

            setSegmentationMRTOrgansCallback();

        case 'setsegmentationailivercallback' % setSegmentationAILiverCallback.m

            setSegmentationAILiverCallback();

        % Modules

        case 'setmachinelearning3dlungshuntcallback' % setMachineLearning3DLungShuntCallback.m 

            setMachineLearning3DLungShuntCallback();
        

        case 'setmachinelearning3dlobelungcallback' % setMachineLearning3DLobeLungCallback.m   

            setMachineLearning3DLobeLungCallback(); 

        % Brown Fat

        case 'setfdgbrownfatctexporttoexcelcallback' % setFDGBrownFatCTExportToExcelCallback.m
            
            setFDGBrownFatCTExportToExcelCallback();
              
        case 'setfdgbrownfatptexporttoexcelcallback' % setFDGBrownFatPTExportToExcelCallback.m

            setFDGBrownFatPTExportToExcelCallback();
      
        case 'setfdgbrownfatfullaiexporttoexcelcallback' % setFDGBrownFatFullAIExportToExcelCallback.m

            setFDGBrownFatFullAIExportToExcelCallback();

        case 'runmachinelearningfdgbrownfatfullaicallback' % runMachineLearningFDGBrownFatFullAICallback.m

             runMachineLearningFDGBrownFatFullAICallback();

        case 'setmachinelearningfdgbrownfatsuvcallback' % setMachineLearningFDGBrownFatSUVCallback.m

            setMachineLearningFDGBrownFatSUVCallback();
            
        case 'setmachinelearningfdgbrownfatsuvrt_structurecallback' % setMachineLearningFDGBrownFatSUVRT_structureCallback.m

            setMachineLearningFDGBrownFatSUVRT_structureCallback();

        % PET Full AI

        case 'setmachinelearningfdgbrownfatpetfullaicallback' % setMachineLearningFDGBrownFatPETFullAICallback.m
   
            setMachineLearningFDGBrownFatPETFullAICallback();

        case 'setmachinelearningfdgbrownfatpetfullaibqmlrtstructcallback' % setMachineLearningFDGBrownFatPETFullAIBQMLRTstructCallback.m    

            setMachineLearningFDGBrownFatPETFullAIBQMLRTstructCallback();

        case 'setmachinelearningfdgbrownfatpetfullaisuvrtstructcallback' % setMachineLearningFDGBrownFatPETFullAISUVRTstructCallback.m    

            setMachineLearningFDGBrownFatPETFullAISUVRTstructCallback();

        case 'setmachinelearningfdgbrownfatpetfullainormrtstructcallback' % setMachineLearningFDGBrownFatPETFullAINormRTstructCallback.m    

            setMachineLearningFDGBrownFatPETFullAINormRTstructCallback();

        % PET CE Loss 

        case 'setmachinelearningfdgbrownfatpetfullaicebqmlrtstructcallback' % setMachineLearningFDGBrownFatPETFullAICEBQMLRTstructCallback.m    

            setMachineLearningFDGBrownFatPETFullAICEBQMLRTstructCallback();

        case 'setmachinelearningfdgbrownfatpetfullaicesuvrtstructcallback' % setMachineLearningFDGBrownFatPETFullAICESUVRTstructCallback.m    

            setMachineLearningFDGBrownFatPETFullAICESUVRTstructCallback();

        case 'setmachinelearningfdgbrownfatpetfullaicenormrtstructcallback' % setMachineLearningFDGBrownFatPETFullAICENormRTstructCallback.m    

            setMachineLearningFDGBrownFatPETFullAICENormRTstructCallback();

        % PET/CT Full AI

        case 'setmachinelearningfdgbrownfatpetctfullaicallback' % setMachineLearningFDGBrownFatPETCTFullAICallback.m    

            setMachineLearningFDGBrownFatPETCTFullAICallback();

        case 'setmachinelearningfdgbrownfatpetctfullaibqmlrtstructcallback' % setMachineLearningFDGBrownFatPETCTFullAIBQMLRTstructCallback    

            setMachineLearningFDGBrownFatPETCTFullAIBQMLRTstructCallback();

        case 'setmachinelearningfdgbrownfatpetctfullaisuvrtstructcallback' % setMachineLearningFDGBrownFatPETCTFullAISUVRTstructCallback    

            setMachineLearningFDGBrownFatPETCTFullAISUVRTstructCallback();

        case 'setmachinelearningfdgbrownfatpetctfullainormrtstructcallback' % setMachineLearningFDGBrownFatPETCTFullAINormRTstructCallback    

            setMachineLearningFDGBrownFatPETCTFullAINormRTstructCallback();

        % PET/CT CE Loss 

        case 'setmachinelearningfdgbrownfatpetctfullaicebqmlrtstructcallback' % setMachineLearningFDGBrownFatPETCTFullAICEBQMLRTstructCallback    

            setMachineLearningFDGBrownFatPETCTFullAICEBQMLRTstructCallback();

        case 'setmachinelearningfdgbrownfatpetctfullaicesuvrtstructcallback' % setMachineLearningFDGBrownFatPETCTFullAICESUVRTstructCallback    

            setMachineLearningFDGBrownFatPETCTFullAICESUVRTstructCallback();

        case 'setmachinelearningfdgbrownfatpetctfullaicenormrtstructcallback' % setMachineLearningFDGBrownFatPETCTFullAICENormRTstructCallback    

            setMachineLearningFDGBrownFatPETCTFullAICENormRTstructCallback();


        case 'setmachinelearningfdgbrownfatexporttopetnetworkcallback' % setMachineLearningFDGBrownFatExportToPETNetworkCallback.m    

            setMachineLearningFDGBrownFatExportToPETNetworkCallback();

        case 'setmachinelearningfdgbrownfatdatapreprocessingpetcallback' % setMachineLearningFDGBrownFatDataPreProcessingPETCallback.m   

            setMachineLearningFDGBrownFatDataPreProcessingPETCallback();

        case 'setmachinelearningfdgbrownfatexporttopetctnetworkcallback' % setMachineLearningFDGBrownFatExportToPETCTNetworkCallback.m
            setMachineLearningFDGBrownFatExportToPETCTNetworkCallback();

        case 'setmachinelearningfdgbrownfatdatapreprocessingpetctcallback' % setMachineLearningFDGBrownFatDataPreProcessingPETCTCallback.m     

            setMachineLearningFDGBrownFatDataPreProcessingPETCTCallback();

        case 'setmachinelearningfdgbrownfatexporttonetworkcallback' % setMachineLearningFDGBrownFatExportToNetworkCallback.m
            
            setMachineLearningFDGBrownFatExportToNetworkCallback();     

        % PET/CT BAT NEW NETWORK 
        case 'setmachinelearningfdgbatexporttonetworkcallback' % setMachineLearningFDGBATExportToNetworkCallback.m

            setMachineLearningFDGBATExportToNetworkCallback()

        case 'setmachinelearningfdgbatdatapreprocessingcallback' % setMachineLearningFDGBATDataPreProcessingCallback.m

            setMachineLearningFDGBATDataPreProcessingCallback();

        case 'setmachinelearningfdglymphnodesuvcallback' % setMachineLearningFDGLymphNodeSUVCallback.m

            setMachineLearningFDGLymphNodeSUVCallback();

        case 'setmachinelearningfdhtcallback' % setMachineLearningFDHTCallback.m   

            setMachineLearningFDHTCallback();


        case 'setmachinelearningfullaiga68dotatatecallback' % setMachineLearningFullAIGa68DOTATATECallback.m

            setMachineLearningFullAIGa68DOTATATECallback();
        

        case 'setmachinelearningga68dotatatecallback' % setMachineLearningGa68DOTATATECallback.m

            setMachineLearningGa68DOTATATECallback();


        case 'setmachinelearninglu177callback' % setMachineLearningLu177Callback.m

            setMachineLearningLu177Callback();


        case 'setmachinelearningpetliverdosimetrycallback' % setMachineLearningPETLiverDosimetryCallback.m

            setMachineLearningPETLiverDosimetryCallback();

        case 'writeroistodicommaskclosefigurecallback' % writeRoisToDicomMaskCloseFigureCallback.m

            writeRoisToDicomMaskCloseFigureCallback();

        % Metastatic Breast Cancer

        case  'setmetastaticbreastcancersegmentationcallback' % setMetastaticBreastCancerSegmentationCallback.m

            setMetastaticBreastCancerSegmentationCallback();

        case 'setmachinelearningbreastcancerpetfullaicallback' % setMachineLearningBreastCancerPETFullAICallback.m

            setMachineLearningBreastCancerPETFullAICallback();

        case 'setmachinelearningbreastcancerpetctfullaicallback' % setMachineLearningBreastCancerPETCTFullAICallback.m

            setMachineLearningBreastCancerPETCTFullAICallback();

        case'setmachinelearningbreastcancerexporttopetnetworkcallback' % setMachineLearningBreastCancerExportToPETNetworkCallback.m 

            setMachineLearningBreastCancerExportToPETNetworkCallback();

        case 'setmachinelearningbreastcancerdatapreprocessingpetcallback' % setMachineLearningBreastCancerDataPreProcessingPETCallback.m  

            setMachineLearningBreastCancerDataPreProcessingPETCallback();

        case 'setmachinelearningbreastcancerexporttopetctnetworkcallback' % setMachineLearningBreastCancerExportToPETCTNetworkCallback.m  

            setMachineLearningBreastCancerExportToPETCTNetworkCallback();

        case 'setmachinelearningbreastcancerdatapreprocessingpetctcallback' % setMachineLearningBreastCancerDataPreProcessingPETCTCallback.m  

            setMachineLearningBreastCancerDataPreProcessingPETCTCallback();            

        % PSMA Ga68 

        case 'setmachinelearningpsmaga68datapreprocessingpetcallback' % setMachineLearningPSMAGa68DataPreProcessingPETCallback.m

            setMachineLearningPSMAGa68DataPreProcessingPETCallback();

        case 'setmachinelearningpsmaga68datapreprocessingpetctcallback' % setMachineLearningPSMAGa68DataPreProcessingPETCTCallback.m            

            setMachineLearningPSMAGa68DataPreProcessingPETCTCallback();

        case 'setmachinelearningpsmaga68exporttopetctnetworkcallback' % setMachineLearningPSMAGa68ExportToPETCTNetworkCallback.m

            setMachineLearningPSMAGa68ExportToPETCTNetworkCallback();

        case 'setmachinelearningpsmaga68exporttopetnetworkcallback' % setMachineLearningPSMAGa68ExportToPETNetworkCallback.m

            setMachineLearningPSMAGa68ExportToPETNetworkCallback();

        case 'setmachinelearningpsmaga68petfullaicallback' % setMachineLearningPSMAGa68PETFullAICallback.m

            setMachineLearningPSMAGa68PETFullAICallback();

        case 'setmachinelearningpsmaga68petctfullaicallback' % setMachineLearningPSMAGa68PETCTFullAICallback.m
     
            setMachineLearningPSMAGa68PETCTFullAICallback();

        % PSMA Lu177 

        case 'setmachinelearningpsmalu177datapreprocessingspectctcallback' % setMachineLearningPSMALu177DataPreProcessingSPECTCTCallback.m

            setMachineLearningPSMALu177DataPreProcessingSPECTCTCallback();

        case 'setmachinelearningpsmalu177datapreprocessingspectcallback' % setMachineLearningPSMALu177DataPreProcessingSPECTCallback.m

            setMachineLearningPSMALu177DataPreProcessingSPECTCallback();

        case 'setmachinelearningpsmalu177exporttospectctnetworkcallback' % setMachineLearningPSMALu177ExportToSPECTCTNetworkCallback.m

            setMachineLearningPSMALu177ExportToSPECTCTNetworkCallback();

        case 'setmachinelearningpsmalu177exporttospectnetworkcallback' % setMachineLearningPSMALu177ExportToSPECTNetworkCallback.m

            setMachineLearningPSMALu177ExportToSPECTNetworkCallback();

        case 'setmachinelearningpsmalu177spectfullaicallback' % setMachineLearningPSMALu177SPECTFullAICallback.m

            setMachineLearningPSMALu177SPECTFullAICallback();

        case 'setmachinelearningpsmalu177spectctfullaicallback' % setMachineLearningPSMALu177SPECTCTFullAICallback.m

            setMachineLearningPSMALu177SPECTCTFullAICallback();

        case 'machinelearningctanonymizationcallback' % machineLearningCTAnonymizationCallback.m

            machineLearningCTAnonymizationCallback();
        
        case 'runpsmalu177spectfullaicallback'% runPSMALu177SPECTFullAICallback.m

            runPSMALu177SPECTFullAICallback();

        case 'runpsmaga68petctfullaicallback'% runPSMAGa68PETCTFullAICallback.m
            
            runPSMAGa68PETCTFullAICallback();  

        case 'runfdgbrownfatpetctfullaicallback'% runFDGBrownFatPETCTFullAICallback.m
            
            runFDGBrownFatPETCTFullAICallback();  

        case 'setvoifatmetricsanalyzerforpetctcallback' % setVOIFatMetricsAnalyzerForPETCTCallback.m    
            setVOIFatMetricsAnalyzerForPETCTCallback();
        
        case 'createtumorablationzonecallback' % createTumorAblationZoneCallback.m
            createTumorAblationZoneCallback();

        case 'createlivertumorzoningcallback' % createLiverTumorZoningCallback.m
            createLiverTumorZoningCallback();

        case 'normalliverlobedratiocallback' % normalLiverLobedRatioCallback.m
            normalLiverLobedRatioCallback();     
    end

end