function createVoiMarginContours(dMarginSize, sJointType, atVoiInput)
%function createVoiMarginContours(dMarginSize, sJointType, atVoiInput)
%Add a Marginal VOI Around an Existing VOI.
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

    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

    atMetaData = dicomMetaData('get', [], dSeriesOffset);

    if size(dicomBuffer('get', [], dSeriesOffset), 3) ~= 1
        b3DIMage = true;
    else
        b3DIMage = false;            
    end     
    
    atRoiInput = roiTemplate('get', dSeriesOffset);

    [~, ~, asLesionShortName] = getLesionType('');

    if isempty(atVoiInput)
        progressBar(1, 'Error: At least one VOI is required to create a margin!');
        errordlg('At least one VOI is required to create a margin!', 'Contour Validation');          
        return;
    end

    if b3DIMage == true

        dCoronal  = sliceNumber('get', 'coronal' );
        dSagittal = sliceNumber('get', 'sagittal');
        dAxial    = sliceNumber('get', 'axial'   );
    end
    
    switch dMarginSize

        case 5 
            aColor = [1 0 0];

        case 10 
            aColor = [0 1 0];

        case 15 
            aColor = [0 0 1];

        case 20
            aColor = [1 1 0];

        case 25
            aColor = [1 0 1];

        otherwise
             aColor = [0 1 1];                  
    end

    if ~isempty(atVoiInput) % VOI

        dNbVois = numel(atVoiInput);

        for vv=1:dNbVois

            if contains(atVoiInput{vv}.Label, 'Ablation Zone') || ...
               contains(atVoiInput{vv}.Label, 'AZ')     
                continue;
            end            

            dNbRois = numel(atVoiInput{vv}.RoisTag);
            
            asTag = cell(dNbRois, 1);

            for rr=1:dNbRois 

                dRoiTagOffset = find(strcmp( cellfun( @(atRoiInput) atRoiInput.Tag, atRoiInput, 'uni', false ), atVoiInput{vv}.RoisTag{rr} ), 1);

                if ~isempty(dRoiTagOffset)
                
                    ptrRoi = atRoiInput{dRoiTagOffset}.Object;
                    
                    if isfield(atRoiInput{dRoiTagOffset}, 'Position')
    
                        switch ptrRoi.Parent
            
                            case axePtr('get', [], dSeriesOffset)
    
                                xPixelSize = atMetaData{1}.PixelSpacing(1);
                                % yPixelSize = atMetaData{1}.PixelSpacing(2);
    
                            case axes1Ptr('get', [], dSeriesOffset)
    
                                xPixelSize = atMetaData{1}.PixelSpacing(2);
                                % yPixelSize = computeSliceSpacing(atMetaData);
    
                                sliceNumber('set', 'coronal', atRoiInput{dRoiTagOffset}.SliceNb);
    
                            case axes2Ptr('get', [], dSeriesOffset)
    
                                xPixelSize = atMetaData{1}.PixelSpacing(1);
                                % yPixelSize = computeSliceSpacing(atMetaData);
   
                                sliceNumber('set', 'sagittal', atRoiInput{dRoiTagOffset}.SliceNb);
    
    
                            case axes3Ptr('get', [], dSeriesOffset)
    
                                xPixelSize = atMetaData{1}.PixelSpacing(1);
                                % yPixelSize = atMetaData{1}.PixelSpacing(2);

                                sliceNumber('set', 'axial', atRoiInput{dRoiTagOffset}.SliceNb);
    
                            otherwise
                                continue;
                               
                        end
    
                        if xPixelSize == 0
                            xPixelSize = 1;
                        end
    
                        % if yPixelSize == 0
                        %     yPixelSize = 1;
                        % end

                        aMarginPosition = computeMarginUsingPolybuffer(ptrRoi.Position, dMarginSize/xPixelSize, sJointType);

                        sTag = num2str(generateUniqueNumber(false));

                        sRoiLabel = ptrRoi.Label;

                        for jj=1:numel(asLesionShortName)
        
                            if contains(sRoiLabel, asLesionShortName{jj})

                                sRoiLabel = replace(sRoiLabel, sprintf('-%s', asLesionShortName{jj}), '');
                                break;
                            end
                        end  

                        pRoi = images.roi.Freehand(ptrRoi.Parent, ...
                                                   'Position'           , aMarginPosition, ...
                                                   'Smoothing'          , ptrRoi.Smoothing, ...
                                                   'Color'              , aColor, ...
                                                   'LineWidth'          , ptrRoi.LineWidth, ...
                                                   'Label'              , sprintf('%s AZ %dmm', sRoiLabel, dMarginSize), ...
                                                   'LabelVisible'       , ptrRoi.LabelVisible, ...
                                                   'FaceSelectable'     , ptrRoi.FaceSelectable, ...
                                                   'FaceAlpha'          , 0, ...
                                                   'Tag'                , sTag, ...
                                                   'StripeColor'        , ptrRoi.StripeColor, ...                                                                              
                                                   'InteractionsAllowed', ptrRoi.InteractionsAllowed, ...                                          
                                                   'UserData'           , 'voi-roi', ...
                                                   'Visible'            , 'on' ...
                                                   );
                                               

                        if ~isempty(pRoi.Waypoints(:))
                            
                            pRoi.Waypoints(:) = false;
                        end
            
                        addRoi(pRoi, dSeriesOffset, atVoiInput{vv}.LesionType);
            
                        addRoiMenu(pRoi);

                        asTag{rr} = sTag;

                    end 
                end               
            end

            asTag = asTag(~cellfun(@isempty, asTag));
            
            if ~isempty(asTag)
                
                sVoiLabel = atVoiInput{vv}.Label;

                for jj=1:numel(asLesionShortName) % Clean up name

                    if contains(sVoiLabel, asLesionShortName{jj})
                        
                        sVoiLabel = replace(sVoiLabel, sprintf('-%s', asLesionShortName{jj}), '');
                        break;
                    end
                end  

                sLabel = sprintf('%s AZ %dmm', sVoiLabel, dMarginSize);

                createVoiFromRois(dSeriesOffset, asTag, sLabel, aColor, atVoiInput{vv}.LesionType);

                setVoiRoiSegPopup();

                plotRotatedRoiOnMip(axesMipPtr('get', [], dSeriesOffset), dicomBuffer('get', [], dSeriesOffset), mipAngle('get'));
            end 
        end
    end

    if size(dicomBuffer('get', [], dSeriesOffset), 3) ~= 1

        sliceNumber('set', 'coronal' , dCoronal);
        sliceNumber('set', 'sagittal', dSagittal);
        sliceNumber('set', 'axial'   , dAxial);
    end
    
    refreshImages();

end