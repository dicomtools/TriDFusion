function writeYamlFile(sFileName, tReadiomics, dLabel)    

    caXamlParam = [];

    % setting

    caXamlParam{numel(caXamlParam)+1} = 'setting:';
    caXamlParam{numel(caXamlParam)+1} = '  additionalInfo: true';
    caXamlParam{numel(caXamlParam)+1} = sprintf('  label: %d', dLabel);

    % binWidth

    if tReadiomics.setting.binWidth.enable == true

        caXamlParam{numel(caXamlParam)+1} = sprintf('  %s: %d', ...
            tReadiomics.setting.binWidth.name, ...
            tReadiomics.setting.binWidth.value);
    end

    % resegmentRange

    if tReadiomics.setting.resegmentRange.enable == true

        caXamlParam{numel(caXamlParam)+1} = sprintf('  %s: [%d,%d]', ...
            tReadiomics.setting.resegmentRange.name, ...
            tReadiomics.setting.resegmentRange.value.min, ...
            tReadiomics.setting.resegmentRange.value.max);        
    end
    
    % binCount

    if tReadiomics.setting.binCount.enable == true

        caXamlParam{numel(caXamlParam)+1} = sprintf('  %s: %d', ...
            tReadiomics.setting.binCount.name, ...
            tReadiomics.setting.binCount.value);
    end

    % resampledPixelSpacing

    if tReadiomics.setting.resampledPixelSpacing.enable == true

        caXamlParam{numel(caXamlParam)+1} = sprintf('  %s: [%d,%d,%d]', ...
            tReadiomics.setting.resampledPixelSpacing.name, ...
            tReadiomics.setting.resampledPixelSpacing.value.x, ...
            tReadiomics.setting.resampledPixelSpacing.value.y, ...        
            tReadiomics.setting.resampledPixelSpacing.value.z);           
    end

    % interpolator

    if tReadiomics.setting.interpolator.enable == true

        caXamlParam{numel(caXamlParam)+1} = sprintf('  %s: %s', ...
            tReadiomics.setting.interpolator.name, ...
            tReadiomics.setting.interpolator.value);
    end

    % padDistance

    if tReadiomics.setting.padDistance.enable == true

        caXamlParam{numel(caXamlParam)+1} = sprintf('  %s: %d', ...
            tReadiomics.setting.padDistance.name, ...
            tReadiomics.setting.padDistance.value);
    end

    % normalize

    if tReadiomics.setting.normalize.enable == true

        caXamlParam{numel(caXamlParam)+1} = sprintf('  %s: %s', ...
            tReadiomics.setting.normalize.name, ...
            tReadiomics.setting.normalize.value);
    end

    % normalizeScale 

    if tReadiomics.setting.normalizeScale.enable == true

        caXamlParam{numel(caXamlParam)+1} = sprintf('  %s: %d', ...
            tReadiomics.setting.normalizeScale.name, ...
            tReadiomics.setting.normalizeScale.value);
    end

    % removeOutliers 

    if tReadiomics.setting.removeOutliers.enable == true

        caXamlParam{numel(caXamlParam)+1} = sprintf('  %s: %d', ...
            tReadiomics.setting.removeOutliers.name, ...
            tReadiomics.setting.removeOutliers.value);
    end

    % minimumROIDimensions

    if tReadiomics.setting.minimumROIDimensions.enable == true

        caXamlParam{numel(caXamlParam)+1} = sprintf('  %s: %d', ...
            tReadiomics.setting.minimumROIDimensions.name, ...
            tReadiomics.setting.minimumROIDimensions.value);
    end

    % minimumROISize

    if tReadiomics.setting.minimumROISize.enable == true

        caXamlParam{numel(caXamlParam)+1} = sprintf('  %s: %d', ...
            tReadiomics.setting.minimumROISize.name, ...
            tReadiomics.setting.minimumROISize.value);
    end

    % geometryTolerance

    if tReadiomics.setting.geometryTolerance.enable == true

        caXamlParam{numel(caXamlParam)+1} = sprintf('  %s: %d', ...
            tReadiomics.setting.geometryTolerance.name, ...
            tReadiomics.setting.geometryTolerance.value);
    end

    % correctMask

    if tReadiomics.setting.correctMask.enable == true

        caXamlParam{numel(caXamlParam)+1} = sprintf('  %s: %s', ...
            tReadiomics.setting.correctMask.name, ...
            tReadiomics.setting.correctMask.value);
    end

 
    % force2D

    if tReadiomics.setting.force2D.enable == true

        caXamlParam{numel(caXamlParam)+1} = sprintf('  %s: %s', ...
            tReadiomics.setting.force2D.name, ...
            tReadiomics.setting.force2D.value);
    end

    % force2Ddimension

    if tReadiomics.setting.force2Ddimension.enable == true

        caXamlParam{numel(caXamlParam)+1} = sprintf('  %s: %d', ...
            tReadiomics.setting.force2Ddimension.name, ...
            tReadiomics.setting.force2Ddimension.value);
    end

    % weightingNorm

    if tReadiomics.setting.weightingNorm.enable == true

        caXamlParam{numel(caXamlParam)+1} = sprintf('  %s: %s', ...
            tReadiomics.setting.weightingNorm.name, ...
            tReadiomics.setting.weightingNorm.value);
    end

    % distances

    if tReadiomics.setting.distances.enable == true

        caXamlParam{numel(caXamlParam)+1} = sprintf('  %s: %d', ...
            tReadiomics.setting.distances.name, ...
            tReadiomics.setting.distances.value);
    end

    % preCrop

    if tReadiomics.setting.preCrop.enable == true

        caXamlParam{numel(caXamlParam)+1} = sprintf('  %s: %s', ...
            tReadiomics.setting.preCrop.name, ...
            tReadiomics.setting.preCrop.value);
    end

    % voxelArrayShift

    if tReadiomics.setting.voxelArrayShift.enable == true

        caXamlParam{numel(caXamlParam)+1} = sprintf('  %s: %d', ...
            tReadiomics.setting.voxelArrayShift.name, ...
            tReadiomics.setting.voxelArrayShift.value);
    end

    % symmetricalGLCM

    if tReadiomics.setting.symmetricalGLCM.enable == true

        caXamlParam{numel(caXamlParam)+1} = sprintf('  %s: %s', ...
            tReadiomics.setting.symmetricalGLCM.name, ...
            tReadiomics.setting.symmetricalGLCM.value);
    end

    % gldm_a

    if tReadiomics.setting.gldm_a.enable == true

        caXamlParam{numel(caXamlParam)+1} = sprintf('  %s: %d', ...
            tReadiomics.setting.gldm_a.name, ...
            tReadiomics.setting.gldm_a.value);
    end  

    % imageType

    caXamlParam{numel(caXamlParam)+1} = '';
    caXamlParam{numel(caXamlParam)+1} = 'imageType:';

    % Original

    if tReadiomics.imageType.original.enable == true

        caXamlParam{numel(caXamlParam)+1} = sprintf('  %s: {%s}', ...
            tReadiomics.imageType.original.name, ...
            tReadiomics.imageType.original.value);
    end  

    % LoG

    if tReadiomics.imageType.loG.enable == true

        caXamlParam{numel(caXamlParam)+1} = sprintf('  %s: {%s}', ...
            tReadiomics.imageType.loG.name, ...
            tReadiomics.imageType.loG.value);
    end 

    % Wavelet

    if tReadiomics.imageType.wavelet.enable == true

        caXamlParam{numel(caXamlParam)+1} = sprintf('  %s: {%s}', ...
            tReadiomics.imageType.wavelet.name, ...
            tReadiomics.imageType.wavelet.value);
    end  

    % Square

    if tReadiomics.imageType.square.enable == true

        caXamlParam{numel(caXamlParam)+1} = sprintf('  %s: {%s}', ...
            tReadiomics.imageType.square.name, ...
            tReadiomics.imageType.square.value);
    end  

    % SquareRoot

    if tReadiomics.imageType.squareRoot.enable == true

        caXamlParam{numel(caXamlParam)+1} = sprintf('  %s: {%s}', ...
            tReadiomics.imageType.squareRoot.name, ...
            tReadiomics.imageType.squareRoot.value);
    end  

    % Logarithm

    if tReadiomics.imageType.logarithm.enable == true

        caXamlParam{numel(caXamlParam)+1} = sprintf('  %s: {%s}', ...
            tReadiomics.imageType.logarithm.name, ...
            tReadiomics.imageType.logarithm.value);
    end 

    % Exponential

    if tReadiomics.imageType.exponential.enable == true

        caXamlParam{numel(caXamlParam)+1} = sprintf('  %s: {%s}', ...
            tReadiomics.imageType.exponential.name, ...
            tReadiomics.imageType.exponential.value);
    end  

    % Gradient

    if tReadiomics.imageType.gradient.enable == true

        caXamlParam{numel(caXamlParam)+1} = sprintf('  %s: {%s}', ...
            tReadiomics.imageType.gradient.name, ...
            tReadiomics.imageType.gradient.value);
    end  

    % featureClass

    caXamlParam{numel(caXamlParam)+1} = '';
    caXamlParam{numel(caXamlParam)+1} = 'featureClass:';
    
    % firstorder

    if ~isempty(tReadiomics.featureClass.firstOrder)
        caXamlParam{numel(caXamlParam)+1} = sprintf('  %s:', tReadiomics.featureClass.firstOrder.name);
        if tReadiomics.featureClass.firstOrder.all == false
            for aa=1:numel(tReadiomics.featureClass.firstOrder.feature)
                caXamlParam{numel(caXamlParam)+1} = sprintf('    - %s', tReadiomics.featureClass.firstOrder.feature{aa});
            end
        end    
    end

    % shape

    if ~isempty(tReadiomics.featureClass.shape)
        caXamlParam{numel(caXamlParam)+1} = sprintf('  %s:', tReadiomics.featureClass.shape.name);
        if tReadiomics.featureClass.shape.all == false
            for aa=1:numel(tReadiomics.featureClass.shape.feature)
                caXamlParam{numel(caXamlParam)+1} = sprintf('    - %s', tReadiomics.featureClass.shape.feature{aa});
            end
        end    
    end

    % glcm
    
    if ~isempty(tReadiomics.featureClass.glcm)
        caXamlParam{numel(caXamlParam)+1} = sprintf('  %s:', tReadiomics.featureClass.glcm.name);
        if tReadiomics.featureClass.glcm.all == false
            for aa=1:numel(tReadiomics.featureClass.glcm.feature)
                caXamlParam{numel(caXamlParam)+1} = sprintf('    - %s', tReadiomics.featureClass.glcm.feature{aa});
            end
        end    
    end

    % glrlm
    
    if ~isempty(tReadiomics.featureClass.glrlm)
        caXamlParam{numel(caXamlParam)+1} = sprintf('  %s:', tReadiomics.featureClass.glrlm.name);
        if tReadiomics.featureClass.glrlm.all == false
            for aa=1:numel(tReadiomics.featureClass.glrlm.feature)
                caXamlParam{numel(caXamlParam)+1} = sprintf('    - %s', tReadiomics.featureClass.glrlm.feature{aa});
            end
        end    
    end

    % glszm
    
    if ~isempty(tReadiomics.featureClass.glszm)
        caXamlParam{numel(caXamlParam)+1} = sprintf('  %s:', tReadiomics.featureClass.glszm.name);
        if tReadiomics.featureClass.glszm.all == false
            for aa=1:numel(tReadiomics.featureClass.glszm.feature)
                caXamlParam{numel(caXamlParam)+1} = sprintf('    - %s', tReadiomics.featureClass.glszm.feature{aa});
            end
        end    
    end

    % ngtdm
    
    if ~isempty(tReadiomics.featureClass.ngtdm)
        caXamlParam{numel(caXamlParam)+1} = sprintf('  %s:', tReadiomics.featureClass.ngtdm.name);
        if tReadiomics.featureClass.ngtdm.all == false
            for aa=1:numel(tReadiomics.featureClass.ngtdmv.feature)
                caXamlParam{numel(caXamlParam)+1} = sprintf('    - %s', tReadiomics.featureClass.ngtdm.feature{aa});
            end
        end    
    end

   
    sDisplayBuffer = '';
    for ff=1:numel(caXamlParam)
        sDisplayBuffer = sprintf('%s%s\n', sDisplayBuffer, caXamlParam{ff});
    end

    fFileID = fopen(sFileName,'w');
    if fFileID ~= -1
        fwrite(fFileID, sDisplayBuffer);
        fclose(fFileID);
    end
end