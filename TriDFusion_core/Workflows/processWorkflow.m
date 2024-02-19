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
        

        % Modules

        case 'setmachinelearning3dlungshuntcallback' % setMachineLearning3DLungShuntCallback.m 

            setMachineLearning3DLungShuntCallback();
        

        case 'setmachinelearning3dlobelungcallback' % setMachineLearning3DLobeLungCallback.m   

            setMachineLearning3DLobeLungCallback(); 


        case 'setmachinelearningfdgbrownfatsuvcallback' % setMachineLearningFDGBrownFatSUVCallback.m

            setMachineLearningFDGBrownFatSUVCallback();
            
        case 'setmachinelearningfdgbrownfatsuvrt_structurecallback' % setMachineLearningFDGBrownFatSUVRT_structureCallback.m

            setMachineLearningFDGBrownFatSUVRT_structureCallback();


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



    end

end