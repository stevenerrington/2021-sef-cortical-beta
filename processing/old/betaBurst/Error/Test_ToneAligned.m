errorWindow = [0 600];

%% GET BBDF
parfor lfpIdx = 1:length(corticalLFPcontacts.all)
    
    lfp = corticalLFPcontacts.all(lfpIdx)
    session = sessionLFPmap.session(lfp);
    
    % Get session name (to load in relevant file)
    sessionName = FileNames{session};
    fprintf('Analysing LFP number %i of 696. \n',lfp);
    
    % Load in beta output data for session
    loadname = ['betaBurst\tone\lfp_session' int2str(session) '_' sessionLFPmap.channelNames{lfp} '_betaOutput_tone'];
    betaOutput = parload([outputDir loadname])
    
    % Get behavioral information
    ssrt = bayesianSSRT.ssrt_mean(session);
    
    trials = [];
    trials.canceled = executiveBeh.ttx_canc{session};
    trials.noncanceled = executiveBeh.ttx.sNC{session};
    trials.nostop = executiveBeh.ttx.GO{session};
    
    % Calculate p(trials) with burst
    [betaOutput] = thresholdBursts(betaOutput.betaOutput, betaOutput.betaOutput.medianLFPpower*6)
    
    % Convolve and get density function
    SessionBDF = BetaBurstConvolver(betaOutput.burstData.burstTime);
    saccade_bbdf_canceled{lfpIdx,1} = nanmean(SessionBDF(executiveBeh.ttx_canc{session}, :));
    saccade_bbdf_noncanceled{lfpIdx,1} = nanmean(SessionBDF(executiveBeh.ttx.sNC{session}, :));
    saccade_bbdf_nostop{lfpIdx,1} = nanmean(SessionBDF(executiveBeh.ttx.GO{session}, :));
end

%% GET INFO TABLES
stoppingBeta.timing.noncanc = SEF_stoppingLFP_getAverageBurstTimeError...
    (corticalLFPcontacts.all,executiveBeh.ttx.sNC, sessionLFPmap, errorWindow);

stoppingBeta.timing.nostop = SEF_stoppingLFP_getAverageBurstTimeError...
    (corticalLFPcontacts.all,executiveBeh.ttx.GO, sessionLFPmap, errorWindow);



%% FIGURE
clear error_figure
allChannels = 1:length(corticalLFPcontacts.all);
euChannels = corticalLFPcontacts.subset.eu;
xChannels = corticalLFPcontacts.subset.x;
time = [-1000:2000];

error_figure(2,1)=gramm('x',time,'y',[saccade_bbdf_nostop(allChannels);saccade_bbdf_noncanceled(allChannels)],...
    'color',[repmat({'No-stop'},length(allChannels),1);repmat({'Non-canceled'},length(allChannels),1)]); 
error_figure(2,2)=gramm('x',time,'y',[saccade_bbdf_nostop(euChannels);saccade_bbdf_noncanceled(euChannels)],...
    'color',[repmat({'No-stop'},length(euChannels),1);repmat({'Non-canceled'},length(euChannels),1)]); 
error_figure(2,3)=gramm('x',time,'y',[saccade_bbdf_nostop(xChannels);saccade_bbdf_noncanceled(xChannels)],...
    'color',[repmat({'No-stop'},length(xChannels),1);repmat({'Non-canceled'},length(xChannels),1)]); 

error_figure(2,1).stat_summary();error_figure(2,2).stat_summary();error_figure(2,3).stat_summary();

error_figure.set_names('y','');
error_figure(2,:).axe_property('XLim',[-1000 1000]); 

error_figure(2,1).no_legend();error_figure(2,2).no_legend();error_figure(2,3).no_legend();

error_figure(2,1).geom_vline('xintercept',0,'style','k-')
error_figure(2,2).geom_vline('xintercept',0,'style','k-')
error_figure(2,3).geom_vline('xintercept',0,'style','k-')

error_figure.set_color_options('map',[colors.nostop;colors.noncanc]);


figure('Renderer', 'painters', 'Position', [100 100 600 350]);
error_figure.draw();
