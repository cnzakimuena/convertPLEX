
function bscanExtract(filesDir, filesLoc, filesDes)

for k = 1:numel(filesDir)
    thisImg = filesDir(k).name;
    
    if contains(thisImg, 'Angio')
        refStr = strfind(thisImg,'Angio');
        imgType = thisImg((refStr(1)+7):(refStr(1)+8));
        fid = fopen(fullfile(filesLoc, thisImg));
        curr_imgID = get_imgID(thisImg);                                     
        if strcmp(imgType, '3m')
            snRef = strfind(thisImg,'sn');
            folderID = ['3mmx3mm' '_' curr_imgID thisImg((snRef(1)-4):(snRef(1)-2))];   
            imID = ['3mmx3mm' '_' curr_imgID thisImg((snRef(1)-4):(snRef(1)-2)) thisImg((snRef(1)+6):(end-4))];           
            if ~exist(fullfile(filesDes, folderID), 'dir')
                mkdir(fullfile(filesDes, folderID));
            end            
            if ~exist(fullfile(filesDes, folderID, imID), 'dir')
                mkdir(fullfile(filesDes, folderID, imID));
            end
            try
                i = 0;
                while ~feof(fid)
                    im = flipud(fread(fid,[300 1536], 'uint8=>uint8')');
                    im = mat2gray(im);
%                     % Image resizing provides consistent resolution across
%                     % both axial and transverse directions 
%                     im = imresize(im, [300 300]);
                    im = imresize(im, [1536 1536]);
                    i = i + 1;                    

                    imwrite(im, fullfile(filesDes, folderID, imID, ...
                        [imID '_' num2str(i, '%03.0f') '.png']))
                end
            catch
            fclose(fid);
            end
 
        elseif strcmp(imgType, '6m')
            snRef = strfind(thisImg,'sn');
            folderID = ['6mmx6mm' '_' curr_imgID thisImg((snRef(1)-4):(snRef(1)-2))]; 
            imID = ['6mmx6mm' '_' curr_imgID thisImg((snRef(1)-4):(snRef(1)-2)) thisImg((snRef(1)+6):(end-4))]; 
            if ~exist(fullfile(filesDes, folderID), 'dir')
                mkdir(fullfile(filesDes, folderID));
            end            
            if ~exist(fullfile(filesDes, folderID, imID), 'dir')
                mkdir(fullfile(filesDes, folderID, imID));
            end
            try
                i = 0;
                while ~feof(fid)
                    im = flipud(fread(fid,[500 1536], 'uint8=>uint8')');
                    im = mat2gray(im);
%                     im = imresize(im, [250 500]);
                    im = imresize(im, [1536 3072]);  
                    i = i + 1;
                    imwrite(im, fullfile(filesDes, folderID, imID, ...
                        [imID '_' num2str(i, '%03.0f') '.png']))
                end
            catch
            fclose(fid);
            end        

        elseif strcmp(imgType, '9m')
            snRef = strfind(thisImg,'sn');
            folderID = ['9mmx9mm' '_' curr_imgID thisImg((snRef(1)-4):(snRef(1)-2))]; 
            imID = ['9mmx9mm' '_' curr_imgID thisImg((snRef(1)-4):(snRef(1)-2)) thisImg((snRef(1)+6):(end-4))]; 
            if ~exist(fullfile(filesDes, folderID), 'dir')
                mkdir(fullfile(filesDes, folderID));
            end            
            if ~exist(fullfile(filesDes, folderID, imID), 'dir')
                mkdir(fullfile(filesDes, folderID, imID));
            end
            try
                i = 0;
                while ~feof(fid)
                    im = flipud(fread(fid,[500 1536], 'uint8=>uint8')');
                    im = mat2gray(im);
                    im = imresize(im, [167 500]);
%                     im = imresize(im, [1536 4608]);  
                    i = i + 1;
%                     imwrite(im, fullfile(filesDes, folderID, imID, ...
%                         [imID '_' num2str(i, '%03.0f') '.png']))
                end
            catch
            fclose(fid);
            end
            
        elseif strcmp(imgType, '12')
            snRef = strfind(thisImg,'sn');
            folderID=['12mmx12mm' '_' curr_imgID thisImg((snRef(1)-4):(snRef(1)-2))]; 
            imID = ['12mmx12mm' '_' curr_imgID thisImg((snRef(1)-4):(snRef(1)-2)) thisImg((snRef(1)+6):(end-4))]; 
            if ~exist(fullfile(filesDes, folderID), 'dir')
                mkdir(fullfile(filesDes, folderID));
            end            
            if ~exist(fullfile(filesDes, folderID, imID), 'dir')
                mkdir(fullfile(filesDes, folderID, imID));
            end
            try
                i = 0;
                while ~feof(fid)
                    im = flipud(fread(fid,[500 1536], 'uint8=>uint8')');
                    im = mat2gray(im);
%                     im = imresize(im, [125 500]);
%                     im = imresize(im, [1536 6144]);  
                    i = i + 1;
%                     imwrite(im, fullfile(filesDes, folderID, imID, ...
%                         [imID '_' num2str(i, '%03.0f') '.png']))
                end
            catch
            fclose(fid);
            end   

        elseif strcmp(imgType, '15')
            snRef = strfind(thisImg,'sn');
            folderID = ['15mmx9mm' '_' curr_imgID thisImg((snRef(1)-4):(snRef(1)-2))]; 
            imID = ['15mmx9mm' '_' curr_imgID thisImg((snRef(1)-4):(snRef(1)-2)) thisImg((snRef(1)+6):(end-4))]; 
            if ~exist(fullfile(filesDes, folderID), 'dir')
                mkdir(fullfile(filesDes, folderID));
            end            
            if ~exist(fullfile(filesDes, folderID, imID), 'dir')
                mkdir(fullfile(filesDes, folderID, imID));
            end
            try
                i = 0;
                while ~feof(fid)
                    im = flipud(fread(fid,[500 1536], 'uint8=>uint8')');
                    im = mat2gray(im);
%                     im = imresize(im, [167 500]);
%                     im = imresize(im, [1536 4608]);  
                    i = i + 1;
%                     imwrite(im, fullfile(filesDes, folderID, imID, ...
%                         [imID '_' num2str(i, '%03.0f') '.png']))
                end
            catch
            fclose(fid);
            end 
       
        end
        
    end
    
end

end
