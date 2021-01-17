
function imgID = get_imgID(fileName)

refStr1 = strfind(fileName, 'mm)_');
refStr2 = strfind(fileName, '_O');
rawSOI = fileName((refStr1(1)+4):(refStr2(1)-1));
refYR = strfind(rawSOI, '_');

% get year string
yrStr = rawSOI((refYR-4):(refYR-1));
% get month string
if rawSOI(2) == '-'
    moStr = ['0' rawSOI(1)];
else
    moStr = rawSOI(1:2);
end
% get day string
if rawSOI(refYR-7) == '-'
    dyStr = ['0' rawSOI(refYR-6)];
else
    dyStr = rawSOI((refYR-7):(refYR-6));
end

% get hour string
if rawSOI(refYR+2) == '-'
    hrStr = ['0' rawSOI(refYR+1)];
else
    hrStr = rawSOI((refYR+1):(refYR+2));
end
%get second string
if fileName(refStr2-2) == '-'
    scStr = ['0' fileName(refStr2-1)];
else
    scStr = fileName((refStr2-2):(refStr2-1));
end
%get minute string
if rawSOI(refYR+2) == '-'
    refMN = refYR+3;
else 
    refMN = refYR+4;
end
if rawSOI(refMN+1) == '-'
    mnStr = ['0' rawSOI(refMN)];
else
    mnStr = rawSOI(refMN:(refMN+1));
end 

imgID = [yrStr moStr dyStr hrStr mnStr scStr];

end
