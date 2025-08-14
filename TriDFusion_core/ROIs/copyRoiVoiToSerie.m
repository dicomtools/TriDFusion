function copyRoiVoiToSerie(dSeriesOffset, dSeriesToOffset, tRoiVoiObject, bMirror)
%function copyRoiVoiToSerie(dSeriesOffset, dSeriesToOffset, tRoiVoiObject, bMirror)
%Copy ROI form a serie to another.
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

%    tRoiInput = roiTemplate('get', get(uiSeriesPtr('get'), 'Value'));

    imRoi       = dicomBuffer('get', [], dSeriesToOffset);
    atDicomInfo = dicomMetaData('get', [], dSeriesToOffset);

%    dSeriesOffset = get(uiSeriesPtr('get'), 'Value');

    atInput       = inputTemplate('get');
    atRoiInput    = roiTemplate('get', dSeriesToOffset);
    atRefRoiInput = roiTemplate('get', dSeriesOffset);
    atRefVoiInput = voiTemplate('get', dSeriesOffset);

    aBuffer = inputBuffer('get');

%    set(uiSeriesPtr('get'), 'Value', dSeriesToOffset);

    aRefBuffer = dicomBuffer('get', [], dSeriesOffset);
    if isempty(aRefBuffer)

        aRefBuffer = aBuffer{dSeriesOffset};
    end

    if isempty(imRoi)

        imRoi = aBuffer{dSeriesToOffset};
    end

    atRefInfo = dicomMetaData('get', [], dSeriesOffset);
    if isempty(atRefInfo)

         atRefInfo = atInput(dSeriesOffset).atDicomInfo;
    end

    if isempty(atDicomInfo)

         atDicomInfo = atInput(dSeriesToOffset).atDicomInfo;
    end

    if strcmpi(tRoiVoiObject.ObjectType, 'voi')

        % Voi

        % dOffset = 1;
        % dEndLoop = numel(tRoiVoiObject.RoisTag);
        % atRoi = cell(dEndLoop, 1);
        % for kk=1:dEndLoop 
        %     for ll=1:numel(atRefRoiInput)
        % 
        %         if strcmpi(tRoiVoiObject.RoisTag{kk}, atRefRoiInput{ll}.Tag)
        %             atRoi{dOffset} = atRefRoiInput{ll};
        %             dOffset = dOffset+1;
        %         end
        %     end
        % end

        % Convert tags to lower-case for case‐insensitive comparison
        refTags = lower(cellfun(@(x)x.Tag, atRefRoiInput, 'UniformOutput', false));
        roiTags = lower(tRoiVoiObject.RoisTag);
        
        % Find all atRefRoiInput whose tag is in roiTags
        mask = ismember(refTags, roiTags);
        atRoi = atRefRoiInput(mask);
        
        if ~isempty(atRoi)

            atRoi = resampleROIs(aRefBuffer, atRefInfo, imRoi, atDicomInfo, atRoi, false, atRefVoiInput, dSeriesOffset);
        end

        asTag = cell(numel(atRoi), 1);
        
        if dSeriesToOffset == dSeriesOffset
            atDicomInfo = atRefInfo;
        end

        for rr=1: numel(atRoi)
            
            atRoi{rr}.Tag = num2str(generateUniqueNumber(false));
            asTag{rr} =atRoi{rr}.Tag; 

            if size(aRefBuffer, 3) ~= 1
    
                switch lower(atRoi{rr}.Axe)
    
                    case 'axes1' % Need to be fixed
                         sSOPClassUID         = [];
                         sSOPInstanceUID      = [];
                         sFrameOfReferenceUID = [];   
                         
                    case 'axes2'% Need to be fixed
                        sSOPClassUID         = [];
                        sSOPInstanceUID      = [];
                        sFrameOfReferenceUID = [];

                    otherwise
    
                        if numel(atDicomInfo) >= atRoi{rr}.SliceNb
                            sSOPClassUID         = atDicomInfo{atRoi{rr}.SliceNb}.SOPClassUID;
                            sSOPInstanceUID      = atDicomInfo{atRoi{rr}.SliceNb}.SOPInstanceUID;
                            sFrameOfReferenceUID = atDicomInfo{atRoi{rr}.SliceNb}.FrameOfReferenceUID;
                        else
                            sSOPClassUID         = atDicomInfo{1}.SOPClassUID;
                            sSOPInstanceUID      = atDicomInfo{1}.SOPInstanceUID;
                            sFrameOfReferenceUID = [];
                        end
    
                end
            else
                sSOPClassUID         = atDicomInfo{1}.SOPClassUID;
                sSOPInstanceUID      = atDicomInfo{1}.SOPInstanceUID;
                sFrameOfReferenceUID = atDicomInfo{1}.FrameOfReferenceUID;
            end
    
            atRoi{rr}.SOPClassUID         = sSOPClassUID;
            atRoi{rr}.SOPInstanceUID      = sSOPInstanceUID;
            atRoi{rr}.FrameOfReferenceUID = sFrameOfReferenceUID;

            if bMirror == true

                aImageSize = size(aBuffer{dSeriesToOffset});

                switch lower(atRoi{rr}.Type)

                    case lower('images.roi.circle')

                        switch lower(atRoi{rr}.Axe)

                            case 'axes1'

                                atRoi{rr}.Position = [];
                                progressBar(1, 'Error: Copy of a circle from a coronal plane is not yet supported!');

                            case 'axes2'

                                atRoi{rr}.Position = [];
                                progressBar(1, 'Error: Copy of a circle from a sagitttal plane is not yet supported!');

                            otherwise


                                % Get the size of the image
                                imgWidth = aImageSize(2);

                                % Perform flipping operations
                                % Horizontal flip
                                atRoi{rr}.Position(:,1) = imgWidth - atRoi{rr}.Position(:,1);
                        end

                    case lower('images.roi.ellipse')

                        switch lower(atRoi{rr}.Axe)

                            case 'axes1'

                                atRoi{rr}.Position = [];
                                progressBar(1, 'Error: Copy mirror of an ellipse from a coronal plane is not yet supported!');

                            case 'axes2'

                                atRoi{rr}.Position = [];
                                progressBar(1, 'Error: Copy mirror of an ellipse from a sagittal plane is not yet supported!');

                            otherwise

                                % Get the size of the image
                                imgWidth = aImageSize(2);

                                % Perform flipping operations
                                % Horizontal flip
                                atRoi{rr}.Position(:,1) = imgWidth - atRoi{rr}.Position(:,1);

                        end

                    case lower('images.roi.rectangle')


                        aRectanglePosition = atRoi{rr}.Position;

                        x = aRectanglePosition(1);
                        y = aRectanglePosition(2);
                        w = aRectanglePosition(3);
                        h = aRectanglePosition(4);

                        imgWidth = aImageSize(2);

                        % Calculate the new X position for horizontal flip
                        newX = imgWidth - x - w;

                        % Update the rectangle's position
                        atRoi{rr}.Position = [newX, y, w, h];

                    otherwise

                        % Get the size of the image
                        imgWidth = aImageSize(2);

                        % Perform flipping operations
                        % Horizontal flip
                        atRoi{rr}.Position(:,1) = imgWidth - atRoi{rr}.Position(:,1);

                end
            end

            if dSeriesToOffset == dSeriesOffset
    
                atRoi{rr} = addRoiFromTemplate(atRoi{rr}, dSeriesToOffset);               
            end

            if isempty(atRoiInput)
                atRoiInput{1} = atRoi{rr};
            else
                atRoiInput{numel(atRoiInput)+1} = atRoi{rr};
            end            
        end

        roiTemplate('set', dSeriesToOffset, atRoiInput);

        asTag = asTag(~cellfun(@isempty, asTag));

        if ~isempty(asTag)

            createVoiFromRois(dSeriesToOffset, asTag, tRoiVoiObject.Label, tRoiVoiObject.Color, tRoiVoiObject.LesionType);

            if dSeriesOffset == dSeriesToOffset

                refreshImages();

                setVoiRoiSegPopup();

                plotRotatedRoiOnMip(axesMipPtr('get', [], dSeriesOffset), dicomBuffer('get', [], dSeriesOffset), mipAngle('get'));
            end
        end

    else
        % Roi

        atRoi = cell(1,1);
        atRoi{1} = tRoiVoiObject;
        atRoi = resampleROIs(aRefBuffer, atRefInfo, imRoi, atDicomInfo, atRoi, false, atRefVoiInput, dSeriesOffset);
        
        if dSeriesToOffset == dSeriesOffset
            atDicomInfo = atRefInfo;
        end
            
        atRoi{1}.Tag = num2str(generateUniqueNumber(false));

        if size(aRefBuffer, 3) ~= 1

            switch lower(atRoi{1}.Axe)

                case {'axes1', 'axes2'}

                    sSOPClassUID         = [];
                    sSOPInstanceUID      = [];
                    sFrameOfReferenceUID = [];

                otherwise

                    if numel(atDicomInfo) >= atRoi{1}.SliceNb
                        sSOPClassUID         = atDicomInfo{atRoi{1}.SliceNb}.SOPClassUID;
                        sSOPInstanceUID      = atDicomInfo{atRoi{1}.SliceNb}.SOPInstanceUID;
                        sFrameOfReferenceUID = atDicomInfo{atRoi{1}.SliceNb}.FrameOfReferenceUID;
                    else
                        sSOPClassUID         = atDicomInfo{1}.SOPClassUID;
                        sSOPInstanceUID      = atDicomInfo{1}.SOPInstanceUID;
                        sFrameOfReferenceUID = atDicomInfo{1}.FrameOfReferenceUID;
                    end

            end
        else
            sSOPClassUID         = atDicomInfo{1}.SOPClassUID;
            sSOPInstanceUID      = atDicomInfo{1}.SOPInstanceUID;
            sFrameOfReferenceUID = atDicomInfo{1}.FrameOfReferenceUID;
        end

        atRoi{1}.SOPClassUID         = sSOPClassUID;
        atRoi{1}.SOPInstanceUID      = sSOPInstanceUID;
        atRoi{1}.FrameOfReferenceUID = sFrameOfReferenceUID;

        if bMirror == true

            aImageSize = size(aBuffer{dSeriesToOffset});

            switch lower(atRoi{1}.Type)

                case lower('images.roi.circle')

                    switch lower(atRoi{1}.Axe)

                        case 'axes1'

                            atRoi{1}.Position = [];
                            progressBar(1, 'Error: Copy of a circle from a coronal plane is not yet supported!');

                        case 'axes2'

                            atRoi{1}.Position = [];
                            progressBar(1, 'Error: Copy of a circle from a sagitttal plane is not yet supported!');

                        otherwise


                            % Get the size of the image
                            imgWidth = aImageSize(2);

                            % Perform flipping operations
                            % Horizontal flip
                            atRoi{1}.Position(:,1) = imgWidth - atRoi{1}.Position(:,1);
                    end

                case lower('images.roi.ellipse')

                    switch lower(atRoi{1}.Axe)

                        case 'axes1'

                            atRoi{1}.Position = [];
                            progressBar(1, 'Error: Copy mirror of an ellipse from a coronal plane is not yet supported!');

                        case 'axes2'

                            atRoi{1}.Position = [];
                            progressBar(1, 'Error: Copy mirror of an ellipse from a sagittal plane is not yet supported!');

                        otherwise

                            % Get the size of the image
                            imgWidth = aImageSize(2);

                            % Perform flipping operations
                            % Horizontal flip
                            atRoi{1}.Position(:,1) = imgWidth - atRoi{1}.Position(:,1);

                    end

                case lower('images.roi.rectangle')


                    aRectanglePosition = atRoi{1}.Position;

                    x = aRectanglePosition(1);
                    y = aRectanglePosition(2);
                    w = aRectanglePosition(3);
                    h = aRectanglePosition(4);

                    imgWidth = aImageSize(2);

                    % Calculate the new X position for horizontal flip
                    newX = imgWidth - x - w;

                    % Update the rectangle's position
                    atRoi{1}.Position = [newX, y, w, h];

                otherwise

                    % Get the size of the image
                    imgWidth = aImageSize(2);

                    % Perform flipping operations
                    % Horizontal flip
                    atRoi{1}.Position(:,1) = imgWidth - atRoi{1}.Position(:,1);

            end
        end

        if dSeriesToOffset == dSeriesOffset

            atRoi{1} = addRoiFromTemplate(atRoi{1}, dSeriesOffset);               
        end
        
        if isempty(atRoiInput)
            atRoiInput{1} = atRoi{1};
        else
            atRoiInput{numel(atRoiInput)+1} = atRoi{1};
        end 

        roiTemplate('set', dSeriesToOffset, atRoiInput);    

        if dSeriesOffset == dSeriesToOffset

            refreshImages();

            if size(dicomBuffer('get', [], dSeriesOffset), 3) ~= 1

                plotRotatedRoiOnMip(axesMipPtr('get', [], dSeriesOffset), dicomBuffer('get', [], dSeriesOffset), mipAngle('get'));
            end
        end  
  
    end

end
