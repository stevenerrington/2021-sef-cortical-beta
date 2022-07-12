function [sepStart, sepEnd] = getBBDFdifference(input1,input2)

ntimeBin = length(input1);
binaryDiff = [];
for timeBinIdx = 1:ntimeBin
    binaryDiff(1,timeBinIdx) = input1(:,timeBinIdx) < input2(:,timeBinIdx);
end

[start, len, k1] = ZeroOnesCount(binaryDiff);
sepIdx = find(len(1:k1) > 50);

if length(sepIdx) > 1
    sepIdx = sepIdx(1);
end

if isempty(sepIdx)
    sepStart = NaN;
    sepEnd = NaN;
else
    sepStart = start(sepIdx);
    sepEnd = start(sepIdx)+len(sepIdx);
end