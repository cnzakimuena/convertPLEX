
function sortimAngio(imDir, imLoc, imDes)

for k = 1:numel(imDir) 
    thisIm = imDir(k).name;
    refStr = strfind(thisIm,'Angio');
    imType = thisIm((refStr(1)+7):(refStr(1)+8));
    
    if strcmp(imType, '3m')
        folderID = ['3mmx3mm' '_' thisIm((refStr(1)+16):(refStr(1)+32))]; 
        imID = ['3mmx3mm' '_' thisIm((refStr(1)+16):(refStr(1)+32))];
        if ~exist(fullfile(imDes, folderID), 'dir')
            mkdir(fullfile(imDes, folderID));
        end
        imLabel = thisIm((refStr(1)+48):end);
        movefile(fullfile(imLoc, thisIm), fullfile(imDes, folderID, ...
            [imID imLabel]), 'f') 
    
    elseif strcmp(imType, '6m')
        folderID = ['6mmx6mm' '_' thisIm((refStr(1)+16):(refStr(1)+32))]; 
        imID = ['6mmx6mm' '_' thisIm((refStr(1)+16):(refStr(1)+32))];
        if ~exist(fullfile(imDes, folderID), 'dir')
            mkdir(fullfile(imDes, folderID));
        end
        imLabel = thisIm((refStr(1)+48):end);
        movefile(fullfile(imLoc, thisIm), fullfile(imDes, folderID, ...
            [imID imLabel]), 'f') 

    elseif strcmp(imType, '9m')
        folderID = ['9mmx9mm' '_' thisIm((refStr(1)+16):(refStr(1)+32))]; 
        imID = ['9mmx9mm' '_' thisIm((refStr(1)+16):(refStr(1)+32))];
        if ~exist(fullfile(imDes, folderID), 'dir')
            mkdir(fullfile(imDes, folderID));
        end
        imLabel = thisIm((refStr(1)+48):end);
        movefile(fullfile(imLoc, thisIm), fullfile(imDes, folderID, ...
            [imID imLabel]), 'f') 
    
    elseif strcmp(imType, '12') 
        folderID = ['12mmx12mm' '_' thisIm((refStr(1)+18):(refStr(1)+34))];
        imID = ['12mmx12mm' '_' thisIm((refStr(1)+18):(refStr(1)+34))];
        if ~exist(fullfile(imDes, folderID), 'dir')
            mkdir(fullfile(imDes, folderID));
        end
        imLabel = thisIm((refStr(1)+50):end);
        movefile(fullfile(imLoc, thisIm), fullfile(imDes, folderID, ...
            [imID imLabel]), 'f') 
    
    elseif strcmp(imType, '15')
        folderID = ['15mmx9mm' '_' thisIm((refStr(1)+17):(refStr(1)+33))];
        imID = ['15mmx9mm' '_' thisIm((refStr(1)+17):(refStr(1)+33))];
        if ~exist(fullfile(imDes, folderID), 'dir')
            mkdir(fullfile(imDes, folderID));
        end
        imLabel = thisIm((refStr(1)+49):end);
        movefile(fullfile(imLoc, thisIm), fullfile(imDes, folderID, ...
            [imID imLabel]), 'f') 
        
    end
    
end

end