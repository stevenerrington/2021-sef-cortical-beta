errorWindow = [300 600];

%% GET BBDF
parfor lfpIdx = 1:length(corticalLFPcontacts.all)
    
    lfp = corticalLFPcontacts.all(lfpIdx)
    session = sessionLFPmap.session(lfp);
    
    % Get session name (to load in relevant file)
    sessionName = FileNames{session};
    fprintf('Analysing LFP number %i of %i. \n',lfpIdx,length(corticalLFPcontacts.all));
    
    % Load in beta output data for session
    loadname = ['betaBurst\saccade\lfp_session' int2str(session) '_' sessionLFPmap.channelNames{lfp} '_betaOutput_saccade'];
    betaOutput = parload([outputDir loadname])
    
    % Get behavioral information
    ssrt = bayesianSSRT.ssrt_mean(session);
    
    trials = [];
    trials.canceled = executiveBeh.ttx_canc{session};
    trials.noncanceled = executiveBeh.ttx.sNC{session};
    trials.nostop = executiveBeh.ttx.GO{session};
    
    % Calculate p(trials) with burst
    [betaOutput] = thresholdBursts(betaOutput.betaOutput, sessionBLpower(session)*burstThreshold)
    
    % Convolve and get density function
    SessionBDF = BetaBurstConvolver(betaOutput.burstData.burstTime);
        
     % Saccade (latency matched aligned)
    nc_sacc_temp = []; ns_sacc_temp = [];
    
    for ii = 1:length(executiveBeh.inh_SSD{session})
        nc_sacc_temp(ii,:) = nanmean(SessionBDF(executiveBeh.ttm_c.NC{session,ii}.all, :));
        ns_sacc_temp(ii,:) = nanmean(SessionBDF(executiveBeh.ttm_c.GO_NC{session,ii}.all, :));
    end

    saccade_bbdf_noncanceled{lfpIdx,1} = nanmean(nc_sacc_temp);
    saccade_bbdf_nostop{lfpIdx,1} = nanmean(ns_sacc_temp);
end

%% GET INFO TABLES
errorBeta.timing.noncanc = SEF_stoppingLFP_getAverageBurstTimeError...
    (corticalLFPcontacts.all,executiveBeh.ttx.sNC, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold);

errorBeta.timing.nostop = SEF_stoppingLFP_getAverageBurstTimeError...
    (corticalLFPcontacts.all,executiveBeh.ttx.GO, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold);


%% Export burst information for use in JASP

noncanceled_pBurst = errorBeta.timing.noncanc.pTrials_burst;
noncanceledBurstTime = errorBeta.timing.noncanc.mean_burstTime;
noncanceledBurstFreq = errorBeta.timing.noncanc.mean_burstFreq;
noncanceledBurstOnset = errorBeta.timing.noncanc.mean_burstOnset;
noncanceledBurstOffset = errorBeta.timing.noncanc.mean_burstOffset;
noncanceledBurstDuration = errorBeta.timing.noncanc.mean_burstDuration;
noncanceledBurstVolume = errorBeta.timing.noncanc.mean_burstVolume;

nostop_pBurst = errorBeta.timing.nostop.pTrials_burst;
nostopBurstTime = errorBeta.timing.nostop.mean_burstTime;
nostopBurstFreq = errorBeta.timing.nostop.mean_burstFreq;
nostopBurstOnset = errorBeta.timing.nostop.mean_burstOnset;
nostopBurstOffset = errorBeta.timing.nostop.mean_burstOffset;
nostopBurstDuration = errorBeta.timing.nostop.mean_burstDuration;
nostopBurstVolume = errorBeta.timing.nostop.mean_burstVolume;

monkeyLabel = sessionLFPmap.monkeyName(corticalLFPcontacts.all);

meanBurstTimeTable = table(noncanceled_pBurst, nostop_pBurst,...
    noncanceledBurstTime, nostopBurstTime,...
    noncanceledBurstOnset,nostopBurstOnset,...
    noncanceledBurstOffset, nostopBurstOffset,...
    noncanceledBurstDuration, nostopBurstDuration,...
    noncanceledBurstVolume, nostopBurstVolume,...
    noncanceledBurstFreq, nostopBurstFreq, monkeyLabel);

writetable(meanBurstTimeTable,...
    'D:\projectCode\project_stoppingLFP\data\exportJASP\LFP_errorBurstProperties_300_600.csv','WriteRowNames',true)


%% Produce error-related activity figure
clear error_figure
allChannels = 1:length(corticalLFPcontacts.all);
euChannels = corticalLFPcontacts.subset.eu;
xChannels = corticalLFPcontacts.subset.x;
time = [-1000:2000];

groupLabelsNoStop = repmat({'No-stop'},length(errorBeta.timing.nostop.pTrials_burst),1);
groupLabelsNonCanc = repmat({'Non-canceled'},length(errorBeta.timing.noncanc.pTrials_burst),1);

burstDataNoStop = [errorBeta.timing.nostop.pTrials_burst];
burstDataNonCanc = [errorBeta.timing.noncanc.pTrials_burst];

error_figure(1,1) = gramm('x',[groupLabelsNoStop(allChannels);groupLabelsNonCanc(allChannels)],...
    'y',[burstDataNoStop(allChannels);burstDataNonCanc(allChannels)],'color',[groupLabelsNoStop(allChannels);groupLabelsNonCanc(allChannels)]);
error_figure(1,2) = gramm('x',[groupLabelsNoStop(euChannels);groupLabelsNonCanc(euChannels)],...
    'y',[burstDataNoStop(euChannels);burstDataNonCanc(euChannels)],'color',[groupLabelsNoStop(euChannels);groupLabelsNonCanc(euChannels)]);
error_figure(1,3) = gramm('x',[groupLabelsNoStop(xChannels);groupLabelsNonCanc(xChannels)],...
    'y',[burstDataNoStop(xChannels);burstDataNonCanc(xChannels)],'color',[groupLabelsNoStop(xChannels);groupLabelsNonCanc(xChannels)]);

error_figure(1,1).stat_boxplot(); error_figure(1,1).geom_jitter('alpha',0.1,'dodge',0.75);
error_figure(1,2).stat_boxplot(); error_figure(1,2).geom_jitter('alpha',0.1,'dodge',0.75);
error_figure(1,3).stat_boxplot(); error_figure(1,3).geom_jitter('alpha',0.1,'dodge',0.75);

error_figure.set_names('y','');
error_figure(1,1).axe_property('YLim',[0 1.0]); error_figure(1,2).axe_property('YLim',[0 1.0]); error_figure(1,3).axe_property('YLim',[0 1.0]); 

error_figure(1,1).no_legend();error_figure(1,2).no_legend();error_figure(1,3).no_legend();

error_figure.set_color_options('map',[colors.nostop;colors.noncanc]);

figure('Renderer', 'painters', 'Position', [100 100 600 250]);
error_figure.draw();

