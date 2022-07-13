function [pTrl_burst] = ssdBurstCount_LFP(betaOutput, ssrt, trials, session, executiveBeh)


for trl = 1:size(betaOutput.burstData,1)
    
    targetTime = executiveBeh.SessionInfo{session}.Curr_SSD (trl); 
   % executiveBeh.TrialEventTimes_Overall{session}(trl,3)-...
   %executiveBeh.TrialEventTimes_Overall{session}(trl,2);
    
    baselineWin_target = [-200-ssrt, -200];
    baselineWin_ssd = baselineWin_target + -targetTime;
   
    baselineBetaIdx = find(betaOutput.burstData.burstTime{trl} < baselineWin_ssd(2) &...
        betaOutput.burstData.burstTime{trl} > baselineWin_ssd(1));
    
    nBaseline_bursts(trl,1) = length(baselineBetaIdx);
    
    ssdBetaIdx = find(betaOutput.burstData.burstTime{trl} > 0 &...
        betaOutput.burstData.burstTime{trl} < ssrt);
    
    nSSD_bursts(trl,1) = length(ssdBetaIdx);
    
  
    
end

pTrl_burst.baseline.canceled = sum(nBaseline_bursts(trials.canceled) > 0)./length(trials.canceled);
pTrl_burst.baseline.noncanc = sum(nBaseline_bursts(trials.noncanceled) > 0)./length(trials.noncanceled);
pTrl_burst.baseline.nostop = sum(nBaseline_bursts(trials.nostop) > 0)./length(trials.nostop);

pTrl_burst.ssd.canceled = sum(nSSD_bursts(trials.canceled) > 0)./length(trials.canceled);
pTrl_burst.ssd.noncanc = sum(nSSD_bursts(trials.noncanceled) > 0)./length(trials.noncanceled);
pTrl_burst.ssd.nostop = sum(nSSD_bursts(trials.nostop) > 0)./length(trials.nostop);
