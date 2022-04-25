function tRegistration = registrationTemplate(sAction, tValue)
%function tRegistration = registrationTemplate(sAction, tValue)
%Get/Set Registration Template.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Note: option settings must fit on one line and can contain one semicolon at most.
%Options can be strings, cell arrays of strings, or numerical arrays.
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

    persistent ptRegistration; 

    if strcmpi('init', sAction)
        ptRegistration.Interpolation = 'Bilinear';

        ptRegistration.Transformation = 'Rigid';   
        
        ptRegistration.Modality = 'Automatic';   

        [tOptimizer, tMetric] = imregconfig('multimodal');
        
        % Multimodal
        ptRegistration.Metric.NumberOfSpatialSamples = 5000;
        ptRegistration.Metric.NumberOfHistogramBins  = 50;        
        ptRegistration.Metric.UseAllPixels = false;
        
        % Multimodal
        ptRegistration.Optimizer.GrowthFactor = 1.05;
        ptRegistration.Optimizer.Epsilon = 2.5e-06;
        ptRegistration.Optimizer.InitialRadius = 0.5e-03;
        
        % Monomodal
        ptRegistration.Optimizer.GradientMagnitudeTolerance = 1.000000e-04;
        ptRegistration.Optimizer.MinimumStepLength = 1.000000e-05;
        ptRegistration.Optimizer.MaximumStepLength = 6.250000e-02;
        ptRegistration.Optimizer.RelaxationFactor  = 5.000000e-01;        
        
        % Multimodal & Monomodal
        ptRegistration.Optimizer.MaximumIterations = 100;    
        
    elseif strcmpi('set', sAction)
       ptRegistration = tValue;            
    end

    tRegistration = ptRegistration;   
end