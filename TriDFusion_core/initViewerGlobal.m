function initViewerGlobal()
%function initViewerGlobal()
%Init All Global Get/Set Functions.
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

    axePtr ('set', '');
    axefPtr('set', '');

    axes1Ptr ('set', '');
    axes1fPtr('set', '');
    axes2Ptr ('set', '');
    axes2fPtr('set', '');
    axes3Ptr ('set', '');
    axes3fPtr('set', '');

    imAxePtr ('set', '');
    imAxeFPtr('set', '');

    imCoronalPtr ('set', '');
    imSagittalPtr('set', '');
    imAxialPtr   ('set', '');

    imCoronalFPtr ('set', '');
    imSagittalFPtr('set', '');   
    imAxialFPtr   ('set', '');

    fiMainWindowPtr       ('set', '');
    uiTopWindowPtr        ('set', '');
    uiSegMainPanelPtr     ('set', '');
    uiSegPanelSliderPtr   ('set', '');
    uiSegPanelPtr         ('set', '');    
    uiKernelMainPanelPtr  ('set', '');
    uiKernelPanelSliderPtr('set', ''); 
    uiKernelPanelPtr      ('set', '');
    uiMain3DPanelPtr      ('set', '');
    ui3DPanelPtr          ('set', '');
    ui3DPanelSliderPtr    ('set', '');

    btn3DPtr         ('set', '');
    btnIsoSurfacePtr ('set', '');
    btnMIPPtr        ('set', '');
    btnTriangulatePtr('set', '');
    btnPanPtr        ('set', '');
    btnZoomPtr       ('set', '');
    btnRegisterPtr   ('set', '');
    btnVsplashPtr    ('set', '');
    uiEditVsplahXPtr ('set', '');
    uiEditVsplahYPtr ('set', '');
    btnFusionPtr     ('set', '');

    uiOneWindowPtr('set', '');
    uiCorWindowPtr('set', '');
    uiSliderCorPtr('set', '');
    uiSagWindowPtr('set', '');
    uiSliderSagPtr('set', '');
    uiTraWindowPtr('set', '');
    uiSliderTraPtr('set', '');

    uiSeriesPtr('set', '');
    uiFusedSeriesPtr('set', '');    

    uiSliderWindowPtr('set', '');
    uiSliderLevelPtr ('set', '');
    uiColorbarPtr    ('set', '');   

    uiFusionSliderWindowPtr('set', '');
    uiFusionSliderLevelPtr ('set', '');
    uiAlphaSliderPtr       ('set', '');
    uiFusionColorbarPtr    ('set', '');

    uiProgressWindowPtr('set', '');
    uiBarPtr('set', '');

    dicomMetaData('reset');    
    dicomBuffer  ('reset');    
    fusionBuffer ('reset');    
    inputBuffer  ('set', '');    

    mainDir     ('set', '');
    roiTemplate ('set', '');
    voiTemplate ('set', '');

    volObject('set', '');                       
    isoObject('set', '');    
    mipObject('set', ''); 
    voiObject('set', '');

    volFusionObject('set', '');                       
    isoFusionObject('set', '');    
    mipFusionObject('set', ''); 
    
    voiGateObject('set', '');
    ui3DGateWindowObject('set', '');
    ui3DLogoObject('set', '');

    volumeScaleFator('set', 'x', 1);
    volumeScaleFator('set', 'y', 1);
    volumeScaleFator('set', 'z', 1);

    volGateObject('set', '');                       
    isoGateObject('set', '');    
    mipGateObject('set', '');
    
    volGateFusionObject('set', '');                       
    isoGateFusionObject('set', '');    
    mipGateFusionObject('set', '');
    
    isDoseKernel   ('set', false);
    isFusion       ('set', false);
    isVsplash      ('set', false);
    init3DPanel    ('set', true );
    view3DPanel    ('set', false);
    viewSegPanel   ('set', false);
    viewKernelPanel('set', false);

    optionsPanelMenuObject   ('set', '');     
    viewRoiObject            ('set', '');    
    viewSegPanelMenuObject   ('set', '');
    viewKernelPanelMenuObject('set', '');
    view3DPanelMenuObject    ('set', '');
    playIconMenuObject       ('set', '');
    recordIconMenuObject     ('set', '');
    gateIconMenuObject       ('set', '');
    viewPlaybackObject       ('set', '');
    playbackMenuObject       ('set', '');
    roiMenuObject            ('set', '');

    volICObject('set', '');
    mipICObject('set', '');    
    volICFusionObject('set', '');
    mipICFusionObject('set', '');  
    
    mipColorObject('set', '');
    volColorObject('set', '');

    logoObject('set', '');

    voiRoiSegObject('set', '');
    voiRoiActObject('set', '');

    chkVoiRoiSubstractObject       ('set', '');   
    editVoiRoiUpperTresholdObject  ('set', '');
    sliderVoiRoiUpperTresholdObject('set', '');
    txtVoiRoiUpperTresholdObject   ('set', '');  
    
    ui3DVolumePtr('set', '');   
    
    viewerRootPath('set', './');
    
end