function aImage = readDcm4che3(fileInput, din)
%function aImage = readDcm4che3(fileInput, din)
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

%        try 
%            din = org.dcm4che.io.DicomInputStream(...
%                    java.io.BufferedInputStream(java.io.FileInputStream(char(fileInput))));    
%        catch 
%           aImage = ''; 
%           return;
%        end  

%        dataset = din.readDataset(-1, -1);
%        pixeldata = dataset.getInts(org.dcm4che.data.Tag.PixelData);

%        rows = dataset.getInt(org.dcm4che.data.Tag.Rows, 0);
%        cols = dataset.getInt(org.dcm4che.data.Tag.Columns,0);

if 0
    pixeldata = din.pixeldata;

    rows = din.rows;
    cols = din.cols;
%        frames = din.nbOfFrames;

    try
        pixeldata2 = unir_numeros(pixeldata,rows,cols);

        aImg = reshape(pixeldata2, cols, rows);

        aAlignImage = zeros(rows, cols);
        for ii =1 :rows-1
            for j=1 :cols-1
                aAlignImage(ii, j)= aImg(cols-j,ii);
            end
        end

        aImage = aAlignImage(1:rows,cols:-1:1);
   catch
        aImage = dicomread(char(fileInput));
    end
else
    aImage = dicomread(char(fileInput));
end

    function pixeldata2 = unir_numeros(pixeldata, rows, cols)
        pixeldata2 = zeros(rows*cols, 1);
        fin = rows*cols*2;
        cont = 0;
        for jj = 1:2:fin
            A = pixeldata(jj);
            B = pixeldata(jj+1);
            cont = cont + 1;
            pixeldata2(cont,1) = A + B*65535;
        end
    end

end