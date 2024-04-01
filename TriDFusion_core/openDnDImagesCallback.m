function openDnDImagesCallback(hObject, tObject)
%function openDnDImagesCallback(hObject, tObject)
%Open a drag and drop images.
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

    for jj=1:numel(tObject.names) 

        if isfile(tObject.names{jj})

            [sPath, sFileName, sExt] = fileparts(tObject.names{jj});

            if numel(tObject.names) >1 

                if jj == numel(tObject.names)

                    bInitDisplay = true;
                else
                    bInitDisplay = false;
                end                   
            else
                bInitDisplay = true;
            end

            switch lower(sExt)
    
                case '.nii'


                    loadNIIFile([sPath '/'], sprintf('%s%s',sFileName, sExt), bInitDisplay, []);   

                case '.nrrd'
                    loadNrrdFile([sPath '/'], sprintf('%s%s',sFileName, sExt), bInitDisplay, []);   
                
                case '.raw'
                   
                case '.stl'

                otherwise

                    if isdicom(tObject.names{jj})

                        loadDcmFile([], tObject.names{jj}, bInitDisplay)

                    end
             
            end

        elseif isfolder(tObject.names{jj})

            atListing = dir(tObject.names{jj});
            
            % Iterate through the struct array
            
            for i = 1:numel(atListing)

                % Check if the file is a DICOM file

                if ~atListing(i).isdir 

                    sFileInput = fullfile(atListing(i).folder, atListing(i).name);

                    if isdicom(sFileInput)  % Folder contains dicom series

                        if numel(tObject.names) >1 
            
                            if jj == numel(tObject.names)
            
                                bInitDisplay = true;
                            else
                                bInitDisplay = false;
                            end                   
                        else
                            bInitDisplay = true;
                        end 

                        acFolderName{1} = tObject.names{jj};
                        loadDcmFile(acFolderName, [], bInitDisplay)

                        break;
                    else

                        [sPath, sFileName, sExt] = fileparts(sFileInput);

                        if numel(tObject.names) >1 
            
                            if jj == numel(tObject.names)
                                
                                if i == numel(atListing)
                                    bInitDisplay = true;
                                else
                                    bInitDisplay = false;
                                end
                            else
                                bInitDisplay = false;
                            end                   
                        else
                            bInitDisplay = true;
                        end 
                        switch lower(sExt)
                
                            case '.nii'
                                loadNIIFile([sPath '/'], sprintf('%s%s',sFileName, sExt), bInitDisplay, []);   
            
                            case '.nrrd'
                                loadNrrdFile([sPath '/'], sprintf('%s%s',sFileName, sExt), bInitDisplay, []);   
                                        
                            case '.raw'
                               
                            case '.stl'
                        end
                    end                   
                end
            end

        end
    end
end