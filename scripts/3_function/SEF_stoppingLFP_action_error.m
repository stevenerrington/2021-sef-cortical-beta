parfor lfpIdx = 1:length(corticalLFPcontacts.all)
    
    lfp = corticalLFPcontacts.all(lfpIdx)
    session = sessionLFPmap.session(lfp);
    
    % Get session name (to load in relevant file)
    sessionName = FileNames{session};
    fprintf('Analysing LFP number %i of %i. \n',lfpIdx,length(corticalLFPcontacts.all));
    
    % Load in beta output data for session
    loadname = fullfile('betaBurst','saccade',['lfp_session' int2str(session) '_' sessionLFPmap.channelNames{lfp} '_betaOutput_saccade']);
    betaOutput = parload(fullfile(outputDir, loadname));
    
    % Get behavioral information
    ssrt = bayesianSSRT.ssrt_mean(session);
    
    % Get relevant trial information
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

%% Get key beta-burst information for...
% Non-canceled trials in the early period (0 to 300 ms)
errorBeta_early.timing.noncanc = SEF_stoppingLFP_getAverageBurstTimeError...
    (corticalLFPcontacts.all,executiveBeh.ttx.sNC, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold, [0 300],outputDir);

% No-stop trials in the early period (0 to 300 ms)
errorBeta_early.timing.nostop = SEF_stoppingLFP_getAverageBurstTimeError...
    (corticalLFPcontacts.all,executiveBeh.ttx.GO, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold, [0 300],outputDir);

% Non-canceled trials in the late period (300 to 600 ms)
errorBeta_late.timing.noncanc = SEF_stoppingLFP_getAverageBurstTimeError...
    (corticalLFPcontacts.all,executiveBeh.ttx.sNC, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold, [300 600],outputDir);

% No-stop trials in the late period (300 to 600 ms)
errorBeta_late.timing.nostop = SEF_stoppingLFP_getAverageBurstTimeError...
    (corticalLFPcontacts.all,executiveBeh.ttx.GO, bayesianSSRT, sessionLFPmap, sessionBLpower, burstThreshold, [300 600],outputDir);

%% Export burst information for use in JASP
% Early period (0 to 300 ms post-saccade) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
noncanceled_pBurst_early = errorBeta_early.timing.noncanc.pTrials_burst;
nostop_pBurst_early = errorBeta_early.timing.nostop.pTrials_burst;
noncanceled_pBurst_late = errorBeta_late.timing.noncanc.pTrials_burst;
nostop_pBurst_late = errorBeta_late.timing.nostop.pTrials_burst;

monkeyLabel = sessionLFPmap.monkeyName(corticalLFPcontacts.all);

error_pBurst_earlylate = table(monkeyLabel,noncanceled_pBurst_early,nostop_pBurst_early,...
    noncanceled_pBurst_late,nostop_pBurst_late);

writetable(error_pBurst_earlylate,...
    fullfile(matDir,'exportJASP','error_pBurst_earlylate.csv'),'WriteRowNames',true)



%% Produce error-related activity figure
clear error_figure
% Define channels for monkeys
allChannels = 1:length(corticalLFPcontacts.all);
euChannels = corticalLFPcontacts.subset.eu;
xChannels = corticalLFPcontacts.subset.x;

% Set time period to plot
time = [-1000:2000];

% Provide labels for trial types (as there are the same number of channels,
% these can be used for each time condition (early/late).
groupLabelsNoStop = repmat({'No-stop'},length(errorBeta_early.timing.nostop.pTrials_burst),1);
groupLabelsNonCanc = repmat({'Non-canceled'},length(errorBeta_early.timing.noncanc.pTrials_burst),1);

% Setup data: no-stop/non-canc for early/late periods
burstDataNoStop_early = [errorBeta_early.timing.nostop.pTrials_burst];
burstDataNonCanc_early = [errorBeta_early.timing.noncanc.pTrials_burst];
burstDataNoStop_late = [errorBeta_late.timing.nostop.pTrials_burst];
burstDataNonCanc_late = [errorBeta_late.timing.noncanc.pTrials_burst];

    % Input data into the gramm function.
    error_figure(1,1) = gramm('x',[groupLabelsNoStop(allChannels);groupLabelsNonCanc(allChannels)],...
        'y',[burstDataNoStop_early(allChannels);burstDataNonCanc_early(allChannels)],'color',[groupLabelsNoStop(allChannels);groupLabelsNonCanc(allChannels)]);
    error_figure(2,1) = gramm('x',[groupLabelsNoStop(euChannels);groupLabelsNonCanc(euChannels)],...
        'y',[burstDataNoStop_early(euChannels);burstDataNonCanc_early(euChannels)],'color',[groupLabelsNoStop(euChannels);groupLabelsNonCanc(euChannels)]);
    error_figure(3,1) = gramm('x',[groupLabelsNoStop(xChannels);groupLabelsNonCanc(xChannels)],...
        'y',[burstDataNoStop_early(xChannels);burstDataNonCanc_early(xChannels)],'color',[groupLabelsNoStop(xChannels);groupLabelsNonCanc(xChannels)]);
    error_figure(1,2) = gramm('x',[groupLabelsNoStop(allChannels);groupLabelsNonCanc(allChannels)],...
        'y',[burstDataNoStop_late(allChannels);burstDataNonCanc_late(allChannels)],'color',[groupLabelsNoStop(allChannels);groupLabelsNonCanc(allChannels)]);
    error_figure(2,2) = gramm('x',[groupLabelsNoStop(euChannels);groupLabelsNonCanc(euChannels)],...
        'y',[burstDataNoStop_late(euChannels);burstDataNonCanc_late(euChannels)],'color',[groupLabelsNoStop(euChannels);groupLabelsNonCanc(euChannels)]);
    error_figure(3,2) = gramm('x',[groupLabelsNoStop(xChannels);groupLabelsNonCanc(xChannels)],...
        'y',[burstDataNoStop_late(xChannels);burstDataNonCanc_late(xChannels)],'color',[groupLabelsNoStop(xChannels);groupLabelsNonCanc(xChannels)]);

    % Setup figure type
    % Early period:
    error_figure(1,1).stat_summary('geom',{'point','line','black_errorbar'}); 
    error_figure(2,1).stat_summary('geom',{'point','line','black_errorbar'}); 
    error_figure(3,1).stat_summary('geom',{'point','line','black_errorbar'});
    % Late period:
    error_figure(1,2).stat_summary('geom',{'point','line','black_errorbar'});
    error_figure(2,2).stat_summary('geom',{'point','line','black_errorbar'});
    error_figure(3,2).stat_summary('geom',{'point','line','black_errorbar'});

    % Define figure parameters
    error_figure(1,1).axe_property('YLim',[0.15 0.45]); error_figure(2,1).axe_property('YLim',[0.15 0.60]); error_figure(3,1).axe_property('YLim',[0.15 0.35]); 
    error_figure(1,2).axe_property('YLim',[0.15 0.45]); error_figure(2,2).axe_property('YLim',[0.15 0.60]); error_figure(3,2).axe_property('YLim',[0.15 0.35]); 
    error_figure(1,1).no_legend();error_figure(2,1).no_legend();error_figure(3,1).no_legend();
    error_figure(1,2).no_legend();error_figure(2,2).no_legend();error_figure(3,2).no_legend();
    error_figure.set_color_options('map',[colors.nostop;colors.noncanc]);
    error_figure.set_names('y','');

    % Generate figure
    figure('Renderer', 'painters', 'Position', [100 100 400 700]);
    error_figure.draw();








% 
% 
% 
% %% Archived
% clear noncanceled* nostop* meanBurstTimeTable*
% noncanceled_pBurst = errorBeta_early.timing.noncanc.pTrials_burst;
% noncanceledBurstTime = errorBeta_early.timing.noncanc.mean_burstTime;
% noncanceledBurstFreq = errorBeta_early.timing.noncanc.mean_burstFreq;
% noncanceledBurstOnset = errorBeta_early.timing.noncanc.mean_burstOnset;
% noncanceledBurstOffset = errorBeta_early.timing.noncanc.mean_burstOffset;
% noncanceledBurstDuration = errorBeta_early.timing.noncanc.mean_burstDuration;
% noncanceledBurstVolume = errorBeta_early.timing.noncanc.mean_burstVolume;
% 
% nostop_pBurst = errorBeta_early.timing.nostop.pTrials_burst;
% nostopBurstTime = errorBeta_early.timing.nostop.mean_burstTime;
% nostopBurstFreq = errorBeta_early.timing.nostop.mean_burstFreq;
% nostopBurstOnset = errorBeta_early.timing.nostop.mean_burstOnset;
% nostopBurstOffset = errorBeta_early.timing.nostop.mean_burstOffset;
% nostopBurstDuration = errorBeta_early.timing.nostop.mean_burstDuration;
% nostopBurstVolume = errorBeta_early.timing.nostop.mean_burstVolume;
% 
% monkeyLabel = sessionLFPmap.monkeyName(corticalLFPcontacts.all);
% 
% meanBurstTimeTable_early = table(noncanceled_pBurst, nostop_pBurst,...
%     noncanceledBurstTime, nostopBurstTime,...
%     noncanceledBurstOnset,nostopBurstOnset,...
%     noncanceledBurstOffset, nostopBurstOffset,...
%     noncanceledBurstDuration, nostopBurstDuration,...
%     noncanceledBurstVolume, nostopBurstVolume,...
%     noncanceledBurstFreq, nostopBurstFreq, monkeyLabel);
% 
% writetable(meanBurstTimeTable_early,...
%     'D:\projectCode\project_stoppingLFP\data\exportJASP\LFP_errorBurstProperties_0_300.csv','WriteRowNames',true)
% 
% % Late period (300 to 600 ms post-saccade) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% clear noncanceled* nostop* meanBurstTimeTable*
% 
% noncanceled_pBurst = errorBeta_late.timing.noncanc.pTrials_burst;
% noncanceledBurstTime = errorBeta_late.timing.noncanc.mean_burstTime;
% noncanceledBurstFreq = errorBeta_late.timing.noncanc.mean_burstFreq;
% noncanceledBurstOnset = errorBeta_late.timing.noncanc.mean_burstOnset;
% noncanceledBurstOffset = errorBeta_late.timing.noncanc.mean_burstOffset;
% noncanceledBurstDuration = errorBeta_late.timing.noncanc.mean_burstDuration;
% noncanceledBurstVolume = errorBeta_late.timing.noncanc.mean_burstVolume;
% 
% nostop_pBurst = errorBeta_late.timing.nostop.pTrials_burst;
% nostopBurstTime = errorBeta_late.timing.nostop.mean_burstTime;
% nostopBurstFreq = errorBeta_late.timing.nostop.mean_burstFreq;
% nostopBurstOnset = errorBeta_late.timing.nostop.mean_burstOnset;
% nostopBurstOffset = errorBeta_late.timing.nostop.mean_burstOffset;
% nostopBurstDuration = errorBeta_late.timing.nostop.mean_burstDuration;
% nostopBurstVolume = errorBeta_late.timing.nostop.mean_burstVolume;
% 
% monkeyLabel = sessionLFPmap.monkeyName(corticalLFPcontacts.all);
% 
% meanBurstTimeTable_late = table(noncanceled_pBurst, nostop_pBurst,...
%     noncanceledBurstTime, nostopBurstTime,...
%     noncanceledBurstOnset,nostopBurstOnset,...
%     noncanceledBurstOffset, nostopBurstOffset,...
%     noncanceledBurstDuration, nostopBurstDuration,...
%     noncanceledBurstVolume, nostopBurstVolume,...
%     noncanceledBurstFreq, nostopBurstFreq, monkeyLabel);
% 
% writetable(meanBurstTimeTable_late,...
%     'D:\projectCode\project_stoppingLFP\data\exportJASP\LFP_errorBurstProperties_300_600.csv','WriteRowNames',true)
