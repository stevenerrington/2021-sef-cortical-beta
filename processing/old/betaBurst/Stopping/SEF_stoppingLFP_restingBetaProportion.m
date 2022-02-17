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
    
    [betaOutput] = thresholdBursts(betaOutput.betaOutput, betaOutput.betaOutput.medianLFPpower*6);
    
    trials = [];
    trials.canceled = executiveBeh.ttx_canc{session};
    trials.noncanceled = executiveBeh.ttx.sNC{session};
    trials.nostop = executiveBeh.ttx.GO{session};
    
    baseline_betaBurstFlag = [];
    target_betaBurstFlag = [];
    
    
    for trl = 1:length(betaOutput.burstData.burstTime)
        baseline_betaBurstFlag(trl,:) = ~isempty(find(betaOutput.burstData.burstTime{trl} >= baselineWin(1) &...
            betaOutput.burstData.burstTime{trl} <= baselineWin(2)));
        
        target_betaBurstFlag(trl,:) = ~isempty(find(betaOutput.burstData.burstTime{trl} >= targetWin(1) &...
            betaOutput.burstData.burstTime{trl} <= targetWin(2)));
    end
    
    betaBaseline_LFP_noncanc(lfpIdx,1) = mean(baseline_betaBurstFlag(executiveBeh.ttx.sNC{session}));
    betaBaseline_LFP_canc(lfpIdx,1) = mean(baseline_betaBurstFlag(executiveBeh.ttx_canc{session}));
    betaBaseline_LFP_nostop(lfpIdx,1) = mean(baseline_betaBurstFlag(executiveBeh.ttx.GO{session}));
    
    targetBaseline_LFP_noncanc(lfpIdx,1) = mean(target_betaBurstFlag(executiveBeh.ttx.sNC{session}));
    targetBaseline_LFP_canc(lfpIdx,1) = mean(target_betaBurstFlag(executiveBeh.ttx_canc{session}));
    targetBaseline_LFP_nostop(lfpIdx,1) = mean(target_betaBurstFlag(executiveBeh.ttx.GO{session}));
end

[mean(betaBaseline_LFP_canc), sem(betaBaseline_LFP_canc)]*100
[mean(betaBaseline_LFP_nostop), sem(betaBaseline_LFP_nostop)]*100
[mean(betaBaseline_LFP_noncanc), sem(betaBaseline_LFP_noncanc)]*100

[mean(targetBaseline_LFP_canc), sem(betaBaseline_LFP_canc)]*100
[mean(targetBaseline_LFP_nostop), sem(betaBaseline_LFP_nostop)]*100
[mean(targetBaseline_LFP_noncanc), sem(betaBaseline_LFP_noncanc)]*100



%%
session = sessionLFPmap.session(corticalLFPcontacts.all);
monkey = sessionLFPmap.monkeyName(corticalLFPcontacts.all);

betaBurstTable = table(session, monkey,...
    betaBaseline_LFP_canc, betaBaseline_LFP_noncanc, betaBaseline_LFP_nostop,...
    targetBaseline_LFP_canc, targetBaseline_LFP_noncanc, targetBaseline_LFP_nostop);

writetable(betaBurstTable,...
    'D:\projectCode\project_stoppingLFP\data\exportJASP\LFP_pBurst_resting.csv','WriteRowNames',true)
