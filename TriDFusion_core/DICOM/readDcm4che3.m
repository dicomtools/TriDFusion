function aImage = readDcm4che3(fileInput, info)
%function aImage = readDcm4che3(fileInput, info)
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
        
     aReshaped = reshape(info.din.pixeldata, info.din.cols, info.din.rows);
     aImage    = cast(zeros(info.din.rows, info.din.cols), class(info.din.pixeldata));
     
     for i =1 :info.din.rows-1
        for j=1 :info.din.cols-1
            aImage(i, j)= aReshaped(info.din.cols-j,i);
        end
     end

    aImage = aImage(1:dinfo.in.rows, info.din.cols:-1:1);
    clear aReshaped;
    
    catch
        aImage = dicomread(char(fileInput));
    end
else
    aImage = dicomread(char(fileInput));
%     aImage = rgb2gray(aImage);
end


end