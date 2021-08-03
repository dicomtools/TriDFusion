function setMathCallback(~, ~)
%function setMathCallback(~, ~)
%Set Mathematic Main Function.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2021, Daniel Lafontaine, on behalf of the TriDFusion development team.
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

    if numel(dicomBuffer('get')) < 1
        return;
    end    
    
    dlgMathematic = ...
        dialog('Position', [(getMainWindowPosition('xpos')+(getMainWindowSize('xsize')/2)-810/2) ...
                            (getMainWindowPosition('ypos')+(getMainWindowSize('ysize')/2)-570/2) ...
                            810 ...
                            570 ...
                            ],...
               'Color', viewerBackgroundColor('get'),...
               'Name' , 'Mathematic'...
               );
           
        uicontrol(dlgMathematic,...
                  'String','Reset',...
                  'Position',[15 525 100 25],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @resetMathematicCallback...
                  );
              
     chkMathSeriesDescription = ...
          uicontrol(dlgMathematic,...
                  'style'   , 'checkbox',...
                  'enable'  , 'on',...
                  'value'   , updateDescription('get'),...
                  'position', [180 475 20 20],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @updateMathDescriptionCallback...
                  );

          uicontrol(dlgMathematic,...
                  'style'   , 'text',...
                  'FontWeight', 'bold',...
                  'string'  , 'Update Description',...
                  'horizontalalignment', 'left',...
                  'position', [15 472 160 20],...
                  'Enable', 'Inactive',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'ButtonDownFcn', @updateMathDescriptionCallback...
                  );
              
          uicontrol(dlgMathematic,...
                  'style'   , 'text',...
                  'FontWeight', 'bold',...
                  'string'  , 'Instruction:',...
                  'horizontalalignment', 'left',...
                  'position', [15 425 310 20],...
                  'Enable', 'Inactive',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get') ...
                  );
              
    asText{1}  = '1- Select the serie(s)';
    asText{2}  = '2- Input the equation (case sensitive)';
    asText{3}  = '3- Execute';
    asText{4}  = ' ';
    asText{5}  = 'Equation example:';
    asText{6}  = ' ';
    asText{7}  = 'a=a+b';
    asText{8}  = 'b=a-b';
    asText{9}  = 'a=a+b;b=a-b';
    asText{10} = ' ';
    asText{11} = 'a=sqrt(a*b)';
    asText{12} = 'a=sqrt(a^3*b^3*c^3)';
    asText{13} = ' ';
    asText{14} = 'a=log(a)*log(b)';

    pos = [15 205 310 20];
    txtMathWindow = ...
        uicontrol(dlgMathematic,...
                  'style'   , 'text',...
                  'string'  , asText,...
                  'horizontalalignment', 'left',...
                  'position', pos,...
                  'Enable', 'Inactive',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get') ...
                  );

    [outstring,newpos] = textwrap(txtMathWindow,asText);
    pos(4) = newpos(4);
    set(txtMathWindow,'String',outstring,'Position',[pos(1),pos(2),pos(3)+10,pos(4)])

    lbMathWindow = ...
        uicontrol(dlgMathematic,...
                  'style'   , 'listbox',...
                  'position', [325 0 485 570],...
                  'fontsize', 10,...
                  'Fontname', 'Monospaced',...
                  'Value'   , 1 ,...
                  'Selected', 'on',...
                  'enable'  , 'on',...
                  'string'  , seriesDescription('get'),...
                  'BackgroundColor', viewerAxesColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @lbMathWindowCallback...
                  );
    set(lbMathWindow, 'Max',2, 'Min',0);
    
          uicontrol(dlgMathematic,...
                  'style'   , 'text',...
                  'FontWeight', 'bold',...
                  'string'  , 'Equation:',...
                  'horizontalalignment', 'left',...
                  'position', [15 90 160 20],...
                  'Enable', 'Inactive',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get') ...
                  );
              
    uiMathEquation = ...
         uicontrol(dlgMathematic,...
                  'enable'    , 'on',...
                  'style'     , 'edit',...
                  'Background', 'white',...
                  'string'    , ' ',...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'position'  , [15 65 295 20]...
                  );
              
        uicontrol(dlgMathematic,...
                  'String','Execute',...
                  'Position',[210 30 100 25],...
                  'BackgroundColor', viewerBackgroundColor('get'), ...
                  'ForegroundColor', viewerForegroundColor('get'), ...
                  'Callback', @executeMathCallback...
                  );
              
    adLbSeries = zeros(size(seriesDescription('get')));
    dNextPosition = 1;

    function lbMathWindowCallback(~, ~)
        
        aAlphabet = 'abcdefghijklmnopqrstuvwxyz';
        if numel(seriesDescription('get')) > numel(aAlphabet)
            progressBar(1, sprintf('Error:lbMathWindowCallback() only support up to %d series!', numel(aAlphabet)));           
            delete(dlgMathematic);
            return;
        end

        adLbOffset = get(lbMathWindow,  'Value');
        asLbString = get(lbMathWindow,  'String');
        asSeriesString = seriesDescription('get');

        if numel(adLbOffset) > numel(asLbString) || ...
           isempty(seriesDescription('get'))
            return;
        end

        if numel(adLbOffset) == 0 % No entry
            set(lbMathWindow, 'String', seriesDescription('get'));
            for jj=1:numel(adLbSeries)
                adLbSeries(jj) = 0;
            end
        elseif numel(adLbOffset) == 1 % First Entry
            dLbOffset = adLbOffset(1);

            for jj=1:numel(adLbSeries)
                if jj==dLbOffset
                    adLbSeries(dLbOffset) = 1;
                    asSeriesString{dLbOffset} = sprintf('a = %s', asSeriesString{dLbOffset});
                    dNextPosition = 2;
                else
                    adLbSeries(jj) = 0;
                end
            end

            set(lbMathWindow, 'String', asSeriesString);
        else
            dNbElementCurrent = 1;
            for ll=1:numel(adLbSeries) % Count Number of element are currently set to a position
                if adLbSeries(ll) ~= 0
                    dNbElementCurrent = dNbElementCurrent+1;
                end
            end

            if dNbElementCurrent > numel(adLbOffset) % Substract one position
                adNewSeries = zeros(size(seriesDescription('get')));
                for jj=1:numel(adNewSeries) % Set a new array
                    for kk=1:numel(adLbOffset)
                        if adLbOffset(kk)==jj
                            adNewSeries(jj)=adLbSeries(adLbOffset(kk));
                        end
                    end
                end

                for jj=1:numel(adNewSeries) % Reset all series with 0
                    if adNewSeries(jj) == 0
                        asLbString{jj}=sprintf('%s', asSeriesString{jj});
                    end
                end

                dMissingElement =1;
                for kk=1:numel(adLbSeries(adLbOffset)) % Find the series offset to substract
                    for jj=1:numel(adNewSeries)
                        if adNewSeries(jj) == dMissingElement
                            dMissingElement = dMissingElement+1;
                        end
                    end
                end

                for jj=1:numel(adNewSeries)
                    if adNewSeries(jj) > dMissingElement
                        adNewSeries(jj) = adNewSeries(jj)-1;
                        asLbString{jj}=sprintf('%s = %s', aAlphabet(adNewSeries(jj)), asSeriesString{jj});
                    end
                end

                adLbSeries = adNewSeries;
                dNextPosition = dNextPosition -1;

            else  % Add one position

                for jj=1:numel(adLbOffset)
                    dCurOffset = adLbOffset(jj);
                    for kk=1:numel(asSeriesString)
                        if kk==dCurOffset && ...
                           adLbSeries(kk) == 0

                            adLbSeries(kk) = dNextPosition;
                            asLbString{kk}=sprintf('%s = %s', aAlphabet(adLbSeries(kk)), asSeriesString{kk});
                            dNextPosition = dNextPosition+1;
                        end
                    end

                end
            end

            dListboxTop = get(lbMathWindow, 'ListboxTop');
            set(lbMathWindow, 'String', asLbString);
            set(lbMathWindow, 'ListboxTop', dListboxTop);
        end

    end

    function resetMathematicCallback(~, ~)

        tInitInput = inputTemplate('get');
        dInitOffset = get(uiSeriesPtr('get'), 'Value');
        if dInitOffset > numel(tInitInput)
            return;
        end
        
        try
            
        set(dlgMathematic, 'Pointer', 'watch');
        set(fiMainWindowPtr('get'), 'Pointer', 'watch');
        drawnow; 
        
        releaseRoiWait();

        set(uiSeriesPtr('get'), 'Enable', 'off');

        aInput = inputBuffer('get');

        if ~strcmp(imageOrientation('get'), 'axial')
            imageOrientation('set', 'axial');
        end

        asDescription = seriesDescription('get');
        for jj=1:numel(aInput)

            set(uiSeriesPtr('get'), 'Value', jj);

            if     strcmp(imageOrientation('get'), 'axial')
                aBuffer = permute(aInput{jj}, [1 2 3]);
            elseif strcmp(imageOrientation('get'), 'coronal')
                aBuffer = permute(aInput{jj}, [3 2 1]);
            elseif strcmp(imageOrientation('get'), 'sagittal')
                aBuffer = permute(aInput{jj}, [3 1 2]);
            end

            if isempty(tInitInput(jj).atDicomInfo{1}.SeriesDate)
                sInitSeriesDate = '';
            else
                sSeriesDate = tInitInput(jj).atDicomInfo{1}.SeriesDate;
                if isempty(tInitInput(jj).atDicomInfo{1}.SeriesTime)
                    sSeriesTime = '000000';
                else
                    sSeriesTime = tInitInput(jj).atDicomInfo{1}.SeriesTime;
                end

                sInitSeriesDate = sprintf('%s%s', sSeriesDate, sSeriesTime);
            end

            if ~isempty(sInitSeriesDate)
                if contains(sInitSeriesDate,'.')
                    sInitSeriesDate = extractBefore(sInitSeriesDate,'.');
                end

                sInitSeriesDate = datetime(sInitSeriesDate,'InputFormat','yyyyMMddHHmmss');
            end

            sInitSeriesDescription = tInitInput(jj).atDicomInfo{1}.SeriesDescription;

            asDescription{jj} = sprintf('%s %s', sInitSeriesDescription, sInitSeriesDate);

            dicomBuffer('set',aBuffer);

            dicomMetaData('set', tInitInput(jj).atDicomInfo);

            setQuantification(jj);

            tInitInput(jj).bEdgeDetection = false;
            tInitInput(jj).bFlipLeftRight = false;
            tInitInput(jj).bFlipAntPost   = false;
            tInitInput(jj).bFlipHeadFeet  = false;
            tInitInput(jj).bDoseKernel    = false;
            tInitInput(jj).bFusedDoseKernel    = false;
            tInitInput(jj).bFusedEdgeDetection = false;
            
            if isfield(tInitInput(jj), 'tRoi')
                atRoi = roiTemplate('get');
                for kk=1:numel(atRoi)
                    atRoi{kk}.SliceNb = tInitInput(jj).tRoi{kk}.SliceNb;
                    atRoi{kk}.Position = tInitInput(jj).tRoi{kk}.Position;
                    atRoi{kk}.Object.Position = tInitInput(jj).tRoi{kk}.Position;
                end
                roiTemplate('set', atRoi);
            end
        end

        seriesDescription('set', asDescription);

        set(uiSeriesPtr('get'), 'Value', dInitOffset);
        set(uiSeriesPtr('get'), 'Enable', 'on');

        fusionBuffer('reset');
        isFusion('set', false);
        set(btnFusionPtr('get'), 'BackgroundColor', viewerBackgroundColor('get'));
        set(btnFusionPtr('get'), 'ForegroundColor', viewerForegroundColor('get'));

        inputTemplate('set', tInitInput);
         
        set(dlgMathematic, 'Pointer', 'default');
        delete(dlgMathematic);

        clearDisplay();
        initDisplay(3);

        initWindowLevel('set', true);
        quantificationTemplate('set', tInitInput(dInitOffset).tQuant);

        dicomViewerCore();

%              triangulateCallback();

        refreshImages();
        
        catch
            progressBar(1, 'Error:resetRegistrationCallback()');           
        end
        
        set(fiMainWindowPtr('get'), 'Pointer', 'default');
        drawnow;         
    end

    function executeMathCallback(~, ~)
        
        tInput = inputTemplate('get');
        
        aInputBuffer  = inputBuffer('get');
        iOffset = get(uiSeriesPtr('get'), 'Value');
                    
        adLbOffset = get(lbMathWindow,  'Value');
        asLbString = get(lbMathWindow,  'String');        
 
        try
            
        set(dlgMathematic, 'Pointer', 'watch');
        drawnow;
    
        for jj=1:numel(adLbOffset)
            
            dCurOffset = adLbOffset(jj);
              
            set(uiSeriesPtr('get'), 'Value', dCurOffset);
            aBuffer = dicomBuffer('get');
            if isempty(aBuffer)
                aBuffer = aInputBuffer{dCurOffset};
                dicomBuffer('set', aBuffer);
            end

            sLbString = asLbString{dCurOffset};
            cLetter = sLbString(1);
            
            switch(cLetter)
                case 'a'; a=double(aBuffer);                    
                case 'b'; b=double(aBuffer);                   
                case 'c'; c=double(aBuffer);
                case 'd'; d=double(aBuffer);
                case 'e'; e=double(aBuffer);
                case 'f'; f=double(aBuffer);
                case 'g'; g=double(aBuffer);
                case 'h'; h=double(aBuffer);
                case 'i'; i=double(aBuffer);
                case 'j'; j=double(aBuffer);
                case 'k'; k=double(aBuffer);
                case 'l'; l=double(aBuffer);
                case 'm'; m=double(aBuffer);
                case 'n'; n=double(aBuffer);
                case 'o'; o=double(aBuffer);
                case 'p'; p=double(aBuffer);
                case 'q'; q=double(aBuffer);
                case 'r'; r=double(aBuffer);
                case 's'; s=double(aBuffer);
                case 't'; t=double(aBuffer);
                case 'u'; u=double(aBuffer);
                case 'v'; v=double(aBuffer);
                case 'w'; w=double(aBuffer);
                case 'x'; x=double(aBuffer);
                case 'y'; y=double(aBuffer);
                case 'z'; z=double(aBuffer);
                otherwise
                    progressBar(1,'Error:executeMathCallback() Associated set serie cant be found!');                                                                                   
            end

        end         
        
        set(uiSeriesPtr('get'), 'Value', iOffset);

        asEquation = strsplit(get(uiMathEquation, 'String'), ';');
        asEquation = strrep(asEquation,' ','');
        for jj=1: numel(asEquation)
            
            sEquation = asEquation{jj};
            
            acOperator = {'*', '/', '^'};
            for cc=1:numel(acOperator)
                aPosition = strfind(sEquation, acOperator{cc});
                for pp=numel(aPosition):-1:1
                    sEquation = insertBefore(sEquation, aPosition(pp), '.');
                end
            end
            
            tMException = [];
            sInput = sprintf('try, %s; catch tMException; end', sEquation);
            evalc(sInput);
            
            if isempty(tMException)
                aPosition = strfind(sEquation, '=');
                for pp=1:numel(aPosition)

                    bOffsetExist = false;

                    cLetter = sEquation(aPosition(pp)-1);

                    for kk=1:numel(adLbOffset)

                        dCurOffset = adLbOffset(kk);
                        sLbString = asLbString{dCurOffset};
                        if strcmpi(cLetter, sLbString(1))
                                                       
                            set(uiSeriesPtr('get'), 'Value', dCurOffset);
                            bOffsetExist = true;
                            break;
                        end

                    end

                    if bOffsetExist == true
                                               
                        switch cLetter
                            case 'a'; aBuffer = double(a);                            
                            case 'b'; aBuffer = double(b);                            
                            case 'c'; aBuffer = double(c);
                            case 'd'; aBuffer = double(d);
                            case 'e'; aBuffer = double(e);
                            case 'f'; aBuffer = double(f);
                            case 'g'; aBuffer = double(g);
                            case 'h'; aBuffer = double(h);
                            case 'i'; aBuffer = double(i);
                            case 'j'; aBuffer = double(j);
                            case 'k'; aBuffer = double(k);
                            case 'l'; aBuffer = double(l);
                            case 'm'; aBuffer = double(m);
                            case 'n'; aBuffer = double(n);
                            case 'o'; aBuffer = double(o);
                            case 'p'; aBuffer = double(p);
                            case 'q'; aBuffer = double(q);
                            case 'r'; aBuffer = double(r);
                            case 's'; aBuffer = double(s);
                            case 't'; aBuffer = double(t);
                            case 'u'; aBuffer = double(u);
                            case 'v'; aBuffer = double(v);
                            case 'w'; aBuffer = double(w);
                            case 'x'; aBuffer = double(x);
                            case 'y'; aBuffer = double(y);
                            case 'z'; aBuffer = double(z);
                        otherwise
                            progressBar(1,'Error:executeMathCallback() Associated result serie cant be found!');                         
                        end

                        dicomBuffer('set', aBuffer);
                        
                        if get(chkMathSeriesDescription, 'Value') == true
                            
                            atMetaData = dicomMetaData('get');
                            if isempty(atMetaData)
                                atMetaData = tInput(dCurOffset).atDicomInfo;
                            end

                            for dd=1:numel(atMetaData)
                                atMetaData{dd}.SeriesDescription  = sprintf('MATH %s', atMetaData{1}.SeriesDescription);
                            end
                            asDescription = seriesDescription('get');
                            asDescription{dCurOffset} = sprintf('MATH %s', asDescription{dCurOffset});

                            seriesDescription('set', asDescription);
                            dicomMetaData('set', atMetaData);                            
                        end
                        
                        updateDescription('set', get(chkMathSeriesDescription, 'Value'));
                        
                    end
                end
            else
                progressBar(1,'Error:executeMathCallback()');                       
                msgbox({tMException.identifier;tMException.message}, 'Error:executeMathCallback()');
                break;
            end
                                
        end 
        
        catch
            progressBar(1,'Error:executeMathCallback()');                       
        end
        
        set(dlgMathematic, 'Pointer', 'default');
        drawnow;
    
        set(uiSeriesPtr('get'), 'Value', iOffset);
        
        if isempty(tMException)        
            progressBar(1,'Ready');                       
            delete(dlgMathematic);
            
            refreshImages();
        end
        
    end
    function updateMathDescriptionCallback(hObject, ~)

         if get(chkMathSeriesDescription, 'Value') == true
            if strcmpi(get(hObject, 'Style'), 'Checkbox')
                set(chkMathSeriesDescription, 'Value', true);
            else
                set(chkMathSeriesDescription, 'Value', false);
            end
        else
            if strcmpi(hObject.Style, 'Checkbox')
                set(chkMathSeriesDescription, 'Value', false);
            else
                set(chkMathSeriesDescription, 'Value', true);
            end
         end

    end

    function sNewString = insertBefore( sInputString, dPosition, sWhatToInsert)
        
        sNewString = char( strcat( cellstr(sInputString(:,1:dPosition-1)), ...
                                   cellstr(sWhatToInsert), ...
                                   cellstr(sInputString(:, dPosition:end)) ) ...
                          );
    end

end