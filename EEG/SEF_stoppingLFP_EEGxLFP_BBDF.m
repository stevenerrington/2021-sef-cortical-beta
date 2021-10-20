window = [-500 1000];
binSize = 50;
times = window(1)+25:binSize:window(2)-25;

perpSessions = 14:29;

%% Get EEG average BBDF
parfor sessionIdx = 1:29
    session = sessionIdx;
    fprintf('Analysing session %i of %i. \n',session, 29)
    ssrt = round(bayesianSSRT.ssrt_mean(session));
    
    % Get EEG bursts %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    eegDir = 'D:\projectCode\project_stoppingEEG\data\monkeyEEG\';
    eeg_stopSignal = ['betaBurst\eeg_session' int2str(session) '_' FileNames{session} '_betaOutput_stopSignal'];
    eeg_saccade = ['betaBurst\eeg_session' int2str(session) '_' FileNames{session} '_betaOutput_saccade'];
    eeg_tone = ['betaBurst\eeg_session' int2str(session) '_' FileNames{session} '_betaOutput_tone'];
    
    % clear eegBetaBurst;
    eegBetaBurst_stopSignal = parload([eegDir eeg_stopSignal]);
    eegBetaBurst_saccade = parload([eegDir eeg_saccade]);
	eegBetaBurst_tone = parload([eegDir eeg_tone]);
    
    [eegBetaBurst_stopSignal] = thresholdBursts_EEG(eegBetaBurst_stopSignal.betaOutput, eegBetaBurst_stopSignal.betaOutput.medianLFPpower*6);
    [eegBetaBurst_saccade] = thresholdBursts_EEG(eegBetaBurst_saccade.betaOutput, eegBetaBurst_saccade.betaOutput.medianLFPpower*6);
	[eegBetaBurst_tone] = thresholdBursts_EEG(eegBetaBurst_tone.betaOutput, eegBetaBurst_tone.betaOutput.medianLFPpower*6);
    

    EEG_SessionBDF_stopSignal = BetaBurstConvolver(eegBetaBurst_stopSignal.burstData.burstTime);
    EEG_SessionBDF_saccade = BetaBurstConvolver(eegBetaBurst_saccade.burstData.burstTime);
    EEG_SessionBDF_tone = BetaBurstConvolver(eegBetaBurst_tone.burstData.burstTime);
    
    % Latency match BBDF  %%%%%%%%%%%%%%%%%%%%%%%%%%%
    c_temp_SSD = []; nc_temp_SSD = []; ns_temp_SSD = [];
    nc_temp_saccade = []; ns_temp_saccade = [];
    
    for ii = 1:length(executiveBeh.inh_SSD{session})
        c_temp_SSD(ii,:) = nanmean(EEG_SessionBDF_stopSignal(executiveBeh.ttm_CGO{session,ii}.C_matched, :));
        nc_temp_SSD(ii,:) = nanmean(EEG_SessionBDF_stopSignal(executiveBeh.ttm_c.NC{session,ii}.all, :));
        ns_temp_SSD(ii,:) = nanmean(EEG_SessionBDF_stopSignal(executiveBeh.ttm_CGO{session,ii}.GO_matched, :));
        
        nc_temp_saccade(ii,:) = nanmean(EEG_SessionBDF_saccade(executiveBeh.ttm_c.NC{session,ii}.all, :));
        ns_temp_saccade(ii,:) = nanmean(EEG_SessionBDF_saccade(executiveBeh.ttm_c.GO_NC{session,ii}.all, :));
    end
    
    
    EEGbbdf_canceled_stopSignal_unmatched{sessionIdx,1} = nanmean(EEG_SessionBDF_stopSignal(executiveBeh.ttx_canc{session}, :));
    EEGbbdf_noncanceled_stopSignal_unmatched{sessionIdx,1} = nanmean(EEG_SessionBDF_stopSignal(executiveBeh.ttx.NC{session}, :));
    EEGbbdf_nostop_stopSignal_unmatched{sessionIdx,1} = nanmean(EEG_SessionBDF_stopSignal(executiveBeh.ttx.GO{session}, :)); 
    
    EEGbbdf_canceled_stopSignal{sessionIdx,1} = nanmean(c_temp_SSD);
    EEGbbdf_noncanceled_stopSignal{sessionIdx,1} = nanmean(nc_temp_SSD);
    EEGbbdf_nostop_stopSignal{sessionIdx,1} = nanmean(ns_temp_SSD);   
    
    EEGbbdf_noncanceled_saccade{sessionIdx,1} = nanmean(nc_temp_saccade);
    EEGbbdf_nostop_saccade{sessionIdx,1} = nanmean(ns_temp_saccade);
    
    % SSRT (latency matched aligned)  %%%%%%%%%%%%%%%%%%%%%%%%%%%
    EEGbbdf_canceled_ssrt{sessionIdx,1} = EEGbbdf_canceled_stopSignal{sessionIdx,1}...
        (1000+ssrt+[-500:1000]);
    EEGbbdf_nostop_ssrt{sessionIdx,1} = EEGbbdf_nostop_stopSignal{sessionIdx,1}...
        (1000+ssrt+[-500:1000]);

    EEGbbdf_canceled_tone{sessionIdx,1} = nanmean(EEG_SessionBDF_tone(executiveBeh.ttx_canc{session}, :));
    EEGbbdf_noncanceled_tone{sessionIdx,1} = nanmean(EEG_SessionBDF_tone(executiveBeh.ttx.sNC{session}, :));
    EEGbbdf_nostop_tone{sessionIdx,1} = nanmean(EEG_SessionBDF_tone(executiveBeh.ttx.GO{session}, :));
    
end



%% Get LFP average BBDF
parfor lfpIdx = 1:length(corticalLFPcontacts.all)
    lfp = corticalLFPcontacts.all(lfpIdx);
    session = sessionLFPmap.session(lfp);
    ssrt = round(bayesianSSRT.ssrt_mean(session));
    
    bbdf = parload(['D:\projectCode\project_stoppingLFP\data\bbdf\bbdf_' int2str(lfpIdx)]);
    fprintf('Analysing LFP number %i of %i. \n',lfpIdx,length(corticalLFPcontacts.all));
    
    % Get behavioral information
    trials = [];
    trials.canceled = executiveBeh.ttx_canc{session};
    trials.noncanceled = executiveBeh.ttx.sNC{session};
    trials.nostop = executiveBeh.ttx.GO{session};
    
    
    % Tone aligned BBDF  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    LFPbbdf_canceled_tone{lfpIdx,1} = nanmean(bbdf.bbdf.tone(trials.canceled, :));
    LFPbbdf_noncanceled_tone{lfpIdx,1} = nanmean(bbdf.bbdf.tone(trials.noncanceled, :));
    LFPbbdf_nostop_tone{lfpIdx,1} = nanmean(bbdf.bbdf.tone(trials.nostop, :));
    
    
    % Stop-signal (latency matched aligned)  %%%%%%%%%%%%%%%%%%%%%%%%%%%
    c_temp = []; nc_temp = []; ns_temp = [];
    
    for ii = 1:length(executiveBeh.inh_SSD{session})
        c_temp(ii,:) = nanmean(bbdf.bbdf.ssd(executiveBeh.ttm_CGO{session,ii}.C_matched, :));
        nc_temp(ii,:) = nanmean(bbdf.bbdf.ssd(executiveBeh.ttm_c.NC{session,ii}.all, :));
        ns_temp(ii,:) = nanmean(bbdf.bbdf.ssd(executiveBeh.ttm_CGO{session,ii}.GO_matched, :));
    end
    
    LFPbbdf_canceled_stopSignal{lfpIdx,1} = nanmean(c_temp);
    LFPbbdf_noncanceled_stopSignal{lfpIdx,1} = nanmean(nc_temp);
    LFPbbdf_nostop_stopSignal{lfpIdx,1} = nanmean(ns_temp);   
    
    % SSRT (latency matched aligned)  %%%%%%%%%%%%%%%%%%%%%%%%%%%
    LFPbbdf_canceled_ssrt{lfpIdx,1} = LFPbbdf_canceled_stopSignal{lfpIdx,1}...
        (1000+ssrt+[-500:1000]);
    LFPbbdf_nostop_ssrt{lfpIdx,1} = LFPbbdf_nostop_stopSignal{lfpIdx,1}...
        (1000+ssrt+[-500:1000]);
    
    % Saccade (latency matched aligned)  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    nc_sacc_temp = []; ns_sacc_temp = [];
    
    for ii = 1:length(executiveBeh.inh_SSD{session})
        nc_sacc_temp(ii,:) = nanmean(bbdf.bbdf.saccade(executiveBeh.ttm_c.NC{session,ii}.all, :));
        ns_sacc_temp(ii,:) = nanmean(bbdf.bbdf.saccade(executiveBeh.ttm_c.GO_NC{session,ii}.all, :));
    end

    LFPbbdf_noncanceled_saccade{lfpIdx,1} = nanmean(nc_sacc_temp);
    LFPbbdf_nostop_saccade{lfpIdx,1} = nanmean(ns_sacc_temp);
    
end

%% Generate Figure

clear testfigure
time = [-1000:2000];
ssrt_time = [-500:1000];
% EEG %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SSD aligned
testfigure(1,1)=gramm('x',time,'y',[EEGbbdf_canceled_stopSignal;...
    EEGbbdf_nostop_stopSignal;EEGbbdf_noncanceled_stopSignal],...
    'color',[repmat({'Canceled'},length(EEGbbdf_canceled_stopSignal),1);...
    repmat({'No-stop'},length(EEGbbdf_nostop_stopSignal),1);...
    repmat({'Non-canceled'},length(EEGbbdf_noncanceled_stopSignal),1)]);
% SSRT aligned
testfigure(1,2)=gramm('x',ssrt_time,'y',[EEGbbdf_canceled_ssrt;...
    EEGbbdf_nostop_ssrt],...
    'color',[repmat({'Canceled'},length(EEGbbdf_canceled_ssrt),1);...
    repmat({'No-stop'},length(EEGbbdf_nostop_ssrt),1)]);
% Tone aligned
testfigure(1,3)=gramm('x',time,'y',[EEGbbdf_canceled_tone;...
    EEGbbdf_nostop_tone;EEGbbdf_noncanceled_tone],...
    'color',[repmat({'Canceled'},length(EEGbbdf_canceled_tone),1);...
    repmat({'No-stop'},length(EEGbbdf_nostop_tone),1);...
    repmat({'Non-canceled'},length(EEGbbdf_noncanceled_tone),1)]);
% Saccade aligned
testfigure(1,4)=gramm('x',time,'y',[EEGbbdf_noncanceled_saccade;...
    EEGbbdf_nostop_saccade],...
    'color',[repmat({'Non-canceled'},length(EEGbbdf_noncanceled_saccade),1);...
    repmat({'No-stop'},length(EEGbbdf_nostop_saccade),1)]);

% LFP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SSD aligned
testfigure(2,1)=gramm('x',time,'y',[LFPbbdf_canceled_stopSignal;...
    LFPbbdf_nostop_stopSignal;LFPbbdf_noncanceled_stopSignal],...
    'color',[repmat({'Canceled'},length(LFPbbdf_canceled_stopSignal),1);...
    repmat({'No-stop'},length(LFPbbdf_nostop_stopSignal),1);...
    repmat({'Non-canceled'},length(LFPbbdf_noncanceled_stopSignal),1)]);
% SSRT aligned
testfigure(2,2)=gramm('x',ssrt_time,'y',[LFPbbdf_canceled_ssrt;...
    LFPbbdf_nostop_ssrt],...
    'color',[repmat({'Canceled'},length(LFPbbdf_canceled_ssrt),1);...
    repmat({'No-stop'},length(LFPbbdf_nostop_ssrt),1)]);
% Tone aligned
testfigure(2,3)=gramm('x',time,'y',[LFPbbdf_canceled_tone;...
    LFPbbdf_nostop_tone;LFPbbdf_noncanceled_tone],...
    'color',[repmat({'Canceled'},length(LFPbbdf_canceled_tone),1);...
    repmat({'No-stop'},length(LFPbbdf_nostop_tone),1);...
    repmat({'Non-canceled'},length(LFPbbdf_noncanceled_tone),1)]);
% Saccade aligned
testfigure(2,4)=gramm('x',time,'y',[LFPbbdf_noncanceled_saccade;...
    LFPbbdf_nostop_saccade],...
    'color',[repmat({'Non-canceled'},length(LFPbbdf_noncanceled_saccade),1);...
    repmat({'No-stop'},length(LFPbbdf_nostop_saccade),1)]);


% GRAMM Setup %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SSD - EEG
testfigure(1,1).stat_summary(); testfigure(1,1).no_legend;
testfigure(1,1).axe_property('XLim',[-200 200]); testfigure(1,1).axe_property('YLim',[0.0000 0.0040]);
testfigure(1,1).geom_vline('xintercept',0,'style','k-');
testfigure(1,1).set_color_options('map',[colors.canceled;colors.nostop;colors.noncanc]);

% SSRT - EEG
testfigure(1,2).stat_summary(); testfigure(1,2).no_legend;
testfigure(1,2).axe_property('XLim',[-200 600]); testfigure(1,2).axe_property('YLim',[0.0000 0.0040]);
testfigure(1,2).geom_vline('xintercept',0,'style','k-');
testfigure(1,2).set_color_options('map',[colors.canceled;colors.nostop]);

% Tone - EEG
testfigure(1,3).stat_summary(); testfigure(1,3).no_legend;
testfigure(1,3).axe_property('XLim',[-600 200]); testfigure(1,3).axe_property('YLim',[0.0000 0.0040]);
testfigure(1,3).geom_vline('xintercept',0,'style','k-');
testfigure(1,3).set_color_options('map',[colors.canceled;colors.nostop;colors.noncanc]);

% Saccade - EEG
testfigure(1,4).stat_summary(); testfigure(1,4).no_legend;
testfigure(1,4).axe_property('XLim',[-200 600]); testfigure(1,4).axe_property('YLim',[0.0000 0.0040]);
testfigure(1,4).geom_vline('xintercept',0,'style','k-');
testfigure(1,4).set_color_options('map',[colors.nostop;colors.noncanc]);

% SSD - LFP
testfigure(2,1).stat_summary(); testfigure(2,1).no_legend;
testfigure(2,1).axe_property('XLim',[-200 200]); testfigure(2,1).axe_property('YLim',[0.0000 0.0020]);
testfigure(2,1).geom_vline('xintercept',0,'style','k-');
testfigure(2,1).set_color_options('map',[colors.canceled;colors.nostop;colors.noncanc]);

% SSRT - LFP
testfigure(2,2).stat_summary(); testfigure(2,2).no_legend;
testfigure(2,2).axe_property('XLim',[-200 600]); testfigure(2,2).axe_property('YLim',[0.0000 0.0020]);
testfigure(2,2).geom_vline('xintercept',0,'style','k-');
testfigure(2,2).set_color_options('map',[colors.canceled;colors.nostop]);

% Tone - LFP
testfigure(2,3).stat_summary(); testfigure(2,3).no_legend;
testfigure(2,3).axe_property('XLim',[-600 200]); testfigure(2,3).axe_property('YLim',[0.0000 0.0020]);
testfigure(2,3).geom_vline('xintercept',0,'style','k-');
testfigure(2,3).set_color_options('map',[colors.canceled;colors.nostop;colors.noncanc]);

% Saccade - LFP
testfigure(2,4).stat_summary(); testfigure(2,4).no_legend;
testfigure(2,4).axe_property('XLim',[-200 600]); testfigure(2,4).axe_property('YLim',[0.0000 0.0020]);
testfigure(2,4).geom_vline('xintercept',0,'style','k-');
testfigure(2,4).set_color_options('map',[colors.nostop;colors.noncanc]);


figure('Renderer', 'painters', 'Position', [100 100 1400 600]);
testfigure.draw();

