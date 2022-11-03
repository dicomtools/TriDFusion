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

if 0

    try
        
     aReshaped = reshape(din.pixeldata, din.cols, din.rows);
     aImage    = cast(zeros(din.rows, din.cols), class(din.pixeldata));
     
     for i =1 :din.rows-1
        for j=1 :din.cols-1
            aImage(i, j)= aReshaped(din.cols-j,i);
        end
     end

    aImage = aImage(1:din.rows, din.cols:-1:1);
    clear aReshaped;
    
    catch
        aImage = dicomread(char(fileInput));
    end
else
    aImage = dicomread(char(fileInput));
end


end