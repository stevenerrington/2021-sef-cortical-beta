
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
    loadname = fullfile('betaBurst','target',['lfp_session' int2str(session) '_' sessionLFPmap.channelNames{lfp} '_betaOutput_target']);
    betaOutput = parload(fullfile(fullfile(dataDir,'lfp'), loadname));
    [betaOutput] = thresholdBursts(betaOutput.betaOutput, betaOutput.betaOutput.medianLFPpower*6);
    
    % Get GO trials \
    trials = []
    trials = sort([executiveBeh.ttx.GO{session}; executiveBeh.ttx.NC{session}]);
    
    % Get RT's within session
    sessionRT = executiveBeh.TrialEventTimes_Overall{session}(:,4) - ...
        executiveBeh.TrialEventTimes_Overall{session}(:,2);
    
    % Initialise the arrays
    burstFlag = []; RTslowing = [];
    
    % For each GO trial
    for trlIdx = 1:length(trials)
        % Get whether a burst occured within the given time window
        % post-saccade (no burst = 0, burst = 1)
        burstFlag(trlIdx,1) = double(sum((betaOutput.burstData.burstTime{trials(trlIdx)} < -200 &...
            betaOutput.burstData.burstTime{trials(trlIdx)} > -400) == 1) > 0);
        burstFlag(trlIdx,2) = double(sum((betaOutput.burstData.burstTime{trials(trlIdx)} < sessionRT(trials(trlIdx)) &...
            betaOutput.burstData.burstTime{trials(trlIdx)} > sessionRT(trials(trlIdx)) - 200) == 1) > 0);
        % Get the change in RT from the NC to the GO trial
        % minus values represent slowing, positive values represent
        % speeding.
        RTslowing(trlIdx,1) = sessionRT(trials(trlIdx));
    end
    
    % Compile the burst flag and RT adapation into one array for future use
    RT_beta_assoc{lfpIdx} = [burstFlag, RTslowing];
    
end


%%
clear pBurst_baseline_quantile pBurst_target_quantile
% For each session
for sessionIdx = 1:29
    % Find the corresponding channels
    sessionLFPch = find(corticalLFPmap.session == sessionIdx);
    
    % Get the RT distribution for the session
    RT_lfp = RT_beta_assoc{sessionLFPch(1)}(:,3);
    % Remove RT's that are too quick
    RT_lfp = RT_lfp(RT_lfp > 100);
    % Get the RT's at each quantile: 0 to 1 in 0.2 increments
    RT_quantiles = quantile(RT_lfp,[0.0 0.2 0.4 0.6 0.8 1.0]);
    
    % Initialise arrays
    burst_baseline_sessionLFP = []; burst_target_sessionLFP = [];
    burst_baseline_session = []; burst_target_session = [];
    
    % For each channel in the session
    for sessionLFPidx = 1:length(sessionLFPch)
        lfpIdx = sessionLFPch(sessionLFPidx);
        % Get a binary array for whether a burst was observed, both in the
        % baseline...
        burst_baseline_sessionLFP(:,sessionLFPidx) = RT_beta_assoc{lfpIdx}(:,1);
        % and target period...
        burst_target_sessionLFP(:,sessionLFPidx) = RT_beta_assoc{lfpIdx}(:,2);
    end
    
    % Once we have this, we can average across contacts in a session to
    % determine the p(Burst) for both baseline and target periods
    burst_baseline_session = mean(burst_baseline_sessionLFP,2);
    burst_target_session = mean(burst_target_sessionLFP,2);
    
    % For each quantile
    for quantileIdx = 1:length(RT_quantiles)-1
        % Find trials that occur within the RT quantile
        quantileTrials = [];
        quantileTrials = find(RT_lfp >= RT_quantiles(quantileIdx) & RT_lfp <= RT_quantiles(quantileIdx+1));
        
        % And use this to average across p(Burst) at baseline and target
        % period.
        pBurst_baseline_quantile(sessionIdx, quantileIdx) = mean(burst_baseline_session(quantileTrials));
        pBurst_target_quantile(sessionIdx, quantileIdx) = mean(burst_target_session(quantileTrials));
        
        % Get the mean RT of trials in this quantile.
        RT_quantile_out(sessionIdx, quantileIdx) = median(RT_lfp(quantileTrials));
                
    end
    
end

% Reshape the arrays to remove the redundant dimension
RT_all = reshape(RT_quantile_out,[],1);
pBurst_baseline_all = reshape(pBurst_baseline_quantile,[],1);
pBurst_target_all = reshape(pBurst_target_quantile,[],1);

% Get a label for each monkey for each quantile and each session, for
% figure use.
sessionLabel = {};
for sessionIdx = 1:29
    sessionLabel = [sessionLabel; repmat(executiveBeh.nhpSessions.monkeyNameLabel(sessionIdx),5,1)];
end

%% Generate figure
figure('Renderer', 'painters', 'Position', [100 100 600 600]);
rt_beta_figure(1,1)=gramm('x',RT_all,'y',pBurst_baseline_all);
rt_beta_figure(1,1).geom_point(); rt_beta_figure(1,1).stat_glm('fullrange',true,'disp_fit',true)
rt_beta_figure(1,1).axe_property('XLim',[50 550]);rt_beta_figure(1,1).axe_property('YLim',[0 0.45])

rt_beta_figure(2,1)=gramm('x',RT_all,'y',pBurst_baseline_all,'color',sessionLabel);
rt_beta_figure(2,1).geom_point(); rt_beta_figure(2,1).stat_glm('fullrange',true,'disp_fit',true)
rt_beta_figure(2,1).axe_property('XLim',[50 550]);rt_beta_figure(2,1).axe_property('YLim',[0 0.45])
rt_beta_figure(2,1).no_legend

rt_beta_figure(1,2)=gramm('x',RT_all,'y',pBurst_target_all);
rt_beta_figure(1,2).geom_point(); rt_beta_figure(1,2).stat_glm('fullrange',true,'disp_fit',true)
rt_beta_figure(1,2).axe_property('XLim',[50 550]);rt_beta_figure(1,2).axe_property('YLim',[0 0.45])

rt_beta_figure(2,2)=gramm('x',RT_all,'y',pBurst_target_all,'color',sessionLabel);
rt_beta_figure(2,2).geom_point(); rt_beta_figure(2,2).stat_glm('fullrange',true,'disp_fit',true)
rt_beta_figure(2,2).axe_property('XLim',[50 550]);rt_beta_figure(2,2).axe_property('YLim',[0 0.45])
rt_beta_figure(2,2).no_legend


rt_beta_figure.draw()
