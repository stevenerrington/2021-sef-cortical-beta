function CSDanalysis_blCorr = CSD_blCorr(CSDanalysis, baselineWin)

nDepths = size(CSDanalysis,1);
nTimes = size(CSDanalysis,2);
nTrls = size(CSDanalysis,3);

for depthIdx = 1:nDepths
    for trlIdx = 1:nTrls
        
        baselineMean = nanmean(CSDanalysis(depthIdx,baselineWin,trlIdx));
        
        CSDanalysis_blCorr(depthIdx,:,trlIdx) = ...
            CSDanalysis(depthIdx,:,trlIdx) - baselineMean;
    end
end

