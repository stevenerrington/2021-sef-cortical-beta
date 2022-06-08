%% Calculate proportion of trials with burst (-200-SSRT to -200 ms pre-target)
parfor lfpIdx = 1:length(corticalLFPcontacts.all)
    
    lfp = corticalLFPcontacts.all(lfpIdx)
    session = sessionLFPmap.session(lfp);
    
    % Get session name (to load in relevant file)
    sessionName = FileNames{session};
    fprintf('Analysing LFP number %i of %i. \n',lfpIdx,length(corticalLFPcontacts.all));
    
    % Load in beta output data for session
    loadname_stopSignal = ['betaBurst\stopSignal\lfp_session' int2str(session) '_' sessionLFPmap.channelNames{lfp} '_betaOutput_stopSignal'];
    betaOutput_stopSignal = parload([outputDir loadname_stopSignal])
    
    % Get behavioral information
    ssrt = bayesianSSRT.ssrt_mean(session);
    
    trials = [];
    trials.canceled = executiveBeh.ttx_canc{session};
    trials.noncanceled = executiveBeh.ttx.sNC{session};
    trials.nostop = executiveBeh.ttx.GO{session};
    
    % Calculate p(trials) with burst
    [betaOutput_stopSignal] = thresholdBursts(betaOutput_stopSignal.betaOutput, sessionThreshold(session))
    [pTrl_burst] = ssdBurstCount_LFP(betaOutput_stopSignal, ssrt, trials, session, executiveBeh);
    
    baseline_canceled(lfpIdx,1) = pTrl_burst.baseline.canceled;
    baseline_noncanc(lfpIdx,1) = pTrl_burst.baseline.noncanc;
    baseline_nostop(lfpIdx,1) = pTrl_burst.baseline.nostop;
    ssd_canceled(lfpIdx,1) = pTrl_burst.ssd.canceled;
    ssd_noncanc(lfpIdx,1) = pTrl_burst.ssd.noncanc;
    ssd_nostop(lfpIdx,1) = pTrl_burst.ssd.nostop;
    
end

%% Create boxplot
time = [-1000:2000];

clear stoppingBoxplot_Figure inputLFP groupLabels epochLabels burstData
inputLFP = 1:length(corticalLFPcontacts.all);
% inputLFP = corticalLFPcontacts.subset.x;

% Boxplot
groupLabels = [repmat({'No-stop'},length(inputLFP),1); repmat({'Non-canceled'},length(inputLFP),1); repmat({'Canceled'},length(inputLFP),1);...
    repmat({'No-stop'},length(inputLFP),1); repmat({'Non-canceled'},length(inputLFP),1); repmat({'Canceled'},length(inputLFP),1)];
epochLabels = [repmat({'Baseline'},length(inputLFP)*3,1);repmat({'post-SSD'},length(inputLFP)*3,1)];
burstData = [baseline_nostop(inputLFP); baseline_noncanc(inputLFP); baseline_canceled(inputLFP);...
    ssd_nostop(inputLFP); ssd_noncanc(inputLFP); ssd_canceled(inputLFP)];

stoppingBoxplot_Figure(1,1)= gramm('x',groupLabels,'y',burstData,'color',epochLabels);
stoppingBoxplot_Figure(1,1).stat_summary('geom',{'point','errorbar'});
stoppingBoxplot_Figure(1,1).no_legend();
stoppingBoxplot_Figure(1,1).axe_property('YLim',[0.08 0.16]);

% Figure parameters & settings
stoppingBoxplot_Figure.set_names('y','');
stoppingBoxplot_Figure.set_color_options('map',[colors.canceled;colors.nostop;colors.noncanc]);

figure('Position',[100 100 350 350]);
stoppingBoxplot_Figure.draw();


%% Export to JASP
session = sessionLFPmap.session(corticalLFPcontacts.all);
monkey = sessionLFPmap.monkeyName(corticalLFPcontacts.all);

betaBurstTable = table(session, monkey,...
    baseline_canceled, baseline_noncanc, baseline_nostop,...
    ssd_canceled, ssd_noncanc, ssd_nostop);

writetable(betaBurstTable,...
    'D:\projectCode\project_stoppingLFP\data\exportJASP\LFP_pBurst_trial.csv','WriteRowNames',true)
