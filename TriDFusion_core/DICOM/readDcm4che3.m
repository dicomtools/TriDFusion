function aImage = readDcm4che3(fileInput, ~)
%function aImage = readDcm4che3(fileInput, ~)
%Return the dicom buffer.
% An example of how to use the dcm4che toolkit from matlab for file
% reading or other dicom functions.
%
% authors: dimitri.pianeta@gmail.com and Alberto Molano
% version : september 2011
%
% An example of how to use the dcm4che toolkit from matlab for file
% reading or other dicom functions.
%
% Step 1 is to download the toolkit from www.dcm4che.org. Select the
% dcm4che2 tookit 'bin' archive, and unzip it.
%
% Then add the java libraries to your path
% version 3  RT 
%
% Example: 
%  readDcm4che2_2('D:\CHU\stage10\dcm4che2
%  matlab\dcm4che-2.0.22-bin\dcm4che-2.0.22\lib\','D:\CHU\stage10\pr
%  ojet original et finale\00000001'')
% 
% 
%pathDcm4che = 'D:\langage
%informatique\dcm4che\dcm4che-2.0.25-bin\dcm4che-2.0.25\lib\';
%testfile = 'C:\Users\Dimitri\Desktop\00000000';
% fileInput : path package java dcm4che2 
% pathDcm4che : path package dcm4che2
% fileInput: noun and path file extension .dcm or no-extension dicom 

% if 0
% 
%     try
% 
%         rows = info.Rows;
%         cols = info.Columns;
%         pixeldata = info.PixelData;
% 
% 
%         pixeldata2 = unir_numeros(pixeldata,rows,cols);
% 
%         img= reshape(pixeldata2 , cols,rows);
% 
%          image = zeros(rows,cols);
%          for i =1 :rows-1
%              for j=1 :cols-1
%           image(i, j)= img(cols-j,i);
%              end
%          end
% 
%         aImage=image(1:rows,cols:-1:1);
% 
% 
% 
%     catch
%         aImage = dicomread(char(fileInput));
%     end
% else
    aImage = dicomread(char(fileInput));
% end
% 
%     function pixeldata2 = unir_numeros(pixeldata, rows, cols)
%         pixeldata2 = zeros(rows*cols, 1);
%         fin = rows*cols*2;
%         cont = 0;
%         for ii = 1:2:fin
%             A = pixeldata(ii);
%             B = pixeldata(ii+1);
%             cont = cont + 1;
%             pixeldata2(cont,1) = A + B*65535;
%         end
%     end

end