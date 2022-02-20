
%% Extract relevant data

% For each LFP in cortex
parfor lfpIdx = 1:length(corticalLFPcontacts.all)
    
    % Get the relative index and session
    lfp = corticalLFPcontacts.all(lfpIdx);
    session = sessionLFPmap.session(lfp);
    
    % Get session name (to load in relevant file)
    sessionName = FileNames{session};
    fprintf('Analysing LFP number %i of 509. \n',lfpIdx);
    
    % Load in beta output data for session
    loadname = ['betaBurst\target\lfp_session' int2str(session) '_' sessionLFPmap.channelNames{lfp} '_betaOutput_target'];
    betaOutput = parload([outputDir loadname]);
    [betaOutput] = thresholdBursts(betaOutput.betaOutput, betaOutput.betaOutput.medianLFPpower*6);
    
    % Get GO trials following NC, and the preceding NC trial (these are
    % paired)
    trialGO = executiveBeh.Trials.all{session}.t_GO_after_NC;
    
    % Get RT's within session
    sessionRT = executiveBeh.TrialEventTimes_Overall{session}(:,4) - ...
        executiveBeh.TrialEventTimes_Overall{session}(:,2);
    
    % Initialise the arrays
    burstFlag = []; RTslowing = [];
    
    % For each GO trial
    for trlIdx = 1:length(trialGO)
        % Get whether a burst occured within the given time window
        % post-saccade (no burst = 0, burst = 1)
        window = [0 100]
        burstFlag(trlIdx,1) = double(sum((betaOutput.burstData.burstTime{trialGO(trlIdx)} < window(2) &...
            betaOutput.burstData.burstTime{trialGO(trlIdx)} > window(1)) == 1) > 0);
        burstFlag(trlIdx,2) = double(sum((betaOutput.burstData.burstTime{trialGO(trlIdx)} < sessionRT(trialGO(trlIdx)) &...
            betaOutput.burstData.burstTime{trialGO(trlIdx)} > sessionRT(trialGO(trlIdx)) - 200) == 1) > 0);
        % Get the change in RT from the NC to the GO trial
        % minus values represent slowing, positive values represent
        % speeding.
        RTslowing(trlIdx,1) = sessionRT(trialGO(trlIdx));
    end
    
    % Compile the burst flag and RT adapation into one array for future use
    RT_beta_assoc{lfpIdx} = [burstFlag, RTslowing];
    
end


%%
clear pBurst_baseline_quantile pBurst_target_quantile
for sessionIdx = 1:29
    sessionLFPch = find(corticalLFPmap.session == sessionIdx);
    
    RT_lfp = RT_beta_assoc{sessionLFPch(1)}(:,3);
    RT_lfp = RT_lfp(RT_lfp > 100);
    RT_quantiles = quantile(RT_lfp,[0.0 0.2 0.4 0.6 0.8 1.0]);
    
    burst_baseline_sessionLFP = []; burst_target_sessionLFP = [];
    burst_baseline_session = []; burst_target_session = [];
    
    for sessionLFPidx = 1:length(sessionLFPch)
        lfpIdx = sessionLFPch(sessionLFPidx);
        burst_baseline_sessionLFP(:,sessionLFPidx) = RT_beta_assoc{lfpIdx}(:,1);
        burst_target_sessionLFP(:,sessionLFPidx) = RT_beta_assoc{lfpIdx}(:,2);
    end
    
    burst_baseline_session = mean(burst_baseline_sessionLFP,2);
    burst_target_session = mean(burst_target_sessionLFP,2);
    
    
    for quantileIdx = 1:length(RT_quantiles)-1
        quantileTrials = [];
        quantileTrials = find(RT_lfp >= RT_quantiles(quantileIdx) & RT_lfp <= RT_quantiles(quantileIdx+1));
        
        pBurst_baseline_quantile(sessionIdx, quantileIdx) = mean(burst_baseline_session(quantileTrials));
        pBurst_target_quantile(sessionIdx, quantileIdx) = mean(burst_target_session(quantileTrials));
        RT_quantile_out(sessionIdx, quantileIdx) = RT_quantiles(quantileIdx);
    end
    
end


RT_all = reshape(RT_quantile_out,[],1);
pBurst_baseline_all = reshape(pBurst_baseline_quantile,[],1);
pBurst_target_all = reshape(pBurst_target_quantile,[],1);

sessionLabel = {};
for sessionIdx = 1:29
    sessionLabel = [sessionLabel; repmat(executiveBeh.nhpSessions.monkeyNameLabel(sessionIdx),5,1)];
end

%% Generate figure
figure('Renderer', 'painters', 'Position', [100 100 350 300]);
g=gramm('x',RT_all,'y',pBurst_baseline_all);
g.geom_point(); g.stat_glm('fullrange',true,'disp_fit',true)
g.axe_property('XLim',[50 450]);g.axe_property('YLim',[0 0.45])
g.draw()

figure('Renderer', 'painters', 'Position', [100 100 350 300]);
g=gramm('x',RT_all,'y',pBurst_baseline_all,'color',sessionLabel);
g.geom_point(); g.stat_glm('fullrange',true,'disp_fit',true)
g.axe_property('XLim',[50 450]);g.axe_property('YLim',[0 0.45])
g.draw()
