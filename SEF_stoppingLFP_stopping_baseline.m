%% Calculate proportion of trials with burst

baselineWin = [-400 -200];
targetWin = [0 200];

parfor lfpIdx = 1:length(corticalLFPcontacts.all)
    
    lfp = corticalLFPcontacts.all(lfpIdx)
    session = sessionLFPmap.session(lfp);   
    
    % Get session name (to load in relevant file)
    sessionName = FileNames{session};
    fprintf('Analysing LFP number %i of %i. \n',lfpIdx,length(corticalLFPcontacts.all));
    
    % Load in beta output data for session
    loadname = ['betaBurst\target\lfp_session' int2str(session) '_' sessionLFPmap.channelNames{lfp} '_betaOutput_target'];
    betaOutput = parload([outputDir loadname]);
    
    [betaOutput] = thresholdBursts(betaOutput.betaOutput, sessionThreshold(session));
    
    baseline_betaBurstFlag = [];
    target_betaBurstFlag = [];
    trials = []; trials = find(~isnan(executiveBeh.TrialEventTimes_Overall{session}(:,2)))
    
    for trlIdx = 1:length(trials)
        trl = trials(trlIdx);
        
        baseline_betaBurstFlag(trlIdx,:) = ~isempty(find(betaOutput.burstData.burstTime{trl} >= baselineWin(1) &...
            betaOutput.burstData.burstTime{trl} <= baselineWin(2)));
        
        target_betaBurstFlag(trlIdx,:) = ~isempty(find(betaOutput.burstData.burstTime{trl} >= targetWin(1) &...
            betaOutput.burstData.burstTime{trl} <= targetWin(2)));
    end
    
    betaBaseline_LFP_all(lfpIdx,1) = mean(baseline_betaBurstFlag);
    targetBaseline_LFP_all(lfpIdx,1) = mean(target_betaBurstFlag);
end

[mean(betaBaseline_LFP_all), sem(betaBaseline_LFP_all)]*100
[mean(targetBaseline_LFP_all), sem(betaBaseline_LFP_all)]*100

