function call_convertPLEX()

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name - call_convertPLEX
% Creation Date - 15th January 2021
% Author - Charles Belanger Nzakimuena
% Website - https://www.ibis-space.com/
%
% Description - 
%   CONVERTPLEX converts .img files to image data usable with matlab
%   varargin is the current patient folder
%
%   - conversion of the .img data to .png images format
%   - analysis of the xml file (analyzePLEX_XML) and storage of all
%   the useful data in a table called IMAGELIST stored in the
%   'DataFile' subfolder
%   -the fundus image is also stored in the ImageList variable stored in
%   the 'DataFile' subfolder
%
% addpath(folderName1,...,folderNameN) adds the specified folders to the 
% top of the search path for the current MATLAB session
% genpath(folderName) returns a character vector containing a path name 
% that includes folderName and multiple levels of subfolders below 
% folderName (relative directory indicated by the dot symbol is collapsed 
% with the the specified folder, i.e., the subfolder 'subfunction')
%
% Example -
%		call_convertPLEX()
%
% License - MIT
%
% Change History -
%                   15th January 2020 - Creation by Charles Belanger Nzakimuena
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath(genpath('./subfunctions'))

%% list names of folders inside the patients folder

currentFolder = pwd;
patientsFolder = fullfile(currentFolder, 'raw');
myDir = dir(patientsFolder);
dirFlags = [myDir.isdir] & ~strcmp({myDir.name},'.') & ~strcmp({myDir.name},'..');
nameFolds = myDir(dirFlags);

%% for each folder, convert PLEX data into data usable by MATLAB

for i = 1:numel(nameFolds) 
        
        % assemble patient folder string
         patientFolder = fullfile(patientsFolder, nameFolds(i).name);

        try
            
            % add line to LOG
            disp(logit(patientFolder, ['Initiating convertPLEX; ' nameFolds(i).name ' folder']))
            
            % Directory of directly exported Angio .bmp images
            imAngioDir = dir(fullfile(patientFolder, '*.bmp'));
            
            % Directory of exported .img images
            imgExpFolder = char(fullfile(patientFolder, 'IMGExportFiles'));
            myDir2 = dir(imgExpFolder);
            dirFlags2 = [myDir2(:).isdir] & ~strcmp({myDir2.name},'.') & ~strcmp({myDir2.name},'..');
            nameFolds2 = myDir2(dirFlags2);
            imgFolder = char(fullfile(imgExpFolder, nameFolds2.name));
            imgDir = dir(fullfile(imgFolder,'*cube_z.img'));
            
            % Create images target directory
            if ~exist(fullfile(patientFolder, 'ProcessedImages'), 'dir')
                mkdir(fullfile(patientFolder, 'ProcessedImages'));
            end
            extractFolder = fullfile(patientFolder, 'ProcessedImages');
            
            % Move all raw images to RawImages
            
            % SORTIMANGIO sorts, renames and moves exported Angio .bmp
            % images to the 'ProcessedImages' subfolder
            sortimAngio(imAngioDir, patientFolder, extractFolder);
            
            % BSCANEXTRACT sorts and converts exported .img file and moves the
            % resulting images into the 'ProcessedImages' subfolder; the 
            % processed images' resolution and aspect ratio are specified 
            bscanExtract(imgDir, imgFolder, extractFolder);
            
            % Directory of exported .xml file
            xmlFolder = fullfile(patientFolder, 'XMLExportFiles');
            xmlDir = dir(fullfile(xmlFolder,'*.xml'));
            
            % Move xml to ProcessedImages
            for k = 1:numel(xmlDir)
                thisXML = xmlDir(k).name;
                if contains(thisXML, 'CZMI')
                    movefile(fullfile(xmlFolder, thisXML), ...
                        fullfile(extractFolder));
                end
            end
            
            % Create data target directory
            if ~exist(fullfile(patientFolder, 'DataFiles'), 'dir')
                mkdir(fullfile(patientFolder, 'DataFiles'));
            end
            
            % searches the xml file path
            xmlFile = dir(fullfile(extractFolder, '*.xml'));
            [~,ImageList] = analyzePLEX_XML(imgDir, extractFolder, ...
                fullfile(extractFolder, xmlFile.name));
            
            % Save shortlisted ImageList ('ImBrevis' files) and fundus image files
            % iteratively as .mat files
            % get only subfolders from directory
            patientDir = dir(extractFolder);
            dirFlags = [patientDir.isdir] & ~strcmp({patientDir.name},'.') & ~strcmp({patientDir.name},'..');
            subFolders = patientDir(dirFlags);
            for k = 1:numel(subFolders)
                currentFolder = subFolders(k).name;
                fundusNameDir = dir(fullfile(extractFolder, currentFolder, ...
                    '*Structure_Retina.bmp'));
                ffName = fundusNameDir.name;
                fundusIm = imread(fullfile(extractFolder, currentFolder, ffName));
                ind = cellfun(@(x) strcmp(x,ffName),ImageList.fundusfileName);
                ImBrevis = ImageList(ind, :);
                frefStr = strfind(ffName, 'Structure_Retina');
                fType = ffName(1:(frefStr(1)-2));
                if ~exist(fullfile(patientFolder,'DataFiles', fType), 'dir')
                    mkdir(fullfile(patientFolder,'DataFiles', fType));
                end
                save(fullfile(patientFolder,'DataFiles', fType, ['ImageList_' ...
                    fType '.mat']),'ImBrevis','fundusIm');
            end
            
        catch exception
            errorString = ['Error in convertPLEX. Message:' exception.message buildCallStack(exception)];
            if ~exist(fullfile(pwd,'error'), 'dir')
                mkdir(fullfile(pwd,'error'));
            end
            disp(logit(fullfile(pwd, 'error'),errorString));
            continue
        end
        
end

disp(logit(patientFolder,'Done convertPLEX'))







