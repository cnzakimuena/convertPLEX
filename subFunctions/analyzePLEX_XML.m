
function [patientData, timeSeries] = analyzePLEX_XML(labelDir, fileLoc, fileName)

% This function reads the PLEX Elite 9000 XML files and extracts the most
% relevant parameters. It gives back the struct patientData and
% thetable TimeSeries.
% patientData contains patient information
% timeSeries has details of every single image acquiered

% JM (20150706):
% I rewrote this file to look for node names, instead of hardcoded node
% number. The reason for doing this is that
% for some XML files the node numbers just below patientNode have slightly
% different order, messing up everything. For these cases, the study node
% was in the same index as the Sex node was before.

% The code is still cryptic because the XML file is cryptic. At least now
% it will work regardless of the nodes order, and it will be easier to find
% bugs, since the error will show which node is missing.

% JM (20160531):
% I simplified the function, and changed timeSeries to be table instead of
% a struct array.

% CBN (20180627):
% Adapted the function from its original Spectralis-intended use to 
% gathering PLEX Elite 9000 XML and extracted image files data

patientData = [];
timeSeries  = [];

allXMLfields = parseXML(fileName);
if isempty(allXMLfields), return, end

% function strcmp(s1,s2) compares strings s1 and s2

patientNode = allXMLfields.Children(strcmp({allXMLfields.Children(:).Name},'PATIENT'));
if isempty(patientNode), return, end
personNameNode = patientNode.Children(strcmp({patientNode.Children(:).Name},'PERSON_NAME'));
if isempty(personNameNode), return, end
alphabetNode = personNameNode.Children(strcmp({personNameNode.Children(:).Name},'ALPHABETIC_COMPONENT'));

if isempty(alphabetNode)
    error('No patient data in XML file.')
end

patientData.LastName  = alphabetNode.Children(strcmp({alphabetNode.Children(:).Name},'LAST_NAME')).Children(1).Data;
patientData.FirstName = alphabetNode.Children(strcmp({alphabetNode.Children(:).Name},'FIRST_NAME')).Children(1).Data;
patientData.BirthDate = patientNode.Children(strcmp({patientNode.Children(:).Name},'BIRTH_DATE')).Children(1).Data;
patientData.Sex       = patientNode.Children(strcmp({patientNode.Children(:).Name},'GENDER')).Children(1).Data;

visitNode = patientNode.Children(strcmp({patientNode.Children(:).Name},'VISITS'));
if isempty(visitNode), return, end
studyNodes = visitNode.Children(strcmp({visitNode.Children(:).Name},'STUDY'));

% the xml file is updated with additional study nodes for every visit;
% the code is designed to gather data for the study node
% corresponding to the date common to all .img files;
% 'IMGExportFiles' folder should only contain current visit .img files

imgFileName = labelDir(1).name;
labelName = get_imgID(imgFileName);
visitDate = labelName(1:8);

for hh = 1:numel(studyNodes)
    currStudyNode = studyNodes(hh);
    dateNode = currStudyNode.Children(strcmp({currStudyNode.Children(:).Name},'VISIT_DATE')).Children.Data;
    dateNode(regexp(dateNode ,'[-]'))=[];
    if dateNode == visitDate
    studyNode = studyNodes(hh);
    end
end
if isempty(studyNode)
    error('No study data in XML file.')
end
if size(studyNode.Children, 2) < 14
    error('This case is not implemented after the changes in this file. Implement it when this error mesage comes out. (JM)')
end

seriesNode = studyNode.Children(strcmp({studyNode.Children(:).Name},'SERIES'));
if isempty(seriesNode)
    error('No series data in XML file.')
end

scanNodes = seriesNode.Children(strcmp({seriesNode.Children(:).Name},'SCAN'));

% Number of elements in the column vector corresponds to the addition of
% all of the 'FRAME_ACQUIRED_COUNTER_STAMP' for all scans for which the
% protocol contains the string 'Angio'

totalColumns = 0;
for h = 1:numel(scanNodes)
    currScanNodes = scanNodes(h).Children;
    protoStr = currScanNodes(strcmp({currScanNodes(:).Name},'PROTOCOL')).Children.Data;
    if contains(protoStr, 'Angio')
        alltrackNode = scanNodes(h).Children(strcmp({scanNodes(h).Children(:).Name},'TRACKINGDETAILS'));
        allframeNodes = alltrackNode.Children(strcmp({alltrackNode.Children(:).Name},'FRAME_ACQUIRED_COUNTER_STAMP'));
        totalColumns = totalColumns + numel(allframeNodes);
    end
end
col = zeros(totalColumns, 1);
colc = cell(totalColumns, 1);

timeSeries = table(colc,colc,colc,colc,colc,colc,col,colc,col,col,colc,colc,colc,colc,col,col, ...
    'VariableNames',{'protocol' 'date' 'hour' 'minute' 'second' ...
    'site' 'signalStrength' 'fundusfileName' ...
    'fwidth' 'fheight' 'cubefileName' 'cubefilePath' ...
    'flowfileName' 'flowfilePath' 'width' 'height'});

k = 0;
for q = 1:numel(scanNodes)
    thisScanNodes = scanNodes(q).Children;
    protoStr = thisScanNodes(strcmp({thisScanNodes(:).Name},'PROTOCOL')).Children.Data;
    if contains(protoStr, 'Angio')
        trackNode = thisScanNodes(strcmp({thisScanNodes(:).Name},'TRACKINGDETAILS'));
        frameNodes = trackNode.Children(strcmp({trackNode.Children(:).Name},'FRAME_ACQUIRED_COUNTER_STAMP'));
        b = k;
        for i = 1:numel(frameNodes)
            k = b + i;
            
            % Scan information
            timeSeries{k,'protocol'} = {thisScanNodes(strcmp({thisScanNodes(:).Name},'PROTOCOL')).Children.Data};
            dateTime = thisScanNodes(strcmp({thisScanNodes(:).Name},'DATE_TIME')).Children.Data;
            dateData = dateTime(1:10);
            hourData = dateTime(12:13);
            minuteData = dateTime(15:16);
            secondData = dateTime(18:19);
            timeSeries{k,'date'} = {dateData};
            timeSeries{k,'hour'}   = {hourData};
            timeSeries{k,'minute'} = {minuteData};
            timeSeries{k,'second'} = {secondData};
            timeSeries{k,'site'} = {thisScanNodes(strcmp({thisScanNodes(:).Name},'SITE')).Children.Data};
            czmsetNode = thisScanNodes(strcmp({thisScanNodes(:).Name},'CZMOCTSETTINGS'));
            
            % Image quality information
            timeSeries{k,'signalStrength'} = str2num(czmsetNode.Children(strcmp({czmsetNode.Children(:).Name},'SIGNALSTRENGTH')).Children.Data);
            
            scanPro = char(timeSeries{k,'protocol'});
            scanSite = char(timeSeries{k,'site'});
            scanType = scanPro(8:9);
            
            folderID = erase(erase(erase(dateTime, '-'), ':'), 'T');
            if strcmp(scanType, '3m')
                folder = fullfile(fileLoc, ['3mmx3mm' '_' folderID ...
                    '_' scanSite]);
            elseif strcmp(scanType, '6m')
                folder = fullfile(fileLoc, ['6mmx6mm' '_' folderID ...
                    '_' scanSite]);
            elseif strcmp(scanType, '9m')
                folder = fullfile(fileLoc, ['9mmx9mm' '_' folderID ...
                    '_' scanSite]);
            elseif strcmp(scanType, '12')
                folder = fullfile(fileLoc, ['12mmx12mm' '_' folderID ...
                    '_' scanSite]);
            elseif strcmp(scanType, '15')
                folder = fullfile(fileLoc, ['15mmx9mm' '_' folderID ...
                    '_' scanSite]);
            end
            
            % Fundus information
            fundusNameDir = dir(fullfile(folder, '*Structure_Retina.bmp'));
            ffName = fundusNameDir.name;
            fundusIm = imread(fullfile(folder, ffName));
            [fh,fw,~] = size(fundusIm);
            timeSeries{k,'fundusfileName'} = {ffName};
            timeSeries{k,'fwidth'}  = fw;
            timeSeries{k,'fheight'} = fh;
            
            % B-scan information
            scanNum = num2str(i, '%03.0f');
     
            subfolderStruc = dir(fullfile(folder, '*_cube_z'));
            subfolder = subfolderStruc.name;
            subfolderDir = dir(fullfile(folder, subfolder, '*.png'));
            for w = 1:numel(subfolderDir)
                scanFileName = [];
                if contains(subfolderDir(w).name,scanNum)
                    scanFileName = subfolderDir(w).name;
                end
                if strcmp(scanFileName, subfolderDir(w).name)
                    break
                end
            end
            timeSeries{k,'cubefileName'} = {scanFileName};
            timeSeries{k,'cubefilePath'} = {fullfile(folder, subfolder, scanFileName)};
            
            subfolderFlow = dir(fullfile(folder, '*_FlowCube_z'));
            subfolder2 = subfolderFlow.name;
            subfolder2Dir = dir(fullfile(folder, subfolder2, '*.png'));
            for ww = 1:numel(subfolder2Dir)
                scanFileName2 = [];
                if contains(subfolder2Dir(ww).name,scanNum)
                    scanFileName2 = subfolder2Dir(ww).name;
                end
                if strcmp(scanFileName2, subfolder2Dir(ww).name)
                    break
                end
            end
            timeSeries{k,'flowfileName'} = {scanFileName2};
            timeSeries{k,'flowfilePath'} = {fullfile(folder, subfolder2, scanFileName2)};
            
            scanFile = imread(fullfile(folder, subfolder, scanFileName));
            [sh,sw] = size(scanFile);
            timeSeries{k,'width'}  = sw;
            timeSeries{k,'height'} = sh;

        end
    end
    
end

end

    



