function sRadionuclide = displayPeriodicTable(pParentUi)
%function sRadionuclide = displayPeriodicTable(pParentUi)
%Display a periodic table and return the selected radionuclide.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Note: 
%   This function performs a specific task using elements from the
%   pre-existing function periodic_table created by [Kevin Hellemans].
%Options can be strings, cell arrays of strings, or numerical arrays.
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
%

% function created by Kevin Hellemans

    alParentUiPosition = get(pParentUi, 'Position');

    sRadionuclide = [];
    
    DLG_PERIODIC_TABLE_X = 700;
    DLG_PERIODIC_TABLE_Y = 400;

    if alParentUiPosition(3) < DLG_PERIODIC_TABLE_X
        DLG_PERIODIC_TABLE_X = getMainWindowSize('xsize');
    end

    if alParentUiPosition(4) < DLG_PERIODIC_TABLE_Y
        DLG_PERIODIC_TABLE_Y = getMainWindowSize('ysize');
    end
   
    dlgPeriodicTable = ...
        dialog('Position', [(alParentUiPosition(1)+(alParentUiPosition(3)/2)-DLG_PERIODIC_TABLE_X/2) ...
                            (alParentUiPosition(2)+(alParentUiPosition(4)/2)-DLG_PERIODIC_TABLE_Y/2) ...
                            DLG_PERIODIC_TABLE_X ...
                            DLG_PERIODIC_TABLE_Y ...
                            ],...
               'MenuBar'    , 'none',...
               'Resize'     , 'on', ...    
               'NumberTitle', 'off',...
               'MenuBar'    , 'none',...
               'Color'      , [0.95 0.95 0.95], ...
               'Name'       , 'Periodic Table',...
               'Toolbar'    , 'none'...               
               );   

    createTable(dlgPeriodicTable);

    arrayfun(@createElement, get(dlgPeriodicTable,'Children'));

    uiwait(dlgPeriodicTable);

    function elementSelectionCallback (~, ~)
            
        if ~isequal(get(gcbo,'Color'), [1 1 0])

            set(gcbo,'Color', [1 1 0]);

            sSelectedElement = get(gcbo,'Tag');
                
            sMassNumber = getMassNumber(sSelectedElement); 

            if ~isempty(sMassNumber)

                sRadionuclide = sprintf('%s-%s', sSelectedElement, sMassNumber);

                delete(dlgPeriodicTable);

            else
                set(gcbo,'Color', [0.8 0.9 0.9])
            end

        else
            set(gcbo,'Color', [0.8 0.9 0.9])
        end
    
    end  
    
    function createElement(input_handle)

        string = get(input_handle,'Tag');

        set(input_handle, ...
            'XTick'        , [], ...
            'YTick'        , [], ...
            'ButtonDownFcn', @elementSelectionCallback, ...
            'XLim'         , [0 1], ...
            'YLim'         , [0 1], ...
            'Box'          , 'on', ...
            'Color'        , [0.8 0.9 0.9]);
              
    
        text(0.5,0.5, ...
             string, ...
             'Parent'             ,input_handle, ...
             'FontSize'           ,12, ...
             'FontUnits'          ,'normalized',...
             'Units','normalized' , ...
             'HorizontalAlignment','center',...
             'VerticalAlignment'  ,'middle', ...
             'HitTest'            ,'off');
    end

    function createTable(pt)

       axes('Parent',pt,'Position', [0.05 0.85 0.04 0.09],'Tag','H');
       axes('Parent',pt,'Position', [0.05 0.75 0.04 0.09],'Tag','Li');
       axes('Parent',pt,'Position', [0.05 0.65 0.04 0.09],'Tag','Na');
       axes('Parent',pt,'Position', [0.05 0.55 0.04 0.09],'Tag','K');
       axes('Parent',pt,'Position', [0.05 0.45 0.04 0.09],'Tag','Rb');
       axes('Parent',pt,'Position', [0.05 0.35 0.04 0.09],'Tag','Cs');
       axes('Parent',pt,'Position', [0.05 0.25 0.04 0.09],'Tag','Fr');
       axes('Parent',pt,'Position', [0.1 0.75 0.04 0.09],'Tag','Be');
       axes('Parent',pt,'Position', [0.1 0.65 0.04 0.09],'Tag','Mg');
       axes('Parent',pt,'Position', [0.1 0.55 0.04 0.09],'Tag','Ca');
       axes('Parent',pt,'Position', [0.1 0.45 0.04 0.09],'Tag','Sr');
       axes('Parent',pt,'Position', [0.1 0.35 0.04 0.09],'Tag','Ba');
       axes('Parent',pt,'Position', [0.1 0.25 0.04 0.09],'Tag','Ra');   
       axes('Parent',pt,'Position', [0.15 0.55 0.04 0.09],'Tag','Sc');
       axes('Parent',pt,'Position', [0.2 0.55 0.04 0.09],'Tag','Ti');
       axes('Parent',pt,'Position', [0.25 0.55 0.04 0.09],'Tag','V');
       axes('Parent',pt,'Position', [0.3 0.55 0.04 0.09],'Tag','Cr');
       axes('Parent',pt,'Position', [0.35 0.55 0.04 0.09],'Tag','Mn');
       axes('Parent',pt,'Position', [0.4 0.55 0.04 0.09],'Tag','Fe');   
       axes('Parent',pt,'Position', [0.45 0.55 0.04 0.09],'Tag','Co');
       axes('Parent',pt,'Position', [0.5 0.55 0.04 0.09],'Tag','Ni');
       axes('Parent',pt,'Position', [0.55 0.55 0.04 0.09],'Tag','Cu');
       axes('Parent',pt,'Position', [0.6 0.55 0.04 0.09],'Tag','Zn');
       axes('Parent',pt,'Position', [0.65 0.55 0.04 0.09],'Tag','Ga');
       axes('Parent',pt,'Position', [0.7 0.55 0.04 0.09],'Tag','Ge');
       axes('Parent',pt,'Position', [0.75 0.55 0.04 0.09],'Tag','As');
       axes('Parent',pt,'Position', [0.8 0.55 0.04 0.09],'Tag','Se');
       axes('Parent',pt,'Position', [0.85 0.55 0.04 0.09],'Tag','Br');
       axes('Parent',pt,'Position', [0.9 0.55 0.04 0.09],'Tag','Kr');   
       axes('Parent',pt,'Position', [0.15 0.45 0.04 0.09],'Tag','Y');
       axes('Parent',pt,'Position', [0.2 0.45 0.04 0.09],'Tag','Zr');
       axes('Parent',pt,'Position', [0.25 0.45 0.04 0.09],'Tag','Nb');
       axes('Parent',pt,'Position', [0.3 0.45 0.04 0.09],'Tag','Mo');
       axes('Parent',pt,'Position', [0.35 0.45 0.04 0.09],'Tag','Tc');
       axes('Parent',pt,'Position', [0.4 0.45 0.04 0.09],'Tag','Ru');   
       axes('Parent',pt,'Position', [0.45 0.45 0.04 0.09],'Tag','Rh');
       axes('Parent',pt,'Position', [0.5 0.45 0.04 0.09],'Tag','Pd');
       axes('Parent',pt,'Position', [0.55 0.45 0.04 0.09],'Tag','Ag');
       axes('Parent',pt,'Position', [0.6 0.45 0.04 0.09],'Tag','Cd');
       axes('Parent',pt,'Position', [0.65 0.45 0.04 0.09],'Tag','In');
       axes('Parent',pt,'Position', [0.7 0.45 0.04 0.09],'Tag','Sn');
       axes('Parent',pt,'Position', [0.75 0.45 0.04 0.09],'Tag','Sb');
       axes('Parent',pt,'Position', [0.8 0.45 0.04 0.09],'Tag','Te');
       axes('Parent',pt,'Position', [0.85 0.45 0.04 0.09],'Tag','I');
       axes('Parent',pt,'Position', [0.9 0.45 0.04 0.09],'Tag','Xe');
       axes('Parent',pt,'Position', [0.15 0.35 0.04 0.09],'Tag','La');
       axes('Parent',pt,'Position', [0.2 0.35 0.04 0.09],'Tag','Hf');
       axes('Parent',pt,'Position', [0.25 0.35 0.04 0.09],'Tag','Ta');
       axes('Parent',pt,'Position', [0.3 0.35 0.04 0.09],'Tag','W');
       axes('Parent',pt,'Position', [0.35 0.35 0.04 0.09],'Tag','Re');
       axes('Parent',pt,'Position', [0.4 0.35 0.04 0.09],'Tag','Os');   
       axes('Parent',pt,'Position', [0.45 0.35 0.04 0.09],'Tag','Ir');
       axes('Parent',pt,'Position', [0.5 0.35 0.04 0.09],'Tag','Pt');
       axes('Parent',pt,'Position', [0.55 0.35 0.04 0.09],'Tag','Au');
       axes('Parent',pt,'Position', [0.6 0.35 0.04 0.09],'Tag','Hg');
       axes('Parent',pt,'Position', [0.65 0.35 0.04 0.09],'Tag','Tl');
       axes('Parent',pt,'Position', [0.7 0.35 0.04 0.09],'Tag','Pb');
       axes('Parent',pt,'Position', [0.75 0.35 0.04 0.09],'Tag','Bi');
       axes('Parent',pt,'Position', [0.8 0.35 0.04 0.09],'Tag','Po');
       axes('Parent',pt,'Position', [0.85 0.35 0.04 0.09],'Tag','At');
       axes('Parent',pt,'Position', [0.9 0.35 0.04 0.09],'Tag','Rn');
       axes('Parent',pt,'Position', [0.15 0.25 0.04 0.09],'Tag','Ac');
       axes('Parent',pt,'Position', [0.65 0.75 0.04 0.09],'Tag','B');
       axes('Parent',pt,'Position', [0.7 0.75 0.04 0.09],'Tag','C');
       axes('Parent',pt,'Position', [0.75 0.75 0.04 0.09],'Tag','N');
       axes('Parent',pt,'Position', [0.8 0.75 0.04 0.09],'Tag','O');
       axes('Parent',pt,'Position', [0.85 0.75 0.04 0.09],'Tag','F');
       axes('Parent',pt,'Position', [0.9 0.75 0.04 0.09],'Tag','Ne');
       axes('Parent',pt,'Position', [0.65 0.65 0.04 0.09],'Tag','Al');
       axes('Parent',pt,'Position', [0.7 0.65 0.04 0.09],'Tag','Si');
       axes('Parent',pt,'Position', [0.75 0.65 0.04 0.09],'Tag','P');
       axes('Parent',pt,'Position', [0.8 0.65 0.04 0.09],'Tag','S');
       axes('Parent',pt,'Position', [0.85 0.65 0.04 0.09],'Tag','Cl');
       axes('Parent',pt,'Position', [0.9 0.65 0.04 0.09],'Tag','Ar');
       axes('Parent',pt,'Position', [0.9 0.85 0.04 0.09],'Tag','He');
       axes('Parent',pt,'Position', [0.25 0.2 0.04 0.09],'Tag','Ce');
       axes('Parent',pt,'Position', [0.3 0.2 0.04 0.09],'Tag','Pr');
       axes('Parent',pt,'Position', [0.35 0.2 0.04 0.09],'Tag','Nd');
       axes('Parent',pt,'Position', [0.4 0.2 0.04 0.09],'Tag','Pm');
       axes('Parent',pt,'Position', [0.45 0.2 0.04 0.09],'Tag','Sm');
       axes('Parent',pt,'Position', [0.5 0.2 0.04 0.09],'Tag','Eu');
       axes('Parent',pt,'Position', [0.55 0.2 0.04 0.09],'Tag','Gd');
       axes('Parent',pt,'Position', [0.6 0.2 0.04 0.09],'Tag','Tb');
       axes('Parent',pt,'Position', [0.65 0.2 0.04 0.09],'Tag','Dy');
       axes('Parent',pt,'Position', [0.7 0.2 0.04 0.09],'Tag','Ho');
       axes('Parent',pt,'Position', [0.75 0.2 0.04 0.09],'Tag','Er');
       axes('Parent',pt,'Position', [0.8 0.2 0.04 0.09],'Tag','Tm');
       axes('Parent',pt,'Position', [0.85 0.2 0.04 0.09],'Tag','Yb');
       axes('Parent',pt,'Position', [0.9 0.2 0.04 0.09],'Tag','Lu');  
       axes('Parent',pt,'Position', [0.25 0.1 0.04 0.09],'Tag','Th');
       axes('Parent',pt,'Position', [0.3 0.1 0.04 0.09],'Tag','Pa');
       axes('Parent',pt,'Position', [0.35 0.1 0.04 0.09],'Tag','U');
       axes('Parent',pt,'Position', [0.4 0.1 0.04 0.09],'Tag','Np');
       axes('Parent',pt,'Position', [0.45 0.1 0.04 0.09],'Tag','Pu');
       axes('Parent',pt,'Position', [0.5 0.1 0.04 0.09],'Tag','Am');
       axes('Parent',pt,'Position', [0.55 0.1 0.04 0.09],'Tag','Cm');
       axes('Parent',pt,'Position', [0.6 0.1 0.04 0.09],'Tag','Bk');
       axes('Parent',pt,'Position', [0.65 0.1 0.04 0.09],'Tag','Cf');
       axes('Parent',pt,'Position', [0.7 0.1 0.04 0.09],'Tag','Es');
       axes('Parent',pt,'Position', [0.75 0.1 0.04 0.09],'Tag','Fm');
       axes('Parent',pt,'Position', [0.8 0.1 0.04 0.09],'Tag','Md');
       axes('Parent',pt,'Position', [0.85 0.1 0.04 0.09],'Tag','No');
       axes('Parent',pt,'Position', [0.9 0.1 0.04 0.09],'Tag','Lr');

    end

    function sMassNumber = getMassNumber(sRadionuclide) 

        sMassNumber = [];

        acString = [];

        Ac = {'223','224','225','226','227','228','230','231','232','233'};
        Ag = {'100m','101','102','102m','103','104','104m','105','105m','106','106m','108','108m','109m','110','110m','111','111m','112','113','113m','114','115','116','117','99'};
        Al = {'26', '28', '29'};
        Am = {'237','238','239','240','241','242','242m','243','244','244m','245','246','246m','247'};
        Ar = {'37','39','41','42','43','44'};
        As = {'68','69','70','71','72','73','74','76','77','78','79'};
        At = {'204','205','206','207','208','209','210','211','215','216','217','218','219','220'};
        Au = {'186','187','190','191','192','193','193m','194','195','195m','196','196m','198','198m','199','200','200m','201','202'};
        Ba = {'124','126','127','128','129','129m','131','131m','133','133m','135m','137m','139','140','141','142'};
        Be = {'10','7'};
        Bi = {'197','200','201','202','203','204','205','206','207','208','210','210m','211','212','212n','213','214','215','216'};
        Bk = {'245','246','247','248m','249','250','251'};
        Br = {'72','73','74','74m','75','76','76m','77','77m','78','80','80m','82','82m','83','84','84m','85'};
        C  = {'10','11','14'};
        Ca = {'41','45','47','49'};
        Cd = {'101','102','103','104','105','107','109','111m','113','113m','115','115m','117','117m','118','119','119m'};
        Ce = {'130','131','132','133','133m','134','135','137','137m','139','141','143','144','145'};
        Cf = {'244','246','247','248','249','250','251','252','253','254','255'};
        Cl = {'34','34m','36','38','39','40'};
        Cm = {'238','239','240','241','242','243','244','245','246','247','248','249','250','251'};
        Co = {'54m','55','56','57','58','58m','60','60m','61','62','62m'};
        Cr = {'48','49','51','55','56'};
        Cs = {'121','121m','123','124','125','126','127','128','129','130','130m','131','132','134','134m','135','135m','136','137','138','138m','139','140'};
        Cu = {'57','59','60','61','62','64','66','67','69'};
        Cy = {'148','149','150','151','152','153','154','155','157','159','165','165m','166','167','168'};
        Er = {'154','156','159','161','163','165','167m','169','171','172','173'};
        Es = {'249','250','250m','251','253','254','254m','255','256'};
        Eu = {'142','142m','143','144','145','146','147','148','149','150','150m','152','152m','152n','154','154m','155','156','157','158','159'};
        F  = {'17','18'};
        Fe = {'52','53','53m','55','59','60','61','62'};
		Fm = {'251','252','253','254','255','256','257'};
		Fr = {'212','219','220','221','222','223','224','227'};
		Ga = {'64','65','66','67','68','70','72','73','74'};
		Gd = {'142','143m','144','145','145m','146','147','148','149','150','151','152','153','159','162'};
		Ge = {'66','67','68','69','71','75','77','78'};
		H =  {'3'};
		Hf = {'167','169','170','172','173','174','175','177m','178m','179m','180m','181','182','182m','183','184'};
		Hg = {'190','191m','192','193','193m','194','195','195m','197','197m','199m','203','205','206','207'};
		Ho = {'150','153','153m','154','154m','155','156','157','159','160','161','162','162m','163','164','164m','166','166m','167','168','168m','170'};
		I  = {'118','118m','119','120','120m','121','122','123','124','125','126','128','129','130','130m','131','132','132m','133','134','134m','135'};		
		In = {'103','105','106','106m','107','108','108m','109','109m','110','110m','111','111m','112','112m','113m','114','114m','115','115m','116m','117','117m','118','118m','119','119m','121','121m'};
		Ir = {'180','182','183','184','185','186','186m','187','188','189','190','190m','190n','191m','192','192m','192n','193m','194','194m','195','195m','196','196m'};
		K  = {'38','40','42','43','44','45','46'};
		Kr = {'74','75','76','77','79','81','81m','83m','85','85m','87','88','89'};
		La = {'128','129','130','131','132','132m','133','134','135','136','137','138','140','141','142','143'};
		Lu = {'165','167','169','169m','170','171','171m','172','172m','173','174','174m','176','176m','177','177m','178','178m','179','180','181'};
		Mg = {'27','28'};
		Mn = {'50m','51','52','52m','53','54','56','57','58m'};
		Mo = {'101','102','89','90','91','91m','93','93m','99'};
		N =  {'13','16'};
		Na = {'22','24'};
		Nb = {'87','88','88m','89','89m','90','91','91m','92','92m','93m','94','94m','95','95m','96','97','98m','99','99m'};
		Nd = {'134','135','136','137','138','139','139m','140','141','141m','144','147','149','151','152'};
		Ne = {'19','24'};
		Ni = {'56','57','59','63','65','66'};
		Np = {'232','233','234','235','236','236m','237','238','239','240','240m','241','242','242m'};
		O  = {'14','15','19'};
		Os = {'180','181','182','183','183m','185','186','189m','190m','191','191m','193','194','196'};
		P  = {'30','32','33'};
		Pa = {'227','228','229','230','231','232','233','234','234m','235','236','237'};
		Pb = {'194','195m','196','197','197m','198','199','200','201','201m','202','202m','203','204m','205','209','210','211','212','214'};
		Pd = {'100','101','103','107','109','109m','111','112','114','96','97','98','99'};
		Pm = {'136','137m','139','140','140m','141','142','143','144','145','146','147','148','148m','149','150','151','152','152m','153','154','154m'};
		Po = {'203','204','205','206','207','208','209','210','211','212','212m','213','214','215','216','218'};
		Pr = {'134','134m','135','136','137','138','138m','139','140','142','142m','143','144','144m','145','146','147','148','148m'};
		Pt = {'184','186','187','188','189','190','191','193','193m','195m','197','197m','199','200','202'};
		Pu = {'232','234','235','236','237','238','239','240','241','242','243','244','245','246'};
		Ra = {'219','220','221','222','223','224','225','226','227','228','230'};
		Rb = {'77','78','78m','79','80','81','81m','82','82m','83','84','84m','86','86m','87','88','89','90','90m'};
		Re = {'178','179','180','181','182','182m','183','184','184m','186','186m','187','188','188m','189','190','190m'};
		Rh = {'100','100m','101','101m','102','102m','103m','104','104m','105','106','106m','107','108','109','94','95','95m','96','96m','97','97m','98','99','99m'};
		Rn = {'207','209','210','211','212','215','216','217','218','219','220','222','223'};
		Ru = {'103','105','106','107','108','92','94','95','97'};
		S  = {'35','37','38'};
		Sb = {'111','113','114','115','116','116m','117','118','118m','119','120','120m','122','122m','124','124m','124n','125','126','126m','127','128','128m','129','130','130m','131','133'};
		Sc = {'42m','43','44','44m','46','47','48','49','50'};
		Se = {'70','71','72','73','73m','75','77m','79','79m','81','81m','83','83m','84'};
		Si = {'31','32'};
		Sm = {'139','140','141','141m','142','143','143m','145','146','147','148','151','153','155','156','157'};
		Sn = {'106','108','109','110','111','113','113m','117m','119m','121','121m','123','123m','125','125m','126','127','127m','128','129','130','130m'};
		Sr = {'79','80','81','82','83','85','85m','87m','89','90','91','92','93','94'};
		Ta = {'170','172','173','174','175','176','177','178','178m','179','180','182','182m','183','184','185','186'};
		Tb = {'146','147','147m','148','148m','149','149m','150','150m','151','151m','152','152m','153','154','155','156','156m','156n','157','158','160','161','162','163','164','165'};
		Tc = {'101','102','102m','104','105','91','91m','92','93','93m','94','94m','95','95m','96','96m','97','97m','98','99','99m'};
		Te = {'113','114','115','115m','116','117','118','119','119m','121','121m','123','123m','125m','127','127m','129','129m','131','131m','132','133','133m','134'};
		Th = {'223','224','226','227','228','229','230','231','232','233','234','235','236'};
		Ti = {'44','45','51','52'};
		Tl = {'190','190m','194','194m','195','196','197','198','198m','199','200','201','202','204','206','206m','207','208','209','210'};
		Tm = {'161','162','163','164','165','166','167','168','170','171','172','173','174','175','176'};
		U  = {'227','228','230','231','232','233','234','235','235m','236','237','238','239','240','242'};
		V  = {'47','48','49','50','52','53'};
		W  = {'177','178','179','179m','181','185','185m','187','188','190'};
		Xe = {'120','121','122','123','125','127','127m','129m','131m','133','133m','135','135m','137','138'};
		Y  = {'81','83','83m','84m','85','85m','86','86m','87','87m','88','89m','90','90m','91','91m','92','93','94','95'};
		Yb = {'162','163','164','165','166','167','169','175','177','178','179'};
		Zn = {'60','61','62','63','65','69','69m','71','71m','72'};
		Zr = {'85','86','87','88','89','89m','93','95','97'};

        switch sRadionuclide

            case 'Ac', acString = Ac;  			  
            case 'Ag', acString = Ag;
			case 'Al', acString = Al;
			case 'Am', acString = Am;
			case 'Ar', acString = Ar;
			case 'As', acString = As;
			case 'At', acString = At;
			case 'Au', acString = Au;
			case 'Ba', acString = Ba;
			case 'Be', acString = Be;
			case 'Bi', acString = Bi;
			case 'Bk', acString = Bk;
			case 'Br', acString = Br;
			case 'C' , acString = C;
			case 'Ca', acString = Ca;
			case 'Cd', acString = Cd;
			case 'Ce', acString = Ce;
			case 'Cf', acString = Cf;
			case 'Cl', acString = Cl;
			case 'Cm', acString = Cm;
			case 'Co', acString = Co;
			case 'Cr', acString = Cr;
			case 'Cs', acString = Cs;
			case 'Cu', acString = Cu;
			case 'Cy', acString = Cy;
			case 'Er', acString = Er;
			case 'Es', acString = Es;
			case 'Eu', acString = Eu;
			case 'F' , acString = F;
			case 'Fe', acString = Fe;
			case 'Fm', acString = Fm;
			case 'Fr', acString = Fr;
			case 'Ga', acString = Ga;
			case 'Gd', acString = Gd;
			case 'Ge', acString = Ge;
			case 'H' , acString = H;
			case 'Hf', acString = Hf;
			case 'Hg', acString = Hg;
			case 'Ho', acString = Ho;
			case 'I' , acString = I;
			case 'In', acString = In;
			case 'Ir', acString = Ir;
			case 'K ', acString = K ;
			case 'Kr', acString = Kr;
			case 'La', acString = La;
			case 'Lu', acString = Lu;
			case 'Mg', acString = Mg;
			case 'Mn', acString = Mn;
			case 'Mo', acString = Mo;
			case 'N' , acString = N;
			case 'Na', acString = Na;
			case 'Nb', acString = Nb;
			case 'Nd', acString = Nd;
			case 'Ne', acString = Ne;
			case 'Ni', acString = Ni;
			case 'Np', acString = Np;
			case 'O' , acString = O;
			case 'Os', acString = Os;
			case 'P' , acString = P;
			case 'Pa', acString = Pa;
			case 'Pb', acString = Pb;
			case 'Pd', acString = Pd;
			case 'Pm', acString = Pm;
			case 'Po', acString = Po;
			case 'Pr', acString = Pr;
			case 'Pt', acString = Pt;
			case 'Pu', acString = Pu;
			case 'Ra', acString = Ra;
			case 'Rb', acString = Rb;
			case 'Re', acString = Re;
			case 'Rh', acString = Rh;
			case 'Rn', acString = Rn;
			case 'Ru', acString = Ru;
			case 'S' , acString = S;
			case 'Sb', acString = Sb;
			case 'Sc', acString = Sc;
			case 'Se', acString = Se;
			case 'Si', acString = Si;
			case 'Sm', acString = Sm;
			case 'Sn', acString = Sn;
			case 'Sr', acString = Sr;
			case 'Ta', acString = Ta;
			case 'Tb', acString = Tb;
			case 'Tc', acString = Tc;
			case 'Te', acString = Te;
			case 'Th', acString = Th;
			case 'Ti', acString = Ti;
			case 'Tl', acString = Tl;
			case 'Tm', acString = Tm;
			case 'U' , acString = U;
			case 'V' , acString = V;
			case 'W' , acString = W;
			case 'Xe', acString = Xe;
			case 'Y' , acString = Y;
			case 'Yb', acString = Yb;
			case 'Zn', acString = Zn;
			case 'Zr', acString = Zr;
        end

        if ~isempty(acString)

            % Display a list dialog
    
            dMassNumber = ...
                listdlg('PromptString' , 'Select a mass:', ...
                        'SelectionMode', 'single', ...
                        'ListString'   , acString, ...
                        'Name'         , 'Select a mass', ...
                        'CancelString' , 'Cancel');

            if ~isempty(dMassNumber)
                
                sMassNumber = acString{dMassNumber};
            end
        end

    end

end