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
    loadname = fullfile('betaBurst','target',['lfp_session' int2str(session) '_' sessionLFPmap.channelNames{lfp} '_betaOutput_target']);
    betaOutput = parload(fullfile(fullfile(dataDir,'lfp'), loadname));
    
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


%% EEG
% Extract data from files
% For each session
for sessionIdx = 1:29
    % Get the admin/details
    session = sessionIdx;
    fprintf('Analysing session %i of %i. \n',session, 29)
    
    % Load in EEG data from directory & threshold bursts
    eegDir = fullfile(driveDir,'project_stoppingEEG','data','monkeyEEG');
    eegName = fullfile('betaBurst',['eeg_session' int2str(session) '_' FileNames{session} '_betaOutput_target']);
    eegBetaBurst = parload([eegDir eegName]);
    [eegBetaBurst] = thresholdBursts_EEG(eegBetaBurst.betaOutput, eegBetaBurst.betaOutput.medianLFPpower*6);
    
    
    baseline_betaBurstFlag_EEG = [];
    target_betaBurstFlag_EEG = [];
    trials = []; trials = find(~isnan(executiveBeh.TrialEventTimes_Overall{session}(:,2)));
    
    for trlIdx = 1:length(trials)
        trl = trials(trlIdx);
        
        baseline_betaBurstFlag_EEG(trlIdx,:) = ~isempty(find(eegBetaBurst.burstData.burstTime{trl} >= baselineWin(1) &...
            eegBetaBurst.burstData.burstTime{trl} <= baselineWin(2)));
        
        target_betaBurstFlag_EEG(trlIdx,:) = ~isempty(find(eegBetaBurst.burstData.burstTime{trl} >= targetWin(1) &...
            eegBetaBurst.burstData.burstTime{trl} <= targetWin(2)));
    end
    
    betaBaseline_EEG_all(sessionIdx,1) = mean(baseline_betaBurstFlag_EEG);
    targetBaseline_EEG_all(sessionIdx,1) = mean(target_betaBurstFlag_EEG);
end


%%

[mean(betaBaseline_LFP_all), sem(betaBaseline_LFP_all)]*100
[mean(targetBaseline_LFP_all), sem(targetBaseline_LFP_all)]*100

[mean(betaBaseline_EEG_all), sem(betaBaseline_EEG_all)]*100
[mean(targetBaseline_EEG_all), sem(targetBaseline_EEG_all)]*100



